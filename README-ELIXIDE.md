# ElixIDE

**ElixIDE** es un IDE profesional de nivel enterprise especializado para el ecosistema Elixir/OTP/Phoenix. Es un fork completo y especializado de VSCode que proporciona herramientas completas para desarrollo en Elixir, desde el nivel más básico hasta el más avanzado.

## 🎯 Objetivo

Proporcionar un IDE profesional que cubra todo el ecosistema Elixir/OTP sin dejar de lado ninguna funcionalidad, herramienta o característica necesaria para alcanzar la excelencia en el desarrollo con Elixir.

## 🚀 Estado del Proyecto

Este proyecto está en desarrollo activo. La estructura base está siendo configurada según el [PROMPT_MAESTRO](Prompts/PROMPT_MAESTRO.md).

## 📋 Requisitos

- **Node.js**: v22.21.1 (específico, ver `.nvmrc`)
- **Python**: 3.9.0 (específico, ver `.python-version`)
- **Yarn**: ≥ 1.22.x
- **Git**: ≥ 2.25.0
- **Espacio en disco**: ≥ 20 GB

## 🛠️ Configuración Inicial

### Primera Instalación

1. Clonar el repositorio:
   ```bash
   git clone https://github.com/Lorenzo-SF/vscode.git ElixIDE
   cd ElixIDE
   ```

2. Configurar remotes:
   ```bash
   git remote add upstream https://github.com/microsoft/vscode.git
   ```

3. Ejecutar setup:
   - **macOS/Linux**: `./setup-yarn.sh`
   - **Windows (WSL2)**: `.\setup-yarn.ps1`

## 📚 Documentación

- [PROMPT_MAESTRO](Prompts/PROMPT_MAESTRO.md): Orquestador principal del proyecto
- [Preprompt](Prompts/Preprompt.md): Configuración del entorno y fork de VSCode

## 🔄 Workflow de Desarrollo

El proyecto utiliza Git Flow con ramas `main` y `develop`:
- `main`: Código estable y probado
- `develop`: Rama de integración para desarrollo activo
- `feature/v{N}-{descripcion}`: Feature branches para cada módulo

## 📝 Licencia

Este proyecto es un fork de VSCode y mantiene la licencia original de VSCode.

## 👥 Contribuir

Este proyecto está en desarrollo activo. Consulta la documentación en `docs/` para más información sobre cómo contribuir.

