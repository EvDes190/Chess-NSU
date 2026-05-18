asect 0x1234
step_data: ds 2
chess_field: dc 0b0000110101001110, 0b0100111000000000, 0b0100011000000000, 0b0100101100000000, 0b0100100000000000, 0b0100011000000000, 0b0100111000000000, 0b0000110100000000, 0b0100111100000000, 0b0100111100000000, 0b0100111100000000, 0b0100111100000000, 0b0100111100000000, 0b0100111100000000, 0b0100111100000000, 0b0100111100000000, 0b0100000000000000, 0b0100000000000000, 0b0100000000000000, 0b0100000000000000, 0b0100000000000000, 0b0100000000000000, 0b0100000000000000, 0b0100000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b1000000000000000, 0b1000000000000000, 0b1000000000000000, 0b1000000000000000, 0b1000000000000000, 0b1000000000000000, 0b1000000000000000, 0b1000000000000000, 0b1001111100000000, 0b1001111100000000, 0b1001111100000000, 0b1001111100000000, 0b1001111100000000, 0b1001111100000000, 0b1001111100000000, 0b1001111100000000, 0b0001110100000000, 0b0101111000000000, 0b1001011000000000, 0b1001101100000000, 0b1001100000000000, 0b1001011000000000, 0b0101111000000000, 0b0001110100000000
# #   rock                horse               bishop              queen               king                bishop              horse               rock
#     0b0000000000001101, 0b0000000001001110, 0b0000000001000110, 0b0000000001001011, 0b0000000001001000, 0b0000000001000110, 0b0000000001001110, 0b0000000000001101,
# #   pawn                pawn                pawn                pawn                pawn                pawn                pawn                pawn
#     0b0000000001001111, 0b0000000001001111, 0b0000000001001111, 0b0000000001001111, 0b0000000001001111, 0b0000000001001111, 0b0000000001001111, 0b0000000001001111,
# #   empty               empty               empty               empty               empty               empty               empty               empty
#     0b0000000001000000, 0b0000000001000000, 0b0000000001000000, 0b0000000001000000, 0b0000000001000000, 0b0000000001000000, 0b0000000001000000, 0b0000000001000000,
# #   empty               empty               empty               empty               empty               empty               empty               empty
#     0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000,
# #   empty               empty               empty               empty               empty               empty               empty               empty
#     0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000, 0b0000000000000000,
# #   empty               empty               empty               empty               empty               empty               empty               empty
#     0b0000000010000000, 0b0000000010000000, 0b0000000010000000, 0b0000000010000000, 0b0000000010000000, 0b0000000010000000, 0b0000000010000000, 0b0000000010000000,
# #   pawn                pawn                pawn                pawn                pawn                pawn                pawn                pawn
#     0b0000000010011111, 0b0000000010011111, 0b0000000010011111, 0b0000000010011111, 0b0000000010011111, 0b0000000010011111, 0b0000000010011111, 0b0000000010011111,
# #   rock                horse               bishop              queen               king                bishop              horse               rock
#     0b0000000000011101, 0b0000000001011110, 0b0000000010010110, 0b0000000010011011, 0b0000000010011000, 0b0000000010010110, 0b0000000001011110, 0b0000000000011101


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
    ldi r7, 0x0010  # white is a first color

    jsr init

    do
        jsr ready_up
        wait
        jsr ready_down

        ldi r0, step_data
        ld r0, r0
        push r0         # save step information

        ldi r3, 0x003f  # mask 0b00111111

        shr r0, r2, 6

        and r3, r0, r1  # r1 - from
        and r3, r2      # r2 - to

        jsr step_handler
        wait
        
        ldi r0, 0x0001
        tst r0
    until z

    halt

