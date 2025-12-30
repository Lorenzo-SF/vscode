/*---------------------------------------------------------------------------------------------
 *  Copyright (c) Microsoft Corporation. All rights reserved.
 *  Licensed under the MIT License. See License.txt in the project root for license information.
 *--------------------------------------------------------------------------------------------*/

/**
 * ElixIDE: Sistema de Bootstrap de Módulos
 * Escanea el directorio modules/ y carga todos los módulos encontrados
 */

import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';
import { Logger } from './utils/logger.js';
import { TelemetryService } from './utils/telemetry.js';
import { ErrorHandler } from './utils/errorHandler.js';

export interface ElixIDEModule {
	id: string;
	name: string;
	version: string;
	activate: (context: vscode.ExtensionContext) => any;
	api?: any;
}

export interface ElixIDEAPI {
	getModuleApi: <T = any>(moduleId: string) => T | undefined;
	publishEvent: (eventName: string, data?: any) => void;
	subscribeToEvent: (eventName: string, callback: (data?: any) => void) => vscode.Disposable;
}

class ElixIDEBootstrap implements ElixIDEAPI {
	private modules: Map<string, ElixIDEModule> = new Map();
	private eventListeners: Map<string, Array<(data?: any) => void>> = new Map();
	private context: vscode.ExtensionContext;
	private logger: Logger;
	private telemetry: TelemetryService;
	private errorHandler: ErrorHandler;
	private healthCheckInterval: any;

	constructor(context: vscode.ExtensionContext) {
		this.context = context;
		this.logger = Logger.getInstance();
		this.telemetry = TelemetryService.getInstance();
		this.errorHandler = ErrorHandler.getInstance();
		
		// Iniciar telemetría
		this.telemetry.logStartup();
		this.telemetry.logMemoryUsage();
		
		// Iniciar health checks periódicos (cada 5 minutos)
		this.startHealthChecks();
	}

	/**
	 * Escanea el directorio modules/ y carga todos los módulos
	 */
	async loadModules(): Promise<void> {
		// ElixIDE: Buscar modules/ en la raíz del proyecto (no en extensionPath)
		// extensionPath puede apuntar a .vscode/extensions/ o similar
		// Necesitamos buscar en la raíz del proyecto ElixIDE
		const projectRoot = path.resolve(__dirname, '../../..');
		const modulesDir = path.join(projectRoot, 'modules');
		
		if (!fs.existsSync(modulesDir)) {
			this.logger.warn('modules/ directory not found', { modulesDir });
			return;
		}

		const entries = fs.readdirSync(modulesDir, { withFileTypes: true });
		
		// Cargar módulos en paralelo (con límite de concurrencia)
		const loadPromises: Promise<void>[] = [];
		
		for (const entry of entries) {
			if (!entry.isDirectory()) {
				continue;
			}

			const modulePath = path.join(modulesDir, entry.name);
			const packageJsonPath = path.join(modulePath, 'package.json');
			
			if (!fs.existsSync(packageJsonPath)) {
				this.logger.warn(`Module ${entry.name} has no package.json, skipping`);
				continue;
			}

			// Cargar módulo con timeout y manejo de errores (en paralelo)
			const loadPromise = (async () => {
				try {
					const loadResult = await this.errorHandler.loadModuleWithTimeout(
						entry.name,
						async () => {
							const packageJson = JSON.parse(fs.readFileSync(packageJsonPath, 'utf-8'));
							const mainPath = packageJson.main || 'out/index.js';
							const compiledMainPath = path.join(modulePath, mainPath);

							if (!fs.existsSync(compiledMainPath)) {
								throw new Error(`Main file not found: ${compiledMainPath}. Compile with 'tsc' first.`);
							}

							// Cargar módulo usando require (compatible con VSCode)
							let moduleExports;
							try {
								moduleExports = require(compiledMainPath);
							} catch (requireError: any) {
								throw new Error(`Failed to require module: ${requireError.message}`);
							}
							
							if (typeof moduleExports.activate !== 'function') {
								throw new Error('Module does not export activate function');
							}

							// Activar módulo
							const api = moduleExports.activate(this.context);

							const module: ElixIDEModule = {
								id: packageJson.name || entry.name,
								name: packageJson.displayName || entry.name,
								version: packageJson.version || '0.0.0',
								activate: moduleExports.activate,
								api: api
							};

							return module;
						},
						30000 // 30 segundos timeout
					);

					if (loadResult.success && loadResult.module) {
						this.modules.set(loadResult.module.id, loadResult.module);
						this.logger.info(`Module ${loadResult.module.name} (${loadResult.module.id}) loaded successfully`, {
							loadTime: loadResult.loadTime
						});
						this.telemetry.logPerformance(`module.load.${loadResult.module.id}`, loadResult.loadTime || 0);
						
						// Registrar health check
						this.errorHandler.registerHealthCheck(loadResult.module.id, () => {
							return this.modules.has(loadResult.module!.id);
						});
					} else {
						// Error ya fue manejado por errorHandler
						// Continuar con otros módulos (modo degradado)
					}
				} catch (err: any) {
					this.logger.error(`Unexpected error loading module ${entry.name}`, {}, err instanceof Error ? err : new Error(String(err)));
				}
			})();
			
			loadPromises.push(loadPromise);
		}
		
		// Esperar a que todos los módulos se carguen (o fallen)
		await Promise.allSettled(loadPromises);
	}

