ENTRY(_start)

SECTIONS { 
  . = 0x00000;
  .text             : {*(.text)}
  .rodata ALIGN(4)  : {*(.rodata)}
  .data   ALIGN(4)  : {*(.data)}
  __bss_start = ALIGN(4);
  .bss              : {*(.bss) *(COMMON)}
  __bss_end = ALIGN(4);
  . = 0x10000;
  __stack_top = ALIGN(4);
}