* = $0801
        BYTE $0B, $08, $0A, $00, $9E, $32, $30, $36, $34, $00, $00, $00

* = $0810



inizio
        jsr $e544   ;pulizia schermo 
        lda #1
        sta $d020    ;colore bordo
        lda #0
        sta $d021       ;colore background
        
        lda #48         ;setto il contatore (unità) a 0 
        sta $0400
        sta $0401       ;contatore (decine)
        lda #1
        sta $d800       ;colore bianco per il counter
        sta $d801

        lda #20         ;posizione di partenza del player
        sta $02         ; indirizzo zero page player
        lda #0          ;setto a 0 l'rng'
        sta $06         ; zero page per il contatore rng
        sta $09         ; zero page per il flag del proiettile
        sta $05         ;timer di rallentamento per il nemico

        lda #20         ;posizione iniziale orizzontale primo nemico
        sta $03         ;byte basso nemico
        lda #$04        ;posizione iniziale nemico verticale
        sta $04         ;byte alto
        

ciclo
        ldy #50         ;clock esterno
        inc $06         ; incremento rng ad ogni frame
wait1   ldx #200        ; clock interno
wait2   dex             
        bne wait2       ;se x != 0 torna a wait2
        dey             ; decremento y
        bne wait1       ;se y != 0 torna a wait1


        lda $09         ;check flag del proiettile
        beq bullet_end  ;se è 0 salta la parte del movimento del proiettile

        ldy #0          ;setto a 0 l'indice Y
        lda #32         ; carico il carattere vuoto
        sta ($07),Y     ;indirizzamento indiretto scrivo dove puntano $07 e $08
        
        sec             ;setto il carry per la sottrazione
        lda $07         ;carico byte basso proiettile
        sbc #40         ;sottraggo 40 (scendo di una riga)
        sta $07         ;carico la nuova posizione
        
        lda $08         ;carico byte alto
        sbc #0          ;gestisco il riporto se è necessario
        sta $08         ;ricarico la posizione

        lda $08         ;carico byte alto
        cmp #$04        ;confronto con la parte alta dello schermo
        bcs check_hit   ;se >= $04, è dentro lo schermo quindi controllo le collisioni

        lda #0          ;proiettile uscito disattivo il nemico
        sta $09
        jmp bullet_end  ;passo a gestire il nemico

check_hit
        lda $07         ;carico byte basso proiettile
        cmp $03         ;confronto con byte basso nemico
        bne bullet_end  ;se sono diversi passo alla gestione del nemico
        lda $08         ;controllo i byte alti proiettile e nemico
        cmp $04 
        bne bullet_end  ;se sono diversi passo alla gestione del nemico
        jmp kill        ;altrimenti vado al sbr della kill
        
bullet_end
        inc $05         ;incremento timer nemico
        lda $05         ;aggiorno il valore
        cmp #5          ;controllo poiché nemico si muove ogni 5 cicli
        bne check_tunnel        ;se non si deve spostare salto al disegno nella stessa posizione
        
        lda #0          ;resetto il timer
        sta $05
              
        ldy #0          ;cancello graficamente il vecchio nemico
        lda #32         
        sta ($03),Y     ;indirizzamento indiretto disegno uno spazio vuoto dove puntano $07 e $08


        clc             ;movimento del nemico, pulisco il bit per il carry
        lda $03         ;carico byte basso
        adc #40         ;aggiungo 40 (spostamento verso il basso)
        sta $03         ;ricarico la pos
        lda $04         ;byte alto
        adc #0          ;gestisco il riporto se necessario
        sta $04         ; ricarico posizione

        lda $04         ;check per vedere se uscito dalla parte bassa dello schermo
        cmp #$08
        bne check_tunnel        ;se non è uscito procede

        jsr reset_nem           ;altrimenti salta al reset
        jmp coll_giocatore      ;saltando il disegno per un frame

check_tunnel
        jmp disegna_nem

kill
        ldy #0          ;ripulisco indice Y
        lda #32         ; spazio vuoto per cancellazione nemico
        sta ($07),Y     ; indirizzamento indiretto per scrivere dove puntano $07 e $08

        lda #0          ;resetto il flag del proiettile
        sta $09
        
        jsr reset_nem   ;con la kill salto al reset del nemico
        
        inc $0401       ;incremento i lvalore delle unità
        lda $0401
        cmp #58         ;se le unità non sono ancora arrivate a 9 proseguo
        bne fine_score
        
        lda #48         ;se sono arrivate a 9, "ridisegno" lo 0 nelle unità
        sta $0401
        inc $0400       ;incremento le decine
        lda $0400
        cmp #58         ;se decine non sono 9 prosegue
        bne fine_score

        lda #48         ;se sono al valore 9 resetto tutto a 0
        sta $0400

fine_score
        jmp disegna_nem 

disegna_nem
        ldy #0          
        lda #90         ;sprite nemice rombo
        sta ($03),Y     ;indirizzamento indiretto per disegnare dove puntano $03 e $04
                
        lda $03         ;carico byte basso
        sta $fb         ;carico il byte b in una casella di memoria temporanea
        clc             ;pulisco il riporto
        lda $04         ;stessa identica cosa per il byte alto
        adc #$D4        ; aggiungo l'offset per raggiungere la color ram
        sta $fc         ;altra casella di memoria temporanea
        lda #2          ;carico il colore rosso
        sta ($fb),Y     ;lo disegno dove puntano fb e fc

