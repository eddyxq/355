//This program calculates the minimum of y=2x^3+14x^2-3x-9, -7<=x<=5

fmt: .string "x is %d, y is %d, current min is %d\n" 	//creates the format string

.global main			 	   	//make main visible to OS
.balign 4				        //ensures instructions are properly aligned

fp .req x29						//define register alias
lr .req x30						//define register alias

main:
	stp	 fp, lr, [sp, -16]! 	//save FP and LR to stack, pre-increment sp
	mov	 fp, sp                	//update FP to current SP

	mov	x19, -7					//x value
	mov	x20, 10					//y value
	mov	x24, 99					//holds the min value
	mov	x25, 14					//coefficient
	mov	x26, -3					//coefficient
	mov	x27, -9					//coefficient

test:
	cmp	x19, 5					//if x > 5 
	b.gt	exit  				//go to exit 

loop:
	mul	x21, x19, x19			//z=x*x					z=x^2
	mul	x21, x21, x19			//z=x^2*x				z=x^3
	add	x21, x21, x21			//z=x^3+x^3				z=2x^3	
	mul	x22, x19, x19			//w=x*x					w=x^2
	mul	x22, x25, x22			//w=14*x^2				w=14x^2
	mul	x23, x26, x19			//v=-3*x				v=-3x
	add	x20, x21, x22			//y=2x^3+14x^2
	add	x20, x20, x23			//y=2x^3+14x^2-3x
	add	x20, x20, x27			//y=2x^3-14x^2-3x-9

	cmp	x20, x24	            //if y > minimum
	b.gt	else				//go to else
	mov	x24, x20 				//new minimum = y

else:							//do nothing
	
print:
	ldr	x0, =fmt				//set string as 1st argument
	mov	x1, x19					//set x variable to 2nd argument
	mov	x2, x20  				//set y variable to 3rd argument
	mov	x3, x24					//set the minimum variable to 4th argument
	bl	printf					//call printf

	add	x19, x19, 1				//x+=1, increments x by 1 
	b	test					//go to test

exit:							//set address of string to be printed
	mov	w0, 0 					//set up return value of 0 from main
	ldp	fp, lr, [sp], 16  		//restore FP and LR from stack, post-increment SP
	ret                       	//return to OS
