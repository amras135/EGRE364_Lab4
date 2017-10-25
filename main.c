#include "stm32l476xx.h"
#include "SysTimer.h"

#define SYSCLK 			8000000
#define BAUDRATE		9600
#define BUFFERSIZE	32

uint8_t USART1_Buffer_Rx[BUFFERSIZE] = {0xFF};
uint8_t Tx_Counter = 0;
uint8_t Rx_Counter = 0;

void General_Init(void) { 											 /*Initializing GPIO pins (using modified code 
																									 given in lab description/Blackboard) */
	RCC->AHB2ENR   |=   RCC_AHB2ENR_GPIODEN | RCC_AHB2ENR_GPIOAEN;
	RCC->APB1ENR1	 |=   RCC_APB1ENR1_USART2EN;		 //Enable USART
	//RCC->CCIPR 		 &= ~(RCC_CCIPR_USART1SEL);
	//RCC->CCIPR 		 |=  (RCC_CCIPR_USART1SEL_0);
	GPIOD->MODER   &= ~(0x0F << (2*5)); 					 //Clear bits for PD5, PD6
	GPIOD->MODER   |=   0x0A << (2*5); 			 			 //Alt Func (10)
	//GPIOD->AFR[0] for PIN.0 - PIN.7
	//GPIOD->AFR[1] for PIN.8 - PIN.15
	GPIOD->AFR[0]  |=   0x77 << (4*5); 						 //AF7 (USART1..3)
	GPIOD->OSPEEDR |=   0x0F << (2*5); 						 //High speed (11)
	GPIOD->OTYPER  &= ~(0x1 << 5); 								 //TX pin (PD5) set as a push-pull output
	GPIOD->OTYPER  |=   0x1 << 6; 								 //RX pin (PD6) set as a floating input
	GPIOD->PUPDR   &= ~(0x0F << (2*5)); 					 //No pull-up/pull-down (00)
}

void USART_Init(USART_TypeDef *USARTx) {  			 //Shamelessly taken and modified from lecture code
																								 /*Default setting: No hardware flow control, 
																									 8 data bits, no parity, and one stop bit */
	USARTx->BRR    =  SYSCLK/BAUDRATE;						 //BRR = System Frequency/BAUDRATE	
	USARTx->CR1 	&= ~USART_CR1_M;								 //Configure word length to 8 bit
	USARTx->CR1 	&= ~USART_CR1_OVER8;						 //Configure oversampling to x16
	USARTx->CR2 	&= ~USART_CR2_STOP;							 //Configure stop bits to 1 stop bit
	USARTx->CR1  	|=  USART_CR1_UE; 							 //Configure baud rate register for 9600 bps
	USARTx->CR1  	|= (USART_CR1_RE	
								|   USART_CR1_TE);							 //Transmitter and Receiver enable
}

void System_Clock_Init(void) { 									 //Pulls clock high (high speed)
	RCC->CR |= RCC_CR_MSION; 
	RCC->CFGR &= ~RCC_CFGR_SW; 
	while ((RCC->CR & RCC_CR_MSIRDY) == 0); 	
	RCC->CR &= ~RCC_CR_MSIRANGE; 
	RCC->CR |= RCC_CR_MSIRANGE_7;
	RCC->CR |= RCC_CR_MSIRGSEL; 
	while ((RCC->CR & RCC_CR_MSIRDY) == 0); 		
}

uint8_t Read(USART_TypeDef *USARTx) { 					 //Reads in the value from Host PC or external hardware
																								 //SR_RXNE (Read data register not empty) bit is set by hardware
	while (!(USARTx->ISR & USART_ISR_RXNE));			 //Wait until RXNE (RX not empty) bit is set
																								 //USART resets the RXNE flag automatically after reading DR
	return ((uint8_t) (USARTx->RDR & 0x1FF));		 	 //Reading USART_RDR automatically clears the RXNE flag					 
}

void Write(USART_TypeDef *USARTx, uint8_t ch) {  //Writes the value to the Host PC from STM32 registers
	USARTx->TDR = (ch & 0x1FF);
	while (!(USARTx->ISR & USART_ISR_TXE)); 			 //wait until TXE (TX empty) bit is set 
} 

int main(void) {
	General_Init();
	USART_Init(USART2);
	System_Clock_Init();
	while(1) {
		USART1_Buffer_Rx[Tx_Counter] = Read(USART2);
		Write(USART2, USART1_Buffer_Rx[Tx_Counter]);
		Tx_Counter++;
		if(Tx_Counter==BUFFERSIZE)
			Tx_Counter = 0;
	}
}
