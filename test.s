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
      ; wait for button up
:     ldh   a,[0]
      and   a,$f
      cp    a,$f
      jr    nz,:-
      ; re-enable screen
      ld    a,$91
      ldh   [$40],a     ; LCDC
      halt
      nop
      ; }}}
