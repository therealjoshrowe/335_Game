TITLE Procedures For Main Game Module (procedures.asm)


INCLUDE Irvine32.inc
INCLUDE header.inc



.CODE
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Display PROC, map_offset: PTR BYTE, row_size: DWORD, rows: DWORD ; we should probably use USES here to push any used registers and save them incase main has them for something
			   LOCAL x:DWORD, y:DWORD ;Probably do not need x local var, unless we want to update it every loop iteration
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
call clrscr
xor ebx, ebx ;The row that we are currently in
mov y, 0
mov x, 0

;A quick note here. the comparrisons in the for loops are above or equal because we would actually compare row_size or rows minus 1 to our x or y b/c of zero indexed concept
OUTER_FOR:
mov ecx, y
cmp ecx, rows
jae END_OUTER_FOR

mov x, 0 ;clear our offset from the start of the row
INNER_FOR:
mov esi, x
cmp esi, row_size
jae END_INNER_FOR

;This is where we do stuff with every element

mov edi, map_offset
add edi, ebx
add edi, esi
movzx eax, BYTE PTR [edi] ;get our current element's value into eax for inspection ;This is a temporary place to store our value, we will use eax for other reasons here soon.

cmp eax, 0
je BORDER
cmp eax, 1
je DISPLAY_SPACE
cmp eax, 2
je DISPLAY_CHARACTER
cmp eax, 3
je DISPLAY_ENEMY_1

cmp eax, 5
je DISPLAY_HORIZONTAL_DIVIDER
cmp eax, 6
je DISPLAY_VERTICAL_DIVIDER
cmp eax, 9
je HOLE
jmp NON_RECOGNIZED_ELEMENT_VALUE


BORDER: ;here is where we will display boarder elements and our check at the top is to make us do less work.
mov eax, brown + (black * 16)
call SetTextColor
mov eax, y
cmp eax, 0
je BORDER_CASE_1
mov ecx,  rows
sub ecx, 1
cmp eax, ecx ; we can compare if it is below rows because if it was 0, we would have already jumped.
jb BORDER_CASE_4
cmp eax, ecx ;for some reason rows - 1 would not calculatte the result, so I used registers
je BORDER_CASE_6 ;it is equal because we are going with the convention we set forth earlier in display. This can be confusing because y starts at 0, but rows will never be 0.

BORDER_CASE_1:
mov eax, x
cmp eax, 0
jne BORDER_CASE_2
mov al, 201
call WriteChar
jmp BORDER_SWITCH_DONE

BORDER_CASE_2:
mov eax, x
mov ecx, row_size ; for some reason the comparrison to row_size - 1 would not give the currect result, so I used registers
sub ecx, 1
cmp eax, ecx
je BORDER_CASE_3
mov al, 205
call WriteChar
jmp BORDER_SWITCH_DONE

BORDER_CASE_3:
; we know that x is equal to row_size
mov al, 187
call WriteChar
jmp BORDER_SWITCH_DONE

BORDER_CASE_4:
mov eax, x
cmp eax, 0
jne BORDER_CASE_5
mov al, 186
call WriteChar
jmp BORDER_SWITCH_DONE

BORDER_CASE_5: ;There is no test for when 0 < y < rows && 0 < x < row_size b/c these cases are considered NON_TRAVERSABLE_NON_BORDER, which is handled further down in this proc.
mov eax, x
mov ecx, row_size
sub ecx, 1
cmp eax, ecx
jne BORDER_CASE_DEFAULT
mov al, 186
call WriteChar
jmp BORDER_SWITCH_DONE

BORDER_CASE_6:
mov eax, x
cmp eax, 0
jne BORDER_CASE_7
mov al, 200
call WriteChar
jmp BORDER_SWITCH_DONE

BORDER_CASE_7:
mov eax, x
mov ecx, row_size
sub ecx, 1
cmp eax, ecx
je BORDER_CASE_8
mov al, 205
call WriteChar
jmp BORDER_SWITCH_DONE

