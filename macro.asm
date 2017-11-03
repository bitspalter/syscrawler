;//////////////////////////////////////////////////////////////////////////////////////////////////
;// [ MACRO ] 
;//////////////////////////////////////////////////////////////////////////////////////////////////

   %macro write 2 
      push     rdi
      push     rsi
      push     rdx
      push     rax
      mov      rdi,        STDOUT      
      mov      rsi,        %1           ; pString
      mov      rdx,        %2           ; cString
      mov      rax,        SYS_WRITE    
      syscall 
      pop      rax
      pop      rdx
      pop      rsi
      pop      rdi
   %endmacro
