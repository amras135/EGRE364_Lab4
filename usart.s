	INCLUDE stm32l476xx_constants.s
	AREA    myCode, CODE, READONLY
	EXPORT  __main
	ENTRY
		
rcc_init	PROC
			PUSH{r0,r1}
			LDR	 r0, =RCC_BASE
			LDR  r1, [r0, #RCC_AHB2ENR]
			ORR	 r1, #RCC_AHB2ENR_GPIODEN		;RCC->AHB2ENR   |= RCC_AHB2ENR_GPIODEN;
			STR  r1, [r0, #RCC_AHB2ENR]
			LDR  r1, [r0, #RCC_APB1ENR1]
			ORR	 r1, #RCC_APB1ENR1_USART2EN		;RCC->APB1ENR1  |= RCC_APB1ENR1_USART2EN;
			STR	 r1, [r0, #RCC_APB1ENR1]
			POP	{r0,r1}
			BX   LR
			ENDP

gpio_init	PROC
			PUSH{r0-r2}
			LDR  r0, =GPIOD_BASE
			LDR	 r1, [r0, #GPIO_MODER]			;GPIOD->MODER   &= ~(0x0F << (2*5));
			LDR  r2, =0x0F
			BIC	 r1, r2, LSL #10				
			LDR  r2, =0x0A                      ;GPIOD->MODER  	|=   0x0A << (2*5);
			ORR	 r1, r2, LSL #10
			STR	 r1, [r0, #GPIO_MODER]
			
			LDR	 r1, [r0, #GPIO_AFR0]
			LDR	 r2, =0x77
			ORR	 r1, r2, LSL #20
			STR	 r1, [r0, #GPIO_AFR0]			;GPIOD->AFR[0] 	|=   0x77 << (4*2);
			
			LDR	 r1, [r0, #GPIO_OSPEEDR]        ;GPIOD->OSPEEDR |=   0x0F << (2*5);
			LDR  r2, =0x0F
			ORR	 r1, r2, LSL #10
			STR	 r1, [r0, #GPIO_OSPEEDR]

			LDR	 r1, [r0, #GPIO_OTYPER]         ;GPIOD->OTYPER  &= ~(0x1 << 5);
			LDR  r2, =0x01
			BIC	 r1, r2, LSL #5
			LDR	 r2, =0x01                      ;GPIOD->OTYPER  |=   0x1 << 6; 
			ORR	 r1, r2, LSL #6
			STR	 r1, [r0, #GPIO_OTYPER]

			LDR	 r1, [r0, #GPIO_PUPDR]          ;GPIOD->PUPDR   &= ~(0x0F << (2*5));
			LDR  r2, =0x0F
			BIC	 r1, r2, LSL #10
			STR	 r1, [r0, #GPIO_PUPDR]
			
			POP {r0-r2}
			
			BX   LR
			ENDP

clock_init	PROC
			PUSH{r0,r1}
			LDR	 r0, =RCC_BASE
			LDR	 r1, [r0, #RCC_CR]
			ORR	 r1, #RCC_CR_MSION				;RCC->CR   |=  RCC_CR_MSION;
			BIC	 r1, #RCC_CFGR_SW				;RCC->CFGR &= ~RCC_CFGR_SW; 
			STR	 r1, [r0, #RCC_CR]					
			
again		LDR	 r1, [r0, #RCC_CR]			    ;while((RCC->CR & RCC_CR_MSIRDY) == 0); 
			TST	 r1, #RCC_CR_MSIRDY
			BEQ	 again
			
			
			BIC	 r1, #RCC_CR_MSIRANGE			;RCC->CR &= ~RCC_CR_MSIRANGE; 
			ORR	 r1, #RCC_CR_MSIRANGE_7			;RCC->CR |=  RCC_CR_MSIRANGE_7;
			ORR	 r1, #RCC_CR_MSIRGSEL
			STR	 r1, [r0, #RCC_CR]
				
again1		LDR	 r1, [r0, #RCC_CR]
			TST	 r1, #RCC_CR_MSIRDY
			BEQ	 again1
				
			POP	{r0,r1}
			BX	 LR
			ENDP
				
usart2_init	PROC
			PUSH {r0,r1,r2}
				
			LDR	 r0, =USART2_BASE
			LDR	 r1, [r0, #USART_CR1]
			BIC	 r1, #USART_CR1_M				;USARTx->CR1 &= ~USART_CR1_M;
			BIC	 r1, #USART_CR1_OVER8		    ;USARTx->CR1 &= ~USART_CR1_OVER8;
			STR	 r1, [r0, #USART_CR1]
				
			LDR	 r1, [r0, #USART_CR2]			;USARTx->CR2 &= ~USART_CR2_STOP;
			BIC	 r1, #USART_CR2_STOP
			STR	 r1, [r0, #USART_CR2]
				
			LDR	 r1, =8000000					;USARTx->BRR = 8000000/9600;
			LDR	 r2, =9600
			UDIV r1, r2
			STR	 r1, [r0, #USART_BRR]
			
			LDR	 r1, [r0, #USART_CR1]
			ORR	 r1, #USART_CR1_UE				;USARTx->CR1 |=  USART_CR1_UE;
			ORR	 r1, #USART_CR1_RE				;USARTx->CR1 |= (USART_CR1_RE | USART_CR1_TE); 
			ORR	 r1, #USART_CR1_TE
			STR	 r1, [r0, #USART_CR1]
			
			POP {r0,r1,r2}
			BX   LR
			ENDP
				
__main	    PROC
			BL  clock_init                      ;Initializes clock
			BL	rcc_init                        ;Initializes RCC
			BL  gpio_init                       ;Initializes GPIOD
			BL	usart2_init                     ;Initializes USART2
			
			LDR	 r0, =USART2_BASE
wait		LDR	 r1, [r0, #USART_ISR]
            TST	 r1, #USART_ISR_RXNE            ;Wait until the data is ready: while(!(USARTx->ISR & USART_ISR_RXNE));  
			BEQ	 wait
			LDRH r1, [r0, #USART_RDR]
			STRH r1, [r0, #USART_TDR]
wait2		LDR	 r1, [r0, #USART_ISR]
            TST	 r1, #USART_ISR_TXE	            ;Wait until the data was sent: while(!(USARTx->ISR & USART_ISR_TXE)); 
			BEQ	 wait2
			B	 wait
			

loop		B	 loop
			ENDP
			END  
		