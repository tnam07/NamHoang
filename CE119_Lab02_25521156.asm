# run_mode:
# 0 = Thong ke diem T1
# 1 = Thong ke diem T2
# 2 = Thong ke diem T3
# 3 = Kiem tra 9 chuoi ngoac
# 4 = Kiem tra rieng chuoi P
# 5 = Mo rong: ve histogram

.data
.align 2

run_mode: .word 1

# Mang diem ca nhan, d = 6
scores_t1: .word 1,9,3,4,8,0,2,8,1,4,10,9

scores_t2: .word 10
scores_t3: .word 4,4,4,4,4

# Bang tra nhom diem
# 0-3 = g0
# 4-6 = g1
# 7-8 = g2
# 9-10 = g3
grade_tab: .byte 0,0,0,0,1,1,1,2,2,3,3

.align 2

hist: .word 0,0,0,0

msg_min:   .asciiz "min="
msg_max:   .asciiz " max="
msg_g0:    .asciiz "g0="
msg_g1:    .asciiz " g1="
msg_g2:    .asciiz " g2="
msg_g3:    .asciiz " g3="
msg_eol:   .asciiz "\n"
msg_test:  .asciiz "Test "
msg_colon: .asciiz ": ("
msg_comma: .asciiz ", "
msg_close: .asciiz ")\n"
msg_dh:    .asciiz ": "

# Cac chuoi kiem tra ngoac
str1: .asciiz "(a+b)*[c-{d/e}]"
str2: .asciiz "f(x[i]{j}))"
str3: .asciiz "{[(])}"
str4: .asciiz "((a)"
str5: .asciiz ""
str6: .asciiz "no brackets here"
str7: .asciiz "]"
str8: .asciiz "([)]"

# Chuoi P: k = 9 cap ngoac
strP: .asciiz "([{([{([{}])}])}])"

.align 2
str_ptrs: .word str1,str2,str3,str4
          .word str5,str6,str7,str8,strP

.text
.globl main

# =====================================
# MAIN
# =====================================

main:
    la $t0, run_mode
    lw $t1, 0($t0)

    li $t2, 3
    beq $t1, $t2, run_all_brackets

    li $t2, 4
    beq $t1, $t2, run_p_only

    li $t2, 5
    beq $t1, $t2, run_draw_hist

    # Chon mang diem T1, T2 hoac T3
    la $s0, scores_t1
    li $s1, 12

    li $t2, 1
    beq $t1, $t2, select_t2

    li $t2, 2
    beq $t1, $t2, select_t3

    j run_stats

select_t2:
    la $s0, scores_t2
    li $s1, 1
    j run_stats

select_t3:
    la $s0, scores_t3
    li $s1, 5

# =====================================
# THONG KE MIN, MAX VA HISTOGRAM
# =====================================

run_stats:
    # Goi stats
    move $a0, $s0
    move $a1, $s1
    jal stats

    move $s2, $v0
    move $s3, $v1

    # Xoa histogram cu
    jal reset_hist

    # Goi histogram
    move $a0, $s0
    move $a1, $s1
    la $a2, grade_tab
    la $a3, hist
    jal histogram

    # In min
    li $v0, 4
    la $a0, msg_min
    syscall

    li $v0, 1
    move $a0, $s2
    syscall

    # In max
    li $v0, 4
    la $a0, msg_max
    syscall

    li $v0, 1
    move $a0, $s3
    syscall

    li $v0, 4
    la $a0, msg_eol
    syscall

    # In so luong tung nhom
    la $s4, hist

    # g0
    li $v0, 4
    la $a0, msg_g0
    syscall

    lw $a0, 0($s4)
    li $v0, 1
    syscall

    # g1
    li $v0, 4
    la $a0, msg_g1
    syscall

    lw $a0, 4($s4)
    li $v0, 1
    syscall

    # g2
    li $v0, 4
    la $a0, msg_g2
    syscall

    lw $a0, 8($s4)
    li $v0, 1
    syscall

    # g3
    li $v0, 4
    la $a0, msg_g3
    syscall

    lw $a0, 12($s4)
    li $v0, 1
    syscall

    # Xuong dong
    li $v0, 4
    la $a0, msg_eol
    syscall

    j program_exit


# =====================================
# PHAN MO RONG - VE HISTOGRAM
# =====================================