# USED REGISTERS: r0, r1, *r2, r3, r4, r5, r6, r7
#
# INPUTS:   r0 - step info
#           r1 - from   0b00YYYXXX
#          *r2 - to     0b00YYYXXX 
# OUPUTS: update r5, r6 and r7's status flags
step_handler:
    push r0
    push r1

    if
        ldi r4, chess_field
        shl r2, r3, 1
        inc r3
        add r3, r4
        ld r4, r4       # to data

        ldi r3, 0x001f
        and r3, r4

        ldi r3, 0x000f

        bit r3, r4
    is nz
        if
            ldi r3, 0x0010
            and r3, r4
            and r7, r3

            xor r4, r3
        is z

            jsr set_invalid
            rts
        fi
    fi

    ldi r0, chess_field
    shl r1, r4, 1
    inc r4
    add r4, r0
    ld r0, r0       # from data

    ldi r4, 0x000f
    and r4, r0
    if
        cmp r0, 15      # 
    is z                # PAWN
        if
            jsr check_pawn
        is z
            pop r1


            # =========================
            # check for border of field
            if
                move r0, r4
                cmp r4, 7
            is z
                clr r4
            fi
            if  
                tst r4
            is z

                # switch figure after get a border of field
                pop r3
                push r3
                jsr pawn_switch_figure

            fi
            # =========================


            jsr from_to_default
            jsr clear_from
            jsr set_r5r6
            jsr time_up_inspect
            jsr change_color
        fi
        pop r0
        rts
    fi
    
    if
        cmp r0, 14      # HORSE
    is z
        if
            jsr check_horse
        is z
            pop r1
            
            jsr from_to_default
            jsr clear_from
            jsr set_r5r6
            jsr time_up_inspect
            jsr change_color
        fi
        rts
    fi

    if
        cmp r0, 6       # BISHOP
    is z

        if
            jsr check_bishop
        is z
            pop r1
            
            jsr from_to_default
            jsr clear_from
            jsr set_r5r6
            jsr time_up_inspect
            jsr change_color
        fi
        rts
    fi

    if
        cmp r0, 13      # ROCK
    is z
        # TODO
        # castling handler

        if
            jsr check_rock
        is z
    
            pop r1

            jsr from_to_default
            jsr clear_from
            jsr set_r5r6
            jsr time_up_inspect
            jsr change_color
        fi
        rts
    fi

    if
        cmp r0, 11
    is z
        if
            jsr check_queen
        is z
            pop r1

            jsr from_to_default
            jsr clear_from
            jsr set_r5r6
            jsr time_up_inspect
            jsr change_color
        fi
        rts
    fi

    if
        cmp r0, 8
    is z
        if
            jsr check_king
        is z
            pop r1

            jsr from_to_default
            jsr clear_from
            jsr set_r5r6
            jsr time_up_inspect
            jsr change_color
        fi
        rts
    fi
    pop r0
rts

# USED REGISTERS: r0, r1, *r2, r3, r4, r7
# INPUTS:   r1 - from   0b00YYYXXX
#          *r2 - to     0b00YYYXXX 
#           r7 - color  0b000X0000
#
# OUTPUTS:  if step valid: z = 1
#           else: set r7 to invalid flag
check_pawn:
    move r1, r3
    if
        ldi r0, chess_field

        shl r2, r4, 1
        inc r4
        add r0, r4
        ld r4, r4       # to data

        ldi r0, 0x000f
        bit r0, r4
    is nz                   # if true -> capturing, white or black
        shr r1, r0, 3   # Y coordinate
        ldi r4, 0x0007
        and r4, r1      # X coordinate

        push r0
        push r1
        if

            jsr pawn_forward_step
            inc r1          # right
                            # step

            jsr check_position
        is cc
            if
                jsr check_same_position
            is z
                pop r0
                pop r0
            
                rts
            fi
        fi

        if
            pop r1
            pop r0

            jsr pawn_forward_step
            dec r1          # left
                            # step

            jsr check_position
        is cc
            if
                jsr check_same_position
            is z
                rts
            fi
        fi

        jsr set_invalid
        rts             # return if pawn try capturing not by right-up or left-up steps
    
    else
        shr r1, r0, 3   # Y coordinate
        ldi r4, 0x0007
        and r4, r1      # X coordinate
        if
            jsr pawn_forward_step
            jsr check_r0_position

        is cc
            if
                jsr check_same_position
            is z
                rts
            fi
        fi
        ##
        if
            push r0
            shl r0, r4, 3
            or r1, r4
            shl r4, r4, 1
            inc r4
            ldi r0, chess_field
            add r4, r0
            ld r0, r0

            ldi r4, 0x000f
            bit r4, r0

            pop r0
        is nz
            jsr set_invalid
            rts
        fi
        ##
        if
            jsr pawn_forward_step
            jsr check_r0_position
        is cc
            if  
                jsr check_same_position
            is z
                if  
                    move r3, r0
                    ldi r4, chess_field
                    shl r0, r0, 1
                    inc r0
                    add r0, r4
                    ld r4, r4

                    ldi r0, 0x0020

                    bit r0, r4

                is z

                    rts
                fi
                
                
            fi
        fi

    fi

    jsr set_invalid
