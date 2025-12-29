#!/bin/bash
# recover-assets.sh - Restaura todos los assets desde Prompts/assets/
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
PROMPTS_ASSETS=""

# Detectar ubicación de Prompts/assets/
if [ -d "$PROJECT_ROOT/../scripts_repo/Prompts/assets" ]; then
    PROMPTS_ASSETS="$PROJECT_ROOT/../scripts_repo/Prompts/assets"
elif [ -d "/mnt/c/Users/loren/Desktop/proyectos/scripts_repo/Prompts/assets" ]; then
    PROMPTS_ASSETS="/mnt/c/Users/loren/Desktop/proyectos/scripts_repo/Prompts/assets"
elif [ -n "$PROMPTS_ASSETS_PATH" ]; then
    PROMPTS_ASSETS="$PROMPTS_ASSETS_PATH"
else
    echo -e "${RED}ERROR: No se encontró Prompts/assets/${NC}"
    echo "Por favor, especifica la ruta:"
    echo "  export PROMPTS_ASSETS_PATH=/ruta/a/Prompts/assets"
    exit 1
fi

cd "$PROJECT_ROOT"

echo -e "${CYAN}========================================${NC}"
echo -e "${CYAN}Recuperación de Assets ElixIDE${NC}"
echo -e "${CYAN}========================================${NC}"
echo ""
echo "Origen: $PROMPTS_ASSETS"
echo "Destino: $PROJECT_ROOT"
echo ""

# Verificar que existe Prompts/assets/
if [ ! -d "$PROMPTS_ASSETS" ]; then
    echo -e "${RED}ERROR: $PROMPTS_ASSETS no existe${NC}"
    exit 1
fi

# 1. Restaurar temas
echo -e "${YELLOW}[1/3] Restaurando temas...${NC}"
THEMES_SOURCE="$PROMPTS_ASSETS/themes"
THEMES_DEST="$PROJECT_ROOT/assets/themes"
THEMES_SUBMODULE="$PROJECT_ROOT/extensions/theme-defaults/themes"

mkdir -p "$THEMES_DEST"
mkdir -p "$THEMES_SUBMODULE"

if [ -d "$THEMES_SOURCE" ]; then
    # Copiar temas
    cp -f "$THEMES_SOURCE"/elixide-*.json "$THEMES_DEST/" 2>/dev/null || true
    cp -f "$THEMES_SOURCE"/elix-*.json "$THEMES_DEST/" 2>/dev/null || true
    
    # Copiar al submódulo
    cp -f "$THEMES_SOURCE"/elixide-*.json "$THEMES_SUBMODULE/" 2>/dev/null || true
    cp -f "$THEMES_SOURCE"/elix-*.json "$THEMES_SUBMODULE/" 2>/dev/null || true
    
    echo "  ✓ Temas restaurados"
else
    echo -e "  ${RED}✗ Directorio themes/ no encontrado${NC}"
fi

# 2. Restaurar iconos
echo -e "${YELLOW}[2/3] Restaurando iconos...${NC}"
ICONS_SOURCE="$PROMPTS_ASSETS/icons"
ICONS_DEST="$PROJECT_ROOT/assets/icons"

mkdir -p "$ICONS_DEST"

if [ -d "$ICONS_SOURCE" ]; then
    # Copiar todos los iconos
    cp -f "$ICONS_SOURCE"/* "$ICONS_DEST/" 2>/dev/null || true
    
    echo "  ✓ Iconos restaurados"
else
    echo -e "  ${RED}✗ Directorio icons/ no encontrado${NC}"
fi

# 3. Verificar integridad
echo -e "${YELLOW}[3/3] Verificando integridad...${NC}"
if [ -f "scripts/assets/verify-assets.sh" ]; then
    bash scripts/assets/verify-assets.sh
else
    echo "  ⊘ Script de verificación no encontrado"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Recuperación de assets completada${NC}"
echo -e "${GREEN}========================================${NC}"

