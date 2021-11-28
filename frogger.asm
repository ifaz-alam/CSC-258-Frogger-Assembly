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

addi $t0, $t0, 0

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
	jr $ra # jump back
	
NEW_COLUMN: 
	# decrement row counter by 1
	addi $t5, $t5, -1
	j DRAW_RECT

DRAW_RECT:
	# t4 = a1 = # columns 
	add $t4, $zero, $a1
	
	# t5 = a2 = # row
	add $t5, $zero, $a2
	
	# if t4 = 0: call END_DRAW_RECT with new row
	beq $t4, $zero, NEW_COLUMN
	
	# draw pixel of colour $a0, then move to the right
	sw $a0, 0($t0)
	addi $t0, $t0, 4
	
	# Store t6 = a0 + 4
	add $t6, $a0, 4
	
	# Calcuate $t6 modulo 128, which is stored in register $hi
	li $t7, 128
	div $t6, $t7
	
	# if $t0 is an edge pixel, wrap around but before you do that add a pixel.
	mfhi $t8
	beq $t8, $zero, WRAP_AROUND
	
	# t4 -= 1
	addi $t4, $t4, -1
	
	# If we are done printing columns for 1 row, we go to the next
	beq $t4, $zero, DRAW_RECT
	
	beq $t5, $zero, END_DRAW_RECT
END_DRAW_RECT:
	li $t4, 0 # reset the counter
	lw $t0, displayAddress # reset the display address anchor
	jr $ra
	
main:
	# We want a draw rectangle function 
	# Its paramters will be $a0 -> colour code, $a1 -> num column, $a2 -> num row, $a3 -> num column
	li $a0, 0x00ff00 # store the green colour code
	li $a1, 3
	li $a2, 3
	
	# set offset of displayAddress
	addi $t0, $t0, 0
	
	jal DRAW_RECT
	


Exit:
li $v0, 10 # terminate the program gracefully
syscall
