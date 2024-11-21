	.model	tiny
	.code
	org	100h
start:
	mov	cx, 256
	mov	dl, 0
	mov	ah, 2
cloop:	int	21h
	inc 	dl
	test 	dl, 0Fh
	jnz 	continue_loop
	push 	dx
	mov 	dl, 0Dh
	int 	21h
	mov 	dl, 0Ah
	int 	21h
	pop 	dx
continue_loop:
	loop cloop

	ret
	end	start 	
