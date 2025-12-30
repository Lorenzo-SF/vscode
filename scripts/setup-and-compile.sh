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

# Verificar npm (VSCode ahora requiere npm)
echo "✅ npm: $(npm --version)"

# Nota: VSCode ahora requiere npm en lugar de yarn
echo ""
echo "⚠️  VSCode requiere npm para la instalación"
echo ""

# Instalar dependencias con npm
echo "=== Instalando dependencias con npm (esto puede tardar 15-30 minutos) ==="
npm install

# Compilar
echo ""
echo "=== Compilando proyecto ==="
npm run compile

echo ""
echo "=== Setup completado ==="
echo "Para ejecutar ElixIDE: yarn start"

