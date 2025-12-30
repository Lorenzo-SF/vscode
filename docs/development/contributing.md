# Guía de Contribución a ElixIDE

## Workflow de Git

ElixIDE utiliza Git Flow con ramas `main` y `develop`. Ver `Preprompt.md` sección 14 para detalles completos.

### Proceso Básico

1. **Crear Feature Branch**
   ```bash
   ./scripts/git/create-feature.sh v{N} "descripcion"
   ```

2. **Desarrollo**
   - Implementar cambios
   - Hacer commits frecuentes con mensajes descriptivos
   - Seguir convenciones de commits (ver abajo)

3. **Validación**
   - Ejecutar todos los checks de calidad
   - Verificar que compila sin errores
   - Ejecutar tests

4. **Merge a Develop**
   ```bash
   ./scripts/git/merge-feature.sh v{N} "descripcion"
   ```

## Convenciones de Commits

Formato: `<tipo>(<ámbito>): <descripción>`

### Tipos
- `feat`: Nueva funcionalidad
- `fix`: Corrección de bug
- `docs`: Documentación
- `style`: Formato (sin cambios de código)
- `refactor`: Refactorización
- `test`: Tests
- `chore`: Tareas de mantenimiento
- `perf`: Mejoras de performance

### Ejemplos
```
feat(v0): Add action bar to titlebar
fix(v0): Correct CSS for activity bar
docs(v0): Update setup documentation
refactor(v0): Improve module loading system
```

## Estándares de Código

### TypeScript
- Strict mode habilitado
- No usar `any` (usar `unknown` si es necesario)
- Tipar todas las funciones y variables
- Usar interfaces para objetos complejos

### Formato
- Usar Prettier con configuración del proyecto
- Líneas máximo 100 caracteres
- 2 espacios para indentación (tabs en algunos archivos)

### Testing
- Cobertura mínima: 70% para código crítico
- 100% de cobertura para funciones de seguridad

## Pre-Commit Checks

Antes de hacer commit, ejecutar:

```bash
npm run compile-check-ts-native
npm run hygiene
npm run eslint -- --fix
npm run stylelint -- --fix
npm run valid-layers-check
npm run define-class-fields-check
npm run vscode-dts-compile-check
npm run tsec-compile-check
npm run core-ci
npm run extensions-ci
```

Ver `Preprompt.md` sección 1.17 para checklist completo.

## Pull Requests

1. Crear PR desde feature branch a `develop`
2. Incluir descripción completa del cambio
3. Incluir screenshots si aplica
4. Verificar que CI/CD pasa todos los checks
5. Esperar aprobación de al menos 1 reviewer

## Referencias

- [Preprompt.md](../../Preprompt.md) - Configuración completa del entorno
- [Workflow de Git](../../Prompts/WORKFLOW_GIT.md) - Detalles del workflow

