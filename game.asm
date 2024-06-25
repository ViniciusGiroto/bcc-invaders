main:
        .loop:
                ; return address for the call to the vtable method
                loadn r0, #main.loop
                push r0

                loadn r0, #vars.state.vtable
                load r1, vars.state
                add r0, r0, r1
                loadi r0, r0
                push r0

                rts

        halt

vars:
        .state: #d16 STATE_GAME
                ..vtable: #d16 screen.main, screen.game, screen.game_over

        .enemies:
                ..offset: #d16 ENEMIES_START_OFFSET
                ..is_dead: #res ENEMIES_COUNT
                ..direction: #d16 1

        .ray:
                ..offset: #d16 0

        .player:
                ..offset: #d16 0
                ..can_shoot: #d16 0
                ..lost: #d16 0
                ..score: #d16 0

enemies:
        .render:
                ; save
                push r0
                push r1
                push r2
                push r3
                push r4
                push r5
                push r6
                push r7

                loadn r0, #ENEMIES_COUNT
                xor r1, r1, r1
                loadn r2, #vars.enemies.is_dead
                load r3, vars.enemies.offset
                loadn r4, #10
                loadn r5, #40

                ..loop:
                        cmp r1, r0
                        jeq ..return
                        loadi r6, r2
                        dec r6
                        jz ..continue

                        div r6, r1, r4
                        mul r6, r6, r5
                        mod r7, r1, r4
                        shiftl0 r7, #1
                        add r6, r6, r7
                        add r6, r6, r3
                        loadn r7, #"O"
                        outchar r7, r6

                ..continue:
                        inc r1
                        inc r2

                        jmp ..loop

                ..return:
                        ; restore
                        pop r7
                        pop r6
                        pop r5
                        pop r4
                        pop r3
                        pop r2
                        pop r1
                        pop r0

                        rts

        .init:
                ; save
                push r0
                push r1
                push r2
                push r3

                loadn r0, #ENEMIES_START_OFFSET
                store vars.enemies.offset, r0

                loadn r0, #ENEMIES_COUNT
                xor r1, r1, r1
                loadn r2, #vars.enemies.is_dead
                xor r3, r3, r3

                ..loop:
                        cmp r1, r0
                        jeq ..return

                        storei r2, r3
                        inc r1
                        inc r2
                        
                        jmp ..loop

                ..return:
                        ; restore
                        pop r3
                        pop r2
                        pop r1
                        pop r0

                        rts

        .update:
                ; save
                push r0
                push r1

                load r0, vars.enemies.offset
                load r1, vars.enemies.direction
                add r0, r0, r1
                store vars.enemies.offset, r0

                ; restore
                pop r1
                pop r0

                jmp .update_direction
        
        .update_direction:
                ; save
                push r0
                push r1
                push r2
                push r3
                push r4
                push r5
                push r6
                push r7

                loadn r0, #ENEMIES_COUNT
                xor r1, r1, r1 ; r1 = 0
                loadn r2, #vars.enemies.is_dead
                load r3, vars.enemies.offset
                loadn r4, #10
                loadn r5, #40

                ..loop:
                        cmp r1, r0
                        jeq ..return
                        loadi r6, r2
                        dec r6
                        jz ..continue

                        div r6, r1, r4
                        mul r6, r6, r5
                        mod r7, r1, r4
                        shiftl0 r7, #1
                        add r6, r6, r7
                        add r6, r6, r3
                        mod r6, r6, r5 ; r6 = n // 10 * 40 + n % 40 + offset
                        mov r7, r5
                        dec r7
                        cmp r6, r7 
                        jeq ..move_left  ; enemies reached the end of the row
                        xor r7, r7, r7
                        cmp r6, r7
                        jeq ..move_right ; enemies reached the start of the row

                ..continue:
                        inc r1
                        inc r2

                        jmp ..loop

                ..move_left:
                        loadn r0, #-1
                        jmp ..change_direction

                ..move_right:
                        loadn r0, #1
                        jmp ..change_direction

                ..change_direction:
                        store vars.enemies.direction, r0
                        add r0, r3, r5
                        store vars.enemies.offset, r0

                ..return:
                        ; restore
                        pop r7
                        pop r6
                        pop r5
                        pop r4
                        pop r3
                        pop r2
                        pop r1
                        pop r0

                        rts

ray:
        .render:
                ; save
                push r0
                push r1

                loadn r0, #"|"
                load r1, vars.ray.offset
                outchar r0, r1

                ; restore
                pop r1
                pop r0

                rts

        .init:
                ; save
                push r0

                loadn r0, #-1
                store vars.ray.offset, r0

                ; restore
                pop r0

                rts

        .check_collision:
                push r0
                push r1
                push r2
                push r3
                push r4
                push r5
                push r6
                push r7

                loadn r0, #ENEMIES_COUNT
                xor r1, r1, r1 ; r1 = 0
                loadn r2, #vars.enemies.is_dead
                load r3, vars.enemies.offset
                loadn r4, #10
                loadn r5, #40

                ..loop:
                        cmp r1, r0
                        jeq ..return
                        loadi r6, r2
                        dec r6
                        jz ..continue

                        div r6, r1, r4
                        mul r6, r6, r5
                        mod r7, r1, r4
                        shiftl0 r7, #1
                        add r6, r6, r7
                        add r6, r6, r3
                        load r7, vars.ray.offset
                        cmp r6, r7
                        jne ..continue
                        loadn r1, #1
                        storei r2, r1
                        store vars.player.can_shoot, r1
                        loadn r1, #-1
                        store vars.ray.offset, r1

                        load r1, vars.player.score
                        inc r1
                        store vars.player.score, r1

                        jmp ..return

                ..continue:
                        inc r1
                        inc r2

                        jmp ..loop

                ..return:
                        ; restore
                        pop r7
                        pop r6
                        pop r5
                        pop r4
                        pop r3
                        pop r2
                        pop r1
                        pop r0

                        rts

        .update:
                ; save
                push r0
                push r1

                load r0, vars.player.can_shoot
                dec r0
                jz ..return

                load r0, vars.ray.offset
                loadn r1, #40
                sub r0, r0, r1
                cmp r0, r1
                jeg ..store
                loadn r0, #1
                store vars.player.can_shoot, r0
                loadn r0, #-1

                ..store:
                        store vars.ray.offset, r0

                ..return:
                        ; restore
                        pop r1
                        pop r0

                        ; tail-call
                        jmp .check_collision

