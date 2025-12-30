/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

import './media/titlebarpart.css';
import { localize, localize2 } from '../../../../nls.js';
import { MultiWindowParts, Part } from '../../part.js';
import { ITitleService } from '../../../services/title/browser/titleService.js';
import { getWCOTitlebarAreaRect, getZoomFactor, isWCOEnabled } from '../../../../base/browser/browser.js';
import { MenuBarVisibility, getTitleBarStyle, getMenuBarVisibility, hasCustomTitlebar, hasNativeTitlebar, DEFAULT_CUSTOM_TITLEBAR_HEIGHT, getWindowControlsStyle, WindowControlsStyle, TitlebarStyle, MenuSettings, hasNativeMenu } from '../../../../platform/window/common/window.js';
import { IContextMenuService } from '../../../../platform/contextview/browser/contextView.js';
import { StandardMouseEvent } from '../../../../base/browser/mouseEvent.js';
import { IConfigurationService, IConfigurationChangeEvent } from '../../../../platform/configuration/common/configuration.js';
import { DisposableStore, IDisposable, MutableDisposable } from '../../../../base/common/lifecycle.js';
import { IBrowserWorkbenchEnvironmentService } from '../../../services/environment/browser/environmentService.js';
import { IThemeService, IColorTheme } from '../../../../platform/theme/common/themeService.js';
import { TITLE_BAR_ACTIVE_BACKGROUND, TITLE_BAR_ACTIVE_FOREGROUND, TITLE_BAR_INACTIVE_FOREGROUND, TITLE_BAR_INACTIVE_BACKGROUND, TITLE_BAR_BORDER, WORKBENCH_BACKGROUND } from '../../../common/theme.js';
import { isMacintosh, isWindows, isLinux, isWeb, isNative, platformLocale } from '../../../../base/common/platform.js';
import { Color } from '../../../../base/common/color.js';
import { EventType, EventHelper, Dimension, append, $, addDisposableListener, prepend, reset, getWindow, getWindowId, isAncestor, getActiveDocument, isHTMLElement } from '../../../../base/browser/dom.js';
import { CustomMenubarControl } from './menubarControl.js';
import { IInstantiationService, ServicesAccessor } from '../../../../platform/instantiation/common/instantiation.js';
import { Emitter, Event } from '../../../../base/common/event.js';
import { IStorageService, StorageScope } from '../../../../platform/storage/common/storage.js';
import { Parts, IWorkbenchLayoutService, ActivityBarPosition, LayoutSettings, EditorActionsLocation, EditorTabsMode } from '../../../services/layout/browser/layoutService.js';
import { createActionViewItem, fillInActionBarActions } from '../../../../platform/actions/browser/menuEntryActionViewItem.js';
import { Action2, IMenu, IMenuService, MenuId, registerAction2 } from '../../../../platform/actions/common/actions.js';
import { IContextKey, IContextKeyService } from '../../../../platform/contextkey/common/contextkey.js';
import { IHostService } from '../../../services/host/browser/host.js';
import { WindowTitle } from './windowTitle.js';
import { Categories } from '../../../../platform/action/common/actionCommonCategories.js';
import { WorkbenchToolBar } from '../../../../platform/actions/browser/toolbar.js';
import { ACCOUNTS_ACTIVITY_ID, GLOBAL_ACTIVITY_ID } from '../../../common/activity.js';
import { AccountsActivityActionViewItem, isAccountsActionVisible, SimpleAccountActivityActionViewItem, SimpleGlobalActivityActionViewItem } from '../globalCompositeBar.js';
import { HoverPosition } from '../../../../base/browser/ui/hover/hoverWidget.js';
import { IEditorGroupsContainer, IEditorGroupsService } from '../../../services/editor/common/editorGroupsService.js';
import { ActionRunner, IAction } from '../../../../base/common/actions.js';
import { IEditorService } from '../../../services/editor/common/editorService.js';
import { ActionsOrientation, IActionViewItem, prepareActions } from '../../../../base/browser/ui/actionbar/actionbar.js';
import { EDITOR_CORE_NAVIGATION_COMMANDS } from '../editor/editorCommands.js';
import { AnchorAlignment } from '../../../../base/browser/ui/contextview/contextview.js';
import { EditorPane } from '../editor/editorPane.js';
import { IKeybindingService } from '../../../../platform/keybinding/common/keybinding.js';
import { ResolvedKeybinding } from '../../../../base/common/keybindings.js';
import { EditorCommandsContextActionRunner } from '../editor/editorTabsControl.js';
import { IEditorCommandsContext, IEditorPartOptionsChangeEvent, IToolbarActions } from '../../../common/editor.js';
import { CodeWindow, mainWindow } from '../../../../base/browser/window.js';
import { ACCOUNTS_ACTIVITY_TILE_ACTION, GLOBAL_ACTIVITY_TITLE_ACTION } from './titlebarActions.js';
import { IView } from '../../../../base/browser/ui/grid/grid.js';
import { createInstantHoverDelegate } from '../../../../base/browser/ui/hover/hoverDelegateFactory.js';
import { IBaseActionViewItemOptions } from '../../../../base/browser/ui/actionbar/actionViewItems.js';
import { IHoverDelegate } from '../../../../base/browser/ui/hover/hoverDelegate.js';
import { CommandsRegistry } from '../../../../platform/commands/common/commands.js';
import { safeIntl } from '../../../../base/common/date.js';
import { IsCompactTitleBarContext, TitleBarVisibleContext } from '../../../common/contextkeys.js';
import { ActivityBarCompositeBar, ActivitybarPart } from '../activitybar/activitybarPart.js';
import { SidebarPart } from '../sidebar/sidebarPart.js';
import { IPaneCompositeBarOptions } from '../paneCompositeBar.js';
import { ACTIVITY_BAR_ACTIVE_BORDER, ACTIVITY_BAR_ACTIVE_BACKGROUND, ACTIVITY_BAR_BADGE_BACKGROUND, ACTIVITY_BAR_BADGE_FOREGROUND, ACTIVITY_BAR_INACTIVE_FOREGROUND, ACTIVITY_BAR_FOREGROUND, ACTIVITY_BAR_DRAG_AND_DROP_BORDER } from '../../../common/theme.js';
import { IExtensionService } from '../../../services/extensions/common/extensions.js';
import { IViewDescriptorService, ViewContainerLocation } from '../../../common/views.js';

export interface ITitleVariable {
	readonly name: string;
	readonly contextKey: string;
}

export interface ITitleProperties {
	isPure?: boolean;
	isAdmin?: boolean;
	prefix?: string;
}

export interface ITitlebarPart extends IDisposable {

	/**
	 * An event when the menubar visibility changes.
	 */
	readonly onMenubarVisibilityChange: Event<boolean>;

	/**
	 * Update some environmental title properties.
	 */
	updateProperties(properties: ITitleProperties): void;

	/**
	 * Adds variables to be supported in the window title.
	 */
	registerVariables(variables: ITitleVariable[]): void;
}

export class BrowserTitleService extends MultiWindowParts<BrowserTitlebarPart> implements ITitleService {

	declare _serviceBrand: undefined;

	readonly mainPart: BrowserTitlebarPart;

	constructor(
		@IInstantiationService protected readonly instantiationService: IInstantiationService,
		@IStorageService storageService: IStorageService,
		@IThemeService themeService: IThemeService
	) {
		super('workbench.titleService', themeService, storageService);

		this.mainPart = this._register(this.createMainTitlebarPart());
		this.onMenubarVisibilityChange = this.mainPart.onMenubarVisibilityChange;
		this._register(this.registerPart(this.mainPart));

		this.registerActions();
		this.registerAPICommands();
	}

	protected createMainTitlebarPart(): BrowserTitlebarPart {
		return this.instantiationService.createInstance(MainBrowserTitlebarPart);
	}

	private registerActions(): void {

		// Focus action
		const that = this;
		this._register(registerAction2(class FocusTitleBar extends Action2 {

			constructor() {
				super({
					id: `workbench.action.focusTitleBar`,
					title: localize2('focusTitleBar', 'Focus Title Bar'),
					category: Categories.View,
					f1: true,
					precondition: TitleBarVisibleContext
				});
			}

			run(): void {
				that.getPartByDocument(getActiveDocument())?.focus();
			}
		}));
	}

	private registerAPICommands(): void {
		this._register(CommandsRegistry.registerCommand({
			id: 'registerWindowTitleVariable',
			handler: (accessor: ServicesAccessor, name: string, contextKey: string) => {
				this.registerVariables([{ name, contextKey }]);
			},
			metadata: {
				description: 'Registers a new title variable',
				args: [
					{ name: 'name', schema: { type: 'string' }, description: 'The name of the variable to register' },
					{ name: 'contextKey', schema: { type: 'string' }, description: 'The context key to use for the value of the variable' }
				]
			}
		}));
	}

