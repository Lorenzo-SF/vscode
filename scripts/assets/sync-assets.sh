#!/bin/bash
# sync-assets.sh - Script para sincronizar assets desde Prompts/assets/ hacia ElixIDE
# Este script copia temas e iconos desde la carpeta de salvaguarda hacia el proyecto

set -e

# Colores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Rutas
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PROMPTS_ASSETS=""

# Detectar ubicación de Prompts/assets/
# Opción 1: Relativo al proyecto (si Prompts está en el mismo nivel)
if [ -d "$PROJECT_ROOT/../scripts_repo/Prompts/assets" ]; then
    PROMPTS_ASSETS="$PROJECT_ROOT/../scripts_repo/Prompts/assets"
# Opción 2: Ruta absoluta común
elif [ -d "/mnt/c/Users/loren/Desktop/proyectos/scripts_repo/Prompts/assets" ]; then
    PROMPTS_ASSETS="/mnt/c/Users/loren/Desktop/proyectos/scripts_repo/Prompts/assets"
else
    echo -e "${RED}ERROR: No se encontró Prompts/assets/${NC}"
    echo "Por favor, especifica la ruta manualmente:"
    echo "  export PROMPTS_ASSETS_PATH=/ruta/a/Prompts/assets"
    exit 1
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Sincronización de Assets ElixIDE${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Origen: $PROMPTS_ASSETS"
echo "Destino: $PROJECT_ROOT"
echo ""

# Verificar que existe Prompts/assets/
if [ ! -d "$PROMPTS_ASSETS" ]; then
    echo -e "${RED}ERROR: $PROMPTS_ASSETS no existe${NC}"
    exit 1
fi

# 1. Sincronizar temas
echo -e "${YELLOW}[1/3] Sincronizando temas...${NC}"

THEMES_SOURCE="$PROMPTS_ASSETS/themes"
THEMES_DEST="$PROJECT_ROOT/assets/themes"

mkdir -p "$THEMES_DEST"

# Copiar temas (soporta nombres alternativos)
if [ -f "$THEMES_SOURCE/elixide-dark.json" ]; then
    cp "$THEMES_SOURCE/elixide-dark.json" "$THEMES_DEST/"
    echo "  ✓ Copiado elixide-dark.json"
elif [ -f "$THEMES_SOURCE/elix-dark.json" ]; then
    cp "$THEMES_SOURCE/elix-dark.json" "$THEMES_DEST/elixide-dark.json"
    echo "  ✓ Copiado elix-dark.json → elixide-dark.json"
else
    echo -e "  ${RED}✗ No se encontró tema oscuro${NC}"
fi

if [ -f "$THEMES_SOURCE/elixide-light.json" ]; then
    cp "$THEMES_SOURCE/elixide-light.json" "$THEMES_DEST/"
    echo "  ✓ Copiado elixide-light.json"
elif [ -f "$THEMES_SOURCE/elix-light.json" ]; then
    cp "$THEMES_SOURCE/elix-light.json" "$THEMES_DEST/elixide-light.json"
    echo "  ✓ Copiado elix-light.json → elixide-light.json"
else
    echo -e "  ${RED}✗ No se encontró tema claro${NC}"
fi

# 2. Sincronizar iconos
echo -e "${YELLOW}[2/3] Sincronizando iconos...${NC}"

ICONS_SOURCE="$PROMPTS_ASSETS/icons"
ICONS_DEST="$PROJECT_ROOT/assets/icons"

mkdir -p "$ICONS_DEST"

# Copiar iconos principales
for icon in icon.png icon.svg logo.png icon.ico icon.icns code.png; do
    if [ -f "$ICONS_SOURCE/$icon" ]; then
        cp "$ICONS_SOURCE/$icon" "$ICONS_DEST/"
        echo "  ✓ Copiado $icon"
    fi
done

# Copiar iconos SVG adicionales
if [ -d "$ICONS_SOURCE" ]; then
    for svg in "$ICONS_SOURCE"/*.svg; do
        if [ -f "$svg" ]; then
            filename=$(basename "$svg")
            cp "$svg" "$ICONS_DEST/"
            echo "  ✓ Copiado $filename"
        fi
    done
fi

# 3. Verificar integridad
echo -e "${YELLOW}[3/3] Verificando integridad...${NC}"

# Verificar temas JSON válidos
for theme in "$THEMES_DEST"/*.json; do
    if [ -f "$theme" ]; then
        if jq empty "$theme" 2>/dev/null; then
            echo "  ✓ $(basename $theme) es JSON válido"
        else
            echo -e "  ${RED}✗ $(basename $theme) no es JSON válido${NC}"
        fi
    fi
done

# Verificar que temas tienen estructura correcta
for theme in "$THEMES_DEST"/elixide-*.json; do
    if [ -f "$theme" ]; then
        if jq -e '.$schema' "$theme" > /dev/null 2>&1 && \
           jq -e '.name' "$theme" > /dev/null 2>&1 && \
           jq -e '.colors' "$theme" > /dev/null 2>&1; then
            echo "  ✓ $(basename $theme) tiene estructura correcta"
        else
            echo -e "  ${RED}✗ $(basename $theme) no tiene estructura correcta${NC}"
        fi
    fi
done

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Sincronización completada${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Assets sincronizados desde: $PROMPTS_ASSETS"
echo "Assets disponibles en: $PROJECT_ROOT/assets"
echo ""

