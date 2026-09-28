param(
    [string]$ModelSim = $env:MODELSIM_BIN
)

$ErrorActionPreference = 'Stop'

if ([string]::IsNullOrWhiteSpace($ModelSim)) {
    $ModelSim = 'C:\intelFPGA\20.1\modelsim_ase\win32aloem\vsim.exe'
}

if (-not (Test-Path -LiteralPath $ModelSim -PathType Leaf)) {
    throw "ModelSim executable not found: $ModelSim. Set MODELSIM_BIN or pass -ModelSim."
}

$tests = @(
    @{ Script = 'run_sim.do'; Pass = 'RV32I_REGRESSION: PASS (32 registers checked)' },
    @{ Script = 'run_uart_tx.do'; Pass = 'UART_TX_TEST: PASS byte=0x41' },
    @{ Script = 'run_uart_mmio.do'; Pass = 'CPU_MMIO_UART_TEST: PASS' },
    @{ Script = 'run_uart_cpu_string.do'; Pass = 'CPU_UART_STRING_TEST: PASS RV32I_CPU_OK' },
    @{ Script = 'run_uart_cpu_rv32i.do'; Pass = 'CPU_RV32I_UART_TEST: PASS CPU_RV32I_PASS (16 bytes)' },
    @{ Script = 'run_uart_cpu_load_use.do'; Pass = 'CPU_LOAD_USE_UART_TEST: PASS LOAD_USE_PASS' }
)

Push-Location $PSScriptRoot
try {
    foreach ($test in $tests) {
        Write-Host "=== Running $($test.Script) ==="
        $output = & $ModelSim -c -do $test.Script 2>&1
        $exitCode = $LASTEXITCODE
        $output | ForEach-Object { Write-Host $_ }
        $transcript = $output -join "`n"

        if ($exitCode -ne 0) {
            throw "$($test.Script) exited with code $exitCode"
        }
        if ($transcript -notmatch [regex]::Escape($test.Pass)) {
            throw "$($test.Script) did not emit its expected PASS marker"
        }
    }

    Write-Host 'ALL_REGRESSIONS: PASS'
}
finally {
    Pop-Location
}
