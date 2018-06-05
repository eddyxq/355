//This program implements nested structs
fmta: .string "Initial cuboid values:\n"			//creates a format string
fmtb: .string "Changed cuboid values:\n"			//creates a format string
fmt1: .string "Cuboid %s origin = (%d, %d)\n" 			//creates a format string
fmt2: .string "\tBase width = %d Base length = %d\n"		//creates a format string
fmt3: .string "\tHeight = %d\n"					//creates a format string
fmt4: .string "\tVolume = %d\n"					//creates a format string
fmtfirst: .string "first"					//creates a format string
fmtsecond: .string "second"					//creates a format string

define(result_r, x27)						//defines a macro for result
define(width_r, x26)						//defines a macro for width
define(length_r, x25)						//defines a macro for length	
define(height_r, x24)						//defines a macro for height
define(volume_r, x23)						//defines a macro for volume
define(c_base_r, x15)						//defines a macro for cuboid base
define(result, x5)						//defines a macro for cuboid base

first_size = 24							//equate for size of first cuboid		
second_size = 24						//equate for size of second cuboid
total_size = first_size + second_size				//size of both cuboids
alloc = -(16 + total_size) & -16				//calculate memory needed
dealloc = -alloc						//calculate memory needed
first_s = 16							//offset for first cuboid
second_s = 40							//offset for second cuboid
	
point_x = 0							//offset for point_x
point_y = 4							//offset for point_y
dimension_width = 0						//offset for width
dimension_length = 4						//offset for length
origin = 0							//offset for origin
base = 8							//offset for base
height = 16							//offset for height
volume = 20							//offset for volume
origin_size = 8							//size of origin
base_size = 8							//size of base
height_size = 4							//size of height
volume_size = 4							//size of volume

c_size = origin_size + base_size + height_size + volume_size	//size of cuboid
c_alloc = -(16 + c_size) & -16					//calculate memory needed
c_dealloc = -c_alloc						//calculate memory needed
c_s = 16

.global main							//make main visible to OS
.balign 4							//ensures instructions are properly aligned

fp .req x29							//define register alias
lr .req x30							//define register alias

scale:
	stp	fp, lr, [sp, -16]!				//save fp and lr to stack, pre-increment sp
	mov 	fp, sp						//update FP to current SP
	
	mov	x9, x0						//move second cuboid into x9
	mov 	w10, w1						//move factor into w10

	ldr	w11, [x9, base + dimension_width]		//get current width
	ldr	w12, [x9, base + dimension_length]		//get current length
	ldr	w13, [x9, height]				//get current height
	ldr	w14, [x9, volume]				//get current volume

	mul	w11, w11, w10					//width*=factor
	mul	w12, w12, w10					//length*=factor
	mul 	w13, w13, w10					//height*=factor
	mul	w14, w11, w12					//volume*=factor
	mul	w14, w14, w13					//volume*=factor
	

	str	w11, [x9, base + dimension_width]		//set new width
	str	w12, [x9, base + dimension_length]		//set new length
	str	w13, [x9, height]				//set new height
	str	w14, [x9, volume]				//set new volume

	ldp	fp, lr, [sp], 16				//restore FP and LR from stack, post-increment SP
	ret							//return to main

move:
	stp	fp, lr, [sp, -16]!				//save fp and lr to stack, pre-increment sp
	mov 	fp, sp						//update FP to current SP
	
	mov 	x9, x0						//move first cuboid into x9	
	mov	w10, w1						//move x factor into w10
	mov	w11, w2						//move y factor into w11

	ldr	w12, [x9, origin + point_x]			//get current x
	ldr	w13, [x9, origin + point_y]			//get current y

	add	w12, w12, w10 					//x+=xFactor
	add	w13, w13, w11 					//y+=yFactor

	str 	w12, [x9, origin + point_x]			//set new x
	str 	w13, [x9, origin + point_y]			//set new y

	ldp	fp, lr, [sp], 16				//restore FP and LR from stack, post-increment SP
	ret							//return to main

equalSize:
	TRUE = 1						//set true = 1
	FALSE = 0						//set false = 0

	stp	fp, lr, [sp, -16]!				//save fp and lr to stack, pre-increment sp
	mov 	fp, sp						//update FP to current SP

	mov	x9, x6						//move first cuboid into x9
	mov	x10, x7						//move second cuboid into x10

	ldr	x11, [x9, base + dimension_width]		//get first.base.width
	ldr	x12, [x10, base + dimension_width]		//get second.base.width
	ldr	x13, [x9, base + dimension_length]		//get first.base.length
	ldr	x14, [x10, base + dimension_length]		//get second.base.length
	ldr	x15, [x9, height]				//get first.height
	ldr 	x16, [x10, height]				//get second.height

	mov 	result, FALSE					//result = FALSE

	cmp 	x11, x12					//if(first.base.width == second.base.width)
	b.ne 	endif						//go to endif
	cmp 	x13, x14					//if(first.base.length == second.base.length)
	b.ne 	endif						//go to endif
	cmp	x15, x16					//if(first.height == second.height)
	b.ne	endif						//go to endif

	mov	result, TRUE					//result = TRUE
	b	endif						//go to endif

endif:
	ldp	fp, lr, [sp], 16				//restore FP and LR from stack, post-increment SP
	ret							//return to main

