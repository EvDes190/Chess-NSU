asect 0x1234
step_data: ds 2
chess_field: dc 0b0000110101001110, 0b0100011001001011, 0b0100100001000110, 0b0100111000001101, 0b0100111101001111, 0b0100111101001111, 0b0100111101001111, 0b0100111101001111, 0b0100000001000000, 0b0100000001000000, 0b0100000001000000, 0b0100000001000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b1000000010000000, 0b1000000010000000, 0b1000000010000000, 0b1000000010000000, 0b1010111110101111, 0b1010111110101111, 0b1010111110101111, 0b1010111110101111, 0b0010110101101110, 0b1010011010101011, 0b1010100010100110, 0b0110111000101101
# #     rock    horse       bishop  queen       king    bishop      horse   rock
#     0b0000110101001110, 0b0100011001001011, 0b0100100001000110, 0b0100111000001101,
# #     pawn    pawn        pawn    pawn        pawn    pawn        pawn    pawn
#     0b0100111101001111, 0b0100111101001111, 0b0100111101001111, 0b0100111101001111,
# #     empty   empty       empty   empty       empty   empty       empty   empty
#     0b0100000001000000, 0b0100000001000000, 0b0100000001000000, 0b0100000001000000,
# #     empty   empty       empty   empty       empty   empty       empty   empty
#     0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000,
# #     empty   empty       empty   empty       empty   empty       empty   empty
#     0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000,
# #     empty   empty       empty   empty       empty   empty       empty   empty
#     0b1000000010000000, 0b1000000010000000, 0b1000000010000000, 0b1000000010000000,
# #     pawn    pawn        pawn    pawn        pawn    pawn        pawn    pawn
#     0b1001111110011111, 0b1001111110011111, 0b1001111110011111, 0b1001111110011111,
# #     rock    horse       bishop  queen       king    bishop      horse   rock
#     0b0001110101011110, 0b1001011010011011, 0b1001100010010110, 0b0101111000011101


asect 0
main: ext
default_handler: ext



dc main, 0
dc default_handler, 0
dc default_handler, 0
dc default_handler, 0
dc default_handler, 0
align 0x80


rsect exc_handlers

default_handler>
    halt
rsect main

main>
    jsr valid
    # ldi r0, step_data # 0x1234
    # ld r0, r0
    ldi r2, 0x001f

    ldi r7, 32
    do  
        clr r4
        clr r5
        clr r6
        # dec r0
        
        move r0, r3
        shl r3, r3, 1
        # inc r3

        ldi r1, chess_field
        add r0, r1
        ld r1, r1
        shr r1, r1, 8

        and r1, r2, r1

        shl r3, r5, 5
        or r1, r5
        
        # 

        ldi r1, chess_field
        add r0, r1
        ld r1, r1
    

        and r1, r2, r1

        inc r3
        shl r3, r6, 5
        or r1, r6
        


        ldi r4, 0x8000

        inc r0
        cmp r0, r7
        wait
    until z



    halt

valid:
    ldi r7, 0x0001
    rts
end.




