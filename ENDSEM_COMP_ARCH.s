@d1: .word 0x7ff50000, 0x7fe40000
d1: .word 0x000c0000, 0x7ff20000

d2: .word 0x80000000, 0x7ff80000, 0x0007ffff

bitsoffirst: .word 0,0,0
bitsofsec: .word 0,0,0
bitsofRes: .word 0,0,0
finalRes: .word 0

sig : .word 0,0
expo_num_diff: .word 0,0

#exponents
big_small : .word 0,0
big_small_s: .word 0,0 

renormalise_sig_sub : .word 0

mlt_bits : .word 0,0,0

add_address: .word 0

.global _start

subtraction:
stmfd sp! ,{r0-r10,lr}
ldr r0,=bitsoffirst
ldr r1,[r0,#4]!
ldr r2,=bitsofsec
ldr r3,[r2,#4]!
ldr r5,=big_small
ldr r4,[r5]
#checking whether exponent of first number is bigger or second
cmp r1,r4


mov r14,r15
add r14,r14,#8

beq check_SB_1
bne check_SB_2

ldr r0,=big_small_s
ldr r1,[r0]
ldr r2,[r0,#4]!
ldr r3,=expo_num_diff
ldr r4,[r3,#4]!

#right shifting the signifcand with smaller exponent
lsr r2,r4
sub r1,r1,r2
ldr r5,=renormalise_sig_sub
str r1,[r5]
cmp r1,#0x00080000
mov r14,r15
add r14,r14,#4
bmi renormalise_sub
ldr r1,[r5]
sub r1,r1,#0x00080000
sub r3,r3,#4
ldr r4,[r3]
lsl r4,#19
orr r1,r1,r4
ldr r3,=bitsofRes
ldr r4,[r3]
lsl r4,#31
orr r1,r1,r4
ldr r0,=finalRes
str r1,[r0]
ldmfd sp!,{r0-r10,pc}

check_SB_1:
stmfd sp! ,{r0-r10,lr}
ldr r0,=bitsoffirst
ldr r1,[r0]
ldr r8,=bitsofRes
str r1,[r8]
ldmfd sp!,{r0-r10,pc}

check_SB_2:
stmfd sp! ,{r0-r10,lr}
ldr r2,=bitsofsec
ldr r3,[r2]
ldr r8,=bitsofRes
str r3,[r8]
ldmfd sp!,{r0-r10,pc}

renormalise_sub:
stmfd sp! ,{r0-r10,lr}
ldr r0,=renormalise_sig_sub
ldr r1,[r0]
ldr r5,=expo_num_diff
ldr r6,[r5]
loop:
lsl r1,#1
sub r6,r6,#1
cmp r1,#0x00080000
bmi loop
str r6,[r5]
str r1,[r0]
ldmfd sp!,{r0-r10,pc}


addition:
stmfd sp! ,{r0-r10,lr}
bl add
ldr r0,=bitsofRes
ldr r2,[r0,#4]!
ldr r1,=expo_num_diff
ldr r3,[r1]
lsl r3,#19
orr r2,r2,r3
ldr r1,=bitsofsec
ldr r3,[r1]
lsl r3,#31
orr r2,r2,r3
ldr r1,=finalRes
str r2,[r1]
bl result
ldmfd sp!,{r0-r10,pc}

add:
stmfd sp! ,{r0-r10,lr}
ldr r0,=expo_num_diff
ldr r1,[r0,#4]!
ldr r0,=big_small_s
ldr r2,[r0]
ldr r3,[r0,#4]!
lsr r3,r1
add r2,r2,r3
cmp r2,#0x00100000
mov r14,r15
add r14,r14,#4
bpl renormalize
sub r2,#0x00080000
ldr r1,=bitsofRes
str r2,[r1,#4]!
ldmfd sp!,{r0-r10,pc}

renormalize:
stmfd sp! ,{r0,r1,r3,lr}
lsr r2,#1
ldr r1,=expo_num_diff
ldr r3,[r1]
add r3,r3,#1
str r3,[r1]
ldmfd sp!,{r0,r1,r3,pc}

significand:
stmfd sp! ,{r0-r10,lr}
ldr r0,=bitsoffirst
ldr r1,=bitsofsec
add r0,r0,#8
add r1,r1,#8
ldr r2,[r0]
ldr r3,[r1]
mov r5,#0x80000
add r2,r2,r5
add r3,r3,r5
ldr r4,=sig
str r2,[r4]
add r4,r4,#4
#lsr r3,#3
str r3,[r4]
ldmfd sp!,{r0-r10,pc}


bit_extract:
stmfd sp! ,{r0-r10,lr}
ldr r5,=d2
ldr r6,[r5]
ldr r0,=bitsoffirst
ldr r1,=bitsofsec

and r4,r2,r6
lsr r4,#31
and r8,r3,r6
lsr r8,#31
str r4,[r0]
str r8,[r1]

add r0,r0,#4
add r1,r1,#4
add r5,r5,#4
ldr r6,[r5]

and r4,r2,r6
lsr r4,#19
and r8,r3,r6
lsr r8,#19
str r4,[r0]
str r8,[r1]

add r0,r0,#4
add r1,r1,#4
add r5,r5,#4
ldr r6,[r5]

and r4,r2,r6
and r8,r3,r6
str r4,[r0]
str r8,[r1]

ldmfd sp!,{r0-r10,pc}

exponent:
stmfd sp! ,{r0-r10,lr}
ldr r0,=bitsoffirst
add r0,r0,#4
ldr r1,[r0]
ldr r2,=bitsofsec
add r2,r2,#4
ldr r3,[r2]
mov r9,r1
mov r10,r3
lsl r3,#20
asr r3,#20
lsl r1,#20
asr r1,#20
cmp r1,r3
bpl first_is_big
bmi second_is_big
ldmfd sp!,{r0-r10,pc}

first_is_big:
stmfd sp! ,{r0-r10,lr}
ldr r4,=expo_num_diff
str r9,[r4]
sub r1,r1,r3
str r1,[r4,#4]!

ldr r5,=big_small
str r9,[r5]
str r10,[r5,#4]!

ldr r1,=big_small_s
ldr r2,=sig
ldr r3,[r2]
str r3,[r1]
ldr r3,[r2,#4]!
str r3,[r1,#4]!
ldmfd sp!,{r0-r10,pc}

second_is_big:
stmfd sp! ,{r0-r10,lr}
ldr r4,=expo_num_diff
str r10,[r4]
sub r1,r3,r1
str r1,[r4,#4]!

ldr r5,=big_small
str r10,[r5]
str r9,[r5,#4]!

ldr r1,=big_small_s
ldr r2,=sig
ldr r3,[r2,#4]!
str r3,[r1]
sub r2,r2,#4
ldr r3,[r2]
str r3,[r1,#4]!
ldmfd sp!,{r0-r10,pc}


sgn_P:
stmfd sp! ,{r0-r10,lr}
mov r1,#0
ldr r6,=mlt_bits
str r1,[r6]
ldmfd sp!,{r0-r10,pc}

#renormalize for multiplication
RNM:
stmfd sp! ,{r0,lr}
lsr r2,r2,#1
add r1,r1,#1
ldmfd sp!,{r0,pc}

nfp_mul:
ldr r0,=d1
ldr r2,[r0]
add r0,r0,#4
ldr r3,[r0]

#####extractingBITS######
bl bit_extract

#####storing significand####
bl significand

#####Analysing the exponent#####
bl exponent

#### multiplication ####
stmfd sp! ,{r0-r10,lr}
ldr r6,=mlt_bits
ldr r2,=bitsoffirst
ldr r3,[r2]
ldr r0,=bitsofsec
ldr r4,[r0]
cmp r3,r4
mov r14,r15
add r14,r14,#12
#storing the sign bit of result
beq sgn_P
mov r7,#1
str r7,[r6]
#exponent
ldr r0,=big_small
ldr r1,[r0]
ldr r2,[r0,#4]!
add r1,r1,r2 
#r1 contains exponent bits

#multypling the significand##
ldr r0,=big_small_s
ldr r2,[r0]
ldr r3,[r0,#4]!
lsr r2,#4
lsr r3,#4
mul r2,r2,r3
#checking for renormalising
cmp r2,#0x80000000
mov r14,r15
add r14,r14,#4
bpl RNM
lsl r1,#19
lsr r2,#11
sub r2,r2,#0x0080000
orr r2,r2,r1
ldr r6,=mlt_bits
ldr r7,[r6]
lsl r7,#31
orr r2,r2,r7
ldr r9,=mlt_bits
str r2,[r9]
ldr r1,=add_address
ldr r14,[r1]
ldmfd sp!,{r0-r10,pc}

nfp_add:
stmfd sp! ,{r0-r10,lr}
######comparing sign bits
ldr r2,=bitsoffirst
ldr r3,[r2]
ldr r0,=bitsofsec
ldr r4,[r0]
cmp r3,r4
mov r14,r15
add r14,r14,#8
bne subtraction
beq addition
result :
ldr r0,=finalRes
ldr r1,[r0]
ldr r3,=mlt_bits
ldr r2,[r3]
ldmfd sp!,{r0-r10,pc}

_start:
mov r14,r15
add r14,r14,#12
ldr r1,=add_address
str r14,[r1]
bl nfp_mul
bl nfp_add
ldr r0,=finalRes
ldr r1,[r0]
ldr r3,=mlt_bits
ldr r2,[r3]

#r1 contains the ans for addition
#r2 contains the ans for multiplication













