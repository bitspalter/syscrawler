%include "macro.asm"
%include "dir.asm"
%include "int2string.asm"
%include "date.asm"

;//////////////////////////////////////////////////////////////////////////////////////////////////
;// [ DATA ]
;//////////////////////////////////////////////////////////////////////////////////////////////////

section .data

   STR_ROOT:    db      './', 0x00

   STR_DATA:    db      'TEST',  0x0A
   LEN_DATA     equ      $ - STR_DATA

   STR_ERROR:   db      'ERROR', 0x0A
   LEN_ERROR    equ      $ - STR_ERROR
   
   STR_DIR:     db      'DIRECTORY'
   LEN_DIR      equ      $ - STR_DIR
   
   STR_FILE:    db      'FILE'
   LEN_FILE     equ      $ - STR_FILE
   
   STR_FUNC:    db      'FUNC'
   LEN_FUNC     equ      $ - STR_FUNC
   
   STR_OPEN:    db      'OPEN'
   LEN_OPEN     equ      $ - STR_OPEN
   
   STR_HANDLE:  db      'HANDLE'
   LEN_HANDLE   equ      $ - STR_HANDLE
   
   ;///////////////////////////////////////////////////
   
   NEW_LINE     db       0x0A
   SPACE        db       0x20
   SLASH        db       0x2F
   COLON        db       0x3A
   POINT        db       0x2E
   
   DCounter     dq       0x00
   FCounter     dq       0x00
   ECounter     dq       0x00

   ;///////////////////////////////////////////////////
   
   SYS_READ     equ      0x00     ; file read
   SYS_WRITE    equ      0x01     ; file write
   SYS_OPEN     equ      0x02     ; file open
   SYS_CLOSE    equ      0x03     ; file close
   SYS_EXIT     equ      0x3C     ; terminate
   SYS_TIME     equ      0xC9     ; get time
   SYS_DIR64    equ      0xD9     ; sys_getdents64
   
   ;///////////////////////////////////////////////////

   O_RDONLY     equ      0x00     ; read only
   O_WRONLY     equ      0x01     ; write only
   O_RDWR       equ      0x02     ; read and write

   O_CREAT      equ      0x40     ; create if not exist

   PERM         equ      0666q

   SUCCESS      equ      0x00     ; success code

   STDIN        equ      0x00     ; standard input
   STDOUT       equ      0x01     ; standard output
   STDERR       equ      0x02     ; standard error
   
   DT_DIR       equ      0x04     ; folder
   DT_REG       equ      0x08     ; file

   DOT          equ      0x2E
   
   ;///////////////////////////////////////////////////
   ;// [ date ] Stack layout
   ;///////////////////////////////////////////////////
   
   cDATEq      equ      0x90
   
   pSECOND     equ      0x08
   pMINUTE     equ      0x10 
   pHOUR       equ      0x18
   pDAY        equ      0x20
   pMONTH      equ      0x28
   pYEAR       equ      0x30
   pWEEKDAY    equ      0x38
   pTIMESTAMP  equ      0x40
   
   pREMSEC     equ      0x48
   pREMDAY     equ      0x50
   pREMYEAR    equ      0x58
   
   pTEMPSEC    equ      0x60
   pTEMPDAY    equ      0x68
   pTEMPMONTH  equ      0x70
   pTEMPYEAR   equ      0x78
   
   pCYCLES_QC  equ      0x80
   pCYCLES_C   equ      0x88
   pCYCLES_Q   equ      0x90
   
   ;///////////////////////////////////////////////////
   ; seconds: (01.01.1970 - 29.02.2000)
   LEAPOCH        equ   (946684800 + 86400 * (31 + 29))
   
   DAYS_PER_400Y  equ   (365 * 400 + 97)
   DAYS_PER_100Y  equ   (365 * 100 + 24)
   DAYS_PER_4Y    equ   (365 *   4 +  1)
   
   DAYS_PER_MONTH db    31,30,31,30,31,31,30,31,30,31,31,29
   
   ;///////////////////////////////////////////////////
   ;// [ Dir ] Stack layout
   ;///////////////////////////////////////////////////
   
   cSTACKVq        equ     0xF000
   
   cInput          equ     0x08
   pInput          equ     0x10
   pFile           equ     0x18
   cBuffer         equ     0x20
   cFName          equ     0x28
   pFName          equ     0x30
   pSTRING         equ     0x1130
   pDIR64          equ     0xF000
   cDIR64          equ     pDIR64 - pSTRING
   
;///////////////////////////////////////////////////

section .bss

   CBUFFER      equ      0xFFFF
   PBUFFER      resb     CBUFFER
   
   STRBUFFER1   resb     0xFF
   STRBUFFER2   resb     0xFF
   
;//////////////////////////////////////////////////////////////////////////////////////////////////
;// [ CODE ]
;//////////////////////////////////////////////////////////////////////////////////////////////////

section .text

   global _start
   
;//////////////////////////////////////////////////////////////////////////////////////////////////
;// [ MAIN ]
;//////////////////////////////////////////////////////////////////////////////////////////////////

_start:      pop          rcx                           ; rcx - argc
              cmp         rcx,           2
              jl          ERROR
              ;add           rsp,             8         ; skip argv[0] - program name
              ;////////////////////////////////////////////////////////
             pop          rsi                           ; get argv[1] 
              xor         rax,           rax
FZERO:        cmp   byte [rsi + rax],    0x00           ; find 0x00 in argv[1]
              je          FZERO_RDY
              inc         rax
              jmp         FZERO
            
FZERO_RDY:    write       rsi,           rax            
              write       NEW_LINE,      1              
            
              ;////////////////////////////////////////////////////////
              
              call        DATE
              write       NEW_LINE,      1
              
              ;////////////////////////////////////////////////////////
            
             pop          rsi                           ; get argv[2]
            
              xor         rax,           rax
FZER1:        cmp   byte [rsi + rax],    0x00           ; find 0x00 in argv[2]
              je          FZER1_RDY
              inc         rax
              jmp         FZER1
            
FZER1_RDY:    ;/////////////////////////////////////////////////////////////////
              ; DIR(pFolder, cFolder) rsi = pFolder, rax = cFolder
              
              call        DIR                            
            
              write       STR_DIR,       LEN_DIR       
              write       SPACE,         1             

              mov         rax,      qword [DCounter]
              call        INT_2_STR
              write       SPACE,         1
              
              write       STR_FILE,      LEN_FILE        ; write to stdout
              write       SPACE,         1               ; write to stdout
              
              mov         rax,      qword [FCounter]
              call        INT_2_STR
              write       SPACE,         1

              mov         rax,      qword [DCounter]
              add         rax,      qword [FCounter]
              call        INT_2_STR
              write       NEW_LINE,      1
              
              ;/////////////////////////////////////////////////////////////////

              jmp         EXIT
            
;//////////////////////////////////////////////////////////////////////////////////////////////////
;// [ ERROR ]
;//////////////////////////////////////////////////////////////////////////////////////////////////

ERROR:        write       STR_ERROR,     LEN_ERROR

;//////////////////////////////////////////////////////////////////////////////////////////////////
;// [ EXIT ]
;//////////////////////////////////////////////////////////////////////////////////////////////////

EXIT:         mov         rax,           SYS_EXIT       ; exit syscall
              mov         rdi,           SUCCESS        ; exit code
              syscall                                   ; call exit syscall
            



