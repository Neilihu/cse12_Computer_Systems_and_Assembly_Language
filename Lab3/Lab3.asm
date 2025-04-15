#############################################################################
# Created by:  Hu Neili
#              1752639
#              13 May 2021
#
# Assignment:  Lab3: ASCII-risks (Asterisks)
#              CSE12, Computer Systems and Assembly Language
#              UC Santa Cruz, Spring 2021
#
# Description: This program can print star triangle according to input
#
# Notes:       This program is intended to be run from the MARS IDE.
############################################################################
.data
msg: .asciiz "Enter the height of the pattern (must be greater than 0):	"
msg2:.asciiz "Invalid Entry!\n"
msg3:.asciiz "	"	
msg4:.asciiz "*"
msg5:.asciiz "\n"
     .text
main:
li $v0, 4
la $a0, msg
syscall
li $v0, 5
syscall
bgtz $v0, startdoing                           #saving number of star we need into v0
fallloop:
	li $v0, 4
	la $a0, msg2
	syscall
	la $a0, msg
	syscall
	li $v0, 5
	syscall
	bgtz $v0, startdoing                    #saving number of star we need into v0
	j fallloop
startdoing:
	add $t0, $t0, $v0                       #saving number of star we need into t0
	addi $s4, $t0, 0                        #counter of star
	sll $t0, $t0, 1
	addi $t0, $t0, -1
	addi $s2, $s2, 1                        #counter
	addi $t4, $s4, 0
	add_space_for1:                         # the first line is special so I did code specific for line 1 to add space
		beq $t4, 1, add_num_for1
		addi $t4, $t4, -1
		li $v0, 4
		la $a0, msg3
		syscall
		bgt $t4, $t6, add_space_for1
	add_num_for1:                           # the first line is special so I did code specific for line 1 to add number
		li $v0, 1
		addi $t1, $t1, 1
		addi $a0, $t1, 0
		syscall
		
		li $v0, 4
		la $a0, msg5
		syscall
		
		addi $s4, $s4, -1
		beq $s4, 0, end
		
		addi $t4, $s4, 0
	add_space:
		beq $t4, 1, add_num
		addi $t4, $t4, -1
		li $v0, 4
		la $a0, msg3
		syscall
		bgt $t4, $t6, add_space
	add_num:
		addi $t1, $t1, 1
		li $v0, 1
		addi $a0, $t1, 0 
		syscall
		add $t2, $t2, $s2
	addspace_and_star:                      #I add star with space
		addi $t2, $t2, -1                # couner for star in a row
		li $v0, 4
		la $a0, msg3
		syscall
		la $a0, msg4
		syscall
		bgtz $t2, addspace_and_star
	#updating_num:                          this part is for updating each counter if necessary
		li $v0, 4
		la $a0, msg3
		syscall
		
		addi $t1, $t1, 1
		li $v0, 1
		addi $a0, $t1, 0 
		syscall
		
		li $v0, 4
		la $a0, msg5
		syscall
		
		beq $t1, $t0, end
		
		addi $s2, $s2, 2
		addi $s4, $s4, -1
		addi $t4, $s4, 0
		
		bgtz $s4, add_space
end:
li $v0, 10
syscall