	//#region Auxiliary Titlebar Parts

	createAuxiliaryTitlebarPart(container: HTMLElement, editorGroupsContainer: IEditorGroupsContainer, instantiationService: IInstantiationService): IAuxiliaryTitlebarPart {
		const titlebarPartContainer = $('.part.titlebar', { role: 'none' });
		titlebarPartContainer.style.position = 'relative';
		container.insertBefore(titlebarPartContainer, container.firstChild); // ensure we are first element

		const disposables = new DisposableStore();

		const titlebarPart = this.doCreateAuxiliaryTitlebarPart(titlebarPartContainer, editorGroupsContainer, instantiationService);
		disposables.add(this.registerPart(titlebarPart));

		disposables.add(Event.runAndSubscribe(titlebarPart.onDidChange, () => titlebarPartContainer.style.height = `${titlebarPart.height}px`));
		titlebarPart.create(titlebarPartContainer);

		if (this.properties) {
			titlebarPart.updateProperties(this.properties);
		}

		if (this.variables.size) {
			titlebarPart.registerVariables(Array.from(this.variables.values()));
		}

		Event.once(titlebarPart.onWillDispose)(() => disposables.dispose());

		return titlebarPart;
	}

	protected doCreateAuxiliaryTitlebarPart(container: HTMLElement, editorGroupsContainer: IEditorGroupsContainer, instantiationService: IInstantiationService): BrowserTitlebarPart & IAuxiliaryTitlebarPart {
		return instantiationService.createInstance(AuxiliaryBrowserTitlebarPart, container, editorGroupsContainer, this.mainPart);
	}

	//#endregion


	//#region Service Implementation

	readonly onMenubarVisibilityChange: Event<boolean>;

	private properties: ITitleProperties | undefined = undefined;

	updateProperties(properties: ITitleProperties): void {
		this.properties = properties;

		for (const part of this.parts) {
			part.updateProperties(properties);
		}
	}

	private readonly variables = new Map<string, ITitleVariable>();

	registerVariables(variables: ITitleVariable[]): void {
		const newVariables: ITitleVariable[] = [];

		for (const variable of variables) {
			if (!this.variables.has(variable.name)) {
				this.variables.set(variable.name, variable);
				newVariables.push(variable);
			}
		}

		for (const part of this.parts) {
			part.registerVariables(newVariables);
		}
	}

	//#endregion
}

export class BrowserTitlebarPart extends Part implements ITitlebarPart {

	//#region IView

	readonly minimumWidth: number = 0;
	readonly maximumWidth: number = Number.POSITIVE_INFINITY;

	get minimumHeight(): number {
		const wcoEnabled = isWeb && isWCOEnabled();
		let value = this.isCommandCenterVisible || wcoEnabled ? DEFAULT_CUSTOM_TITLEBAR_HEIGHT : 30;
		if (wcoEnabled) {
			value = Math.max(value, getWCOTitlebarAreaRect(getWindow(this.element))?.height ?? 0);
		}

		return value / (this.preventZoom ? getZoomFactor(getWindow(this.element)) : 1);
	}

	get maximumHeight(): number { return this.minimumHeight; }

	//#endregion

	//#region Events

	private _onMenubarVisibilityChange = this._register(new Emitter<boolean>());
	readonly onMenubarVisibilityChange = this._onMenubarVisibilityChange.event;

	private readonly _onWillDispose = this._register(new Emitter<void>());
	readonly onWillDispose = this._onWillDispose.event;

	//#endregion

	protected rootContainer!: HTMLElement;
	protected windowControlsContainer: HTMLElement | undefined;

	protected dragRegion: HTMLElement | undefined;
	private title!: HTMLElement;

	private leftContent!: HTMLElement;
	private centerContent!: HTMLElement;
	private rightContent!: HTMLElement;

	protected readonly customMenubar = this._register(new MutableDisposable<CustomMenubarControl>());
	protected appIcon: HTMLElement | undefined;
	private appIconBadge: HTMLElement | undefined;
	protected menubar?: HTMLElement;
	private lastLayoutDimensions: Dimension | undefined;

	private actionToolBar!: WorkbenchToolBar;
	private readonly actionToolBarDisposable = this._register(new DisposableStore());
	private readonly editorActionsChangeDisposable = this._register(new DisposableStore());
	private actionToolBarElement!: HTMLElement;

	private globalToolbarMenu: IMenu | undefined;
	private layoutToolbarMenu: IMenu | undefined;

	private readonly globalToolbarMenuDisposables = this._register(new DisposableStore());
	private readonly editorToolbarMenuDisposables = this._register(new DisposableStore());
	private readonly layoutToolbarMenuDisposables = this._register(new DisposableStore());
	private readonly activityToolbarDisposables = this._register(new DisposableStore());
	
	// ElixIDE: Activity bar horizontal en titlebar
	private titlebarActivityBarContainer: HTMLElement | undefined;
	private titlebarActivityBar: ActivityBarCompositeBar | undefined;

	private readonly hoverDelegate: IHoverDelegate;

	private readonly titleDisposables = this._register(new DisposableStore());
	private titleBarStyle: TitlebarStyle;

	private isInactive: boolean = false;

	private readonly isAuxiliary: boolean;
	private isCompact = false;

	private readonly isCompactContextKey: IContextKey<boolean>;

	private readonly windowTitle: WindowTitle;

	constructor(
		id: string,
		targetWindow: CodeWindow,
		private readonly editorGroupsContainer: IEditorGroupsContainer,
		@IContextMenuService private readonly contextMenuService: IContextMenuService,
		@IConfigurationService protected readonly configurationService: IConfigurationService,
		@IBrowserWorkbenchEnvironmentService protected readonly environmentService: IBrowserWorkbenchEnvironmentService,
		@IInstantiationService protected readonly instantiationService: IInstantiationService,
		@IThemeService themeService: IThemeService,
		@IStorageService private readonly storageService: IStorageService,
		@IWorkbenchLayoutService layoutService: IWorkbenchLayoutService,
		@IContextKeyService protected readonly contextKeyService: IContextKeyService,
		@IHostService private readonly hostService: IHostService,
		@IEditorGroupsService editorGroupsService: IEditorGroupsService,
		@IEditorService private readonly editorService: IEditorService,
		@IMenuService private readonly menuService: IMenuService,
		@IKeybindingService private readonly keybindingService: IKeybindingService,
		@IExtensionService private readonly extensionService: IExtensionService,
		@IViewDescriptorService private readonly viewDescriptorService: IViewDescriptorService,
	) {
		super(id, { hasTitle: false }, themeService, storageService, layoutService);

		// ElixIDE: Usar editorGroupsService para evitar error de compilación
		void editorGroupsService;

		this.isAuxiliary = targetWindow.vscodeWindowId !== mainWindow.vscodeWindowId;

		this.isCompactContextKey = IsCompactTitleBarContext.bindTo(this.contextKeyService);

		this.titleBarStyle = getTitleBarStyle(this.configurationService);

		this.windowTitle = this._register(instantiationService.createInstance(WindowTitle, targetWindow));

		this.hoverDelegate = this._register(createInstantHoverDelegate());

		this.registerListeners(getWindowId(targetWindow));
	}

	private registerListeners(targetWindowId: number): void {
		this._register(this.hostService.onDidChangeFocus(focused => focused ? this.onFocus() : this.onBlur()));
		this._register(this.hostService.onDidChangeActiveWindow(windowId => windowId === targetWindowId ? this.onFocus() : this.onBlur()));
		this._register(this.configurationService.onDidChangeConfiguration(e => this.onConfigurationChanged(e)));
		this._register(this.editorGroupsContainer.onDidChangeEditorPartOptions(e => this.onEditorPartConfigurationChange(e)));
	}

	private onBlur(): void {
		this.isInactive = true;

		this.updateStyles();
	}

	private onFocus(): void {
		this.isInactive = false;

		this.updateStyles();
	}

	private onEditorPartConfigurationChange({ oldPartOptions, newPartOptions }: IEditorPartOptionsChangeEvent): void {
		if (
			oldPartOptions.editorActionsLocation !== newPartOptions.editorActionsLocation ||
			oldPartOptions.showTabs !== newPartOptions.showTabs
		) {
			if (hasCustomTitlebar(this.configurationService, this.titleBarStyle) && this.actionToolBar) {
				this.createActionToolBar();
				this.createActionToolBarMenus({ editorActions: true });
				this._onDidChange.fire(undefined);
			}
		}
	}

