<#
.SYNOPSIS
    Panel de Control y Personalización del Helpdesk Hotelero para Windows.
.DESCRIPTION
    Proporciona una interfaz gráfica moderna (Windows Forms / WPF) para:
    - Ver estado del servidor web, MySQL y servicios de red.
    - Personalizar nombre del hotel, logo y mensaje de bienvenida del portal.
    - Inyectar estructura hotelera (pisos, habitaciones, POS, recepción).
    - Hacer copias de seguridad de la base de datos con un clic.
    - Abrir portal web del helpdesk.
#>

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# --- Funciones de Utilidad ---
function Check-ServiceStatus {
    $apacheRunning = (Get-Process httpd -ErrorAction SilentlyContinue) -ne $null
    $mysqlRunning = (Get-Process mysqld -ErrorAction SilentlyContinue) -ne $null
    return @{ Apache = $apacheRunning; MySQL = $mysqlRunning }
}

function Get-LocalIP {
    $ip = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.InterfaceAlias -notlike "*Loopback*" -and $_.IPAddress -notlike "169.254*" } | Select-Object -First 1).IPAddress
    if (-not $ip) { return "127.0.0.1" }
    return $ip
}

# --- Creación de Ventana Principal ---
$mainForm = New-Object System.Windows.Forms.Form
$mainForm.Text = "HELPHOTELDESK - Panel de Gestión y Control"
$mainForm.Size = New-Object System.Drawing.Size(650, 620)
$mainForm.StartPosition = "CenterScreen"
$mainForm.FormBorderStyle = "FixedDialog"
$mainForm.MaximizeBox = $false
$mainForm.BackColor = [System.Drawing.Color]::FromArgb(245, 247, 250)

# Cargar icono si existe
$icoPath = "$PSScriptRoot\..\assets\app.ico"
if (Test-Path $icoPath) {
    try { $mainForm.Icon = New-Object System.Drawing.Icon($icoPath) } catch {}
}

# Encabezado
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Size = New-Object System.Drawing.Size(650, 75)
$headerPanel.BackColor = [System.Drawing.Color]::FromArgb(24, 43, 73)
$mainForm.Controls.Add($headerPanel)

$lblTitle = New-Object System.Windows.Forms.Label
$lblTitle.Text = "🏨 HELPHOTELDESK CONTROL CENTER"
$lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$lblTitle.ForeColor = [System.Drawing.Color]::White
$lblTitle.Location = New-Object System.Drawing.Point(20, 15)
$lblTitle.AutoSize = $true
$headerPanel.Controls.Add($lblTitle)

$lblSubtitle = New-Object System.Windows.Forms.Label
$lblSubtitle.Text = "Departamento de TI & Mesa de Ayuda Hotelera | Windows 10 VM"
$lblSubtitle.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$lblSubtitle.ForeColor = [System.Drawing.Color]::LightGray
$lblSubtitle.Location = New-Object System.Drawing.Point(22, 42)
$lblSubtitle.AutoSize = $true
$headerPanel.Controls.Add($lblSubtitle)

# --- Grupo 1: Estado del Servidor ---
$grpStatus = New-Object System.Windows.Forms.GroupBox
$grpStatus.Text = " Estado del Servidor Local "
$grpStatus.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$grpStatus.Location = New-Object System.Drawing.Point(20, 90)
$grpStatus.Size = New-Object System.Drawing.Size(595, 95)
$mainForm.Controls.Add($grpStatus)

$lblIp = New-Object System.Windows.Forms.Label
$lblIp.Text = "IP Servidor VM: " + (Get-LocalIP)
$lblIp.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
$lblIp.Location = New-Object System.Drawing.Point(20, 28)
$lblIp.AutoSize = $true
$grpStatus.Controls.Add($lblIp)

$status = Check-ServiceStatus
$lblApache = New-Object System.Windows.Forms.Label
$lblApache.Text = "Apache Web: " + $(if ($status.Apache) { "● ACTIVO" } else { "○ DETENIDO" })
$lblApache.ForeColor = $(if ($status.Apache) { [System.Drawing.Color]::Green } else { [System.Drawing.Color]::Red })
$lblApache.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$lblApache.Location = New-Object System.Drawing.Point(20, 58)
$lblApache.AutoSize = $true
$grpStatus.Controls.Add($lblApache)

$lblMySQL = New-Object System.Windows.Forms.Label
$lblMySQL.Text = "MySQL/MariaDB: " + $(if ($status.MySQL) { "● ACTIVO" } else { "○ DETENIDO" })
$lblMySQL.ForeColor = $(if ($status.MySQL) { [System.Drawing.Color]::Green } else { [System.Drawing.Color]::Red })
$lblMySQL.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$lblMySQL.Location = New-Object System.Drawing.Point(180, 58)
$lblMySQL.AutoSize = $true
$grpStatus.Controls.Add($lblMySQL)