run_draw_hist:
    jal reset_hist

    la $a0, scores_t1
    li $a1, 12
    la $a2, grade_tab
    la $a3, hist
    jal histogram

    la $a0, hist
    li $a1, 4
    jal draw_hist

    j program_exit


# =====================================
# KIEM TRA TAT CA CHUOI NGOAC
# =====================================

run_all_brackets:
    la $s0, str_ptrs
    li $s1, 9
    li $s2, 1

rab_loop:
    beq $s1, $zero, program_exit

    lw $a0, 0($s0)
    jal check_brackets

    move $s3, $v0
    move $s4, $v1

    jal print_bracket_result

    addiu $s0, $s0, 4
    addiu $s1, $s1, -1
    addiu $s2, $s2, 1

    j rab_loop


# =====================================
# KIEM TRA RIENG CHUOI P
# =====================================

run_p_only:
    li $s2, 9

    la $a0, strP
    jal check_brackets

    move $s3, $v0
    move $s4, $v1

    jal print_bracket_result
    j program_exit


program_exit:
    li $v0, 10
    syscall


# =====================================
# print_bracket_result
# Tham so: $s2 = test index
#          $s3 = vi tri loi
#          $s4 = ma loi
# Tra ve: khong
# Su dung: $v0, $a0
# Thu tuc la
# =====================================

print_bracket_result:
    li $v0, 4
    la $a0, msg_test
    syscall

    li $v0, 1
    move $a0, $s2
    syscall

    li $v0, 4
    la $a0, msg_colon
    syscall

    li $v0, 1
    move $a0, $s3
    syscall

    li $v0, 4
    la $a0, msg_comma
    syscall

    li $v0, 1
    move $a0, $s4
    syscall

    li $v0, 4
    la $a0, msg_close
    syscall

    jr $ra


# =====================================
# stats
# Tim diem nho nhat va lon nhat
#
# Tham so:
# $a0 = dia chi mang word
# $a1 = n, n >= 1
#
# Tra ve:
# $v0 = min
# $v1 = max
#
# Su dung: $a0,$a1,$t0,$t1,$v0,$v1
# Khong ghi bo nho, khong dung $s
# Thu tuc la
# =====================================

stats:
    lw $v0, 0($a0)
    move $v1, $v0

    addiu $a0, $a0, 4
    addiu $a1, $a1, -1

stats_loop:
    beq $a1, $zero, stats_done

    lw $t0, 0($a0)

    # Cap nhat min
    slt $t1, $t0, $v0
    beq $t1, $zero, stats_max
    move $v0, $t0

stats_max:
    # Cap nhat max
    slt $t1, $v1, $t0
    beq $t1, $zero, stats_next
    move $v1, $t0

stats_next:
    addiu $a0, $a0, 4
    addiu $a1, $a1, -1
    j stats_loop

stats_done:
    jr $ra


# =====================================
# reset_hist
# Dat hist[0..3] ve 0
#
# Tham so: khong
# Tra ve: khong
# Su dung: $t0, $t1
# Thu tuc la
# =====================================

reset_hist:
    la $t0, hist
    li $t1, 4

rh_loop:
    sw $zero, 0($t0)
    addiu $t0, $t0, 4
    addiu $t1, $t1, -1
    bne $t1, $zero, rh_loop

    jr $ra


# =====================================
# histogram
# Thong ke nhom diem
#
# Tham so:
# $a0 = dia chi mang diem word
# $a1 = so phan tu
# $a2 = dia chi grade_tab
# $a3 = dia chi hist
#
# Tra ve: khong
# Ket qua ghi trong mang hist
#
# Su dung: $a0,$a1,$t0-$t6
# Thu tuc la
# =====================================

histogram:
hist_loop:
    beq $a1, $zero, hist_done

    # Doc diem hien tai
    lw $t0, 0($a0)

    # Kiem tra diem hop le 0..10
    sltiu $t1, $t0, 11
    beq $t1, $zero, hist_next

    # Lay nhom diem tu grade_tab
    addu $t2, $a2, $t0
    lbu $t3, 0($t2)

    # Tinh dia chi hist[group]
    sll $t4, $t3, 2
    addu $t5, $a3, $t4

    # Tang bo dem
    lw $t6, 0($t5)
    addiu $t6, $t6, 1
    sw $t6, 0($t5)

hist_next:
    addiu $a0, $a0, 4
    addiu $a1, $a1, -1
    j hist_loop

hist_done:
    jr $ra