	protected onConfigurationChanged(event: IConfigurationChangeEvent): void {

		// Custom menu bar (disabled if auxiliary)
		if (!this.isAuxiliary && !hasNativeMenu(this.configurationService, this.titleBarStyle) && (!isMacintosh || isWeb)) {
			if (event.affectsConfiguration(MenuSettings.MenuBarVisibility)) {
				if (this.currentMenubarVisibility === 'compact') {
					this.uninstallMenubar();
				} else {
					this.installMenubar();
				}
			}
		}

		// Actions
		if (hasCustomTitlebar(this.configurationService, this.titleBarStyle) && this.actionToolBar) {
			const affectsLayoutControl = event.affectsConfiguration(LayoutSettings.LAYOUT_ACTIONS);
			const affectsActivityControl = event.affectsConfiguration(LayoutSettings.ACTIVITY_BAR_LOCATION);

			if (affectsLayoutControl || affectsActivityControl) {
				this.createActionToolBarMenus({ layoutActions: affectsLayoutControl, activityActions: affectsActivityControl });

				this._onDidChange.fire(undefined);
			}
		}

		// Command Center
		if (event.affectsConfiguration(LayoutSettings.COMMAND_CENTER)) {
			this.recreateTitle();
		}
	}

	private recreateTitle(): void {
		this.createTitle();

		this._onDidChange.fire(undefined);
	}

	updateOptions(options: { compact: boolean }): void {
		const oldIsCompact = this.isCompact;
		this.isCompact = options.compact;

		this.isCompactContextKey.set(this.isCompact);

		if (oldIsCompact !== this.isCompact) {
			this.recreateTitle();
			this.createActionToolBarMenus(true);
		}
	}

	protected installMenubar(): void {
		if (this.menubar) {
			return; // If the menubar is already installed, skip
		}

		this.customMenubar.value = this.instantiationService.createInstance(CustomMenubarControl);

		this.menubar = append(this.leftContent, $('div.menubar'));
		this.menubar.setAttribute('role', 'menubar');

		this._register(this.customMenubar.value.onVisibilityChange(e => this.onMenubarVisibilityChanged(e)));

		this.customMenubar.value.create(this.menubar);
	}

	private uninstallMenubar(): void {
		this.customMenubar.value = undefined;

		this.menubar?.remove();
		this.menubar = undefined;

		this.onMenubarVisibilityChanged(false);
	}

	protected onMenubarVisibilityChanged(visible: boolean): void {
		if (isWeb || isWindows || isLinux) {
			if (this.lastLayoutDimensions) {
				this.layout(this.lastLayoutDimensions.width, this.lastLayoutDimensions.height);
			}

			this._onMenubarVisibilityChange.fire(visible);
		}
	}

	updateProperties(properties: ITitleProperties): void {
		this.windowTitle.updateProperties(properties);
	}

	registerVariables(variables: ITitleVariable[]): void {
		this.windowTitle.registerVariables(variables);
	}

