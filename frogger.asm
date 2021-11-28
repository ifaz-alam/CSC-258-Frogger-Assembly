# Demo for painting
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
.data
displayAddress: .word 0x10008000
.text
lw $t0, displayAddress # $t0 stores the base address for display
li $t1, 0xff0000 # $t1 stores the red colour code
li $t2, 0x00ff00 # $t2 stores the green colour code
li $t3, 0x0000ff # $t3 stores the blue colour code


# sw $t1, 0($t0) # paint the first (top-left) unit red.


# The counter variable for number of pixels drawn in a row
addi $t4, $zero, 0
addi $t5, $zero, 0

addi $t0, $t0, 4092

#sw $t2, 0($t0)

# To get the address of the n'th edge, we do 124 + 128(n - 1) = 128n - 128 + 124 = 128n - 4. 
# So we can compute for the edge when $t0 + 4 is congruent to 0 modulo 128 
j main

DRAW_RECTANGLE:  beq $t4, $a1, DRAW_LAST_PIXEL
	sw $a0, 0($t0) # draw a pixel of colour type $a0
	
	# change the memory address of the pixel to the next adjacent pixel 
	addi $t0, $t0, 4
	
	# increment the counter variable
	addi $t4, $t4, 1
	
	j DRAW_RECTANGLE

# Add the last pixel on the row
DRAW_LAST_PIXEL: sw $a0, 0($t0)
		 li $t4, 0 # reset the counter
		 lw $t0, displayAddress # reset the display address anchor
		 jr $ra # jump back

# DRAW THE REMAINING PIXEL BEFORE WRAPPING AROUND
WRAP_AROUND: sw $a0, 0($t0)
	addi $t0, $t0, -128

DRAW_RECT:
	# t4 = a1 = # columns 
	add $t4, $zero, $a1
	
	# if t4 = 0: call END_DRAW_RECT with new row
	beq $t4, $zero, DRAW_RECT
	# else
	
	# draw pixel of colour $a0, then move to the right
	sw $a0, 0($t0)
	addi $t0, $t0, 4
	
	
	# Store t5 = a0 + 4
	add $t5, $a0, 4
	
	# Calcuate $t5 modulo 128, which is stored in register $hi
	div $t5, 128
	
	# if $t0 is an edge pixel, wrap around but before you do that add a pixel.
	beq $hi, $zero, WRAP_AROUND
	addi $t0, $t0, -128
	
	# t4 -= 1
	addi $t4, $t4, -1

END_DRAW_RECT:
	jr $ra
main:
	# We want a draw rectangle function 
	# Its paramters will be $a0 -> colour code, $a1 -> num column, $a2 -> num row, $a3 -> num column
	li $a0, 0x00ff00 # store the green colour code
	li $a1, 3
	
	# starting offset of displayAddress
	addi $t0, $t0, 128
	
	#jal DRAW_RECTANGLE
	


Exit:
li $v0, 10 # terminate the program gracefully
syscall
