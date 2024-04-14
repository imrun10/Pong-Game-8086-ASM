STACK SEGMENT PARA STACK
	      DB 64 DUP ('  ')
STACK ENDS

DATA SEGMENT PARA 'DATA'
	originX        DW 0A0h	; ORIGINIAL X POSITION OF THE BALL
	originY        DW 64H 	; ORIGINIAL Y POSITION OF THE BALL
	windowWidth    DW 140h	; width of the window 320x200 pixels converted to hex
	windowHeight   DW 0C8h	; height of the window
	windowBounds   DW 6   	; size of the window
	timeAux        DB 00h 	; auxiliary variable to store the time
	ballX          DW 0A0h	; x position of the ball
	ballY          DW 64h 	; y position of the ball
	ballSize       DW 04h 	; size of the ball
	ballVelocityX  DW 05h 	; velocity of the ball in the x axis
	ballVelocityY  DW 02h 	; velocity of the ball in the y axis
	paddleLeftX    DW 0Ah 	; x position of the left paddle
	paddleLeftY    DW 0Ah 	; y position of the left paddle
	paddleWidth    DW 03h 	; width of the paddle
	paddleHeight   DW 1Fh 	; height of the paddle
	paddleRightX   DW 130h	; x position of the right paddle
	paddleRightY   DW 0A0h	; y position of the right paddle
	paddleVelocity DW 0Fh 	; velocity of the paddle
	paddleLeftPoint DB 0
	paddleRightPoint DB 0

DATA ENDS

CODE SEGMENT PARA 'CODE'
MAIN PROC FAR
	                                 ASSUME CS:CODE,DS:DATA,SS:STACK        	; sets the segment to the one the code is using
	                                 PUSH   DS                              	; push to the stack the DS SEGMENT
	                                 SUB    AX,AX                           	; clean register
	                                 PUSH   AX
	                                 MOV    AX,DATA                         	; save the constants of the DATA SEGMENT in the AX register
	                                 MOV    DS, AX                          	; save the contents of AX in the DS segment
	                                 POP    AX                              	; release the top item from the stack to the AX register
	                                 POP    AX                              	; release the top item from the stack to the AX register
	
	                                 CALL   CLEAR_SCREEN                    	; call the clear screen function

	CHECK_TIME:                      
	                                 MOV    AH, 2Ch                         	; get system time
	                                 INT    21h                             	; execute the command CH = HOUR, CL = MINUTE, DH = SECOND, DL = 1/100 SECONDS
	                                 cmp    DL, timeAux                     	; compare the current hour with the auxiliary variable
	                                 je     CHECK_TIME                      	; if they are the same, go to the next step
	; IF IT'S different, run the rest of the code
	                                 MOV    timeAux, DL                     	; save the current time in the auxiliary variable UPDATING TIME
		
	                                 CALL   CLEAR_SCREEN                    	; call the clear screen function
	                                 CALL   MOVE_BALL                       	; call the move ball function
	                                 CALL   DRAW_BALL                       	; call the draw ball function
	                                 CALL   MOVE_PADDLES                    	; call the move paddle function
	                                 CALL   DRAW_PADDLES                    	; call the draw paddle function
	                                 JMP    CHECK_TIME                      	; go back to the beginning of the loop
	
	                                 RET
		 