	protected override createContentArea(parent: HTMLElement): HTMLElement {
		this.element = parent;
		this.rootContainer = append(parent, $('.titlebar-container'));
		
		// ElixIDE: Agregar clase has-center para que el CSS se aplique correctamente
		this.rootContainer.classList.add('has-center');

		this.leftContent = append(this.rootContainer, $('.titlebar-left'));
		this.centerContent = append(this.rootContainer, $('.titlebar-center'));
		this.rightContent = append(this.rootContainer, $('.titlebar-right'));

		// App Icon (Windows, Linux)
		if ((isWindows || isLinux) && !hasNativeTitlebar(this.configurationService, this.titleBarStyle)) {
			this.appIcon = prepend(this.leftContent, $('a.window-appicon'));
		}

		// Draggable region that we can manipulate for #52522
		this.dragRegion = prepend(this.rootContainer, $('div.titlebar-drag-region'));

		// Menubar: install a custom menu bar depending on configuration
		if (
			!this.isAuxiliary &&
			!hasNativeMenu(this.configurationService, this.titleBarStyle) &&
			(!isMacintosh || isWeb) &&
			this.currentMenubarVisibility !== 'compact'
		) {
			this.installMenubar();
		}

		// ElixIDE: Ocultar título de ventana - será reemplazado por activity bar
		this.title = append(this.centerContent, $('div.window-title'));
		this.title.style.display = 'none';
		
		// ElixIDE: Asegurar que centerContent sea visible y tenga el tamaño correcto
		// IMPORTANTE: centerContent debe ocupar el espacio central del titlebar
		this.centerContent.style.display = 'flex';
		this.centerContent.style.visibility = 'visible';
		this.centerContent.style.width = '100%';
		this.centerContent.style.height = '100%';
		this.centerContent.style.flexGrow = '1';
		this.centerContent.style.flexShrink = '1';
		this.centerContent.style.minWidth = '0';
		this.centerContent.style.justifyContent = 'center';
		this.centerContent.style.alignItems = 'center';
		this.centerContent.style.overflow = 'visible';
		
		// ElixIDE: Crear contenedor para activity bar horizontal en titlebar
		// Este contenedor reemplazará completamente el título de ventana
		this.titlebarActivityBarContainer = append(this.centerContent, $('div.titlebar-activity-bar'));
		// ElixIDE: Agregar clase para CSS
		this.titlebarActivityBarContainer.classList.add('titlebar-activity-bar');
		// ElixIDE: Accesibilidad - Etiquetas ARIA
		this.titlebarActivityBarContainer.setAttribute('role', 'toolbar');
		this.titlebarActivityBarContainer.setAttribute('aria-label', 'Activity Bar');
		// ElixIDE: Asegurar que el contenedor sea visible y centrado
		// CRÍTICO: Debe ocupar todo el espacio disponible en centerContent
		this.titlebarActivityBarContainer.style.display = 'flex';
		this.titlebarActivityBarContainer.style.visibility = 'visible';
		this.titlebarActivityBarContainer.style.justifyContent = 'center';
		this.titlebarActivityBarContainer.style.alignItems = 'center';
		this.titlebarActivityBarContainer.style.width = '100%';
		this.titlebarActivityBarContainer.style.height = '100%';
		this.titlebarActivityBarContainer.style.minHeight = '30px';
		this.titlebarActivityBarContainer.style.position = 'relative';
		this.titlebarActivityBarContainer.style.zIndex = '10';
		this.titlebarActivityBarContainer.style.overflow = 'visible';
		this.titlebarActivityBarContainer.style.flexGrow = '1';
		this.titlebarActivityBarContainer.style.flexShrink = '1';
		this.titlebarActivityBarContainer.style.minWidth = '0';
		
		console.log('[ElixIDE] ✅ Created titlebarActivityBarContainer in centerContent', {
			container: this.titlebarActivityBarContainer,
			parent: this.centerContent,
			parentClasses: this.centerContent.className,
			containerClasses: this.titlebarActivityBarContainer.className,
			parentVisible: this.centerContent.style.display !== 'none' && this.centerContent.style.visibility !== 'hidden',
			containerVisible: this.titlebarActivityBarContainer.style.display !== 'none' && this.titlebarActivityBarContainer.style.visibility !== 'hidden',
			parentWidth: this.centerContent.style.width,
			containerWidth: this.titlebarActivityBarContainer.style.width
		});
		// ElixIDE: Retrasar la creación de la activity bar hasta que el layout esté inicializado
		// Usar múltiples estrategias para asegurar que se cree correctamente
		console.log('[ElixIDE] Setting up activity bar creation in titlebar');
		
		// ElixIDE: Verificar que el contenedor esté en el DOM y sea visible
		setTimeout(() => {
			if (this.titlebarActivityBarContainer) {
				const isInDOM = document.body.contains(this.titlebarActivityBarContainer) || 
				               this.rootContainer.contains(this.titlebarActivityBarContainer) ||
				               this.centerContent.contains(this.titlebarActivityBarContainer);
				const computedStyle = window.getComputedStyle(this.titlebarActivityBarContainer);
				console.log('[ElixIDE] 🔍 Container verification:', {
					exists: !!this.titlebarActivityBarContainer,
					inDOM: isInDOM,
					display: computedStyle.display,
					visibility: computedStyle.visibility,
					width: computedStyle.width,
					height: computedStyle.height,
					opacity: computedStyle.opacity,
					zIndex: computedStyle.zIndex,
					parent: this.centerContent,
					parentDisplay: window.getComputedStyle(this.centerContent).display,
					parentVisibility: window.getComputedStyle(this.centerContent).visibility
				});
			}
		}, 100);
		
		// Estrategia 1: requestAnimationFrame inmediato
		requestAnimationFrame(() => {
			// Intentar crear la activity bar, con reintentos si SidebarPart no está disponible
			let attempts = 0;
			const maxAttempts = 50; // Aumentar intentos significativamente
			const tryCreate = () => {
				console.log(`[ElixIDE] 🔄 Attempt ${attempts + 1}/${maxAttempts} to create activity bar`);
				
				// Verificar que el contenedor exista y sea visible antes de intentar crear
				if (!this.titlebarActivityBarContainer) {
					console.error('[ElixIDE] ❌ titlebarActivityBarContainer is null!');
					attempts++;
					if (attempts < maxAttempts) {
						setTimeout(tryCreate, 200);
					}
					return;
				}
				
				// Verificar visibilidad del contenedor
				const containerStyle = window.getComputedStyle(this.titlebarActivityBarContainer);
				if (containerStyle.display === 'none' || containerStyle.visibility === 'hidden') {
					console.warn('[ElixIDE] ⚠️ Container is hidden, forcing visibility');
					this.titlebarActivityBarContainer.style.display = 'flex';
					this.titlebarActivityBarContainer.style.visibility = 'visible';
				}
				
				if (this.createTitlebarActivityBar()) {
					console.log('[ElixIDE] ✅ Activity bar created successfully!');
					
					// CRÍTICO: Esperar a que las extensiones se registren antes de verificar los action items
					// El PaneCompositeBar espera a whenInstalledExtensionsRegistered() antes de renderizar botones
					this.extensionService.whenInstalledExtensionsRegistered().then(() => {
						console.log('[ElixIDE] 📦 Extensions registered, checking action items...');
						
						// Verificar después de que las extensiones se registren
						setTimeout(() => {
							const actionItems = this.titlebarActivityBarContainer?.querySelectorAll('.action-item');
							const actionBar = this.titlebarActivityBarContainer?.querySelector('.monaco-action-bar');
							console.log('[ElixIDE] 📊 Action bar status after extensions registered:', {
								actionItems: actionItems?.length || 0,
								hasActionBar: !!actionBar,
								containerVisible: window.getComputedStyle(this.titlebarActivityBarContainer!).display !== 'none',
								actionBarVisible: actionBar ? window.getComputedStyle(actionBar).display !== 'none' : false
							});
							
							if (actionItems && actionItems.length === 0) {
								console.warn('[ElixIDE] ⚠️ No action items found after extensions registered');
								console.warn('[ElixIDE] Container HTML:', this.titlebarActivityBarContainer?.innerHTML.substring(0, 500));
								
								// CRÍTICO: Forzar registro manual de view containers
								console.log('[ElixIDE] 🔧 Attempting to force register view containers...');
								this.forceRegisterViewContainers().catch(err => {
									console.error('[ElixIDE] ❌ Error in forceRegisterViewContainers:', err);
								});
								
								// Intentar forzar el renderizado si aún no hay items
								if (actionBar) {
									const actionBarElement = actionBar as HTMLElement;
									actionBarElement.style.display = 'flex';
									actionBarElement.style.visibility = 'visible';
									console.log('[ElixIDE] 🔧 Forced action bar visibility');
								}
								
								// Verificar nuevamente después de forzar registro
								setTimeout(() => {
									const actionItemsAfter = this.titlebarActivityBarContainer?.querySelectorAll('.action-item');
									if (actionItemsAfter && actionItemsAfter.length > 0) {
										console.log('[ElixIDE] ✅ Action items found after forced registration:', actionItemsAfter.length);
										// Asegurar que todos los items sean visibles
										actionItemsAfter.forEach((item: Element) => {
											const el = item as HTMLElement;
											el.style.display = 'flex';
											el.style.visibility = 'visible';
											el.style.opacity = '1';
										});
									} else {
										console.error('[ElixIDE] ❌ Still no action items after forced registration');
									}
								}, 1000);
							} else if (actionItems && actionItems.length > 0) {
								console.log('[ElixIDE] ✅ Action items found:', actionItems.length);
								// Asegurar que todos los items sean visibles
								actionItems.forEach((item: Element) => {
									const el = item as HTMLElement;
									el.style.display = 'flex';
									el.style.visibility = 'visible';
									el.style.opacity = '1';
								});
							}
						}, 1000); // Dar tiempo adicional después de que se registren las extensiones
					}).catch(err => {
						console.error('[ElixIDE] ❌ Error waiting for extensions:', err);
					});
					
					return; // Éxito
				}
				attempts++;
				if (attempts < maxAttempts) {
					setTimeout(tryCreate, 200); // Reintentar después de 200ms
				} else {
					console.error('[ElixIDE] ❌ Failed to create activity bar in titlebar after', maxAttempts, 'attempts');
					// Intentar una última vez después de más tiempo
					setTimeout(() => {
						console.log('[ElixIDE] 🔄 Final attempt to create activity bar');
						this.createTitlebarActivityBar();
					}, 2000);
				}
			};
			tryCreate();
		});
		
		// Estrategia 2: También intentar después de que el layout se complete
		this._register(this.layoutService.onDidChangePartVisibility(() => {
			// Si aún no se ha creado, intentar crear
			if (!this.titlebarActivityBar) {
				console.log('[ElixIDE] Layout visibility changed, attempting to create activity bar');
				setTimeout(() => {
					this.createTitlebarActivityBar();
				}, 100);
			} else {
				// Si ya existe, verificar que los botones estén visibles
				setTimeout(() => {
					const actionItems = this.titlebarActivityBarContainer?.querySelectorAll('.action-item');
					if (actionItems && actionItems.length === 0) {
						console.warn('[ElixIDE] Activity bar exists but no action items found, may need to wait for extensions');
					}
				}, 500);
			}
		}));

		// Create Toolbar Actions
		if (hasCustomTitlebar(this.configurationService, this.titleBarStyle)) {
			this.actionToolBarElement = append(this.rightContent, $('div.action-toolbar-container'));
			this.createActionToolBar();
			this.createActionToolBarMenus();
		}

		// Window Controls Container
		if (!hasNativeTitlebar(this.configurationService, this.titleBarStyle)) {
			let primaryWindowControlsLocation = isMacintosh ? 'left' : 'right';
			if (isMacintosh && isNative) {

				// Check if the locale is RTL, macOS will move traffic lights in RTL locales
				// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Intl/Locale/textInfo

				const localeInfo = safeIntl.Locale(platformLocale).value;
				const textInfo = (localeInfo as { textInfo?: unknown }).textInfo;
				if (textInfo && typeof textInfo === 'object' && 'direction' in textInfo && textInfo.direction === 'rtl') {
					primaryWindowControlsLocation = 'right';
				}
			}

			if (isMacintosh && isNative && primaryWindowControlsLocation === 'left') {
				// macOS native: controls are on the left and the container is not needed to make room
				// for something, except for web where a custom menu being supported). not putting the
				// container helps with allowing to move the window when clicking very close to the
				// window control buttons.
			} else if (getWindowControlsStyle(this.configurationService) === WindowControlsStyle.HIDDEN) {
				// Linux/Windows: controls are explicitly disabled
			} else {
				this.windowControlsContainer = append(primaryWindowControlsLocation === 'left' ? this.leftContent : this.rightContent, $('div.window-controls-container'));
				if (isWeb) {
					// Web: its possible to have control overlays on both sides, for example on macOS
					// with window controls on the left and PWA controls on the right.
					append(primaryWindowControlsLocation === 'left' ? this.rightContent : this.leftContent, $('div.window-controls-container'));
				}

				if (isWCOEnabled()) {
					this.windowControlsContainer.classList.add('wco-enabled');
				}
			}
		}

		// Context menu over title bar: depending on the OS and the location of the click this will either be
		// the overall context menu for the entire title bar or a specific title context menu.
		// Windows / Linux: we only support the overall context menu on the title bar
		// macOS: we support both the overall context menu and the title context menu.
		//        in addition, we allow Cmd+click to bring up the title context menu.
		{
			this._register(addDisposableListener(this.rootContainer, EventType.CONTEXT_MENU, e => {
				EventHelper.stop(e);

				let targetMenu: MenuId;
				if (isMacintosh && isHTMLElement(e.target) && isAncestor(e.target, this.title)) {
					targetMenu = MenuId.TitleBarTitleContext;
				} else {
					targetMenu = MenuId.TitleBarContext;
				}

				this.onContextMenu(e, targetMenu);
			}));

			if (isMacintosh) {
				this._register(addDisposableListener(this.title, EventType.MOUSE_DOWN, e => {
					if (e.metaKey) {
						EventHelper.stop(e, true /* stop bubbling to prevent command center from opening */);

						this.onContextMenu(e, MenuId.TitleBarTitleContext);
					}
				}, true /* capture phase to prevent command center from opening */));
			}
		}

		this.updateStyles();

		return this.element;
	}