player:
        .render:
                ; save
                push r0
                push r1

                loadn r0, #"@"
                load r1, vars.player.offset
                outchar r0, r1

                ; restore
                pop r1
                pop r0

                rts

        .init:
                ; save
                push r0

                loadn r0, #PLAYER_START_OFFSET
                store vars.player.offset, r0

                xor r0, r0, r0
                store vars.player.score, r0
                store vars.player.lost, r0

                inc r0
                store vars.player.can_shoot, r0

                ; restore
                pop r0

                rts

        .update:
                breakp
                ; save
                push r0
                push r1
                
                inchar r0
                loadn r1, #"D"
                cmp r0, r1
                jeq ..move_right

                loadn r1, #"A"
                cmp r0, r1
                jeq ..move_left

                loadn r1, #" "
                cmp r0, r1
                jeq ..shoot

                ..return:
                        ; restore
                        pop r1
                        pop r0

                        rts

                ..move_right:
                        load r0, vars.player.offset
                        loadn r1, #29 * 40 + 39
                        cmp r0, r1
                        jeq ..return
                        inc r0

                        store vars.player.offset, r0

                        jmp ..return

                ..move_left:
                        load r0, vars.player.offset
                        loadn r1, #29 * 40
                        cmp r0, r1
                        jeq ..return
                        dec r0

                        store vars.player.offset, r0

                        jmp ..return

                ..shoot:
                        load r0, vars.player.can_shoot ; if player.can_shoot else return
                        dec r0
                        jnz ..return

                        xor r0, r0, r0
                        store vars.player.can_shoot, r0
                        load r0, vars.player.offset
                        store vars.ray.offset, r0

                        jmp ..return

        .show_score:
                ; save
                push r0
                push r1
                push r2
                push r3
                push r4
                push r5

                load r0, vars.player.score
                loadn r1, #10
                loadn r4, #11
                loadn r3, #"0"
                xor r5, r5, r5

                ..loop:
                        mod r2, r0, r1
                        div r0, r0, r1
                        add r2, r2, r3
                        outchar r2, r4
                        dec r4

                        cmp r0, r5
                        jne ..loop

                ..return:
                        ; restore
                        pop r5
                        pop r4
                        pop r3
                        pop r2
                        pop r1
                        pop r0

                        rts

screen:
        .render:
                ; save
                push r0
                push r1
                push r2
                push r3
                push r4

                xor r1, r1, r1
                loadn r2, #1200

                ..loop:
                        cmp r1, r2
                        jeq ..return
                        loadi r4, r0
                        outchar r4, r1
                        inc r0
                        inc r1

                        jmp ..loop

                ..return:
                        ; restore
                        pop r4
                        pop r3
                        pop r2
                        pop r1
                        pop r0

                        rts

        .main:
                ; save
                push r0
                push r1

                loadn r0, #screens.main
                call screen.render
                loadn r1, #0x0D

                ..loop:
                        inchar r0
                        cmp r0, r1
                        jne ..loop

                loadn r0, #STATE_GAME
                store vars.state, r0

                ; restore
                pop r1
                pop r0

                rts
        
        .game:
                call ray.init
                call enemies.init
                call player.init

                loadn r7, #0

                ..loop:
                        loadn r0, #screens.clear
                        call screen.render
                        call player.show_score

                        loadn r6, #0x1000
                        cmp r6, r7
                        ceq ray.update

                        loadn r6, #0x4000
                        cmp r6, r7
                        ceq enemies.update

                        loadn r6, #0x1000
                        cmp r6, r7
                        ceq player.update

                        call ray.render
                        call enemies.render
                        call player.render

                        inc r7

                        load r1, vars.player.lost
                        dec r1

                        jnz ..loop
                rts
        
        .game_over:
                rts

screens:
        .main:
                string "                                        "
                string "                                        "
                string "                                        "
                string "              .__  __  __               "
                string "              [__)/  `/  `              "
                string "              [__)\\__.\\__.              "
                string "                                        "
                string "        ._.            .                "
                string "         | ._ .  , _. _| _ ._. __       "
                string "        _|_[ ) \\/ (_](_](/,[  _)        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "          Press enter to start          "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "

        .clear:
                string "SCORE:                                  "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "
                string "                                        "

end:

STATE_MAIN=0
STATE_GAME=1
STATE_GAME_OVER=2

ENEMIES_START_OFFSET=42
ENEMIES_COUNT=50

PLAYER_START_OFFSET=29 * 40 + 20
