#!/bin/bash
# common.sh - Funciones comunes para scripts de build
# Especificación: v0.md sección 1.4, Tarea 3

set -e

# Colores para output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Función para imprimir mensajes
log_info() {
	echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
	echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
	echo -e "${RED}[ERROR]${NC} $1"
}

# Función para verificar que un comando existe
check_command() {
	if ! command -v "$1" >/dev/null 2>&1; then
		log_error "Comando '$1' no encontrado. Por favor, instálalo primero."
		exit 1
	fi
}

# Función para verificar versión de Node.js
check_node_version() {
	local required_version="22.21.1"
	local current_version=$(node --version | sed 's/v//')
	
	if [ "$current_version" != "$required_version" ]; then
		log_warn "Versión de Node.js: $current_version (requerida: $required_version)"
		log_warn "Usando nvm para cambiar a la versión correcta..."
		
		if command -v nvm >/dev/null 2>&1; then
			source ~/.nvm/nvm.sh
			nvm use "$required_version" || {
				log_error "No se pudo cambiar a Node.js $required_version"
				exit 1
			}
		else
			log_error "nvm no está disponible. Por favor, instala Node.js $required_version"
			exit 1
		fi
	fi
	
	log_info "Node.js versión correcta: $(node --version)"
}

# Función para verificar versión de Python
check_python_version() {
	local required_version="3.9.0"
	local current_version=$(python --version 2>&1 | awk '{print $2}')
	
	if [ "$current_version" != "$required_version" ]; then
		log_warn "Versión de Python: $current_version (requerida: $required_version)"
		log_warn "Usando pyenv para cambiar a la versión correcta..."
		
		if command -v pyenv >/dev/null 2>&1; then
			eval "$(pyenv init -)"
			pyenv global "$required_version" || {
				log_error "No se pudo cambiar a Python $required_version"
				exit 1
			}
		else
			log_error "pyenv no está disponible. Por favor, instala Python $required_version"
			exit 1
		fi
	fi
	
	log_info "Python versión correcta: $(python --version)"
}

# Función para aplicar parches
apply_patches() {
	local patches_dir="$1"
	local target_dir="$2"
	
	log_info "Aplicando parches desde $patches_dir..."
	
	if [ ! -d "$patches_dir" ]; then
		log_warn "Directorio de parches no existe: $patches_dir"
		return 0
	fi
	
	cd "$target_dir"
	
	for patch in "$patches_dir"/*.patch; do
		if [ -f "$patch" ]; then
			log_info "Aplicando parche: $(basename "$patch")"
			if git apply --check "$patch" 2>/dev/null; then
				git apply "$patch" || {
					log_error "Error al aplicar parche: $patch"
					exit 1
				}
				log_info "  ✓ Parche aplicado correctamente"
			else
				log_warn "  ⚠ Parche ya aplicado o tiene conflictos: $patch"
			fi
		fi
	done
	
	log_info "Parches aplicados correctamente"
}

# Función para sincronizar assets
sync_assets() {
	local project_root="$1"
	
	log_info "Sincronizando assets..."
	
	if [ -f "$project_root/scripts/assets/sync-assets.sh" ]; then
		bash "$project_root/scripts/assets/sync-assets.sh" || {
			log_error "Error al sincronizar assets"
			exit 1
		}
		log_info "Assets sincronizados correctamente"
	else
		log_warn "Script de sincronización no encontrado"
	fi
}

# Función para verificar que el proyecto está compilado
check_compiled() {
	local out_dir="$1"
	
	if [ ! -d "$out_dir" ] || [ -z "$(ls -A "$out_dir" 2>/dev/null)" ]; then
		log_error "El proyecto no está compilado. Ejecuta 'npm run compile' primero."
		exit 1
	fi
	
	log_info "Proyecto compilado correctamente"
}