BORDER_CASE_8:
;we know that x should be equal to row_size here, so there does not need to be a check.
mov al, 188
call WriteChar
jmp BORDER_SWITCH_DONE

BORDER_CASE_DEFAULT:
mov al, '?'
call WriteChar
jmp BORDER_SWITCH_DONE

DISPLAY_SPACE:
mov al, ' '
call WriteChar
jmp BORDER_SWITCH_DONE

HOLE:
mov al, 219
call WriteChar
jmp BORDER_SWITCH_DONE

DISPLAY_CHARACTER:
mov eax, white + (black * 16)
call SetTextColor
mov al, 1
call WriteChar
jmp BORDER_SWITCH_DONE ; we will reuse this label, instead of making a new one

DISPLAY_ENEMY_1:
mov eax, green + (black * 16)
call SetTextColor
mov al, 174
call WriteChar
jmp BORDER_SWITCH_DONE

DISPLAY_HORIZONTAL_DIVIDER:
mov eax, brown + (black * 16)
call SetTextColor
mov al, 205
call WriteChar
jmp BORDER_SWITCH_DONE

DISPLAY_VERTICAL_DIVIDER:
mov eax, brown + (black * 16)
call SetTextColor
mov al, 186
call WriteCHar
NON_RECOGNIZED_ELEMENT_VALUE:


BORDER_SWITCH_DONE:
mov eax, white + (black * 16)
call SetTextColor
add x, 1
jmp INNER_FOR
END_INNER_FOR:

add y, 1
add ebx, row_size
call crlf
jmp OUTER_FOR
END_OUTER_FOR:
ret ; As per STDCALL, clean up the stack.
Display ENDP

;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
character_move_left PROC, map_offset: PTR BYTE, row_size: DWORD, rows: DWORD
	 LOCAL x: DWORD, y: DWORD
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
mov x, 0
mov y, 0 ;initialize or local variables
xor ebx, ebx

OUTER_FOR:
mov ecx, y
cmp ecx, rows
jae END_OUTER_FOR

mov x, 0
INNER_FOR:
mov esi, x
cmp esi, row_size
jae END_INNER_FOR
;here is where we do things.
mov edi, map_offset
add edi, ebx
add edi, esi
movzx eax, BYTE PTR [edi]
cmp eax, 2
jne CONTINUE
cmp esi, 1 ; see if we are to the left of the border
je MOVE_LEFT_INVALID
sub edi, 1 ;let's peek at what value is in the position to the immediate left of ours.

movzx eax, BYTE PTR [edi] ;GET THE  VALUE INTO EAX HERE.
cmp eax, 1
jne MOVE_LEFT_INVALID
xor eax, eax
mov al, 2
mov [edi], al
add edi, 1
mov al, 1
mov [edi], al
jmp DONE

CONTINUE:
add x, 1
jmp INNER_FOR
END_INNER_FOR:

add ebx, row_size
add y, 1
;call crlf we totally do not  need this as we are not displaying anything.
jmp OUTER_FOR
END_OUTER_FOR:
jmp DONE

MOVE_LEFT_INVALID:
mov eax, 1
DONE:
ret ; as per STDCALL
character_move_left ENDP


;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
character_move_right PROC, map_offset: PTR BYTE, row_size: DWORD, rows: DWORD
	 LOCAL x: DWORD, y: DWORD
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
mov x, 0
mov y, 0
xor ebx, ebx

OUTER_FOR:
mov ecx, y
cmp ecx, rows
jae END_OUTER_FOR

mov x, 0
INNER_FOR:
mov esi, x
cmp esi, row_size
jae END_INNER_FOR
;here is where we do things.
mov edi, map_offset
add edi, ebx
add edi, esi
movzx eax, BYTE PTR [edi]
cmp eax, 2
jne CONTINUE
mov ecx, row_size
sub ecx, 1
cmp esi, ecx ; see if we are to the left of the border
je MOVE_RIGHT_INVALID
add edi, 1 ;let's peek at what value is in the position to the immediate right of ours.

