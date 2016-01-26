TITLE Function Prototypes include file.
COMMENT *
Description: This is a simple include file that has all  of the fucntion prototypes for ANSI Crawler.
Date: 03/24/2014
Revision Date: 04/03/2014
Programmer: Joshua Rowe & Jeff Schafer
*
display PROTO, map_offset: PTR BYTE, row_size: DWORD, rows: DWORD
character_move_left PROTO, map_offset: PTR BYTE, row_size: DWORD, rows: DWORD
character_move_right PROTO, map_offset: PTR BYTE, row_size: DWORD, rows: DWORD
character_move_up PROTO, map_offset: PTR BYTE, row_size: DWORD, rows: DWORD
character_move_down PROTO, map_offset: PTR BYTE, row_size: DWORD, rows: DWORD
enemy_one_move PROTO, map_offset: PTR BYTE, row_size: DWORD, rows: DWORD, moved_map_offset: PTR BYTE
display_health PROTO, current_health: BYTE
enemy_one_attack_check PROTO, map_offset: PTR BYTE, row_size: DWORD, rows: DWORD, already_moved_map_offset: PTR BYTE, current_health_offset: PTR BYTE
display_damage PROTO, map_offset: PTR BYTE, row_size: DWORD, rows: DWORD