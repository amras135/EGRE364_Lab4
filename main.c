#include "stm32l476xx.h"
#include "SysTimer.h"

#define FCK 			64000000
#define BAUDRATE	115200

void GPIO_USART_Init(void) { //Initializing GPIO pins (using modified code given in lab description)
	RCC->AHB2ENR   |=   RCC_AHB2ENR_GPIODEN | RCC_AHB2ENR_GPIOAEN;
	
	RCC->APB2ENR	 |=   RCC_APB2ENR_USART1EN;
	RCC->CCIPR 		 &= ~(RCC_CCIPR_USART1SEL);
	RCC->CCIPR 		 |=  (RCC_CCIPR_USART1SEL_0);
	
	USART1->BRR 		=  (int) FCK / BAUDRATE;//Sets the baud rate to 115200
	USART1->CR1 	 |=  (USART_CR1_TE | USART_CR1_RE);
	USART1->CR1		 |=   USART_CR1_UE;
	
	GPIOD->MODER   &= ~(0x0F << (2*5)); 		//Clear bits for PD5, PD6
	GPIOD->MODER   |=   0x0A << (2*5); 			//Alt Func (10)
	//GPIOD->AFR[0] for PIN.0 - PIN.7
	//GPIOD->AFR[1] for PIN.8 - PIN.15
	GPIOD->AFR[0]  |=   0x77 << (4*5); 			//AF7(USART1..3)
	GPIOD->OSPEEDR |=   0x0F << (2*5); 			//40 MHz (11)
	GPIOD->OTYPER  &= ~(0x1 << 5); 					//TX pin (PA2) should be set up as a push-pull output
	GPIOD->OTYPER  |=   0x1 << 6; 					//RX pin (PA10) is a floating input
	GPIOD->PUPDR   &= ~(0x0F << (2*5)); 		//No pull-up/pull-down	
}

void System_Clock_Init(void){ //Pulls clock high (high speed)
	RCC->CR |= RCC_CR_MSION; 
	RCC->CFGR &= ~RCC_CFGR_SW; 
	while ((RCC->CR & RCC_CR_MSIRDY) == 0); 	
	RCC->CR &= ~RCC_CR_MSIRANGE; 
	RCC->CR |= RCC_CR_MSIRANGE_7;
	RCC->CR |= RCC_CR_MSIRGSEL; 
	while ((RCC->CR & RCC_CR_MSIRDY) == 0); 		
}

int main(void) {
}