# =====================================
# check_brackets
# Kiem tra ngoac can bang
#
# Tham so:
# $a0 = dia chi chuoi .asciiz
#
# Tra ve:
# $v0 = vi tri loi, dem tu 1
# $v1 = ma loi
#
# Ma loi:
# 0 = hop le
# 1 = ngoac dong sai loai
# 2 = ngoac dong khi stack rong
# 3 = het chuoi con ngoac mo
#
# Su dung:
# $a0,$t0-$t3,$t8,$v0,$v1,$sp
#
# Khoi phuc $sp truoc khi return
# Thu tuc la
# =====================================

check_brackets:
    move $t8, $sp
    li $t0, 1

cb_scan:
    lbu $t1, 0($a0)

    # Ket thuc chuoi
    beq $t1, $zero, cb_end_string

    # Ngoac mo '('
    li $t2, 40
    beq $t1, $t2, cb_push

    # Ngoac mo '['
    li $t2, 91
    beq $t1, $t2, cb_push

    # Ngoac mo '{'
    li $t2, 123
    beq $t1, $t2, cb_push

    # Ngoac dong ')'
    li $t2, 41
    beq $t1, $t2, cb_close

    # Ngoac dong ']'
    li $t2, 93
    beq $t1, $t2, cb_close

    # Ngoac dong '}'
    li $t2, 125
    beq $t1, $t2, cb_close

cb_next:
    # Chuyen sang ky tu tiep theo
    addiu $a0, $a0, 1
    addiu $t0, $t0, 1
    j cb_scan


# =====================================
# PUSH NGOAC MO
# =====================================

cb_push:
    addiu $sp, $sp, -4
    sw $t1, 0($sp)
    j cb_next


# =====================================
# KIEM TRA NGOAC DONG
# =====================================

cb_close:
    # Stack rong?
    beq $sp, $t8, cb_error_empty

    # Pop ngoac mo gan nhat
    lw $t3, 0($sp)
    addiu $sp, $sp, 4

    # Neu la ')', can '('
    li $t2, 41
    beq $t1, $t2, cb_need_round

    # Neu la ']', can '['
    li $t2, 93
    beq $t1, $t2, cb_need_square

    # Con lai la '}', can '{'
    li $t2, 123
    bne $t3, $t2, cb_error_type
    j cb_next


cb_need_round:
    li $t2, 40
    bne $t3, $t2, cb_error_type
    j cb_next


cb_need_square:
    li $t2, 91
    bne $t3, $t2, cb_error_type
    j cb_next


# =====================================
# KET THUC CHUOI
# =====================================

cb_end_string:
    # Neu stack chua rong: loi 3
    bne $sp, $t8, cb_error_unclosed

    # Chuoi hop le
    move $v0, $zero
    move $v1, $zero
    j cb_return


# =====================================
# CAC MA LOI
# =====================================

cb_error_type:
    move $v0, $t0
    li $v1, 1
    j cb_return

cb_error_empty:
    move $v0, $t0
    li $v1, 2
    j cb_return

cb_error_unclosed:
    move $v0, $t0
    li $v1, 3


# =====================================
# KHOI PHUC STACK VA RETURN
# =====================================

cb_return:
    move $sp, $t8
    jr $ra


# =====================================
# draw_hist
# Phan mo rong: ve bieu do bang '|'
#
# Tham so:
# $a0 = dia chi mang hist
# $a1 = so nhom (4)
#
# Tra ve: khong
# Su dung: $t0-$t3,$v0,$a0
# Thu tuc la
# =====================================

draw_hist:
    move $t0, $a0
    move $t1, $a1
    move $t2, $zero

dh_group:
    beq $t1, $zero, dh_done

    # In ky tu 'g'
    li $v0, 11
    li $a0, 103
    syscall

    # In so nhom
    li $v0, 1
    move $a0, $t2
    syscall

    # In ": "
    li $v0, 4
    la $a0, msg_dh
    syscall

    # Doc so luong cua nhom
    lw $t3, 0($t0)

dh_bars:
    beq $t3, $zero, dh_newline

    # In '|'
    li $v0, 11
    li $a0, 124
    syscall

    addiu $t3, $t3, -1
    j dh_bars

dh_newline:
    li $v0, 4
    la $a0, msg_eol
    syscall

    # Sang nhom tiep
    addiu $t0, $t0, 4
    addiu $t1, $t1, -1
    addiu $t2, $t2, 1
    j dh_group

dh_done:
    jr $ra
