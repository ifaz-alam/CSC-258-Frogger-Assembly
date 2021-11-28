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

main:
	# Call DRAW_RECT
	# Usage:
	# $a0 -> colour code
	# $a1 -> # of columns (horizontal distance)
	# $a2 -> # of rows (vertical distance)
	# $a3 -> pixel offset value
	
	# Let's draw a green rectangle for the safe zone
	
	# Setting our variables based on the specifications above
	li $a0, 0x00f00
	li $a1, 2
	li $a2, 2
	li $a3, 4
	
	# Register t1 is a counter variable for the current column
	# Register t2 is a counter variable for the current row
	li $t1, 0
	li $t2, 1
	
	j DRAW_RECT

END_DRAW_RECT:
	# reset the counters
	li $t1, 0 
	li $t2, 0
	
	# reset the display address to its base address
	lw $t0, displayAddress

IS_LAST_PIXEL:
	# We're on the last pixel
	beq $t2, $a2 END_DRAW_RECT
	
	# We're not on the last pixel, create a new row
	bneq $t2, $a2, NEW_ROW

NEW_ROW:
	# Reset the column count
	li $t1, 0
	
	# Increment the row counter
	addi $t5, $t5, 1
	
	# Restore the column offset and shift it down by one row on the displayAddress (+128)
	lw $t0, displayAddress
	addi $t0, $t0, 128
	add $t0, $t0, $a3 
	
	# Call DRAW_RECT
	j DRAW_RECT

DRAW_RECT:
	# Increment the column position (initially from 0 if new column or brand new call), and draw a pixel
	addi $t1, $t1, 1
	sw $a0, 0($t0)
	
	# Shift the displayAddress pivot
	addi $t0, $t0, 4
	
	# Check if we're done drawing the rectangle
	beq $t1, $a1, IS_LAST_PIXEL
	
	