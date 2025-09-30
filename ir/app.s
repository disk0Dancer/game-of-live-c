	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 15, 0	sdk_version 15, 2
	.globl	_app                            ; -- Begin function app
	.p2align	2
_app:                                   ; @app
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	_clear_all
	mov	w0, #180                        ; =0xb4
	bl	_randomize
	stur	wzr, [x29, #-4]
	b	LBB0_1
LBB0_1:                                 ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB0_3 Depth 2
	ldur	w8, [x29, #-4]
	subs	w8, w8, #1000
	cset	w8, ge
	tbnz	w8, #0, LBB0_8
	b	LBB0_2
LBB0_2:                                 ;   in Loop: Header=BB0_1 Depth=1
	bl	_draw_frame
	bl	_simFlush
	adrp	x0, _nxt@PAGE
	add	x0, x0, _nxt@PAGEOFF
	adrp	x1, _cur@PAGE
	add	x1, x1, _cur@PAGEOFF
	bl	_step_generation
	str	wzr, [sp, #8]
	b	LBB0_3
LBB0_3:                                 ;   Parent Loop BB0_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldr	w8, [sp, #8]
	subs	w8, w8, #4, lsl #12             ; =16384
	cset	w8, ge
	tbnz	w8, #0, LBB0_6
	b	LBB0_4
LBB0_4:                                 ;   in Loop: Header=BB0_3 Depth=2
	ldrsw	x9, [sp, #8]
	adrp	x8, _nxt@PAGE
	add	x8, x8, _nxt@PAGEOFF
	ldr	w8, [x8, x9, lsl #2]
	ldrsw	x10, [sp, #8]
	adrp	x9, _cur@PAGE
	add	x9, x9, _cur@PAGEOFF
	str	w8, [x9, x10, lsl #2]
	b	LBB0_5
LBB0_5:                                 ;   in Loop: Header=BB0_3 Depth=2
	ldr	w8, [sp, #8]
	add	w8, w8, #1
	str	w8, [sp, #8]
	b	LBB0_3
LBB0_6:                                 ;   in Loop: Header=BB0_1 Depth=1
	b	LBB0_7
LBB0_7:                                 ;   in Loop: Header=BB0_1 Depth=1
	ldur	w8, [x29, #-4]
	add	w8, w8, #1
	stur	w8, [x29, #-4]
	b	LBB0_1
LBB0_8:
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function clear_all
_clear_all:                             ; @clear_all
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	x1, #65536                      ; =0x10000
	adrp	x0, _cur@PAGE
	add	x0, x0, _cur@PAGEOFF
	bl	_bzero
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function randomize
_randomize:                             ; @randomize
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	w0, [x29, #-4]
	str	wzr, [sp, #8]
	b	LBB2_1
LBB2_1:                                 ; =>This Inner Loop Header: Depth=1
	ldr	w8, [sp, #8]
	subs	w8, w8, #4, lsl #12             ; =16384
	cset	w8, ge
	tbnz	w8, #0, LBB2_4
	b	LBB2_2
LBB2_2:                                 ;   in Loop: Header=BB2_1 Depth=1
	bl	_simRand
	mov	w9, #1000                       ; =0x3e8
	sdiv	w8, w0, w9
	mul	w8, w8, w9
	subs	w8, w0, w8
	ldur	w9, [x29, #-4]
	subs	w8, w8, w9
	cset	w9, lt
	mov	w8, #0                          ; =0x0
	and	w9, w9, #0x1
	ands	w9, w9, #0x1
	csinc	w8, w8, wzr, eq
	ldrsw	x10, [sp, #8]
	adrp	x9, _cur@PAGE
	add	x9, x9, _cur@PAGEOFF
	str	w8, [x9, x10, lsl #2]
	b	LBB2_3
LBB2_3:                                 ;   in Loop: Header=BB2_1 Depth=1
	ldr	w8, [sp, #8]
	add	w8, w8, #1
	str	w8, [sp, #8]
	b	LBB2_1
LBB2_4:
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function draw_frame
_draw_frame:                            ; @draw_frame
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	w8, #-1                         ; =0xffffffff
	stur	w8, [x29, #-4]
	mov	w8, #-16777216                  ; =0xff000000
	stur	w8, [x29, #-8]
	stur	wzr, [x29, #-12]
	b	LBB3_1
LBB3_1:                                 ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB3_3 Depth 2
	ldur	w8, [x29, #-12]
	subs	w8, w8, #128
	cset	w8, ge
	tbnz	w8, #0, LBB3_8
	b	LBB3_2
LBB3_2:                                 ;   in Loop: Header=BB3_1 Depth=1
	str	wzr, [sp, #16]
	b	LBB3_3
LBB3_3:                                 ;   Parent Loop BB3_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldr	w8, [sp, #16]
	subs	w8, w8, #128
	cset	w8, ge
	tbnz	w8, #0, LBB3_6
	b	LBB3_4
LBB3_4:                                 ;   in Loop: Header=BB3_3 Depth=2
	ldr	w8, [sp, #16]
	str	w8, [sp, #12]                   ; 4-byte Folded Spill
	ldur	w8, [x29, #-12]
	str	w8, [sp, #8]                    ; 4-byte Folded Spill
	ldr	w0, [sp, #16]
	ldur	w1, [x29, #-12]
	bl	_idx
	ldr	w1, [sp, #8]                    ; 4-byte Folded Reload
	mov	x9, x0
	ldr	w0, [sp, #12]                   ; 4-byte Folded Reload
	adrp	x8, _cur@PAGE
	add	x8, x8, _cur@PAGEOFF
	ldr	w8, [x8, w9, sxtw #2]
	subs	w8, w8, #0
	cset	w9, ne
	mov	w8, #-16777216                  ; =0xff000000
	and	w9, w9, #0x1
	ands	w9, w9, #0x1
	csinv	w2, w8, wzr, eq
	bl	_draw_cell
	b	LBB3_5
LBB3_5:                                 ;   in Loop: Header=BB3_3 Depth=2
	ldr	w8, [sp, #16]
	add	w8, w8, #1
	str	w8, [sp, #16]
	b	LBB3_3
LBB3_6:                                 ;   in Loop: Header=BB3_1 Depth=1
	b	LBB3_7
LBB3_7:                                 ;   in Loop: Header=BB3_1 Depth=1
	ldur	w8, [x29, #-12]
	add	w8, w8, #1
	stur	w8, [x29, #-12]
	b	LBB3_1
LBB3_8:
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function step_generation
_step_generation:                       ; @step_generation
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #96
	stp	x29, x30, [sp, #80]             ; 16-byte Folded Spill
	add	x29, sp, #80
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	x0, [x29, #-8]
	stur	x1, [x29, #-16]
	stur	wzr, [x29, #-20]
	b	LBB4_1
LBB4_1:                                 ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB4_3 Depth 2
	ldur	w8, [x29, #-20]
	subs	w8, w8, #128
	cset	w8, ge
	tbnz	w8, #0, LBB4_13
	b	LBB4_2
LBB4_2:                                 ;   in Loop: Header=BB4_1 Depth=1
	stur	wzr, [x29, #-24]
	b	LBB4_3
LBB4_3:                                 ;   Parent Loop BB4_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldur	w8, [x29, #-24]
	subs	w8, w8, #128
	cset	w8, ge
	tbnz	w8, #0, LBB4_11
	b	LBB4_4
LBB4_4:                                 ;   in Loop: Header=BB4_3 Depth=2
	ldur	x0, [x29, #-16]
	ldur	w1, [x29, #-24]
	ldur	w2, [x29, #-20]
	bl	_neighbors
	stur	w0, [x29, #-28]
	ldur	x8, [x29, #-16]
	str	x8, [sp, #32]                   ; 8-byte Folded Spill
	ldur	w0, [x29, #-24]
	ldur	w1, [x29, #-20]
	bl	_idx
	ldr	x8, [sp, #32]                   ; 8-byte Folded Reload
	ldr	w8, [x8, w0, sxtw #2]
	subs	w8, w8, #0
	cset	w8, ne
	and	w8, w8, #0x1
	stur	w8, [x29, #-32]
	ldur	w8, [x29, #-32]
	subs	w8, w8, #0
	cset	w8, eq
	tbnz	w8, #0, LBB4_8
	b	LBB4_5
LBB4_5:                                 ;   in Loop: Header=BB4_3 Depth=2
	ldur	w8, [x29, #-28]
	subs	w8, w8, #2
	cset	w8, eq
	mov	w9, #1                          ; =0x1
	str	w9, [sp, #28]                   ; 4-byte Folded Spill
	tbnz	w8, #0, LBB4_7
	b	LBB4_6
LBB4_6:                                 ;   in Loop: Header=BB4_3 Depth=2
	ldur	w8, [x29, #-28]
	subs	w8, w8, #3
	cset	w8, eq
	str	w8, [sp, #28]                   ; 4-byte Folded Spill
	b	LBB4_7
LBB4_7:                                 ;   in Loop: Header=BB4_3 Depth=2
	ldr	w8, [sp, #28]                   ; 4-byte Folded Reload
	and	w8, w8, #0x1
	str	w8, [sp, #24]                   ; 4-byte Folded Spill
	b	LBB4_9
LBB4_8:                                 ;   in Loop: Header=BB4_3 Depth=2
	ldur	w8, [x29, #-28]
	subs	w8, w8, #3
	cset	w8, eq
	and	w8, w8, #0x1
	str	w8, [sp, #24]                   ; 4-byte Folded Spill
	b	LBB4_9
LBB4_9:                                 ;   in Loop: Header=BB4_3 Depth=2
	ldr	w8, [sp, #24]                   ; 4-byte Folded Reload
	stur	w8, [x29, #-36]
	ldur	w8, [x29, #-36]
	str	w8, [sp, #20]                   ; 4-byte Folded Spill
	ldur	x8, [x29, #-8]
	str	x8, [sp, #8]                    ; 8-byte Folded Spill
	ldur	w0, [x29, #-24]
	ldur	w1, [x29, #-20]
	bl	_idx
	ldr	x9, [sp, #8]                    ; 8-byte Folded Reload
	ldr	w8, [sp, #20]                   ; 4-byte Folded Reload
	str	w8, [x9, w0, sxtw #2]
	b	LBB4_10
LBB4_10:                                ;   in Loop: Header=BB4_3 Depth=2
	ldur	w8, [x29, #-24]
	add	w8, w8, #1
	stur	w8, [x29, #-24]
	b	LBB4_3
LBB4_11:                                ;   in Loop: Header=BB4_1 Depth=1
	b	LBB4_12
LBB4_12:                                ;   in Loop: Header=BB4_1 Depth=1
	ldur	w8, [x29, #-20]
	add	w8, w8, #1
	stur	w8, [x29, #-20]
	b	LBB4_1
LBB4_13:
	ldp	x29, x30, [sp, #80]             ; 16-byte Folded Reload
	add	sp, sp, #96
	ret
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function draw_cell
_draw_cell:                             ; @draw_cell
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	w0, [x29, #-4]
	stur	w1, [x29, #-8]
	stur	w2, [x29, #-12]
	ldur	w8, [x29, #-4]
	lsl	w8, w8, #2
	str	w8, [sp, #16]
	ldur	w8, [x29, #-8]
	lsl	w8, w8, #2
	str	w8, [sp, #12]
	str	wzr, [sp, #8]
	b	LBB5_1
LBB5_1:                                 ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB5_3 Depth 2
	ldr	w8, [sp, #8]
	subs	w8, w8, #4
	cset	w8, ge
	tbnz	w8, #0, LBB5_8
	b	LBB5_2
LBB5_2:                                 ;   in Loop: Header=BB5_1 Depth=1
	str	wzr, [sp, #4]
	b	LBB5_3
LBB5_3:                                 ;   Parent Loop BB5_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ldr	w8, [sp, #4]
	subs	w8, w8, #4
	cset	w8, ge
	tbnz	w8, #0, LBB5_6
	b	LBB5_4
LBB5_4:                                 ;   in Loop: Header=BB5_3 Depth=2
	ldr	w8, [sp, #16]
	ldr	w9, [sp, #4]
	add	w0, w8, w9
	ldr	w8, [sp, #12]
	ldr	w9, [sp, #8]
	add	w1, w8, w9
	ldur	w2, [x29, #-12]
	bl	_simPutPixel
	b	LBB5_5
LBB5_5:                                 ;   in Loop: Header=BB5_3 Depth=2
	ldr	w8, [sp, #4]
	add	w8, w8, #1
	str	w8, [sp, #4]
	b	LBB5_3
LBB5_6:                                 ;   in Loop: Header=BB5_1 Depth=1
	b	LBB5_7
LBB5_7:                                 ;   in Loop: Header=BB5_1 Depth=1
	ldr	w8, [sp, #8]
	add	w8, w8, #1
	str	w8, [sp, #8]
	b	LBB5_1
LBB5_8:
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function idx
_idx:                                   ; @idx
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	str	w0, [sp, #12]
	str	w1, [sp, #8]
	ldr	w9, [sp, #8]
	ldr	w8, [sp, #12]
	add	w0, w8, w9, lsl #7
	add	sp, sp, #16
	ret
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function neighbors
_neighbors:                             ; @neighbors
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #176
	stp	x29, x30, [sp, #160]            ; 16-byte Folded Spill
	add	x29, sp, #160
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	x0, [x29, #-8]
	stur	w1, [x29, #-12]
	stur	w2, [x29, #-16]
	ldur	w8, [x29, #-12]
	subs	w0, w8, #1
	mov	w1, #128                        ; =0x80
	str	w1, [sp, #4]                    ; 4-byte Folded Spill
	bl	_wrap
	ldr	w1, [sp, #4]                    ; 4-byte Folded Reload
	stur	w0, [x29, #-20]
	ldur	w8, [x29, #-12]
	add	w0, w8, #1
	bl	_wrap
	ldr	w1, [sp, #4]                    ; 4-byte Folded Reload
	stur	w0, [x29, #-24]
	ldur	w8, [x29, #-16]
	subs	w0, w8, #1
	bl	_wrap
	ldr	w1, [sp, #4]                    ; 4-byte Folded Reload
	stur	w0, [x29, #-28]
	ldur	w8, [x29, #-16]
	add	w0, w8, #1
	bl	_wrap
	stur	w0, [x29, #-32]
	ldur	x8, [x29, #-8]
	str	x8, [sp, #8]                    ; 8-byte Folded Spill
	ldur	w0, [x29, #-20]
	ldur	w1, [x29, #-28]
	bl	_idx
	ldr	x8, [sp, #8]                    ; 8-byte Folded Reload
	ldr	w8, [x8, w0, sxtw #2]
	str	w8, [sp, #28]                   ; 4-byte Folded Spill
	ldur	x8, [x29, #-8]
	str	x8, [sp, #16]                   ; 8-byte Folded Spill
	ldur	w0, [x29, #-12]
	ldur	w1, [x29, #-28]
	bl	_idx
	ldr	x9, [sp, #16]                   ; 8-byte Folded Reload
	ldr	w8, [sp, #28]                   ; 4-byte Folded Reload
	ldr	w9, [x9, w0, sxtw #2]
	add	w8, w8, w9
	str	w8, [sp, #44]                   ; 4-byte Folded Spill
	ldur	x8, [x29, #-8]
	str	x8, [sp, #32]                   ; 8-byte Folded Spill
	ldur	w0, [x29, #-24]
	ldur	w1, [x29, #-28]
	bl	_idx
	ldr	x9, [sp, #32]                   ; 8-byte Folded Reload
	ldr	w8, [sp, #44]                   ; 4-byte Folded Reload
	ldr	w9, [x9, w0, sxtw #2]
	add	w8, w8, w9
	str	w8, [sp, #60]                   ; 4-byte Folded Spill
	ldur	x8, [x29, #-8]
	str	x8, [sp, #48]                   ; 8-byte Folded Spill
	ldur	w0, [x29, #-20]
	ldur	w1, [x29, #-16]
	bl	_idx
	ldr	x9, [sp, #48]                   ; 8-byte Folded Reload
	ldr	w8, [sp, #60]                   ; 4-byte Folded Reload
	ldr	w9, [x9, w0, sxtw #2]
	add	w8, w8, w9
	str	w8, [sp, #76]                   ; 4-byte Folded Spill
	ldur	x8, [x29, #-8]
	str	x8, [sp, #64]                   ; 8-byte Folded Spill
	ldur	w0, [x29, #-24]
	ldur	w1, [x29, #-16]
	bl	_idx
	ldr	x9, [sp, #64]                   ; 8-byte Folded Reload
	ldr	w8, [sp, #76]                   ; 4-byte Folded Reload
	ldr	w9, [x9, w0, sxtw #2]
	add	w8, w8, w9
	stur	w8, [x29, #-68]                 ; 4-byte Folded Spill
	ldur	x8, [x29, #-8]
	str	x8, [sp, #80]                   ; 8-byte Folded Spill
	ldur	w0, [x29, #-20]
	ldur	w1, [x29, #-32]
	bl	_idx
	ldr	x9, [sp, #80]                   ; 8-byte Folded Reload
	ldur	w8, [x29, #-68]                 ; 4-byte Folded Reload
	ldr	w9, [x9, w0, sxtw #2]
	add	w8, w8, w9
	stur	w8, [x29, #-52]                 ; 4-byte Folded Spill
	ldur	x8, [x29, #-8]
	stur	x8, [x29, #-64]                 ; 8-byte Folded Spill
	ldur	w0, [x29, #-12]
	ldur	w1, [x29, #-32]
	bl	_idx
	ldur	x9, [x29, #-64]                 ; 8-byte Folded Reload
	ldur	w8, [x29, #-52]                 ; 4-byte Folded Reload
	ldr	w9, [x9, w0, sxtw #2]
	add	w8, w8, w9
	stur	w8, [x29, #-36]                 ; 4-byte Folded Spill
	ldur	x8, [x29, #-8]
	stur	x8, [x29, #-48]                 ; 8-byte Folded Spill
	ldur	w0, [x29, #-24]
	ldur	w1, [x29, #-32]
	bl	_idx
	ldur	x9, [x29, #-48]                 ; 8-byte Folded Reload
	ldur	w8, [x29, #-36]                 ; 4-byte Folded Reload
	ldr	w9, [x9, w0, sxtw #2]
	add	w0, w8, w9
	ldp	x29, x30, [sp, #160]            ; 16-byte Folded Reload
	add	sp, sp, #176
	ret
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function wrap
_wrap:                                  ; @wrap
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #16
	.cfi_def_cfa_offset 16
	str	w0, [sp, #8]
	str	w1, [sp, #4]
	ldr	w8, [sp, #8]
	subs	w8, w8, #0
	cset	w8, ge
	tbnz	w8, #0, LBB8_2
	b	LBB8_1
LBB8_1:
	ldr	w8, [sp, #8]
	ldr	w9, [sp, #4]
	add	w8, w8, w9
	str	w8, [sp, #12]
	b	LBB8_5
LBB8_2:
	ldr	w8, [sp, #8]
	ldr	w9, [sp, #4]
	subs	w8, w8, w9
	cset	w8, lt
	tbnz	w8, #0, LBB8_4
	b	LBB8_3
LBB8_3:
	ldr	w8, [sp, #8]
	ldr	w9, [sp, #4]
	subs	w8, w8, w9
	str	w8, [sp, #12]
	b	LBB8_5
LBB8_4:
	ldr	w8, [sp, #8]
	str	w8, [sp, #12]
	b	LBB8_5
LBB8_5:
	ldr	w0, [sp, #12]
	add	sp, sp, #16
	ret
	.cfi_endproc
                                        ; -- End function
.zerofill __DATA,__bss,_nxt,65536,2     ; @nxt
.zerofill __DATA,__bss,_cur,65536,2     ; @cur
.subsections_via_symbols