movzx eax, BYTE PTR [edi] ;GET THE  VALUE INTO EAX HERE.
cmp eax, 1
jne MOVE_RIGHT_INVALID
xor eax, eax
mov al, 2
mov [edi], al
sub edi, 1
mov al, 1
mov [edi], al
jmp DONE


CONTINUE:
add x, 1
jmp INNER_FOR
END_INNER_FOR:

add ebx, row_size
add y, 1
;call crlf we totally do not  need this as we are not displaying anything.
jmp OUTER_FOR
END_OUTER_FOR:

MOVE_RIGHT_INVALID:
mov eax, 1


DONE:
ret ; as per STDCALL
character_move_right ENDP


;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
character_move_up PROC, map_offset: PTR BYTE, row_size: DWORD, rows: DWORD
	 LOCAL x: DWORD, y: DWORD
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


mov x, 0
mov y, 0
xor ebx, ebx

OUTER_FOR:
mov ecx, y
cmp ecx, rows
jae END_OUTER_FOR

mov x, 0
INNER_FOR:
mov esi, x
cmp esi, row_size
jae END_INNER_FOR
;here is where we do things.
mov edi, map_offset
add edi, ebx
add edi, esi
movzx eax, BYTE PTR [edi]
cmp eax, 2
jne CONTINUE
mov ecx, rows
sub ecx, 1
cmp y, ecx ; see if we are to the position directly below the border
je MOVE_RIGHT_INVALID
sub edi, row_size ;let's peek at what value is in the position to the immediate above of ours.

movzx eax, BYTE PTR [edi] ;GET THE  VALUE INTO EAX HERE.
cmp eax, 1
jne MOVE_RIGHT_INVALID
xor eax, eax
mov al, 2
mov [edi], al
add edi, row_size
mov al, 1
mov [edi], al
jmp DONE


CONTINUE:
add x, 1
jmp INNER_FOR
END_INNER_FOR:

add ebx, row_size
add y, 1
;call crlf we totally do not  need this as we are not displaying anything.
jmp OUTER_FOR
END_OUTER_FOR:

MOVE_RIGHT_INVALID:
mov eax, 1


DONE:
ret  ; as per STDCALL
character_move_up ENDP


;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
character_move_down PROC, map_offset: PTR BYTE, row_size: DWORD, rows: DWORD
	 LOCAL x: DWORD, y: DWORD
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

mov x, 0
mov y, 0
xor ebx, ebx

OUTER_FOR:
mov ecx, y
cmp ecx, rows
jae END_OUTER_FOR

mov x, 0
INNER_FOR:
mov esi, x
cmp esi, row_size
jae END_INNER_FOR
;here is where we do things.
mov edi, map_offset
add edi, ebx
add edi, esi
movzx eax, BYTE PTR [edi]
cmp eax, 2
jne CONTINUE
mov ecx, rows
sub ecx, 1
cmp y, ecx ; see if we are to the position directly below the border
je MOVE_RIGHT_INVALID
add edi, row_size ;let's peek at what value is in the position to the immediate above of ours.

movzx eax, BYTE PTR [edi] ;GET THE  VALUE INTO EAX HERE.
cmp eax, 1
jne MOVE_RIGHT_INVALID
xor eax, eax
mov al, 2
mov [edi], al
sub edi, row_size
mov al, 1
mov [edi], al
jmp DONE


CONTINUE:
add x, 1
jmp INNER_FOR
END_INNER_FOR:

add ebx, row_size
add y, 1
;call crlf we totally do not  need this as we are not displaying anything.
jmp OUTER_FOR
END_OUTER_FOR:

MOVE_RIGHT_INVALID:
mov eax, 1


DONE:
ret ; as per STDCALL
character_move_down ENDP


