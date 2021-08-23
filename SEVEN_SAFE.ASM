; "Seven", Atari XL/XE Intro 256B
; code by tr1x / Agenda
; requirements: original Atari XL/XE 64KB PAL
; version: 1.0
; release date: 2021-08-21

rtclok	equ $0012
rowcrs	equ $0054
colcrs	equ $0055
oldrow	equ $005a
oldcol	equ $005b
vvblkd	equ $0224
pcolr0	equ $02c0
color2	equ $02c6
color4	equ $02c8
atachr	equ $02fb
hposp0	equ $d000
sizep0	equ $d008
grafp0	equ $d00d
colpf2	equ $d018
colbk	equ $d01a
gractl	equ $d01d
audf1	equ $d200
audc1	equ $d201
random	equ $d20a
wsync	equ $d40a
vcount	equ $d40b
xitvbv	equ $e462
osgraph	equ $ef9c
osprint	equ $f1a4
ospoint	equ $f1d8
osdraw	equ $f9c2


	org $2000

start
	; ************************
	; * "Random walk" effect *
	; ************************
	jsr init
	ldy #$00
loopd1	iny
loopd2	lda random
	and #%00000011
	clc
	adc #$ff
	clc
	adc rowcrs,y
	sta rowcrs,y
	dey
	bpl loopd2
	jsr ospoint
	lda rtclok+2
	bne loopd1


	; *****************
	; * "Dots" effect *
	; *****************
	lda #$02
	jsr init2
loopt1	bit random
	lda #$0e
	bvc skipt1
	lda #$87
skipt1	jsr osprint
	lda rtclok+2
	bne loopt1


	; ********************
	; * "Rainbow" effect *
	; ********************
	inc rtclok+2
loopc1	lda vcount
opcodc1	adc rtclok+2		; "adc" = 65 is used as a counter for "Lines" effect
	sta wsync
	sta colbk
	lda rtclok+2
	bne loopc1


	; ******************
	; * "Lines" effect *
	; ******************
	jsr init
looph1	lda random
	sta colcrs
	lda random
	sta rowcrs
	jsr osdraw
	dec opcodc1
	bne looph1


	; ********************************
	; * "Sierpinski triangle" effect *
	; ********************************
	jsr init
loopb1	lda rowcrs
	bit colcrs
	bne skipb1
	jsr ospoint
skipb1	dec rowcrs
	bne loopb1
	inc colcrs
	bne loopb1
	dec opcodz1-3		; change sound
loopb2	lda rtclok+2
	bne loopb2


	; ***********************
	; * "Chessboard" effect *
	; ***********************
	inc rtclok+2
	ldy #$03
loopa1	lda #$03
	sta sizep0,y
	lda #$ff
	sta grafp0,y
	sta pcolr0,y
	dey
	bpl loopa1
loopa2	lda vcount
	sec
	sbc rtclok+2
	and #%11100000
	clc
	adc rtclok+2
	ldy #$03
	sta wsync
loopa3	sta hposp0,y
	clc
	adc #$40
	dey
	bpl loopa3
	lda rtclok+2
	bne loopa2


	; *****************************
	; * "Munching squares" effect *
	; *****************************
	lda #$09
	jsr init2
loopf1	lda #$4f
	sta colcrs
loopf2	lda rowcrs
	tay
	sta hposp0-$fc,y	; hide players
	lsr
	lsr
	eor colcrs
opcodf1	and #$7f
	sta atachr
	jsr ospoint
	dec rowcrs
	bne loopf2
	dec colcrs
	bpl loopf2
	lda #$10
	;clc			; not necessary
	adc color4
	sta color4
	dec opcodf1+1
	bpl loopf1		; inifinity loop


	; init graphics mode and timer
init	lda #$08
init2	jsr osgraph
	sty rtclok+2		; Y should be 1 at this point
	;dey
	sty color2		; background color in gr. 8
	;dey
	sty atachr
	rts


	; VBLANK interrupt routine
vbrout	lda rtclok+2
	bne skipz1
	rol opcodz1+1
skipz1
opcodz1	ora #%11101010
	sta audc1
	jmp xitvbv


	org vvblkd
	.word .adr(vbrout)


	run start