	.model	tyny
	.code
	org	100h
start:
	mov	ax, 0003h
	int	10h
	mov	dx, 0
	mov	si, 256
	mov	al, 0
	mov	ah, 9
	mov	cx, 1
	mov	bl, 00011111b
	
cloop:
	int	10h
	push	ax
	mov	ah, 2
	
	inc	dl
	int	10h
	mov	ax, 0920h
	int	10h
	mov	ah, 2
	inc	dl
	int	10h
	pop	ax

	inc	al
	test	al, 0Fh
	jnz	continue_loop

	push	ax
	mov	ah, 2
	inc	dh
	mov	dl, 0
	int	10h
	pop	ax

continue_loop:
	dec	si
	jnz	cloop
	ret
	end	start	
