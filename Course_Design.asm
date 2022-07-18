data segment
    file       db "C:\Einword.txt",0
    handle     dw ?
    str0       db "WELCOME!$"
    str1       db "Simple English-English Dictionary$"
    str2       db "Options��1.input, 2.delete, 3.search, 4.modify, 5.exit$"
    str3       db "explain:$"
    str4       db "synonym:$"
    str5       db "antonym:$"
    str6       db "An error occurred, please re-enter!$"
    str7       db "thank you!$ "
    input_hint db "please enter:$"
    searchhint db  "you might be looking for:$"
    error      db "no such word$"
    next_w     db "Please enter any key:$"
    now        dw 0                                   ;���ڲ��ҵ�����ĸ��
    count      dw 0                                   ;���ڲ��ҵ��ĵ���
    cnt        dw 0                                   ;�����Ѿ�����ĵ�����
    maywnum    dw 0                                   ;�˱������ڴ洢searchw����һ���ռ�ָ��
    word1      db 20   dup(" ")                       ;����
    word2      db 40   dup(" ")                       ;����
    word3      db 20   dup(" ")                       ;ͬ���
    word4      db 20   dup(" ")                       ;�����
    word_add   db 100  dup(" ")                       ;һ�����ʵĺ�
    words      db 4000 dup(" ")                       ;�ܵĵ��ʣ���ÿ�����ʵ����ݶ�һ��100�д�С�Ŀռ�  
    searchw    db 100  dup(" ")                       ;���ҵĿ��ܲ��ҵ���
ends                  

stack segment
    dw   128  dup(0)
ends

code segment
start: 
    mov ax, data
    mov ds, ax
    mov es, ax
;--------------------------------------------------��----------------------------------------------------;
;��Ļ��
   scroll macro cont, ulrow, ulcol, lrrow, lrcol, att ;�������Ͼ�궨��
        mov ah, 6                                     ;�������Ͼ�
        mov al, cont                                  ;N=�Ͼ�������N=0����
        mov ch, ulrow                                 ;���Ͻ��к�
        mov cl, ulcol                                 ;���Ͻ��к�
        mov dh, lrrow                                 ;���½��к�
        mov dl, lrcol                                 ;���½��к�
        mov bh, att                                   ;����������
        int 10h
    endm
;�ù��λ��   
    curse macro y, x
        mov ah, 2                                     
        mov dh, y                                     ;�к�
        mov dl, x                                     ;�к�
        mov bh, 0                                     ;��ǰҳ
        int 10h
    endm 
;���word_add��
    clean macro 
        local loop1
        mov cx, 100
        mov word_add, 20h
        mov di, cx
        dec di
        loop1:
            mov word_add[di], 20h
            dec di
            loop loop1
    endm 
;����ת�ƺ�
    word_transfer macro addr1��addr2��place           ;place��ʾ�Ž�ȥ��λ��
        local for
        push si
        push di
        push cx
        mov ah, 0ah                               
        lea dx, addr1
        int 21h
        mov ch, 0
        mov cl, addr1[1]                              ;���ٸ���ĸ
        mov si, 2
        mov di, place
        for:
            push dx                                   ;ת�Ƶ�word_add
            mov dl, addr1[si]
            mov addr2[di], dl
            inc  si
            inc  di 
            pop  dx
            loop for 
        pop cx
        pop di
        pop si
     endm
;����words��
    words_insert macro loc, adr1, adr2
        local loop1,loop2                             ;loc��ʾ�ڼ�������
        push si
        push di
        push cx
        push dx
        push ax
        mov  cx, 0
        mov  ax, 0
        mov  dx, 0 
        mov  ax, cnt                                  
        sub  ax, loc 
        cmp  ax, 0 
        jz add1                                       ;��β��ֱ�Ӳ���
        mov  dl, 64h                                  ;��ȥ�����Ž�����������
        mov  cx, ax                                   ;��ʱax��ʾҪ�ƶ��ĵ�����
        inc  cx
        mov  di, ax
        dec  di  
        loop1:
            mov  dl, adr2[di]                         ;����ƹ���
            mov  adr2[di+100], dl
            dec  di
            loop loop1
        add1:                                         ;���뵽����ǰ��׼��
            mov  cx, 100 
            mov  si, 100
            mov  ax, loc 
            mov  bx, 100
            mul  bx
            add  si, ax
            mov  di, 100 
            inc  cx
            dec  di
            dec  si
        loop2:                                        ;����ѭ��
            mov  dl, adr1[di]
            mov  adr2[si], dl
            dec  di
            dec  si 
            loop loop2  
        pop  ax
        pop  dx
        pop  cx
        pop  di
        pop  si
    endm 
