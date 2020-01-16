#pragma once
struct IDT_entry {
	unsigned short int offset_lowerbits;
	unsigned short int selector;
	unsigned char zero;
	unsigned char type_attr;
	unsigned short int offset_middlebits;
	unsigned int offset_higherbits;
	unsigned int reserved;
};

void idt_init();
void IRQ_set_mask(unsigned char IRQline);
void IRQ_clear_mask(unsigned char IRQline);