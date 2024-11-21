	.model
	.code
	org 	100h
start:
	mov 	ah, 40h
	mov	bx, 2
	mov	dx, offset message
	mov	cx, message_length
	int 	21h
	ret
message	db	"this function could print symbol $"
message_length = $-message

	end	start
