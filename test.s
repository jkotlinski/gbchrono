; MIT License
; Copyright (c) 2023 Johan Kotlinski

SECTION "timer",ROM0[$50]
      jp    timer_isr

SECTION "joypad",ROM0[$60]
      jp    joypad_isr

SECTION "boot",ROM0[$100]
      jr    main

SECTION "hram",HRAM[$ff80]
digits:

SECTION "test",ROM0[$150]
main:
      ; disable screen {{{
:     ldh   a,[$44]     ; LY
      cp    a,144
      jr    nz,:-
      xor   a
      ldh   [$40],a     ; LCDC
      ; }}}
      ; initialize RAM {{{
      xor   a
      ld    hl,digits
      ld    [hl+],a
      ld    [hl+],a
      ld    [hl+],a
      ld    [hl+],a
      ld    [hl+],a
      ld    [hl+],a
      ld    [hl+],a
      ld    [hl+],a
      ; }}}
      ; wait for start press {{{
      ; select P15 by setting it low
      ld    a,$10
      ldh   [0],a
      ; wait for button down
:     ldh   a,[0]
      and   a,$f
      cp    a,$f
      jr    z,:-
      ; wait for button up
:     ldh   a,[0]
      and   a,$f
      cp    a,$f
      jr    nz,:-
      ; }}}
      ; enable timer + interrupts {{{
      ; start 4096/16=256 Hz timer
      ld    a,-16
      ldh   [6],a ; TMA
      ld    a,4
      ldh   [7],a ; TAC

      ; enable timer and joypad interrupts
      xor   a
      ldh   [$f],a      ; IF
      ld    a,$14
      ldh   [$ff],a     ; IE

      ei
      ; }}}
      ; idle loop {{{
:     halt
      nop
      jr    :-
      ; }}}

timer_isr: ; {{{
      ld    c,low(digits)
:     ldh   a,[c]
      inc   a
      cp    a,10
      jr    nz,:+
      xor   a
      ldh   [c],a
      inc   c
      jr    :-
:     ldh   [c],a
      reti
      ; }}}

joypad_isr: ; {{{
      ; initialize font
      ld    hl,$9000
      ld    de,font
:     ld    a,[de]
      ld    [hl+],a
      inc   de
      ld    a,l
      cp    a,160
      jr    nz,:-

      ; re-enable screen
      ld    a,$91
      ldh   [$40],a     ; LCDC

:     halt
      nop
      jr    :-
      ; }}}

font: ; {{{
      db    $00,$00,$7E,$3C,$66,$66,$6E,$6E
      db    $66,$66,$76,$76,$66,$66,$7E,$3C
      db    $00,$00,$38,$18,$78,$38,$18,$18
      db    $18,$18,$18,$18,$18,$18,$7E,$7E
      db    $00,$00,$7E,$3C,$66,$66,$06,$06
      db    $7E,$3C,$70,$60,$60,$60,$7E,$7E
      db    $00,$00,$7E,$3C,$66,$66,$06,$06
      db    $1E,$1C,$06,$06,$66,$66,$7E,$3C
      db    $00,$00,$0E,$06,$3E,$16,$66,$46
      db    $7E,$7E,$06,$06,$06,$06,$06,$06
      db    $00,$00,$7E,$7E,$60,$60,$60,$60
      db    $7E,$7C,$06,$06,$66,$66,$7E,$3C
      db    $00,$00,$7E,$3C,$66,$66,$60,$60
      db    $7E,$7C,$66,$66,$66,$66,$7E,$3C
      db    $00,$00,$7E,$7E,$06,$06,$0C,$0C
      db    $18,$18,$38,$10,$30,$30,$30,$30
      db    $00,$00,$7E,$3C,$66,$66,$66,$66
      db    $7E,$3C,$66,$66,$66,$66,$7E,$3C
      db    $00,$00,$7E,$3C,$66,$66,$66,$66
      db    $7E,$3E,$06,$06,$66,$66,$7E,$3C
      ; }}}
