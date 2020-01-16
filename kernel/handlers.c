#include "screen.h"

static int timer = 0;

void irq0_handler(void) {
	//pintos function parameters: channel:0 mode: 2 frequency: valoare int(100)
	timer++;
	PutChar('t', timer + 1);
	__outbyte(0x20, 0x20); //EOI
}

void irq1_handler(void) {
	char scanCode = __inbyte(0x60);
	PutChar(scanCode, 0);
	switch (scanCode)
	{
	case 0xA0:
		PutString("D", 0);
		break;
	case 0x20:
		PutString("D", 0);
	default:
	//	PutString("Default", 0);
		break;
	}
	//HelloBoot();
	__outbyte(0x20, 0x20); //EOI
}

void irq2_handler(void) {
	__outbyte(0x20, 0x20); //EOI
}

void irq3_handler(void) {
	__outbyte(0x20, 0x20); //EOI
}

void irq4_handler(void) {
	__outbyte(0x20, 0x20); //EOI
}

void irq5_handler(void) {
	__outbyte(0x20, 0x20); //EOI
}

void irq6_handler(void) {
	__outbyte(0x20, 0x20); //EOI
}

void irq7_handler(void) {
	__outbyte(0x20, 0x20); //EOI
}

void irq8_handler(void) {
	__outbyte(0xA0, 0x20);
	__outbyte(0x20, 0x20); //EOI          
}

void irq9_handler(void) {
	__outbyte(0xA0, 0x20);
	__outbyte(0x20, 0x20); //EOI
}

void irq10_handler(void) {
	__outbyte(0xA0, 0x20);
	__outbyte(0x20, 0x20); //EOI
}

void irq11_handler(void) {
	__outbyte(0xA0, 0x20);
	__outbyte(0x20, 0x20); //EOI
}

void irq12_handler(void) {
	__outbyte(0xA0, 0x20);
	__outbyte(0x20, 0x20); //EOI
}

void irq13_handler(void) {
	__outbyte(0xA0, 0x20);
	__outbyte(0x20, 0x20); //EOI
}

void irq14_handler(void) {
	__outbyte(0xA0, 0x20);
	__outbyte(0x20, 0x20); //EOI
}

void irq15_handler(void) {
	__outbyte(0xA0, 0x20);
	__outbyte(0x20, 0x20); //EOI
}


