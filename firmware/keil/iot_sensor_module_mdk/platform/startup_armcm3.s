        PRESERVE8
        THUMB

Stack_Size      EQU     0x00000400

        AREA    STACK, NOINIT, READWRITE, ALIGN=3
Stack_Mem       SPACE   Stack_Size
        EXPORT  __initial_sp
__initial_sp

        AREA    RESET, DATA, READONLY
        EXPORT  __Vectors

__Vectors
        DCD     __initial_sp
        DCD     Reset_Handler
        DCD     Default_Handler
        DCD     Default_Handler
        DCD     Default_Handler
        DCD     Default_Handler
        DCD     Default_Handler
        DCD     0
        DCD     0
        DCD     0
        DCD     0
        DCD     Default_Handler
        DCD     Default_Handler
        DCD     0
        DCD     Default_Handler
        DCD     Default_Handler

        AREA    |.text|, CODE, READONLY
        EXPORT  Reset_Handler
        IMPORT  main

Reset_Handler
        BL      main

Stop
        B       Stop

Default_Handler
        B       Default_Handler

        END
