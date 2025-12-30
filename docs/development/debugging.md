# Guía de Debugging de ElixIDE

## Debugging en VSCode

### Configuración de Launch

El archivo `.vscode/launch.json` contiene configuraciones para depurar ElixIDE:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Launch ElixIDE",
      "type": "node",
      "request": "launch",
      "runtimeExecutable": "${workspaceFolder}/scripts/code.sh",
      "runtimeArgs": ["--extensionDevelopmentPath=${workspaceFolder}"],
      "console": "integratedTerminal"
    }
  ]
}
```

### Pasos para Debugging

1. Compilar el proyecto: `npm run compile`
2. Establecer breakpoints en el código
3. Presionar F5 o seleccionar "Launch ElixIDE" en el debugger
4. ElixIDE se abrirá en una nueva ventana con debugging habilitado

## Debugging de Módulos

### Debugging Individual

Para depurar un módulo específico:

1. Abrir el módulo en VSCode
2. Establecer breakpoints en `src/index.ts` o archivos del módulo
3. Ejecutar ElixIDE en modo desarrollo
4. Los breakpoints se activarán cuando el módulo se cargue

### Logs de Módulos

Los módulos pueden usar el sistema de logging de VSCode:

```typescript
import * as vscode from 'vscode';

// Logging básico
console.log('Módulo cargado');

// Output channel dedicado
const outputChannel = vscode.window.createOutputChannel('ElixIDE Module');
outputChannel.appendLine('Mensaje de log');
```

## Developer Tools

### Consola de Desarrollo

1. Abrir ElixIDE
2. Help > Toggle Developer Tools
3. Verificar pestaña Console para errores
4. Usar pestaña Network para debugging de requests

### Inspección de UI

1. Abrir Developer Tools
2. Usar Inspector (Ctrl+Shift+C / Cmd+Shift+C)
3. Inspeccionar elementos de la UI
4. Ver estilos CSS aplicados

## Troubleshooting

### ElixIDE no inicia
- Verificar que `npm run compile` completó sin errores
- Verificar logs en Developer Tools
- Verificar que Node.js es la versión correcta (v22.21.1)

### Módulos no cargan
- Verificar que `src/bootstrap.ts` está ejecutándose
- Verificar logs en Output Channel
- Verificar que `package.json` del módulo es válido

### Breakpoints no funcionan
- Verificar que el código está compilado
- Verificar que source maps están habilitados
- Verificar que el archivo fuente corresponde al código ejecutado

## Referencias

- [VSCode Extension API](https://code.visualstudio.com/api)
- [Chrome DevTools](https://developer.chrome.com/docs/devtools/)