MAIN ENDP
MOVE_PADDLES PROC NEAR                                                  		; process movement of the paddles

	; Left paddle movement

	; check if any key is being pressed (if not check the other paddle)
	                                 MOV    AH, 01h
	                                 INT    16h
	                                 JZ     CHECK_RIGHT_PADDLE_MOVEMENT     	; ZF = 1, JZ -> Jump If Zero

	; check which key is being pressed (AL = ASCII character)
	                                 MOV    AH, 00h
	                                 INT    16h

	; if it is 'w' or 'W' move up
	                                 CMP    AL, 77h                         	; 'w'
	                                 JE     MOVE_LEFT_PADDLE_UP
	                                 CMP    AL, 57h                         	; 'W'
	                                 JE     MOVE_LEFT_PADDLE_UP

	; if it is 's' or 'S' move down
	                                 CMP    AL, 73h                         	; 's'
	                                 JE     MOVE_LEFT_PADDLE_DOWN
	                                 CMP    AL, 53h                         	; 'S'
	                                 JE     MOVE_LEFT_PADDLE_DOWN
	                                 JMP    CHECK_RIGHT_PADDLE_MOVEMENT

	MOVE_LEFT_PADDLE_UP:             
	                                 MOV    AX, paddleVelocity
	                                 SUB    paddleLeftY, AX

	                                 MOV    AX, windowBounds
	                                 CMP    paddleLeftY, AX
	                                 JL     FIX_PADDLE_LEFT_TOP_POSITION
	                                 JMP    CHECK_RIGHT_PADDLE_MOVEMENT

	FIX_PADDLE_LEFT_TOP_POSITION:    
	                                 MOV    paddleLeftY, AX
	                                 JMP    CHECK_RIGHT_PADDLE_MOVEMENT

	MOVE_LEFT_PADDLE_DOWN:           
	                                 MOV    AX, paddleVelocity
	                                 ADD    paddleLeftY, AX
	                                 MOV    AX, windowHeight
	                                 SUB    AX, windowBounds
	                                 SUB    AX, paddleHeight
	                                 CMP    paddleLeftY, AX
	                                 JG     FIX_PADDLE_LEFT_BOTTOM_POSITION
	                                 JMP    CHECK_RIGHT_PADDLE_MOVEMENT

	FIX_PADDLE_LEFT_BOTTOM_POSITION: 
	                                 MOV    paddleLeftY, AX
	                                 JMP    CHECK_RIGHT_PADDLE_MOVEMENT


	; Right paddle movement
	CHECK_RIGHT_PADDLE_MOVEMENT:     

	; if it is 'o' or 'O' move up
	                                 CMP    AL, 6Fh                         	; 'o'
	                                 JE     MOVE_RIGHT_PADDLE_UP
	                                 CMP    AL, 4Fh                         	; 'O'
	                                 JE     MOVE_RIGHT_PADDLE_UP

	; if it is 'l' or 'L' move down
	                                 CMP    AL, 6Ch                         	; 'l'
	                                 JE     MOVE_RIGHT_PADDLE_DOWN
	                                 CMP    AL, 4Ch                         	; 'L'
	                                 JE     MOVE_RIGHT_PADDLE_DOWN
	                                 JMP    EXIT_PADDLE_MOVEMENT


	MOVE_RIGHT_PADDLE_UP:            
	                                 MOV    AX, paddleVelocity
	                                 SUB    paddleRightY, AX

	                                 MOV    AX, windowBounds
	                                 CMP    paddleRightY, AX
	                                 JL     FIX_PADDLE_RIGHT_TOP_POSITION
	                                 JMP    EXIT_PADDLE_MOVEMENT

	FIX_PADDLE_RIGHT_TOP_POSITION:   
	                                 MOV    paddleRightY, AX
	                                 JMP    EXIT_PADDLE_MOVEMENT

	MOVE_RIGHT_PADDLE_DOWN:          
	                                 MOV    AX, paddleVelocity
	                                 ADD    paddleRightY, AX
	                                 MOV    AX, windowHeight
	                                 SUB    AX, windowBounds
	                                 SUB    AX, paddleHeight
	                                 CMP    paddleRightY, AX
	                                 JG     FIX_PADDLE_RIGHT_BOTTOM_POSITION
	                                 JMP    EXIT_PADDLE_MOVEMENT

	FIX_PADDLE_RIGHT_BOTTOM_POSITION:
	                                 MOV    paddleRightY, AX
	                                 JMP    EXIT_PADDLE_MOVEMENT

	EXIT_PADDLE_MOVEMENT:            
	                                 RET

MOVE_PADDLES ENDP




