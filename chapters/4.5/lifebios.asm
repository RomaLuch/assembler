; lifebios.asm
; Игра "Жизнь" на поле 320x200, использующая вывод на экран средствами BIOS
;
; Компиляция:
; TASM:
; tasm /m lifebios.asm
; tlink /x lifebios.obj
; MASM:
; ml /c lifebios.asm
; link lifebios.obj
; WASM:
; wasm lifebios.asm
; wlink file lifebios.obj form DOS
;

	.model small
	.stack	100h	; явное задание стека - для EXE-программ
	.186			; для команд shl al,4 и shr al,4
	.code
start:
	push	FAR_BSS	; сегментный адрес буфера в DS
	pop	ds

;
; заполнение массива ячеек псевдослучайными значениями
;
	xor	ax,ax
	int	1Ah		; Функция AH = 0 INT 1Ah: получить текущее время
; DX теперь содержит число секунд, прошедших
; с момента включения компьютера, которое
; используется как начальное значение генератора
; случайных чисел
	mov	di,320*200+1	; максимальный номер ячейки
fill_buffer:
	imul	dx,4E35h	; простой генератор случайных чисел
	inc	dx		; из двух команд
	mov	ax,dx		; текущее случайное число копируется в AX
	shr	ax,15		; от него оставляется только один бит,
	mov	byte ptr [di],al	; и в массив копируется 00, если ячейка
; пуста, и 01, если заселена
	dec	di		; следующая ячейка
	jnz	fill_buffer	; продолжить цикл, если DI не стал равен нулю

	mov	ax,0013h	; графический режим 320x200, 256 цветов
	int	10h

; основной цикл

new_cycle:

; Шаг 1: для каждой ячейки вычисляется число соседей и записывается в старшие 4 
; бита этой ячейки

	mov	di,320*200+1	; максимальный номер ячейки
step_1:
	mov	al,byte ptr [di+1]	; в AL вычисляется сумма 
	add	al,byte ptr [di-1]	; значений восьми соседних ячеек,
	add	al,byte ptr [di+319]	; при этом в младших четырех 
	add	al,byte ptr [di-319]	; битах накапливается число 
	add	al,byte ptr [di+320]	; соседей
	add	al,byte ptr [di-320]
	add	al,byte ptr [di+321]
	add	al,byte ptr [di-321]
	shl	al,4			; теперь старшие четыре бита AL - число
					; соседей текущей ячейки
	or	byte ptr [di],al	; поместить их в старшие четыре бита 
					; текущей ячейки
	dec	di		; следующая ячейка
	jnz	step_1	; продолжить цикл, если DI не стал равен нулю


; Шаг 2: изменение состояния ячеек в соответствии с полученными в шаге 1 
; значениями числа соседей


	mov	di,320*200+1	; максимальный номер ячейки
flip_cycle:
	mov	al,byte ptr [di]	; считать ячейку из массива
	shr	al,4			; AL = число соседей
	cmp	al,3			; если число соседей = 3,
	je	birth			; ячейка заселяется,
	cmp	al,2			; если число соседей = 2,
	je	f_c_continue	; ячейка не изменяется,
	mov	byte ptr [di],0	; иначе - ячейка погибает
	jmp	short f_c_continue
birth:
	mov	byte ptr [di],1
f_c_continue:
	and	byte ptr [di],0Fh	; обнулить число соседей в старших битах 
					; ячейки
	dec	di			; следующая ячейка
	jnz	flip_cycle

;
; Вывод массива на экран средствами BIOS
;
	mov	si,320*200+1	; максимальный номер ячейки
	mov	cx,319		; максимальный номер столбца
	mov	dx,199		; максимальный номер строки
zdisplay:
	mov	al,byte ptr [si] ; цвет точки (00 - черный, 01 - синий)
	mov	ah,0Ch	; номер видеофункции в AH
	int	10h		; вывести точку на экран
	dec	si		; следующая ячейка
	dec	cx		; следующий номер столбца
	jns	zdisplay	; если столбцы не закончились - продолжить
	mov	cx,319	; иначе: снова максимальный номер столбца в CX
	dec	dx		; и следующий номер строки в DX
	jns	zdisplay	; если и строки закончились - выход из цикла

	mov	ah,1		; если не нажата клавиша
	int	16h
	jz	new_cycle	; следующий шаг жизни

	mov	ax,0003h	; восстановить текстовый режим
	int	10h
	mov	ax,4C00h	; и завершить программу
	int	21h

	.fardata?		; сегмент дальних неинициализированных данных
	db	320*200+1 dup(?)	; содержит массив ячеек
	end start
