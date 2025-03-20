#include "usart.h"
void USART_initialize(unsigned short int baud_rate) //lab4
{
 /* seteaza baud rate */
 UBRRH = (unsigned char)(baud_rate >> 8);
 UBRRL = (unsigned char)(baud_rate & 0xFF);
 UCSRB = (1 << RXEN) | (1 << TXEN); /* activeaza transmisia si
 receptia la iesire */
 /* seteaza pinul TXD: iesire */
 DDRD |= (1 << PD1);
 /* seteaza pinul RXD: intrare */
 DDRD &= ~(1 << PD0);
 /* activeaza întreruperea */
 UCSRB |= (1 << RXCIE);
}
void USART_transmit(unsigned char data)
{
 /* asteapta pâna ce se termina de transmis toate datele si dupa trece
 la urmatoarele informatii */
 while (!( UCSRA & (1 << UDRE)))
 {
 TIMSK |= ( 1 << TOIE1 );

 }
 UDR = data;
}
unsigned char USART_Receive( void )
{
 /* Asteapta receptionarea datelor */
 while ( !(UCSRA & (1<<RXC)) )
 {
 ;
 }
 /* Preia si returneaza datele receptionate din buffer */
 return UDR;
}
