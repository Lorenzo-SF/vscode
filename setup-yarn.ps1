# setup-yarn.ps1 - Script de configuración de entorno para ElixIDE en Windows
# Este script verifica WSL2 y ejecuta el setup dentro de WSL2

param(
    [switch]$SkipWSLCheck
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "ElixIDE - Setup de Entorno (Windows)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que estamos en el directorio correcto
if (-not (Test-Path ".git") -or -not (Test-Path "package.json")) {
    Write-Host "ERROR: Este script debe ejecutarse desde el directorio raíz de ElixIDE" -ForegroundColor Red
    exit 1
}

# Verificar PowerShell 5+
if ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "ERROR: Se requiere PowerShell 5 o superior" -ForegroundColor Red
    exit 1
}

# Verificar Windows 10/11
$osVersion = [System.Environment]::OSVersion.Version
if ($osVersion.Major -lt 10) {
    Write-Host "ERROR: Se requiere Windows 10 o superior" -ForegroundColor Red
    exit 1
}

Write-Host "[1/5] Verificando WSL2..." -ForegroundColor Yellow

# Verificar WSL2
$wslStatus = wsl --status 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Host "WSL2 no está instalado. Instalando..." -ForegroundColor Yellow
    
    # Verificar permisos de administrador
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Host "ERROR: Se requieren permisos de administrador para instalar WSL2" -ForegroundColor Red
        Write-Host "Por favor, ejecuta este script como administrador" -ForegroundColor Yellow
        exit 1
    }
    
    Write-Host "Habilitando características de Windows..." -ForegroundColor Yellow
    Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -ErrorAction SilentlyContinue
    Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart -ErrorAction SilentlyContinue
    
    Write-Host "Instalando WSL2..." -ForegroundColor Yellow
    wsl --install
    
    Write-Host "IMPORTANTE: Es necesario reiniciar el sistema para completar la instalación de WSL2" -ForegroundColor Red
    Write-Host "Después del reinicio, ejecuta este script nuevamente" -ForegroundColor Yellow
    exit 0
}

# Verificar distribución Ubuntu
Write-Host "[2/5] Verificando distribución Ubuntu..." -ForegroundColor Yellow
$ubuntuDistro = wsl -l -v 2>&1 | Select-String "Ubuntu"
if (-not $ubuntuDistro) {
    Write-Host "Ubuntu no está instalado. Por favor, instálalo desde Microsoft Store:" -ForegroundColor Yellow
    Write-Host "https://www.microsoft.com/store/productId/9PDXGNCFSCZV" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Después de instalar Ubuntu, ejecuta este script nuevamente" -ForegroundColor Yellow
    exit 1
}

# Obtener nombre de la distribución Ubuntu
$ubuntuName = (wsl -l -v 2>&1 | Select-String "Ubuntu" | Select-Object -First 1).ToString().Split()[0]

Write-Host "[3/5] Preparando ruta del proyecto en WSL2..." -ForegroundColor Yellow

# Convertir ruta de Windows a WSL
$currentPath = (Get-Location).Path
$wslPath = $currentPath -replace '^([A-Z]):', { '/mnt/' + $_.Groups[1].Value.ToLower() } -replace '\\', '/'

Write-Host "Ruta en WSL2: $wslPath" -ForegroundColor Gray

Write-Host "[4/5] Ejecutando setup dentro de WSL2..." -ForegroundColor Yellow
Write-Host ""

# Ejecutar setup-yarn.sh dentro de WSL2
$setupScript = Join-Path $currentPath "setup-yarn.sh"
if (-not (Test-Path $setupScript)) {
    Write-Host "ERROR: No se encontró setup-yarn.sh" -ForegroundColor Red
    Write-Host "Asegúrate de que el archivo existe en el directorio raíz del proyecto" -ForegroundColor Yellow
    exit 1
}

# Copiar script a WSL si es necesario y ejecutarlo
Write-Host "Ejecutando configuración dentro de WSL2..." -ForegroundColor Cyan
wsl -d $ubuntuName bash -c "cd '$wslPath' && chmod +x setup-yarn.sh && ./setup-yarn.sh"

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "ERROR: El setup falló dentro de WSL2" -ForegroundColor Red
    Write-Host "Revisa los logs en setup-yarn.log para más detalles" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "[5/5] Verificación final..." -ForegroundColor Yellow

# Verificar que todo está configurado correctamente
Write-Host "Verificando Node.js..." -ForegroundColor Gray
$nodeVersion = wsl -d $ubuntuName bash -c "cd '$wslPath' && node --version"
if ($nodeVersion -match "v22\.21\.1") {
    Write-Host "  ✓ Node.js $nodeVersion" -ForegroundColor Green
} else {
    Write-Host "  ✗ Node.js versión incorrecta: $nodeVersion (esperado: v22.21.1)" -ForegroundColor Red
}

Write-Host "Verificando Yarn..." -ForegroundColor Gray
$yarnVersion = wsl -d $ubuntuName bash -c "cd '$wslPath' && yarn --version"
if ($yarnVersion) {
    Write-Host "  ✓ Yarn $yarnVersion" -ForegroundColor Green
} else {
    Write-Host "  ✗ Yarn no está disponible" -ForegroundColor Red
}

Write-Host "Verificando Python..." -ForegroundColor Gray
$pythonVersion = wsl -d $ubuntuName bash -c "cd '$wslPath' && python --version"
if ($pythonVersion -match "Python 3\.9\.0") {
    Write-Host "  ✓ $pythonVersion" -ForegroundColor Green
} else {
    Write-Host "  ✗ Python versión incorrecta: $pythonVersion (esperado: Python 3.9.0)" -ForegroundColor Red
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Setup completado!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Para trabajar con ElixIDE, abre WSL2 y navega al directorio:" -ForegroundColor Yellow
Write-Host "  wsl" -ForegroundColor Cyan
Write-Host "  cd $wslPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "Comandos útiles:" -ForegroundColor Yellow
Write-Host "  yarn compile  - Compilar el proyecto" -ForegroundColor Gray
Write-Host "  yarn watch    - Modo desarrollo (watch)" -ForegroundColor Gray
Write-Host "  yarn start    - Ejecutar ElixIDE" -ForegroundColor Gray
Write-Host "  yarn test     - Ejecutar tests" -ForegroundColor Gray
Write-Host ""

