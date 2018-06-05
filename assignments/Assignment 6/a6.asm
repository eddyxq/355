buffer_s = 16
buffer_size = 8
alloc = -(16 + buffer_size) & -16
dealloc = -alloc
AT_FDCWD = -100

//Define register aliases
term		.req d21
x		.req d22
total		.req d23
a       	.req d24
base		.req d25
i  		.req d26
temp		.req d28
fp		.req x29
lr		.req x30

min:		.double 0r1.0e-13
numzero:	.double 0r0.0
numone:		.double 0r1.0

//Macros
define(fd_reg, w19)
define(nread_reg, w20)
define(buffer_base_reg, x21)

			.text
path: 		.string "input.bin"
error_msg: 	.string "Error opening file:%s. Program aborted. "
fmt1: 		.string "%.10f\t%.10f\n"
fmt2:		.string "x\t\tln(x)\n"

	.global main						// make main visible to OS
	.balign 4						// ensures instructions are properly aligned
main:
 	stp fp, lr, [sp, alloc]!				// save FP and LR to stack, pre-increment sp
	mov fp, sp						// update FP to current SP

	ldr	x0, =fmt2					// load format string
	bl	printf						// call printf

//Open the binary file
	mov w0, AT_FDCWD					// 1st arg (cwd)
	adrp x1, path						// 2nd arg (pathname)
	add x1, x1, :lo12: path
	mov w2, 0						// 3rd arg (read-only)
	mov w3, 0						// 4th arg (not used)
	mov x8, 56						// openat I/O request - to open a file
	svc 0							// Call system function
	mov fd_reg, w0						// Record FD
	cmp fd_reg, 0						// Check if File Descriptor = -1 (error occured)
	b.ge open_works						// If no error branch over

// Else print the error message
	adrp x0, error_msg					// Set 1st arg (high order bits)
 	add x0, x0, :lo12:error_msg				// Set 1st arg (lower 12 bits)
 	adrp x1, path						// Set 2nd arg (high order bits)
  	add x1, x1, :lo12:path					// Set 2nd arg (lower 12 bits)
	bl printf						// call printf
	mov w0, -1 						// Return -1 and exit the program
	b exit							// go to exit

open_works:
	add buffer_base_reg, x29, buffer_s			// Calculate base address

//Read the binary file
top:
    	mov w0, fd_reg						// 1st arg (fd)
    	mov x1, buffer_base_reg					// 2nd arg (buffer)
	mov w2, buffer_size					// 3rd arg (n) - how many bytes to read from buffer each time
	mov x8, 63						// read I/O request
	svc 0							// Call system function

	mov nread_reg, w0					// Record number of bytes actually read
	cmp nread_reg, buffer_size				// If nread != buffersize
	b.ne end						// then read failed, so exit loop

//calculate ln(x)
	ldr 	d0, [buffer_base_reg]				// load d0
	bl 	calculate					// call calculate
	fmov    d1, d0        					// set 3rd arg for printing
	
//Print the long ints
	adrp x0, fmt1						// Set 1st arg (high order bits)
    	add x0, x0, :lo12:fmt1					// Set 1st arg (lower 12 bits)
    	ldr d0, [buffer_base_reg] 				// 2nd arg (load string from buffer)

	bl printf						// call printf
	b top							// go to top

end:	
// Close the text file
	mov w0, fd_reg						// 1st arg (fd)
	mov x8, 57						// close I/O request
	svc 0							// Call system function

	mov w0, 0						// w0 = 0
exit:
	ldp fp, lr, [sp], dealloc				// restore FP and LR from stack, post-increment SP
	ret							// return to OS

calculate:
	stp 	x29, x30, [sp, -16]!                            // save fp and lr to stack, pre-increment sp
    	mov 	x29, sp                                         // update fp to current sp
	
	ldr 	x22, =min					// load min
	ldr 	d3, [x22]					// d3 = min
	ldr 	x23, =numone					// load immediate 1
	ldr 	d4, [x23]					// d4 = 1
	ldr	x24, =numzero					// load immediate 0
	ldr 	d5, [x24]					// d3 = 0

	fmov	x, d0						// x = parameter passed in
	fmov	i, d4						// i = 1
	fmov 	total, d5					// total = 0
	fsub	a, x, d4					// a = x - 1
	fdiv	a, a, x						// a = (x-1) / x
	fadd 	total, total, a					// total += a
	fmov	term, a						// term = a
	fmov	base, a

loop:
	fadd	i, i, d4					// i += 1
	fmul	temp, a, base					// temp = a * base
	fmov	base, temp					// base = temp
	fdiv 	term, temp, i					// term = temp / i
	fadd 	total, total, term				// total += term
	fabs 	term, term					// term = |term|
	fcmp	term, d3					// if term > min
	b.ge	loop						// go to loop
	
	fmov	d0, total					// return total
    	ldp 	x29, x30, [sp], 16                              // restore fp and lr from stack, post-increment sp
    	ret                                                     // return to main	

