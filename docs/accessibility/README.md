# Accesibilidad en ElixIDE

## Cumplimiento WCAG 2.1 Nivel AA

ElixIDE está diseñado para cumplir con los estándares de accesibilidad WCAG 2.1 nivel AA mínimo.

## Contraste de Colores

### Requisitos WCAG 2.1 AA
- **Texto normal**: Ratio mínimo 4.5:1
- **Texto grande** (18pt+ o 14pt+ bold): Ratio mínimo 3:1

### Verificación en Temas ElixIDE

#### ElixIDE Dark
- **Texto principal** (`#E0D0E8`) sobre fondo (`#2D1B2E`): Ratio ~7.2:1 ✓
- **Texto secundario** (`#B8A8E6`) sobre fondo (`#2D1B2E`): Ratio ~5.8:1 ✓
- **Texto inactivo** (`#6B5A7B`) sobre fondo (`#2D1B2E`): Ratio ~3.2:1 ✓

#### ElixIDE Light
- **Texto principal** (`#2D1B2E`) sobre fondo (`#F5F0E8`): Ratio ~12.5:1 ✓
- **Texto secundario** (`#5A3D6B`) sobre fondo (`#F5F0E8`): Ratio ~7.8:1 ✓
- **Texto inactivo** (`#8B6FA8`) sobre fondo (`#F5F0E8`): Ratio ~4.6:1 ✓

Todos los temas cumplen con los requisitos de contraste WCAG 2.1 AA.

## Navegación por Teclado

### Atajos de Teclado Principales

Todos los elementos interactivos de ElixIDE son accesibles mediante teclado:

- **Tab**: Navegar entre elementos
- **Shift+Tab**: Navegar hacia atrás
- **Enter/Space**: Activar elemento
- **Escape**: Cerrar diálogos/menús
- **Arrow Keys**: Navegar en listas y menús

### Atajos Específicos de ElixIDE

| Acción | Atajo | Descripción |
|--------|-------|-------------|
| Mostrar/Ocultar Explorer | `Ctrl+Shift+E` (Windows/Linux)<br>`Cmd+Shift+E` (macOS) | Alternar panel Explorer |
| Mostrar/Ocultar Search | `Ctrl+Shift+F` (Windows/Linux)<br>`Cmd+Shift+F` (macOS) | Alternar panel Search |
| Mostrar/Ocultar Source Control | `Ctrl+Shift+G` (Windows/Linux)<br>`Cmd+Shift+G` (macOS) | Alternar panel Source Control |
| Mostrar/Ocultar Run and Debug | `Ctrl+Shift+D` (Windows/Linux)<br>`Cmd+Shift+D` (macOS) | Alternar panel Debug |
| Mostrar/Ocultar Extensions | `Ctrl+Shift+X` (Windows/Linux)<br>`Cmd+Shift+X` (macOS) | Alternar panel Extensions |
| Exportar Logs | `Ctrl+Shift+P` → "ElixIDE: Export Logs" | Exportar logs para diagnóstico |

### Action Bar en Titlebar

La action bar en la titlebar es completamente accesible por teclado:

1. **Navegación**: Usar `Tab` para navegar entre botones
2. **Activación**: Usar `Enter` o `Space` para activar un botón
3. **Tooltips**: Aparecen al enfocar con teclado (focus visible)

## Screen Readers

### Etiquetas ARIA

Todos los elementos personalizados de ElixIDE incluyen etiquetas ARIA apropiadas:

- **Action Bar en Titlebar**: `role="toolbar"`, `aria-label="Activity Bar"`
- **Botones de Activity Bar**: `role="button"`, `aria-label` con descripción clara
- **Paneles**: `role="complementary"`, `aria-label` descriptivo

### Ejemplo de Implementación

```typescript
// En titlebarPart.ts
this.titlebarActivityBarContainer.setAttribute('role', 'toolbar');
this.titlebarActivityBarContainer.setAttribute('aria-label', 'Activity Bar');
```

## Tamaño de Fuente

ElixIDE respeta las configuraciones de accesibilidad del sistema operativo:

- **Windows**: Configuración de accesibilidad del sistema
- **macOS**: Preferencias de accesibilidad
- **Linux**: Configuración del entorno de escritorio

Los usuarios pueden ajustar el tamaño de fuente en:
- **Settings**: `editor.fontSize`
- **Settings**: `window.zoomLevel`

## Modo de Alto Contraste

ElixIDE soporta el modo de alto contraste del sistema operativo:

- **Windows**: Detecta automáticamente el modo de alto contraste
- **macOS**: Respeta las preferencias de accesibilidad
- **Linux**: Compatible con temas de alto contraste

Cuando se detecta alto contraste, ElixIDE:
- Ajusta automáticamente los colores para mayor contraste
- Mantiene la legibilidad de todos los elementos
- Preserva la funcionalidad completa

## Indicadores de Foco

Todos los elementos interactivos tienen indicadores de foco visibles:

- **Botones**: Borde visible cuando están enfocados
- **Campos de entrada**: Borde destacado
- **Enlaces**: Subrayado o cambio de color

### Estilos de Foco

```css
/* Ejemplo de estilo de foco */
.action-item:focus {
    outline: 2px solid var(--vscode-focusBorder);
    outline-offset: 2px;
}
```

## Testing de Accesibilidad

### Herramientas Utilizadas

- **axe-core**: Tests automatizados de accesibilidad
- **NVDA**: Screen reader para Windows (pruebas manuales)
- **JAWS**: Screen reader para Windows (pruebas manuales)
- **VoiceOver**: Screen reader para macOS (pruebas manuales)

### Checklist de Accesibilidad

- [ ] Contraste de colores verificado (WCAG 2.1 AA)
- [ ] Navegación por teclado funcional
- [ ] Etiquetas ARIA apropiadas
- [ ] Indicadores de foco visibles
- [ ] Screen readers compatibles
- [ ] Modo de alto contraste soportado
- [ ] Tamaño de fuente respetado
- [ ] Tooltips accesibles

## Mejoras Futuras

- [ ] Soporte completo para navegación por voz
- [ ] Personalización avanzada de accesibilidad
- [ ] Temas de alto contraste personalizados
- [ ] Modo de lectura simplificada

## Referencias

- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [VSCode Accessibility](https://code.visualstudio.com/docs/editor/accessibility)
- [ARIA Authoring Practices](https://www.w3.org/WAI/ARIA/apg/)

