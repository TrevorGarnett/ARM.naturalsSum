@ Filename: Lab4.s
@ Author:   Trevor Garnett
@ Objective:  To get the students to learn the basics of ARM Assemby.  
@ History:
@	Created 10/29, adding comments when necessary
@
@ Use these commands to assemble, link, run and debug this program:
@    as -o Lab4.o Lab4.s
@    gcc -o Lab4 Lab4.o
@    ./Lab4 ;echo $?
@    gdb --args ./Lab4 

@ ****************************************************
@ The = (equal sign) is used in the ARM Assembler to get the address of a
@ label declared in the .data section. This takes the place of the ADR
@ instruction used in the textbook. 
@ ****************************************************

.equ READERROR, 0 @Used to check for scanf read error. 

.global main @ Have to use main because of C library uses. 

main:

@*******************
prompt:
@*******************

@ Ask the user to enter a number.
 
   ldr r0, =strInputPrompt @ Put the address of my string into the first parameter
   bl  printf              @ Call the C printf to display input prompt. 

@*******************
get_input:
@*******************

@ Set up r0 with the address of input pattern
@ scanf puts the input value at the address stored in r1. We are going
@ to use the address for our declared variable in the data section - intInput. 
@ After the call to scanf the input is at the address pointed to by r1 which in this
@ case will be intInput. 

   ldr r0, =numInputPattern @ Setup to read in one number.
   ldr r1, =intInput        @ load r1 with the address of where the
                            @ input value will be stored. 
   bl  scanf                @ scan the keyboard.
   cmp r0, #READERROR       @ Check for a read error.
   beq readerror            @ If there was a read error go handle it. 
   ldr r1, =intInput        @ Have to reload r1 because it gets wiped out. 
   ldr r1, [r1]             @ Read the contents of intInput so we can use it
   cmp r1, #1		    @ Make sure the number is greater than 1
   blt readerror            @ The number entered was less than 1
   cmp r1, #100             @ Updating flags wrt 100
   bgt readerror            @ The number entered is greater than 100


@ Print the iteraion, as well as the sum of the iteration,up to a point.
@ r1 contains the value input to keyboard. 
   
   mov r7, r1		    @Moving the input to here so as to not overwrite its contents
   ldr r0, =Title	    @Title of table: "Number   Sum"
   bl printf		    @printing

   mov r6, #1		    @r6 will count as the iterator
   mov r5, #1		    @r5 will be the sum of positive integers
less_than:
   ldr r0, =iteration
   mov r1, r6		    @moving iterator to r1 for printing
   bl printf
   ldr r0, =sum
   mov r1, r5		    @moving sum to r1 for printing
   bl printf
   add r6, r6, #1	    @Icrement the iterator i++
   add r5, r5, r6	    @Add the sum to the new iteration sum = sum(n-1) + (n)
   cmp r6, r7		    @if the iterator is less than the number given,
   ble less_than	    @repeat

   sub r1, r5, r6	    @the sum was increased since last prit
   ldr r0, =strOutputNum    @No we are printing the total sum
   bl  printf
   b   myexit 		    @leave the code. 

@***********
readerror:
@***********
@ Got a read error from the scanf routine. Clear out the input buffer then
@ branch back for the user to enter a value. 
@ Since an invalid entry was made we now have to clear out the input buffer by
@ reading with this format %[^\n] which will read the buffer until the user 
@ presses the CR. 

   ldr r0, =strInputPattern
   ldr r1, =strInputError   @ Put address into r1 for read.
   bl scanf                 @ scan the keyboard.
@  Not going to do anything with the input. This just cleans up the input buffer.  
@  The input buffer should now be clear so get another input.

   b prompt


@*******************
myexit:
@*******************
@ End of my code. Force the exit and return control to OS

   mov r7, #0x01 @SVC call to exit
   svc 0         @Make the system call. 

.data

@ Declare the strings and data needed

.balign 4 @the memory address for this is 0x2102c
strInputPrompt: .asciz "This program will print the sum of the integers from 1 to a number you enter. Please enter an integer from 1 to 100: "

.balign 4
strOutputNum: .asciz "The sum is: %d \n"

@ Format pattern for scanf call.

.balign 4
numInputPattern: .asciz "%d"  @ integer format for read. 

.balign 4
strInputPattern: .asciz "%[^\n]" @ Used to clear the input buffer for invalid input. 

.balign 4
strInputError: .skip 100*4  @ User to clear the input buffer for invalid input. 

.balign 4
intInput: .word 0   @ Location used to store the user input.

.balign 4
iteration: .asciz "%d \t \t"

.balign 4
sum: .asciz "%d \n"

.balign 4
Title: .asciz "Number \t \tSum \n" 

@ Let the assembler know these are the C library functions. 

.global printf
@  To use printf:
@     r0 - Contains the starting address of the string to be printed. The string
@          must conform to the C coding standards.
@     r1 - If the string contains an output parameter i.e., %d, %c, etc. register
@          r1 must contain the value to be printed. 
@ When the call returns registers: r0, r1, r2, r3 and r12 are changed. 

.global scanf
@  To use scanf:
@      r0 - Contains the address of the input format string used to read the user
@           input value. In this example it is numInputPattern.  
@      r1 - Must contain the address where the input value is going to be stored.
@           In this example memory location intInput declared in the .data section
@           is being used.  
@ When the call returns registers: r0, r1, r2, r3 and r12 are changed.
@ Important Notes about scanf:
@   If the user entered an input that does NOT conform to the input pattern, 
@   then register r0 will contain a 0. If it is a valid format
@   then r0 will contain a 1. The input buffer will NOT be cleared of the invalid
@   input so that needs to be cleared out before attempting anything else. 
@

@end of code and end of file. Leave a blank line after this.
