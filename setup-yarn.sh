#!/bin/bash
# setup-yarn.sh - Script de configuración de entorno para ElixIDE
# Compatible con macOS, Linux (Ubuntu/Debian) y WSL2

set -e  # Salir si hay errores

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Log file
LOG_FILE="./setup-yarn.log"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "========================================"
echo -e "${CYAN}ElixIDE - Setup de Entorno${NC}"
echo "========================================"
echo ""

# Fase 0: Detección de Plataforma
echo -e "${YELLOW}[Fase 0] Detección de plataforma...${NC}"

# Verificar que estamos en el directorio correcto
if [ ! -d ".git" ] || [ ! -f "package.json" ]; then
    echo -e "${RED}ERROR: Este script debe ejecutarse desde el directorio raíz de ElixIDE${NC}"
    exit 1
fi

# Detectar plataforma
PLATFORM="unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="darwin"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
    # Verificar si estamos en WSL2
    if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null ; then
        PLATFORM="wsl2"
    fi
else
    echo -e "${RED}ERROR: Plataforma no soportada: $OSTYPE${NC}"
    exit 1
fi

echo -e "${GREEN}Plataforma detectada: $PLATFORM${NC}"
echo ""

# Fase 1: Prerrequisitos del Sistema Operativo
echo -e "${YELLOW}[Fase 1] Instalando prerrequisitos del sistema...${NC}"

if [ "$PLATFORM" == "darwin" ]; then
    # macOS
    if ! command -v brew &> /dev/null; then
        echo "Instalando Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    fi
    
    if ! xcode-select -p &> /dev/null; then
        echo "Instalando Xcode Command Line Tools..."
        xcode-select --install || true
    fi
    
elif [ "$PLATFORM" == "linux" ] || [ "$PLATFORM" == "wsl2" ]; then
    # Linux / WSL2
    echo "Actualizando lista de paquetes..."
    sudo apt-get update -qq
    
    echo "Instalando dependencias del sistema..."
    sudo apt-get install -y \
        build-essential \
        curl \
        wget \
        git \
        ca-certificates \
        gnupg \
        lsb-release \
        libx11-dev \
        libxkbfile-dev \
        libsecret-1-dev \
        libgtk-3-dev \
        libnss3-dev \
        libatk-bridge2.0-dev \
        libdrm2 \
        libxkbcommon-dev \
        libxcomposite-dev \
        libxdamage-dev \
        libxrandr-dev \
        libgbm-dev \
        libasound2-dev \
        libpango1.0-dev \
        libatk1.0-dev \
        libcairo-gobject2 \
        libgdk-pixbuf2.0-dev \
        python3 \
        python3-pip \
        python3-dev \
        libssl-dev \
        libffi-dev \
        pkg-config \
        > /dev/null 2>&1
    
    echo -e "${GREEN}Dependencias del sistema instaladas${NC}"
fi

echo ""

# Fase 2: Gestores de Versiones de Lenguaje
echo -e "${YELLOW}[Fase 2] Configurando gestores de versiones...${NC}"

# Node.js via NVM
if [ ! -d "$HOME/.nvm" ]; then
    echo "Instalando nvm..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
fi

# Cargar nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Leer versión de Node.js desde .nvmrc
NODE_VERSION=$(cat .nvmrc | tr -d '\n')
echo "Versión de Node.js requerida: $NODE_VERSION"

# Instalar Node.js si no está presente
if ! nvm list | grep -q "$NODE_VERSION"; then
    echo "Instalando Node.js $NODE_VERSION..."
    nvm install "$NODE_VERSION"
fi

# Usar versión correcta
nvm use "$NODE_VERSION"
nvm alias default "$NODE_VERSION"

# Verificar Node.js
NODE_ACTUAL=$(node --version)
if [ "$NODE_ACTUAL" == "v$NODE_VERSION" ]; then
    echo -e "${GREEN}✓ Node.js $NODE_ACTUAL${NC}"
else
    echo -e "${RED}✗ Node.js versión incorrecta: $NODE_ACTUAL (esperado: v$NODE_VERSION)${NC}"
    exit 1
fi

# Python via Pyenv
PYTHON_VERSION=$(cat .python-version | tr -d '\n')
echo "Versión de Python requerida: $PYTHON_VERSION"

if [ ! -d "$HOME/.pyenv" ]; then
    echo "Instalando pyenv..."
    if [ "$PLATFORM" == "darwin" ]; then
        brew install pyenv
    else
        curl https://pyenv.run | bash
    fi
