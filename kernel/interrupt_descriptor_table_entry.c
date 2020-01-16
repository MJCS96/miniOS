#include "interrupt_descriptor_table_entry.h"
#include "main.h"

struct IDT_entry IDT[256];
#define PIC1		0x20		/* IO base address for master PIC */
#define PIC2		0xA0		/* IO base address for slave PIC */
#define PIC1_COMMAND	PIC1
#define PIC1_DATA	(PIC1+1)
#define PIC2_COMMAND	PIC2
#define PIC2_DATA	(PIC2+1)


void set_irq_address(unsigned long long irq_address,int index) {
	IDT[index].offset_lowerbits = irq_address & 0xffff;
	IDT[index].selector = 40; /* KERNEL_CODE_SEGMENT_OFFSET */
	IDT[index].zero = 0;
	IDT[index].type_attr = 0x8e; /* INTERRUPT_GATE */
	IDT[index].offset_higherbits = (irq_address & 0xffffffff00000000) >> 32;
	IDT[index].offset_middlebits = (irq_address & 0xffff0000) >> 16;
	IDT[index].reserved = 0;
}


void idt_init(void) {
	extern int irq2();
	extern int irq3();
	extern int irq4();
	extern int irq5();
	extern int irq6();
	extern int irq7();
	extern int irq8();
	extern int irq9();
	extern int irq10();
	extern int irq11();
	extern int irq12();
	extern int irq13();
	extern int irq14();
	extern int irq15();
	
	unsigned long long irq0_address;
	unsigned long long irq1_address;
	unsigned long long irq2_address;
	unsigned long long irq3_address;
	unsigned long long irq4_address;
	unsigned long long irq5_address;
	unsigned long long irq6_address;
	unsigned long long irq7_address;
	unsigned long long irq8_address;
	unsigned long long irq9_address;
	unsigned long long irq10_address;
	unsigned long long irq11_address;
	unsigned long long irq12_address;
	unsigned long long irq13_address;
	unsigned long long irq14_address;
	unsigned long long irq15_address;
	unsigned long long idt_address;
	unsigned short int idt_ptr[5];

	/* remapping the PIC */
	__outbyte(0x20, 0x11);
	__outbyte(0xA0, 0x11);
	__outbyte(0x21, 0x20);
	__outbyte(0xA1, 40);
	__outbyte(0x21, 0x04);
	__outbyte(0xA1, 0x02);
	__outbyte(0x21, 0x01);
	__outbyte(0xA1, 0x01);
	__outbyte(0x21, 0x0);
	__outbyte(0xA1, 0x0);
	irq0_address = (unsigned long long)irq0;
	set_irq_address(irq0_address, 32);

	irq1_address = (unsigned long long)irq1;
	set_irq_address(irq1_address, 33);
	
	irq2_address = (unsigned long long)irq2;
	set_irq_address(irq2_address, 34);
	
	irq3_address = (unsigned long long)irq3;
	set_irq_address(irq3_address, 35);

	irq4_address = (unsigned long long)irq4;
	set_irq_address(irq4_address, 36);

	irq5_address = (unsigned long long)irq5;
	set_irq_address(irq5_address, 37);

	irq6_address = (unsigned long long)irq6;
	set_irq_address(irq6_address, 38);

	irq7_address = (unsigned long long)irq7;
	set_irq_address(irq7_address, 39);

	irq8_address = (unsigned long long)irq8;
	set_irq_address(irq8_address, 40);

	irq9_address = (unsigned long long)irq9;
	set_irq_address(irq9_address, 41);

	irq10_address = (unsigned long long)irq10;
	set_irq_address(irq10_address, 42);

	irq11_address = (unsigned long long)irq11;
	set_irq_address(irq11_address, 43);


	irq12_address = (unsigned long long)irq12;
	set_irq_address(irq12_address, 44);


	irq13_address = (unsigned long long)irq13;
	set_irq_address(irq13_address, 45);


	irq14_address = (unsigned long long)irq14;
	set_irq_address(irq14_address, 46);


	irq15_address = (unsigned long long)irq15;
	set_irq_address(irq15_address, 47);

	/* fill the IDT descriptor */
	idt_address = (unsigned long long)IDT;
	idt_ptr[0] = (sizeof(struct IDT_entry) * 256);

	idt_ptr[1] = 0xFFFF & idt_address;
	idt_ptr[2] = (unsigned short)((((unsigned long long)0xFFFF << 16)& idt_address) >> 16);
    idt_ptr[3] = (unsigned short)((((unsigned long long)0xFFFF << 32) & idt_address) >> 32);
	idt_ptr[4] = (unsigned short)((((unsigned long long)0xFFFF << 48) & idt_address) >> 48);

	__lidt(idt_ptr);
}

void IRQ_set_mask(unsigned char IRQline) {
	unsigned short port;
	unsigned char value;

	if (IRQline < 8) {
		port = PIC1_DATA;
	}
	else {
		port = PIC2_DATA;
		IRQline -= 8;
	}
	value = __inbyte(port) | (1 << IRQline);
	__outbyte(port, value);
}

void IRQ_clear_mask(unsigned char IRQline) {
	unsigned short port;
	unsigned char value;

	if (IRQline < 8) {
		port = PIC1_DATA;
	}
	else {
		port = PIC2_DATA;
		IRQline -= 8;
	}
	value = __inbyte(port) & ~(1 << IRQline);
	__outbyte(port, value);
}