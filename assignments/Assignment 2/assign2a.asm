//This program multiplies two integers
fmt1: .string "multiplier = 0x%08x (%d) multiplicand = 0x%08 (%d)\n\n" 	//creates a format string
fmt2: .string "product = 0x%08x multiplier = 0x%08x\n"			//creates a format string	
fmt3: .string "64-bit result = 0x%0161x (%ld)\n"			//creates a format string

define(multiplicand, w19)					//defines a macro for multiplicand
define(multiplier, w20)						//defines a macro for multiplier
define(product, w21)						//defines a macro for product
define(i, w22)							//defines a macro for loop counter i
define(boolean, w23)						//defines a macro for boolean flag
define(temp1, x24)						//defines a macro for temp1 variable
define(temp2, x25)						//defines a macro for temp2 variable
define(result, x26)						//defines a macro for final result

.global main							//make main visible to IS
.balign 4							//ensures instructions are properly aligned

fp .req x29							//define register alias
lr .req x30							//define register alias

main:
	stp	fp, lr, [sp, -16]!				//save fp and lr to stack, pre-increment sp
	mov	fp, sp						//update FP to current SP

	mov	multiplicand, -16384				//initialize multiplicand
	mov	multiplier, 47					//initialize multiplier
	mov	product, 0					//initialize product
	mov	i, 0						//initialize loop counter
	mov	boolean, 0					//initialize variable

print_initial_var:
	ldr	x0, =fmt1					//set string to 1st argument
	mov	w1, multiplier					//set multiplier to 2nd argument
	mov	w2, multiplier					//set multiplier to 3rd argument
	mov	w3, multiplicand				//set multiplicand to 4th argument
	mov	w4, multiplicand				//set multiplicand to 5th argument
	bl	printf						//call printf
	
test_multiplier:
	cmp	multiplier, 0					//if multiplier < 0
	b.gt	set_negative					//go to set_negative
	mov	boolean, 0					//else set boolean to false
	b	test						//go to test

set_negative:
	mov	boolean, 1					//set boolean to true
	b	test						//go to test

loop:
	tst	multiplier, 0x1					//compare multiplier with immediate 1
	b.eq	next1						//go to next1
	add	product, product, multiplicand			//product += multiplicand
	
next1:
	asr	multiplier, multiplier, 1			//multiplier >>= 1
	tst	product, 0x1					//if product & 0x1
	b.eq	else						//go to else
	orr	multiplier, multiplier, 0x80000000		//multiplier = multiplier | 0x80000000
	b	next2						//go to next2
	
else:
	and	multiplier, multiplier, 0x7FFFFFFF		//multiplier = multiplier & 0x7FFFFFFF

next2:
	asr	product, product, 1				//product >>= 1

update:
	add	i, i, 1						//i+=1, update loop counter
	
test:
	cmp	i, 32						//if i < 32
	b.lt	loop						//go to loop

next3:
	cmp	boolean, 0					//if negative
	b.ne	print_product_and_multiplier			//go to print_product_and_multiplier
	sub	product, product, multiplicand			//product -= multiplicand

print_product_and_multiplier:
	ldr	x0, =fmt2					//set string to 1st argument
	mov	w1, product					//set product to 2nd argument
	mov	w2, multiplier					//set multiplier to 3rd argument
	bl	printf						//call printf

cast_and_combine:
	sxtw	temp1, product					//sign extend product and store in temp1
	lsl	temp1, temp1, 32				//temp1 <= 32
	sxtw	temp2, multiplier				//sign extend multiplier and store in temp2
	and 	temp2, temp2, 0xFFFFFFFF			//temp2 = multiplier & 0xFFFFFFFFF
	add	result, temp1, temp2				//add temp1 and temp2 to get final result

print_result:
	ldr	x0, =fmt3					//set string to 1st argument			
	mov	x1, result					//set result to 2nd argument
	mov	x2, result					//set result to 3rd argument	
	bl	printf						//call printf

exit:							
	mov	w0, 0 						//set up return value of 0 from main
	ldp	fp, lr, [sp], 16  				//restore FP and LR from stack, post-increment SP
	ret							//return to OS


