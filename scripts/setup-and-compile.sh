#!/bin/bash
set -e

echo "=== ElixIDE: Setup y Compilación ==="

# Cargar NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"

cd ~/proyectos/ElixIDE

# Instalar Node.js 22.21.1 si no está instalado
if ! command -v node &> /dev/null || [ "$(node --version)" != "v22.21.1" ]; then
    echo "Instalando Node.js 22.21.1..."
    nvm install 22.21.1
    nvm use 22.21.1
    nvm alias default 22.21.1
fi

# Activar Node.js
nvm use 22.21.1

# Verificar Node.js
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"

# Habilitar Corepack y Yarn
echo "Configurando Yarn..."
corepack enable || true
corepack prepare yarn@stable --activate || true

# Verificar Yarn
echo "Yarn: $(yarn --version)"

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