DRAW_PADDLES PROC NEAR
	                                 MOV    CX, paddleLeftX                 	; set the initial column (X)
	                                 MOV    DX, paddleLeftY                 	; set the initial line (Y)
	                    
	DRAW_PADDLE_LEFT_HORIZONTAL:     
	                                 MOV    AH, 0Ch                         	; set the configuration to writing a pixel
	                                 MOV    AL, 0Fh                         	; choose white as color
	                                 MOV    BH, 00h                         	; set the page number
	                                 INT    10h                             	; execute the configuration
	                                 INC    CX                              	; CX = CX + 1
	                                 MOV    AX, CX                          	; CX - paddleLeftX > paddleWidth (Y -> We go to the next line, N -> We continue to the next column
	                                 SUB    AX, paddleLeftX                 	; AX = CX - paddleLeftX meaning the difference between the current column and the initial column
	                                 CMP    AX, paddleWidth                 	; compare the difference with the width of the paddle
	                                 JNG    DRAW_PADDLE_LEFT_HORIZONTAL     	; if the difference is less than the width of the paddle, we continue to the next column
	                                 MOV    CX, paddleLeftX                 	; the CX register goes back to the initial column
	                                 INC    DX                              	; we advance one line
	                                 MOV    AX, DX                          	; DX - paddleLeftY > paddleHeight (Y -> we exit this procedure, N -> we continue to the next line
	                                 SUB    AX, paddleLeftY                 	; AX = DX - paddleLeftY meaning the difference between the current line and the initial line
	                                 CMP    AX, paddleHeight                	; compare the difference with the height of the paddle
	                                 JNG    DRAW_PADDLE_LEFT_HORIZONTAL     	; if the difference is less than the height of the paddle, we continue to the next line
	                
	                                 MOV    CX, paddleRightX                	; set the initial column (X)
	                                 MOV    DX, paddleRightY                	; set the initial line (Y)
	DRAW_PADDLE_RIGHT_HORIZONTAL:    
	                                 MOV    AH, 0Ch                         	; set the configuration to writing a pixel
	                                 MOV    AL, 0Fh                         	; choose white as color
	                                 MOV    BH, 00h                         	; set the page number
	                                 INT    10h                             	; execute the configuration
	                                 INC    CX                              	; CX = CX + 1
	                                 MOV    AX, CX                          	; CX - paddleRightX > paddleWidth (Y -> We go to the next line, N -> We continue to the next column
	                                 SUB    AX, paddleRightX                	; AX = CX - paddleRightX meaning the difference between the current column and the initial column
	                                 CMP    AX, paddleWidth                 	; compare the difference with the width of the paddle
	                                 JNG    DRAW_PADDLE_RIGHT_HORIZONTAL    	; if the difference is less than the width of the paddle, we continue to the next column
	                                 MOV    CX, paddleRightX                	; the CX register goes back to the initial column
	                                 INC    DX                              	; we advance one line
	                                 MOV    AX, DX                          	; DX - paddleRightY > paddleHeight (Y -> we exit this procedure, N -> we continue to the next line
	                                 SUB    AX, paddleRightY                	; AX = DX - paddleRightY meaning the difference between the current line and the initial line
	                                 CMP    AX, paddleHeight                	; compare the difference with the height of the paddle
	                                 JNG    DRAW_PADDLE_RIGHT_HORIZONTAL    	; if the difference is less than the height of the paddle, we continue to the next line
	                     
						 
	                                 RET
MOVE_BALL PROC NEAR
	                                 MOV    AX, ballVelocityX               	; set the velocity of the ball in the x-axis
	                                 ADD    ballX, AX                       	; add the velocity to the x position of the ball
	; x-axis collision, <0 left boundary >windowWidth right boundary
	                                 MOV    AX, windowBounds
	                                 CMP    ballX, AX                       	; compare the x position of the ball with 0
	                                 JL     PL_TWO_POINT                  	; if the x position of the ball is less than 0 p2 gets a point and reset the ball
									
	                                 MOV    AX, windowWidth
	                                 SUB    AX, ballSize
	                                 SUB    AX, windowBounds
	                                 CMP    ballX, AX                       	; compare the x position of the ball with the width of the window
	                                 JG     PL_ONE_POINT                  	; IF IT MORE THAN THE WINDOW WITH THEN P1 GETS THE POINTS


	                                 JMP    CONTINUE
PL_ONE_POINT: ;player 1 gets a point
INC paddleLeftPoint
CALL RESET_BALL
CMP paddleLeftPoint, 5
JGE GAME_OVER
RET
PL_TWO_POINT: ;player 2 gets a point
INC paddleRightPoint
CALL RESET_BALL
CMP paddleRightPoint, 5
JGE GAME_OVER
RET

GAME_OVER: ; rests point after 5
MOV paddleLeftPoint, 0
MOV paddleRightPoint, 0
CALL RESET_BALL
RET

	NEG_VELOCITY_X:                  
	                                 CALL   RESET_BALL                      	; change the direction of the velocity in the x-axis
	                                 RET
	CONTINUE:                        

	                                 MOV    AX, ballVelocityY               	; set the velocity of the ball in the y-axis
	                                 ADD    ballY, AX                       	; add the velocity to the y position of the ball
	; y-axis collision, <0 top boundary >windowHeight bottom boundary
	                                 MOV    AX, windowBounds
	                                 CMP    ballY, AX                       	; compare the y position of the ball with 0
	                                 JL     NEG_VELOCITY_Y                  	; if the y position of the ball is less than 0, go to the NEG_VELOCITY_Y label
	                                 MOV    AX, windowHeight
	                                 SUB    AX, ballSize
	                                 SUB    AX, windowBounds
	                                 CMP    ballY, AX                       	; compare the y position of the ball with the height of the window
					
	                                 JG     NEG_VELOCITY_Y                  	; if the y position of the ball is greater than the height of the window, go to the NEG_VELOCITY_Y label
									JMP CONTINE2
	
NEG_VELOCITY_Y:                  
	                                 NEG    ballVelocityY                   	; change the direction of the velocity in the y-axis
								
	                                 RET
CONTINE2:
		
                   
	; check if ball is colliding with the right paddle
	; you need to check the sll 4 edges of the ball and the paddle to see if they are interecting, that is how you program colllision

	;edge 1
	                                 MOV    AX, ballX
	                                 ADD    AX, ballSize
	                                 CMP    AX, paddleRightX
	                                 JNG    CHECK_LEFT_PADDLE_COLLISION

	;edge 2
	                                 MOV    AX, paddleRightX
	                                 ADD    AX, paddleWidth
	                                 CMP    AX, ballX
	                                 JNG    CHECK_LEFT_PADDLE_COLLISION

	;edge 3
	                                 MOV    AX, ballY
	                                 ADD    AX, ballSize
	                                 CMP    AX, paddleRightY
	                                 JNG    CHECK_LEFT_PADDLE_COLLISION

	;edge 4
	                                 MOV    AX, paddleRightY
	                                 ADD    AX, paddleHeight
	                                 CMP    AX, ballY
	                                 JNG    CHECK_LEFT_PADDLE_COLLISION

	;if it reaches here there is a collision with the right paddle

	                                 JMP   COLLIDED
	                                 RET                                    	;the ball can't collide with two paddles

	CHECK_LEFT_PADDLE_COLLISION:     
		

	; check if ball is colliding with the left paddle
	;same as above but inverse the comparisons and also with the left paddle

	;edge 1
	                                 MOV    AX, ballX
	                                 ADD    AX, ballSize
	                                 CMP    AX, paddleLeftX
	                                 JNG    NO_COLLISION

	;edge 2
	                                 MOV    AX, paddleLeftX
	                                 ADD    AX, paddleWidth
	                                 CMP    AX, ballX
	                                 JNG    NO_COLLISION

	;edge 3
	                                 MOV    AX, ballY
	                                 ADD    AX, ballSize
	                                 CMP    AX, paddleLeftY
	                                 JNG    NO_COLLISION

	;edge 4
	                                 MOV    AX, paddleLeftY
	                                 ADD    AX, paddleHeight
	                                 CMP    AX, ballY
	                                 JNG    NO_COLLISION

	;if it reaches here there is a collision with the left paddle


	                                 JMP   COLLIDED
	                                 
	
	COLLIDED:                        
	                                 NEG    ballVelocityX
	                                 RET
		 
	NO_COLLISION:                    
	                                 RET


MOVE_BALL ENDP
	
CLEAR_SCREEN PROC NEAR                                                  		; clear the screen by restarting the video mode
	                                 MOV    AH, 00h                         	; set the configuration to video mode
	                                 MOV    AL, 13h                         	; choose the video mode
	                                 INT    10h                             	; execute the configuration
		
	                                 MOV    AH, 0
	                                 MOV    AL,13h                          	;choose the video mode
	                                 INT    10h                             	;execute the configuration
		
	                                 MOV    AH,0Bh                          	;set the configuration
	                                 MOV    BH,00h                          	;to the background color
	                                 MOV    BL,00h                          	;choose black as background color
	                                 INT    10h                             	;execute the configuration
			
	                                 RET
			
CLEAR_SCREEN ENDP

RESET_BALL PROC NEAR
	                                 MOV    AX, originX                     	; set the initial x position of the ball
	                                 MOV    ballX, AX                       	; save the initial x position of the ball in the ballX variable
	                                 MOV    AX, originY                     	; set the initial y position of the ball
	                                 MOV    ballY, AX                       	; save the initial y position of the ball in the ballY variable
	                                 RET
RESET_BALL ENDP
DRAW_BALL PROC NEAR
	                                 MOV    CX, ballX                       	; set the initial column (X)
	                                 MOV    DX, ballY                       	; set the initial line (Y)

	DRAW_BALL_HORIZONTAL:            
	                                 MOV    AH, 0Ch                         	; set the configuration to writing a pixel
	                                 MOV    AL, 0Fh                         	; choose white as color
	                                 MOV    BH, 00h                         	; set the page number
	                                 INT    10h                             	; execute the configuration

	                                 INC    CX                              	; CX = CX + 1
	                                 MOV    AX, CX                          	; CX - ballX > ballSize (Y -> We go to the next line, N -> We continue to the next column
	                                 SUB    AX, ballX                       	; AX = CX - ballX meaning the difference between the current column and the initial column
	                                 CMP    AX, ballSize                    	; compare the difference with the size of the ball
	                                 JNG    DRAW_BALL_HORIZONTAL            	; if the difference is less than the size of the ball, we continue to the next column

	                                 MOV    CX, ballX                       	; the CX register goes back to the initial column
	                                 INC    DX                              	; we advance one line

	                                 MOV    AX, DX                          	; DX - ballY > ballSize (Y -> we exit this procedure, N -> we continue to the next line
	                                 SUB    AX, ballY                       	; AX = DX - ballY meaning the difference between the current line and the initial line
	                                 CMP    AX, ballSize                    	; compare the difference with the size of the ball
	                                 JNG    DRAW_BALL_HORIZONTAL            	; if the difference is less than the size of the ball, we continue to the next line

	                                 RET
DRAW_BALL ENDP


CODE ENDS
END