rts

# USED REGISTERS:   r0, r4, *r7
# UPDATE FLAGS:     C, V, Z, N
# 
# INPUTS:   r0 - Y coordinate
#          *r7 - current color  0b000X0000
# OUTPUTS:  if black:   pawn is down (dec r0)
#           else:       pawn is up (inc r0)
pawn_forward_step:
    if  
        ldi r4, 0x0010
        bit r7, r4
    is z            # if color = white: z = 0
        inc r0
    else
        dec r0
    fi
rts


# USED REGISTERS: r0, *r1, r3, r4
#
# INPUTS:  *r1 - from   0b00YYYXXX
#           r3 - step info
#
# OUPUTS:   update field
pawn_switch_figure:
    ldi r0, chess_field
    shl r1, r4, 1
    inc r4
    add r4, r0  # r0 - from address
    ld r0, r4   # r4 - from data


    shl r3, r3, 8   # 0xX000 -> 0x00X0
    shl r3, r3, 4   # 0x00X0 -> 0x000X

    push r3
    ldi r3, 0xfff0
    and r3, r4
    pop r3

    or r3, r4

    st r0, r4
rts

# USED REGISTERS: 
# INPUTS:   r1 - from   0b00YYYXXX
#          *r2 - to     0b00YYYXXX 
#           r7 - color  0b000X0000
#
# OUTPUTS:  if step valid: z = 1
#           else: set r7 to invalid flag
check_horse:
    shr r1, r0, 3   # Y coordinate
    ldi r4, 0x0007
    and r4, r1      # X coordinate
    
    move r0, r3
    move r1, r4

    # east  =======
    if
        add r1, 2       
        jsr check_r1_position
    is cc
        if
            add r0, 1
            jsr check_r0_position
        is cc
            if
                jsr check_same_position
            is z

                rts
            fi
        fi
        move r3, r0
        if
            add r0, -1
            jsr check_r0_position
        is cc
            if
                jsr check_same_position
            is z

                rts
            fi
        fi
    fi

    # east  =======
    move r3, r0
    move r4, r1
    if
        add r1, -2       
        jsr check_r1_position
    is cc
        if
            add r0, 1
            jsr check_r0_position
        is cc
            if
                jsr check_same_position
            is z
                rts
            fi
        fi
        move r3, r0
        if
            add r0, -1
            jsr check_r0_position
        is cc
            if
                jsr check_same_position
            is z
                rts
            fi
        fi
    fi


    # north =======
    move r3, r0
    move r4, r1

    if
        add r0, -2
        jsr check_r0_position
    is cc
        if
            add r1, 1
            jsr check_r1_position
        is cc
            if
                jsr check_same_position
            is z
                rts
            fi
        fi
        move r4, r1
        if
            add r1, -1
            jsr check_r1_position
        is cc
            if
                jsr check_same_position
            is z
                rts
            fi
        fi
    fi

    # south =======
    move r3, r0
    move r4, r1
    
    if
        add r0, 2
        jsr check_r0_position
    is cc
        if
            add r1, 1
            jsr check_r1_position
        is cc
            if
                jsr check_same_position
            is z
                rts
            fi
        fi
        move r4, r1
        if
            add r1, -1
            jsr check_r1_position
        is cc
            if
                jsr check_same_position
            is z
                rts
            fi
        fi
    fi

    jsr set_invalid
