            INCLUDE stm32l476xx_constants.s
            
            AREA    myCode, CODE, READONLY
            EXPORT  __main

row4        DCD     0x31, 0x32, 0x33
row3        DCD     0x34, 0x35, 0x36
row2        DCD     0x37, 0x38, 0x39
row1        DCD     0x2A, 0x30, 0x23
			ENTRY
		
rcc_init	PROC
			PUSH{r0,r1}
			LDR	 r0, =RCC_BASE
			LDR  r1, [r0, #RCC_AHB2ENR]
			ORR	 r1, #RCC_AHB2ENR_GPIODEN		;RCC->AHB2ENR   |= RCC_AHB2ENR_GPIODEN;
			ORR	 r1, #RCC_AHB2ENR_GPIOEEN		;RCC->AHB2ENR   |= RCC_AHB2ENR_GPIOEEN;
			ORR	 r1, #RCC_AHB2ENR_GPIOHEN		;RCC->AHB2ENR   |= RCC_AHB2ENR_GPIOHEN;
			STR  r1, [r0, #RCC_AHB2ENR]
			LDR  r1, [r0, #RCC_APB1ENR1]
			ORR	 r1, #RCC_APB1ENR1_USART2EN		;RCC->APB1ENR1  |= RCC_APB1ENR1_USART2EN;
			STR	 r1, [r0, #RCC_APB1ENR1]
			POP	{r0,r1}
			BX   LR
			ENDP

gpio_init	PROC
			PUSH{r0-r2}
            
            ;Set PD5-PD6 as alternate function 0 (USART), high-speed, no PUPD
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

			LDR	 r1, [r0, #GPIO_OTYPER]         ;GPIOD->OTYPER  &= ~(0x1 << 5); (Floating input)
			LDR  r2, =0x01
			BIC	 r1, r2, LSL #5
			LDR	 r2, =0x01                      ;GPIOD->OTYPER  |=   0x1 << 6; 
			ORR	 r1, r2, LSL #6
			STR	 r1, [r0, #GPIO_OTYPER]

			LDR	 r1, [r0, #GPIO_PUPDR]          ;GPIOD->PUPDR   &= ~(0x0F << (2*5));
			LDR  r2, =0x0F
			BIC	 r1, r2, LSL #10
			STR	 r1, [r0, #GPIO_PUPDR]
            
            ;Set PE11-PE14 as output, open-drain, high speed, and with no PUPD
            LDR  r0, =GPIOE_BASE
            LDR	 r1, [r0, #GPIO_MODER]			;GPIOE->MODER   &= ~(0x3FF << (2*10));
			LDR  r2, =0xFF
			BIC	 r1, r2, LSL #(2*12)				
			LDR  r2, =0x55                      ;GPIOE->MODER  	|=   0x55 << (2*11);
			ORR	 r1, r2, LSL #(2*12)
			STR	 r1, [r0, #GPIO_MODER]
            
            LDR	 r1, [r0, #GPIO_OSPEEDR]        ;GPIOE->OSPEEDR |=   0xFF << (2*11);
			LDR  r2, =0xFFF
			ORR	 r1, r2, LSL #22
			STR	 r1, [r0, #GPIO_OSPEEDR]

			LDR	 r1, [r0, #GPIO_OTYPER]         ;GPIOE->OTYPER  |=   0x0F << 11; 
			LDR	 r2, =0xF
			ORR	 r1, r2, LSL #12
			STR	 r1, [r0, #GPIO_OTYPER]

			LDR	 r1, [r0, #GPIO_PUPDR]          ;GPIOE->PUPDR   &= ~(0xFF << (2*11));
			LDR  r2, =0xFF
			BIC	 r1, r2, LSL #(2*12)
			STR	 r1, [r0, #GPIO_PUPDR]
            
            ;Set PE10, PH0-PH1 as input with no PUPD
            LDR	 r1, [r0, #GPIO_MODER]			;GPIOE->MODER   &= ~(0x03 << (2*10));
			LDR  r2, =0xF
			BIC	 r1, r2, LSL #(2*10)				
			STR	 r1, [r0, #GPIO_MODER]

			LDR	 r1, [r0, #GPIO_PUPDR]          ;GPIOE->PUPDR   &= ~(0x03 << (2*10));
			LDR  r2, =0xF
			BIC	 r1, r2, LSL #20
			LDR	 r2, =0x5
			ORR	 r1, r2, LSL #20
			STR	 r1, [r0, #GPIO_PUPDR]
            
            LDR  r0, =GPIOH_BASE
            LDR	 r1, [r0, #GPIO_MODER]			;GPIOH->MODER   &= ~(0x03 << (2*0));
			LDR  r2, =0xF
			BIC	 r1, r2				
			STR	 r1, [r0, #GPIO_MODER]

			LDR	 r1, [r0, #GPIO_PUPDR]          ;GPIOH->PUPDR   &= ~(0x03 << (2*0));
			LDR  r2, =0xF
			BIC	 r1, r2
			LDR	 r2, =0x5
			ORR	 r1, r2
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
                
DELAY 		PROC 
			PUSH{r1,LR}
			LDR  r1, =0x6000                    ;Initial value for loop counter
againx 		NOP  		                        ;Execute two no-operation instructions
			NOP
			SUBS r1, #1
			BNE  againx
			POP {r1,PC}
			ENDP
                
col_check   PROC
			push{lr}
            ;PUSH{r0,r1,r2,r4,LR}
            
            LDR  r0, =GPIOE_BASE
            ;LDR  r1, [r0, #GPIO_ODR]
            ;LDR  r2, =0xF
            ;BIC  r1, r2, LSL #11
            ;STR  r1, [r0, #GPIO_ODR]

            LDR  r1, [r0, #GPIO_IDR]            ;Checks input column 3 to see if it is not 1
            LDR  r2, =0x1
            TST  r1, r2, LSL #10
            BEQ  col_found3
            
            LDR  r0, =GPIOH_BASE                ;Checks input column 1 to see if it is not 1
            LDR  r1, [r0, #GPIO_IDR]
            LDR  r2, =0x1
            TST  r1, r2, LSL #0
            BEQ  col_found1
            
            LDR  r2, =0x1                       ;Checks input column 2 to see if it is not 1
            TST  r1, r2, LSL #1
            BEQ  col_found2
            
            ;POP {r0,r1,r2,r4}
            LDR  r3, =0x0
			
			pop {lr}
			bx lr
            ;POP {PC}
            
col_found1  BL   DELAY
            ;POP {r0,r1,r2,r4}
            LDR  r3, =0x1
            POP {lr}
            bx lr
			
col_found2  BL   DELAY
            ;POP {r0,r1,r2,r4}
            LDR  r3, =0x2
            POP {lr}
			bx lr
            
col_found3  BL   DELAY
            ;POP {r0,r1,r2,r4}
            LDR  r3, =0x3
            POP {lr}
            bx lr
			ENDP
                
keypd_check PROC
			push{lr}
            ;PUSH{r0,r1,r2,r3,LR}
            
            LDR  r0, =GPIOE_BASE                ;Checks row 1 and ends if/which column input is equal to 0
            ;LDR  r1, [r0, #GPIO_ODR]                  ;If all column inputs are 1, continue
			LDR  r1, [r0, #GPIO_ODR]
            LDR  r2, =0xF
            BIC  r1, r2, LSL #12
            LDR  r2, =0xE
            ORR  r1, r2, LSL #12
            STR  r1, [R0, #GPIO_ODR]
            LDR  r4, =0x1
            BL   col_check
            CMP  r3, #0x0
            BNE  row_found
            
            LDR  r0, =GPIOE_BASE
            LDR  r1, [r0, #GPIO_ODR]                  ;Checks row 2 and ends if/which column input is equal to 0
            LDR  r2, =0xF
            BIC  r1, r2, LSL #12
            LDR  r2, =0xD                       ;If all column inputs are 1, continue
            orr  r1, r2, LSL #12
            STR  r1, [r0, #GPIO_ODR]
            LDR  r4, =0x2
            BL   col_check
            CMP  r3, #0x0
            BNE  row_found
            
            LDR  r0, =GPIOE_BASE
            LDR  r1, [r0, #GPIO_ODR]                  ;Checks row 3 and ends if/which column input is equal to 0
            LDR  r2, =0xF
            BIC  r1, r2, LSL #12
            LDR  r2, =0xB                       ;If all column inputs are 1, continue
            orr  r1, r2, LSL #12
            STR  r1, [r0, #GPIO_ODR]
            LDR  r4, =0x3
            BL   col_check
            CMP  r3, #0x0
            BNE  row_found
            
            LDR  r0, =GPIOE_BASE
            LDR  r1, [r0, #GPIO_ODR]                  ;Checks row 4 and ends if/which column input is equal to 0
            LDR  r2, =0xF
            BIC  r1, r2, LSL #12
            LDR  r2, =0x7                       ;If all column inputs are 1, continue
            orr  r1, r2, LSL #12
            STR  r1, [r0, #GPIO_ODR]
            LDR  r4, =0x4
            BL   col_check
            CMP  r3, #0x0
            BNE  row_found
            
            LDR  r4, =0x0
            
row_found   ;POP {r0,r1,r2,r3,LR}
			pop {lr}
			BX LR
            ENDP
				
__main	    PROC
			BL   clock_init                     ;Initializes clock
			BL	 rcc_init                       ;Initializes RCC
			BL   gpio_init                      ;Initializes GPIOD, GPIOE, and GPIOH
			BL	 usart2_init                    ;Initializes USART2
            
loop		BL keypd_check
			
			CMP r4, #1
			BEQ row_1
			
			CMP r4, #2
			BEQ row_2
			
			CMP r4, #3
			BEQ row_3
			
			CMP r4, #4
			BEQ row_4
			
row_1		LDR r5, =row1
			B row_done
row_2		LDR r5, =row2
			B row_done
row_3		LDR r5, =row3
			B row_done
row_4		LDR r5, =row4
			B row_done

row_done	SUB r3, #1
			LDR r2, =4
			MUL r3, r2
			
			LDR r6, [r5, r3]

col_done	
            ;r3 is what holds the value for column,
            ;r4 holds the value for the row
			
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
