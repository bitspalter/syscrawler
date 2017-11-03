;//////////////////////////////////////////////////////////////////////////////////////////////////
;// [ INT_2_STR ]
;//////////////////////////////////////////////////////////////////////////////////////////////////
INT_2_STR:    push        rbp                         ; create the stack frame
              mov         rbp,        rsp 
            
             push         r12

             push         rax
             push         rbx
             push         rdx
             push         rsi
             push         rdi

              ;/////////////////////////////////////////////////////////////////
              xor         r12,             r12
              ;//////////////////////////////////////////////////////////////
INT_2_LOOP:   mov         rdx,             0x00         ; reminder from division
              mov         rbx,             0x0A         ; base
              div         rbx                           ; rax = rax / 10
              add         rdx,             0x30         ; add 48
             push         rdx
              inc         r12                           ; go next
              cmp         rax,             0x00         ; check factor with 0
              jne         INT_2_LOOP                    ; loop again
              ;//////////////////////////////////////////////////////////////
              mov         rax,             1
              mul         r12
              mov         r12,             8
              mul         r12
              ;//////////////////////////////////////////////////////////////
              mov         rdi,             STDOUT      
              mov         rsi,             rsp          ; pString
              mov         rdx,             rax          ; cString
              mov         rax,             SYS_WRITE    
              syscall 
              ;/////////////////////////////////////////////////////////////////

             pop          rdi
             pop          rsi
             pop          rdx 
             pop          rbx
             pop          rax
             
             pop          r12
            
              mov         rsp,             rbp          ; destroy the stack frame
              pop         rbp
            
              ret
