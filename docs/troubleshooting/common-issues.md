# Problemas Comunes y Soluciones

## Problemas de Instalación

### Node.js version mismatch
**Síntoma**: Error "Node.js version mismatch" o versión incorrecta

**Solución**:
```bash
# Verificar que nvm está cargado
source ~/.nvm/nvm.sh

# Verificar versión instalada
nvm list

# Instalar versión correcta
nvm install 22.21.1 && nvm use 22.21.1
```

### Python version mismatch
**Síntoma**: Error "Python version mismatch" o versión incorrecta

**Solución**:
```bash
# Verificar que pyenv está configurado
eval "$(pyenv init -)"

# Instalar versión correcta
pyenv install 3.9.0 && pyenv global 3.9.0
```

### Yarn not found
**Síntoma**: Comando `yarn` no encontrado

**Solución**:
```bash
# Activar Corepack
corepack enable

# O instalar yarn manualmente
npm install -g yarn
```

## Problemas de Compilación

### Module build failed
**Síntoma**: Errores de compilación de módulos nativos

**Solución**:
```bash
# Verificar que build-essential está instalado
sudo apt-get install build-essential

# Verificar que Python 3.9.0 está disponible
python --version

# Limpiar y reinstalar
yarn cache clean
yarn install
```

### TypeScript compilation errors
**Síntoma**: Errores de compilación TypeScript

**Solución**:
```bash
# Verificar tipos
npm run compile-check-ts-native

# Limpiar y recompilar
rm -rf out/
npm run compile
```

## Problemas de Runtime

### ElixIDE no inicia
**Síntoma**: ElixIDE no se abre o se cierra inmediatamente

**Solución**:
1. Verificar logs en Developer Tools (Help > Toggle Developer Tools)
2. Verificar que `npm run compile` completó sin errores
3. Verificar que Node.js es la versión correcta
4. Verificar permisos de archivos

### Módulos no cargan
**Síntoma**: Módulos no aparecen o no funcionan

**Solución**:
1. Verificar que `src/bootstrap.ts` está ejecutándose
2. Verificar logs en Output Channel
3. Verificar que `package.json` del módulo es válido
4. Verificar que el módulo está en `modules/`

### Action bar no visible
**Síntoma**: Action bar no aparece en titlebar

**Solución**:
1. Verificar que el parche `vscode-actionbar-top.patch` está aplicado
2. Verificar que CSS está compilado correctamente
3. Verificar Developer Tools para errores de CSS
4. Limpiar cache y recompilar

## Problemas de Build

### Build falla en macOS
**Síntoma**: Error al generar .dmg

**Solución**:
```bash
# Verificar Xcode Command Line Tools
xcode-select --install

# Instalar create-dmg (opcional)
brew install create-dmg
```

### Build falla en Linux
**Síntoma**: Error al generar .deb o .rpm

**Solución**:
```bash
# Instalar herramientas requeridas
sudo apt-get install fakeroot dpkg-dev  # Para .deb
sudo yum install rpm-build              # Para .rpm
```

### Build falla en Windows
**Síntoma**: Error al generar .exe

**Solución**:
1. Verificar que InnoSetup está instalado en Windows (no WSL)
2. Verificar que el build se ejecuta desde WSL2
3. Verificar permisos de archivos

## Problemas de Git

### Error al aplicar parches
**Síntoma**: `git apply` falla con conflictos

**Solución**:
1. Verificar que el submódulo está en el commit correcto
2. Verificar que los parches están actualizados
3. Resolver conflictos manualmente si es necesario
4. Regenerar parches si es necesario

## Referencias

- [Problemas de Build](./build-issues.md)
- [Preprompt.md](../../Preprompt.md) sección 11

