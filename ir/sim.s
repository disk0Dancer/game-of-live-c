	.section	__TEXT,__text,regular,pure_instructions
	.build_version macos, 15, 0	sdk_version 15, 2
	.globl	_simInit                        ; -- Begin function simInit
	.p2align	2
_simInit:                               ; @simInit
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	mov	w0, #32                         ; =0x20
	bl	_SDL_Init
	subs	w8, w0, #0
	cset	w8, eq
	tbnz	w8, #0, LBB0_2
	b	LBB0_1
LBB0_1:
	bl	_SDL_GetError
	mov	x8, sp
	str	x0, [x8]
	adrp	x0, l_.str@PAGE
	add	x0, x0, l_.str@PAGEOFF
	bl	_SDL_Log
	mov	w0, #1                          ; =0x1
	bl	_exit
LBB0_2:
	mov	w1, #512                        ; =0x200
	mov	x0, x1
	mov	w2, #0                          ; =0x0
	adrp	x3, _Window@PAGE
	add	x3, x3, _Window@PAGEOFF
	adrp	x4, _Renderer@PAGE
	add	x4, x4, _Renderer@PAGEOFF
	bl	_SDL_CreateWindowAndRenderer
	subs	w8, w0, #0
	cset	w8, eq
	tbnz	w8, #0, LBB0_4
	b	LBB0_3
LBB0_3:
	bl	_SDL_GetError
	mov	x8, sp
	str	x0, [x8]
	adrp	x0, l_.str.1@PAGE
	add	x0, x0, l_.str.1@PAGEOFF
	bl	_SDL_Log
	mov	w0, #1                          ; =0x1
	bl	_exit
LBB0_4:
	mov	w0, #-16777216                  ; =0xff000000
	bl	_simClear
	adrp	x8, _Renderer@PAGE
	ldr	x0, [x8, _Renderer@PAGEOFF]
	bl	_SDL_RenderPresent
	bl	_SDL_GetTicks
	adrp	x8, _Ticks@PAGE
	str	w0, [x8, _Ticks@PAGEOFF]
	mov	x0, #0                          ; =0x0
	bl	_time
                                        ; kill: def $w0 killed $w0 killed $x0
	bl	_srand
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_simClear                       ; -- Begin function simClear
	.p2align	2