fi

# Configurar pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# Instalar Python si no está presente
if ! pyenv versions | grep -q "$PYTHON_VERSION"; then
    echo "Instalando Python $PYTHON_VERSION..."
    pyenv install "$PYTHON_VERSION"
fi

# Establecer Python global
pyenv global "$PYTHON_VERSION"

# Verificar Python
PYTHON_ACTUAL=$(python --version 2>&1)
if echo "$PYTHON_ACTUAL" | grep -q "Python $PYTHON_VERSION"; then
    echo -e "${GREEN}✓ $PYTHON_ACTUAL${NC}"
else
    echo -e "${RED}✗ Python versión incorrecta: $PYTHON_ACTUAL (esperado: Python $PYTHON_VERSION)${NC}"
    exit 1
fi

echo ""

# Fase 3: Configuración de Yarn
echo -e "${YELLOW}[Fase 3] Configurando Yarn...${NC}"

# Activar Corepack
corepack enable

# Verificar Yarn
if command -v yarn &> /dev/null; then
    YARN_VERSION=$(yarn --version)
    echo -e "${GREEN}✓ Yarn $YARN_VERSION${NC}"
else
    echo "Instalando Yarn como fallback..."
    npm install -g yarn
    YARN_VERSION=$(yarn --version)
    echo -e "${GREEN}✓ Yarn $YARN_VERSION${NC}"
fi

# Configurar Yarn
yarn config set network-timeout 600000
yarn config set network-concurrency 1

echo ""

# Fase 4: Instalación de Dependencias del Proyecto
echo -e "${YELLOW}[Fase 4] Instalando dependencias del proyecto...${NC}"
echo "Esto puede tardar 10-30 minutos..."

# Limpiar cache (opcional)
# yarn cache clean

# Instalar dependencias
if [ -f "yarn.lock" ]; then
    echo "Instalando con yarn.lock..."
    yarn install --frozen-lockfile
else
    echo "Instalando sin yarn.lock..."
    yarn install
fi

echo -e "${GREEN}Dependencias instaladas${NC}"
echo ""

# Fase 5: Compilación Inicial del Proyecto
echo -e "${YELLOW}[Fase 5] Compilando proyecto...${NC}"
echo "Esto puede tardar varios minutos..."

yarn compile

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Compilación exitosa${NC}"
else
    echo -e "${RED}ERROR: La compilación falló${NC}"
    exit 1
fi

echo ""

# Fase 6: Verificación Integral del Entorno
echo -e "${YELLOW}[Fase 6] Verificación final...${NC}"

# Verificar versiones
echo "Verificando versiones..."
NODE_VER=$(node --version)
YARN_VER=$(yarn --version)
PYTHON_VER=$(python --version 2>&1)
GIT_VER=$(git --version | cut -d' ' -f3)

echo -e "  Node.js: ${GREEN}$NODE_VER${NC}"
echo -e "  Yarn: ${GREEN}$YARN_VER${NC}"
echo -e "  Python: ${GREEN}$PYTHON_VER${NC}"
echo -e "  Git: ${GREEN}$GIT_VER${NC}"

# Verificar herramientas de compilación
if command -v gcc &> /dev/null; then
    GCC_VER=$(gcc --version | head -n1)
    echo -e "  GCC: ${GREEN}$GCC_VER${NC}"
fi

if command -v make &> /dev/null; then
    MAKE_VER=$(make --version | head -n1)
    echo -e "  Make: ${GREEN}$MAKE_VER${NC}"
fi

# Verificar espacio en disco
AVAILABLE_SPACE=$(df -h . | tail -1 | awk '{print $4}')
echo -e "  Espacio disponible: ${GREEN}$AVAILABLE_SPACE${NC}"

echo ""

# Fase 7: Documentación y Finalización
echo "========================================"
echo -e "${GREEN}Setup completado exitosamente!${NC}"
echo "========================================"
echo ""
echo -e "${CYAN}Comandos útiles:${NC}"
echo "  yarn compile  - Compilar el proyecto"
echo "  yarn watch    - Modo desarrollo (watch)"
echo "  yarn start    - Ejecutar ElixIDE"
echo "  yarn test     - Ejecutar tests"
echo ""
echo -e "${YELLOW}Log completo guardado en: $LOG_FILE${NC}"
echo ""

