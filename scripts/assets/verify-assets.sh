#!/bin/bash
# verify-assets.sh - Script para verificar integridad de assets en Prompts/assets/
# Especificación: v0.md sección 1.7

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
if [ -d "$PROJECT_ROOT/../scripts_repo/Prompts/assets" ]; then
    PROMPTS_ASSETS="$PROJECT_ROOT/../scripts_repo/Prompts/assets"
elif [ -d "/mnt/c/Users/loren/Desktop/proyectos/scripts_repo/Prompts/assets" ]; then
    PROMPTS_ASSETS="/mnt/c/Users/loren/Desktop/proyectos/scripts_repo/Prompts/assets"
elif [ -n "$PROMPTS_ASSETS_PATH" ]; then
    PROMPTS_ASSETS="$PROMPTS_ASSETS_PATH"
else
    echo -e "${RED}ERROR: No se encontró Prompts/assets/${NC}"
    exit 1
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}Verificación de Assets ElixIDE${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Verificando: $PROMPTS_ASSETS"
echo ""

ERRORS=0

# Verificar temas
echo -e "${YELLOW}[1/3] Verificando temas...${NC}"
THEMES_DIR="$PROMPTS_ASSETS/themes"

if [ ! -d "$THEMES_DIR" ]; then
    echo -e "  ${RED}✗ Directorio themes/ no existe${NC}"
    ERRORS=$((ERRORS + 1))
else
    # Verificar tema oscuro
    if [ -f "$THEMES_DIR/elixide-dark.json" ] || [ -f "$THEMES_DIR/elix-dark.json" ]; then
        THEME_DARK="$THEMES_DIR/elixide-dark.json"
        [ -f "$THEMES_DIR/elix-dark.json" ] && THEME_DARK="$THEMES_DIR/elix-dark.json"
        
        if command -v jq >/dev/null 2>&1; then
            if jq empty "$THEME_DARK" 2>/dev/null; then
                echo "  ✓ Tema oscuro existe y es JSON válido"
                
                # Verificar estructura
                if jq -e '.$schema' "$THEME_DARK" > /dev/null 2>&1 && \
                   jq -e '.name' "$THEME_DARK" > /dev/null 2>&1 && \
                   jq -e '.colors' "$THEME_DARK" > /dev/null 2>&1 && \
                   jq -e '.tokenColors' "$THEME_DARK" > /dev/null 2>&1; then
                    echo "  ✓ Tema oscuro tiene estructura correcta"
                else
                    echo -e "  ${RED}✗ Tema oscuro no tiene estructura correcta${NC}"
                    ERRORS=$((ERRORS + 1))
                fi
            else
                echo -e "  ${RED}✗ Tema oscuro no es JSON válido${NC}"
                ERRORS=$((ERRORS + 1))
            fi
        else
            echo "  ⚠ jq no está instalado, saltando validación JSON"
        fi
    else
        echo -e "  ${RED}✗ Tema oscuro no encontrado${NC}"
        ERRORS=$((ERRORS + 1))
    fi
    
    # Verificar tema claro
    if [ -f "$THEMES_DIR/elixide-light.json" ] || [ -f "$THEMES_DIR/elix-light.json" ]; then
        THEME_LIGHT="$THEMES_DIR/elixide-light.json"
        [ -f "$THEMES_DIR/elix-light.json" ] && THEME_LIGHT="$THEMES_DIR/elix-light.json"
        
        if command -v jq >/dev/null 2>&1; then
            if jq empty "$THEME_LIGHT" 2>/dev/null; then
                echo "  ✓ Tema claro existe y es JSON válido"
                
                # Verificar estructura
                if jq -e '.$schema' "$THEME_LIGHT" > /dev/null 2>&1 && \
                   jq -e '.name' "$THEME_LIGHT" > /dev/null 2>&1 && \
                   jq -e '.colors' "$THEME_LIGHT" > /dev/null 2>&1 && \
                   jq -e '.tokenColors' "$THEME_LIGHT" > /dev/null 2>&1; then
                    echo "  ✓ Tema claro tiene estructura correcta"
                else
                    echo -e "  ${RED}✗ Tema claro no tiene estructura correcta${NC}"
                    ERRORS=$((ERRORS + 1))
                fi
            else
                echo -e "  ${RED}✗ Tema claro no es JSON válido${NC}"
                ERRORS=$((ERRORS + 1))
            fi
        else
            echo "  ⚠ jq no está instalado, saltando validación JSON"
        fi
    else
        echo -e "  ${RED}✗ Tema claro no encontrado${NC}"
        ERRORS=$((ERRORS + 1))
    fi
fi

# Verificar iconos
echo -e "${YELLOW}[2/3] Verificando iconos...${NC}"
ICONS_DIR="$PROMPTS_ASSETS/icons"

if [ ! -d "$ICONS_DIR" ]; then
    echo -e "  ${RED}✗ Directorio icons/ no existe${NC}"
    ERRORS=$((ERRORS + 1))
else
    # Verificar iconos requeridos
    REQUIRED_ICONS=("icon.png" "logo.png" "icon.ico" "icon.icns" "code.png")
    for icon in "${REQUIRED_ICONS[@]}"; do
        if [ -f "$ICONS_DIR/$icon" ]; then
            # Verificar tamaño si es posible
            if command -v identify >/dev/null 2>&1 || command -v file >/dev/null 2>&1; then
                echo "  ✓ $icon existe"
            else
                echo "  ✓ $icon existe"
            fi
        else
            echo -e "  ${RED}✗ $icon no encontrado${NC}"
            ERRORS=$((ERRORS + 1))
        fi
    done
    
    # Verificar iconos SVG opcionales
    SVG_COUNT=$(find "$ICONS_DIR" -name "*.svg" -type f | wc -l)
    if [ "$SVG_COUNT" -gt 0 ]; then
        echo "  ✓ $SVG_COUNT icono(s) SVG encontrado(s)"
    fi
fi

# Verificar documentación
echo -e "${YELLOW}[3/3] Verificando documentación...${NC}"
if [ -f "$PROMPTS_ASSETS/README.md" ]; then
    echo "  ✓ README.md existe"
else
    echo -e "  ${YELLOW}⚠ README.md no encontrado (opcional)${NC}"
fi

if [ -f "$THEMES_DIR/README.md" ]; then
    echo "  ✓ themes/README.md existe"
else
    echo -e "  ${YELLOW}⚠ themes/README.md no encontrado (opcional)${NC}"
fi

if [ -f "$ICONS_DIR/README.md" ]; then
    echo "  ✓ icons/README.md existe"
else
    echo -e "  ${YELLOW}⚠ icons/README.md no encontrado (opcional)${NC}"
fi

echo ""
echo -e "${GREEN}========================================${NC}"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ Verificación completada sin errores${NC}"
    echo -e "${GREEN}========================================${NC}"
    exit 0
else
    echo -e "${RED}✗ Verificación completada con $ERRORS error(es)${NC}"
    echo -e "${GREEN}========================================${NC}"
    exit 1
fi

