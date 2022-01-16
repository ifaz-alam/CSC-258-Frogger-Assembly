
j d

label:
	li $t4, 1
	syscall
c:
	# load our values first for testing
	li $t1, -1
	li $t2, 2

	# store result in t3
	slt $t3, $t1, $t2 # if t1 < t2  then t3 = 1 else t3 = 0

	# if t3 != 0 then it must be that t3 = 1. so t1 < t2. now branch
	bne $t3, $zero, label

 	# now check case for when t1 = t2
 	beq $t1, $t2, label 

d:
	addi $s0, $zero, 1
	
	addi $t1, $zero, 2
	
	 div $s0, $t1 
	 
a: 
li $s0, 1
li $t0, 2

# temporary register
add $t1, $s0, $zero

# set s = t + 0 = t
add $s0, $t0, $zero

# set t= t1 + 0 = t1 = s0
add $t0, $t1, $zero

li $s, 4