# Spring 2021 CSE12 Lab 4 Template
######################################################
# Macros made for you (you will need to use these)
######################################################

# Macro that stores the value in %reg on the stack 
#	and moves the stack pointer.
.macro push(%reg)
	subi $sp $sp 4
	sw %reg 0($sp)
.end_macro 

# Macro takes the value on the top of the stack and 
#	loads it into %reg then moves the stack pointer.
.macro pop(%reg)
	lw %reg 0($sp)
	addi $sp $sp 4	
.end_macro

#################################################
# Macros for you to fill in (you will need these)
#################################################

# Macro that takes as input coordinates in the format
#	(0x00XX00YY) and returns x and y separately.
# args: 
#	%input: register containing 0x00XX00YY
#	%x: register to store 0x000000XX in
#	%y: register to store 0x000000YY in
.macro getCoordinates(%input %x %y)
	srl %x, %input, 16
	#add %x, $0, $t7
	nop
	sll %y, %input, 16
	nop
	srl %y, %y, 16
	#srl %y, $t8, 16
	nop
.end_macro

# Macro that takes Coordinates in (%x,%y) where
#	%x = 0x000000XX and %y= 0x000000YY and
#	returns %output = (0x00XX00YY)
# args: 
#	%x: register containing 0x000000XX
#	%y: register containing 0x000000YY
#	%output: register to store 0x00XX00YY in
.macro formatCoordinates(%output %x %y)
	add %output, %x, $0
	nop
	sll %output, %output, 16
	nop
	add %output, %output, %y
	nop
.end_macro 

# Macro that converts pixel coordinate to address
# 	  output = origin + 4 * (x + 128 * y)
# 	where origin = 0xFFFF0000 is the memory address
# 	corresponding to the point (0, 0), i.e. the memory
# 	address storing the color of the the top left pixel.
# args: 
#	%x: register containing 0x000000XX
#	%y: register containing 0x000000YY
#	%output: register to store memory address in
.macro getPixelAddress(%output %x %y)
	sll %y, %y, 7   #y*128
	nop
	add %x, %x, %y #x+128*y
	nop
	sll %x, %x, 2  #4(x+128*y)
	nop
	addi %output, %x, 0xFFFF0000
	nop
.end_macro

.data
originAddress: .word 0xFFFF0000

.text
# prevent this file from being run as main
li $v0 10 
syscall

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#  Subroutines defined below
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#*****************************************************
# Clear_bitmap: Given a color, will fill the bitmap 
#	display with that color.
# -----------------------------------------------------
# Inputs:
#	$a0 = Color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
#pesuducode
#clear_bitmap(a0):
#	t1 = originaladdress
#	t3 = the whole page
#       t7 = backup color for background
#	for i in range(t3):
#   		put colour in originaladdress
#   		originaladdress += 4
#*****************************************************
clear_bitmap: nop
	lw $t1, originAddress
	addi $t3, $0, 16384
	add $t7, $a0, $0
	clean_page:
		addi $t3, $t3, -1		
		sw $a0, ($t1)
		addi $t1, $t1, 4
		bgtz $t3, clean_page
 	jr $ra

#*****************************************************
# draw_pixel: Given a coordinate in $a0, sets corresponding 
#	value in memory to the color given by $a1
# -----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#		$a1 = color of pixel in format (0x00RRGGBB)
#	Outputs:
#		No register outputs
#*****************************************************
#pesudocode
#draw_pixel(a0, a1):
#	getCoordinates(a0, t0, t1)   (t0 = x-coordinate    t1 = y-coordinate)
#	getPixelAddress($t1 $t0, $t1) use t1 as temporary address
#	put color in t1 address
#******************************************************
draw_pixel: nop
	getCoordinates($a0, $t0, $t1)
	getPixelAddress($t1 $t0, $t1)
	sw  $a1, ($t1)
	jr $ra
	
