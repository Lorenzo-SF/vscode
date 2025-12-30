# API para Desarrolladores de Módulos

## Visión General

Esta API permite a los desarrolladores crear módulos para ElixIDE que se integren con el sistema de bootstrap y otros módulos.

## Estructura Básica de un Módulo

```typescript
// modules/v{N}-{nombre}/src/index.ts
import * as vscode from 'vscode';
import { ModuleApi } from './api/moduleApi';

export function activate(context: vscode.ExtensionContext): ModuleApi {
  // Inicializar módulo
  const api = new ModuleApi(context);
  
  // Registrar comandos, providers, etc.
  
  return api;
}

export function deactivate(): void {
  // Limpieza si es necesario
}
```

## API de ElixIDE

### Obtener API de Otro Módulo

```typescript
// Obtener API de otro módulo
const asdfApi = ElixIDE.getModuleApi<AsdfApi>('v2-asdf-manager');
if (asdfApi) {
  const env = await asdfApi.getEnvironmentForProject(projectPath);
}
```

### Publicar Eventos

```typescript
// Publicar evento
ElixIDE.publishEvent('module.event.name', { data: 'value' });
```

### Suscribirse a Eventos

```typescript
// Suscribirse a evento
ElixIDE.subscribeToEvent('module.event.name', (data) => {
  // Manejar evento
});
```

## Registro de Contribuciones

### Comandos

```typescript
context.subscriptions.push(
  vscode.commands.registerCommand('elixide.module.command', () => {
    // Implementación del comando
  })
);
```

### Providers

```typescript
// En package.json
{
  "contributes": {
    "providers": {
      "elixide.module.provider": {
        "id": "module-provider",
        "name": "Module Provider"
      }
    }
  }
}
```

## Manejo de Errores

Ver `Preprompt.md` sección 1.2 para patrones de manejo de errores.

## Testing

Ver `Preprompt.md` sección 1.8 para estándares de testing.

## Referencias

- [VSCode Extension API](https://code.visualstudio.com/api)
- [Sistema de Módulos](../architecture/modules.md)

