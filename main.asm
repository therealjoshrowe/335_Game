TITLE ANSI Crawler main module (main.asm)
COMMENT *
Description: This is the main module for our game. It is also a revised from scratch version of previous code
Date: 03/27/2014
Revision Date: 03/27/2014
Programmer: Joshua Rowe
*

INCLUDE Irvine32.inc
INCLUDE header.inc

;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;MACROS
i_key EQU 105
j_key EQU 106
k_key EQU 107
l_key EQU 108
q_key EQU 113
s_key EQU 115
;-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------



.DATA
map BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
map_row_size_constant = ($ - map)
;   BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0    <-- This is so we can see the top row of the map b/c the row size constant obscures it
	BYTE 0, 2, 3, 1, 1, 1, 5, 1, 1, 1, 1, 1, 1, 1, 0
	BYTE 0, 1, 1, 1, 1, 1, 6, 1, 1, 1, 1, 1, 1, 3, 0
	BYTE 0, 1, 1, 1, 1, 1, 9, 1, 1, 1, 1, 1, 1, 1, 0
	BYTE 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 0
	BYTE 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
	
map_number_of_rows_constant = ($ - map) / map_row_size_constant
map_row_size DWORD map_row_size_constant
map_number_of_rows DWORD map_number_of_rows_constant
already_moved_map BYTE LENGTHOF map * map_number_of_rows_constant DUP(0)
health BYTE 2
number_of_enemies BYTE 5
player_death_prompt BYTE "You have died. Play Again?", 0
exit_prompt BYTE "Exiting.....", 0

.CODE

main PROC

;Main will be one big game loop that waits for user input, processes it, updates everything else, then loops back
;Commands from user will be interpreted by using a switch statement.

;here we will set the default color of our command window.

mov eax, white + (black * 16)
call SetTextColor

;Now we will display the title screen


MAIN_GAME_LOOP:

movzx eax, health
cmp eax, 0
jbe PLAYER_DEATH
INVOKE display, ADDR map, map_row_size, map_number_of_rows
INVOKE display_health, health

xor eax, eax
call ReadChar ;get input from user. Note, we have to sanitize the input to make sure we accept a letter reguardless of case.
or al, 00100000b ;set bit 5 to make any character entered lowercase.

CASE_1:
cmp al, q_key
jne CASE_2
jmp QUIT_KEY_PRESSED
CASE_2:
cmp al, i_key
jne CASE_3
INVOKE character_move_up, ADDR map, map_row_size, map_number_of_rows
jmp SWITCH_DONE
CASE_3:
cmp al, j_key
jne CASE_4
INVOKE character_move_left, ADDR map, map_row_size, map_number_of_rows
jmp SWITCH_DONE
CASE_4:
cmp al, k_key
jne CASE_5
INVOKE character_move_down, ADDR map, map_row_size, map_number_of_rows
jmp SWITCH_DONE
CASE_5:
cmp al, l_key
jne CASE_6
INVOKE character_move_right, ADDR map, map_row_size, map_number_of_rows
jmp SWITCH_DONE
CASE_6:


SWITCH_DONE:

INVOKE enemy_one_attack_check, ADDR map, map_row_size, map_number_of_rows, ADDR already_moved_map, ADDR health
INVOKE enemy_one_move, ADDR map, map_row_size, map_number_of_rows, ADDR already_moved_map
mov eax, 250
call delay
jmp MAIN_GAME_LOOP

PLAYER_DEATH:
call clrscr
mov edx, OFFSET player_death_prompt
call WriteString
call crlf

QUIT_KEY_PRESSED:
mov edx, OFFSET exit_prompt
call WriteString
call crlf

exit
main ENDP


END main