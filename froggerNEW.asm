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
	cars_row_1: .space 4
	cars_row_2: .space 4
	cars_row_3: .space 4
	cars_row_3_timer: .space 4
	LogsLeftGroup: .space 4
	LogsRightGroup: .space 4
	LogsMiddleLeft: .space 4
	LogsMiddleRight: .space 4
	
displayAddress: .word 0x10008000
.text

# For the first row the distance between first car and second car is 40
li $s3, 2560
#2nd is 44
li $s4, 2980
# for the third the offset is 60
li $s5, 3328

sw $s3, cars_row_1($zero)
sw $s4, cars_row_2($zero)
sw $s5, cars_row_3($zero)

# Reassign the values
# Frog life
li $s5, 5
# Frog score
li $s6, 0

# Log starting positions
# LogLeftGroup - 896 and 1664
# LogRightGroup - 956 and 1724
li $s3, 896
sw $s3, LogsLeftGroup($zero)
li $s4, 956
sw $s4, LogsRightGroup($zero)


# Middle logs anchor points in order of first log, second log
#1st log
li $s3, 1300
sw $s3, LogsMiddleLeft($zero)
#2nd log
li $s3, 1356
sw $s3, LogsMiddleLeft($zero)


# Set log frame count to 0. we will move the top and bottom row once every 20 frames
li $s4, 20
# The middle one will move faster, we will update it once every 10 frames
li $s3, 10

sw $zero, cars_row_3_timer($zero)

# For the second row the distance between first car and second car is 

lw $t0, displayAddress # $t0 stores the base address for display
# Store frog position
li $t4, 3896


# Register t1 is a counter variable for the current column
# Register t2 is a counter variable for the current row
li $t1, 0
li $t2, 1

j main

# check whether the grouped logs can move yet
check_log_group_frames:
	beq $s4, $zero, draw_logs_grouped_shift
	bne $s4, $zero, draw_logs_grouped_still

check_log_middle_frames:
	beq $s3 $zero, draw_middle_logs_shift
	bne $s3, $zero, draw_middle_logs_still

draw_middle_logs_still:
	# Draw middle left log
	# stack store $rs value from main
	addi $sp, $sp, -4
	# push the current $ra onto the stack
	sw $ra, 0($sp)
	
	
	# decrement log frame counter
	addi $s3, $s3, -1
	
	# stack store $rs value from main
	addi $sp, $sp, -4
	# push the current $ra onto the stack
	sw $ra, 0($sp)
	
	li $a0, 0x964B00
	li $a1, 10
	li $a2, 3
	lw $a3, LogsMiddleLeft($zero)
	add $t0, $t0, $a3
	jal DRAW_RECT 
	
	lw $a3, LogsMiddleRight($zero)
	
	li $a0, 0x964B00
	li $a1, 10
	li $a2, 3
	add $t0, $t0, $a3
	jal DRAW_RECT
		
	# restore the $ra from the stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	

draw_middle_logs_shift:
	# middle left logs draw
	# stack store $rs value from main
	addi $sp, $sp, -4
	# push the current $ra onto the stack
	sw $ra, 0($sp)

	# reset log frame counter
	li $s3, 20
	
	li $a0, 0x964B00
	li $a1, 10
	li $a2, 3
	lw $a3, LogsLeftGroup($zero)
	add $t0, $t0, $a3
	jal DRAW_RECT 
	
	lw $a3, LogsRightGroup($zero)
	li $a0, 0x964B00
	li $a1, 10
	li $a2, 3
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	# we are going to shift the coordinates
	lw $a3, LogsLeftGroup($zero)
	addi $a3, $a3, 4
	jal check_wrap_log_right
	
	#addi $a3, $a3, 4
	# store the relevant offset 
	sw $a3, LogsLeftGroup($zero)
	
	# we are going to shift the coordinates
	lw $a3, LogsRightGroup($zero)
	addi $a3, $a3, 4
	jal check_wrap_log_right
	
	#addi $a3, $a3, 4
	# store the relevant offset 
	sw $a3, LogsRightGroup($zero)
	
	
	# restore the $ra from the stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	

