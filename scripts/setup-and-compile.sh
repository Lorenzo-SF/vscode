#!/bin/bash
set -e

echo "=== ElixIDE: Setup y Compilación ==="

cd ~/proyectos/ElixIDE

# Instalar NVM si no está instalado
if [ ! -d "$HOME/.nvm" ]; then
    echo "Instalando NVM..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
    
    # Agregar a .bashrc para futuras sesiones
    if ! grep -q "NVM_DIR" ~/.bashrc; then
        echo '' >> ~/.bashrc
        echo '# NVM' >> ~/.bashrc
        echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
        echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
        echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc
    fi
else
    # Cargar NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
fi

# Instalar Node.js 22.21.1 si no está instalado
if ! command -v node &> /dev/null || [ "$(node --version 2>/dev/null)" != "v22.21.1" ]; then
    echo "Instalando Node.js 22.21.1..."
    nvm install 22.21.1
    nvm use 22.21.1
    nvm alias default 22.21.1
else
    nvm use 22.21.1
fi

# Verificar Node.js
echo "✅ Node.js: $(node --version)"
echo "✅ npm: $(npm --version)"

# Habilitar Corepack y Yarn
echo "Configurando Yarn..."
corepack enable || true
corepack prepare yarn@stable --activate || true

# Verificar Yarn
if command -v yarn &> /dev/null; then
    echo "✅ Yarn: $(yarn --version)"
else
    echo "⚠️  Yarn no disponible, intentando instalar..."
    npm install -g yarn
    echo "✅ Yarn: $(yarn --version)"
fi

# Instalar dependencias
echo ""
echo "=== Instalando dependencias (esto puede tardar 10-15 minutos) ==="
yarn install

# Compilar
echo ""
echo "=== Compilando proyecto ==="
yarn compile

echo ""
echo "=== Setup completado ==="
echo "Para ejecutar ElixIDE: yarn start"

