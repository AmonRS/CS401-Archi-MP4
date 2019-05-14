// test asm program

.data
    var1: 5 7 8 9
    var2: 98

.code
    li %r1, 56      // li rr, aa
    li %r2, 72       //
    li %r5, var2

    add %r3, %r1, %r2        // add rr, rr, rr

    sub %r4, %r2, %r1       // sub rr, rr, rr

    jmp 32                  // jmp iiiiii

    mov %r3, %r1
    mov %r4, %r2



