TITLE Inventory (inventory.asm)
COMMENT &
Name Of Game: ANSI Crawler
Description: This module is the inventory .
Date: 1/31/2014
Revision Date: 2/3/2014
Programmer: Joshua Rowe + Jeff Schafer
&

INCLUDE Irvine32.inc

b_key EQU 98																		 ; Used to exit inventory
d_key EQU 100																		 ; used to itiate delete 
y_key EQU 121																		 ; used to manipulate weapon bag



.data

prompt_15 BYTE "Bag is full!",0														 ; prompt to tell user bag is full
prompt_16 BYTE "You must delete an item to add to inventory!",0						 ; prompt to tell user they must delete something to add 
prompt_17 BYTE "Item added your bag.",0												 ; prompt to tell user item has succesfully been add to bag
prompt_18 BYTE "Delete an item? (y for yest n for no)",0
item_1 BYTE "Long Sword",0													 ; item 1
item_2 BYTE "Great Sword",0													 ; item 2
item_3 BYTE "Sword of a thousand truths",0									 ; item 3
item_4 BYTE "Broken Sword",0												 ; item 4
item_5 BYTE "Twin Blade",0													 ; item 5
item_6 BYTE "Empty",0
prompt_20 BYTE "Enter item number to delete in bag(type 0 if none!)",0				 ; prompt to ask user which item they would like to delete
prompt_21 BYTE "Enter item number to delete in armor bag",0							 ; prompt to ask user which item they would like to delete
prompt_23 BYTE "Would you like to delete another item? (y for yes & n for no)",0	 ; prompt to see if user would like to delete another item
prompt_24 BYTE "Exiting Inventory",0												 ; prompt to user they have exited inventory menu
prompt_25 BYTE "Your input value does not correspond to a valid action. Please re-enter a valid action!",0
prompt_26 BYTE "Press b to exit menu!",0
prompt_27 BYTE "Press d to delete an item.",0 
header    BYTE "Inventory Menu",0													 ; Inventory Menu Header
header2   BYTE "Item",0												 ; Bag Header



bag DWORD 0																			 ; array to hold all the weapon items
row_size = ($ - bag) / TYPE bag														 ; itiate all slots to be empty
		  DWORD 0 
		  DWORD 0 
		  DWORD 0 
		  DWORD 0
		  DWORD 0
		  DWORD 0
		  DWORD 0
		  DWORD 0
		  DWORD 0
		  DWORD 0
		  DWORD 0
		  DWORD 0
		  DWORD 0

.code
Inventory proc
push ebp
add ebp, esp
call clrscr
Inventory_Display:
mov edx, offset header
call WriteString
call Crlf
mov edx, offset prompt_26
call WriteString
call Crlf
mov edx, offset prompt_27
call WriteString
call Crlf
mov esi, offset bag
mov eax, 0
mov ebx, 0
mov edi, 0
mov edx, offset header2
call WriteString
call Crlf
.while (ebx < 16)
mov ecx, [esi]
cmp ecx, 0
JNE Long_Sword
Empty:
	 mov edx, offset item_6
	 call WriteString
	 jmp Next_Slot
Long_Sword:
	 cmp ecx, 1
	 JNE Great_Sword
	 mov edx, offset item_1
	 call WriteString
	 mov eax, 5
	 call WriteDec
	 jmp Next_Slot
Great_Sword:
	 cmp ecx, 2
	 JNE Sword_Of
	 mov edx, offset item_2
	 call WriteString
	 mov eax, 7
	 call WriteDec
	 jmp Next_Slot
Sword_Of:
	 cmp ecx, 3
	 JNE Broken
	 mov edx, offset item_3
	 call WriteString
	 mov eax, 10
	 call WriteDec
	 jmp Next_Slot
Broken:
	 cmp ecx, 4
	 JNE Twin
	 mov edx, offset item_4
	 call WriteString
	 mov eax, 4
	 call WriteDec
	 jmp Next_Slot
Twin:
	 cmp ecx, 5
	 JNE Next_Slot
	 mov edx, offset item_5
	 call WriteString
	 mov eax, 8
	 call WriteDec	 
Next_Slot:
	 call Crlf
	 add esi, 4	 
	 inc ebx
.endw


Inventory_Loop_Start:
call readChar
Delete1:																				 ; Deletion test if user wants to delete an item
	 cmp al, d_key
	 JNE CASE2
	 call Delete_Menu
	 add esp, 4
	 jmp Inventory_Display
CASE2:																				 ; <- This will be the final check. If it is not true, then jump to default.
	 cmp al, b_key																	 ; Do action if user entered 'i'
	 JNE DEFAULT_CASE2
	 mov edx, OFFSET prompt_24														 ; prompt to user that they are exiting inventory menu
	 call WriteString
	 JMP Inventory_Quit
DEFAULT_CASE2:
	 mov edx, OFFSET prompt_25														 ; prompt to user that they enter in a wrong command 
	 call WriteString
	 call Crlf
	 jmp Inventory_Loop_Start
Inventory_Quit:
	 pop ebp
	 ret
Inventory endp 

Delete_Menu proc				   ; pass bag offset in esi																 
push ebp
mov edx, offset prompt_20		   ; prompt to user for item deletion
call writestring
call ReadDec
cmp eax, 0
je End_Delete
sub eax, 1						   ; for row calculation
mov ecx, 4
mul ecx							   ; move to rom user specified
mov ebx, 0
mov esi, offset bag
mov [esi + eax], ebx
End_Delete:
call clrscr
pop ebp
ret
Delete_Menu endp

Item_Add proc							; item must be passed in edx to be added to inventory
.while (ebx < row_size)
mov ecx, [esi + edi]
cmp ecx, 0
jne Test_1
mov [esi + edi], edx
jmp Out_1
Test_1:
add edi, 4
cmp ebx, row_size
jne Loop_Again
push edx
mov edx, offset prompt_18
call readchar
cmp al, y_key								;y for yes
JNE Out_1
call Delete_Menu
pop edx
xor ebx,ebx
Loop_Again:
inc ebx
.endw
Out_1:
Item_add endp
END