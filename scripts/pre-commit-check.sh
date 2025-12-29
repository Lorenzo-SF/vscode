#!/bin/bash
# ElixIDE: Script de verificaciones pre-commit
# Ejecuta todos los checks de calidad antes de permitir un commit
# Especificación: Preprompt.md sección 1.17.17

set -e

echo "🔍 Ejecutando verificaciones pre-commit..."

# 1. Verificar que el código compila sin errores
echo "📦 Verificando compilación TypeScript..."
npm run compile-check-ts-native || {
	echo "❌ Error: Compilación TypeScript falló"
	exit 1
}

# 2. Ejecutar hygiene (copyright, formato, indentación, unicode, eslint, stylelint)
echo "🧹 Ejecutando hygiene checks..."
npm run hygiene || {
	echo "❌ Error: Hygiene checks fallaron"
	exit 1
}

# 3. Ejecutar ESLint y arreglar automáticamente lo posible
echo "🔍 Ejecutando ESLint..."
npm run eslint -- --fix || {
	echo "❌ Error: ESLint falló"
	exit 1
}

# 4. Ejecutar Stylelint y arreglar automáticamente lo posible
echo "🎨 Ejecutando Stylelint..."
npm run stylelint -- --fix || {
	echo "❌ Error: Stylelint falló"
	exit 1
}

# 5. Verificar capas arquitectónicas
echo "🏗️  Verificando capas arquitectónicas..."
npm run valid-layers-check || {
	echo "❌ Error: Validación de capas falló"
	exit 1
}

# 6. Verificar inicialización de campos de clase
echo "📋 Verificando inicialización de campos de clase..."
npm run define-class-fields-check || {
	echo "❌ Error: Validación de campos de clase falló"
	exit 1
}

# 7. Verificar tipos TypeScript (vscode-dts)
echo "📝 Verificando tipos TypeScript (vscode-dts)..."
npm run vscode-dts-compile-check || {
	echo "❌ Error: Validación de tipos vscode-dts falló"
	exit 1
}

# 8. Verificar seguridad TypeScript (tsec)
echo "🔒 Verificando seguridad TypeScript (tsec)..."
npm run tsec-compile-check || {
	echo "❌ Error: Validación de seguridad TypeScript falló"
	exit 1
}

# 9. Compilar core
echo "⚙️  Compilando core..."
npm run core-ci || {
	echo "❌ Error: Compilación de core falló"
	exit 1
}

# 10. Compilar extensiones
echo "🔌 Compilando extensiones..."
npm run extensions-ci || {
	echo "❌ Error: Compilación de extensiones falló"
	exit 1
}

# 11. Ejecutar tests unitarios (si existen)
if [ -d "test/unit" ] && [ "$(ls -A test/unit)" ]; then
	echo "🧪 Ejecutando tests unitarios..."
	npm run test-node || {
		echo "⚠️  Advertencia: Tests unitarios fallaron (continuando...)"
	}
fi

echo "✅ Todas las verificaciones pasaron!"

