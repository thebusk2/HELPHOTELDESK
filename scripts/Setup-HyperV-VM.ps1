<#
.SYNOPSIS
    Crea y configura la Máquina Virtual para el Helpdesk del Hotel en Hyper-V.
.DESCRIPTION
    Ejecutar este script en PowerShell como Administrador en el equipo HOST de Hyper-V.
    Crea un conmutador virtual de tipo Externo o Interno y aprovisiona la VM con Windows 10.
#>

param(
    [string]$VMName = "HotelDesk-VM",
    [int64]$MemoryStartupBytes = 4GB,
    [int]$CPUCount = 2,
    [int64]$VHDSizeBytes = 60GB,
    [string]$VHDPath = "C:\Hyper-V\Virtual Hard Disks\HotelDesk-VM.vhdx",
    [string]$SwitchName = "HotelLAN-Switch",
    [string]$ISODetectionPath = "C:\ISOs\Windows10.iso"
)

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "🏨 CREADOR DE MÁQUINA VIRTUAL HYPER-V - HELPDESK HOTEL" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Comprobar permisos de Administrador
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "Por favor, ejecuta este script abriendo PowerShell como Administrador."
    exit
}

# 2. Verificar si el rol de Hyper-V está activo
$hypervFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All
if ($hypervFeature.State -ne "Enabled") {
    Write-Warning "Hyper-V no parece estar habilitado en este equipo. Habilítalo ejecutando:"
    Write-Warning "Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All"
    exit
}

# 3. Comprobar / Crear Switch Virtual
$switch = Get-VMSwitch -Name $SwitchName -ErrorAction SilentlyContinue
if (-not $switch) {
    Write-Host "El conmutador virtual '$SwitchName' no existe. Creando conmutador por defecto (Default Switch)..." -ForegroundColor Yellow
    # Intentamos obtener un switch externo o usamos el Default Switch
    $defaultSwitch = Get-VMSwitch | Where-Object { $_.SwitchType -eq "External" -or $_.Name -like "*Default*" } | Select-Object -First 1
    if ($defaultSwitch) {
        $SwitchName = $defaultSwitch.Name
        Write-Host "Usando switch existente: $SwitchName" -ForegroundColor Green
    } else {
        Write-Host "Creando switch interno '$SwitchName'..." -ForegroundColor Yellow
        New-VMSwitch -Name $SwitchName -SwitchType Internal | Out-Null
    }
}

# 4. Crear directorio para discos si no existe
$vhdFolder = Split-Path -Path $VHDPath
if (-not (Test-Path $vhdFolder)) {
    New-Item -ItemType Directory -Path $vhdFolder -Force | Out-Null
}

# 5. Crear la Máquina Virtual (Generación 2 para Windows 10 moderno)
if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) {
    Write-Warning "La máquina virtual '$VMName' ya existe en Hyper-V."
} else {
    Write-Host "Creando VM '$VMName' (Gen 2, $CPUCount vCPUs, $([math]::Round($MemoryStartupBytes/1GB)) GB RAM)..." -ForegroundColor Yellow
    
    $vm = New-VM -Name $VMName `
                 -Generation 2 `
                 -MemoryStartupBytes $MemoryStartupBytes `
                 -SwitchName $SwitchName `
                 -NewVHDPath $VHDPath `
                 -NewVHDSizeBytes $VHDSizeBytes

    # Ajustar procesadores
    Set-VMProcessor -VMName $VMName -Count $CPUCount

    # Activar inicio dinámico de memoria o fija según preferencia
    Set-VMMemory -VMName $VMName -DynamicMemoryEnabled $true -MinimumBytes 2GB -MaximumBytes 8GB

    # Configurar booteo desde DVD si existe la ISO
    if (Test-Path $ISODetectionPath) {
        Write-Host "Montando ISO de Windows 10: $ISODetectionPath" -ForegroundColor Green
        Add-VMDvdDrive -VMName $VMName -Path $ISODetectionPath
        $dvd = Get-VMDvdDrive -VMName $VMName
        Set-VMFirmware -VMName $VMName -FirstBootDevice $dvd
    } else {
        Write-Host "No se encontró ISO en '$ISODetectionPath'. Recuerda montar la ISO de Windows 10 en la configuración de la VM." -ForegroundColor Yellow
    }

    Write-Host "¡Máquina virtual creada con éxito!" -ForegroundColor Green
    Write-Host "Inicia la VM desde el Administrador de Hyper-V o con: Start-VM -Name '$VMName'" -ForegroundColor Cyan
}