rts

check_bishop:
    if
        ldi r0, 0x0007
        shl r2, r3, 3
        and r3, r0, r3

        shl r1, r0, 3

        cmp r0, r3
    is cc
        ldi r3, 0x0001  # 1
    else
        ldi r3, 0xffff  # -1
    fi


    if
        push r0

        ldi r0, 0x0007
        and r0, r1
        and r0, r2, r4

        pop r0

        cmp r1, r4
    is cc
        ldi r4, 0x0001  # 1
    else
        ldi r4, 0xffff  # -1
    fi

    if
        jsr shaft
    is z
        rts
    fi

    jsr set_invalid
rts

# USED REGISTERS: 
# INPUTS:   r1 - from   0b00YYYXXX
#          *r2 - to     0b00YYYXXX 
#           r7 - color  0b000X0000
#
# OUTPUTS:  if step valid: z = 1
#           else: set r7 to invalid flag
check_rock:

    # return if to and from same
    if
        cmp r1, r2
    is z                    
        jsr set_invalid
        rts
    fi


    # =================
    # if fromY = toY:       shiftY = 0
    # else if fromY < toY:  shiftY = 1
    # else:                 shiftY = -1
    if
        ldi r0, 0x0007
        shl r2, r3, 3
        and r3, r0, r3

        shl r1, r0, 3

        cmp r0, r3
    is z
        ldi r3, 0x0000      # 0
    else
        if
        is cs
            ldi r3, 0x0001  # 1
        else
            ldi r3, 0xffff  # -1
        fi
    fi

    # if fromX = toX:       shiftX = 0
    # else if fromX < toX:  shiftX = 1
    # else:                 shiftX = -1
    if
        push r0

        ldi r0, 0x0007
        and r0, r1
        and r0, r2, r4

        pop r0

        cmp r1, r4
    is z
        ldi r4, 0x0000      # 0
    else
        if
        is cs
            ldi r4, 0x0001  # 1
        else
            ldi r4, 0xffff  # -1
        fi
    fi
    # =================


    # check to exclude diagonal moves
    if
        push r0
        push r1
        add r3, r4, r0
        ldi r1, 0x0001

        bit r0, r1

        pop r1
        push r1
    is z
        jsr set_invalid
        rts
    fi

    if
        jsr shaft
    is z
        rts
    fi

    jsr set_invalid
rts

check_queen:
    # return if to and from same
    if
        cmp r1, r2
    is z                    
        jsr set_invalid
        rts
    fi


    # =================
    # if fromY = toY:       shiftY = 0
    # else if fromY < toY:  shiftY = 1
    # else:                 shiftY = -1
    if
        ldi r0, 0x0007
        shl r2, r3, 3
        and r3, r0, r3

        shl r1, r0, 3

        cmp r0, r3
    is z
        ldi r3, 0x0000      # 0
    else
        if
        is cs
            ldi r3, 0x0001  # 1
        else
            ldi r3, 0xffff  # -1
        fi
    fi

    # if fromX = toX:       shiftX = 0
    # else if fromX < toX:  shiftX = 1
    # else:                 shiftX = -1
    if
        push r0

        ldi r0, 0x0007
        and r0, r1
        and r0, r2, r4

        pop r0

        cmp r1, r4
    is z
        ldi r4, 0x0000      # 0
    else
        if
        is cs
            ldi r4, 0x0001  # 1
        else
            ldi r4, 0xffff  # -1
        fi
    fi
    # =================
    
    if
        jsr shaft
    is z
        rts
    fi

    jsr set_invalid
rts

