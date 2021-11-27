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

# t4 denotes the horizontal offset, a multiple of 32 renders the next row.
# To get n rows worth of visuals, we need an upper bound of 32n - 1.
# 7 rows worth of safe zone, is given by 32 * 9 - 1 = 223


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

main:
	# We want a draw rectangle function 
	# Its paramters will be $a0 -> colour code, $a1 -> num column, $a2 -> num row
	li $a0, 0x00ff00 # store the green colour code
	li $a1, 0	
	
	# starting offset of displayAddress
	addi $t0, $t0, 128
	
	jal DRAW_RECTANGLE
	


Exit:
li $v0, 10 # terminate the program gracefully
syscall