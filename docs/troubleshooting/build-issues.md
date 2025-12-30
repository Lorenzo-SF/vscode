# Problemas de Build

## Problemas Comunes de Build

### Dependencias faltantes
**Síntoma**: Error "Module not found" o "Command not found"

**Solución**:
```bash
# Limpiar e instalar dependencias
rm -rf node_modules/
yarn cache clean
yarn install
```

### Errores de compilación nativa
**Síntoma**: Errores al compilar módulos nativos (node-gyp)

**Solución**:
```bash
# Verificar build essentials
sudo apt-get install build-essential python3-dev pkg-config

# Verificar Python 3.9.0
python --version

# Reconstruir módulos nativos
npm rebuild
```

### Errores de TypeScript
**Síntoma**: Errores de compilación TypeScript

**Solución**:
```bash
# Verificar tipos
npm run compile-check-ts-native

# Limpiar y recompilar
rm -rf out/
npm run compile
```

### Hygiene checks fallan
**Síntoma**: `npm run hygiene` reporta errores

**Solución**:
```bash
# Verificar copyright headers
# Verificar formato de código
# Verificar indentación (debe usar tabs)
# Ejecutar formatters
npm run eslint -- --fix
npm run stylelint -- --fix
```

## Problemas Específicos por Plataforma

### macOS
- **Xcode Command Line Tools**: `xcode-select --install`
- **create-dmg**: `brew install create-dmg` (opcional)

### Linux
- **fakeroot/dpkg**: `sudo apt-get install fakeroot dpkg-dev` (para .deb)
- **rpm-build**: `sudo yum install rpm-build` (para .rpm)

### Windows/WSL2
- **InnoSetup**: Instalar en Windows (no WSL)
- **Node.js de Windows**: Asegurarse de usar Node.js de WSL, no de Windows

## Problemas de Parches

### Parche no aplica
**Síntoma**: `git apply` falla

**Solución**:
1. Verificar que el submódulo está en el commit correcto
2. Verificar que el parche está actualizado
3. Aplicar manualmente si es necesario
4. Regenerar parche si es necesario

### Conflictos con upstream
**Síntoma**: Parche tiene conflictos con nueva versión de VSCode

**Solución**:
1. Actualizar submódulo a nueva versión
2. Aplicar parche manualmente
3. Resolver conflictos
4. Regenerar parche desde cambios resueltos

## Problemas de Assets

### Assets no sincronizan
**Síntoma**: Temas o iconos no aparecen

**Solución**:
```bash
# Ejecutar script de sincronización
./scripts/assets/sync-assets.sh

# Verificar assets
./scripts/assets/verify-assets.sh
```

### Assets corruptos
**Síntoma**: Temas o iconos no se cargan correctamente

**Solución**:
1. Verificar integridad en `Prompts/assets/`
2. Restaurar desde `Prompts/assets/`
3. Re-sincronizar assets

## Referencias

- [Problemas Comunes](./common-issues.md)
- [Sistema de Construcción](../architecture/build-system.md)

