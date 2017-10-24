#include "stm32l476xx.h"
#include "SysTimer.h"

#define FCK 			64000000
#define BAUDRATE	115200

void GPIO_USART_Init(void) { //Initializing GPIO pins (using modified code given in lab description)
	RCC->AHB2ENR   |=   RCC_AHB2ENR_GPIODEN | RCC_AHB2ENR_GPIOAEN;
	
	RCC->APB2ENR	 |=   RCC_APB2ENR_USART1EN;//Enable USART
	RCC->CCIPR 		 &= ~(RCC_CCIPR_USART1SEL);
	RCC->CCIPR 		 |=  (RCC_CCIPR_USART1SEL_0);
	
	USART1->BRR 		=  (int) FCK / BAUDRATE;//Sets the baud rate to ~115200
	USART1->CR1 	 |=  (USART_CR1_TE | USART_CR1_RE);
	USART1->CR1		 |=   USART_CR1_UE;				//Enable USART TX and RX
	
	GPIOD->MODER   &= ~(0x0F << (2*5)); 		//Clear bits for PD5, PD6
	GPIOD->MODER   |=   0x0A << (2*5); 			//Alt Func (10)
	//GPIOD->AFR[0] for PIN.0 - PIN.7
	//GPIOD->AFR[1] for PIN.8 - PIN.15
	GPIOD->AFR[0]  |=   0x77 << (4*5); 			//AF7(USART1..3)
	GPIOD->OSPEEDR |=   0x0F << (2*5); 			//40 MHz (11)
	GPIOD->OTYPER  &= ~(0x1 << 5); 					//TX pin (PD5) should be set up as a push-pull output
	GPIOD->OTYPER  |=   0x1 << 6; 					//RX pin (PD6) is a floating input
	GPIOD->PUPDR   &= ~(0x0F << (2*5)); 		//No pull-up/pull-down
}

void System_Clock_Init(void) { //Pulls clock high (high speed)
	RCC->CR |= RCC_CR_MSION; 
	RCC->CFGR &= ~RCC_CFGR_SW; 
	while ((RCC->CR & RCC_CR_MSIRDY) == 0); 	
	RCC->CR &= ~RCC_CR_MSIRANGE; 
	RCC->CR |= RCC_CR_MSIRANGE_7;
	RCC->CR |= RCC_CR_MSIRGSEL; 
	while ((RCC->CR & RCC_CR_MSIRDY) == 0); 		
}

void Read(USART_TypeDef *USARTx, uint8_t *buffer, uint32_t bytes) { //Reads in received data (from book)
	int i;
	for(i = 0; i < bytes; i++) {
		while(!(USARTx->ISR & USART_ISR_RXNE));	//Waits until hardware sets RXNE (Receive register not empty flag)
		buffer[i] = USARTx->RDR;								//ISR is Status register
	}
}

void Write(USART_TypeDef *USARTx, uint8_t *buffer, uint32_t bytes) { //Writes out sent data (from book)
	int i;
	for(i = 0; i < bytes; i++) {
		while(!(USARTx->ISR & USART_ISR_TXE));//Wait until hardware sets TXE (Transmission data register empty flag)
		USARTx->TDR = buffer[i] & 0xFF;
	}
	while(!(USARTx->ISR & USART_ISR_TC)); 	//Wait until hardware sets TC (Transmission complete)
	USARTx->ICR |= USART_ICR_TCCF; 					//Sets 1 to TCCF (Transmission complete clear flag) to clear TC bit in ISR
}

int main(void) {
	uint8_t buffer; 			//USART buffer
	GPIO_USART_Init();
	System_Clock_Init();
	while(1) {
		GPIOD->ODR = 'C' << 5;
		buffer = GPIOD->ODR;
		Read (USART1, &buffer, 1);
		Write(USART1, &buffer, 1);
	}
}
