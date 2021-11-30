#
# CSC258H5S Fall 2021 Assembly Final Project
# University of Toronto, St. George
#
# Student: Ifaz Alam, 1007272700
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Added third row in each of water and road sections
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################
.data
	x: .word 14
	y: .word 20
	vehicle_row: .space 256
displayAddress: .word 0x10008000
.text
lw $t0, displayAddress # $t0 stores the base address for display

j main

WRAP_AROUND:
	addi $t0, $t0, -128
	j DRAW_RECT
	
DRAW_RECT:
	# Increment the column position (initially from 0 if new column or brand new call), and draw a pixel
	addi $t1, $t1, 1
	sw $a0, 0($t0)
	
	# Check if we're done drawing the rectangle
	beq $t1, $a1, IS_LAST_PIXEL
	
	# Shift the displayAddress pivot
	addi $t0, $t0, 4
	
	
	# WARP AROUND CHECK
	# t6 = t0
	add $t6, $zero, $t0
	
	# check whether t6 % 128 == 0
	li $t7 128
	div $t6, $t7
	mfhi $t6
	
	beq $t6, $zero, WRAP_AROUND 
	
	j DRAW_RECT


IS_LAST_PIXEL:
	# We're on the last pixel
	beq $t2, $a2 END_DRAW_RECT
	
	# We're not on the last pixel, create a new row
	bne $t2, $a2, NEW_ROW

NEW_ROW:
	# Reset the column count
	li $t1, 0

	# Restore the column offset
	lw $t0, displayAddress
	add $t0, $t0, $a3
	
	# We now shift it down however many rows on the row counter, which is address + 128 * t2
	# t3 stores the vertical shift amount.
	li $t3, 128
	mul $t3, $t3, $t2
	
	add $t0, $t0, $t3
	
	# Increment the row counter
	addi $t2, $t2, 1
	
	# Call DRAW_RECT
	j DRAW_RECT


END_DRAW_RECT:
	# reset the counters
	li $t1, 0 
	li $t2, 0
	
	# reset the display address to its base address
	lw $t0, displayAddress
	jr $ra
	
main:
	# Call DRAW_RECT
	# Usage:
	# $a0 -> colour code
	# $a1 -> # of columns (horizontal distance)
	# $a2 -> # of rows (vertical distance)
	# $a3 -> pixel offset value
	
	# Register t1 is a counter variable for the current column
	# Register t2 is a counter variable for the current row
	li $t1, 0
	li $t2, 1
	
	# Let's draw a green rectangle for the safe zone
	# Setting our variables based on the specifications above
	li $a0, 0x006400
	li $a1, 32
	li $a2, 8
	li $a3, 0
	
	# Shift Offset
	add $t0, $t0, $a3
	
	jal DRAW_RECT
	
	# Now let's draw the blue water
	li $a0, 0x87CEEB
	li $a1, 32
	li $a2, 9
	li $a3, 896
	
	# Shift offset
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	# Now let's draw the middle safe zone
	li $a0, 0xFFE5B4
	li $a1, 32
	li $a2, 4
	li $a3, 2048
	
	# Shift offset
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	# Now let's draw the road
	li $a0, 0x808080
	li $a1, 32
	li $a2, 8
	li $a3, 2560
	
	# Shift offset
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	# Now let's draw the primary safe zone
	li $a0, 0x006400
	li $a1, 32
	li $a2, 4
	li $a3, 3584
	
	# Shift offset
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	# draw frog
	# offset is 4x + y * 128
	# x = 15, y = 29
	# offset is 3764
	li $a0, 0x90EE90
	li $a1, 3
	li $a2, 2
	li $a3, 3896
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	# Draw logs first row
	li $a0, 0x964B00
	li $a1, 10
	li $a2, 3
	li $a3, 896
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	li $a0, 0x964B00
	li $a1, 10
	li $a2, 3
	li $a3, 956
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	# Draw logs second row
	li $a0, 0x964B00
	li $a1, 10
	li $a2, 3
	li $a3, 1300
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	li $a0, 0x964B00
	li $a1, 10
	li $a2, 3
	li $a3, 1356
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	# Draw logs third row
	li $a0, 0x964B00
	li $a1, 10
	li $a2, 3
	li $a3, 1664
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	li $a0, 0x964B00
	li $a1, 10
	li $a2, 3
	li $a3, 1724
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	
	# Each pixel is 4 bytes
	# Vehicle row has 32 * 2 pixels so the space needed is 32 * 2 * 4 = 256 bytes
	# Draw Cars First Row
	li $a0, 0xFF0000
	li $a1, 4
	li $a2, 2
	li $a3, 2560
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	li $a0, 0xFF0000
	li $a1, 4
	li $a2, 2
	li $a3, 2600
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	# Draw cars second row
	li $a0, 0xFF0000
	li $a1, 4
	li $a2, 2
	li $a3, 2980
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	li $a0, 0xFF0000
	li $a1, 4
	li $a2, 2
	li $a3, 3024
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	# Draw cars third row
	li $a0, 0xFF0000
	li $a1, 4
	li $a2, 2
	li $a3, 3328
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	li $a0, 0xFF0000
	li $a1, 4
	li $a2, 2
	li $a3, 3388
	add $t0, $t0, $a3
	jal DRAW_RECT
	

	li $v0, 32
	li $a0, 17
	syscall
	j main