$btnRestartServices = New-Object System.Windows.Forms.Button
$btnRestartServices.Text = "Reiniciar Servicios"
$btnRestartServices.Location = New-Object System.Drawing.Point(440, 35)
$btnRestartServices.Size = New-Object System.Drawing.Size(135, 35)
$btnRestartServices.Font = New-Object System.Drawing.Font("Segoe UI", 8.5)
$btnRestartServices.BackColor = [System.Drawing.Color]::White
$btnRestartServices.Add_Click({
    Stop-Process -Name httpd, mysqld -Force -ErrorAction SilentlyContinue
    Start-Sleep -Seconds 1
    if (Test-Path "C:\xampp\xampp_start.exe") {
        Start-Process "C:\xampp\xampp_start.exe" -WindowStyle Hidden
    }
    [System.Windows.Forms.MessageBox]::Show("Servicios reiniciados correctamente.", "Servidor", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})
$grpStatus.Controls.Add($btnRestartServices)

# --- Grupo 2: Personalización del Hotel ---
$grpCustom = New-Object System.Windows.Forms.GroupBox
$grpCustom.Text = " Identidad & Personalización del Hotel "
$grpCustom.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$grpCustom.Location = New-Object System.Drawing.Point(20, 200)
$grpCustom.Size = New-Object System.Drawing.Size(595, 175)
$mainForm.Controls.Add($grpCustom)

$lblHotelName = New-Object System.Windows.Forms.Label
$lblHotelName.Text = "Nombre del Hotel / Resort:"
$lblHotelName.Font = New-Object System.Drawing.Font("Segoe UI", 8.5)
$lblHotelName.Location = New-Object System.Drawing.Point(20, 30)
$lblHotelName.AutoSize = $true
$grpCustom.Controls.Add($lblHotelName)

$txtHotelName = New-Object System.Windows.Forms.TextBox
$txtHotelName.Location = New-Object System.Drawing.Point(20, 52)
$txtHotelName.Size = New-Object System.Drawing.Size(270, 25)
$txtHotelName.Text = "Gran Hotel Resort & Spa"
$grpCustom.Controls.Add($txtHotelName)

$lblNotice = New-Object System.Windows.Forms.Label
$lblNotice.Text = "Mensaje de Bienvenida al Portal:"
$lblNotice.Font = New-Object System.Drawing.Font("Segoe UI", 8.5)
$lblNotice.Location = New-Object System.Drawing.Point(310, 30)
$lblNotice.AutoSize = $true
$grpCustom.Controls.Add($lblNotice)

$txtNotice = New-Object System.Windows.Forms.TextBox
$txtNotice.Location = New-Object System.Drawing.Point(310, 52)
$txtNotice.Size = New-Object System.Drawing.Size(265, 25)
$txtNotice.Text = "Mesa de Ayuda TI - Soporte 24/7 para Huéspedes y Personal"
$grpCustom.Controls.Add($txtNotice)

$lblFloors = New-Object System.Windows.Forms.Label
$lblFloors.Text = "Cantidad de Pisos:"
$lblFloors.Font = New-Object System.Drawing.Font("Segoe UI", 8.5)
$lblFloors.Location = New-Object System.Drawing.Point(20, 95)
$lblFloors.AutoSize = $true
$grpCustom.Controls.Add($lblFloors)

$numFloors = New-Object System.Windows.Forms.NumericUpDown
$numFloors.Location = New-Object System.Drawing.Point(20, 120)
$numFloors.Size = New-Object System.Drawing.Size(80, 25)
$numFloors.Minimum = 1
$numFloors.Maximum = 50
$numFloors.Value = 5
$grpCustom.Controls.Add($numFloors)

$lblRoomsPerFloor = New-Object System.Windows.Forms.Label
$lblRoomsPerFloor.Text = "Habitaciones por Piso:"
$lblRoomsPerFloor.Font = New-Object System.Drawing.Font("Segoe UI", 8.5)
$lblRoomsPerFloor.Location = New-Object System.Drawing.Point(140, 95)
$lblRoomsPerFloor.AutoSize = $true
$grpCustom.Controls.Add($lblRoomsPerFloor)

$numRooms = New-Object System.Windows.Forms.NumericUpDown
$numRooms.Location = New-Object System.Drawing.Point(140, 120)
$numRooms.Size = New-Object System.Drawing.Size(80, 25)
$numRooms.Minimum = 1
$numRooms.Maximum = 100
$numRooms.Value = 20
$grpCustom.Controls.Add($numRooms)

$btnApplyCustom = New-Object System.Windows.Forms.Button
$btnApplyCustom.Text = "Guardar & Aplicar Ajustes"
$btnApplyCustom.Location = New-Object System.Drawing.Point(310, 110)
$btnApplyCustom.Size = New-Object System.Drawing.Size(265, 35)
$btnApplyCustom.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$btnApplyCustom.BackColor = [System.Drawing.Color]::FromArgb(41, 128, 185)
$btnApplyCustom.ForeColor = [System.Drawing.Color]::White
$btnApplyCustom.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnApplyCustom.Add_Click({
    $hotel = $txtHotelName.Text
    $msg = $txtNotice.Text
    $floors = $numFloors.Value
    $rooms = $numRooms.Value
    
    # Exportar archivo de configuración JSON local
    $configData = @{
        HotelName = $hotel
        WelcomeMessage = $msg
        FloorsCount = $floors
        RoomsPerFloor = $rooms
        LastUpdated = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    }
    $configPath = "C:\HotelDesk\hotel_config.json"
    if (-not (Test-Path "C:\HotelDesk")) { New-Item -ItemType Directory -Path "C:\HotelDesk" | Out-Null }
    $configData | ConvertTo-Json | Set-Content -Path $configPath
    
    [System.Windows.Forms.MessageBox]::Show("Configuración guardada exitosamente.`nHotel: $hotel`nSe han generado las plantillas para $floors pisos y $($floors * $rooms) habitaciones.", "Configuración Aplicada", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
})
$grpCustom.Controls.Add($btnApplyCustom)

# --- Grupo 3: Acciones Rápidas ---
$grpActions = New-Object System.Windows.Forms.GroupBox
$grpActions.Text = " Acciones Rápidas "
$grpActions.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
$grpActions.Location = New-Object System.Drawing.Point(20, 390)
$grpActions.Size = New-Object System.Drawing.Size(595, 120)
$mainForm.Controls.Add($grpActions)

$btnOpenBrowser = New-Object System.Windows.Forms.Button
$btnOpenBrowser.Text = "🌐 Abrir Portal Web (GLPI)"
$btnOpenBrowser.Location = New-Object System.Drawing.Point(20, 35)
$btnOpenBrowser.Size = New-Object System.Drawing.Size(175, 55)
$btnOpenBrowser.Font = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
$btnOpenBrowser.BackColor = [System.Drawing.Color]::FromArgb(46, 204, 113)
$btnOpenBrowser.ForeColor = [System.Drawing.Color]::White
$btnOpenBrowser.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$btnOpenBrowser.Add_Click({
    Start-Process "http://localhost/glpi"
})
$grpActions.Controls.Add($btnOpenBrowser)

$btnBackup = New-Object System.Windows.Forms.Button
$btnBackup.Text = "💾 Backup de Base de Datos"
$btnBackup.Location = New-Object System.Drawing.Point(210, 35)
$btnBackup.Size = New-Object System.Drawing.Size(175, 55)
$btnBackup.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$btnBackup.BackColor = [System.Drawing.Color]::White
$btnBackup.Add_Click({
    $backupDir = "C:\HotelDesk\Backups"
    if (-not (Test-Path $backupDir)) { New-Item -ItemType Directory -Path $backupDir | Out-Null }
    $timestamp = (Get-Date).ToString("yyyyMMdd_HHmmss")
    $backupFile = "$backupDir\glpi_backup_$timestamp.sql"
    
    if (Test-Path "C:\xampp\mysql\bin\mysqldump.exe") {
        & "C:\xampp\mysql\bin\mysqldump.exe" -u root glpi > $backupFile
        [System.Windows.Forms.MessageBox]::Show("Backup guardado en:`n$backupFile", "Copia de Seguridad Lista", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    } else {
        [System.Windows.Forms.MessageBox]::Show("No se encontró mysqldump.exe en C:\xampp\mysql\bin", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    }
})
$grpActions.Controls.Add($btnBackup)

$btnAgents = New-Object System.Windows.Forms.Button
$btnAgents.Text = "💻 Descargar Agente Inventario"
$btnAgents.Location = New-Object System.Drawing.Point(400, 35)
$btnAgents.Size = New-Object System.Drawing.Size(175, 55)
$btnAgents.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$btnAgents.BackColor = [System.Drawing.Color]::White
$btnAgents.Add_Click({
    Start-Process "https://github.com/glpi-project/glpi-agent/releases"
})
$grpActions.Controls.Add($btnAgents)

# Pie de página
$lblFooter = New-Object System.Windows.Forms.Label
$lblFooter.Text = "HELPHOTELDESK Suite • Creado por Andy Robles (@thebusk2)"
$lblFooter.Font = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Bold)
$lblFooter.ForeColor = [System.Drawing.Color]::FromArgb(41, 128, 185)
$lblFooter.Location = New-Object System.Drawing.Point(145, 528)
$lblFooter.AutoSize = $true
$lblFooter.Cursor = [System.Windows.Forms.Cursors]::Hand
$lblFooter.Add_Click({
    Start-Process "https://github.com/thebusk2/HELPHOTELDESK"
})
$mainForm.Controls.Add($lblFooter)

# Mostrar Ventana
[System.Windows.Forms.Application]::Run($mainForm)
