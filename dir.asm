;//////////////////////////////////////////////////////////////////////////////////////////////////
;// [ DIR ]  ; DIR(pFolder, cFolder) rsi = pFolder, rax = cFolder
;//////////////////////////////////////////////////////////////////////////////////////////////////
DIR:          push         rbp                             ; create the stack frame 
              mov          rbp,             rsp    

              ;/////////////////////////////////////////////////////////////////
                                                           ; create the stack Space
              sub          rsp,             cDIR64         ; Buffer fo SYS_DIR64        
              sub          rsp,             cSTRING        ; 4252 ; LINUX X86-64 PATH_MAX 4096  ; save Input String
              sub          rsp,             cSTACKVq       ; Size for local qword variables
              
              ;/////////////////////////////////////////////////////////////////
              
              mov   qword [rsp + cInput],   rax            ; cInput
              mov   qword [rsp + pInput],   rsi            ; pInput
            
              mov   qword [rsp + pFile],    0x00           ; pFile
            
              mov   qword [rsp + cBuffer],  0x00           ; cBuffer (getdents64)
            
              mov   qword [rsp + cFName],   0x00           ; cFName
              mov   qword [rsp + pFName],   0x00           ; pFName

              ;/////////////////////////////////////////////////////////////////
              ; copy pInput -> Stack(rsp + pSTRING)
              ;/////////////////////////////////////////////////////////////////
              
              mov          r8,       qword [rsp + cInput]  ; cInput 
              xor          r9,              r9
              mov          rcx,             rsp
              add          rcx,             pSTRING        ; rcx = (rsp + pSTRING)
              
