OUTPUT_ARCH(riscv)
ENTRY(_start)
MEMORY
{
  FLASH (rx)  : ORIGIN = 0x00000000, LENGTH = 32K
  RAM   (rwx) : ORIGIN = 0x00008000, LENGTH = 32K
}
SECTIONS
{
  .text : ALIGN(4) { KEEP(*(.text.startup)) *(.text .text.*) *(.rodata .rodata.*) } > FLASH
  .data : ALIGN(4) { __data_start = .; *(.data .data.*) *(.sdata .sdata.*); __data_end = .; } > RAM AT> FLASH
  __data_load_start = LOADADDR(.data);
  .bss (NOLOAD) : ALIGN(4) { __bss_start = .; *(.sbss .sbss.*) *(.bss .bss.*) *(COMMON); __bss_end = .; } > RAM
  __stack_top = ORIGIN(RAM) + LENGTH(RAM);
  /DISCARD/ : { *(.comment) *(.eh_frame*) *(.riscv.attributes) }
}
ASSERT(SIZEOF(.text) + SIZEOF(.data) <= LENGTH(FLASH), "CoreMark code exceeds 32KB ROM")
ASSERT(__bss_end < __stack_top - 4096, "CoreMark static RAM leaves less than 4KB stack")