;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
enemy_one_move PROC, map_offset: PTR BYTE, row_size: DWORD, rows: DWORD, moved_map_offset: PTR BYTE
	 LOCAL x: DWORD, y: DWORD, direction: DWORD, changed_direction_count: DWORD 
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
call Randomize ; seed our random number generator
xor ebx, ebx
mov x, 0
mov y, 0

OUTER_FOR:
mov ecx, y
cmp ecx, rows
jae END_OUTER_FOR

mov x, 0
INNER_FOR:
mov esi, x
cmp esi, row_size
jae END_INNER_FOR
;do stuff here...

mov edi, moved_map_offset
add edi, ebx
add edi, esi
movzx eax, BYTE PTR [edi] ;check to see if this position on the map has already been moved to. If so, skip this element
cmp eax, 1
je CONTINUE

mov edi, map_offset
add edi, ebx
add edi, esi
movzx eax, BYTE PTR [edi] ;check to see if this position has an enemy that needs to be moved. If so, do work. If not, skip this element.
cmp eax, 3
jne CONTINUE

;now we need to determine what direction we will be moving...
mov eax, 1 ; we only want to produce one random number
call Random32 ;generate that number
mov ecx, 2 ; two directions to choose from
xor edx, edx ;clear edx to prevent overflow
div ecx

 
add edx, 1 ; to sync this value with the non-zero indexed values we use with direction
mov direction, edx
cmp edx, 2
je DIRECTION_2
DIRECTION_LOOP_START:
DIRECTION_1: ;left
; edi still has our current position in it btw
sub edi, 1 ;move left one
movzx ecx, BYTE PTR [edi]
cmp ecx, 1
jne CHANGE_DIRECTION ; we also need to check how many times we have changed direction. If it is the number of directions we have, we need to break our or will have an inifinte loop
mov al, 3
mov [edi], al
add edi, 1
mov al, 1
mov [edi], al

mov edi, moved_map_offset ;<----- we actually do not need to check this because we will never check what is already behind us in our array traversal.
add edi, ebx
add edi, esi
sub edi, 1 ;because we are moving left, so the moved to position is the position we moved to by moving left.
mov al, 1
mov [edi], al ;for true

DIRECTION_2: ;right
add edi, 1 ; the position to our right
movzx ecx, BYTE PTR [edi]
cmp ecx, 1
jne CHANGE_DIRECTION
mov al, 3
mov [edi], al
sub edi, 1
mov al, 1
mov [edi], al

mov edi, moved_map_offset
add edi, ebx
add edi, esi
add edi, 1 ; for the position to our right.
mov al, 1
mov [edi], al

mov edi, moved_map_offset ;<----- we actually do not need to check this because we will never check what is already behind us in our array traversal.
add edi, ebx
add edi, esi
add edi, 1 ;because we are moving right, so the moved to position is the position we moved to by moving right.
mov al, 1
mov [edi], al ;for true
CHANGE_DIRECTION:
mov eax, changed_direction_count
cmp eax, 2
jae CONTINUE
mov eax, direction
cmp eax, 1
jne OTHER
mov direction, 2
jmp DIRECTION_LOOP_START
OTHER:
mov direction, 1
jmp DIRECTION_LOOP_START


CONTINUE:
add x, 1
jmp INNER_FOR
END_INNER_FOR:

call crlf
add ebx, row_size
add y, 1
jmp OUTER_FOR
END_OUTER_FOR:

mov x, 0
mov y, 0
xor ebx, ebx

CLEAR_OUTER_FOR:
mov eax, y
mov ecx, rows
cmp eax, ecx
jae CLEAR_OUTER_FOR_END
mov x, 0
CLEAR_INNER_FOR:
mov esi, x
mov ecx, row_size
cmp esi, ecx
jae CLEAR_INNER_FOR_END
;Do stuff here::

mov edi, moved_map_offset
add edi, ebx
add edi, esi
mov al, 0
mov [edi], al

add x, 1
jmp CLEAR_INNER_FOR
CLEAR_INNER_FOR_END:

