#
# CMPUT 229: Cube Statistics Laboratory
# Author: Jose Nelson Amaral
# Date: December 2009
#
# Main program to read base array into memory,
# read a several cube specifications
# and print statistics for each cube.
#
	.data
errorCS:
	.asciiz "Please check parameters and calling convention for CS: invalid args."
	.align 2
arena:
	.space 32768
Pedge:
	.asciiz "edge = "
Prange:
	.asciiz ", Range = "
Paverage:	
	.asciiz ", Average = "
Pnewline:
	.asciiz "\n"

# These data items will be used by the CubeStats method.
	.globl min
	.globl max
	.globl total
min:	.word 0
max:	.word 0
total:	.word 0

######################################################################
# Register usage:                                                    #
# $s0: dimension                                                     #
# $s1: size                                                          #
# $s2: edge                                                          #
# $s3: first                                                         #
######################################################################
	
	.text
	.globl power
power:
	li $v0, 1
ploop:	
	beqz $a1, pdone
	mul $v0, $v0, $a0
	subu $a1, $a1, 1
	j ploop
pdone:
	jr $ra
	
	.globl main
main:
	subu     $sp, $sp, 4            # Adjust the stack to save $fp
	sw	 $fp, 0($sp)            # Save $fp
	move     $fp, $sp	        # $fp <-- $fp
	subu     $sp, $sp, 4	        # Adjust stack to save $ra
	sw	 $ra, -4($fp)	        # Save the return address ($ra)

	# Get the dimension
	li	 $v0, 5
	syscall
	move     $s0, $v0               # $s0 <-- dimension

	# Get the size
	li	 $v0, 5
	syscall
	move     $s1, $v0               # $s1 <-- size

	# Calculate numelems
	move     $a0, $s1	        # $a0 <-- size
	move     $a1, $s0	        # $a1 <-- dimension
	jal	 power		        # numelems <-- power(size,dimension)

	# Read array
	sll	 $v0,$v0,2	        # $v0 <-- 4*numelems
	la	 $t5, arena	        # cursor <-- start of arena 
	add	 $t6, $t5, $v0	        # $t6 <-- end of array
ReadArray:
	li	 $v0, 5
	syscall			        # $v0 <-- element
	sw	 $v0 0($t5)	        # *cursor <-- element
	addi     $t5, $t5, 4	        # *cursor++
	blt	 $t5, $t6, ReadArray # if(cursor<end of array) 

forever:
	# Read a Cube
	la	 $s3, arena	        # first <-- start of arena
	add	 $t2, $0, $0	        # d <-- 0
	
ReadCube:
	# Get the corner, calculating its absolute location along the way
	li	 $v0, 5
	syscall			        # $v0 <-- cubed
	move     $t4, $v0		# $t4 <-- cubed
	blt	 $t4, $0, ExitMain	# if(cubed<0) ExitMain
	move     $a0, $s1		# $a0 <-- size
	#move     $a1, $t2		# $a1 <-- d
	# Bug fixed Feb. 27 2017
	sub      $a1, $s0, $t2		# $a1 <-- dimension - d
	addi     $a1, $a1, -1       # $a1 <-- dimension - d - 1	
	jal	 power			# $v0 <-- power(size,dimension - d - 1)
	mul	 $t3, $t4, $v0	        # $t3 <-- cubed*power(size,dimension - d - 1)
	sll      $t3, $t3, 2            # $t3 <-- 4*$t3 (offset)
	add	 $s3, $s3, $t3	        # first = first + cubed*power(size,dimension - d - 1)
	add	 $t2, $t2, 1	        # d <-- d + 1
	blt	 $t2, $s0, ReadCube     # if(d<dimension) ReadCube

	# Get the edge length
	li	 $v0, 5
	syscall				# $v0 <-- edge
	move     $s2, $v0		# $s2 <-- edge

	# Initialize total, min, and max to be used by CubeStats
	lw   $t0, 0($s3)
    sw   $t0, min
	sw   $t0, max
	sw   $0, total
	# Set up the arguments and call CubeStats
	move     $a0, $s3		# $a0 <-- first
	move     $a1, $s2		# $a1 <-- edge
	move     $a2, $s0		# $a2 <-- dimension
	move     $a3, $s1		# $a3 <-- size
	
	jal	 CubeStats
	# Get the range and average into $t0, $t1
	move     $t0, $v0
	move     $t1, $v1

	# Print the value of the edge
	li       $v0, 4
	la       $a0, Pedge
	syscall
	move     $a0, $s2
	li       $v0, 1
	syscall

	# Print the value of the range
	li       $v0, 4
	la       $a0, Prange
	syscall
	move     $a0, $t0
	li       $v0, 1
	syscall

	# Print the value of the average
	li      $v0, 4
	la      $a0, Paverage
	syscall
	move    $a0, $t1
	li      $v0, 1
	syscall
	li		$v0, 4
	la		$a0, Pnewline
	syscall
	j       forever
	
ExitMain:	
	# Usual stuff at the end of the main
	lw      $ra, -4($fp)
	addu    $sp, $sp, 4
	lw      $fp, 0($sp)
	addu    $sp, $sp, 4
	jr      $ra



