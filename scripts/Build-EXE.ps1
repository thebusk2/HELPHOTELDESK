<#
.SYNOPSIS
    Compilador nativo de C# a .EXE usando csc.exe incorporado en Windows (.NET Framework).
#>

$cscPath = "C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe"
if (-not (Test-Path $cscPath)) {
    $cscPath = "C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe"
}

if (-not (Test-Path $cscPath)) {
    Write-Error "No se encontró el compilador de C# en Windows (.NET Framework 4.x)."
    exit 1
}

$sourceFile = "$PSScriptRoot\HotelDeskSetup.cs"
$outputExe = "$PSScriptRoot\..\HELPHOTELDESK.exe"
$iconPath = "$PSScriptRoot\..\assets\app.ico"

Write-Host "Compilando HELPHOTELDESK.exe con icono nativo..." -ForegroundColor Cyan

if (Test-Path $iconPath) {
    & $cscPath /target:winexe /platform:anycpu /win32icon:$iconPath /out:$outputExe $sourceFile /reference:System.Windows.Forms.dll,System.Drawing.dll,System.IO.Compression.dll,System.IO.Compression.FileSystem.dll
} else {
    & $cscPath /target:winexe /platform:anycpu /out:$outputExe $sourceFile /reference:System.Windows.Forms.dll,System.Drawing.dll,System.IO.Compression.dll,System.IO.Compression.FileSystem.dll
}

if (Test-Path $outputExe) {
    Write-Host "¡Éxito! Se ha generado el ejecutable: $outputExe" -ForegroundColor Green
} else {
    Write-Error "Error durante la compilación."
}
