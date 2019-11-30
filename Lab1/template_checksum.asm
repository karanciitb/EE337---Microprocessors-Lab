ORG 00H
;-- code memory location 00h
LJMP MAIN

ORG 50H
;-- code memory location 50h

INIT:
	;-- store the numbers to be added at appropriate locations
	
	RET
;-- end of subroutine INIT

ADD_40:
	;-- add the numbers stored from memory location 40h to 67h
	;-- by using subroutine written in homework

	RET
;-- end of subroutine ADD_40
	
TWOS_COMP:
	;-- perform 2's compliment of the resultant sum
	;-- store the checksum byte at memory location 68h
	
	RET
;-- end of subroutine TWOS_COMP

ADD_41:
        ;-- add numbers from memory location 40h to 68h
	
	RET
;-- end of subroutine ADD_41

ORG 0200H
;-- code memory location 200h
MAIN:
	ACALL INIT
	ACALL ADD_40
	ACALL TWOS_COMP
	ACALL ADD_41	;verify the result
	HERE:SJMP HERE
END



