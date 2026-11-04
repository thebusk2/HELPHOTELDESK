<#
.SYNOPSIS
    Compilador nativo de C# a .EXE usando csc.exe incorporado en Windows (.NET Framework).
.DESCRIPTION
    No requiere instalar Visual Studio, GCC ni herramientas externas.
    Windows 10 ya incluye csc.exe en C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe.
    Este script compila el código fuente HotelDeskSetup.cs y produce HotelDeskSetup.exe.
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
$outputExe = "$PSScriptRoot\..\HotelDeskSetup.exe"

Write-Host "Compilando HotelDeskSetup.exe usando csc.exe..." -ForegroundColor Cyan

& $cscPath /target:winexe /platform:anycpu /out:$outputExe $sourceFile /reference:System.Windows.Forms.dll,System.Drawing.dll,System.IO.Compression.dll,System.IO.Compression.FileSystem.dll

if (Test-Path $outputExe) {
    Write-Host "¡Éxito! Se ha generado el ejecutable: $outputExe" -ForegroundColor Green
} else {
    Write-Error "Error durante la compilación."
}
