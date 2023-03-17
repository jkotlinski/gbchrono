; MIT License
; Copyright (c) 2023 Johan Kotlinski

; a tool for measuring game boy clock speed

SECTION "timer_isr",ROM0[$50] ; {{{
      push  af
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
      pop   af
      reti  ; }}}

SECTION "boot",ROM0[$100]
      jr    main

SECTION "hram",HRAM[$ff80]
digits:

SECTION "main",ROM0[$150]
main: ; {{{
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
      ; beep {{{
      ld    a,$80
      ldh   [$12],a
      ldh   [$14],a
      ; }}}
      ; wait for start press {{{
      ; select P15 by setting it low
      ld    a,$10
      ldh   [0],a
      ; wait for button down
:     ldh   a,[0]
      cp    a,$df
      jr    z,:-
      ; wait for button up
:     ldh   a,[0]
      cp    a,$df
      jr    nz,:-
      ; }}}
      ; disable sound {{{
      xor   a
      ldh   [$26],a
      ; }}}
      ; start timer {{{
      ; 4096/16=256 Hz
      ld    a,-16
      ldh   [6],a       ; TMA
      ld    a,4
      ldh   [7],a       ; TAC
      ; enable interrupts
      xor   a
      ldh   [$f],a      ; IF
      ld    a,4
      ldh   [$ff],a     ; IE
      ei
      ; }}}
      ; }}}
main_loop: ; {{{
      ldh   a,[0]
      cp    a,$df
      call  nz,show_results
      halt
      nop
      jr    main_loop
      ; }}}
show_results: ; {{{
      ; wait for button up {{{
:     ldh   a,[0]
      cp    a,$df
      jr    nz,:-
      ; }}}
      ; disable interrupts {{{
      xor   a
      ldh   [$ff],a     ; IE
      ; }}}
      ; initialize font {{{
      ld    hl,$8000
      ld    de,font
:     ld    a,[de]
      ld    [hl+],a
      inc   de
      ld    a,l
      cp    a,176
      jr    nz,:-
      ; }}}
      ; clear bg map {{{
      ld    hl,$9800
:     ld    [hl],10     ; space
      inc   hl
      ld    a,l
      cp    a,$34
      jr    nz,:-
      ld    a,h
      cp    a,$9a
      jr    nz,:-
      ; }}}
      ; print digits {{{
      ld    hl,$9906
      ldh   a,[$87]
      ld    [hl+],a
      ldh   a,[$86]
      ld    [hl+],a
      ldh   a,[$85]
      ld    [hl+],a
      ldh   a,[$84]
      ld    [hl+],a
      ldh   a,[$83]
      ld    [hl+],a
      ldh   a,[$82]
      ld    [hl+],a
      ldh   a,[$81]
      ld    [hl+],a
      ldh   a,[$80]
      ld    [hl+],a
      ; }}}
      ; re-enable screen {{{
      ld    a,$91
      ldh   [$40],a     ; LCDC
      ; }}}
      ret
      ; }}}
font: ; {{{
      db    $00,$00,$1c,$1c,$26,$26,$63,$63     ; 0
      db    $63,$63,$63,$63,$32,$32,$1c,$1c
      db    $00,$00,$1c,$0c,$3c,$3c,$0c,$0c     ; 1
      db    $0c,$0c,$0c,$0c,$0c,$0c,$3f,$3f
      db    $00,$00,$3e,$3e,$63,$63,$07,$03     ; 2
      db    $1e,$0e,$38,$38,$70,$70,$7f,$7f
      db    $00,$00,$3e,$3e,$63,$63,$03,$03     ; 3
      db    $1e,$1e,$03,$03,$63,$63,$3e,$3e
      db    $00,$00,$0e,$0e,$1e,$1e,$36,$36     ; 4
      db    $66,$66,$7f,$7f,$06,$06,$06,$06
      db    $00,$00,$7e,$7e,$60,$60,$60,$60     ; 5
      db    $3e,$3e,$03,$03,$63,$63,$3e,$3e
      db    $00,$00,$1e,$1e,$30,$30,$60,$60     ; 6
      db    $7e,$7e,$63,$63,$63,$63,$3e,$3e
      db    $00,$00,$7f,$7f,$63,$63,$06,$06     ; 7
      db    $0c,$0c,$18,$18,$18,$18,$18,$18
      db    $00,$00,$3e,$3e,$63,$63,$63,$63     ; 8
      db    $3e,$3e,$63,$63,$63,$63,$3e,$3e
      db    $00,$00,$3e,$3e,$63,$63,$63,$63     ; 9
      db    $3f,$3f,$03,$03,$06,$06,$3c,$3c
      db    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0     ; space
      ; }}}
