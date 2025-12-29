# Arquitectura de ElixIDE

## Visión General

ElixIDE es un fork de VSCode/Code-OSS diseñado específicamente para desarrollo en Elixir. Mantiene la funcionalidad completa de VSCode mientras agrega características específicas para Elixir.

## Componentes Principales

### 1. Core de VSCode (Submódulo)

- **Ubicación**: `vscode-original/` (submódulo Git)
- **Propósito**: Base de VSCode sin modificaciones
- **Actualización**: Se actualiza desde upstream de VSCode
- **Modificaciones**: Se aplican mediante parches en `patches/`

### 2. Sistema de Módulos

- **Ubicación**: `modules/`
- **Propósito**: Módulos personalizados de ElixIDE
- **Carga**: Sistema de bootstrap dinámico
- **API**: Interfaz `ElixIDEAPI` para comunicación entre módulos

### 3. Sistema de Temas

- **Ubicación**: `assets/themes/` y `extensions/theme-defaults/themes/`
- **Temas**: ElixIDE Dark y ElixIDE Light
- **Sincronización**: Desde `Prompts/assets/themes/` (fuente de verdad)

### 4. Sistema de Assets

- **Ubicación**: `assets/`
- **Fuente de Verdad**: `Prompts/assets/`
- **Sincronización**: Scripts en `scripts/assets/`

## Flujo de Datos

```
Prompts/assets/ (Fuente de Verdad)
    ↓ sync-assets.sh
ElixIDE/assets/ (Copia de Trabajo)
    ↓ durante build
vscode-original/extensions/theme-defaults/themes/ (Ubicación Final)
```

## Sistema de Bootstrap

El sistema de bootstrap carga dinámicamente todos los módulos desde `modules/`:

1. Escanea `modules/` buscando directorios con `package.json`
2. Carga cada módulo usando `require()`
3. Activa cada módulo llamando a su función `activate()`
4. Registra APIs de módulos para comunicación inter-módulo

## Sistema de Parches

Los parches modifican el core de VSCode sin hacer fork completo:

1. Parches en `patches/` se aplican durante build
2. Cada parche modifica archivos específicos del core
3. Los parches se pueden actualizar cuando VSCode upstream cambia

## Referencias

- [Documentación de Módulos](modules.md)
- [Sistema de Build](build-system.md)
- [Reubicación de Action Bar](actionbar-relocation.md)
