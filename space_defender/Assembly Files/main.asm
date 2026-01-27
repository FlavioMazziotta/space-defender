* = $0801
        BYTE $0B, $08, $0A, $00, $9E, $32, $30, $36, $34, $00, $00, $00

* = $0810



inizio
        jsr $e544   ;pulizia schermo 
        lda #1
        sta $d020    ;colore bordo
        lda #0
        sta $d021       ;colore background
        
        lda #48
        sta $0400
        sta $0401
        lda #1
        sta $d800
        sta $d801

        lda #20
        sta $02
        lda #0
        sta $06
        sta $09
        sta $05

        lda #20
        sta $03
        lda #$04
        sta $04
        

ciclo
        ldy #50
        inc $06
wait1   ldx #200
wait2   dex
        bne wait2
        dey
        bne wait1


        lda $09
        beq bullet_end

        ldy #0
        lda #32
        sta ($07),Y
        
        sec
        lda $07
        sbc #40
        sta $07
        
        lda $08
        sbc #0
        sta $08

        lda $08
        cmp #$04
        bcs check_hit

        lda #0
        sta $09
        jmp bullet_end

check_hit
        lda $07
        cmp $03
        bne bullet_end
        lda $08
        cmp $04
        bne bullet_end
        jmp kill

bullet_end
        inc $05
        lda $05
        cmp #5
        bne check_tunnel
        
        lda #0
        sta $05
              
        ldy #0
        lda #32
        sta ($03),Y


        clc
        lda $03
        adc #40
        sta $03
        lda $04
        adc #0
        sta $04

        lda $04
        cmp #$08
        bne check_tunnel

        jsr reset_nem
        jmp coll_giocatore

check_tunnel
        jmp disegna_nem

kill
        ldy #0
        lda #32
        sta ($07),Y

        lda #0
        sta $09
        
        jsr reset_nem
        
        inc $0401
        lda $0401
        cmp #58
        bne fine_score
        
        lda #48
        sta $0401
        inc $0400
        lda $0400
        cmp #58
        bne fine_score

        lda #48
        sta $0400

fine_score
        jmp disegna_nem

disegna_nem
        ldy #0
        lda #90
        sta ($03),Y
        
        lda $03
        sta $fb
        clc
        lda $04
        adc #$D4
        sta $fc
        lda #2
        sta ($fb),Y

coll_giocatore
        clc
        lda #$c0
        adc $02
        cmp $03
        bne input
        lda $04
        cmp #$07
        bne input
        jmp game_over

input
        ldx $02
        lda #32
        sta $07c0,X
        
        jsr $ffe4
        cmp #0
        beq disegna_gioc
        
        cmp #87
        beq spara
        
        cmp #65
        beq sinistra
        
        cmp #68
        beq destra
        
        jmp disegna_gioc


spara
        lda $09
        bne disegna_gioc
        lda #1
        sta $09
        clc
        lda #$98
        adc $02
        sta $07
        lda #$07
        sta $08
        jmp disegna_gioc

sinistra 
        ldx $02
        cpx #2
        beq disegna_gioc
        dec $02
        jmp disegna_gioc

destra
        ldx $02
        cpx #37
        beq disegna_gioc
        inc $02
        jmp disegna_gioc

disegna_gioc
        ldx $02
        lda #65
        sta $07c0,X
        lda #1
        sta $dbc0,X
        
        lda $09
        beq loop_back

        ldy #0
        lda #102
        sta ($07),Y
        
        lda $07
        sta $fb
        clc
        lda $08
        adc #$D4
        sta $fc
        lda #1
        sta ($fb),Y
        
loop_back
        jmp ciclo

reset_nem
        lda #$04
        sta $04
numero_rng
        lda $06
        and #63
        cmp #38
        bcs riprova
        cmp #2
        bcc riprova
        sta $03
        rts
riprova
        inc $06
        jmp numero_rng

game_over
        ldx #0
        
schermata_finale
        lda gameover,X
        sta $05f0,X
        lda #1
        sta $d9f0,X
        inx
        cpx #9
        bne schermata_finale
schermata_attesa
        inc $d020
        jsr $ffe4
        cmp #32
        beq restart
        jmp schermata_attesa
restart 
        jmp inizio


gameover
        byte 7, 1, 13, 5, 32, 15, 22, 5, 18
        

        