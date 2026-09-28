param(
    [Parameter(Mandatory=$true)][string]$ElfPath,
    [Parameter(Mandatory=$true)][string]$RomPath
)

$bytes = [System.IO.File]::ReadAllBytes($ElfPath)
if ($bytes[0] -ne 0x7f -or $bytes[1] -ne 0x45 -or $bytes[2] -ne 0x4c -or $bytes[3] -ne 0x46) {
    throw 'Input is not an ELF file.'
}
if ($bytes[4] -ne 1 -or $bytes[5] -ne 1) {
    throw 'Expected a 32-bit little-endian ELF.'
}

$phoff = [BitConverter]::ToUInt32($bytes, 28)
$phentsize = [BitConverter]::ToUInt16($bytes, 42)
$phnum = [BitConverter]::ToUInt16($bytes, 44)
$image = [System.Collections.Generic.SortedDictionary[uint32,byte]]::new()
$highestAddress = [uint32]0

for ($i = 0; $i -lt $phnum; $i++) {
    $entry = [int]($phoff + ($i * $phentsize))
    $type = [BitConverter]::ToUInt32($bytes, $entry)
    if ($type -ne 1) { continue }
    $offset = [BitConverter]::ToUInt32($bytes, $entry + 4)
    $paddr = [BitConverter]::ToUInt32($bytes, $entry + 12)
    $filesz = [BitConverter]::ToUInt32($bytes, $entry + 16)
    for ($j = 0; $j -lt $filesz; $j++) {
        $address = [uint32]($paddr + $j)
        $image[$address] = $bytes[[int]($offset + $j)]
        if ($address -gt $highestAddress) { $highestAddress = $address }
    }
}

if ($image.Count -eq 0) { throw 'ELF contains no loadable program data.' }
if ($highestAddress -ge 0x8000) { throw ('ROM image exceeds 32 KiB: 0x{0:X}' -f $highestAddress) }

$wordCount = [int](($highestAddress + 4) / 4)
$lines = [System.Collections.Generic.List[string]]::new()
$lines.Add('// Generated from corrected CoreMark performance ELF; do not hand-edit.')
$lines.Add('module coremark_rom(input wire [31:0] addr, output reg [31:0] data);')
$lines.Add('always @(*) begin')
$lines.Add('case (addr[14:2])')
for ($word = 0; $word -lt $wordCount; $word++) {
    $value = [uint32]0
    for ($lane = 0; $lane -lt 4; $lane++) {
        $byteAddress = [uint32](($word * 4) + $lane)
        if ($image.ContainsKey($byteAddress)) {
            $value = $value -bor ([uint32]$image[$byteAddress] -shl (8 * $lane))
        }
    }
    $lines.Add("13'd$word`: data = 32'h$($value.ToString('X8'));")
}
$lines.Add("default: data = 32'h00000013;")
$lines.Add('endcase')
$lines.Add('end')
$lines.Add('endmodule')
[System.IO.File]::WriteAllLines($RomPath, $lines)
"ROM_WORDS=$wordCount MAX_LOAD_ADDRESS=0x$($highestAddress.ToString('X'))"
