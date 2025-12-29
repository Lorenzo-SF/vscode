# Sistema de Módulos de ElixIDE

## Visión General

ElixIDE utiliza un sistema de módulos auto-contenidos que se cargan dinámicamente al iniciar la aplicación. Cada módulo es una extensión de VSCode independiente con su propia configuración y código.

## Estructura de un Módulo

```
modules/v{N}-{nombre-descriptivo}/
├── package.json                    # Configuración del módulo
├── tsconfig.json                   # Configuración TypeScript
├── README.md                       # Documentación del módulo
├── src/
│   ├── index.ts                    # Punto de entrada, exporta activate()
│   ├── core/                       # Lógica principal
│   ├── api/                        # API pública
│   ├── ui/                         # Componentes de UI
│   ├── integrations/               # Integraciones con otros módulos
│   └── utils/                      # Utilidades
└── tests/                          # Tests del módulo
```

## Carga de Módulos

El sistema de bootstrap (`src/bootstrap.ts`) escanea el directorio `modules/` y carga automáticamente todos los módulos encontrados:

1. Detecta módulos buscando `package.json` en `modules/`
2. Lee la configuración de cada módulo
3. Carga el punto de entrada (`src/index.ts`)
4. Ejecuta `activate()` de cada módulo
5. Registra contribuciones en la API de VSCode

## Comunicación entre Módulos

Los módulos se comunican a través de:

1. **API Pública**: Cada módulo exporta una API TypeScript
2. **Bus de Eventos**: Sistema de eventos de VSCode
3. **Context Keys**: Estado compartido mediante context keys

## Ejemplo de Módulo

```typescript
// modules/v0-core/src/index.ts
import * as vscode from 'vscode';
import { CoreApi } from './api/coreApi';

export function activate(context: vscode.ExtensionContext): CoreApi {
  // Inicializar módulo
  const api = new CoreApi(context);
  
  // Registrar comandos
  context.subscriptions.push(
    vscode.commands.registerCommand('elixide.core.showVersion', () => {
      vscode.window.showInformationMessage('ElixIDE v0.1.0');
    })
  );
  
  return api;
}
```

## Referencias

- [API para Desarrolladores de Módulos](../api/module-api.md)