_simClear:                              ; @simClear
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	stp	x29, x30, [sp, #32]             ; 16-byte Folded Spill
	add	x29, sp, #32
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	w0, [x29, #-4]
	ldur	w0, [x29, #-4]
	sub	x1, x29, #8
	sub	x2, x29, #12
	add	x3, sp, #16
	add	x4, sp, #12
	bl	_unpack_argb_int
	adrp	x8, _Renderer@PAGE
	str	x8, [sp]                        ; 8-byte Folded Spill
	ldr	x0, [x8, _Renderer@PAGEOFF]
	ldur	w11, [x29, #-8]
	ldur	w10, [x29, #-12]
	ldr	w9, [sp, #16]
	ldr	w8, [sp, #12]
	and	w1, w11, #0xff
	and	w2, w10, #0xff
	and	w3, w9, #0xff
	and	w4, w8, #0xff
	bl	_SDL_SetRenderDrawColor
	ldr	x8, [sp]                        ; 8-byte Folded Reload
	ldr	x0, [x8, _Renderer@PAGEOFF]
	bl	_SDL_RenderClear
	ldp	x29, x30, [sp, #32]             ; 16-byte Folded Reload
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_simExit                        ; -- Begin function simExit
	.p2align	2
_simExit:                               ; @simExit
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #80
	stp	x29, x30, [sp, #64]             ; 16-byte Folded Spill
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	adrp	x8, ___stack_chk_guard@GOTPAGE
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
	ldr	x8, [x8]
	stur	x8, [x29, #-8]
	b	LBB2_1
LBB2_1:                                 ; =>This Inner Loop Header: Depth=1
	mov	x0, sp
	bl	_SDL_PollEvent
	subs	w8, w0, #0
	cset	w8, eq
	tbnz	w8, #0, LBB2_4
	b	LBB2_2
LBB2_2:                                 ;   in Loop: Header=BB2_1 Depth=1
	ldr	w8, [sp]
	subs	w8, w8, #256
	cset	w8, ne
	tbnz	w8, #0, LBB2_4
	b	LBB2_3
LBB2_3:
	b	LBB2_5
LBB2_4:                                 ;   in Loop: Header=BB2_1 Depth=1
	b	LBB2_1
LBB2_5:
	adrp	x8, _Renderer@PAGE
	ldr	x8, [x8, _Renderer@PAGEOFF]
	subs	x8, x8, #0
	cset	w8, eq
	tbnz	w8, #0, LBB2_7
	b	LBB2_6
LBB2_6:
	adrp	x8, _Renderer@PAGE
	ldr	x0, [x8, _Renderer@PAGEOFF]
	bl	_SDL_DestroyRenderer
	b	LBB2_7
LBB2_7:
	adrp	x8, _Window@PAGE
	ldr	x8, [x8, _Window@PAGEOFF]
	subs	x8, x8, #0
	cset	w8, eq
	tbnz	w8, #0, LBB2_9
	b	LBB2_8
LBB2_8:
	adrp	x8, _Window@PAGE
	ldr	x0, [x8, _Window@PAGEOFF]
	bl	_SDL_DestroyWindow
	b	LBB2_9
LBB2_9:
	bl	_SDL_Quit
	ldur	x9, [x29, #-8]
	adrp	x8, ___stack_chk_guard@GOTPAGE
	ldr	x8, [x8, ___stack_chk_guard@GOTPAGEOFF]
	ldr	x8, [x8]
	subs	x8, x8, x9
	cset	w8, eq
	tbnz	w8, #0, LBB2_11
	b	LBB2_10
LBB2_10:
	bl	___stack_chk_fail
LBB2_11:
	ldp	x29, x30, [sp, #64]             ; 16-byte Folded Reload
	add	sp, sp, #80
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_simFlush                       ; -- Begin function simFlush
	.p2align	2
_simFlush:                              ; @simFlush
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #32
	stp	x29, x30, [sp, #16]             ; 16-byte Folded Spill
	add	x29, sp, #16
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	_SDL_PumpEvents
	mov	w0, #256                        ; =0x100
	bl	_SDL_HasEvent
	mov	w8, #1                          ; =0x1
	subs	w8, w8, w0
	cset	w8, eq
	mov	w9, #0                          ; =0x0
	str	w9, [sp, #8]                    ; 4-byte Folded Spill
	tbnz	w8, #0, LBB3_2
	b	LBB3_1
LBB3_1:
	mov	w8, #1                          ; =0x1
	str	w8, [sp, #8]                    ; 4-byte Folded Spill
	b	LBB3_2
LBB3_2:
	ldr	w8, [sp, #8]                    ; 4-byte Folded Reload
	eor	w9, w8, #0x1
                                        ; implicit-def: $x8
	mov	x8, x9
	ands	x8, x8, #0x1
	cset	w8, eq
	tbnz	w8, #0, LBB3_4
	b	LBB3_3
LBB3_3:
	adrp	x0, l___func__.simFlush@PAGE
	add	x0, x0, l___func__.simFlush@PAGEOFF
	adrp	x1, l_.str.3@PAGE
	add	x1, x1, l_.str.3@PAGEOFF
	mov	w2, #51                         ; =0x33
	adrp	x3, l_.str.4@PAGE
	add	x3, x3, l_.str.4@PAGEOFF
	bl	___assert_rtn
LBB3_4:
	b	LBB3_5
LBB3_5:
	bl	_SDL_GetTicks
	adrp	x8, _Ticks@PAGE
	ldr	w8, [x8, _Ticks@PAGEOFF]
	subs	w8, w0, w8
	stur	w8, [x29, #-4]
	ldur	w8, [x29, #-4]
	subs	w8, w8, #50
	cset	w8, hs
	tbnz	w8, #0, LBB3_7
	b	LBB3_6
LBB3_6:
	ldur	w9, [x29, #-4]
	mov	w8, #50                         ; =0x32
	subs	w0, w8, w9
	bl	_SDL_Delay
	b	LBB3_7
LBB3_7:
	adrp	x8, _Renderer@PAGE
	ldr	x0, [x8, _Renderer@PAGEOFF]
	bl	_SDL_RenderPresent
	ldp	x29, x30, [sp, #16]             ; 16-byte Folded Reload
	add	sp, sp, #32
	ret
	.cfi_endproc
                                        ; -- End function
	.p2align	2                               ; -- Begin function unpack_argb_int
_unpack_argb_int:                       ; @unpack_argb_int
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #48
	.cfi_def_cfa_offset 48
	str	w0, [sp, #44]
	str	x1, [sp, #32]
	str	x2, [sp, #24]
	str	x3, [sp, #16]
	str	x4, [sp, #8]
	ldr	w8, [sp, #44]
	asr	w8, w8, #24
	and	w8, w8, #0xff
	ldr	x9, [sp, #8]
	str	w8, [x9]
	ldr	w8, [sp, #44]
	asr	w8, w8, #16
	and	w8, w8, #0xff
	ldr	x9, [sp, #32]
	str	w8, [x9]
	ldr	w8, [sp, #44]
	asr	w8, w8, #8
	and	w8, w8, #0xff
	ldr	x9, [sp, #24]
	str	w8, [x9]
	ldrb	w8, [sp, #44]
	ldr	x9, [sp, #16]
	str	w8, [x9]
	add	sp, sp, #48
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_simPutPixel                    ; -- Begin function simPutPixel
	.p2align	2
_simPutPixel:                           ; @simPutPixel
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #64
	stp	x29, x30, [sp, #48]             ; 16-byte Folded Spill
	add	x29, sp, #48
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	w0, [x29, #-4]
	stur	w1, [x29, #-8]
	stur	w2, [x29, #-12]
	ldur	w9, [x29, #-4]
	mov	w8, #0                          ; =0x0
	subs	w8, w8, w9
	cset	w8, gt
	mov	w9, #0                          ; =0x0
	str	w9, [sp, #16]                   ; 4-byte Folded Spill
	tbnz	w8, #0, LBB5_3
	b	LBB5_1
LBB5_1:
	ldur	w8, [x29, #-4]
	subs	w8, w8, #512
	cset	w8, ge
	mov	w9, #0                          ; =0x0
	str	w9, [sp, #16]                   ; 4-byte Folded Spill
	tbnz	w8, #0, LBB5_3
	b	LBB5_2
LBB5_2:
	mov	w8, #1                          ; =0x1
	str	w8, [sp, #16]                   ; 4-byte Folded Spill
	b	LBB5_3
LBB5_3:
	ldr	w8, [sp, #16]                   ; 4-byte Folded Reload
	eor	w9, w8, #0x1
                                        ; implicit-def: $x8
	mov	x8, x9
	ands	x8, x8, #0x1
	cset	w8, eq
	tbnz	w8, #0, LBB5_5
	b	LBB5_4
LBB5_4:
	adrp	x0, l___func__.simPutPixel@PAGE
	add	x0, x0, l___func__.simPutPixel@PAGEOFF
	adrp	x1, l_.str.3@PAGE
	add	x1, x1, l_.str.3@PAGEOFF
	mov	w2, #68                         ; =0x44
	adrp	x3, l_.str.6@PAGE
	add	x3, x3, l_.str.6@PAGEOFF
	bl	___assert_rtn
LBB5_5:
	b	LBB5_6
LBB5_6:
	ldur	w9, [x29, #-8]
	mov	w8, #0                          ; =0x0
	subs	w8, w8, w9
	cset	w8, gt
	mov	w9, #0                          ; =0x0
	str	w9, [sp, #12]                   ; 4-byte Folded Spill
	tbnz	w8, #0, LBB5_9
	b	LBB5_7
LBB5_7:
	ldur	w8, [x29, #-8]
	subs	w8, w8, #512
	cset	w8, ge
	mov	w9, #0                          ; =0x0
	str	w9, [sp, #12]                   ; 4-byte Folded Spill
	tbnz	w8, #0, LBB5_9
	b	LBB5_8
LBB5_8:
	mov	w8, #1                          ; =0x1
	str	w8, [sp, #12]                   ; 4-byte Folded Spill
	b	LBB5_9
LBB5_9:
	ldr	w8, [sp, #12]                   ; 4-byte Folded Reload
	eor	w9, w8, #0x1
                                        ; implicit-def: $x8
	mov	x8, x9
	ands	x8, x8, #0x1
	cset	w8, eq
	tbnz	w8, #0, LBB5_11
	b	LBB5_10
LBB5_10:
	adrp	x0, l___func__.simPutPixel@PAGE
	add	x0, x0, l___func__.simPutPixel@PAGEOFF
	adrp	x1, l_.str.3@PAGE
	add	x1, x1, l_.str.3@PAGEOFF
	mov	w2, #69                         ; =0x45
	adrp	x3, l_.str.7@PAGE
	add	x3, x3, l_.str.7@PAGEOFF
	bl	___assert_rtn
LBB5_11:
	b	LBB5_12
LBB5_12:
	ldur	w0, [x29, #-12]
	sub	x1, x29, #16
	sub	x2, x29, #20
	add	x3, sp, #24
	add	x4, sp, #20
	bl	_unpack_argb_int
	adrp	x8, _Renderer@PAGE
	str	x8, [sp]                        ; 8-byte Folded Spill
	ldr	x0, [x8, _Renderer@PAGEOFF]
	ldur	w11, [x29, #-16]
	ldur	w10, [x29, #-20]
	ldr	w9, [sp, #24]
	ldr	w8, [sp, #20]
	and	w1, w11, #0xff
	and	w2, w10, #0xff
	and	w3, w9, #0xff
	and	w4, w8, #0xff
	bl	_SDL_SetRenderDrawColor
	ldr	x8, [sp]                        ; 8-byte Folded Reload
	ldr	x0, [x8, _Renderer@PAGEOFF]
	ldur	w1, [x29, #-4]
	ldur	w2, [x29, #-8]
	bl	_SDL_RenderDrawPoint
	bl	_SDL_GetTicks
	adrp	x8, _Ticks@PAGE
	str	w0, [x8, _Ticks@PAGEOFF]
	ldp	x29, x30, [sp, #48]             ; 16-byte Folded Reload
	add	sp, sp, #64
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_simFillRect                    ; -- Begin function simFillRect
	.p2align	2
_simFillRect:                           ; @simFillRect
	.cfi_startproc
; %bb.0:
	sub	sp, sp, #80
	stp	x29, x30, [sp, #64]             ; 16-byte Folded Spill
	add	x29, sp, #64
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	stur	w0, [x29, #-4]
	stur	w1, [x29, #-8]
	stur	w2, [x29, #-12]
	stur	w3, [x29, #-16]
	stur	w4, [x29, #-20]
	ldur	w8, [x29, #-12]
	subs	w8, w8, #0
	cset	w8, le
	tbnz	w8, #0, LBB6_2
	b	LBB6_1
LBB6_1:
	ldur	w8, [x29, #-16]
	subs	w8, w8, #0
	cset	w8, gt
	tbnz	w8, #0, LBB6_3
	b	LBB6_2
LBB6_2:
	b	LBB6_10
LBB6_3:
	ldur	w8, [x29, #-4]
	subs	w8, w8, #512
	cset	w8, ge
	tbnz	w8, #0, LBB6_5
	b	LBB6_4
LBB6_4:
	ldur	w8, [x29, #-8]
	subs	w8, w8, #512
	cset	w8, lt
	tbnz	w8, #0, LBB6_6
	b	LBB6_5
LBB6_5:
	b	LBB6_10
LBB6_6:
	ldur	w8, [x29, #-4]
	ldur	w9, [x29, #-12]
	add	w8, w8, w9
	subs	w8, w8, #0
	cset	w8, le
	tbnz	w8, #0, LBB6_8
	b	LBB6_7
LBB6_7:
	ldur	w8, [x29, #-8]
	ldur	w9, [x29, #-16]
	add	w8, w8, w9
	subs	w8, w8, #0
	cset	w8, gt
	tbnz	w8, #0, LBB6_9
	b	LBB6_8
LBB6_8:
	b	LBB6_10
LBB6_9:
	ldur	w0, [x29, #-20]
	sub	x1, x29, #24
	sub	x2, x29, #28
	add	x3, sp, #32
	add	x4, sp, #28
	bl	_unpack_argb_int
	adrp	x8, _Renderer@PAGE
	str	x8, [sp]                        ; 8-byte Folded Spill
	ldr	x0, [x8, _Renderer@PAGEOFF]
	ldur	w11, [x29, #-24]
	ldur	w10, [x29, #-28]
	ldr	w9, [sp, #32]
	ldr	w8, [sp, #28]
	and	w1, w11, #0xff
	and	w2, w10, #0xff
	and	w3, w9, #0xff
	and	w4, w8, #0xff
	bl	_SDL_SetRenderDrawColor
	ldr	x8, [sp]                        ; 8-byte Folded Reload
	ldur	w9, [x29, #-4]
	add	x1, sp, #12
	str	w9, [sp, #12]
	ldur	w9, [x29, #-8]
	str	w9, [sp, #16]
	ldur	w9, [x29, #-12]
	str	w9, [sp, #20]
	ldur	w9, [x29, #-16]
	str	w9, [sp, #24]
	ldr	x0, [x8, _Renderer@PAGEOFF]
	bl	_SDL_RenderFillRect
	b	LBB6_10
LBB6_10:
	ldp	x29, x30, [sp, #64]             ; 16-byte Folded Reload
	add	sp, sp, #80
	ret
	.cfi_endproc
                                        ; -- End function
	.globl	_simRand                        ; -- Begin function simRand
	.p2align	2
_simRand:                               ; @simRand
	.cfi_startproc
; %bb.0:
	stp	x29, x30, [sp, #-16]!           ; 16-byte Folded Spill
	mov	x29, sp
	.cfi_def_cfa w29, 16
	.cfi_offset w30, -8
	.cfi_offset w29, -16
	bl	_rand
	ldp	x29, x30, [sp], #16             ; 16-byte Folded Reload
	ret
	.cfi_endproc
                                        ; -- End function
	.section	__TEXT,__cstring,cstring_literals
l_.str:                                 ; @.str
	.asciz	"SDL_Init failed: %s"

.zerofill __DATA,__bss,_Window,8,3      ; @Window
.zerofill __DATA,__bss,_Renderer,8,3    ; @Renderer
l_.str.1:                               ; @.str.1
	.asciz	"SDL_CreateWindowAndRenderer failed: %s"

.zerofill __DATA,__bss,_Ticks,4,2       ; @Ticks
l_.str.2:                               ; @.str.2
	.asciz	"User-requested quit"

l___func__.simFlush:                    ; @__func__.simFlush
	.asciz	"simFlush"

l_.str.3:                               ; @.str.3
	.asciz	"sim.c"

l_.str.4:                               ; @.str.4
	.asciz	"SDL_TRUE != SDL_HasEvent(SDL_QUIT) && \"User-requested quit\""

l_.str.5:                               ; @.str.5
	.asciz	"Out of range"

l___func__.simPutPixel:                 ; @__func__.simPutPixel
	.asciz	"simPutPixel"

l_.str.6:                               ; @.str.6
	.asciz	"0 <= x && x < SIM_X_SIZE && \"Out of range\""

l_.str.7:                               ; @.str.7
	.asciz	"0 <= y && y < SIM_Y_SIZE && \"Out of range\""

.subsections_via_symbols