DIR11:        xor          rdx,             rdx
              mov          dl,        byte [rsi + r9]      ; rsi = pInput 
              mov    byte [rcx + r9],       dl              
              inc          r9
              dec          r8
              cmp          r8,              0x00
              jne          DIR11
            
              ;/////////////////////////////////////////////////////////////////
              ; add slash ( /home -> /home/
              ;/////////////////////////////////////////////////////////////////
              
              mov          rax,      qword [rsp + cInput]
              mov          rsi,             rsp
              add          rsi,             pSTRING
            
              cmp    byte [rsi + rax - 1],  0x2F
              je           NOSLASH1
            
              mov    byte [rsi + rax],      0x2F
            
              mov          rax,      qword [rsp + cInput]
              inc          rax
              mov   qword [rsp + cInput],   rax

NOSLASH1:     mov    byte [rsi + rax],      0x00

              ;/////////////////////////////////////////////////////////////////
              ; print FolderName to stdout
              ;/////////////////////////////////////////////////////////////////
              
              write        STR_OPEN,        LEN_OPEN
              write        SPACE,           1
            
              write        rsi,             rax
              write        NEW_LINE,        1
            
              ;/////////////////////////////////////////////////////////////////
              ; open Folder
              ;/////////////////////////////////////////////////////////////////
              
              mov          rdi,             rsi          ; filename
              mov          rsi,             SYS_READ     ; read mode
              mov          rdx,             0            ; 
              mov          rax,             SYS_OPEN     ; open syscall
              syscall   

              cmp          rax,             0            ; check if fd in eax > 0 (ok) 
              jl           DIR_ERR                       ; cannot open file.  Exit with error status 
 
              mov   qword [rsp + pFile],    rax          ; save file handle

              ;/////////////////////////////////////////////////////////////////
              ; read getdents64
              ;/////////////////////////////////////////////////////////////////
              
              mov          rdi,      qword [rsp + pFile] ; file handle  
              mov          rsi,             rsp
              add          rsi,             pDIR64       ; pBuffer  getdents64
              mov          rdx,             cDIR64       ; cBuffer
              mov          rax,             SYS_DIR64    ; getdents64 syscall
              syscall
 
              cmp          rax,             1            ; check if fd in eax > 0 (ok) 
              jl           DIR_ERR                       ; cannot read folder.  Exit with error status 
            
              mov   qword [rsp + cBuffer],  rax          ; save read bytes
            
              ;/////////////////////////////////////////////////////////////////
              ; LOOP 
              ;/////////////////////////////////////////////////////////////////
              
              
              mov          r14,             rsp
              add          r14,             pDIR64           ; r14 = rsp + pDIR64
              xor          r15,             r15
DIR1_LOOP:    xor          rax,             rax
              mov          ax,        word [r14 + r15 + 16]  ; Size of this dirent
              sub          ax,              19               ; Sub Size of Struct without FileName
              
              mov          rdx,             r15              ; Add Offset
              add          rdx,             19               ; Add Size of Struct without FileName
              add          rdx,             r14

              ;/////////////////////////////////////////////////////////////////
              ; find string_terminator 0x00
              ;/////////////////////////////////////////////////////////////////
              
              xor          rcx,             rcx
              mov          rcx,             r15
TZERO:        cmp    byte [r14 + 19 + rcx], 0x00
              je           TZERO1
              inc          rcx
              jmp          TZERO
TZERO1:       sub          rcx,             r15 

              mov   qword [rsp + cFName],   rcx             ; save cFilename
              mov   qword [rsp + pFName],   rdx             ; save pFilename
            
              ;///////////////////////////////////////////// 
              ; CHECK TYPE
              ;///////////////////////////////////////////// 
            
              cmp    byte [r14 + r15 + 18], FOLDER   
              jne          NOFOLDER1
            
              ;///////////////////////////////////////////// 
              ; FOLDER
              ;///////////////////////////////////////////// 
            
              cmp    byte [r14 + r15 + 19], DOT  ; Jump if No DOT  string = "test", 0
              jne          DOTRDY

              cmp    byte [r14 + r15 + 20], DOT  ; Jump if DOT     string = "..", 0
              je     NEXT
              
              cmp    byte [r14 + r15 + 20], 0x00 ; Jump if ZERO    string = ".", 0
              je     NEXT
              
DOTRDY:
              ;/////////////////////////////////////////////////////////////////
              ; copy pFName -> Stack(rsp + pSTRING + cInput) 
              ;/////////////////////////////////////////////////////////////////
              
              mov          rax,      qword [rsp + cInput]     ; cInput
              mov          r13,             rsp
              add          r13,             pSTRING           ; pLocalString
              add          r13,             rax               ; pLocalString[cInput]
            
              xor          r8,              r8
              xor          rbx,             rbx
              mov          rdx,      qword [rsp + pFName]
            
COPYFNAME1:   mov          bl,        byte [rdx + r8]
              mov    byte [r13 + r8],       bl
              inc          r8
              cmp          r8,       qword [rsp + cFName]
              jne          COPYFNAME1
            
              ;/////////////////////////////////////////////

              inc   qword [Counter]
              
              ;/////////////////////////////////////////////
            
              mov          rsi,             rsp                ; pFilename
              add          rsi,             pSTRING
            
              mov          rax,      qword [rsp + cInput]      ; cInputString
              add          rax,      qword [rsp + cFName]      ; cFilename

             push          r9
             push          r8
             push          r13
             push          r14
             push          r15
           
              call         DIR ; Rekursion ///////////////////
            
             pop           r15
             pop           r14
             pop           r13
             pop           r8 
             pop           r9
           
              jmp          NEXT
            

            
NOFOLDER1:    cmp    byte [r14 + r15 + 18], FILE            ; File    
              jne          NOFILE1
            
              ;///////////////////////////////////////////// 
              ; FILE
              ;/////////////////////////////////////////////
              
              jmp          NEXT
            
NOFILE1:    
              ;/////////////////////////////////////////////////////////////////
              
NEXT:         xor          rax,             rax
              mov          ax,        word [r14 + r15 + 16]  ; Size of this dirent
            
              add          r15,             rax   
              sub   qword [rsp + cBuffer],  rax

              cmp   qword [rsp + cBuffer],  0x00             ; check factor with 0
              jne          DIR1_LOOP                         ; loop again
            
              ;/////////////////////////////////////////////////////////////////
              ; LOOP END 
              ;/////////////////////////////////////////////////////////////////
              
              mov          rdi,      qword [rsp + pFile]     ; file handle
              mov          rax,             SYS_CLOSE        ; close syscall
              syscall

              jmp          DIR_READY
            
              ;/////////////////////////////////////////////////////////////////

DIR_ERR:      write        STR_ERROR,       LEN_ERROR           

              ;/////////////////////////////////////////////////////////////////
             
DIR_READY:    mov          rsp,             rbp              ; destroy the stack frame
              pop          rbp
              ret
