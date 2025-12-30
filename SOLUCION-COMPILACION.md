# Solución: Errores de Compilación de Módulos Nativos

## Problema

Al ejecutar `yarn install`, varios módulos nativos fallan al compilar:

```
➤ YN0009: │ native-keymap@npm:3.3.7 couldn't be built successfully
➤ YN0009: │ @vscode/deviceid@npm:0.1.2 couldn't be built successfully
➤ YN0009: │ @vscode/windows-registry@npm:1.1.2 couldn't be built successfully
...
```

## ✅ Solución

### Paso 1: Instalar dependencias del sistema

```bash
cd ~/proyectos/ElixIDE
./scripts/install-build-deps.sh
```

Este script instala:
- `build-essential` - Herramientas de compilación (gcc, make, etc.)
- `python3` y `python3-dev` - Requerido para node-gyp
- `pkg-config` - Para encontrar librerías del sistema
- Todas las librerías necesarias para módulos nativos

### Paso 2: Reinstalar dependencias

```bash
source scripts/init-env.sh
yarn install
```

### Paso 3: Compilar el proyecto

```bash
yarn compile
```

### Paso 4: Iniciar ElixIDE

```bash
./scripts/start.sh
```

O directamente:

```bash
./scripts/code.sh
```

## 📋 Scripts Disponibles

| Script | Descripción |
|-------|-------------|
| `./scripts/install-build-deps.sh` | Instala dependencias del sistema |
| `./scripts/init-env.sh` | Carga el entorno (source este archivo) |
| `./scripts/start.sh` | Inicia ElixIDE (verifica e instala todo) |
| `./scripts/code.sh` | Ejecuta ElixIDE directamente |

## ⚠️ Nota sobre Módulos de Windows

Algunos módulos nativos son específicos de Windows:
- `@vscode/windows-registry`
- `@vscode/windows-process-tree`
- `@vscode/windows-mutex`

Estos fallarán en Linux/WSL2, pero **no son críticos** para el funcionamiento básico. VSCode tiene código de respaldo para cuando estos módulos no están disponibles.

## 🔍 Verificar Logs de Compilación

Si un módulo falla, puedes ver el log:

```bash
cat /tmp/xfs-XXXXXX/build.log
```

Reemplaza `XXXXXX` con el código del error.

## ✅ Verificación

Después de instalar las dependencias, deberías poder:

```bash
source scripts/init-env.sh
yarn install  # Debería completarse sin errores críticos
yarn compile  # Debería compilar correctamente
./scripts/start.sh  # Debería iniciar ElixIDE
```

