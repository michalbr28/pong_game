.486
.model flat, stdcall
option casemap : none

include \masm32\include\windows.inc
include \masm32\include\kernel32.inc
include \masm32\include\user32.inc
include \masm32\include\msvcrt.inc
includelib msvcrt.lib
include drd.inc
includelib drd.lib

	
X macro args : VARARG
asm_txt TEXTEQU <>
FORC char, <&args>
IFDIF <&char>, <!\>
asm_txt CATSTR asm_txt, <&char>
ELSE
asm_txt
asm_txt TEXTEQU <>
ENDIF
ENDM
asm_txt
endm
	

.data
MI_50_LE_NOAH equ 50

landWidth DWORD 1500
landHeight DWORD 900
limitY DWORD landHeight
limitX DWORD landWidth
borderY DWORD 0
turn DWORD 0
black DWORD 0

x1 DWORD 100
y1 DWORD 300
dirY1 DWORD 1

x2 DWORD 1325
y2 DWORD 300
dirY2 DWORD 1

;ball start position
x3 DWORD 650
y3 DWORD 300

diry3 DWORD 1
dirx3 DWORD 1

pngImag BYTE "Rect.bmp", 0
obj Img <0,0,0,0>
pngBall BYTE "Tennis.bmp", 0 
pok Img <0,0,0,0>
pngLand BYTE "Pongi.bmp", 0
land Img <0,0,0,0>
gameOver BYTE "GameOveri.bmp", 0
looser Img <0,0,0,0>
Winner BYTE "win.bmp", 0
win Img <0,0,0,0>
imgLand BYTE "Start.bmp", 0
start Img <0,0,0,0>


STime SYSTEMTIME{}; at: proc Random
;oRect RECT{200,200,400,400};
;hdcHandle HDC 0
;scoreCounter DWORD 0
;scoreFormat BYTE "%d", 0
;scoreText BYTE "aaaaaaaaaa", 0

.code


MoveY1 PROC
pusha
;inc scoreCounter
X	mov eax, y1 \ add eax, dirY1 \ mov y1, eax
X   mov eax, limitY \ cmp y1, eax \ mov borderY, eax \ jg stop
X	cmp y1, 10 \ mov borderY, 10 \ jl stop
jmp exit
stop :
X	mov eax, borderY \ mov y1, eax
exit :
popa
ret
MoveY1 ENDP

MoveY2 PROC
pusha
;inc scoreCounter
	mov eax, y2  
	add eax, dirY2 
	mov y2, eax

	mov eax, limitY
	cmp y2, eax
	mov borderY, eax
	jg stop

	cmp y2, 10
	mov borderY, 10
	jl stop

	jmp exit

stop :
	popa

	mov eax, borderY
	mov y2, eax

exit :
popa
ret
MoveY2 ENDP

MovementManger1 PROC
pusha
X	mov eax, turn \ inc eax \ mov turn, eax
X	cmp turn, 1 \ je doTurn
	popa
	jmp exit

doTurn :
	popa
	mov turn, 0

X	invoke GetAsyncKeyState, VK_W \ cmp eax, 0 \ mov dirY1, -1 \jne MoveY1
X	invoke GetAsyncKeyState, VK_S \ cmp eax, 0 \ mov dirY1, 1 \jne MoveY1

exit :
	ret
MovementManger1 ENDP

MovementManger2 PROC
pusha
X	mov eax, turn \ inc eax \ mov turn, eax
X	cmp turn, 1 \ je doTurn
	popa
	jmp exit

doTurn :
	popa
	mov turn, 0

X	invoke GetAsyncKeyState, VK_UP \ cmp eax, 0 \ mov dirY2, -1 \jne MoveY2
X	invoke GetAsyncKeyState, VK_DOWN \ cmp eax, 0 \ mov dirY2, 1 \jne MoveY2

exit :
	ret
MovementManger2 ENDP


BallX PROC	
	pusha
X	mov eax, x3 \ add eax, dirx3\ mov x3, eax			
X   mov eax, limitX \ cmp x3, eax 
X	popa \ jg goLeft		
X	cmp x3, 3 \ jl goRight
	jmp exit

