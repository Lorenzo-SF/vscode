#!/bin/bash
# recover-submodule.sh - Restaura el submódulo desde un estado corrupto
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
echo -e "${CYAN}Recuperación de Submódulo VSCode${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""

# Verificar que estamos en un repositorio Git
if [ ! -d ".git" ]; then
    echo -e "${RED}ERROR: No se encontró repositorio Git${NC}"
    exit 1
fi

# Verificar que existe .gitmodules
if [ ! -f ".gitmodules" ]; then
    echo -e "${RED}ERROR: No se encontró .gitmodules${NC}"
    exit 1
fi

# Detectar submódulo
SUBMODULE_PATH=""
if [ -d "vscode-original" ]; then
    SUBMODULE_PATH="vscode-original"
elif [ -d "src/vscode-original" ]; then
    SUBMODULE_PATH="src/vscode-original"
else
    echo -e "${RED}ERROR: No se encontró directorio del submódulo${NC}"
    exit 1
fi

echo -e "${YELLOW}Submódulo detectado: $SUBMODULE_PATH${NC}"
echo ""

# Opciones de recuperación
echo "Opciones de recuperación:"
echo "1. Re-inicializar submódulo (más seguro)"
echo "2. Forzar actualización del submódulo"
echo "3. Eliminar y clonar de nuevo"
echo ""
read -p "Seleccione opción (1-3): " option

case $option in
    1)
        echo -e "${YELLOW}[Opción 1] Re-inicializando submódulo...${NC}"
        git submodule deinit -f "$SUBMODULE_PATH" 2>/dev/null || true
        git submodule init "$SUBMODULE_PATH"
        git submodule update "$SUBMODULE_PATH"
        echo -e "${GREEN}✓ Submódulo re-inicializado${NC}"
        ;;
    2)
        echo -e "${YELLOW}[Opción 2] Forzando actualización...${NC}"
        git submodule update --init --force "$SUBMODULE_PATH"
        echo -e "${GREEN}✓ Submódulo actualizado${NC}"
        ;;
    3)
        echo -e "${YELLOW}[Opción 3] Eliminando y clonando de nuevo...${NC}"
        read -p "¿Está seguro? Esto eliminará todos los cambios locales (y/n): " confirm
        if [ "$confirm" != "y" ]; then
            echo "Operación cancelada"
            exit 0
        fi
        
        # Backup de parches si existen
        if [ -d "patches" ]; then
            echo "Haciendo backup de parches..."
            cp -r patches patches.backup.$(date +%Y%m%d-%H%M%S)
        fi
        
        # Eliminar submódulo
        rm -rf "$SUBMODULE_PATH"
        git submodule deinit -f "$SUBMODULE_PATH" 2>/dev/null || true
        
        # Re-clonar
        git submodule init "$SUBMODULE_PATH"
        git submodule update "$SUBMODULE_PATH"
        
        echo -e "${GREEN}✓ Submódulo re-clonado${NC}"
        echo -e "${YELLOW}Nota: Debes aplicar los parches nuevamente${NC}"
        ;;
    *)
        echo -e "${RED}Opción inválida${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Recuperación completada${NC}"
echo -e "${GREEN}========================================${NC}"

