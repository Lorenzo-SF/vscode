# ✅ Solución: "comando not found" para node y yarn

## Problema

Al ejecutar `node` o `yarn start` directamente, obtienes:
```
bash: node: command not found
bash: yarn: command not found
```

## ✅ Solución Implementada

Se han creado scripts que cargan automáticamente el entorno necesario.

## 🚀 Formas de Usar

### Opción 1: Scripts Wrapper (RECOMENDADO)

```bash
cd ~/proyectos/ElixIDE

# Iniciar ElixIDE (carga entorno automáticamente)
./scripts/start.sh

# Compilar proyecto
source scripts/init-env.sh && yarn compile
```

### Opción 2: Cargar Entorno Manualmente

```bash
cd ~/proyectos/ElixIDE

# Cargar entorno (hacer esto ANTES de usar node/yarn)
source scripts/init-env.sh

# Ahora puedes usar node y yarn normalmente
node --version
yarn --version
yarn start
yarn compile
```

### Opción 3: Aliases (Una sola vez)

```bash
cd ~/proyectos/ElixIDE
./scripts/install-aliases.sh
source ~/.bashrc

# Ahora puedes usar:
elixide-node --version
elixide-yarn --version
elixide-start
elixide-compile
```

## 📋 Scripts Disponibles

| Script | Descripción |
|--------|-------------|
| `./scripts/init-env.sh` | Carga el entorno (source este archivo) |
| `./scripts/start.sh` | Inicia ElixIDE (carga entorno automáticamente) |
| `./scripts/setup-and-compile.sh` | Setup completo y compilación |
| `./scripts/install-aliases.sh` | Instala aliases en .bashrc |

## ⚙️ ¿Por qué es necesario?

El proyecto usa:
- **NVM** para gestionar Node.js
- **Corepack** para gestionar Yarn

Estos no se cargan automáticamente en cada shell. Los scripts `init-env.sh` y `start.sh` los cargan automáticamente.

## ✅ Verificación

```bash
cd ~/proyectos/ElixIDE
source scripts/init-env.sh

# Deberías ver:
# ✅ Entorno configurado:
#    Node.js: v22.21.1
#    npm: 10.9.4
#    Yarn: 4.12.0

node --version  # Debería funcionar
yarn --version  # Debería funcionar
```

## 📝 Nota Importante

**Siempre carga el entorno primero:**
```bash
source scripts/init-env.sh
```

**O usa los scripts wrapper que lo hacen automáticamente:**
```bash
./scripts/start.sh
```

