# Remote FPGA board-test record

Platform: Logos2 PG2L200H remote FPGA. Platform allocation identifiers and credentials are intentionally omitted.

## Results

- Directed CPU/RV32I UART test: PASS. User observed `CPU_RV32I_PASS` at 14:41:20.564. Program emits `CPU_RV32I_PASS\r\n` after directed checks.
- Load-use hazard UART test: PASS. User previously observed `LOAD_USE_PASS`. This is a separate targeted test.
- Earlier UART smoke test: `RV32I_CPU_OK`, recorded separately.

## CoreMark run (2026-09-27)

- Serial output reported a CoreMark 2K performance run, 1000 iterations, about 52 seconds, 19 iterations/second, and `Correct operation validated`.
- At 27 MHz, the rounded console values give approximately 0.71 CoreMark/MHz. Raw timer ticks and a high-precision score were not captured.
- This used the dedicated `fpga_top_coremark` wrapper and a CoreMark ROM, not the release candidate's default top-level/ROM. All 16 RTL inputs listed by the CoreMark PDS Tcl flow were compared against the release candidate and matched byte-for-byte. The wrapper, 27 MHz constraint, fixed ELF/HEX, ROM generator, generated ROM, and prebuilt `.sbit` are now packaged under `benchmarks/coremark/`; `verify_rom.ps1` regenerated the committed ROM with an exact SHA-256 match. The packaged image is the later 2026-09-26 15:57:35 build; the fragmented serial transcript does not independently link that bitstream hash to the board run.
- The serial output was provided in fragmented console chunks; the pass claim is limited to the printed `Correct operation validated` marker.
- Archived fixed ELF SHA-256: `C17908C380B30972C86F5E1E975D5F1BEEA4CF6DE0669FB2A5E92FE21BE04DFB`.
- Packaged CoreMark ROM SHA-256: `0D5EFD977D40D305129353D8E432449368AD9F21F3D88B838EA3D6A70D57583F`.
- Packaged CoreMark `.sbit` SHA-256: `B42F4A4D85D11F4B7AA8B39D25C36A9341CE39D476909F62AC1CE3C062CE5730`.
- The sanitized saved-PDS timing summary is in `benchmarks/coremark/evidence/pnr-summary.md`; the 27 MHz clock constraint passed with 22.300 ns setup WNS and no failing endpoints.

## CoreMark rerun (2026-09-28)

- The user-provided remote serial transcript on 2026-09-28 reported 1000 iterations, `Total time (secs): 52`, `Iterations/Sec: 19`, the PG2L200H target, and ended with `Correct operation validated`.
- Using the displayed integer rate and 27 MHz board clock gives approximately 0.70 CoreMark/MHz (`19 / 27`). This is an approximate score from the displayed output, not a precision measurement.
- The transcript arrived in fragmented serial chunks. It is evidence that this run printed the CoreMark validation marker; it does not include a bitstream filename or hash. Do not claim this rerun is cryptographically linked to the packaged `.sbit` unless the programmed image is independently confirmed.

## Simulation evidence (2026-09-27)

- `powershell -ExecutionPolicy Bypass -File sim/run_regression.ps1`: exit 0; six expected PASS markers (architectural register checks, UART TX byte, UART MMIO, CPU UART string, RV32I UART program, and load-use UART program); ModelSim reported zero errors and warnings.
- `powershell -ExecutionPolicy Bypass -File benchmarks/coremark/firmware/pg2l200h/verify_rom.ps1`: `COREMARK_ROM_REPRODUCTION: PASS`; archived ELF regenerated the packaged ROM byte-for-byte.

These directed tests are not proof of full RV32I compliance. The official `riscv-tests` suite, real ILA capture, a clean source-to-identical-ELF rebuild, and exact historical source-to-board bitstream linkage remain outstanding. Preserve the upstream MIT notice and confirm team/competition publication rights before public release.
