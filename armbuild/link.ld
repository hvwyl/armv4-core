ENTRY(Reset_Handler)

SECTIONS { 
  . = 0x00000;
  .text : {*(.text)}
  . = 0x10000;
  .data : {*(.data)}
}