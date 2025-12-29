# Internacionalización (i18n) en ElixIDE

## Preparación para i18n

Aunque v0 no incluye traducciones completas, la infraestructura está preparada para soportar múltiples idiomas.

## Estructura de Archivos de Localización

### Archivos de Localización

Los archivos de localización siguen el formato estándar de VSCode:

- `package.nls.json` - Inglés (idioma por defecto)
- `package.nls.es.json` - Español
- `package.nls.fr.json` - Francés
- `package.nls.de.json` - Alemán
- etc.

### Ubicación

Los archivos de localización están en cada extensión/módulo:
- `extensions/theme-defaults/package.nls.json` - Localización de temas
- `modules/core/package.nls.json` - Localización del módulo core
- etc.

## Uso de Strings Localizados

### En package.json

Usar referencias a strings localizados con el prefijo `%`:

```json
{
  "displayName": "%displayName%",
  "description": "%description%",
  "contributes": {
    "themes": [
      {
        "label": "%elixideDarkColorThemeLabel%"
      }
    ]
  }
}
```

### En Código TypeScript

Usar la función `localize` de VSCode:

```typescript
import { localize } from '../../../../nls.js';

const message = localize('key', 'Default message');
```

### Definir Strings en package.nls.json

```json
{
  "displayName": "ElixIDE Core",
  "description": "Core functionality for ElixIDE",
  "elixideDarkColorThemeLabel": "ElixIDE Dark",
  "elixideLightColorThemeLabel": "ElixIDE Light"
}
```

## API para Obtener Strings Localizados

VSCode proporciona automáticamente la localización basada en:
1. Configuración del usuario (`locale`)
2. Idioma del sistema operativo
3. Fallback a inglés si no hay traducción

### Ejemplo de Uso

```typescript
// En package.json
{
  "contributes": {
    "commands": [
      {
        "command": "elixide.showVersion",
        "title": "%showVersionCommandTitle%"
      }
    ]
  }
}

// En package.nls.json
{
  "showVersionCommandTitle": "Show ElixIDE Version"
}

// En package.nls.es.json
{
  "showVersionCommandTitle": "Mostrar Versión de ElixIDE"
}
```

## Proceso de Traducción

### 1. Identificar Strings a Traducir

Buscar todas las cadenas hardcodeadas en el código:

```bash
# Buscar strings hardcodeadas (ejemplo)
grep -r "ElixIDE" src/ --include="*.ts" | grep -v "localize"
```

### 2. Mover a package.nls.json

Reemplazar strings hardcodeadas con referencias:

**Antes:**
```typescript
vscode.window.showInformationMessage('ElixIDE started successfully');
```

**Después:**
```typescript
const message = localize('startup.success', 'ElixIDE started successfully');
vscode.window.showInformationMessage(message);
```

Y en `package.nls.json`:
```json
{
  "startup.success": "ElixIDE started successfully"
}
```

### 3. Crear Archivos de Traducción

Para cada idioma, crear `package.nls.{locale}.json`:

```json
// package.nls.es.json
{
  "startup.success": "ElixIDE iniciado correctamente"
}
```

### 4. Verificar Traducciones

- Probar con diferentes configuraciones de `locale`
- Verificar que todas las cadenas están traducidas
- Verificar que no hay strings faltantes

## Formatos y Localización

### Fechas y Números

Usar APIs de localización del sistema:

```typescript
// Fechas
const date = new Date();
const formatted = date.toLocaleDateString(); // Respeta configuración del sistema

// Números
const number = 1234.56;
const formatted = number.toLocaleString(); // Respeta configuración del sistema
```

### Zonas Horarias

Respetar configuración del usuario:

```typescript
const now = new Date();
const timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
```

### Encoding

Todos los archivos de texto usan UTF-8:

- Archivos de código: UTF-8
- Archivos de localización: UTF-8
- Archivos de configuración: UTF-8

## Estado Actual

### Implementado

- ✅ Estructura de archivos de localización preparada
- ✅ Uso de `package.nls.json` en temas
- ✅ API de localización de VSCode disponible
- ✅ Separación de texto de código (en temas)

### Pendiente (para versiones futuras)

- ⏳ Traducciones completas a múltiples idiomas
- ⏳ Herramientas de extracción de strings
- ⏳ Proceso automatizado de traducción
- ⏳ Verificación de traducciones en CI/CD

## Mejores Prácticas

### DO

- ✅ Usar `localize()` para todas las cadenas visibles al usuario
- ✅ Proporcionar mensajes por defecto claros en inglés
- ✅ Mantener strings cortos y claros
- ✅ Usar placeholders para valores dinámicos: `%1` en lugar de concatenación

### DON'T

- ❌ Hardcodear strings en el código
- ❌ Concatenar strings traducidos
- ❌ Asumir formato de fechas/números
- ❌ Usar abreviaciones sin contexto

### Ejemplo Correcto

```typescript
const message = localize(
  'file.saved',
  'File {0} saved successfully',
  fileName
);
```

### Ejemplo Incorrecto

```typescript
const message = 'File ' + fileName + ' saved successfully'; // ❌
```

## Referencias

- [VSCode Internationalization](https://code.visualstudio.com/api/references/extension-manifest#localization-contribution-point)
- [VSCode NLS API](https://github.com/microsoft/vscode-nls)
- [ICU Message Format](http://userguide.icu-project.org/formatparse/messages)

