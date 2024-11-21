	.model	tiny
	.code
	org 100h
start:  mov	ah,9
	mov	dx,offset message
	int 	21h
	ret
message db	"Hello World!", 00h, 0Ah, '$'
	end	start
