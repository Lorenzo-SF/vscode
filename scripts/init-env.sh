#!/bin/bash
# ElixIDE: Script de inicialización del entorno
# Este script debe ser source'd antes de ejecutar cualquier comando
# Uso: source scripts/init-env.sh

# Cargar NVM
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
    . "$NVM_DIR/nvm.sh"
    . "$NVM_DIR/bash_completion"
else
    echo "ERROR: NVM no está instalado. Ejecuta primero: ./scripts/setup-and-compile.sh"
    return 1 2>/dev/null || exit 1
fi

# Activar Node.js 22.21.1
if ! nvm use 22.21.1 2>/dev/null; then
    echo "Instalando Node.js 22.21.1..."
    nvm install 22.21.1
    nvm use 22.21.1
    nvm alias default 22.21.1
fi

# Habilitar Corepack y Yarn
if ! command -v yarn &> /dev/null; then
    echo "Configurando Yarn..."
    corepack enable || true
    corepack prepare yarn@stable --activate || true
fi

# Verificar instalación
echo "✅ Entorno configurado:"
echo "   Node.js: $(node --version)"
echo "   npm: $(npm --version)"
echo "   Yarn: $(yarn --version 2>/dev/null || echo 'no disponible')"