# USED REGISTERS: r0, r1, *r2, r3, r4, r7
# INPUTS:   r1 - from   0b00YYYXXX
#          *r2 - to     0b00YYYXXX 
check_king:
    shl r1, r0, 3
    ldi r3, 0x0007
    and r3, r1

    move r0, r3
    move r1, r4

    if
        inc r1
        jsr check_r1_position
    is cc
        if
            inc r0
            jsr check_r0_position
        is cc
            if
                jsr check_same_position
            is z
                rts
            fi
        fi

        move r3, r0
        if
            jsr check_same_position
        is z
            rts
        fi

        move r3, r0
        if
            dec r0
            jsr check_r0_position
        is cc
            if
                jsr check_same_position
            is z
                rts
            fi
        fi
    fi
    move r3, r0
    move r4, r1

    if
        inc r0
        jsr check_r0_position
    is cc
        if
            jsr check_same_position
        is z
            rts
        fi
    fi
    move r3, r0
    if
        dec r0
        jsr check_r0_position
    is cc
        if
            jsr check_same_position
        is z
            rts
        fi
    fi
    move r3, r0

    if
        dec r1
        jsr check_r1_position
    is cc
        if
            inc r0
            jsr check_r0_position
        is cc
            if
                jsr check_same_position
            is z
                rts
            fi
        fi

        move r3, r0
        if
            jsr check_same_position
        is z
            rts
        fi

        move r3, r0
        if
            dec r0
            jsr check_r0_position
        is cc
            if
                jsr check_same_position
            is z
                rts
            fi
        fi
    fi

    jsr set_invalid
rts


# USED REGISTERS: r0, r1, r2, r3, r4, r5, r6
#
# INPUTS:   r0 - Y coordinate
#           r1 - X coordinate
#          *r2 - 0b00YYYXXX
#          *r3 - Y shift
#          *r4 - X shift
#
# OUTPUTS:  if figure can reach destination:    z = 1
#           else:                               z = 0
shaft:
    do
        add r3, r0
        add r4, r1
        if
            jsr check_position
        is cs
            ldi r0, 0x0000
            tst r0
            rts
        fi

        if
            jsr check_same_position
        is z
            rts
        fi


        push r3
        push r4
        if              # check for collision
            push r3
            push r4

            shl r0, r3, 3
            or r1, r3
            inc r3

            ldi r4, chess_field
            add r3, r4

            ld r4, r4

            ldi r3, 0x000f

            bit r3, r4
        is nz
            pop r4
            pop r3

            ldi r0, 0x0000
            tst r0
            rts
        fi
        pop r4
        pop r3

    until z
rts

# USED REGISTERS: r0, r7
# INPUTS: r7
set_invalid:
    push r0

    ldi r0, 0x1118
    and r0, r7
    ldi r0, 0x0004
    or r0, r7

    pop r0
    rts
rts

# USED REGISTERS: *r0, *r1, *r2, *r3
# INPUTS:  *r0 - Y coordinate
#          *r1 - X coordinate
#          *r2 - 0b00YYYXXX
# OUTPUTS:  C, V, Z, N
#           if same: z = 1
#           else: z = 0
check_same_position:
    push r0
    push r3
    shl r0, r3, 3
    or r1, r3
    cmp r2, r3
    pop r3
    pop r0
rts

# CHECK FOR VALID POSITION
# USED REGISTERS: *r0, *r1
# UPDATE FLAGS: C, V, Z, N
#
# INPUTS:   *r0, *r1 - coordinate on row and major (order not important)
# OUTPUTS:  if 0 <= r0, r1 <= 7: cs = 0, cc = 1
#           else: cs = 1, cc = 0
check_position:
    if
        cmp r0, 8
    is cs
        rts
    fi

    if
        cmp r1, 8
    is cs
        rts
    fi
rts

# CHECK r0 REGISTER FOR VALID COORDINATE
# USED REGISTERS: *r0
# UPDATE FLAGS: C, V, Z, N
#
# INPUTS:   *r0 - coordinate
# OUTPUTS:  if 0 <= r0 <= 7: cs = 0, cc = 1
#           else: cs = 1, cc = 0
check_r0_position:
    cmp r0, 8
rts

