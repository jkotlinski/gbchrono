; MIT License
; Copyright (c) 2023 Johan Kotlinski

SECTION "timer",ROM0[$50]
	jp	timer

SECTION "joypad",ROM0[$60]
	jp	joypad

SECTION "boot",ROM0[$100]
        jr      main

SECTION "hram",HRAM[$ff80]
digits:

SECTION "test",ROM0[$150]
main:
	di

	; disable screen
: 	ldh	a,[$44]	; LY
	cp	a,144
	jr	nz,:-
	xor	a
	ldh	[$40],a	; LCDC

	xor	a
	ld	hl,digits
	ld	[hl+],a
	ld	[hl+],a
	ld	[hl+],a
	ld	[hl+],a
	ld	[hl+],a
	ld	[hl+],a
	ld	[hl+],a
	ld	[hl+],a

	; start 4096/256=16 Hz timer
	ldh	[6],a	; TMA
	ld	a,4
	ldh	[7],a	; TAC

	; enable timer and joypad interrupts
	ld	a,$14
	ldh	[$ff],a

	ei

: 	halt
	nop
	jr 	:-

timer:  ld	l,low(digits)
:  	inc	[hl]
	ld	a,[hl]
	cp	a,10
	jr	nz,:+
	ld	[hl],0
	inc	l
	jr	:-
: 	reti

joypad:
