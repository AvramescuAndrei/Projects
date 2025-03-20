#ifndef __USART__
#define __USART__
#include <inavr.h>
#include <iom16.h>
#define F_OSC 4000000
#define BAUD 19200
#define BAUD_RATE (F_OSC/16/BAUD - 1) /*rata de baud=number of signal
elements/total time (in seconds)(cu cat este mai mare, cu atat data se
transmite mai repede*/
void USART_initialize(unsigned short int baud_rate);
void USART_transmit(unsigned char data);
unsigned char USART_Receive( void );
void myprint(unsigned int tip, unsigned int nr_car, void * val);
void integerTransmit (unsigned int p1, unsigned int p2, void * p3);
void hexadecimalTransmit (unsigned int p1, unsigned int p2, void *p3);
void doubleTransmit(unsigned int p1, unsigned int p2, void * p3);
void floatTransmit(unsigned int p1, unsigned int p2, void * p3);
void characterTransmit (unsigned int p1, unsigned int p2, void *p3);
//#pragma vector = USART_RXC_vect
//__interrupt void interrupt_routine_USART_RXC(void);
#endif
