fmt1: .string "\nStack overflow. Cannot push value onto stack.\n"	//creates a format string
fmt2: .string "\nStack underflow. Cannot pop an empty stack.\n"		//creates a format string
fmt3: .string "\nEmpty stack\n"						//creates a format string
fmt4: .string "\nCurrent stack contents:\n"				//creates a format string
fmt5: .string "\n   %d"							//creates a format string
fmt6: .string " <-- top of stack"					//creates a format string
fmt7: .string "\n"							//creates a format string

STACKSIZE = 5							//stack size = 5
TRUE = 1                                        		//true = 1
FALSE = 0                                       		//false = 0

alloc = -(16+4) & -16						//calculate memory needed
dealloc = -alloc						//calculate memory needed

define(top, w28)						//defines a macro for top
define(value, w27)						//defines a macro for value
define(i_r, w26)						//defines a macro for i

fp .req x29				         		//define register alias
lr .req x30							//define register alias

	.data
	.global stack
stack:	.skip STACKSIZE * 4

    	.global top                             
top:	.word -1                                

	.text
	.balign 4
	.global push
push:
	stp	fp, lr, [sp, -16]!				//save fp and lr to stack, pre-increment sp
	mov 	fp, sp						//update fp to current fp
                             
    	mov 	value, w0	            	                //pass parameter to value register
    	bl 	stackFull                       	        //call stackFull
    	cmp 	x0, TRUE                                	//if(stackFull())
    	b.ne   	next                                		//go to next

    	ldr	x0, =fmt1	                            	//set string to 1st argument
    	bl	printf                                  	//call printf
	b	skipNext					//go to skipNext
    
next:
	ldr	x19, =top					//get address of top
	ldr 	top, [x19]					//load top

	add 	top, top, 1					//++top
	str 	top, [x19]					//store top
	
	ldr	x20, =stack					//get address of stack
	str 	value, [x20, top, SXTW 2] 			//store value

skipNext:
	ldp	fp, lr, [sp], 16				//restore fp and lr from stack, post-increment sp
	ret							//return to main

	.global stackFull
stackFull:
	stp	fp, lr, [sp, -16]!				//save fp and lr to stack, pre-increment sp
	mov	fp, sp						//update fp to current sp

	ldr	x19, =top					//get address of top
	ldr	top, [x19]					//load top

	cmp	top, STACKSIZE-1				//if(top == STACKSIZE-1)
	b.ne	else						//go to else

	mov 	x0, TRUE					//set return value to true
	b 	skipElse					//go to skipElse

else:
	mov	x0, FALSE					//set return value to false

skipElse:
	ldp	fp, lr, [sp], 16				//restore fp and lr from stack, post-increment sp
	ret							//return to main

	.global pop
pop:
	stp	fp, lr, [sp, -16]!				//save fp and lr to stack, pre-increment sp
	mov	fp, sp						//update fp to current fp

	bl	stackEmpty					//call stackEmpty
	cmp 	w0, TRUE					//if(stackEmpty())
	b.ne	next2						//go to next2

	ldr	x0, =fmt2					//set string to 1st argument
	bl	printf						//call printf
	mov 	x0, -1						//set return value to -1
	b	skipNext2

next2:
	ldr	x19, =top					//get address of top
	ldr	top, [x19]					//load top

	ldr	x20, =stack					//get address of stack
	ldr	value, [x20, top, SXTW 2]			//load stack

	sub 	top, top, 1					//top--
	str 	top, [x19]					//store top
	mov	w0, value					//set return to value

skipNext2:
	ldp	fp, lr, [sp], 16				//restore fp and lr from stack, post-increment sp
	ret							//return to main

	.global stackEmpty
stackEmpty:
	stp	fp, lr, [sp, -16]!				//save fp and lr to stack, pre-increment sp
	mov	fp, sp						//update fp to current sp

	ldr	x19, =top					//get address of top
	ldr	top, [x19]					//load top

	cmp	top, -1						//if(top==-1)
	b.ne	else2						//go to else2

	mov	x0, TRUE					//set return value to true
	b	skipElse2					//go to skipElse2

else2:	
	mov	x0, FALSE					//set return value to false

skipElse2:
	ldp	fp, lr, [sp], 16				//restore fp and lr from stack, post-increment sp
	ret							//return to main

	.global display
display:
	stp	fp, lr, [sp, -16]!				//save fp and lr to stack, pre-increment sp
	mov	fp, sp						//update fp to current sp

	bl	stackEmpty					//call stackEmpty
	cmp	w0, TRUE					//if(stackEmpty())
	b.ne	print						//go to print
			
	ldr	x0, =fmt3					//set string as 1st argument
	bl 	printf						//call printf
	b	exit						//go to exit

print:
	ldr	x0, =fmt4					//set string as 1st argument
	bl 	printf						//call printf

	ldr	x19, =top					//get address of top
	ldr	top, [x19]					//load top
	mov	i_r, top					//i=top				
	b	test						//go to test

loop:
	ldr	x20, =stack					//get address of stack
	
	ldr	x0, =fmt5					//set string as 1st argument
	ldr 	w1, [x20, i_r, SXTW 2]				//set stack[i] as 2nd argument
	bl	printf						//call printf

	cmp	i_r, top					//if(i==top)		
	b.ne	skipPrinting					//go to skipPrinting
	
	ldr 	x0, =fmt6					//set string as 1st argument
	bl	printf						//call printf
	
skipPrinting:
	ldr	x0, =fmt7					//set string as 1st argument
	bl 	printf						//call printf

	sub	i_r, i_r, 1					//i-=1

test:
	cmp	i_r, 0						//if i>=0
	b.ge	loop						//go to loop
exit:
	ldp	fp, lr, [sp], 16				//restore fp and lr from stack, post-increment sp
	ret							//return to main

