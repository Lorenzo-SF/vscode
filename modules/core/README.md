# ElixIDE Core Module

Módulo core de ElixIDE que proporciona funcionalidades básicas y demuestra el sistema de módulos.

## Funcionalidades

- Comando `ElixIDE: Show Version` - Muestra la versión de ElixIDE
- API pública para otros módulos

## Uso

Este módulo se carga automáticamente al iniciar ElixIDE mediante el sistema de bootstrap.

## API Pública

```typescript
import { CoreApi } from 'v0-core/api/coreApi';

const coreApi = ElixIDE.getModuleApi<CoreApi>('v0-core');
if (coreApi) {
  const version = coreApi.getVersion();
  coreApi.showInfo();
}
```