	private createTitle(): void {
		this.titleDisposables.clear();

		// ElixIDE: Ocultar completamente el título - será reemplazado por activity bar
		// El título no se mostrará en la titlebar
		reset(this.title);
		this.title.style.display = 'none';
		
		// ElixIDE: Código original comentado - el título se oculta para dar espacio a la activity bar
		// const isShowingTitleInNativeTitlebar = hasNativeTitlebar(this.configurationService, this.titleBarStyle);
		// 
		// // Text Title
		// if (!this.isCommandCenterVisible) {
		// 	if (!isShowingTitleInNativeTitlebar) {
		// 		this.title.textContent = this.windowTitle.value;
		// 		this.titleDisposables.add(this.windowTitle.onDidChange(() => {
		// 			this.title.textContent = this.windowTitle.value;
		// 			if (this.lastLayoutDimensions) {
		// 				this.updateLayout(this.lastLayoutDimensions);
		// 			}
		// 		}));
		// 	} else {
		// 		reset(this.title);
		// 	}
		// }
		// 
		// // Menu Title
		// else {
		// 	const commandCenter = this.instantiationService.createInstance(CommandCenterControl, this.windowTitle, this.hoverDelegate);
		// 	reset(this.title, commandCenter.element);
		// 	this.titleDisposables.add(commandCenter);
		// }
	}

	// ElixIDE: Crear activity bar horizontal en titlebar
	// Retorna true si se creó exitosamente, false si necesita reintento
	private createTitlebarActivityBar(): boolean {
		if (!this.titlebarActivityBarContainer) {
			return false;
		}

		// ElixIDE: Obtener SidebarPart existente desde el layoutService
		// El SidebarPart ya está creado y registrado en el workbench
		// Nota: getPart está en la implementación pero no en la interfaz, usar casting
		const layoutServiceAny = this.layoutService as any;
		let sidebarPart: SidebarPart | undefined;
		try {
			sidebarPart = layoutServiceAny.getPart(Parts.SIDEBAR_PART) as SidebarPart;
			if (!sidebarPart) {
				console.warn('[ElixIDE] SidebarPart not found, will retry');
				return false; // Necesita reintento
			}
			console.log('[ElixIDE] SidebarPart obtained successfully');
		} catch (e: any) {
			// getPart puede lanzar error si la parte no existe
			console.warn('[ElixIDE] Error getting SidebarPart:', e?.message || e);
			return false;
		}

		// Si ya existe, no crear de nuevo
		if (this.titlebarActivityBar) {
			return true;
		}

		// Crear opciones para ActivityBarCompositeBar horizontal
		// Nota: partContainerClass debe coincidir con la clase del contenedor para que el CSS se aplique
		const options: IPaneCompositeBarOptions = {
			partContainerClass: 'titlebar-activity-bar',
			pinnedViewContainersKey: ActivitybarPart.pinnedViewContainersKey,
			placeholderViewContainersKey: ActivitybarPart.placeholderViewContainersKey,
			viewContainersWorkspaceStateKey: ActivitybarPart.viewContainersWorkspaceStateKey,
			icon: true,
			orientation: ActionsOrientation.HORIZONTAL, // ElixIDE: Horizontal en titlebar
			recomputeSizes: true,
			activityHoverOptions: {
				position: () => HoverPosition.BELOW, // ElixIDE: Hover debajo en titlebar
			},
			fillExtraContextMenuActions: (actions, e) => {
				// ElixIDE: Menú contextual para activity bar en titlebar
			},
			compositeSize: 0,
			iconSize: 20, // ElixIDE: Tamaño de icono para titlebar (20px)
			overflowActionSize: 28, // ElixIDE: Tamaño de botón para titlebar
			colors: (theme: IColorTheme) => ({
				activeForegroundColor: theme.getColor(ACTIVITY_BAR_FOREGROUND),
				inactiveForegroundColor: theme.getColor(ACTIVITY_BAR_INACTIVE_FOREGROUND),
				activeBorderColor: theme.getColor(ACTIVITY_BAR_ACTIVE_BORDER),
				activeBackground: theme.getColor(ACTIVITY_BAR_ACTIVE_BACKGROUND),
				badgeBackground: theme.getColor(ACTIVITY_BAR_BADGE_BACKGROUND),
				badgeForeground: theme.getColor(ACTIVITY_BAR_BADGE_FOREGROUND),
				dragAndDropBorder: theme.getColor(ACTIVITY_BAR_DRAG_AND_DROP_BORDER),
				activeBackgroundColor: undefined,
				inactiveBackgroundColor: undefined,
				activeBorderBottomColor: undefined,
			}),
			compact: true
		};

		// Crear ActivityBarCompositeBar horizontal usando instantiationService
		// El instantiationService inyectará automáticamente todos los servicios necesarios
		this.titlebarActivityBar = this._register(
			this.instantiationService.createInstance(
				ActivityBarCompositeBar,
				options,
				Parts.ACTIVITYBAR_PART,
				sidebarPart,
				false // showGlobalActivities
			)
		);

		// Renderizar en el contenedor
		if (!this.titlebarActivityBarContainer) {
			console.error('[ElixIDE] titlebarActivityBarContainer is null');
			return false;
		}

		try {
			// El método create() retorna el elemento creado (action bar con clase .composite-bar)
			const activityBarElement = this.titlebarActivityBar.create(this.titlebarActivityBarContainer);
			
			if (!activityBarElement) {
				console.warn('[ElixIDE] Activity bar create() returned null/undefined');
				return false;
			}

			// El elemento creado es un div con clase .composite-bar
			// Asegurar que el elemento creado sea visible y horizontal
			activityBarElement.style.display = 'flex';
			activityBarElement.style.visibility = 'visible';
			activityBarElement.style.flexDirection = 'row';
			activityBarElement.style.alignItems = 'center';
			activityBarElement.style.justifyContent = 'center';
			activityBarElement.style.height = '100%';
			activityBarElement.style.width = 'auto';
			activityBarElement.style.margin = '0';
			activityBarElement.style.padding = '0';
			activityBarElement.style.minHeight = '30px'; // Asegurar altura mínima
			
			// Asegurar que el contenedor sea visible
			this.titlebarActivityBarContainer.style.display = 'flex';
			this.titlebarActivityBarContainer.style.visibility = 'visible';
			this.titlebarActivityBarContainer.style.width = '100%';
			this.titlebarActivityBarContainer.style.height = '100%';
			this.titlebarActivityBarContainer.style.minHeight = '30px'; // Asegurar altura mínima
			this.titlebarActivityBarContainer.style.position = 'relative'; // Para posicionamiento
			
			// Los botones aparecerán después de que las extensiones se registren
			// Usar MutationObserver para detectar cuando aparezcan los botones
			let actionBarFound = false;
			
			const styleActionBar = (actionBar: HTMLElement) => {
				if (actionBarFound) return; // Ya se estilizó
				
				actionBar.style.display = 'flex';
				actionBar.style.flexDirection = 'row';
				actionBar.style.alignItems = 'center';
				actionBar.style.justifyContent = 'center';
				actionBar.style.gap = '4px';
				actionBar.style.height = '100%';
				actionBar.style.width = 'auto';
				actionBar.style.visibility = 'visible';
				actionBar.style.opacity = '1';
				actionBar.style.position = 'relative';
				actionBar.style.zIndex = '10';
				
				// Asegurar que los action items sean visibles
				const actionItems = actionBar.querySelectorAll('.action-item');
				actionItems.forEach((item: Element) => {
					const el = item as HTMLElement;
					el.style.display = 'flex';
					el.style.visibility = 'visible';
					el.style.opacity = '1';
					el.style.position = 'relative';
					el.style.zIndex = '10';
				});
				
				if (actionItems.length > 0) {
					actionBarFound = true;
					console.log('[ElixIDE] ✅ Action bar found and styled, action items:', actionItems.length);
				}
			};
			
			const observer = new MutationObserver((mutations) => {
				const actionBar = activityBarElement.querySelector('.monaco-action-bar') as HTMLElement;
				if (actionBar && !actionBarFound) {
					styleActionBar(actionBar);
					if (actionBarFound) {
						observer.disconnect();
					}
				}
			});
			
			observer.observe(activityBarElement, {
				childList: true,
				subtree: true,
				attributes: false
			});
			
			// También observar el contenedor completo
			observer.observe(this.titlebarActivityBarContainer, {
				childList: true,
				subtree: true,
				attributes: false
			});
			
			// También verificar inmediatamente y después de delays
			const checkActionBar = () => {
				const actionBar = activityBarElement.querySelector('.monaco-action-bar') as HTMLElement;
				if (actionBar && !actionBarFound) {
					styleActionBar(actionBar);
					if (actionBarFound) {
						observer.disconnect(); // Dejar de observar una vez encontrado
					}
				}
			};
			
			// Verificar inmediatamente
			checkActionBar();
			
			// Verificar después de delays (las extensiones pueden tardar en registrarse)
			setTimeout(checkActionBar, 100);
			setTimeout(checkActionBar, 500);
			setTimeout(checkActionBar, 1000);
			setTimeout(checkActionBar, 2000);
			
			// Forzar layout después de crear
			setTimeout(() => {
				if (this.lastLayoutDimensions) {
					this.layout(this.lastLayoutDimensions.width, this.lastLayoutDimensions.height);
				}
				checkActionBar(); // Verificar nuevamente después del layout
			}, 100);
			
			// Forzar visibilidad inmediatamente
			this.titlebarActivityBarContainer.style.display = 'flex';
			this.titlebarActivityBarContainer.style.visibility = 'visible';
			activityBarElement.style.display = 'flex';
			activityBarElement.style.visibility = 'visible';
			
			console.log('[ElixIDE] ✅ Activity bar created successfully in titlebar', {
				container: this.titlebarActivityBarContainer,
				element: activityBarElement,
				elementClasses: activityBarElement.className,
				containerInDOM: document.body.contains(this.titlebarActivityBarContainer) || 
				               this.rootContainer.contains(this.titlebarActivityBarContainer),
				containerDisplay: window.getComputedStyle(this.titlebarActivityBarContainer).display,
				containerVisibility: window.getComputedStyle(this.titlebarActivityBarContainer).visibility,
				elementDisplay: window.getComputedStyle(activityBarElement).display,
				elementVisibility: window.getComputedStyle(activityBarElement).visibility
			});
		} catch (error: any) {
			console.error('[ElixIDE] Error creating activity bar in titlebar:', error);
			console.error('[ElixIDE] Error stack:', error?.stack);
			return false;
		}

		return true; // Éxito
	}