add ebx, row_size
add y, 1
jmp CLEAR_OUTER_FOR
CLEAR_OUTER_FOR_END:
ret
enemy_one_move ENDP


;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
display_health PROC, current_health: BYTE
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	 LOCAL string[8]: BYTE
	 mov string[0], 'H'
	 mov string[1], 'e'
	 mov string[2], 'a'
	 mov string[3], 'l'
	 mov string[4], 't'
	 mov string[5], 'h'
	 mov string[6], ':'
	 mov string[7], 0
lea edx, string
call WriteString

mov eax, red + (black * 16)
call SetTextColor
movzx ecx, current_health
L1:
mov al, 3 ;ASCII for the heart character.
call WriteChar
loop L1

mov eax, white + (black * 16)
call SetTextColor
call crlf

ret 
display_health ENDP

;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
enemy_one_attack_check PROC, map_offset: PTR BYTE, row_size: DWORD, rows: DWORD, already_moved_map_offset: PTR BYTE, current_health_offset: PTR BYTE
	 LOCAL x: DWORD, y: DWORD
;-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

mov x, 0
mov y, 0 ;initialize our local variables
mov ebx, 0

OUTER_FOR:
mov ecx, y
mov eax, rows
cmp ecx, eax
jae END_OUTER_FOR

mov x, 0 ;we are starting at the begining of ech row at the start of each iteration of the inner for
INNER_FOR:
mov esi, x
mov ecx, row_size
cmp esi, ecx
jae END_INNER_FOR
;Do stuff here.

mov edi, map_offset
add edi, ebx
add  edi, esi

movzx eax, BYTE PTR [edi]

cmp eax, 3 
jne CONTINUE
sub edi, 1
movzx eax, BYTE PTR [edi]
cmp eax, 2 ;see if the player is to the imeadiate left of our position.
jne CONTINUE

mov ecx, current_health_offset
mov al, [ecx]
sub al, 1
mov [ecx], al

mov edi, already_moved_map_offset
add edi, ebx
add edi, esi
mov al, 1
mov [edi], al

INVOKE display_damage, map_offset, row_size, rows


CONTINUE:
add x, 1
jmp INNER_FOR
END_INNER_FOR:

add y, 1
add ebx, row_size
jmp OUTER_FOR
END_OUTER_FOR:


ret ;as per STDCALL
enemy_one_attack_check ENDP

;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
display_damage PROC, map_offset: PTR BYTE, row_size: DWORD, rows: DWORD ; we should probably use USES here to push any used registers and save them incase main has them for something
			   LOCAL x:DWORD, y:DWORD ;Probably do not need x local var, unless we want to update it every loop iteration
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
call clrscr
xor ebx, ebx ;The row that we are currently in
mov y, 0
mov x, 0

;A quick note here. the comparrisons in the for loops are above or equal because we would actually compare row_size or rows minus 1 to our x or y b/c of zero indexed concept
OUTER_FOR:
mov ecx, y
cmp ecx, rows
jae END_OUTER_FOR

mov x, 0 ;clear our offset from the start of the row
INNER_FOR:
mov esi, x
cmp esi, row_size
jae END_INNER_FOR

;This is where we do stuff with every element

mov edi, map_offset
add edi, ebx
add edi, esi
movzx eax, BYTE PTR [edi] ;get our current element's value into eax for inspection ;This is a temporary place to store our value, we will use eax for other reasons here soon.

cmp eax, 0
je BORDER
cmp eax, 1
je DISPLAY_SPACE
cmp eax, 2
je DISPLAY_CHARACTER
cmp eax, 3
je DISPLAY_ENEMY_1

cmp eax, 5
je DISPLAY_HORIZONTAL_DIVIDER
cmp eax, 6
je DISPLAY_VERTICAL_DIVIDER
cmp eax, 9
je HOLE
jmp NON_RECOGNIZED_ELEMENT_VALUE


