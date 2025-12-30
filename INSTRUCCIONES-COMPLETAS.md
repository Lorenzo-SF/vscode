# 📖 Instrucciones Completas - ElixIDE

## 🚀 Setup Inicial (Primera Vez)

### 1. Instalar dependencias del sistema

```bash
cd ~/proyectos/ElixIDE
./scripts/install-build-deps.sh
```

**Nota:** Requiere `sudo`, se te pedirá la contraseña.

### 2. Setup completo del proyecto

```bash
cd ~/proyectos/ElixIDE
./scripts/setup-and-compile.sh
```

Este script:
- Instala NVM si no está instalado
- Instala Node.js 22.21.1
- Configura Yarn
- Instala dependencias del proyecto (`yarn install`)
- Compila el proyecto (`yarn compile`)

**Tiempo estimado:** 15-30 minutos

## 📝 Uso Diario

### Cargar entorno

```bash
cd ~/proyectos/ElixIDE
source scripts/init-env.sh
```

### Comandos disponibles después de cargar entorno

```bash
# Verificar versiones
node --version
yarn --version

# Instalar dependencias
yarn install

# Compilar proyecto
yarn compile

# Iniciar ElixIDE
./scripts/code.sh
```

### O usar el script de inicio (recomendado)

```bash
cd ~/proyectos/ElixIDE
./scripts/start.sh
```

Este script:
- Carga el entorno automáticamente
- Verifica/instala dependencias si es necesario
- Compila si es necesario
- Inicia ElixIDE

## 🔧 Solución de Problemas

### "comando not found" para node o yarn

**Solución:**
```bash
source scripts/init-env.sh
```

### Errores de compilación de módulos nativos

**Solución:**
```bash
./scripts/install-build-deps.sh
source scripts/init-env.sh
yarn install
```

### El proyecto no compila

**Solución:**
```bash
source scripts/init-env.sh
yarn compile
```

### "Couldn't find a script named 'start'"

**Solución:** VSCode no tiene script `start`. Usa:
```bash
./scripts/code.sh
```

O:
```bash
./scripts/start.sh
```

## 📋 Scripts Disponibles

| Script | Descripción |
|--------|-------------|
| `./scripts/install-build-deps.sh` | Instala dependencias del sistema |
| `./scripts/setup-and-compile.sh` | Setup completo y compilación |
| `./scripts/init-env.sh` | Carga el entorno (source este archivo) |
| `./scripts/start.sh` | Inicia ElixIDE (todo en uno) |
| `./scripts/code.sh` | Ejecuta ElixIDE directamente |
| `./scripts/run-ci-checks.sh` | Ejecuta checks de CI/CD |

## 📚 Documentación Adicional

- `README-USO.md` - Guía de uso detallada
- `SOLUCION-NODE-YARN.md` - Solución para node/yarn
- `SOLUCION-COMPILACION.md` - Solución para errores de compilación

## ✅ Checklist de Setup

- [ ] Dependencias del sistema instaladas (`./scripts/install-build-deps.sh`)
- [ ] NVM instalado (automático con `setup-and-compile.sh`)
- [ ] Node.js 22.21.1 instalado (automático con `setup-and-compile.sh`)
- [ ] Yarn configurado (automático con `setup-and-compile.sh`)
- [ ] Dependencias del proyecto instaladas (`yarn install`)
- [ ] Proyecto compilado (`yarn compile`)
- [ ] ElixIDE se inicia correctamente (`./scripts/start.sh`)

## 🎯 Flujo de Trabajo Recomendado

```bash
# 1. Cargar entorno
cd ~/proyectos/ElixIDE
source scripts/init-env.sh

# 2. Hacer cambios en el código

# 3. Compilar
yarn compile

# 4. Probar
./scripts/code.sh
```

O simplemente:

```bash
./scripts/start.sh  # Hace todo automáticamente
```

