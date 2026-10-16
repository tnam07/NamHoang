
.data
.align 2

limits: .word 50, 100, 200, 300, 400, 9999
prices: .word 1720, 1780, 2070, 2620, 2970, 3120

prompt: .asciiz "Nhap so kWh (0..9999): "
error:  .asciiz "Gia tri khong hop le, nhap lai.\n"
result: .asciiz "Tien dien: "
suffix: .asciiz " dong\n"

.text
.globl main

# $s0 = So kWh nhap vao
# $s1 = So kWh con lai
# $s2 = Tong tien dien
# $s3 = Con tro mang nguong
# $s4 = Con tro mang don gia
# $s5 = Nguong cua bac truoc

main:

input_loop:
    # In loi nhac
    li $v0, 4
    la $a0, prompt
    syscall

    # Nhap x
    li $v0, 5
    syscall

    move $s0, $v0

    # Kiem tra 0 <= x <= 9999
    sltiu $t0, $s0, 10000
    bne $t0, $zero, input_ok

    # Gia tri khong hop le
    li $v0, 4
    la $a0, error
    syscall

    j input_loop

input_ok:
    # Khoi tao
    move $s1, $s0
    move $s2, $zero
    move $s5, $zero

    la $s3, limits
    la $s4, prices

    # Truong hop x = 0
    beq $s1, $zero, print_result

calc_loop:
    # Lay nguong va don gia hien tai
    lw $t0, 0($s3)
    lw $t1, 24($s3)

    # Do rong bac
    subu $t2, $t0, $s5

    # Kiem tra so kWh con lai co vuot bac nay
    slt $t3, $t2, $s1
    beq $t3, $zero, last_part

    # Tinh tien toan bo bac
    mul $t4, $t2, $t1
    addu $s2, $s2, $t4

    # Cap nhat so kWh con lai
    subu $s1, $s1, $t2

    # Cap nhat nguong
    move $s5, $t0

    # Chuyen sang bac tiep theo
    addiu $s3, $s3, 4

    j calc_loop

last_part:
    # Tinh tien so kWh con lai
    mul $t4, $s1, $t1
    addu $s2, $s2, $t4

print_result:
    # In chuoi ket qua
    li $v0, 4
    la $a0, result
    syscall

    # In tong tien
    li $v0, 1
    move $a0, $s2
    syscall

    li $v0, 4
    la $a0, suffix
    syscall

    # Ket thuc
    li $v0, 10
    syscall
