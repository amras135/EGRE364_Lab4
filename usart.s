            INCLUDE stm32l476xx_constants.s
            
            AREA    myData, DATA, READWRITE     ;ASCII for 0-9 is 0x30-0x39, * is 0x2A, # is 0x23
nums        DCB     0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37, 0x38, 0x39, 0x2A, 0x30, 0x23

            ALIGN
            AREA    myCode, CODE, READONLY
            EXPORT  __main
            ENTRY
		
rcc_init	PROC
			PUSH{r0,r1}
            
			LDR	 r0, =RCC_BASE
			LDR  r1, [r0, #RCC_AHB2ENR]
			ORR	 r1, #RCC_AHB2ENR_GPIODEN		;RCC->AHB2ENR   |= RCC_AHB2ENR_GPIODEN;
			STR  r1, [r0, #RCC_AHB2ENR]
            
            LDR  r1, [r0, #RCC_AHB2ENR]
			ORR	 r1, #RCC_AHB2ENR_GPIOHEN		;RCC->AHB2ENR   |= RCC_AHB2ENR_GPIOHEN;
			STR  r1, [r0, #RCC_AHB2ENR]
            
            LDR  r1, [r0, #RCC_AHB2ENR]
			ORR	 r1, #RCC_AHB2ENR_GPIOEEN		;RCC->AHB2ENR   |= RCC_AHB2ENR_GPIOEEN;
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
            LDR	 r1, [r0, #GPIO_MODER]			;GPIOE->MODER   &= ~(0xFF << (2*11));
			LDR  r2, =0xFF
			BIC	 r1, r2, LSL #22				
			LDR  r2, =0x55                      ;GPIOE->MODER  	|=   0x55 << (2*11);
			ORR	 r1, r2, LSL #22
			STR	 r1, [r0, #GPIO_MODER]
            
            LDR	 r1, [r0, #GPIO_OSPEEDR]        ;GPIOE->OSPEEDR |=   0xFF << (2*11);
			LDR  r2, =0xFF
			ORR	 r1, r2, LSL #22
			STR	 r1, [r0, #GPIO_OSPEEDR]

			LDR	 r1, [r0, #GPIO_OTYPER]         ;GPIOE->OTYPER  |=   0x0F << 11; 
			LDR	 r2, =0xF
			ORR	 r1, r2, LSL #11
			STR	 r1, [r0, #GPIO_OTYPER]

			LDR	 r1, [r0, #GPIO_PUPDR]          ;GPIOE->PUPDR   &= ~(0xFF << (2*11));
			LDR  r2, =0xFF
			BIC	 r1, r2, LSL #22
			STR	 r1, [r0, #GPIO_PUPDR]
            
            ;Set PE10, PH0-PH1 as input with no PUPD
            LDR	 r1, [r0, #GPIO_MODER]			;GPIOE->MODER   &= ~(0x03 << (2*10));
			LDR  r2, =0x3
			BIC	 r1, r2, LSL #20				
			STR	 r1, [r0, #GPIO_MODER]

			LDR	 r1, [r0, #GPIO_PUPDR]          ;GPIOE->PUPDR   &= ~(0x03 << (2*10));
			LDR  r2, =0x3
			BIC	 r1, r2, LSL #20
			STR	 r1, [r0, #GPIO_PUPDR]
            
            LDR  r0, =GPIOH_BASE
            LDR	 r1, [r0, #GPIO_MODER]			;GPIOH->MODER   &= ~(0x03 << (2*0));
			LDR  r2, =0x3
			BIC	 r1, r2, LSL #0				
			STR	 r1, [r0, #GPIO_MODER]

			LDR	 r1, [r0, #GPIO_PUPDR]          ;GPIOH->PUPDR   &= ~(0x03 << (2*0));
			LDR  r2, =0x3
			BIC	 r1, r2, LSL #0
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
            PUSH{r0,r1,r2,r4,LR}
            
            LDR  r0, =GPIOE_BASE
            LDR  r1, [r0, #GPIO_IDR]            ;Checks input column 3 to see if it is not 1
            LDR  r2, =0x1
            AND  r1, r2, LSL #10                ;Clears all but the bit we need to look at
            CMP  r1, r2, LSL #10                ;Checks if IDR value at PE10 is a 1
            BNE  col_found3                     ;If it's 0 (it's pulled UP), column 3 is pressed
            
            LDR  r0, =GPIOH_BASE                ;Checks input column 1 to see if it is not 1
            LDR  r1, [r0, #GPIO_IDR]
            LDR  r2, =0x1
            AND  r1, r2, LSL #0                 ;Clears all but the bit we need to look at
            CMP  r1, r2, LSL #0                 ;Checks if IDR value at PH0 is a 1
            BNE  col_found1                     ;If it's 0 (it's pulled UP), column 1 is pressed
            
            LDR  r0, =GPIOH_BASE                ;Checks input column 1 to see if it is not 1
            LDR  r1, [r0, #GPIO_IDR]
            LDR  r2, =0x1                       ;Checks input column 2 to see if it is not 1
            AND  r1, r2, LSL #1                 ;Clears all but the bit we need to look at
            CMP  r1, r2, LSL #1                 ;Checks if IDR value at PH1 is a 1
            BNE  col_found2                     ;If it's 0 (it's pulled UP), column 2 is pressed
            
            POP {r0,r1,r2,r4}
            LDR  r3, =0x0
            POP {PC}
            
col_found1  BL   DELAY
            POP {r0,r1,r2,r4}
            LDR  r3, =0x1
            POP {PC}
            
col_found2  BL   DELAY
            POP {r0,r1,r2,r4}
            LDR  r3, =0x2
            POP {PC}
            
col_found3  BL   DELAY
            POP {r0,r1,r2,r4}
            LDR  r3, =0x3
            POP {PC}
            ENDP
                
keypd_check PROC
            PUSH{r0,r1,r2,LR}
            
            ;Checks if anything was pressed
            LDR  r0, =GPIOE_BASE
            LDR  r1, [r0, #GPIO_ODR]
            LDR  r2, =0x0                       ;Loads b0000
            BIC  r1, r2, LSL #11                ;Shifts by 11 to line up with PE11 (row 1)
            STR  r1, [r0, #GPIO_ODR]
            LDR  r4, =0x0                       ;No  row pressed
            BL   col_check                      ;No  col was found
            CMP  r3, #0x0                       ;Was col pressed
            BEQ  row_found                      ;No  row was found
            
            ;Checks if row 1 was pressed
            LDR  r1, [r0, #GPIO_ODR]
            LDR  r2, =0xE                       ;Loads b1110
            BIC  r1, r2, LSL #11
            STR  r1, [r0, #GPIO_ODR]
            LDR  r4, =0x1                       ;Row 1 was pressed
            BL   col_check                      ;Col X was pressed
            CMP  r3, #0x1                       ;Was X = 1
            BEQ  row_found                      ;If r3 is 0x1, col 1 and row 1 are pressed
            CMP  r3, #0x2                       ;Was X = 2
            BEQ  row_found                      ;If r3 is 0x2, col 2 and row 1 are pressed
            CMP  r3, #0x3                       ;Was X = 3
            BEQ  row_found                      ;If r3 is 0x3, col 3 and row 1 are pressed
            
            ;Checks if row 2 was pressed
            LDR  r1, [r0, #GPIO_ODR]
            LDR  r2, =0xD                       ;Loads b1101
            BIC  r1, r2, LSL #11
            STR  r1, [r0, #GPIO_ODR]
            LDR  r4, =0x2                       ;Row 2 was pressed
            BL   col_check                      ;Col X was pressed
            CMP  r3, #0x1                       ;Was X = 1
            BEQ  row_found                      ;If r3 is 0x1, col 1 and row 2 are pressed
            CMP  r3, #0x2                       ;Was X = 2
            BEQ  row_found                      ;If r3 is 0x2, col 2 and row 2 are pressed
            CMP  r3, #0x3                       ;Was X = 3
            BEQ  row_found                      ;If r3 is 0x3, col 3 and row 2 are pressed
            
            ;Checks if row 3 was pressed
            LDR  r1, [r0, #GPIO_ODR]
            LDR  r2, =0xB                       ;Loads b1011
            BIC  r1, r2, LSL #11
            STR  r1, [r0, #GPIO_ODR]
            LDR  r4, =0x3                       ;Row 3 was pressed
            BL   col_check                      ;Col X was pressed
            CMP  r3, #0x1                       ;Was X = 1
            BEQ  row_found                      ;If r3 is 0x1, col 1 and row 3 are pressed
            CMP  r3, #0x2                       ;Was X = 2
            BEQ  row_found                      ;If r3 is 0x2, col 2 and row 3 are pressed
            CMP  r3, #0x3                       ;Was X = 3
            BEQ  row_found                      ;If r3 is 0x3, col 3 and row 3 are pressed
            
            ;Checks if row 4 was pressed
            LDR  r1, [r0, #GPIO_ODR]
            LDR  r2, =0x7                       ;Loads b0111
            BIC  r1, r2, LSL #11
            STR  r1, [r0, #GPIO_ODR]
            LDR  r4, =0x4                       ;Row 4 was pressed
            BL   col_check                      ;Col X was pressed
            CMP  r3, #0x1                       ;Was X = 1
            BEQ  row_found                      ;If r3 is 0x1, col 1 and row 4 are pressed
            CMP  r3, #0x2                       ;Was X = 2
            BEQ  row_found                      ;If r3 is 0x2, col 2 and row 4 are pressed
            CMP  r3, #0x3                       ;Was X = 3
            BEQ  row_found                      ;If r3 is 0x3, col 3 and row 4 are pressed
            
            LDR  r4, =0x0                       ;Okay just kidding nothing was pressed if we get here
            
row_found   POP {r0,r1,r2,PC}
            ENDP
                
find_number PROC
            PUSH{r0,r1,r2,r3,r4}
            
            MOV  r0, r3                         ;r0 = column #
            MOV  r1, r4                         ;r1 = row #
            
            LDR  r3, =nums
            
            ORR  r0, r1, LSL #4                 ;Concatenates column and row => ex. row 4, column 3 gives 0x34 in hex0000000000000000000000
            
            CMP  r0, #0x11                      ;Sees if Col=1, Row=1
            BEQ  num_1                          ;Sets USART_RDR value to ASCII for 1
            
            CMP  r0, #0x21                      ;Sees if Col=2, Row=1
            BEQ  num_2                          ;Sets USART_RDR value to ASCII for 2
            
            CMP  r0, #0x31                      ;Sees if Col=3, Row=1
            BEQ  num_3                          ;Sets USART_RDR value to ASCII for 3
            
            CMP  r0, #0x12                      ;Sees if Col=1, Row=2
            BEQ  num_4                          ;Sets USART_RDR value to ASCII for 4
            
            CMP  r0, #0x22                      ;Sees if Col=2, Row=2
            BEQ  num_5                          ;Sets USART_RDR value to ASCII for 5
            
            CMP  r0, #0x32                      ;Sees if Col=3, Row=2
            BEQ  num_6                          ;Sets USART_RDR value to ASCII for 6
            
            CMP  r0, #0x13                      ;Sees if Col=1, Row=3
            BEQ  num_7                          ;Sets USART_RDR value to ASCII for 7
            
            CMP  r0, #0x23                      ;Sees if Col=2, Row=3
            BEQ  num_8                          ;Sets USART_RDR value to ASCII for 8
            
            CMP  r0, #0x33                      ;Sees if Col=3, Row=3
            BEQ  num_9                          ;Sets USART_RDR value to ASCII for 9
            
            CMP  r0, #0x24                      ;Sees if Col=2, Row=4
            BEQ  num_0                          ;Sets USART_RDR value to ASCII for 0
            
            CMP  r0, #0x34                      ;Sees if Col=3, Row=4
            BEQ  num_hash                       ;Sets USART_RDR value to ASCII for #
            
            CMP  r0, #0x14                      ;Sees if Col=1, Row=4
            BEQ  num_star                       ;Sets USART_RDR value to ASCII for *

endme       POP {r0,r1,r2,r3,r4}
            BX   LR
            
num_1       LDR  r5, [r3, #0]
            ;LDR  r0, =USART2_BASE
            ;LDR  r1, [r0, #USART_ISR]
            ;ORR  r1, #USART_ISR_RXNE            ;Sets RXNE bit when # is found
            ;STR  r1, [r0, #USART_ISR]
            B    endme
num_2       LDR  r5, [r3, #1]
            ;LDR  r0, =USART2_BASE
            ;LDR  r1, [r0, #USART_ISR]
            ;ORR  r1, #USART_ISR_RXNE            ;Sets RXNE bit when # is found
            ;STR  r1, [r0, #USART_ISR]
            B    endme
num_3       LDR  r5, [r3, #2]
            ;LDR  r0, =USART2_BASE
            ;LDR  r1, [r0, #USART_ISR]
            ;ORR  r1, #USART_ISR_RXNE            ;Sets RXNE bit when # is found
            ;STR  r1, [r0, #USART_ISR]
            B    endme
num_4       LDR  r5, [r3, #3]
            ;LDR  r0, =USART2_BASE
            ;LDR  r1, [r0, #USART_ISR]
            ;ORR  r1, #USART_ISR_RXNE            ;Sets RXNE bit when # is found
            ;STR  r1, [r0, #USART_ISR]
            B    endme
num_5       LDR  r5, [r3, #4]
            ;LDR  r0, =USART2_BASE
            ;LDR  r1, [r0, #USART_ISR]
            ;ORR  r1, #USART_ISR_RXNE            ;Sets RXNE bit when # is found
            ;STR  r1, [r0, #USART_ISR]
            B    endme
num_6       LDR  r5, [r3, #5]
            ;LDR  r0, =USART2_BASE
            ;LDR  r1, [r0, #USART_ISR]
            ;ORR  r1, #USART_ISR_RXNE            ;Sets RXNE bit when # is found
            ;STR  r1, [r0, #USART_ISR]
            B    endme
num_7       LDR  r5, [r3, #6]
            ;LDR  r0, =USART2_BASE
            ;LDR  r1, [r0, #USART_ISR]
            ;ORR  r1, #USART_ISR_RXNE            ;Sets RXNE bit when # is found
            ;STR  r1, [r0, #USART_ISR]
            B    endme
num_8       LDR  r5, [r3, #7]
            ;LDR  r0, =USART2_BASE
            ;LDR  r1, [r0, #USART_ISR]
            ;ORR  r1, #USART_ISR_RXNE            ;Sets RXNE bit when # is found
            ;STR  r1, [r0, #USART_ISR]
            B    endme
num_9       LDR  r5, [r3, #8]
            ;LDR  r0, =USART2_BASE
            ;LDR  r1, [r0, #USART_ISR]
            ;ORR  r1, #USART_ISR_RXNE            ;Sets RXNE bit when # is found
            ;STR  r1, [r0, #USART_ISR]
            B    endme
num_star    LDR  r5, [r3, #9]
            ;LDR  r0, =USART2_BASE
            ;LDR  r1, [r0, #USART_ISR]
            ;ORR  r1, #USART_ISR_RXNE            ;Sets RXNE bit when # is found
            ;STR  r1, [r0, #USART_ISR]
            B    endme
num_0       LDR  r5, [r3, #10]
            ;LDR  r0, =USART2_BASE
            ;LDR  r1, [r0, #USART_ISR]
            ;ORR  r1, #USART_ISR_RXNE            ;Sets RXNE bit when # is found
            ;STR  r1, [r0, #USART_ISR]
            B    endme
num_hash    LDR  r5, [r3, #11]
            ;LDR  r0, =USART2_BASE
            ;LDR  r1, [r0, #USART_ISR]
            ;ORR  r1, #USART_ISR_RXNE            ;Sets RXNE bit when # is found
            ;STR  r1, [r0, #USART_ISR]
            B    endme
            ENDP
				
__main	    PROC                                ;*******TO FIX - figure out how to set RXNE bit because the way i was doing it didnt work (see line 352-421)*******************************
			BL   clock_init                     ;Initializes clock
			BL	 rcc_init                       ;Initializes RCC
			BL   gpio_init                      ;Initializes GPIOD, GPIOE, and GPIOH
			BL	 usart2_init                    ;Initializes USART2
            
            ;r3 is what holds the value for column,
            ;r4 holds the value for the row
            ;r5 is the ASCII value for the number based on r3, r4
			
			LDR	 r0, =USART2_BASE
wait		LDR	 r1, [r0, #USART_ISR]

            BL   keypd_check                    ;Gets row # and column #
            BL   find_number                    ;Determines the # to display from r3 and r4
            
            TST	 r1, #USART_ISR_RXNE            ;Wait until the data is ready: while(!(USARTx->ISR & USART_ISR_RXNE));  
			BEQ	 wait
			LDRH r1, [r0, #USART_RDR]           ;Loads  receive data register value
            LDR  r6, =0xFF
            BIC  r1, r6
            ORR  r1, r5
			STRH r1, [r0, #USART_TDR]           ;Stores receive data register in transmit data register
            
wait2		LDR	 r1, [r0, #USART_ISR]
            TST	 r1, #USART_ISR_TXE	            ;Wait until the data was sent: while(!(USARTx->ISR & USART_ISR_TXE)); 
			BEQ	 wait2
			B	 wait

loop		B	 loop
			ENDP
            ALIGN
			END  
		