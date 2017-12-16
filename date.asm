;//////////////////////////////////////////////////////////////////////////////////////////////////
;// [ DATE ]
;//////////////////////////////////////////////////////////////////////////////////////////////////
DATE:       push           rbp                                ; create the stack frame 
              mov          rbp,             rsp    
              
              sub          rsp,             cDATEq            ; size for local variable
              
              ;/////////////////////////////////////////////////////////////////
              
              mov          rax,             SYS_TIME
              xor          rdi,             rdi        
              syscall
              
              mov   qword [rbp - pTIMESTAMP], rax

              xor          rdx,             rdx
              mov          rbx,             60
              div          rbx
              
              mov   qword [rbp - pSECOND],  rdx
              
              xor          rdx,             rdx
              mov          rbx,             60
              div          rbx
              
              mov   qword [rbp - pMINUTE],  rdx
              
              xor          rdx,             rdx
              mov          rbx,             24
              div          rbx
              
              inc          rdx
              mov   qword [rbp - pHOUR],    rdx

              ;//////////////////////////////////////////////////

              mov          rax,      qword [rbp - pTIMESTAMP]  
              sub          rax,             LEAPOCH
              
              mov   qword [rbp - pTEMPSEC], rax

              xor          rdx,             rdx
              mov          rbx,             86400
              div          rbx
              
              mov   qword [rbp - pTEMPDAY], rax
              mov   qword [rbp - pREMSEC],  rdx

              cmp   qword [rbp - pREMSEC],  0x00
              jg           DATE2

              add   qword [rbp - pREMSEC],  86400
              dec   qword [rbp - pTEMPDAY]

              ;///////////////////////////////////////////////
              
DATE2:        mov          rax,      qword [rbp - pTEMPDAY]
              add          rax,             0x03

              xor          rdx,             rdx
              mov          rbx,             0x07
              div          rbx

              mov   qword [rbp - pWEEKDAY], rdx

              cmp          rdx,             0x00
              jg           DATE3
              
              add   qword [rbp - pWEEKDAY], 0x07

              ;///////////////////////////////////////////////
              
DATE3:        mov          rax,      qword [rbp - pTEMPDAY]
              
              xor          rdx,             rdx
              mov          rbx,             DAYS_PER_400Y
              div          rbx
              
              mov   qword [rbp - pCYCLES_QC], rax
              mov   qword [rbp - pREMDAY],    rdx

              cmp          rdx,             0x00
              jg           DATE4
              
              add   qword [rbp - pREMDAY],  DAYS_PER_400Y
              dec   qword [rbp - pCYCLES_QC]
              
              ;///////////////////////////////////////////////
              
DATE4:        xor          rdx,             rdx
              mov          rax,      qword [rbp - pREMDAY]
              mov          rbx,             DAYS_PER_100Y
              div          rbx
              
              mov   qword [rbp - pCYCLES_C], rax

              cmp          rax,             0x04
              jne          DATE5
              
              dec   qword [rbp - pCYCLES_C]

DATE5:        mov          rdx,             DAYS_PER_100Y
              mul          rdx
              
              sub   qword [rbp - pREMDAY],  rax

              ;///////////////////////////////////////////////

              xor          rdx,             rdx
              mov          rax,      qword [rbp - pREMDAY]
              mov          rbx,             DAYS_PER_4Y
              div          rbx
              
              mov   qword [rbp - pCYCLES_Q], rax
              
              cmp          rax,             0x19
              jne          DATE6
              
              dec   qword [rbp - pCYCLES_Q]
              
DATE6:        mov          rdx,             DAYS_PER_4Y
              mul          rdx
              
              sub   qword [rbp - pREMDAY],  rax

              ;///////////////////////////////////////////////

              xor          rdx,             rdx
              mov          rax,      qword [rbp - pREMDAY]
              mov          rbx,             365
              div          rbx
              
              mov   qword [rbp - pREMYEAR], rax

              cmp          rax,             0x04
              jne          DATE7
              
              dec   qword [rbp - pREMYEAR]
              
DATE7:        mov          rdx,             365
              mul          rdx

              sub   qword [rbp - pREMDAY],  rax

              ;///////////////////////////////////////////////
              
              xor          r8,              r8
              
              mov          rax,      qword [rbp - pCYCLES_QC]
              mov          rdx,             400
              mul          rdx
              add          r8,              rax

              mov          rax,      qword [rbp - pCYCLES_C]
              mov          rdx,             100
              mul          rdx
              add          r8,              rax

              mov          rax,      qword [rbp - pCYCLES_Q]
              mov          rdx,             4
              mul          rdx
              add          r8,              rax

              add          r8,       qword [rbp - pREMYEAR]
              add          r8,              2000
              
              mov   qword [rbp - pYEAR],    r8

              ;///////////////////////////////////////////////
              
              xor          rbx,             rbx
              mov          rcx,      qword [rbp - pREMDAY]
              mov          rdx,             DAYS_PER_MONTH
              
DATE_LOOP:    xor          rax,             rax
              mov           al,       byte [rdx + rbx]
              cmp          rcx,             rax
              jl           DATE_RDY
              
              sub          rcx,             rax
              inc          rbx
              jmp          DATE_LOOP
              
DATE_RDY:     mov          rax,             rcx
              inc          rax
              
              mov   qword [rbp - pDAY],     rax

              mov          rax,             rbx
              add          rax,             0x03
              
              mov   qword [rbp - pMONTH],   rax

              ;///////////////////////////////////////////////
              
              write        NEW_LINE,        1
              mov          rax,      qword [rbp - pDAY]
              call         INT_2_STR
              write        POINT,           1
              mov          rax,      qword [rbp - pMONTH]
              call         INT_2_STR
              write        POINT,           1
              mov          rax,      qword [rbp - pYEAR]
              call         INT_2_STR
              write        SPACE,           1
              write        SPACE,           1
              
              mov          rax,      qword [rbp - pHOUR]
              call         INT_2_STR
              write        COLON,           1
              mov          rax,      qword [rbp - pMINUTE]
              call         INT_2_STR
              write        COLON,           1
              mov          rax,      qword [rbp - pSECOND]
              call         INT_2_STR
              write        NEW_LINE,        1

              ;/////////////////////////////////////////////////////////////////
              
              mov          rsp,             rbp              ; destroy the stack frame
            pop            rbp
              ret