#*****************************************************
# get_pixel:
#  Given a coordinate, returns the color of that pixel	
#-----------------------------------------------------
#	Inputs:
#		$a0 = coordinates of pixel in format (0x00XX00YY)
#	Outputs:
#		Returns pixel color in $v0 in format (0x00RRGGBB)
#*****************************************************
#pesudocode
#get_picel(a0):
#	getCoordinates(a0, t0, t1)  (t0 = x-coordinate    t1 = y-coordinate)
#	getPixelAddress($t1 $t0, $t1) use t1 as temporary address
#	get color from t1 address
#******************************************************
get_pixel: nop
	getCoordinates($a0, $t0, $t1)
	getPixelAddress($t1 $t0, $t1)
	lw $v0, 0($t1)
	jr $ra

#*****************************************************
# draw_horizontal_line: Draws a horizontal line
# ----------------------------------------------------
# Inputs:
#	$a0 = y-coordinate in format (0x000000YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
#pesudocode
#because I do jal so I have to save $ra first
#       getCoordinates($a0, $t0, $t1)
#   for i in range 128:   
#       draw_pixel at $a0 address
#       x += 1 
#       update x to $a0
#   go back
#****************************************************
draw_horizontal_line: nop
	push($ra)
	getCoordinates($a0, $t0, $t1)         #only y-coordinate has number which is t1
start:
	jal draw_pixel
	getCoordinates($a0, $t0, $t1)    
	addi $t0, $t0, 1
	formatCoordinates($a0, $t0, $t1)
	bne $t0, 128, start
	pop($ra)
 	jr $ra


#*****************************************************
# draw_vertical_line: Draws a vertical line
# ----------------------------------------------------
# Inputs:
#	$a0 = x-coordinate in format (0x000000XX)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
#pesudocode
#because I do jal so I have to save $ra first
#       convert to the usable form
#       getCoordinates($a0, $t0, $t1)
#   for i in range 128:   
#       draw_pixel at $a0 address
#       y += 1 
#       update y to $a0
#   go back
draw_vertical_line: nop
	push($ra)
	sll $a0, $a0, 16
	getCoordinates($a0, $t0, $t1)
start2:	
	jal draw_pixel
	getCoordinates($a0, $t0, $t1)
	addi $t1, $t1, 1
	formatCoordinates($a0, $t0, $t1)
	bne $t1, 128, start2
	pop($ra)
 	jr $ra


#*****************************************************
# draw_crosshair: Draws a horizontal and a vertical 
#	line of given color which intersect at given (x, y).
#	The pixel at (x, y) should be the same color before 
#	and after running this function.
# -----------------------------------------------------
# Inputs:
#	$a0 = (x, y) coords of intersection in format (0x00XX00YY)
#	$a1 = color in format (0x00RRGGBB) 
# Outputs:
#	No register outputs
#*****************************************************
#pesudocode
#because I do jal so I have to save $ra first
#       save the data that I need 
#       t4 = x
#       t5 = y
#       t6 = coordiante
#       put needed data in specific form
#       draw the horizontal line
#       put needed data in specific form
#       draw the vertical line
#       put needed data in specific form
#       draw the cross point
#       go back
draw_crosshair: nop
	push($ra)
	
	# HINT: Store the pixel color at $a0 before drawing the horizontal and 
	# vertical lines, then afterwards, restore the color of the pixel at $a0 to 
	# give the appearance of the center being transparent.
	
	# Note: Remember to use push and pop in this function to save your t-registers
	# before calling any of the above subroutines.  Otherwise your t-registers 
	# may be overwritten.  
	getCoordinates($a0, $t4, $t5)
	add $t6, $a0, $0
	add $a0, $t5, $0
	jal draw_horizontal_line
	
	add $a0, $t4,$0
	jal draw_vertical_line
	
	add $a0, $t6, $0
	add $a1, $t7, $0
	jal draw_pixel

	# HINT: at this point, $ra has changed (and you're likely stuck in an infinite loop). 
	# Add a pop before the below jump return (and push somewhere above) to fix this.
	pop($ra)
	jr $ra