	getModuleApi<T = any>(moduleId: string): T | undefined {
		const module = this.modules.get(moduleId);
		return module?.api as T | undefined;
	}

	publishEvent(eventName: string, data?: any): void {
		const listeners = this.eventListeners.get(eventName);
		if (listeners) {
			listeners.forEach(callback => {
				try {
					callback(data);
				} catch (error: any) {
					this.logger.error(`Error in event listener for ${eventName}`, {}, error instanceof Error ? error : new Error(String(error)));
				}
			});
		}
	}

	subscribeToEvent(eventName: string, callback: (data?: any) => void): vscode.Disposable {
		if (!this.eventListeners.has(eventName)) {
			this.eventListeners.set(eventName, []);
		}
		
		this.eventListeners.get(eventName)!.push(callback);
		
		return new vscode.Disposable(() => {
			const listeners = this.eventListeners.get(eventName);
			if (listeners) {
				const index = listeners.indexOf(callback);
				if (index > -1) {
					listeners.splice(index, 1);
				}
			}
		});
	}

	getModulesCount(): number {
		return this.modules.size;
	}

	/**
	 * Iniciar health checks periódicos
	 */
	private startHealthChecks(): void {
		// Health check cada 5 minutos
		this.healthCheckInterval = setInterval(async () => {
			const results = await this.errorHandler.performHealthChecks();
			const failed = Array.from(results.entries()).filter(([_, healthy]) => !healthy);
			
			if (failed.length > 0) {
				this.logger.warn(`Health checks failed for modules: ${failed.map(([id]) => id).join(', ')}`);
			}
		}, 5 * 60 * 1000); // 5 minutos
	}

	/**
	 * Limpiar recursos
	 */
	dispose(): void {
		if (this.healthCheckInterval) {
			clearInterval(this.healthCheckInterval);
		}
		this.telemetry.logShutdown();
	}
}

// API global de ElixIDE
declare global {
	interface Window {
		ElixIDE?: ElixIDEAPI;
	}
}

let bootstrapInstance: ElixIDEBootstrap | undefined;

export async function bootstrap(context: vscode.ExtensionContext): Promise<void> {
	const logger = Logger.getInstance();
	logger.info('Starting ElixIDE bootstrap...');
	
	try {
		bootstrapInstance = new ElixIDEBootstrap(context);
		await bootstrapInstance.loadModules();
		
		// Exponer API global
		if (typeof window !== 'undefined') {
			(window as any).ElixIDE = bootstrapInstance;
		}
		
		const modulesCount = bootstrapInstance.getModulesCount();
		logger.info(`Bootstrap complete. Loaded ${modulesCount} modules.`);
		
		// Registrar métricas
		const telemetry = TelemetryService.getInstance();
		telemetry.logPerformance('bootstrap.totalModules', modulesCount);
		telemetry.logMemoryUsage();
	} catch (error: any) {
		const err = error instanceof Error ? error : new Error(String(error));
		logger.error('Bootstrap error (non-fatal)', {}, err);
		
		// No bloquear el arranque de VSCode si el bootstrap falla
		// ElixIDE funcionará en modo degradado
	}
}

export function getElixIDEAPI(): ElixIDEAPI | undefined {
	return bootstrapInstance;
}