coll_giocatore
        clc             ;poichè devo fare una somma pulisco il carry
        lda #$c0        ;carico riga bassa del player
        adc $02         ;sommo la posizione X
        cmp $03         ;check con byte basso
        bne input       ;se sono diversi proseguo con l'input del giocatore
        lda $04         ;check byte alto nemico
        cmp #$07        ;con byte alto player (identico a quello del proiettile)
        bne input       ;se sono diversi proseguo con l'input
        jmp game_over   ;altrimenti game over

input
        ldx $02         
        lda #32
        sta $07c0,X     ;disegno spazio vuoto nella vecchia pos del player
        
        jsr $ffe4       ;prendo un input dalla tastiera
        cmp #0          ;se non è stato premuto niente disegno giocatore nella stessa pos
        beq disegna_gioc
        
        cmp #87         ;se premo W va alla procedura dello sparo
        beq spara
        
        cmp #65         ;se premo A va alla procedura del movimento verso sx
        beq sinistra
        
        cmp #68         ;se premo D va alla proc del mov verso dc
        beq destra
        
        jmp disegna_gioc        ;tasto non valido disegna gioc nella stessa pos


spara
        lda $09         ;carica flag del proiettile
        bne disegna_gioc        ;flag gia attivo disegna il gioc
        lda #1          ;attivo la flag
        sta $09         
        clc     
        lda #$98        ;pos iniziale proiettile stessa "coordinata x" del player
        adc $02         ; aggiungo la X del player
        sta $07         ;carico nel byte basso
        lda #$07        ;posizione verticale una riga sopra il player
        sta $08         ;carico nel byte alto del poriettile
        jmp disegna_gioc

sinistra 
        ldx $02         ;carico pos del player
        cpx #2          ;confronto con bordo sinistro settato a 2 (spiegazione orale del perchè)
        beq disegna_gioc        ;se coincidono ridisegna il player al bordo
        dec $02         ;altrimenti decrementa la posizione
        jmp disegna_gioc        

destra
        ldx $02         ;carico pos del player
        cpx #37         ;confronto con bordo destro settato a 37 (spiegazione oraòe)
        beq disegna_gioc        ;se uguali ridisegna il player
        inc $02         ;altrimenti aumenta la pos di uno e disegna
        jmp disegna_gioc

disegna_gioc
        ldx $02         ;carico pos del player
        lda #65         ;sprite del player 
        sta $07c0,X     ;indirizzamento assoluto (giocatore non necessita di un puntatore)
        lda #1          ;carico colore bianco
        sta $dbc0,X     ;
        
        lda $09       ;check proiettile
        beq loop_back   ;disattivo passa al loop

        ldy #0          ;se è attivo procede a disegnare
        lda #102        ;carica lo sprite
        sta ($07),Y
        
        lda $07         ;identica procedura per colorare il nemico con l'offset della color ram
        sta $fb
        clc
        lda $08
        adc #$D4
        sta $fc
        lda #1
        sta ($fb),Y
        
loop_back
        jmp ciclo       ;torna all'inizio loop infinito

reset_nem
        lda #$04        ;resetta altezza nemico in cima
        sta $04         ;nessun jmp poichè cade direttamente nelal routine successiva (spiegazione orale per bug fixing)
numero_rng
        lda $06         ;carica il valore del contatore rng 
        and #63         ;bit mask da 0 a 63 (6bit)
        cmp #38         ;compara il numero per vedere se è inferiore a 38 (limite spazio per gestire contatore spiegazione orale)
        bcs riprova     ;se non è inferiore va alla sbr riprova che incrementa e ripete
        cmp #2          ;stesso procedimento per bordo sinistro
        bcc riprova
        sta $03         ;se è buono carica nel byte basso
        rts             ;agisce come parte conclusiva di reset_nem e torna dove era stata chiamata reset_nem (spiegazione orale per bug fixing)
riprova
        inc $06
        jmp numero_rng

game_over
        ldx #0  ;contatore
        
schermata_finale
        lda gameover,X  ;legge i caratteri nella stringa
        sta $05f0,X     ;scrive il primo carattere della stringa
        lda #1          ;carica il colore
        sta $d9f0,X
        inx             ;incremento il contatore
        cpx #9          ;ripete finchè non ha scritto tutti i caratteri della stringa
        bne schermata_finale    
schermata_attesa
        inc $d020       ;"flash intermittente"
        jsr $ffe4       ;attende input da tastiera
        cmp #32         ;premendo barra spaziatrice il gioco riparte
        beq restart
        jmp schermata_attesa ;loop finchè non viene premuta la barra spaziatrice
restart 
        jmp inizio      ;ritorna al loop iniziale


gameover
        byte 7, 1, 13, 5, 32, 15, 22, 5, 18     ;stringa coi codici dei caratteri per la parola ""game over""
        

        