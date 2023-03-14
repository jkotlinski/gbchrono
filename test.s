; MIT License
; Copyright (c) 2023 Johan Kotlinski

SECTION "timer",ROM0[$50]
      jp    timer

SECTION "joypad",ROM0[$60]
      jp    joypad

SECTION "boot",ROM0[$100]
      jr    main

SECTION "hram",HRAM[$ff80]
digits:

SECTION "test",ROM0[$150]
main:
      ; disable screen
:     ldh   a,[$44]     ; LY
      cp    a,144
      jr    nz,:-
      xor   a
      ldh   [$40],a     ; LCDC

      ; initialize RAM
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

      ; start 4096/4=1024 Hz timer
      ld    a,-4
      ldh   [6],a ; TMA
      ld    a,4
      ldh   [7],a ; TAC

      ; enable timer and joypad interrupts
      ld    a,$14
      ldh   [$ff],a

      ei

:     halt
      nop
      jr    :-

timer:
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

joypad:
