# Guía de Configuración de Desarrollo

## Requisitos Previos

### Software Requerido

- **Node.js**: v18.x o superior (verificar con `node --version`)
- **Yarn**: v1.22+ o npm v8+ (recomendado yarn)
- **Git**: v2.30+
- **Python**: v3.8+ (para algunas dependencias)
- **Build Tools**:
  - Windows: Visual Studio Build Tools
  - macOS: Xcode Command Line Tools
  - Linux: build-essential

### Verificar Versiones

```bash
node --version    # Debe ser v18.x+
yarn --version    # Debe ser v1.22+
git --version     # Debe ser v2.30+
python3 --version # Debe ser v3.8+
```

## Configuración Inicial

### 1. Clonar Repositorio

```bash
git clone <repository-url>
cd ElixIDE
```

### 2. Inicializar Submódulo

```bash
git submodule update --init --recursive
```

### 3. Instalar Dependencias

```bash
# Con yarn (recomendado)
yarn install

# O con npm
npm install
```

### 4. Aplicar Parches

```bash
cd vscode-original
for patch in ../patches/*.patch; do
    git apply "$patch"
done
cd ..
```

### 5. Sincronizar Assets

```bash
bash scripts/assets/sync-assets.sh
```

### 6. Compilar

```bash
# Con yarn
yarn run compile

# O con npm
npm run compile
```

## Desarrollo

### Modo Desarrollo

```bash
# Compilar en modo watch
yarn run watch

# En otra terminal, iniciar ElixIDE
yarn run elixide:start
```

### Estructura de Directorios

```
ElixIDE/
├── src/              # Código fuente de ElixIDE
├── modules/          # Módulos personalizados
├── assets/           # Assets (temas, iconos)
├── patches/          # Parches para VSCode
├── scripts/          # Scripts de build y utilidades
├── docs/             # Documentación
└── vscode-original/  # Submódulo de VSCode
```

### Compilar Módulos

Cada módulo debe compilarse individualmente:

```bash
cd modules/core
yarn install
yarn run compile
```

### Hot Reload

ElixIDE soporta hot reload para módulos durante desarrollo:

1. Compilar módulo en modo watch: `yarn run watch`
2. Los cambios se reflejan automáticamente al recargar la ventana

## Debugging

### Configurar Launch

El archivo `.vscode/launch.json` está configurado para debugging:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Launch ElixIDE",
      "type": "node",
      "request": "launch",
      "program": "${workspaceFolder}/src/extension.ts",
      "outFiles": ["${workspaceFolder}/out/**/*.js"]
    }
  ]
}
```

### Debugging Módulos

Para debuggear módulos:

1. Abrir módulo en VSCode
2. Configurar breakpoints
3. Ejecutar ElixIDE en modo debug
4. Los breakpoints se activarán cuando el módulo se ejecute

## Testing

### Ejecutar Tests

```bash
# Tests unitarios
yarn run test

# Tests funcionales
bash scripts/test/v0-functional-tests.sh

# Validaciones
bash scripts/test/v0-validations-checklist.sh
```

## Troubleshooting

### Problemas Comunes

#### Submódulo no se inicializa

```bash
git submodule update --init --recursive
```

#### Parches no se aplican

```bash
cd vscode-original
git reset --hard
for patch in ../patches/*.patch; do
    git apply "$patch"
done
```

#### Assets no se sincronizan

```bash
bash scripts/assets/sync-assets.sh
bash scripts/assets/verify-assets.sh
```

#### Errores de compilación

```bash
# Limpiar y recompilar
rm -rf out/ node_modules/.cache/
yarn install
yarn run compile
```

## Referencias

- [Guía de Contribución](../development/contributing.md)
- [Guía de Debugging](../development/debugging.md)
- [Problemas Comunes](../troubleshooting/common-issues.md)
