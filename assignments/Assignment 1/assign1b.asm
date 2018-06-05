//This program calculates the minimum of y=2x^3+14x^2-3x-9, -7<=x<=5

fmt: .string "x is %d, y is %d, current min is %d\n" 	//creates the format string

define(x_r, x19)				//defines macro for x
define(y_r, x20)				//defines macro for y
define(m_r, x24)				//defines macro for min 
define(a_r, x25)				//defines macro for a coefficient
define(b_r, x26)				//defines macro for a coefficient
define(c_r, x27)				//defines macro for a coefficient
define(d_r, x28)				//defines macro for a coefficient

.global main			    		//make main visible to OS
.balign 4			      		//ensures instructions are properly aligned

fp .req x29					//define register alias
lr .req x30					//define register alias

main:
	stp	fp, lr, [sp, -16]!     		//save FP and LR to stack, pre-increment sp
	mov	fp, sp                		//update FP to current SP

	mov	x_r, -7				//x value
	mov	y_r, 10				//y value
	mov	m_r, 99				//min value
	mov	a_r, 2				//1st coefficient
	mov	b_r, 14				//2nd coefficient
	mov	c_r, -3				//3rd coefficient
	mov	d_r, -9				//4th coefficient

	b	test				//go to test	
	
setmin:
	mov	m_r, y_r 		    	//set new minimum to y
	b	print				//go to print
	
loop:       
	madd	y_r, a_r, x_r, b_r		//y=(2*x)+14		    y=2x+14
	madd	y_r, y_r, x_r, c_r 		//y=((2x+14)*x)+(-3)        y=2x^2+14x-3
	madd	y_r, y_r, x_r, d_r    	 	//y=((2x^2+14x-3)*x)+(-9)   y=2x^3+14x^2-3x-9

	cmp	y_r, m_r                	//if y <= min
	b.le	setmin				//go to setmin

print:
	ldr	x0, =fmt			//set string to 1st argument
	mov	x1, x_r 			//set x to 2nd argument
	mov	x2, y_r  			//set y to 3rd argument
	mov	x3, m_r				//set the current min value to 4th argument

	bl	printf				//call printf
        add	x_r, x_r, 1			//x+=1, increments x by 1         
	
test:
	cmp	x_r, 5				//if x <= 5 
	b.le	loop  				//go to loop 	
		
exit:						//set address of string to be printed
	mov	w0, 0 				//set up return value of 0 from main
	ldp	fp, lr, [sp], 16 	   	//restore FP and LR from stack, post-increment SP
	ret                       		//return to OS
