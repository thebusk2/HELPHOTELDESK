<#
.SYNOPSIS
    Instalación y despliegue desatendido/guiado de GLPI en Windows 10 dentro de la VM.
.DESCRIPTION
    Descarga e instala el stack web (PHP, Apache/XAMPP o MariaDB), prepara extensiones de PHP,
    descarga la última versión de GLPI y crea el servicio de Windows.
#>

param(
    [string]$InstallDir = "C:\HotelDesk",
    [string]$DbPassword = "HotelDeskSecure2026!"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "🏨 INSTALADOR AUTOMATIZADO DE GLPI PARA HOTEL (WINDOWS 10)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Comprobación de Administrador
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "Por favor, ejecuta este script en la máquina virtual como Administrador."
    exit
}

# 2. Configurar regla de Firewall para permitir acceso desde la red del hotel
Write-Host "[1/5] Configurando Firewall de Windows para puertos 80 (HTTP) y 443 (HTTPS)..." -ForegroundColor Yellow
New-NetFirewallRule -DisplayName "Hotel Helpdesk Web (HTTP)" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow -ErrorAction SilentlyContinue | Out-Null
New-NetFirewallRule -DisplayName "Hotel Helpdesk Web (HTTPS)" -Direction Inbound -LocalPort 443 -Protocol TCP -Action Allow -ErrorAction SilentlyContinue | Out-Null
Write-Host "✓ Reglas de Firewall habilitadas." -ForegroundColor Green

# 3. Preparar directorios
if (-not (Test-Path $InstallDir)) {
    New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
}

Write-Host "[2/5] Descargando componentes del servidor (XAMPP / MariaDB & PHP)..." -ForegroundColor Yellow
$installerXamppUrl = "https://sourceforge.net/projects/xampp/files/XAMPP%20Windows/8.2.12/xampp-windows-x64-8.2.12-0-VS16-installer.exe/download"
$xamppInstallerPath = "$env:TEMP\xampp-installer.exe"

if (-not (Test-Path "C:\xampp\apache\bin\httpd.exe")) {
    Write-Host "Descargando XAMPP (PHP 8.2)..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri $installerXamppUrl -OutFile $xamppInstallerPath
    Write-Host "Instalando XAMPP de forma silenciosa en C:\xampp..." -ForegroundColor Cyan
    Start-Process -FilePath $xamppInstallerPath -ArgumentList "--mode unattended" -Wait
    Remove-Item $xamppInstallerPath -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "✓ XAMPP ya se encuentra instalado en C:\xampp." -ForegroundColor Green
}

# 4. Descargar e instalar GLPI
Write-Host "[3/5] Descargando la última versión de GLPI..." -ForegroundColor Yellow
$glpiUrl = "https://github.com/glpi-project/glpi/releases/download/10.0.16/glpi-10.0.16.tgz"
$glpiTarGz = "$env:TEMP\glpi.tgz"
$glpiTar = "$env:TEMP\glpi.tar"

if (-not (Test-Path "C:\xampp\htdocs\glpi\index.php")) {
    Invoke-WebRequest -Uri $glpiUrl -OutFile $glpiTarGz
    
    Write-Host "Extrayendo GLPI en C:\xampp\htdocs\glpi..." -ForegroundColor Cyan
    tar -xzf $glpiTarGz -C "C:\xampp\htdocs"
    Remove-Item $glpiTarGz -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "✓ GLPI ya está presente en C:\xampp\htdocs\glpi." -ForegroundColor Green
}

# 5. Configurar PHP Extensions requeridas por GLPI
Write-Host "[4/5] Habilitando extensiones PHP necesarias (intl, gd, ldap, curl, zip, mysqli)..." -ForegroundColor Yellow
$phpIni = "C:\xampp\php\php.ini"
if (Test-Path $phpIni) {
    $content = Get-Content $phpIni
    $extensions = @("curl", "fileinfo", "gd", "intl", "mbstring", "mysqli", "openssl", "pdo_mysql", "soap", "sockets", "sodium", "zip", "ldap", "bz2")
    foreach ($ext in $extensions) {
        $content = $content -replace ";extension=$ext", "extension=$ext"
    }
    # Aumentar límites para adjuntos e imágenes de soporte
    $content = $content -replace "upload_max_filesize = 2M", "upload_max_filesize = 32M"
    $content = $content -replace "post_max_size = 8M", "post_max_size = 48M"
    $content = $content -replace "memory_limit = 128M", "memory_limit = 512M"
    Set-Content -Path $phpIni -Value $content
}

# 6. Iniciar servicios Apache y MySQL
Write-Host "[5/5] Iniciando servicios de Apache y MySQL..." -ForegroundColor Yellow
Start-Process "C:\xampp\xampp_start.exe" -Wait -WindowStyle Hidden

# Obtener IP Local
$localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254*" } | Select-Object -First 1).IPAddress

Write-Host "==========================================================" -ForegroundColor Green
Write-Host "✅ INSTALACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "Accede a la mesa de ayuda desde tu navegador en:" -ForegroundColor Cyan
Write-Host "👉 http://localhost/glpi   (Local en la VM)" -ForegroundColor White
Write-Host "👉 http://$localIP/glpi  (Desde cualquier PC del hotel)" -ForegroundColor White
Write-Host ""
Write-Host "Credenciales por defecto de GLPI:" -ForegroundColor Yellow
Write-Host "• Administrador: glpi / glpi" -ForegroundColor White
Write-Host "• Técnico: tech / tech" -ForegroundColor White
Write-Host "• Usuario estándar: normal / normal" -ForegroundColor White
Write-Host "==========================================================" -ForegroundColor Green
