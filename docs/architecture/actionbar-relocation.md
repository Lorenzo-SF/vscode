# Action Bar Relocation - Documentación de Arquitectura

## Resumen

Este documento describe la decisión arquitectónica y los cambios realizados para reubicar la action bar (barra de acciones) de la sidebar izquierda a la titlebar (barra de título) de la ventana en ElixIDE.

## Decisión Arquitectónica

### Problema

En VSCode estándar, la action bar se encuentra en la sidebar izquierda, ocupando espacio vertical y reduciendo el área disponible para el contenido del editor.

### Solución

Reubicar completamente la action bar a la titlebar, reemplazando el título de la ventana y ocupando todo el ancho disponible. Esto:
- Maximiza el espacio vertical disponible para el editor
- Proporciona una experiencia más moderna y diferenciada de VSCode
- Mantiene toda la funcionalidad original de la action bar

### Alternativas Consideradas

1. **Mantener en sidebar**: No hay diferenciación, espacio desperdiciado
2. **Action bar flotante**: Más complejo, puede interferir con contenido
3. **Action bar en titlebar**: ✅ Elegida - Mejor UX, más espacio, diferenciación clara

## Cambios Realizados

### 1. Modificaciones en `activitybarPart.ts`

**Ubicación**: `src/vs/workbench/browser/parts/activitybar/activitybarPart.ts`

**Cambios**:
- `minimumWidth` y `maximumWidth` establecidos a `0` para ocultar la activity bar original
- CSS agregado para ocultar completamente la activity bar vertical

**Código relevante**:
```typescript
readonly minimumWidth: number = 0; // ElixIDE: Ocultar activity bar
readonly maximumWidth: number = 0; // ElixIDE: Ocultar activity bar
```

### 2. Modificaciones en `titlebarPart.ts`

**Ubicación**: `src/vs/workbench/browser/parts/titlebar/titlebarPart.ts`

**Cambios principales**:
- Título de ventana oculto completamente (`this.title.style.display = 'none'`)
- Contenedor para activity bar horizontal creado en `centerContent`
- `ActivityBarCompositeBar` instanciado con orientación horizontal
- Creación diferida hasta que el layout esté inicializado (en `updateLayout`)

**Código relevante**:
```typescript
// ElixIDE: Ocultar título de ventana - será reemplazado por activity bar
this.title = append(this.centerContent, $('div.window-title'));
this.title.style.display = 'none';

// ElixIDE: Crear contenedor para activity bar horizontal en titlebar
this.titlebarActivityBarContainer = append(this.centerContent, $('div.titlebar-activity-bar'));
```

### 3. Modificaciones CSS

#### `activitybarpart.css`

**Ubicación**: `src/vs/workbench/browser/parts/activitybar/media/activitybarpart.css`

**Cambios**:
```css
/* ElixIDE: Ocultar completamente la activity bar original */
.monaco-workbench .part.activitybar {
    display: none !important;
}

.monaco-workbench .activitybar > .content {
    display: none !important;
}
```

#### `titlebarpart.css`

**Ubicación**: `src/vs/workbench/browser/parts/titlebar/media/titlebarpart.css`

**Cambios**:
```css
/* ElixIDE: Estilos para la activity bar horizontal en la titlebar */
.monaco-workbench .part.titlebar .titlebar-activity-bar {
    height: 100%;
    display: flex;
    flex-direction: row;
    align-items: center;
    -webkit-app-region: no-drag;
}

.monaco-workbench .part.titlebar .titlebar-activity-bar .monaco-action-bar .action-item .action-label {
    font-size: 20px;
    width: 28px;
    height: 28px;
    line-height: 28px;
    text-align: center;
}
```

## Especificaciones Técnicas

### Ubicación y Posicionamiento

**Windows/Linux**:
- Activity bar ocupa todo el ancho de la titlebar
- Controles de ventana (minimizar, maximizar, cerrar) integrados en el lado derecho
- Botones de activity bar alineados horizontalmente de izquierda a derecha

**macOS**:
- Activity bar ocupa todo el ancho de la titlebar
- Controles de ventana (verde, amarillo, rojo) integrados en el lado izquierdo
- Botones de activity bar siguen a los controles de ventana

### Dimensiones

- **Altura de titlebar**: 30-35px (estándar)
- **Tamaño de botones**: 28x28px (recomendado, mínimo 24x24px)
- **Ancho**: 100% del ancho disponible de la ventana

### Funcionalidad Preservada

