# Sistema de Construcción de ElixIDE

## Visión General

El sistema de construcción de ElixIDE está diseñado para ser multiplataforma (macOS, Linux, Windows/WSL2) y reproducible. Utiliza scripts de build específicos por plataforma y aplica parches al core de VSCode durante el proceso.

## Proceso de Construcción

### 1. Preparación
1. Actualizar submódulo `vscode-original` al commit/tag correcto
2. Verificar y sincronizar assets desde `Prompts/assets/`
3. Aplicar parches al core de VSCode:
   - `patches/vscode-identity.patch` (branding)
   - `patches/vscode-actionbar-top.patch` (UI modifications)

### 2. Compilación
1. Instalar dependencias: `npm install` o `yarn install`
2. Compilar TypeScript: `npm run compile`
3. Compilar extensiones: `npm run compile-extensions-build`
4. Verificar hygiene: `npm run hygiene`

### 3. Empaquetado
- **macOS**: `npm run elixide:package:macos` → genera `.dmg`
- **Linux**: `npm run elixide:package:linux` → genera `.AppImage`, `.deb`, `.rpm`
- **Windows**: `npm run elixide:package:windows` → genera `.exe`

## Scripts de Build

### Scripts Comunes
- `scripts/build/common.sh`: Funciones comunes para todos los scripts
- `scripts/assets/sync-assets.sh`: Sincroniza assets desde `Prompts/assets/`
- `scripts/assets/verify-assets.sh`: Verifica integridad de assets

### Scripts por Plataforma
- `scripts/build/darwin.sh`: Build para macOS
- `scripts/build/linux.sh`: Build para Linux
- `scripts/build/win32.ps1`: Build para Windows (desde PowerShell)

## Requisitos

### Herramientas Requeridas
- Node.js v22.21.1 (gestionado por nvm)
- Python 3.9.0 (gestionado por pyenv)
- Yarn ≥ 1.22.x
- Build essentials (gcc, make, pkg-config)

### Herramientas por Plataforma
- **macOS**: Xcode Command Line Tools, create-dmg (opcional)
- **Linux**: fakeroot, dpkg-dev (para .deb), rpm-build (para .rpm)
- **Windows**: InnoSetup 6.x (para .exe)

## Troubleshooting

Ver [docs/troubleshooting/build-issues.md](../troubleshooting/build-issues.md) para problemas comunes de build.