printCuboid:
	stp	fp, lr, [sp, -16]!				//save fp and lr to stack, pre-increment sp
	mov 	fp, sp						//update FP to current SP

	mov	x19, x0						//move the string into x19
	mov	x20, x1						//move the cuboid into x20
	
	ldr	x0, =fmt1					//set string to 1st argument
	mov	x1, x19						//set string to 2nd argument
	ldr	x2, [x20, origin + point_x]			//get c.origin.x
	ldr	x3, [x20, origin + point_y]			//get c.origin.y
	bl	printf						//call printf
	
	ldr	x0, =fmt2					//set string to 1st argument
	ldr	x1, [x20, base + dimension_width]		//get c.base.width
	ldr	x2, [x20, base + dimension_length]		//get c.base.length
	bl	printf						//call printf
	
	ldr	x0, =fmt3					//set string to 1st argument
	ldr	x1, [x20, height]				//get c.height
	bl	printf						//call printf
	
	ldr	x0, =fmt4					//set string to 1st argument
	ldr	x1, [x20, volume]				//get c.volume
	bl	printf						//call printf

	ldp	fp, lr, [sp], 16				//restore FP and LR from stack, post-increment SP
	ret							//return to main

newCuboid:
	stp	fp, lr, [sp, c_alloc]!				//save fp and lr to stack, pre-increment sp
	mov 	fp, sp						//update FP to current SP

	add	c_base_r, fp, c_s				//calculate cuboid struct base address

	str	xzr, [c_base_r, origin + point_x]		//c.origin.x = 0
	str	xzr, [c_base_r, origin + point_y]		//c.origin.y = 0
	
	mov	width_r, 2					//set width to 2
	str	width_r, [c_base_r, base + dimension_width]	//c.base.width = 2
	
	mov	length_r, 2					//set length to 2
	str	length_r, [c_base_r, base + dimension_length]	//c.base.length = 2
	
	mov	height_r, 3					//set height to 3
	str	height_r, [c_base_r, height]			//c.height = 3
	
	mul	x28, width_r, length_r				//volume = width * length
	mul	x28, x28, height_r				//volume = width * length * height
	str	x28, [c_base_r, volume]				//c.volume = volume
	
	ldr	x10, [c_base_r, origin + point_x]		//get c.origin.x
	str	x10, [x8, origin + point_x]			//set c.origin.x

	ldr	x10, [c_base_r, origin + point_y]		//get c.origin.y
	str	x10, [x8, origin + point_y]			//set c.origin.y

	ldr	x10, [c_base_r, base + dimension_width]		//get c.base.width
	str	x10, [x8, base + dimension_width]		//set c.base.width

	ldr	x10, [c_base_r, base + dimension_length]	//get c.base.length
	str	x10, [x8, base + dimension_length]		//set c.base.length

	ldr	x10, [c_base_r, height]				//get c.height
	str	x10, [x8, height]				//set c.height
		
	ldr	x10, [c_base_r, volume]				//get c.volume
	str	x10, [x8, volume]				//set c.volume

	ldp	fp, lr, [sp], c_dealloc				//restore FP and LR from stack, post-increment SP
	ret							//return to main

main:
	stp	fp, lr, [sp, alloc]!				//save fp and lr to stack, pre-increment sp
	mov	fp, sp						//update FP to current SP

	add	x8, fp, first_s					//get address of first cuboid
	bl	newCuboid					//call newCuboid()
	
	add	x8, fp, second_s				//get address of second cuboid
	bl 	newCuboid					//call newCuboid()

	ldr	x0, =fmta					//printf ("Initial cuboid values:\n")
	bl	printf						//call printf
	
	ldr	x0, =fmtfirst					//set string to 1st argument
	add	x1, fp, first_s					//set first cuboid to 2nd argument
	bl	printCuboid					//call printCuboid()	
	
	ldr	x0, =fmtsecond					//set string to 1st argument
	add	x1, fp, second_s				//set second cuboid to 2nd argument
	bl	printCuboid					//call printCuboid()
		
	add	x6, fp, first_s					//calculate address of first
	add	x7, fp, second_s				//calculate address of second
	bl	equalSize					//call equalSize()
	mov 	result_r, result				//store return result

if:
	cmp 	result_r, TRUE					//if(equalSize())
	b.ne	next						//skip to next

	add	x0, fp, first_s					//store address of first cuboid
	mov	w1, 3						//store x factor 
	mov	w2, -6						//store y factor
	bl	move						//call move()
		
	add 	x0, fp, second_s				//store address of second cuboid
	mov 	w1, 4						//store scale factor
	bl	scale						//call scale()

next:
	ldr 	x0, =fmtb					//printf("\nChanged cuboid values:\n")
	bl	printf						//call printf
	
	ldr	x0, =fmtfirst					//set string as 1st argument
	add	x1, fp, first_s					//set first cuboid as 2nd argument
	bl	printCuboid					//call printCuboid()
	
	ldr	x0, =fmtsecond					//set string as 1st argument
	add	x1, fp, second_s				//set second cuboid 2nd argument
	bl	printCuboid					//call printCuboid()

exit:							
	mov	w0, 0 						//set up return value of 0 from main
	ldp	fp, lr, [sp], 16  				//restore FP and LR from stack, post-increment SP
	ret							//return to OS

