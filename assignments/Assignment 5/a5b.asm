define(month_r, w19)				//define macro for month
define(day_r, w20)				//define macro for day
define(season_r, w21)				//define macro for season

fmt1:   .string "%s %d%s is %s\n"               //create format string
fmt2:   .string "usage: a5b mm dd\n" 		//create format string
    
spr:    .string "Spring"			//creates string for a season	
sum:    .string "Summer"			//creates string for a season
fal:    .string "Fall"				//creates string for a season
win:    .string "Winter"			//creates string for a season

jan:    .string "January"			//creates string for a month
feb:    .string "Febuary"			//creates string for a month
mar:    .string "March"				//creates string for a month
apr:    .string "April"				//creates string for a month
may:    .string "May"				//creates string for a month
jun:    .string "June"				//creates string for a month
jul:    .string "July"				//creates string for a month
aug:    .string "August"			//creates string for a month
sep:    .string "September"			//creates string for a month
oct:    .string "October"			//creates string for a month
nov:    .string "November"			//creates string for a month
dec:    .string "December"			//creates string for a month

st:     .string "st"				//creates string for a suffix
nd:     .string "nd"				//creates string for a suffix
rd:     .string "rd"				//creates string for a suffix
th:     .string "th"				//creates string for a suffix

season: .dword  spr, sum, fal, win
months: .dword  jan, feb, mar, apr, may, jun, jul, aug, sep, oct, nov, dec
suffix: .dword  st, nd, rd, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, th, st, nd, rd, th, th, th, th, th, th, th, st

argc_r  .req w27				//define register alias
argv_r  .req x28                            	//define register alias
fp      .req x29				//define register alias
lr      .req x30				//define register alias

	.balign 4                               //ensures instructions are properly aligned
	.global main                            //make main visible to OS
main:                                          
	stp	x29, x30, [sp, -16]!            //save fp and lr to stack, pre-increment sp
	mov     x29, sp                         //update fp to current fp

	mov     argc_r, w0                      //get number of arguments
	mov     argv_r, x1                      //get value of arguments
 
test:
	cmp     argc_r, 3                       //if(argc_r<3)
	b.lt    print                           //go to print

check_month:
	mov	w25, 1				//mov 1 to w25
	ldr     x0, [argv_r, w25, SXTW 3]       //load month
	bl      atoi                            //call atoi
	mov     month_r, w0                     //store month

	cmp     month_r, 1                      //if(month<1)
	b.lt    print                           //go to print
	cmp     month_r, 12                     //if(month>12)
	b.gt    print                           //go to print

check_day:
	mov	w26, 2				//mov 2 to w26
	ldr     x0, [argv_r, w26, SXTW 3]       //load day
	bl      atoi                            //call atoi
	mov     day_r, w0                       //store day
    
	cmp     day_r, 1                        //if(day<1)
	b.lt    print                           //go to print
	cmp     day_r, 31                       //if(day>31)
	b.gt    print                           //go to print

checkIfSpring:
	cmp	day_r, 21			//if day>=21
	b.lt	checkIfSpring2			//go to checkIfSpring2	
	cmp	month_r, 3			//if month>=3
	b.lt	checkIfSpring2			//go to checkIfSpring2
	cmp	month_r, 5			//if month<=5
	b.gt	checkIfSpring2			//go to checkIfSpring2
	mov 	season_r, 0			//it is spring if above all true
	b	display				//go to display

checkIfSpring2:
	cmp	day_r, 20			//if day<20
	b.gt	checkIfSummer			//go to checkIfSummer
	cmp	month_r, 4			//if month>=4
	b.lt	checkIfSummer			//go to checkIfSummer
	cmp	month_r, 6			//if month<=6
	b.gt	checkIfSummer			//go to checkIfSummer
	mov 	season_r, 0			//it is spring if above all true
	b	display				//go to display

checkIfSummer:
	cmp	day_r, 21			//if day>=21
	b.lt	checkIfSummer2			//go to checkIfSummer2
	cmp	month_r, 6			//if month>=6
	b.lt	checkIfSummer2			//go to checkIfSummer2
	cmp	month_r, 8			//if month<=8
	b.gt	checkIfSummer2			//go to checkIfSummer2
	mov 	season_r, 1			//it is summer if above all true
	b	display				//go to display

checkIfSummer2:
	cmp	day_r, 20			//if day<20
	b.gt	checkIfFall			//go to checkIfFall
	cmp	month_r, 7			//if month>=7
	b.lt	checkIfFall			//go to checkIfFall
	cmp	month_r, 9			//if month<=9
	b.gt	checkIfFall			//go to checkIfFall
	mov	season_r, 1			//it is summer if above all true
	b	display				//go to display

checkIfFall:	
	cmp	day_r, 21			//if day>=21
	b.lt	checkIfFall2			//go to checkIfFall2
	cmp	month_r, 9			//if month>=9
	b.lt	checkIfFall2			//go to checkIfFall2
	cmp	month_r, 11			//if month<=11
	b.gt	checkIfFall2			//go to checkIfFall2
	mov	season_r, 2			//it is fall if above all true
	b	display				//go to display	
	
checkIfFall2:
	cmp	day_r, 20			//if day<20
	b.gt	checkIfWinter			//go to checkIfWinter
	cmp	month_r, 10			//if month>=10
	b.lt	checkIfWinter			//go to checkIfWinter
	cmp	month_r, 12			//if month<=12
	b.gt	checkIfWinter			//go to checkIfWinter
	mov	season_r, 2			//it is fall if above all true
	b	display				//go to display

checkIfWinter:
	mov	season_r, 3			//else it must be winter
	
display: 	
    	sub     month_r, month_r, 1             //month-=1 to get correct index

    	ldr	x22, =suffix	                //load suffix
	ldr	x23, =months			//load months
    	ldr     x24, =season			//load season
    
    	ldr	x0, =fmt1			//set string to 1st argument
    	ldr     x1, [x23, month_r, SXTW 3]      //set month to 2nd argument
    	mov     w2, day_r                       //set day to 3rd argument
	sub	day_r, day_r, 1			//day-=1 to get correct index
      	ldr     x3, [x22, day_r, SXTW 3]        //set suffix to 4th argument
    	ldr     x4, [x24, season_r, SXTW 3]     //set season to 5th argument
    	bl      printf                          //call printf
    	b       exit				//go to exit
    
print:                                         
	ldr	x0, =fmt2			//set string as 1st argument
	bl  	printf                          //call printf

exit:							
	mov	w0, 0 			       	//set up return value of 0 from main
	ldp	fp, lr, [sp], 16  		//restore FP and LR from stack, post-increment SP
	ret					//return to OS   
                     
