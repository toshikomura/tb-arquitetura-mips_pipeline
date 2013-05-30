lw $2, 8($4)
lw $3, 8($0)
lw $4, 20($0)
nop
add $5, $0, $2

nop
nop
nop

add $5, $5, $3
nop
nop

nop
slt $6, $4, $5
nop
nop

nop
beq $6, $0, -9
nop


nop
nop
sw $5, 0($0)
beq $0, $0, -18

jal 8

j -4

jr $2