;�����
    word_input macro mark, place                             
        local loop1,loop2,loop3,loop4,exit     
        mov ax, mark    
        cmp ax, 1
            jz loop1                                  ;��־һΪ����     
        cmp ax, 2
            jz loop2                                  ;��־��Ϊ����     
        cmp ax, 3
            jz loop3                                  ;��־��Ϊͬ���       
        cmp ax, 4
            jz loop4                                  ;��־��Ϊ�����
        loop1:
            word_transfer word1,word_add,place        ;���뵥��
            jmp exit
        loop2:
            word_transfer word2,word_add,place        ;������� 
            jmp exit
        loop3:
            word_transfer word3,word_add,place        ;����ͬ���
            jmp exit
        loop4:
            word_transfer word4,word_add,place        ;���뷴���
            jmp exit                                                                                
        exit:                                                       
    endm
;ɾ����
    words_delete macro adr1,loc
        push si
        push di
        push cx
        push dx
        push ax
        mov  cx, 0
        mov  ax, 0
        mov  dx, 0  
        mov  ax, cnt                                  
        sub  ax, loc
        dec  ax
        mov  dx, 100                                  ;��ȥ�����Ž��������ǰ��
        mul  dx
        mov  cx, ax                                   ;��ʱax��ʾҪ�ƶ��ĵ�����
        mov  ax, loc
        mov  dx, 100
        mul  dx
        mov  di, ax  
        loop1:
            mov  dl, adr1[di+100]                     ;��ǰ�ƹ���
            mov  adr1[di], dl
            inc  di
            loop loop1 
        sub12:                                        ;���뵽ɾ��ǰ��׼��
            mov  cx, 100
            mov  ax, cnt 
            dec  ax
            mov  bx, 100
            mul  bx
            mov  di, ax 
        loop2:                                        ;���100��ɾ��ѭ��
            mov  adr1[di], 20h
            inc  di 
            loop loop2
        pop  ax
        pop  dx
        pop  cx
        pop  di
        pop  si
    endm
;���������,��words�У��ӵ�count����ʼ���100��
    words_search macro adr1,loc 
        local loop1,loop2,loop3
        push si
        push di
        push cx
        push dx
        push ax
        call print_show
        mov  ax, loc
        mov  dx, 100
        mul  dx
        mov  dx, 0
        mov  cx, 40
        mov  di, ax
        add  di, 20
        curse 12, 12 
        loop1:
            mov  dl, adr1[di]
            mov  ah,2
            int 21h
            inc di
            loop loop1
        curse 18, 12 
        mov  cx, 20
        loop2:
            mov  dl, adr1[di]
            mov  ah,2
            int 21h
            inc di
            loop loop2
        curse 18, 51 
        mov  cx, 20
        loop3:
            mov  dl, adr1[di]
            mov  ah,2
            int 21h
            inc di
            loop loop3
        pop  ax
        pop  dx
        pop  cx
        pop  di
        pop  si
    endm
;--------------------------------------------------������--------------------------------------------------;
;�����ļ��� 
    import:
        ;mov ah, 3ch                                   ;�½��ļ����Ѿ���C:\emu8086\emu8086\vdrive�ļ��д���
        ;mov cx, 0
        ;lea dx, file                         
        ;int 21h
        mov al, 0                                     ;�򿪷�ʽΪд
        mov ah, 3DH                                   ;���ļ�
        lea dx, file
        int 21h
        mov handle, ax                                ;�����ļ���
        mov ah, 3FH                                   ;��ȡ�ļ�
        mov bx, handle                                ;���ļ����Ŵ�����bx
        mov cx, 4000
        lea dx, words                                 ;���ݻ�������ַ 
        int 21h      
        mov bx, handle                                ;���ļ����Ŵ�����bx
        mov ah, 3EH                                   ;�ر��ļ�
        int 21h