	// ElixIDE: Forzar registro manual de view containers
	// Este método se llama cuando las extensiones se registran pero no hay action items
	private async forceRegisterViewContainers(): Promise<void> {
		if (!this.titlebarActivityBar) {
			console.warn('[ElixIDE] Cannot force register: titlebarActivityBar is null');
			return;
		}

		// Obtener view containers disponibles para Sidebar
		const viewContainers = this.viewDescriptorService.getViewContainersByLocation(ViewContainerLocation.Sidebar);
		console.log('[ElixIDE] 🔍 Found view containers to register:', viewContainers.length, viewContainers.map(v => v.id));

		if (viewContainers.length === 0) {
			console.warn('[ElixIDE] No view containers found for Sidebar location');
			return;
		}

		// Acceder al PaneCompositeBar interno usando casting
		// El ActivityBarCompositeBar extiende PaneCompositeBar, así que podemos acceder a métodos privados
		const paneCompositeBar = this.titlebarActivityBar as any;
		
		// Verificar que el método existe
		if (typeof paneCompositeBar.onDidRegisterViewContainers !== 'function') {
			console.error('[ElixIDE] onDidRegisterViewContainers method not found in ActivityBarCompositeBar');
			// Intentar otra estrategia: llamar a getViewContainers y forzar registro
			try {
				const getViewContainers = paneCompositeBar.getViewContainers;
				if (typeof getViewContainers === 'function') {
					const existingContainers = getViewContainers.call(paneCompositeBar);
					console.log('[ElixIDE] Existing containers in PaneCompositeBar:', existingContainers.length);
					if (existingContainers.length === 0) {
						// Forzar registro llamando directamente al método privado usando bind
						const onDidRegister = (paneCompositeBar as any).onDidRegisterViewContainers;
						if (typeof onDidRegister === 'function') {
							onDidRegister.call(paneCompositeBar, viewContainers);
							console.log('[ElixIDE] ✅ Forced registration via direct method call');
						}
					}
				}
			} catch (e: any) {
				console.error('[ElixIDE] ❌ Error in fallback registration:', e?.message || e);
			}
			return;
		}

		// Forzar registro manual de cada view container
		console.log('[ElixIDE] 🔧 Forcing registration of view containers...');
		
		// Obtener el compositeBar antes de registrar
		const compositeBar = (paneCompositeBar as any).compositeBar;
		console.log('[ElixIDE] 📦 CompositeBar obtained:', !!compositeBar, 'has create method:', typeof compositeBar?.create === 'function');
		
		// Verificar el estado antes de registrar
		const actionItemsBefore = this.titlebarActivityBarContainer?.querySelectorAll('.action-item');
		console.log('[ElixIDE] 📊 Action items before registration:', actionItemsBefore?.length || 0);
		
		try {
			// Llamar a onDidRegisterViewContainers con todos los containers a la vez
			// Este método es privado pero podemos accederlo con casting
			// NOTA: onDidRegisterViewContainers ya llama a updateCompositeBarActionItem y showOrHideViewContainer
			paneCompositeBar.onDidRegisterViewContainers(viewContainers);
			console.log('[ElixIDE] ✅ Forced registration of all view containers');
			
			// Verificar que getCompositeActions se haya llamado para cada container
			for (const viewContainer of viewContainers) {
				const compositeActions = (paneCompositeBar as any).compositeActions?.get(viewContainer.id);
				console.log('[ElixIDE] 📋 Composite actions for', viewContainer.id, ':', !!compositeActions, 'has activityAction:', !!compositeActions?.activityAction);
			}
			
			// CRÍTICO: Asegurar que los composites estén pinned para que se muestren
			// updateCompositeSwitcher solo muestra items que están pinned o son activeItem
			for (const viewContainer of viewContainers) {
				try {
					if (compositeBar && typeof compositeBar.pin === 'function') {
						await compositeBar.pin(viewContainer.id, false);
						console.log('[ElixIDE] ✅ Pinned view container:', viewContainer.id);
					}
				} catch (err: any) {
					console.error('[ElixIDE] ❌ Error pinning', viewContainer.id, ':', err?.message || err);
				}
			}
			
			// CRÍTICO: Establecer dimension si no está establecida
			// updateCompositeSwitcher requiere que dimension esté definido
			if (compositeBar && !compositeBar.dimension) {
				const containerRect = this.titlebarActivityBarContainer?.getBoundingClientRect();
				if (containerRect) {
					compositeBar.dimension = { width: containerRect.width, height: containerRect.height };
					console.log('[ElixIDE] ✅ Set dimension on compositeBar:', compositeBar.dimension);
				}
			}
			
			// CRÍTICO: Forzar updateCompositeSwitcher para que el composite bar renderice los action items
			if (compositeBar && typeof compositeBar.updateCompositeSwitcher === 'function') {
				compositeBar.updateCompositeSwitcher();
				console.log('[ElixIDE] ✅ Forced updateCompositeSwitcher on compositeBar');
			}
			
			// También forzar recomputeSizes
			if (compositeBar && typeof compositeBar.recomputeSizes === 'function') {
				compositeBar.recomputeSizes();
				console.log('[ElixIDE] ✅ Forced recomputeSizes on compositeBar');
			}
			
			// Verificar el estado después de registrar
			setTimeout(() => {
				const actionItemsAfter = this.titlebarActivityBarContainer?.querySelectorAll('.action-item');
				console.log('[ElixIDE] 📊 Action items after registration (immediate):', actionItemsAfter?.length || 0);
				
				// Verificar el HTML del composite bar
				const compositeBarElement = this.titlebarActivityBarContainer?.querySelector('.composite-bar');
				if (compositeBarElement) {
					console.log('[ElixIDE] 📄 Composite bar HTML:', compositeBarElement.innerHTML.substring(0, 500));
				}
			}, 100);
		} catch (e: any) {
			console.error('[ElixIDE] ❌ Error forcing registration:', e?.message || e);
			// Intentar uno por uno como fallback
			console.log('[ElixIDE] 🔄 Trying one-by-one registration...');
			for (const viewContainer of viewContainers) {
				try {
					paneCompositeBar.onDidRegisterViewContainers([viewContainer]);
					console.log('[ElixIDE] ✅ Forced registration of view container:', viewContainer.id);
				} catch (err: any) {
					console.error('[ElixIDE] ❌ Error forcing registration of', viewContainer.id, ':', err?.message || err);
				}
			}
			
			// Forzar updateCompositeSwitcher y recomputeSizes después de registrar todos
			const compositeBar = (paneCompositeBar as any).compositeBar;
			if (compositeBar) {
				if (typeof compositeBar.updateCompositeSwitcher === 'function') {
					compositeBar.updateCompositeSwitcher();
					console.log('[ElixIDE] ✅ Forced updateCompositeSwitcher on compositeBar (fallback)');
				}
				if (typeof compositeBar.recomputeSizes === 'function') {
					compositeBar.recomputeSizes();
					console.log('[ElixIDE] ✅ Forced recomputeSizes on compositeBar (fallback)');
				}
			}
		}

		// Verificar que los action items aparezcan después del registro forzado
		setTimeout(() => {
			const actionItems = this.titlebarActivityBarContainer?.querySelectorAll('.action-item');
			console.log('[ElixIDE] 📊 Action items after forced registration:', actionItems?.length || 0);
			if (actionItems && actionItems.length > 0) {
				console.log('[ElixIDE] ✅ Successfully registered view containers!');
			} else {
				console.warn('[ElixIDE] ⚠️ Still no action items after forced registration');
			}
		}, 500);
	}

