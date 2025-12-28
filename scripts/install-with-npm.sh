#!/bin/bash
# ElixIDE: Instalar dependencias usando npm (requerido por VSCode)

cd ~/proyectos/ElixIDE

# Cargar entorno
source scripts/init-env.sh

echo "=== ElixIDE: Instalación con npm ==="
echo ""
echo "⚠️  VSCode ahora requiere npm en lugar de yarn"
echo ""

# Verificar que npm está disponible
if ! command -v npm &> /dev/null; then
    echo "ERROR: npm no está disponible"
    exit 1
fi

echo "✅ npm: $(npm --version)"
echo ""

# Limpiar instalación anterior si existe
if [ -d "node_modules" ]; then
    echo "Limpiando instalación anterior..."
    rm -rf node_modules
    rm -rf .yarn
    rm -f .pnp.cjs .pnp.loader.mjs yarn.lock
fi

# Instalar con npm
echo "Instalando dependencias con npm (esto puede tardar 15-30 minutos)..."
npm install

echo ""
echo "=== Instalación completada ==="
echo ""
echo "Ahora puedes compilar con:"
echo "  npm run compile"
echo ""
echo "Y ejecutar ElixIDE con:"
echo "  ./scripts/code.sh"