BORDER: ;here is where we will display boarder elements and our check at the top is to make us do less work.
mov eax, brown + (black * 16)
call SetTextColor
mov eax, y
cmp eax, 0
je BORDER_CASE_1
mov ecx,  rows
sub ecx, 1
cmp eax, ecx ; we can compare if it is below rows because if it was 0, we would have already jumped.
jb BORDER_CASE_4
cmp eax, ecx ;for some reason rows - 1 would not calculatte the result, so I used registers
je BORDER_CASE_6 ;it is equal because we are going with the convention we set forth earlier in display. This can be confusing because y starts at 0, but rows will never be 0.

BORDER_CASE_1:
mov eax, x
cmp eax, 0
jne BORDER_CASE_2
mov al, 201
call WriteChar
jmp BORDER_SWITCH_DONE

BORDER_CASE_2:
mov eax, x
mov ecx, row_size ; for some reason the comparrison to row_size - 1 would not give the currect result, so I used registers
sub ecx, 1
cmp eax, ecx
je BORDER_CASE_3
mov al, 205
call WriteChar
jmp BORDER_SWITCH_DONE

BORDER_CASE_3:
; we know that x is equal to row_size
mov al, 187
call WriteChar
jmp BORDER_SWITCH_DONE

BORDER_CASE_4:
mov eax, x
cmp eax, 0
jne BORDER_CASE_5
mov al, 186
call WriteChar
jmp BORDER_SWITCH_DONE

BORDER_CASE_5: ;There is no test for when 0 < y < rows && 0 < x < row_size b/c these cases are considered NON_TRAVERSABLE_NON_BORDER, which is handled further down in this proc.
mov eax, x
mov ecx, row_size
sub ecx, 1
cmp eax, ecx
jne BORDER_CASE_DEFAULT
mov al, 186
call WriteChar
jmp BORDER_SWITCH_DONE

BORDER_CASE_6:
mov eax, x
cmp eax, 0
jne BORDER_CASE_7
mov al, 200
call WriteChar
jmp BORDER_SWITCH_DONE

BORDER_CASE_7:
mov eax, x
mov ecx, row_size
sub ecx, 1
cmp eax, ecx
je BORDER_CASE_8
mov al, 205
call WriteChar
jmp BORDER_SWITCH_DONE

BORDER_CASE_8:
;we know that x should be equal to row_size here, so there does not need to be a check.
mov al, 188
call WriteChar
jmp BORDER_SWITCH_DONE

BORDER_CASE_DEFAULT:
mov al, '?'
call WriteChar
jmp BORDER_SWITCH_DONE

DISPLAY_SPACE:
mov al, ' '
call WriteChar
jmp BORDER_SWITCH_DONE

HOLE:
mov al, 219
call WriteChar
jmp BORDER_SWITCH_DONE

DISPLAY_CHARACTER:
mov eax, red + (black * 16)
call SetTextColor
mov al, 1
call WriteChar
jmp BORDER_SWITCH_DONE ; we will reuse this label, instead of making a new one

DISPLAY_ENEMY_1:
mov eax, green + (black * 16)
call SetTextColor
mov al, 174
call WriteChar
jmp BORDER_SWITCH_DONE

DISPLAY_HORIZONTAL_DIVIDER:
mov eax, brown + (black * 16)
call SetTextColor
mov al, 205
call WriteChar
jmp BORDER_SWITCH_DONE

DISPLAY_VERTICAL_DIVIDER:
mov eax, brown + (black * 16)
call SetTextColor
mov al, 186
call WriteCHar
NON_RECOGNIZED_ELEMENT_VALUE:


BORDER_SWITCH_DONE:
mov eax, white + (black * 16)
call SetTextColor
add x, 1
jmp INNER_FOR
END_INNER_FOR:

add y, 1
add ebx, row_size
call crlf
jmp OUTER_FOR
END_OUTER_FOR:
ret ; As per STDCALL, clean up the stack.
display_damage ENDP

display_title_screen PROC

ret
display_title_screen ENDP

END