;������Ļ����
    screen:                                           
        scroll 0,  0,  0,  24, 79,  05h               ;����
        scroll 25, 0,  0,  24, 79,  71h               ;���ⴰ�ڣ���ɫ��
        scroll 23, 1,  1,  3,  78,  21h               ;����
        scroll 23, 5,  1,  9,  78,  21h               ;�����
        scroll 23, 11, 1,  23��78,  21h               ;���ʲ㣬������ɫ 
;�ж϶�����
   words_num:
        mov  di, 0  
        mov  cx, 40
        loopf:
            mov  al, words[di]
            cmp  al, 20h
            jz init
            inc cnt
            add di, 100
            loop loopf 
;��ʾ����ӢӢ�ֵ�
    init:
        curse 2, 23
        mov ah, 09h                                   
        lea dx, str1
        int 21h
        curse 7, 4     
        mov ah, 09h                                   ;��ʾѡ����Ϣ
        lea dx, str2
        int 21h
        scroll 23, 11, 1,  23��78,  21h               ;���ʲ㣬������ɫ 
        curse 15, 35
        mov ah, 09h                                   ;��ʾע��
        lea dx, str0
        int 21h 
;��ʼ   
     begin:
        curse 7,  60
        mov ah, 0                                     ;����ѡ��
        int 16h                                           
        mov ah, 0eh                                   ;��ʾ������ַ�
        int 10h
        cmp al, 49                                    ;ѡһ����
        jz input
        cmp al, 50                                    ;ѡ��ɾ��
        jz delete
        cmp al, 51                                    ;ѡ������
        jz search                                     
        cmp al, 52                                    ;ѡ���޸�
        jz modify                                     
        cmp al, 53                                    ;ѡ���˳�
        jz exit
        scroll 23, 5, 1, 9, 78, 21h                   ;���
        curse 7, 4  
        mov ah, 09h
        lea dx, str6                                  ;ѡ��������
        int 21h
        mov ah, 0
        int 16h                                         
        curse 7, 4                                    ;��������
        mov ah, 09h                                  
        lea dx, str2
        int 21h
        jmp begin
;���뺯��
     input:                                           
        call clear
        call print_show
        curse 7, 20
        word_input 1, 0
        curse 12, 12
        word_input 2, 20
        curse 18, 12
        word_input 3, 60
        curse 18, 51
        word_input 4, 80                              ;�����ж���������
        call word_insert
        mov ax, cnt
        add ax, 1                                     ;��cnt��һ����������
        mov cnt, ax
        mov now,  0
        mov count,0
        clean
        jmp init
;ɾ������         
     delete:                                          
        call clear
        call print_show
        curse 7, 20
        mov ah, 0ah                               
        lea dx, word1
        int 21h
        call word_delete
        delete_op:
        mov ax, cnt                                    ;��cnt��һ����������
        sub ax, 1
        mov cnt, ax
        mov now,  0
        mov count,0
        clean 
        jmp init
;���Һ���        
     search:                                          
        call clear
        call print_show
        curse 7, 20
        mov ah, 0ah                               
        lea dx, word1
        int 21h
        call word_search
        search_op:
        mov now,  0
        mov count,0
        clean
        jmp init                                     ;���������cnt���ñ�
;�޸ĺ���        
     modify:                                          
        call clear
        call print_show 
        curse 7, 20
        mov ah, 0ah                               
        lea dx, word1
        int 21h
        call word_modify 
        modify_op:
        mov now,  0
        mov count,0
        clean 
        jmp init
;��������        
     exit:
        mov bx, handle
        mov al, 1                                     ;�򿪷�ʽΪд
        mov ah, 3DH                                   ;���ļ�
        lea dx, file
        int 21h
        mov bx, handle
        mov cx, 4000
        mov ah, 40h                  
        lea dx, words
        int 21h
        mov bx, handle                                ;���ļ����Ŵ�����bx
        mov ah, 3EH                                   ;�ر��ļ�
        int 21h
        scroll 23, 11, 1,  23��78,  21h               ;���ʲ㣬������ɫ 
        curse 15, 35
        mov ah, 09h                                   ;��ʾע��
        lea dx, str7
        int 21h                                           
        mov ax, 4c00h                                 
        int 21h
