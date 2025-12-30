#!/bin/bash
# ElixIDE: Script para crear release
# Uso: ./scripts/git/create-release.sh v{N}.{M}.{P} "descripcion"
# Ejemplo: ./scripts/git/create-release.sh v0.1.0 "Base del proyecto y entorno de construcción"
# Especificación: Preprompt.md sección 14.6

set -e

VERSION=$1
DESC=$2

if [ -z "$VERSION" ] || [ -z "$DESC" ]; then
	echo "Error: Uso: $0 v{N}.{M}.{P} \"descripcion\""
	echo "Ejemplo: $0 v0.1.0 \"Base del proyecto y entorno de construcción\""
	exit 1
fi

echo "Creando release: $VERSION"

# Asegurarse de estar en develop y actualizado
git checkout develop
git pull origin develop

# Crear release branch
git checkout -b "release/$VERSION"

# Preparar release (actualizar versiones, changelog, etc.)
# Nota: Esto es un placeholder - en implementación real se actualizarían versiones
echo "Release branch release/$VERSION creada."
echo "Por favor, actualiza versiones y changelog antes de continuar."
echo "Luego ejecuta: git commit -m \"chore: Prepare release $VERSION\""

# Mergear a main
git checkout main
git pull origin main
git merge --no-ff "release/$VERSION"

# Crear tag de versión
git tag -a "$VERSION" -m "Release $VERSION: $DESC"

# Push de main y tags
git push origin main
git push origin --tags

# Volver a develop y mergear release branch
git checkout develop
git merge "release/$VERSION"
git push origin develop

echo "Release $VERSION created and tagged."