# CHECK r1 REGISTER FOR VALID COORDINATE
# USED REGISTERS: *r1
# UPDATE FLAGS: C, V, Z, N
#
# INPUTS:   *r1 - coordinate
# OUTPUTS:  if 0 <= r1 <= 7: cs = 0, cc = 1
#           else: cs = 1, cc = 0
check_r1_position:
    cmp r1, 8
rts

# USED REGISTERS: r0, *r1, r3
# INPUTS:  *r1 - 0b00YYYXXX
# 
# OUTPUTS: update chess_field
clear_from:
    ldi r0, chess_field
    shl r1, r3, 1
    inc r3
    add r3, r0
    
    clr r3
    st r0, r3
rts

# USED REGISTERS: r0, *r1, *r2, r3, r4
# INPUTS:  *r1 - from   0b00YYYXXX
#          *r2 - to     0b00YYYXXX
# OUTPUTS: update chess_field
from_to_default:
    ldi r0, chess_field
    shl r1, r3, 1
    inc r3
    add r3, r0
    ld r0, r0       # from data

    ldi r3, 0x0020
    or r3, r0       # set step-flag on from data

    ldi r3, chess_field
    shl r2, r4, 1
    inc r4
    add r4, r3

    st r3, r0
rts

# USED REGISTERS: r0, *r1, *r2, r3, r4, r5, r6
# INPUTS:  *r1 - from   0b00YYYXXX
#          *r2 - to     0b00YYYXXX
# OUTPUTS:  r5, r6
set_r5r6:
    ldi r4, 0x001f

    ldi r0, chess_field
    shl r1, r3, 1
    inc r3
    add r3, r0
    ld r0, r0       # from data
    and r4, r0

    shl r1, r5, 5
    or r0, r5

    ldi r0, chess_field
    shl r2, r3, 1
    inc r3
    add r3, r0
    ld r0, r0
    and r4, r0

    shl r2, r6, 5
    or r0, r6
rts

# USED REGISTERS: r0, r7
#
# INPUTS:   r7
# OUTPUTS:  r7
change_color:
    ldi r0, 0x0010
    xor r0, r7
rts

# USED REGISTERS: r0, r7
#
# INPUTS:   r7
# OUTPUTS:  r7
time_up_inspect:
    ldi r0, 0x8000
    xor r0, r7
    xor r0, r7
rts

# USED REGISTERS: *r0, r7
ready_up:
    push r0
    ldi r0, 0x4000
    or r0, r7
    pop r0
rts

# USED REGISTERS: *r0, r7
ready_down:
    push r0
    ldi r0, 0xbfff
    and r0, r7
    pop r0
rts

# INIT FIELD FUNCTIONS
# USED REGISTERS: r0, r1, r2, r3, r4, r5, r6, r7
# UPDATE FLAGS: C, V, Z, N
init:
    ldi r2, 0x001f  # mask

    clr r0
    ldi r4, 0x0010
    jsr init_2rows

    ldi r0, 0x0030
    ldi r4, 0x0040
    jsr init_2rows
rts

init_2rows:
    do  
        clr r5
        clr r6
        clr r3

        ldi r1, chess_field
        shl r0, r3, 1
        inc r3
        ldw r1, r3, r1
        # add r3, r1
        # ld r1, r1

        and r1, r2, r1

        shl r0, r5, 5
        or r1, r5
        
        inc r0
        # 

        ldi r1, chess_field
        shl r0, r3, 1
        inc r3
        ldw r1, r3, r1
        # add r3, r1
        # ld r1, r1

        and r1, r2, r1


        shl r0, r6, 5
        or r1, r6

        inc r0
        push r0
        jsr time_up_inspect
        pop r0
        cmp r0, r4
        wait
    until z
rts
# INIT FIELD FUNCTIONS END


# USED REGISTERS: *r0, r7
debug12:
    push r0
    ldi r0, 0x1000
    or r0, r7
    pop r0
rts

# USED REGISTERS: *r0, r7
debug13:
    push r0
    ldi r0, 0x2000
    or r0, r7
    pop r0
rts



end.