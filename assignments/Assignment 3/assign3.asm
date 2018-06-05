//This program implements a array algorithm

fmt1:	.string "v[%d]: %d\n"			//creates a format string
fmt2:	.string "\nSorted array:\n"		//creates a format string

.balign 4					//ensures instructions are properly aligned
.global main					//make main visible to OS

counter .req w23				//define register alias
base .req x24					//define register alias
vmax .req w25					//define register alias
element .req w26				//define register alias
index .req w27					//define register alias
temp .req w28					//define register alias
fp .req x29					//define register alias
lr .req x30					//define register alias

SIZE = 50					//50 elements
i_size = 4					//size of counter i = 4
j_size = 4					//size of counter i = 4
v_size = 4 * SIZE				//size of all variable of array = 4*50 = 200 bytes
max_size = 4					//size of counter i = 4
temp_size = 4					//size of counter i = 4
						//calculate memory needed for local variable
alloc = -(16 + i_size + j_size + v_size + max_size + temp_size) & -16
dealloc = -alloc

i_s = 16					//define equate
j_s = 20					//define equate
v_s = 32					//define equate
max_s = 24					//define equate
temp_s = 28					//define equate

main:
	stp	fp, lr, [sp, alloc]!		//save fp and lr to stack, pre-increment sp
	mov	fp, sp				//update FP to current SP
	str	wzr, [fp, i_s]			//initialize i to 0
	str	wzr, [fp, j_s]			//initialize j to 0
	str	wzr, [fp, max_s]		//initialize max_s to 0
	str	wzr, [fp, temp_s]		//initialize temp_s to 0

loop1:
	bl	rand				//call rand()
	and	temp, w0, 0x3FF			//rand() & 0x3FF
	ldr	counter, [fp, i_s]		//load index
	add	base, fp, v_s			//get base address
	str	temp, [base, counter, SXTW 2]	//v[i] = rand()

print1:
	ldr	x0, =fmt1			//set string to 1st argument
	ldr	w1, [fp, i_s]			//load current index
	ldr	counter, [fp, i_s]		//set index as 2nd argument
	add	base, fp, v_s			//load element 
	ldr	w2, [base, counter, SXTW 2]	//set element as 3rd argument
	bl	printf				//call printf

update:
	ldr	counter, [fp, i_s]		//load i
	add	counter, counter, 1		//i+=1
	str	counter, [fp, i_s]		//store new i

loop1_test:
	ldr	counter, [fp, i_s]		//load i
	cmp 	counter, SIZE			//if i < SIZE
	b.lt 	loop1				//go to loop1
	str 	wzr, [fp, i_s]			//set i to 0
	b 	outer_loop_test			//go to outer_loop_test

outer_loop:
	ldr 	counter, [fp, i_s]		//load i
	str 	counter, [fp, max_s]		//max = i
	ldr 	index, [fp, i_s]		//load i 
	add 	index, index, 1			//i+=1 
	str 	index, [fp, j_s]		//j = i + 1
	b 	inner_loop_test			//go to inner_loop_test

inner_loop:
	ldr 	counter, [fp, j_s]		//load j
	add 	base, fp, v_s			//get base address
	ldr 	element, [base, counter, SXTW 2]//load v[j]
	ldr 	counter, [fp, max_s]		//load max
	ldr 	vmax, [base, counter, SXTW 2]	//load v[max]
	cmp 	element, vmax			//if v[j] > v[max]
	b.le 	update2				//go to next
	ldr 	counter, [fp, j_s]		//load j
	str 	counter, [fp, max_s]		//max = j
	
update2:
	ldr 	index, [fp, j_s]		//load j
	add 	index, index, 1			//j+=1
	str 	index, [fp, j_s]		//store new j

inner_loop_test:
	ldr 	index, [fp, j_s]		//load j
	cmp 	index, SIZE			//if j < SIZE	
	b.lt 	inner_loop			//go to inner_loop

swap:
	ldr 	counter, [fp, max_s]		//load max
	add 	base, fp, v_s			//get base address
	ldr 	element, [base, counter, SXTW 2]//load v[max]
	str 	element, [fp, temp_s]		//temp = v[max]
	ldr 	counter, [fp, i_s]		//load i
	add 	base, fp, v_s			//get base address
	ldr 	element, [base, counter, SXTW 2]//load v[i]
	ldr 	counter, [fp, max_s]		//load max
	str 	element, [base, counter, SXTW 2]//v[max]= v[i]
	ldr 	counter, [fp, i_s]		//load i
	ldr 	vmax, [fp, temp_s]		//load temp
	add 	base, fp, v_s			//get base address
	str 	vmax, [base, counter, SXTW 2]	//v[i] = temp

update3:
	ldr 	counter, [fp, i_s]		//load i
	add 	counter, counter, 1		//i+=1
	str 	counter, [fp, i_s]		//store new i

outer_loop_test:
	ldr 	counter, [fp, i_s]		//load i
	cmp 	counter, 49			//if i < SIZE - 1
	b.lt 	outer_loop			//go to outer_loop

print2:
	ldr 	x0, =fmt2			//set string to 1st argument
	bl 	printf				//call printf
	str 	wzr, [fp, i_s]			//set i to 0
	b 	loop3_test			//go to loop3_test

loop3:
	ldr 	x0, =fmt1			//set string to 1st argument
	ldr 	w1, [fp, i_s]			//load i
	ldr 	counter, [fp, i_s]		//load i
	add 	base, fp, v_s			//get base address
	ldr 	w2, [base, counter, SXTW 2]	//load v[i] 
	bl 	printf				//call printf

update4:
	ldr 	counter, [fp, i_s]		//load i to counter from memory
	add 	counter, counter, 1		//i+=1
	str 	counter, [fp, i_s]		//store new i

loop3_test:
	ldr 	counter, [fp, i_s]		//load i 
	cmp 	counter, SIZE			//if 1 < SIZE
	b.lt 	loop3				//go to loop3

exit:
	mov 	w0, 0				//set up retunr value of 0 from main
	ldp 	fp, lr, [sp], dealloc		//restore FP and LR from stack, post-increment SP
	ret					//return to OS

