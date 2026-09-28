$ErrorActionPreference = 'Stop'

$here = $PSScriptRoot
$packageRoot = [System.IO.Path]::GetFullPath((Join-Path $here '..\..'))
$elf = Join-Path $here 'coremark_performance_fixed.elf'
$generator = Join-Path $here 'generate_rom.ps1'
$expectedRom = Join-Path $packageRoot 'rom\coremark_rom.v'
$actualRom = Join-Path $env:TEMP ('xiao-coremark-rom-' + [guid]::NewGuid().ToString('N') + '.v')

try {
    & $generator -ElfPath $elf -RomPath $actualRom

    $expectedHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $expectedRom).Hash
    $actualHash = (Get-FileHash -Algorithm SHA256 -LiteralPath $actualRom).Hash
    if ($actualHash -ne $expectedHash) {
        throw "Generated ROM does not match the checked-in ROM. Expected $expectedHash, got $actualHash."
    }
    Write-Host "COREMARK_ROM_REPRODUCTION: PASS SHA256=$actualHash"
}
finally {
    if (Test-Path -LiteralPath $actualRom) {
        Remove-Item -LiteralPath $actualRom -Force
    }
}