;--------------------------------------------------�ӳ���--------------------------------------------------;
;���뺯��
    word_insert proc
        push si
        push di
        push cx
        push dx
        push ax
        find1:                                         ;�ҵ���ѵ�λ��
            cmp  cnt, 0
            jz insert1
            mov di, now
            mov si, 0 
            mov al, word_add[si] 
            mov dl, words[di]
            cmp al, dl
            jz  next_letter
            jnge insert1
            ja next_word
        insert1:                                       ;�жϿ��Բ���
            words_insert  count, word_add, words
            jmp exit1
        next_letter:                                   ;�жϿ��Խ�����һ����ĸ
            inc now
            call word_insert
        next_word:                                     ;�жϿ��Խ�����һ������
            mov ax, cnt
            mov bx, count                              ;���¸���Ϊ�գ��Ͳ���
            cmp ax, bx 
            jz insert1                                     
            inc count
            mov ax, count
            mov bx, 100
            mul bx
            mov now, ax
            call word_insert
        exit1:           
        pop  ax
        pop  dx
        pop  cx
        pop  di
        pop  si
        ret
    word_insert endp
;ɾ������
    word_delete proc
        push si
        push di
        push cx
        push dx
        push ax
        mov cl, word1[1]                               ;�鿴�ж��ٸ���ĸ
        mov ch, 0
        mov di, now 
        mov si, 2
        find2:                                         ;�ж���Ⱦͼ������������һ��
            mov al, word1[si] 
            mov dl, words[di]
            cmp al, dl
            jne add2
            inc si
            inc di    
            loop find2
        next2:                                         ;���������������Ѿ�������ˣ���һ����    
            jmp  out2                                  ;��Ⱦͽ������                                     
        add2:                                          ;������һ����ĸ����һ��
            inc count                                  ;���뵽�¸�����
            mov ax, count 
            mov bx, cnt
            cmp ax, bx
            ja word_delete_error                       ;�������˾ͽ���
            mov bx, 100
            mul bx
            mov now, ax
            call  word_delete
        word_delete_error:
            curse 7, 4  
            mov ah, 09h
            lea dx, error                              ;�Ҳ����������
            int 21h
            jmp exit2 
        out2:
            words_delete words,count
        exit2:
            call next_op
            jmp delete_op        
        pop  ax
        pop  dx
        pop  cx
        pop  di
        pop  si
        ret
    word_delete endp
;���Һ���
    word_search proc
        push si
        push di
        push cx
        push dx
        push ax 
        mov cl, word1[1]                               ;�鿴�ж��ٸ���ĸ
        mov ch, 0
        mov di, now 
        mov si, 2
        find3:                                         ;�ж���Ⱦͼ������������һ��
            mov al, word1[si] 
            mov dl, words[di]
            cmp al, dl
            jne add3
            inc si
            inc di    
            loop find3
        next3:                                         ;���������������Ѿ�������ˣ���һ����
            jmp else3                                  ;��Ⱦͽ�������鿴��һ�����ʣ�������һ����ĸ�ͱ�ʾ�¸��п��Դ�ӡ����  
        add3:                                          
            inc count                                  ;���뵽�¸�����
            mov ax, count 
            mov bx, cnt
            cmp ax, bx
            ja word_search_error
            mov bx, 100
            mul bx
            mov now, ax
            call word_search
        word_search_error:
            mov cx, maywnum
            cmp cx, 0
            jz  out_e
            scroll 23, 5, 1, 6, 78, 21h                ;�������ʾ������ɫ
            scroll 23, 7, 1, 9, 78, 21h                ;�����
            curse 7, 4                                 
            mov ah, 09h
            lea dx, searchhint        
            int 21h 
            scroll 23, 11, 1,  23��78,  21h            ;���ʲ㣬������ɫ
            curse 12, 4
            mov di, 0
            out__an:
                mov dl, searchw[di]
                cmp dl, 20h
                jz exit3
                mov ah, 02h
                int 21h 
                inc di
                loop out__an 
            out_e:
                curse 7, 4  
                mov ah, 09h
                lea dx, error                          ;�Ҳ����������
                int 21h
                jmp exit3 
        out3:                                          ;���
            words_search words, count
            jmp exit3
        else3:
            mov al, words[di]                          ;���
            cmp al, 20h
            jz out3 
            mov di, now 
            mov cx, 20                                 ;��cxΪ10��,������������ȥ
            out__3:
                mov dl, words[di]
                cmp dl, 20h
                jz next_search
                mov si, maywnum
                mov searchw[si],  dl    
                inc si
                mov maywnum,si
                inc di
                loop out__3
        next_search:
            mov searchw[si], 44
            jmp add3
        exit3:
            call next_op
            jmp search_op                                          
        pop  ax
        pop  dx
        pop  cx
        pop  di
        pop  si
        ret
    word_search endp
