
.data
.align 2

pitches:
    .word 64,64,65,67,67,65,64,62
    .word 60,60,62,64,64,62,62

lengths:
    .word 2,2,2,2,2,2,2,2
    .word 2,2,2,2,3,1,4

note_count:    .word 15
student_a:     .word 6
student_b:     .word 5

instruments:   .word 0,24,40,73

# 0 = A: syscall 33
# 1 = B: syscall 31
# 2 = C: syscall 31 + syscall 32
playback_mode: .word 0

space_str:     .asciiz " "
newline:       .asciiz "\n"
msg_expected:  .asciiz "Tong du kien (ms): "
msg_measured:  .asciiz "Thoi gian do duoc (ms): "

.text
.globl main

# $s0 = con tro pitches
# $s1 = con tro lengths
# $s2 = so not con lai
# $s3 = ms moi don vi nhip
# $s4 = nhac cu MIDI
# $s5 = so nua cung dich giong
# $s6 = tong thoi luong du kien
# $s7 = che do phat

main:
    la $s0, pitches
    la $s1, lengths

    la $t0, note_count
    lw $s2, 0($t0)

    la $t0, student_a
    lw $s5, 0($t0)

    la $t0, student_b
    lw $t1, 0($t0)

    # Beat = 150 + 10*b
    li $t2, 10
    mul $s3, $t1, $t2
    addiu $s3, $s3, 150

    # Instrument = instruments[b mod 4]
    andi $t2, $t1, 3
    sll $t2, $t2, 2
    la $t3, instruments
    addu $t3, $t3, $t2
    lw $s4, 0($t3)

    la $t0, playback_mode
    lw $s7, 0($t0)

    move $s6, $zero

    # Lay thoi gian bat dau
    li $v0, 30
    syscall
    move $t8, $a0

note_loop:
    beq $s2, $zero, end_playback

    # Doc cao do va dich giong
    lw $t1, 0($s0)
    addu $t1, $t1, $s5

    # Tinh thoi luong not
    lw $t2, 0($s1)
    mul $t2, $t2, $s3

    # Cong don thoi gian du kien
    addu $s6, $s6, $t2

    # In cao do
    li $v0, 1
    move $a0, $t1
    syscall

    # In dau cach
    li $v0, 4
    la $a0, space_str
    syscall

    # In thoi gian
    li $v0, 1
    move $a0, $t2
    syscall

    # Xuong dong
    li $v0, 4
    la $a0, newline
    syscall

    # Tham so MIDI
    move $a0, $t1
    move $a1, $t2
    move $a2, $s4
    li $a3, 100

    # Chon che do phat
    li $t3, 1
    beq $s7, $t3, play_31

    li $t3, 2
    beq $s7, $t3, play_31_32

play_33:
    li $v0, 33
    syscall
    j next_note

play_31:
    li $v0, 31
    syscall
    j next_note

play_31_32:
    li $v0, 31
    syscall

    # Sleep theo thoi luong not
    move $a0, $t2
    li $v0, 32
    syscall

next_note:
    addiu $s0, $s0, 4
    addiu $s1, $s1, 4
    addiu $s2, $s2, -1
    j note_loop

end_playback:
    # Lay thoi gian ket thuc
    li $v0, 30
    syscall

    subu $t9, $a0, $t8

    # In tong du kien
    li $v0, 4
    la $a0, msg_expected
    syscall

    li $v0, 1
    move $a0, $s6
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    # In thoi gian do duoc
    li $v0, 4
    la $a0, msg_measured
    syscall

    li $v0, 1
    move $a0, $t9
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    # Ket thuc
    li $v0, 10
    syscall