draw_logs_grouped_still:
	# Draw the grouped ones on the left
	# stack store $rs value from main
	addi $sp, $sp, -4
	# push the current $ra onto the stack
	sw $ra, 0($sp)
	
	
	# decrement log frame counter
	addi $s4, $s4, -1
	
	# Draw the grouped ones on the left
	# stack store $rs value from main
	addi $sp, $sp, -4
	# push the current $ra onto the stack
	sw $ra, 0($sp)
	
	li $a0, 0x964B00
	li $a1, 10
	li $a2, 3
	lw $a3, LogsLeftGroup($zero)
	add $t0, $t0, $a3
	jal DRAW_RECT 
	
	addi $a3, $a3, 768
	
	li $a0, 0x964B00
	li $a1, 10
	li $a2, 3
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	# Draw the grouped ones on the right
	li $a0, 0x964B00
	li $a1, 10
	li $a2, 3
	lw $a3, LogsRightGroup($zero)
	add $t0, $t0, $a3
	jal DRAW_RECT 
	
	addi $a3, $a3, 768
	
	li $a0, 0x964B00
	li $a1, 10
	li $a2, 3
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	# restore the $ra from the stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
		
				
draw_logs_grouped_shift:
	# Draw the grouped ones on the left
	# stack store $rs value from main
	addi $sp, $sp, -4
	# push the current $ra onto the stack
	sw $ra, 0($sp)
	
	
	# reset log frame counter
	li $s4, 20
	
	# Draw the grouped ones on the left
	# stack store $rs value from main
	addi $sp, $sp, -4
	# push the current $ra onto the stack
	sw $ra, 0($sp)
	
	li $a0, 0x964B00
	li $a1, 10
	li $a2, 3
	lw $a3, LogsLeftGroup($zero)
	add $t0, $t0, $a3
	jal DRAW_RECT 
	
	addi $a3, $a3, 768
	
	li $a0, 0x964B00
	li $a1, 10
	li $a2, 3
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	# we are going to shift the coordinates
	lw $a3, LogsLeftGroup($zero)
	addi $a3, $a3, -4
	jal check_wrap_log_left
	
	#addi $a3, $a3, 4
	# store the relevant offset 
	sw $a3, LogsLeftGroup($zero)
	
	# Draw the grouped ones on the right
	li $a0, 0x964B00
	li $a1, 10
	li $a2, 3
	lw $a3, LogsRightGroup($zero)
	add $t0, $t0, $a3
	jal DRAW_RECT 
	
	addi $a3, $a3, 768
	
	li $a0, 0x964B00
	li $a1, 10
	li $a2, 3
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	# we are going to shift the coordinates
	lw $a3, LogsRightGroup($zero)
	addi $a3, $a3, -4
	jal check_wrap_log_left
	
	#addi $a3, $a3, 4
	# store the relevant offset 
	sw $a3, LogsRightGroup($zero)
	
	# restore the $ra from the stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
check_wrap_log_left:
	#check to see if we need to wrap around. let t6 = a3 and check whether t6 % 124 == 0
	add $t6, $zero, $a3
	li $t7, 128
	div $t6, $t7
	mfhi $t6
	beq $t6, 124, wrap_log_left
	jr $ra
	
wrap_log_left:
	addi $a3, $a3, 128
	jr $ra
	
check_wrap_log_right:
	#check to see if we need to wrap around. let t6 = a3 and check whether t6 % 124 == 0
	add $t6, $zero, $a3
	li $t7, 128
	div $t6, $t7
	mfhi $t6
	beq $t6, 0, wrap_log_right
	jr $ra
	
wrap_log_right:
	addi $a3, $a3, -128
	jr $ra



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
	li $t2, 1
	
	# reset the display address to its base address
	lw $t0, displayAddress
	jr $ra
	
	
keyboard_input:
	lw $t5, 0xffff0004
	beq $t5, 0x77, respond_to_w
	beq $t5, 0x61, respond_to_a
	beq $t5, 0x73, respond_to_s
	beq $t5, 0x64, respond_to_d
	jr $ra
	
respond_to_a:
	addi $t4, $t4, -4
	jr $ra

respond_to_d:
	addi $t4, $t4, 4
	jr $ra
	
respond_to_w:
	addi $t4, $t4, -128
	jr $ra
	
respond_to_s:
	addi $t4, $t4, 128
	jr $ra

draw_end_zone:
	# Let's draw a green rectangle for the safe zone
	# Setting our variables based on the specifications above
	li $a0, 0x006400
	li $a1, 32
	li $a2, 8
	li $a3, 0
	
	# Shift Offset
	add $t0, $t0, $a3
	
	# stack store $rs value from main
	addi $sp, $sp, -4
	# push the current $ra onto the stack
	sw $ra, 0($sp)
	jal DRAW_RECT
	
	# restore the $ra from the stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra

draw_car_row_1:
	# stack store $rs value from main
	addi $sp, $sp, -4
	# push the current $ra onto the stack
	sw $ra, 0($sp)
	
	li $a0, 0xFF0000
	li $a1, 1
	li $a2, 1
	lw $a3, cars_row_1($zero)
	add $t0, $t0, $a3
	jal DRAW_RECT 
	
	addi $a3, $a3, 80
	
	li $a0, 0xFF0000
	li $a1, 1
	li $a2, 1
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	
	
	# we are going to shift the coordinates
	lw $a3, cars_row_1($zero)
	addi $a3, $a3, -4
	jal check_wrap_car_r1
	
	#addi $a3, $a3, 4
	# store the relevant offset 
	sw $a3, cars_row_1($zero)
	
	# restore the $ra from the stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
check_wrap_car_r1:
	#check to see if we need to wrap around. let t6 = a3 and check whether t6 % 124 == 0
	add $t6, $zero, $a3
	li $t7, 128
	div $t6, $t7
	mfhi $t6
	beq $t6, 124, wrap_car_r1
	jr $ra
	