- ✅ Mostrar/ocultar paneles al hacer clic en botones
- ✅ Tooltips al pasar el mouse
- ✅ Indicadores de estado activo/inactivo
- ✅ Badges de notificaciones
- ✅ Accesibilidad (navegación por teclado, screen readers)
- ✅ Event handlers y lógica de activación

## Diagrama Visual

### ANTES (VSCode estándar):
```
┌─────────────────────────────────────────┐
│ [─][□][×] "ElixIDE" o título ventana    │ ← Titlebar tradicional
├─┬──────────────────────────────────────┤
│ │ [Explorer]                            │
│A│ [Search]                              │
│c│ [Source Control]                      │
│t│ [Run and Debug]                       │
│i│ [Extensions]                          │
│v│                                       │
│e│  [Sidebar con contenido]              │
│ │                                       │
└─┴──────────────────────────────────────┘
```

### DESPUÉS (ElixIDE):
```
┌─────────────────────────────────────────┐
│ [Explorer][Search][SC][Debug][Ext]... [─][□][×] │ ← Action bar REEMPLAZA titlebar
├──────────────────────────────────────────┤      │ (controles ventana integrados)
│ [Sidebar con contenido, sin action bar]  │
│                                          │
└──────────────────────────────────────────┘
```

## Implementación Técnica

### Flujo de Creación

1. **Inicialización del TitlebarPart**:
   - Se crea el contenedor `titlebarActivityBarContainer` en `createContentArea()`
   - El título se oculta inmediatamente

2. **Creación de ActivityBarCompositeBar**:
   - Se retrasa hasta `updateLayout()` para asegurar que el layout esté inicializado
   - Se obtiene `SidebarPart` usando `instantiationService`
   - Se crea `ActivityBarCompositeBar` con orientación horizontal
   - Se renderiza en el contenedor

3. **Ocultación de Activity Bar Original**:
   - CSS oculta completamente la activity bar vertical
   - `minimumWidth` y `maximumWidth` en `0` previenen que ocupe espacio

### Dependencias

- `ActivityBarCompositeBar`: Clase que renderiza los botones de la activity bar
- `SidebarPart`: Parte del workbench que gestiona los paneles
- `IWorkbenchLayoutService`: Servicio para acceder a las partes del workbench
- `IInstantiationService`: Servicio para crear instancias con inyección de dependencias

## Troubleshooting

### Problema: Activity bar no aparece en titlebar

**Solución**:
1. Verificar que `titlebarActivityBarContainer` se crea en `createContentArea()`
2. Verificar que `createTitlebarActivityBar()` se llama en `updateLayout()`
3. Verificar que `SidebarPart` está disponible cuando se crea
4. Revisar la consola del desarrollador para errores

### Problema: Activity bar aparece pero los botones no funcionan

**Solución**:
1. Verificar que `ActivityBarCompositeBar` se crea correctamente
2. Verificar que los event handlers están registrados
3. Verificar que `SidebarPart` se pasa correctamente al constructor

### Problema: Activity bar original todavía visible

**Solución**:
1. Verificar que CSS en `activitybarpart.css` está aplicado
2. Verificar que `minimumWidth` y `maximumWidth` están en `0`
3. Limpiar caché del navegador/Electron

### Problema: Controles de ventana no se integran correctamente

**Solución**:
1. Verificar posicionamiento según plataforma (Windows/Linux: derecha, macOS: izquierda)
2. Verificar que `-webkit-app-region: no-drag` está en los botones
3. Verificar que los controles de ventana están en el contenedor correcto

## Mantenimiento

### Actualización de VSCode

Cuando se actualice el submódulo de VSCode:
1. Verificar que los cambios en `titlebarPart.ts` siguen siendo compatibles
2. Verificar que los cambios en `activitybarPart.ts` siguen siendo compatibles
3. Verificar que los cambios CSS siguen siendo aplicables
4. Actualizar el parche `vscode-actionbar-top.patch` si es necesario

### Modificaciones Futuras

Para modificar el comportamiento de la activity bar en titlebar:
1. Modificar `createTitlebarActivityBar()` en `titlebarPart.ts`
2. Modificar estilos en `titlebarpart.css`
3. Probar en las tres plataformas (Windows, macOS, Linux)

## Referencias

- [VSCode Workbench Architecture](https://github.com/microsoft/vscode/wiki/Source-Code-Organization)
- [VSCode Extension API - Workbench](https://code.visualstudio.com/api/references/vscode-api#window)
- [Electron Titlebar Customization](https://www.electronjs.org/docs/latest/tutorial/window-customization)

## Historial de Cambios

- **v0.1.0** (2024-12-28): Implementación inicial de reubicación de action bar a titlebar

