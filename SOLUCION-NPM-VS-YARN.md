# Solución: VSCode Requiere npm en lugar de yarn

## Problema

Al ejecutar `yarn install`, obtienes:

```
*** Seems like you are using `yarn` which is not supported in this repo any more, please use `npm i` instead. ***
```

## ✅ Solución

VSCode ha cambiado y ahora **requiere npm** en lugar de yarn para la instalación.

### Opción 1: Usar npm directamente (Recomendado)

```bash
cd ~/proyectos/ElixIDE
source scripts/init-env.sh
npm install
```

### Opción 2: Usar script de instalación

```bash
cd ~/proyectos/ElixIDE
./scripts/install-with-npm.sh
```

### Opción 3: Setup completo con npm

```bash
cd ~/proyectos/ElixIDE
./scripts/setup-and-compile.sh
```

Este script ahora usa npm en lugar de yarn.

## 📋 Comandos Actualizados

| Comando Anterior (yarn) | Comando Nuevo (npm) |
|------------------------|---------------------|
| `yarn install` | `npm install` |
| `yarn compile` | `npm run compile` |
| `yarn start` | `./scripts/code.sh` |

## ⚠️ Nota sobre node-gyp

Si ves errores sobre `node-gyp`, puedes instalarlo globalmente:

```bash
npm install -g node-gyp
```

Pero normalmente no es necesario, npm lo incluye.

## ✅ Verificación

Después de instalar con npm:

```bash
source scripts/init-env.sh
npm install          # Debería completarse sin errores
npm run compile      # Debería compilar correctamente
./scripts/code.sh    # Debería iniciar ElixIDE
```

## 🔄 Migración de yarn a npm

Si ya tienes una instalación con yarn:

```bash
cd ~/proyectos/ElixIDE

# Limpiar instalación anterior
rm -rf node_modules
rm -rf .yarn
rm -f .pnp.cjs .pnp.loader.mjs yarn.lock

# Instalar con npm
source scripts/init-env.sh
npm install
```

## 📝 Scripts Actualizados

- `scripts/setup-and-compile.sh` - Ahora usa npm
- `scripts/install-with-npm.sh` - Nuevo script para instalación con npm
- `scripts/start.sh` - Sigue funcionando igual (usa `./scripts/code.sh`)

