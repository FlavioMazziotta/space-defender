 C64 Space Defender - Assembly 6502

Progetto d'esame per il corso di Architettura dei Calcolatori.
Questo repository contiene il codice sorgente di un videogioco sviluppato interamente in **Assembly MOS 6502** per Commodore 64.

 Descrizione del Progetto
Il software è un engine di gioco che gestisce direttamente l'hardware del C64 senza l'ausilio di librerie esterne. Il codice implementa un game loop lineare che gestisce rendering, logica di gioco, input utente e generazione procedurale dei nemici.

Caratteristiche Principali
* Memory Mapped I/O: Accesso diretto ai registri del chip video VIC-II (`$D020`, `$D021`) e alla Screen RAM (`$0400`).
* Zero Page Optimization: Utilizzo degli indirizzi `$02-$09` per le variabili ad alta frequenza (player, nemici, flag) per massimizzare la velocità di esecuzione (3 cicli di clock vs 4).
* 16-bit Pointers & Indirect Addressing: Uso della modalità `($LL),Y` per gestire dinamicamente la posizione dei nemici e dei proiettili nella memoria video.
* Linear Game Loop: Architettura basata su 5 fasi sequenziali (Setup, Timing, Logic, Event Handling, Rendering).
* RNG Custom: Generatore di numeri pseudo-casuali per lo spawn dei nemici con logica di filtraggio per evitare sovrapposizioni con l'interfaccia utente.

Requisiti e Replicabilità
Per compilare ed eseguire il progetto è necessario un ambiente di sviluppo per C64.

 Software Necessario
1.  **Assembler:** (https://www.ajordison.co.uk/download.html).
2.  **Emulatore:** [VICE Emulator](https://vice-emu.sourceforge.io/) (consigliato).

Istruzioni per la Compilazione
Il codice include l'header BASIC (`$0801`) per l'avvio automatico.

1.  Clona il repository:
    ```bash
    git clone [https://github.com/code50/216724026.git](https://github.com/code50/216724026.git)
    ```
2.  Apri il file sorgente `.asm` nel tuo assembler.
3.  Compila il codice generando un file `.prg` (Program File).
    * Start Address: `$0801` (SYS 2064).
4.  Carica il file `.prg` nell'emulatore VICE.
5.  Digita `RUN` se non parte automaticamente.

Comandi di Gioco
* **W**: Spara proiettile.
* **A**: Muovi a sinistra.
* **D**: Muovi a destra.
* **Spazio**: Riavvia dopo il Game Over.

Dettagli Architetturali (Mappa della Memoria)
| Indirizzo  Utilizzo  Descrizione 

| `$0002` | Player X | Coordinata orizzontale giocatore |
| `$0003-$0004` | Nemico Pointer | Puntatore 16-bit (Low/High) per indirizzamento indiretto |
| `$0005` | Timer | Gestione velocità discesa nemico |
| `$0006` | RNG Seed | Seme per la generazione casuale |
| `$0007-$0008` | Bullet Pointer | Puntatore 16-bit per il proiettile |
| `$0009` | Flag Bullet | Stato proiettile (0=Off, 1=On) |
| `$0400-$07E7` | Screen RAM | Memoria video per caratteri |
| `$D800-$DBE7` | Color RAM | Memoria dedicata ai colori (Mappata in I/O) |

---
Progetto realizzato da Mazziotta Flavio - Matricola: 0124003462
