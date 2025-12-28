# Guía de Uso - ElixIDE

## 🚀 Inicio Rápido

### Primera vez (Setup inicial)

```bash
cd ~/proyectos/ElixIDE
./scripts/setup-and-compile.sh
```

Este script:
- Instala NVM si no está instalado
- Instala Node.js 22.21.1
- Configura Yarn
- Instala dependencias del proyecto
- Compila el proyecto

### Uso diario

**Opción 1: Usar scripts wrapper (Recomendado)**

```bash
cd ~/proyectos/ElixIDE

# Cargar entorno y ejecutar comandos
source scripts/init-env.sh
node --version
yarn --version
yarn start
```

**Opción 2: Usar scripts de inicio**

```bash
cd ~/proyectos/ElixIDE

# Iniciar ElixIDE (carga entorno automáticamente)
./scripts/start.sh

# Compilar proyecto
source scripts/init-env.sh && yarn compile
```

**Opción 3: Instalar aliases (Una sola vez)**

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

## 📋 Comandos Disponibles

### Scripts principales

- `./scripts/setup-and-compile.sh` - Setup completo y compilación
- `./scripts/init-env.sh` - Cargar entorno (source este archivo)
- `./scripts/start.sh` - Iniciar ElixIDE
- `./scripts/run-ci-checks.sh` - Ejecutar checks de CI/CD
- `./scripts/install-aliases.sh` - Instalar aliases en .bashrc

### Comandos después de cargar entorno

```bash
source scripts/init-env.sh

# Node.js
node --version
node script.js

# Yarn
yarn --version
yarn install
yarn compile
yarn start

# npm (también disponible)
npm --version
```

## ⚠️ Problemas Comunes

### "comando not found" para node o yarn

**Solución:** Carga el entorno primero:

```bash
cd ~/proyectos/ElixIDE
source scripts/init-env.sh
```

O usa los scripts wrapper:

```bash
./scripts/start.sh  # Para yarn start
```

### NVM no se carga automáticamente

**Solución:** El script `init-env.sh` carga NVM automáticamente. Si quieres que se cargue siempre, agrega esto a tu `~/.bashrc`:

```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
```

### El proyecto no compila

**Solución:** Ejecuta el setup completo:

```bash
cd ~/proyectos/ElixIDE
./scripts/setup-and-compile.sh
```

## 🔧 Configuración del Entorno

El entorno de ElixIDE requiere:
- **Node.js**: 22.21.1 (instalado via NVM)
- **Yarn**: Instalado via Corepack
- **Python**: 3.9.0 (para algunas dependencias nativas)

Todos estos se instalan automáticamente con `setup-and-compile.sh`.

## 📝 Notas

- El proyecto está en `~/proyectos/ElixIDE` (WSL2)
- Los scripts están en `~/Proyectos/ElixIDE-scripts` (separados del proyecto)
- Siempre carga el entorno con `source scripts/init-env.sh` antes de usar node/yarn directamente
- O usa los scripts wrapper que cargan el entorno automáticamente