	private actionViewItemProvider(action: IAction, options: IBaseActionViewItemOptions): IActionViewItem | undefined {

		// --- Activity Actions
		if (!this.isAuxiliary) {
			if (action.id === GLOBAL_ACTIVITY_ID) {
				return this.instantiationService.createInstance(SimpleGlobalActivityActionViewItem, { position: () => HoverPosition.BELOW }, options);
			}
			if (action.id === ACCOUNTS_ACTIVITY_ID) {
				return this.instantiationService.createInstance(SimpleAccountActivityActionViewItem, { position: () => HoverPosition.BELOW }, options);
			}
		}

		// --- Editor Actions
		const activeEditorPane = this.editorGroupsContainer.activeGroup?.activeEditorPane;
		if (activeEditorPane && activeEditorPane instanceof EditorPane) {
			const result = activeEditorPane.getActionViewItem(action, options);

			if (result) {
				return result;
			}
		}

		// Check extensions
		return createActionViewItem(this.instantiationService, action, { ...options, menuAsChild: false });
	}

	private getKeybinding(action: IAction): ResolvedKeybinding | undefined {
		const editorPaneAwareContextKeyService = this.editorGroupsContainer.activeGroup?.activeEditorPane?.scopedContextKeyService ?? this.contextKeyService;

		return this.keybindingService.lookupKeybinding(action.id, editorPaneAwareContextKeyService);
	}

	private createActionToolBar(): void {

		// Creates the action tool bar. Depends on the configuration of the title bar menus
		// Requires to be recreated whenever editor actions enablement changes

		this.actionToolBarDisposable.clear();

		this.actionToolBar = this.actionToolBarDisposable.add(this.instantiationService.createInstance(WorkbenchToolBar, this.actionToolBarElement, {
			contextMenu: MenuId.TitleBarContext,
			orientation: ActionsOrientation.HORIZONTAL,
			ariaLabel: localize('ariaLabelTitleActions', "Title actions"),
			getKeyBinding: action => this.getKeybinding(action),
			overflowBehavior: { maxItems: 9, exempted: [ACCOUNTS_ACTIVITY_ID, GLOBAL_ACTIVITY_ID, ...EDITOR_CORE_NAVIGATION_COMMANDS] },
			anchorAlignmentProvider: () => AnchorAlignment.RIGHT,
			telemetrySource: 'titlePart',
			highlightToggledItems: this.editorActionsEnabled || this.isAuxiliary, // Only show toggled state for editor actions or auxiliary title bars
			actionViewItemProvider: (action, options) => this.actionViewItemProvider(action, options),
			hoverDelegate: this.hoverDelegate
		}));

		if (this.editorActionsEnabled) {
			this.actionToolBarDisposable.add(this.editorGroupsContainer.onDidChangeActiveGroup(() => this.createActionToolBarMenus({ editorActions: true })));
		}
	}

	private createActionToolBarMenus(update: true | { editorActions?: boolean; layoutActions?: boolean; globalActions?: boolean; activityActions?: boolean } = true): void {
		if (update === true) {
			update = { editorActions: true, layoutActions: true, globalActions: true, activityActions: true };
		}

		const updateToolBarActions = () => {
			const actions: IToolbarActions = { primary: [], secondary: [] };

			// --- Editor Actions
			if (this.editorActionsEnabled) {
				this.editorActionsChangeDisposable.clear();

				const activeGroup = this.editorGroupsContainer.activeGroup;
				if (activeGroup) {
					const editorActions = activeGroup.createEditorActions(this.editorActionsChangeDisposable, this.isAuxiliary && this.isCompact ? MenuId.CompactWindowEditorTitle : MenuId.EditorTitle);

					actions.primary.push(...editorActions.actions.primary);
					actions.secondary.push(...editorActions.actions.secondary);

					this.editorActionsChangeDisposable.add(editorActions.onDidChange(() => updateToolBarActions()));
				}
			}

			// --- Global Actions
			if (this.globalToolbarMenu) {
				fillInActionBarActions(
					this.globalToolbarMenu.getActions(),
					actions
				);
			}

			// --- Layout Actions
			if (this.layoutToolbarMenu) {
				fillInActionBarActions(
					this.layoutToolbarMenu.getActions(),
					actions,
					() => !this.editorActionsEnabled || this.isCompact // layout actions move to "..." if editor actions are enabled unless compact
				);
			}

			// --- Activity Actions (always at the end)
			if (this.activityActionsEnabled) {
				if (isAccountsActionVisible(this.storageService)) {
					actions.primary.push(ACCOUNTS_ACTIVITY_TILE_ACTION);
				}

				actions.primary.push(GLOBAL_ACTIVITY_TITLE_ACTION);
			}

			this.actionToolBar.setActions(prepareActions(actions.primary), prepareActions(actions.secondary));
		};

		// Create/Update the menus which should be in the title tool bar

		if (update.editorActions) {
			this.editorToolbarMenuDisposables.clear();

			// The editor toolbar menu is handled by the editor group so we do not need to manage it here.
			// However, depending on the active editor, we need to update the context and action runner of the toolbar menu.
			if (this.editorActionsEnabled && this.editorService.activeEditor !== undefined) {
				const context: IEditorCommandsContext = { groupId: this.editorGroupsContainer.activeGroup.id };

				this.actionToolBar.actionRunner = this.editorToolbarMenuDisposables.add(new EditorCommandsContextActionRunner(context));
				this.actionToolBar.context = context;
			} else {
				this.actionToolBar.actionRunner = this.editorToolbarMenuDisposables.add(new ActionRunner());
				this.actionToolBar.context = undefined;
			}
		}

		if (update.layoutActions) {
			this.layoutToolbarMenuDisposables.clear();

			if (this.layoutControlEnabled) {
				this.layoutToolbarMenu = this.menuService.createMenu(MenuId.LayoutControlMenu, this.contextKeyService);

				this.layoutToolbarMenuDisposables.add(this.layoutToolbarMenu);
				this.layoutToolbarMenuDisposables.add(this.layoutToolbarMenu.onDidChange(() => updateToolBarActions()));
			} else {
				this.layoutToolbarMenu = undefined;
			}
		}

		if (update.globalActions) {
			this.globalToolbarMenuDisposables.clear();

			if (this.globalActionsEnabled) {
				this.globalToolbarMenu = this.menuService.createMenu(MenuId.TitleBar, this.contextKeyService);

				this.globalToolbarMenuDisposables.add(this.globalToolbarMenu);
				this.globalToolbarMenuDisposables.add(this.globalToolbarMenu.onDidChange(() => updateToolBarActions()));
			} else {
				this.globalToolbarMenu = undefined;
			}
		}

		if (update.activityActions) {
			this.activityToolbarDisposables.clear();
			if (this.activityActionsEnabled) {
				this.activityToolbarDisposables.add(this.storageService.onDidChangeValue(StorageScope.PROFILE, AccountsActivityActionViewItem.ACCOUNTS_VISIBILITY_PREFERENCE_KEY, this._store)(() => updateToolBarActions()));
			}
		}

		updateToolBarActions();
	}

