#@;sort vals in dmem
.set noat

addi $1, $0, 0xeb08
addi $2, $0, 0x7782
mult $1, $2
multu $1, $2
mflo $1
mfhi $2
#add packed bytes with saturation
addu $3, $1, $2
# sat val in 12 bits
lbu $3, 12($3)
sll $0, $1, 5
sll $0, $2, 6
