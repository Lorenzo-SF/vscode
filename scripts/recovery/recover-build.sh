#!/bin/bash
# recover-build.sh - Limpia y reconstruye desde cero
# Especificación: v0.md sección 6.3

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Recuperación Completa de Build${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""
echo -e "${YELLOW}ADVERTENCIA: Este script limpiará todos los archivos de build${NC}"
read -p "¿Continuar? (y/n): " confirm

if [ "$confirm" != "y" ]; then
    echo "Operación cancelada"
    exit 0
fi

# 1. Limpiar archivos de build
echo -e "${YELLOW}[1/5] Limpiando archivos de build...${NC}"
rm -rf out/
rm -rf .build/
rm -rf build/
rm -rf node_modules/.cache/
echo "  ✓ Archivos de build eliminados"

# 2. Limpiar compilaciones de TypeScript
echo -e "${YELLOW}[2/5] Limpiando compilaciones TypeScript...${NC}"
find . -type d -name "out" -not -path "./node_modules/*" -exec rm -rf {} + 2>/dev/null || true
find . -type d -name ".tsbuildinfo" -not -path "./node_modules/*" -exec rm -rf {} + 2>/dev/null || true
echo "  ✓ Compilaciones TypeScript eliminadas"

# 3. Restaurar submódulo
echo -e "${YELLOW}[3/5] Restaurando submódulo...${NC}"
if [ -f "scripts/recovery/recover-submodule.sh" ]; then
    bash scripts/recovery/recover-submodule.sh <<< "1"
else
    echo "  ⊘ Script de recuperación de submódulo no encontrado"
fi

# 4. Aplicar parches
echo -e "${YELLOW}[4/5] Aplicando parches...${NC}"
if [ -d "patches" ]; then
    if [ -d "vscode-original" ] || [ -d "src/vscode-original" ]; then
        SUBMODULE_PATH="vscode-original"
        [ -d "src/vscode-original" ] && SUBMODULE_PATH="src/vscode-original"
        
        cd "$SUBMODULE_PATH"
        for patch in ../patches/*.patch; do
            if [ -f "$patch" ]; then
                echo "  Aplicando $(basename $patch)..."
                git apply "$patch" 2>/dev/null || {
                    echo -e "  ${YELLOW}⚠ Parche $(basename $patch) no se pudo aplicar (puede estar ya aplicado)${NC}"
                }
            fi
        done
        cd "$PROJECT_ROOT"
        echo "  ✓ Parches aplicados"
    else
        echo "  ⊘ Submódulo no encontrado"
    fi
else
    echo "  ⊘ Directorio patches/ no encontrado"
fi

# 5. Reinstalar dependencias y compilar
echo -e "${YELLOW}[5/5] Reinstalando dependencias y compilando...${NC}"
if command -v yarn > /dev/null 2>&1; then
    echo "  Instalando dependencias con yarn..."
    yarn install
    echo "  Compilando..."
    yarn run compile
elif command -v npm > /dev/null 2>&1; then
    echo "  Instalando dependencias con npm..."
    npm install
    echo "  Compilando..."
    npm run compile
else
    echo -e "  ${RED}✗ No se encontró yarn ni npm${NC}"
    exit 1
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Recuperación de build completada${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Próximos pasos:"
echo "1. Verificar que el proyecto compila: npm run compile"
echo "2. Probar que ElixIDE arranca: npm run elixide:start"
echo "3. Ejecutar tests: npm run test"

