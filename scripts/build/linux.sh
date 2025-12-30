#!/bin/bash
# linux.sh - Script de build para Linux
# Especificación: v0.md sección 1.4, Tarea 3

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
COMMON_SCRIPT="$SCRIPT_DIR/common.sh"

# Cargar funciones comunes
source "$COMMON_SCRIPT"

log_info "=========================================="
log_info "Build de ElixIDE para Linux"
log_info "=========================================="
echo ""

# Verificar que estamos en Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
	log_error "Este script debe ejecutarse en Linux"
	exit 1
fi

# Verificar comandos requeridos
check_command node
check_command npm
check_command yarn

# Verificar versiones
check_node_version
check_python_version

# Cambiar al directorio del proyecto
cd "$PROJECT_ROOT"

# Aplicar parches
apply_patches "$PROJECT_ROOT/patches" "$PROJECT_ROOT"

# Sincronizar assets
sync_assets "$PROJECT_ROOT"

# Instalar dependencias
log_info "Instalando dependencias..."
npm install || {
	log_error "Error al instalar dependencias"
	exit 1
}

# Compilar
log_info "Compilando proyecto..."
npm run compile || {
	log_error "Error al compilar"
	exit 1
}

# Verificar compilación
check_compiled "$PROJECT_ROOT/out"

# Build para Linux
ARCH="${1:-x64}"  # Por defecto x64

log_info "Construyendo para Linux $ARCH..."

npm run gulp vscode-linux-$ARCH-min || {
	log_error "Error al construir para Linux $ARCH"
	exit 1
}

log_info "=========================================="
log_info "✓ Build completado exitosamente"
log_info "=========================================="
log_info "Bundle generado en: ../VSCode-linux-$ARCH/"

# Opcional: Generar paquetes
if [ "$2" = "package" ]; then
	log_info "Generando paquetes..."
	
	# .deb
	if command -v dpkg-deb >/dev/null 2>&1; then
		log_info "Generando paquete .deb..."
		npm run gulp vscode-linux-$ARCH-prepare-deb
		npm run gulp vscode-linux-$ARCH-build-deb
	fi
	
	# .rpm
	if command -v rpmbuild >/dev/null 2>&1; then
		log_info "Generando paquete .rpm..."
		npm run gulp vscode-linux-$ARCH-prepare-rpm
		npm run gulp vscode-linux-$ARCH-build-rpm
	fi
fi