goLeft:
	mov dirx3, -1
	jmp exit

goRight:
	mov dirx3, 1
	
exit:
	ret
BallX ENDP

BallY PROC	
	pusha
	X	mov eax, y3 \ add eax, diry3 \ mov y3, eax			
	X   mov eax, limitY \ cmp y3, eax 
	X	popa \ jg goDown		
	X	cmp y3, 3 \ jl goUp
jmp exit
	goDown:
		mov diry3, -1
		jmp exit
	goUp:
		mov diry3, 1
	exit: 
		ret
BallY ENDP

BallManger PROC	
	pusha
		add turn,1
	popa
		cmp turn, 1 
		je doTurn	
jmp exit
	doTurn:
		mov turn, 0			 
		invoke BallX
		invoke BallY
	exit:
		ret
BallManger ENDP

Collision PROC
	pusha
	 mov eax, dirx3 
	 cmp eax, 0 
	 jg right 
	 jl left

right:	
	mov eax,x3
	add eax, 50
	cmp eax,x2
	jge overXr
	jmp exit

overXr:
	mov eax,y2
	add eax,133
	cmp y3,eax
	jg exit

	mov eax,y3
	add eax,50
	cmp eax,y2
	jl exit

	mov dirx3,-1
	jmp left

	left:
		
	mov eax,x1	
	add eax,75
	cmp x3,eax
	jle overXl
	jmp exit

overXl:
	mov eax,y1
	add eax,133
	cmp y3,eax
	jg exit

	mov eax,y3
	cmp eax,y1
	jl exit

	mov dirx3,1
		
	exit: 
		popa
		ret
Collision ENDP


EndGame PROC		
		invoke drd_imageDraw, offset looser, 0, 0
		invoke drd_imageDraw, offset win, 750, 0
	ret
EndGame ENDP

EndGame1 PROC
	invoke drd_imageDraw, offset win, 0, 0
	invoke drd_imageDraw, offset looser,750, 0
  ret
EndGame1 ENDP

Init PROC	
	pusha
	X	mov eax, landWidth \ mov limitX, eax
	X	mov eax, limitX \ sub eax, pok.iwidth \ sub eax, 10 \ mov limitX, eax
	X	mov eax, landHeight \ mov limitY, eax
	X	mov eax, limitY \ sub eax, pok.iheight \ sub eax, 10 \ mov limitY, eax
	X	mov eax, landHeight \ mov limitY, eax
	X	mov eax, limitY \ sub eax, obj.iheight \ sub eax, 10 \ mov limitY, eax
	popa
	ret
Init ENDP


main PROC

	invoke drd_init, 1500, landHeight, 0
	invoke drd_imageLoadFile, offset imgLand, offset start
	invoke drd_imageLoadFile, offset pngImag, offset obj
	invoke drd_imageLoadFile, offset pngBall, offset pok
	invoke drd_imageLoadFile, offset pngLand, offset land
	invoke drd_imageLoadFile, offset gameOver, offset looser
	invoke drd_imageLoadFile, offset Winner, offset win
	invoke drd_imageSetTransparent, offset obj, 0ffffffh
	invoke drd_imageSetTransparent, offset pok, 0a0a0a0h 
	invoke Init

	invoke drd_imageDraw, offset start, 0, 0
	invoke drd_processMessages
	invoke drd_flip

starti:
	invoke GetAsyncKeyState, VK_SPACE 
	cmp eax, 0  
	jne again  
	jmp starti
again:
	cmp x3,10 
	jl endGame

cmp x3,1390
jne continue
invoke EndGame1
jmp over

endGame:
	invoke EndGame  
	jmp over

continue:

invoke drd_pixelsClear, black
invoke drd_imageDraw, offset land, 0, 0
invoke drd_imageDraw, offset obj, x1, y1
invoke drd_imageDraw, offset obj, x2, y2
invoke drd_imageDraw, offset pok, x3, y3

invoke Collision
invoke MovementManger1
invoke MovementManger2
invoke BallManger

over:

invoke drd_processMessages
invoke drd_flip
jmp again

	ret
main ENDP
end main