wrap_car_r1:
	addi $a3, $a3, 128
	jr $ra

# draw car row 2
draw_car_row_2:
	# stack store $rs value from main
	addi $sp, $sp, -4
	# push the current $ra onto the stack
	sw $ra, 0($sp)
	
	li $a0, 0xFF0000
	li $a1, 1
	li $a2, 1
	lw $a3, cars_row_2($zero)
	add $t0, $t0, $a3
	jal DRAW_RECT 
	
	addi $a3, $a3, 44
	
	li $a0, 0xFF0000
	li $a1, 1
	li $a2, 1
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	# we are going to shift the coordinates
	lw $a3, cars_row_2($zero)
	addi $a3, $a3, 4
	jal check_wrap_car_r2
	
	#addi $a3, $a3, 4
	# store the relevant offset 
	sw $a3, cars_row_2($zero)
	
	# restore the $ra from the stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
check_wrap_car_r2:
	#check to see if we need to wrap around. let t6 = a3 and check whether t6 % 124 == 0
	add $t6, $zero, $a3
	li $t7, 128
	div $t6, $t7
	mfhi $t6
	beq $t6, 124, wrap_car_r2
	jr $ra
	
wrap_car_r2:
	addi $a3, $a3, -128
	jr $ra

# draw cars on row 3

draw_car_row_3:
	# stack store $rs value from main
	addi $sp, $sp, -4
	# push the current $ra onto the stack
	sw $ra, 0($sp)
	
	li $a0, 0xFF0000
	li $a1, 1
	li $a2, 1
	lw $a3, cars_row_3($zero)
	add $t0, $t0, $a3
	jal DRAW_RECT 
	
	addi $a3, $a3, 44
	
	li $a0, 0xFF0000
	li $a1, 1
	li $a2, 1
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	# we are going to shift the coordinates
	lw $a3, cars_row_3($zero)
	addi $a3, $a3, -4
	jal check_wrap_car_r3
	
	#addi $a3, $a3, 4
	# store the relevant offset 
	sw $a3, cars_row_3($zero)
	
	# restore the $ra from the stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
			
check_wrap_car_r3:
	#check to see if we need to wrap around. let t6 = a3 and check whether t6 % 124 == 0
	add $t6, $zero, $a3
	li $t7, 128
	div $t6, $t7
	mfhi $t6
	beq $t6, 124, wrap_car_r3
	jr $ra
	
wrap_car_r3:
	addi $a3, $a3, 128
	jr $ra
	

car_collision:
	# stack store $rs value from main
	addi $sp, $sp, -4
	# push the current $ra onto the stack
	sw $ra, 0($sp)
	
	# stack store $t7 value from main
	addi $sp, $sp, -4
	# push the current $t7 onto the stack
	sw $ra, 0($sp)
	
	lw $t7, cars_row_1($zero)
	
	beq $t4, $t7, frog_death
	addi $t7, $t7, 40
	beq $t4, $t7, frog_death
	addi $t7, $t7, -40
	addi $t7, $t7, 420
	beq $t4, $t7, frog_death
	addi $t7, $t7, 44
	beq $t4, $t7, frog_death
	lw $t7, cars_row_1($zero)
	addi $t7, $t7, 768
	beq $t4, $t7, frog_death
	addi $t7, $t7, 60
	beq $t4, $t7, frog_death
	
	# restore the $t7 from the stack
	lw $t7, 0($sp)
	addi $sp, $sp, 4
	
	# restore the $ra from the stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	jr $ra
	
frog_death:
	li $t4, 3896

	# restore the $t7 from the stack
	lw $t7, 0($sp)
	addi $sp, $sp, 4
	
	# restore the $ra from the stack
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	addi $s5, $s5, -1
	beq $s5, $zero, game_over
	jr $ra
game_over:
	syscall
main:
	# Call DRAW_RECT
	# Usage:
	# $a0 -> colour code
	# $a1 -> # of columns (horizontal distance)
	# $a2 -> # of rows (vertical distance)
	# $a3 -> pixel offset value
	
	# Let's draw a green rectangle for the end zone
	jal draw_end_zone
	
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
	
	jal check_log_group_frames
	jal check_log_middle_frames
	
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
	
	# Draw Cars First Row
	jal draw_car_row_1
	
	# Draw cars second row
	jal draw_car_row_2
	
	# Draw cars third row
	jal draw_car_row_3
	
			
	# draw frog
	# offset is 4x + y * 128
	# offset is 3764
	li $a0, 0x90ee90
	li $a1, 2
	li $a2, 1
	#t4 stores the position of the frog
	move $a3, $t4
	add $t0, $t0, $a3
	jal DRAW_RECT
	
	
	# Keyboard input
	lw $t8, 0xffff0000
	beq $t8, 1, keyboard_input
	jal car_collision
	# ?
	li $v0, 32
	li $a0, 17
	syscall
	
	j main

