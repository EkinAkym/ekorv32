  __heap_size    = 0x200;  /* required amount of heap */
  __stack_size  =  0x200;  /* required amount of stack */

  MEMORY
  {
    ROM (rwx) : ORIGIN = 0x00000000, LENGTH = 0x00800
    RAM (rwx) : ORIGIN = 0x00000800, LENGTH = 0x00800
  }
  SECTIONS
  {
    .text :
    {
      *(.boot)
      *(.text)
      *(.text)
      *(.rodata*)
    } > ROM
    .data :
    {
      *(.sbss)
      *(.data)
      *(.bss)
      *(.rela*)
      *(COMMON)
    } > RAM

    .heap :
    {
      . = ALIGN(4);
      PROVIDE ( end = . );
      _sheap = .;
      . = . + __heap_size;
      . = ALIGN(4);
      _eheap = .;
    } >RAM

    .stack :
    {
      . = ALIGN(4);
      _estack = .;
      . = . + __stack_size;
      . = ALIGN(4);
      _sstack = .;
    } >RAM
  }
                        