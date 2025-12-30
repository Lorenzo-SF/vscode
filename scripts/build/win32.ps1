# win32.ps1 - Script de build para Windows (desde PowerShell)
# Especificación: v0.md sección 1.4, Tarea 3
# NOTA: Este script debe ejecutarse desde PowerShell en Windows, no desde WSL

param(
    [string]$Arch = "x64"
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $ScriptDir)

Write-Host "==========================================" -ForegroundColor Green
Write-Host "Build de ElixIDE para Windows" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host ""

# Verificar que estamos en Windows
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "[ERROR] PowerShell 5+ requerido" -ForegroundColor Red
    exit 1
}

# Verificar comandos requeridos
$requiredCommands = @("node", "npm", "yarn")
foreach ($cmd in $requiredCommands) {
    if (-not (Get-Command $cmd -ErrorAction SilentlyContinue)) {
        Write-Host "[ERROR] Comando '$cmd' no encontrado" -ForegroundColor Red
        exit 1
    }
}

# Verificar versión de Node.js
$nodeVersion = node --version
if ($nodeVersion -ne "v22.21.1") {
    Write-Host "[WARN] Versión de Node.js: $nodeVersion (requerida: v22.21.1)" -ForegroundColor Yellow
}

Write-Host "[INFO] Node.js versión: $nodeVersion" -ForegroundColor Green

# Cambiar al directorio del proyecto
Set-Location $ProjectRoot

# Aplicar parches (desde WSL si es necesario)
Write-Host "[INFO] Aplicando parches..." -ForegroundColor Green
$patchesDir = Join-Path $ProjectRoot "patches"
if (Test-Path $patchesDir) {
    # Nota: Los parches deben aplicarse desde WSL
    Write-Host "[WARN] Parches deben aplicarse desde WSL. Ejecuta desde WSL:" -ForegroundColor Yellow
    Write-Host "  cd $ProjectRoot"
    Write-Host "  bash scripts/build/common.sh apply_patches"
}

# Sincronizar assets
Write-Host "[INFO] Sincronizando assets..." -ForegroundColor Green
$syncScript = Join-Path $ProjectRoot "scripts\assets\sync-assets.sh"
if (Test-Path $syncScript) {
    # Ejecutar desde WSL
    wsl bash $syncScript
}

# Instalar dependencias
Write-Host "[INFO] Instalando dependencias..." -ForegroundColor Green
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Error al instalar dependencias" -ForegroundColor Red
    exit 1
}

# Compilar
Write-Host "[INFO] Compilando proyecto..." -ForegroundColor Green
npm run compile
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Error al compilar" -ForegroundColor Red
    exit 1
}

# Build para Windows
Write-Host "[INFO] Construyendo para Windows $Arch..." -ForegroundColor Green

if ($Arch -eq "x64") {
    npm run gulp vscode-win32-x64-min
} elseif ($Arch -eq "arm64") {
    npm run gulp vscode-win32-arm64-min
} else {
    Write-Host "[ERROR] Arquitectura no soportada: $Arch (usar x64 o arm64)" -ForegroundColor Red
    exit 1
}

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Error al construir para Windows $Arch" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Green
Write-Host "✓ Build completado exitosamente" -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
Write-Host "[INFO] Bundle generado en: ..\VSCode-win32-$Arch\" -ForegroundColor Green

# Nota sobre instalador
Write-Host ""
Write-Host "[INFO] Para generar instalador .exe, instala InnoSetup y ejecuta:" -ForegroundColor Yellow
Write-Host "  npm run gulp vscode-win32-$Arch-system-setup" -ForegroundColor Yellow

