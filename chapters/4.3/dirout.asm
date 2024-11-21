	.model	tiny
	.386
	.code

	org	100h
start:
	mov	ax, 0003h
	int	10h
	cld

	mov	eax, 1F201F00h
	mov	bx, 0F20h
	mov	cx, 255
	mov	di, offset ctable
cloop:
	stosd
	inc	al

	test	cx, 0Fh
	jnz	continue_loop
	push	cx
	mov	cx, 80-32
	xchg	ax, bx
	rep	stosw

	xchg	bx, ax
	pop	cx
continue_loop:
	loop	cloop
	stosd

	mov	ax, 0B800h
	mov	es, ax
	xor	di, di
	mov	si, offset ctable
	mov	cx, 15*80+32
	rep	movsw
	ret
ctable:
	end	start
