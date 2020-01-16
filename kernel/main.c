#include "main.h"
#include "screen.h"
#include "interrupt_descriptor_table_entry.h"

void KernelMain()
{
    //__magic();    // break into BOCHS
    
   // __enableSSE();  // only for demo; in the future will be called from __init.asm
  //	ASMEntryPoint();
	
    ClearScreen();
	idt_init();
	IRQ_clear_mask(0);
	IRQ_clear_mask(1);
	IRQ_clear_mask(8);
	
	//HelloBoot();
	__sti();
	pit_configure_channel(0, 2, 200);
    // TODO!!! PIC programming; see http://www.osdever.net/tutorials/view/programming-the-pic
    // TODO!!! define interrupt routines and dump trap frame
    
    // TODO!!! Timer programming

    // TODO!!! Keyboard programming

    // TODO!!! Implement a simple console

    // TODO!!! read disk sectors using PIO mode ATA

    // TODO!!! Memory management: virtual, physical and heap memory allocators
	while (1) {}
}