	override updateStyles(): void {
		super.updateStyles();

		// Part container
		if (this.element) {
			if (this.isInactive) {
				this.element.classList.add('inactive');
			} else {
				this.element.classList.remove('inactive');
			}

			const titleBackground = this.getColor(this.isInactive ? TITLE_BAR_INACTIVE_BACKGROUND : TITLE_BAR_ACTIVE_BACKGROUND, (color, theme) => {
				// LCD Rendering Support: the title bar part is a defining its own GPU layer.
				// To benefit from LCD font rendering, we must ensure that we always set an
				// opaque background color. As such, we compute an opaque color given we know
				// the background color is the workbench background.
				return color.isOpaque() ? color : color.makeOpaque(WORKBENCH_BACKGROUND(theme));
			}) || '';
			this.element.style.backgroundColor = titleBackground;

			if (this.appIconBadge) {
				this.appIconBadge.style.backgroundColor = titleBackground;
			}

			if (titleBackground && Color.fromHex(titleBackground).isLighter()) {
				this.element.classList.add('light');
			} else {
				this.element.classList.remove('light');
			}

			const titleForeground = this.getColor(this.isInactive ? TITLE_BAR_INACTIVE_FOREGROUND : TITLE_BAR_ACTIVE_FOREGROUND);
			this.element.style.color = titleForeground || '';

			const titleBorder = this.getColor(TITLE_BAR_BORDER);
			this.element.style.borderBottom = titleBorder ? `1px solid ${titleBorder}` : '';
		}
	}

	protected onContextMenu(e: MouseEvent, menuId: MenuId): void {
		const event = new StandardMouseEvent(getWindow(this.element), e);

		// Show it
		this.contextMenuService.showContextMenu({
			getAnchor: () => event,
			menuId,
			contextKeyService: this.contextKeyService,
			domForShadowRoot: isMacintosh && isNative ? event.target : undefined
		});
	}

	protected get currentMenubarVisibility(): MenuBarVisibility {
		if (this.isAuxiliary) {
			return 'hidden';
		}

		return getMenuBarVisibility(this.configurationService);
	}

	private get layoutControlEnabled(): boolean {
		return this.configurationService.getValue<boolean>(LayoutSettings.LAYOUT_ACTIONS) !== false;
	}

	protected get isCommandCenterVisible() {
		return !this.isCompact && this.configurationService.getValue<boolean>(LayoutSettings.COMMAND_CENTER) !== false;
	}

	private get editorActionsEnabled(): boolean {
		return (this.editorGroupsContainer.partOptions.editorActionsLocation === EditorActionsLocation.TITLEBAR ||
			(
				this.editorGroupsContainer.partOptions.editorActionsLocation === EditorActionsLocation.DEFAULT &&
				this.editorGroupsContainer.partOptions.showTabs === EditorTabsMode.NONE
			));
	}

	private get activityActionsEnabled(): boolean {
		const activityBarPosition = this.configurationService.getValue<ActivityBarPosition>(LayoutSettings.ACTIVITY_BAR_LOCATION);
		return !this.isCompact && !this.isAuxiliary && (activityBarPosition === ActivityBarPosition.TOP || activityBarPosition === ActivityBarPosition.BOTTOM);
	}

	private get globalActionsEnabled(): boolean {
		return !this.isCompact;
	}

	get hasZoomableElements(): boolean {
		const hasMenubar = !(this.currentMenubarVisibility === 'hidden' || this.currentMenubarVisibility === 'compact' || (!isWeb && isMacintosh));
		const hasCommandCenter = this.isCommandCenterVisible;
		const hasToolBarActions = this.globalActionsEnabled || this.layoutControlEnabled || this.editorActionsEnabled || this.activityActionsEnabled;
		return hasMenubar || hasCommandCenter || hasToolBarActions;
	}

	get preventZoom(): boolean {
		// Prevent zooming behavior if any of the following conditions are met:
		// 1. Shrinking below the window control size (zoom < 1)
		// 2. No custom items are present in the title bar

		return getZoomFactor(getWindow(this.element)) < 1 || !this.hasZoomableElements;
	}

	override layout(width: number, height: number): void {
		this.updateLayout(new Dimension(width, height));

		super.layoutContents(width, height);
	}

	private updateLayout(dimension: Dimension): void {
		this.lastLayoutDimensions = dimension;

		if (!hasCustomTitlebar(this.configurationService, this.titleBarStyle)) {
			return;
		}

		const zoomFactor = getZoomFactor(getWindow(this.element));

		this.element.style.setProperty('--zoom-factor', zoomFactor.toString());
		this.rootContainer.classList.toggle('counter-zoom', this.preventZoom);

		if (this.customMenubar.value) {
			const menubarDimension = new Dimension(0, dimension.height);
			this.customMenubar.value.layout(menubarDimension);
		}

		const hasCenter = this.isCommandCenterVisible || this.title.textContent !== '';
		this.rootContainer.classList.toggle('has-center', hasCenter);
	}

	focus(): void {
		if (this.customMenubar.value) {
			this.customMenubar.value.toggleFocus();
		} else {
			// eslint-disable-next-line no-restricted-syntax
			(this.element.querySelector('[tabindex]:not([tabindex="-1"])') as HTMLElement | null)?.focus();
		}
	}

	toJSON(): object {
		return {
			type: Parts.TITLEBAR_PART
		};
	}

	override dispose(): void {
		this._onWillDispose.fire();

		super.dispose();
	}
}

export class MainBrowserTitlebarPart extends BrowserTitlebarPart {

	constructor(
		@IContextMenuService contextMenuService: IContextMenuService,
		@IConfigurationService configurationService: IConfigurationService,
		@IBrowserWorkbenchEnvironmentService environmentService: IBrowserWorkbenchEnvironmentService,
		@IInstantiationService instantiationService: IInstantiationService,
		@IThemeService themeService: IThemeService,
		@IStorageService storageService: IStorageService,
		@IWorkbenchLayoutService layoutService: IWorkbenchLayoutService,
		@IContextKeyService contextKeyService: IContextKeyService,
		@IHostService hostService: IHostService,
		@IEditorGroupsService editorGroupService: IEditorGroupsService,
		@IEditorService editorService: IEditorService,
		@IMenuService menuService: IMenuService,
		@IKeybindingService keybindingService: IKeybindingService,
		@IExtensionService extensionService: IExtensionService,
		@IViewDescriptorService viewDescriptorService: IViewDescriptorService,
	) {
		super(Parts.TITLEBAR_PART, mainWindow, editorGroupService.mainPart, contextMenuService, configurationService, environmentService, instantiationService, themeService, storageService, layoutService, contextKeyService, hostService, editorGroupService, editorService, menuService, keybindingService, extensionService, viewDescriptorService);
	}
}

export interface IAuxiliaryTitlebarPart extends ITitlebarPart, IView {
	readonly container: HTMLElement;
	readonly height: number;

	updateOptions(options: { compact: boolean }): void;
}

export class AuxiliaryBrowserTitlebarPart extends BrowserTitlebarPart implements IAuxiliaryTitlebarPart {

	private static COUNTER = 1;

	get height() { return this.minimumHeight; }

	constructor(
		readonly container: HTMLElement,
		editorGroupsContainer: IEditorGroupsContainer,
		private readonly mainTitlebar: BrowserTitlebarPart,
		@IContextMenuService contextMenuService: IContextMenuService,
		@IConfigurationService configurationService: IConfigurationService,
		@IBrowserWorkbenchEnvironmentService environmentService: IBrowserWorkbenchEnvironmentService,
		@IInstantiationService instantiationService: IInstantiationService,
		@IThemeService themeService: IThemeService,
		@IStorageService storageService: IStorageService,
		@IWorkbenchLayoutService layoutService: IWorkbenchLayoutService,
		@IContextKeyService contextKeyService: IContextKeyService,
		@IHostService hostService: IHostService,
		@IEditorGroupsService editorGroupService: IEditorGroupsService,
		@IEditorService editorService: IEditorService,
		@IMenuService menuService: IMenuService,
		@IKeybindingService keybindingService: IKeybindingService,
		@IExtensionService extensionService: IExtensionService,
		@IViewDescriptorService viewDescriptorService: IViewDescriptorService,
	) {
		const id = AuxiliaryBrowserTitlebarPart.COUNTER++;
		super(`workbench.parts.auxiliaryTitle.${id}`, getWindow(container), editorGroupsContainer, contextMenuService, configurationService, environmentService, instantiationService, themeService, storageService, layoutService, contextKeyService, hostService, editorGroupService, editorService, menuService, keybindingService, extensionService, viewDescriptorService);
	}

	override get preventZoom(): boolean {

		// Prevent zooming behavior if any of the following conditions are met:
		// 1. Shrinking below the window control size (zoom < 1)
		// 2. No custom items are present in the main title bar
		// The auxiliary title bar never contains any zoomable items itself,
		// but we want to match the behavior of the main title bar.

		return getZoomFactor(getWindow(this.element)) < 1 || !this.mainTitlebar.hasZoomableElements;
	}
}