;�޸ĺ���
    word_modify proc
        push si
        push di
        push cx
        push dx
        push ax 
        mov cl, word1[1]+1                             ;�鿴�ж��ٸ���ĸ
        mov ch, 0
        mov di, now 
        mov si, 2
        find4:                                         ;�ж���Ⱦͼ������������һ��
            mov al, word1[si] 
            mov dl, words[di]
            cmp al, dl
            jne next4
            inc si
            inc di    
            loop find4
        next4:                                         ;���������жϵ������ǲ���һ����
            mov dl, words[di]
            cmp dl, 20h
            jz  out4                                   ;��Ⱦͽ������      
        add4:                                          ;������һ����ĸ���¸�����
            inc count                                  ;���뵽�¸�����
            mov ax, count 
            mov bx, cnt
            cmp ax, bx
            ja word_modify_error
            mov bx, 100
            mul bx
            mov now, ax
            call word_modify
        word_modify_error:
            curse 7, 4  
            mov ah, 09h
            lea dx, error                              ;�Ҳ����������
            int 21h
            jmp exit4 
        out4:                                          ;
            curse 12, 12
            word_input 2, 20
            curse 18, 12
            word_input 3, 60
            curse 18, 51
            word_input 4, 80
            add now, 20
            mov cx,  80
            mov di, now
            mov si, 20
            in4:
                mov dl, word_add[si]
                mov words[di], dl
                inc di
                inc si
                loop in4         
        exit4:
            call next_op
            jmp modify_op
        pop  ax
        pop  dx
        pop  cx
        pop  di
        pop  si
        ret
    word_modify endp
;ͼ���ӡ
    print_show proc
        scroll 23, 11, 1,  23��78,  21h               ;���ʲ㣬������ɫ
        curse 12, 4
        mov ah, 09h                                   ;��ʾע��
        lea dx, str3
        int 21h
        curse 18, 4
        mov ah, 09h                                   ;��ʾͬ���
        lea dx, str4
        int 21h
        curse 18, 43
        mov ah, 09h                                   ;��ʾ�����
        lea dx, str5
        int 21h
        ret
    print_show endp
;��ʾ����
    clear proc                                        ;�����������
        push ax
        push bx
        push cx
        push dx
        scroll 23, 5, 1, 6, 78, 21h                   ;�������ʾ������ɫ
        scroll 23, 7, 1, 9, 78, 21h                   ;�����
        curse 7, 4                                 
        mov ah, 09h
        lea dx, input_hint        
        int 21h
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    clear endp
;��ʾ���    
    next_op proc                                        ;�����������
        push ax
        push bx
        push cx
        push dx
        scroll 23, 5, 1, 6, 78, 21h                   ;�������ʾ������ɫ
        scroll 23, 7, 1, 9, 78, 21h                   ;�����
        curse 7, 4                                 
        mov ah, 09h
        lea dx, next_w        
        int 21h
        curse 7, 30
        mov ah,1
        int 21h
        pop dx
        pop cx
        pop bx
        pop ax
        ret
    next_op endp                    
ends 

end start ; 