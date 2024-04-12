%include "src/game.inc"
%include "lib/mem.inc"
%include "lib/numeric.inc"
%include "lib/debug/print.inc"

extern memset, memcpy, rand, srand, time



section .data align 4
    Game_N_I_SKIPS dd 0

section .rodata align 4
    float_fmt db "%f", 10, 0

section .text


; #[stdcall]
; fn GameField::new() -> Self
GameField_new:
    push ebp
    push edi
    mov ebp, esp

    .argbase            equ 12
    .return             equ .argbase+0

    .args_size          equ .return-.argbase+4

    ; return := edi
    mov edi, dword [ebp+.return]

    DEBUGLN `GameField::new()`

    ; return.cells = mem::zeroed()
    MEM_SET edi+GameField.cells, 0, GameField_WIDTH * GameField_HEIGHT * Cell.sizeof

    pop edi
    pop ebp
    ret .args_size


; #[stdcall]
; fn GameField::draw(&self, image: &mut ScreenImage)
GameField_draw:
    push ebp
    push esi
    push edi
    mov ebp, esp

    .cur_color          equ -12
    .left_offset        equ -8
    .bottom_offset      equ -4

    .argbase            equ 16
    .self               equ .argbase+0
    .image              equ .argbase+4

    .args_size          equ .image-.argbase+4
    .stack_size         equ -.cur_color

    sub esp, .stack_size

    ; self := esi
    mov esi, dword [ebp+.self]

    ; image := edi
    mov edi, dword [ebp+.image]

    ; left_offset = (image.width - FIELD_WIDTH_PIXELS) / 2
    mov eax, dword [edi+ScreenImage.width]
    sub eax, FIELD_WIDTH_PIXELS
    shr eax, 1
    mov dword [ebp+.left_offset], eax

    ; bottom_offset = (image.height - FIELD_HEIGHT_PIXELS) / 2
    mov eax, dword [edi+ScreenImage.height]
    sub eax, FIELD_HEIGHT_PIXELS
    shr eax, 1
    mov dword [ebp+.bottom_offset], eax

    ; image.fill_rect(left_offset, bottom_offset,
    ;                 FIELD_WIDTH_PIXELS, FIELD_HEIGHT_PIXELS,
    ;                 Game::BACKGROUND_COLOR)
    push Game_BACKGROUND_COLOR
    push FIELD_HEIGHT_PIXELS
    push FIELD_WIDTH_PIXELS
    push dword [ebp+.bottom_offset]
    push dword [ebp+.left_offset]
    push edi
    call ScreenImage_fill_rect

    %assign row 0
    %rep GameField_HEIGHT
        %assign col 0
        %rep GameField_WIDTH

            ; Self::draw_cell(image, row, col, self.cells[row * GameField_WIDTH + col].type)
            mov al, byte [esi+GameField.cells+4*(row*GameField_WIDTH+col)+Cell.type]
            movzx eax, al
            push eax
            push col
            push row
            push edi
            call GameField_draw_cell

        %assign col col+1
        %endrep
    %assign row row+1
    %endrep

    add esp, .stack_size

    pop edi
    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; fn GameField::draw_cell(image: &mut ScreenImage, row: u32, col: u32, type: CellType)
GameField_draw_cell:
    push ebp
    push edi
    mov ebp, esp

    .cur_color          equ -12
    .left               equ -8
    .bottom             equ -4

    .argbase            equ 12
    .image              equ .argbase+0
    .row                equ .argbase+4
    .col                equ .argbase+8
    .type               equ .argbase+12

    .args_size          equ .type-.argbase+4
    .stack_size         equ -.cur_color

    sub esp, .stack_size

    ; image := edi
    mov edi, dword [ebp+.image]

    ; if row >= GameField_HEIGHT { return }
    cmp dword [ebp+.row], GameField_HEIGHT
    jnb .exit

    ; if col >= GameField_WIDTH { return }
    cmp dword [ebp+.col], GameField_WIDTH
    jnb .exit

    ; cur_color = Game::CELL_COLORS[type]
    mov eax, dword [ebp+.type]
    mov eax, dword [Game_CELL_COLORS+4*eax]
    mov dword [ebp+.cur_color], eax

    ; left = (image.width - FIELD_WIDTH_PIXELS) / 2 
    ;      + col * CELL_SIZE_PIXELS + CELL_PADDING_PIXELS
    mov eax, dword [edi+ScreenImage.width]
    sub eax, FIELD_WIDTH_PIXELS
    shr eax, 1
    mov dword [ebp+.left], eax
    mov edx, CELL_SIZE_PIXELS
    mov eax, dword [ebp+.col]
    mul edx
    add eax, CELL_PADDING_PIXELS
    add dword [ebp+.left], eax

    ; bottom = (image.height - FIELD_HEIGHT_PIXELS) / 2 
    ;      + row * CELL_SIZE_PIXELS + CELL_PADDING_PIXELS
    mov eax, dword [edi+ScreenImage.height]
    sub eax, FIELD_HEIGHT_PIXELS
    shr eax, 1
    mov dword [ebp+.bottom], eax
    mov edx, CELL_SIZE_PIXELS
    mov eax, dword [ebp+.row]
    mul edx
    add eax, CELL_PADDING_PIXELS
    add dword [ebp+.bottom], eax

    ; image.fill_rect(left, 
    ;                 bottom,
    ;                 CELL_SIZE_PIXELS - 2 * CELL_PADDING_PIXELS,
    ;                 CELL_SIZE_PIXELS - 2 * CELL_PADDING_PIXELS,
    ;                 cur_color)
    push dword [ebp+.cur_color]
    push CELL_SIZE_PIXELS - 2 * CELL_PADDING_PIXELS
    push CELL_SIZE_PIXELS - 2 * CELL_PADDING_PIXELS
    push dword [ebp+.bottom]
    push dword [ebp+.left]
    push edi
    call ScreenImage_fill_rect

.exit:
    add esp, .stack_size

    pop edi
    pop ebp
    ret .args_size


; #[stdcall]
; fn GameField::draw_empty_cell(image: &mut ScreenImage, row: u32, col: u32, thickness: u32, type: CellType)
GameField_draw_empty_cell:
    push ebp
    push edi
    mov ebp, esp

    .cur_color          equ -12
    .left               equ -8
    .bottom             equ -4

    .argbase            equ 12
    .image              equ .argbase+0
    .row                equ .argbase+4
    .col                equ .argbase+8
    .thickness          equ .argbase+12
    .type               equ .argbase+16

    .args_size          equ .type-.argbase+4
    .stack_size         equ -.cur_color

    sub esp, .stack_size

    ; image := edi
    mov edi, dword [ebp+.image]

    ; if row >= GameField_HEIGHT { return }
    cmp dword [ebp+.row], GameField_HEIGHT
    jnb .exit

    ; if col >= GameField_WIDTH { return }
    cmp dword [ebp+.col], GameField_WIDTH
    jnb .exit

    ; cur_color = Game::CELL_COLORS[type]
    mov eax, dword [ebp+.type]
    mov eax, dword [Game_CELL_COLORS+4*eax]
    mov dword [ebp+.cur_color], eax

    ; left = (image.width - FIELD_WIDTH_PIXELS) / 2 
    ;      + col * CELL_SIZE_PIXELS + CELL_PADDING_PIXELS
    mov eax, dword [edi+ScreenImage.width]
    sub eax, FIELD_WIDTH_PIXELS
    shr eax, 1
    mov dword [ebp+.left], eax
    mov edx, CELL_SIZE_PIXELS
    mov eax, dword [ebp+.col]
    mul edx
    add eax, CELL_PADDING_PIXELS
    add dword [ebp+.left], eax

    ; bottom = (image.height - FIELD_HEIGHT_PIXELS) / 2 
    ;      + row * CELL_SIZE_PIXELS + CELL_PADDING_PIXELS
    mov eax, dword [edi+ScreenImage.height]
    sub eax, FIELD_HEIGHT_PIXELS
    shr eax, 1
    mov dword [ebp+.bottom], eax
    mov edx, CELL_SIZE_PIXELS
    mov eax, dword [ebp+.row]
    mul edx
    add eax, CELL_PADDING_PIXELS
    add dword [ebp+.bottom], eax

    ; image.fill_box(left, 
    ;                 bottom,
    ;                 CELL_SIZE_PIXELS - 2 * CELL_PADDING_PIXELS,
    ;                 CELL_SIZE_PIXELS - 2 * CELL_PADDING_PIXELS,
    ;                 thickness,
    ;                 cur_color)
    push dword [ebp+.cur_color]
    push dword [ebp+.thickness]
    push CELL_SIZE_PIXELS - 2 * CELL_PADDING_PIXELS
    push CELL_SIZE_PIXELS - 2 * CELL_PADDING_PIXELS
    push dword [ebp+.bottom]
    push dword [ebp+.left]
    push edi
    call ScreenImage_fill_box

.exit:
    add esp, .stack_size

    pop edi
    pop ebp
    ret .args_size



; [stdcall]
; fn Game::new() -> Self
Game_new:
    push ebp
    push edi
    mov ebp, esp

    .prev_esp           equ -4

    .argbase            equ 12
    .return             equ .argbase+0

    .args_size          equ .return-.argbase+4
    .stack_size         equ -.prev_esp

    sub esp, .stack_size

    ; return := edi
    mov edi, dword [ebp+.return]

    DEBUGLN `Game::new()`

    ; return.field = GameField::new()
    lea eax, dword [edi+Game.field]
    push eax
    call GameField_new

    ; return.cur_figure_type = Game::random_figure_type(0)
    push 0
    call Game_random_figure_type
    mov byte [edi+Game.cur_figure_type], al

    ; return.saved_figure_type = 0
    mov byte [edi+Game.saved_figure_type], 0

    ; return.saved_last_time = false
    mov byte [edi+Game.saved_last_time], 0

    ; return.cur_figure = Game::FIGURES[return.cur_figure_type]
    mov edx, eax
    shl edx, 4
    MEM_COPY edi+Game.cur_figure, Game_FIGURES+edx, 16

    ; return.projected_figure = Game::FIGURES[return.cur_figure_type]
    mov edx, eax
    shl edx, 4
    MEM_COPY edi+Game.projected_figure, Game_FIGURES+edx, 16

    ; return.figure_row = Game_DEFAULT_FIGURE_ROW
    mov dword [edi+Game.figure_row], Game_DEFAULT_FIGURE_ROW

    ; return.figure_col = Game_DEFAULT_FIGURE_COL
    mov dword [edi+Game.figure_col], Game_DEFAULT_FIGURE_COL

    ; return.projection_row = Game_DEFAULT_FIGURE_ROW
    mov dword [edi+Game.projection_row], Game_DEFAULT_FIGURE_ROW

    ; return.projection_col = Game_DEFAULT_FIGURE_COL
    mov dword [edi+Game.projection_col], Game_DEFAULT_FIGURE_COL

    ; return.fall_speed = initial_fall_speed
    fld dword [Game_INITIAL_FALL_SPEED]
    fstp dword [edi+Game.fall_speed]

    ; return.last_fall_time = 0.0
    fldz
    fstp dword [edi+Game.last_fall_time]

    ; return.speed_multiplier = 1.0
    fld1
    fstp dword [edi+Game.speed_multiplier]

    ; return.lie_time = 0.0
    fldz
    fstp dword [edi+Game.lie_time]

    mov dword [ebp+.prev_esp], esp
    ; srand(time(null))
    push 0
    call time
    push eax
    call srand
    mov esp, dword [ebp+.prev_esp]

    ; return.next_figure_types[0] = Game::random_figure_type(return.cur_figure_type)
    mov al, byte [edi+Game.cur_figure_type]
    movzx eax, al
    push eax
    call Game_random_figure_type
    mov byte [edi+Game.next_figure_types+0], al

    %assign i 1
    %rep Game.next_figure_types.len - 1

        ; return.next_figure_types[i] = Game::random_figure_type(return.next_figure_types[i-1])
        mov al, byte [edi+Game.next_figure_types+i-1]
        push eax
        call Game_random_figure_type
        mov byte [edi+Game.next_figure_types+i], al

    %assign i i+1
    %endrep

    add esp, .stack_size

    pop edi
    pop ebp
    ret .args_size


; #[stdcall]
; fn Game::next_figure(next_figures: &mut [FigureType; Self::N_NEXT_FIGURES]) -> FigureType
Game_next_figure:
    push ebp
    push esi
    mov ebp, esp

    .result             equ -4

    .argbase            equ 12
    .next_figures       equ .argbase+0

    .args_size          equ .next_figures-.argbase+4
    .stack_size         equ -.result

    sub esp, .stack_size

    ; next_figures := esi
    mov esi, dword [ebp+.next_figures]

    ; let result = next_figures[0]
    mov al, byte [esi+0]
    movzx eax, al
    mov dword [ebp+.result], eax

    %assign i 0
    %rep Game.next_figure_types.len - 1

        mov al, byte [esi+i+1]
        mov byte [esi+i], al

    %assign i i+1
    %endrep

    ; next_figures[Game_N_NEXT_FIGURES - 1]
    ;     = Game::random_figure_type(next_figures[Game_N_NEXT_FIGURES - 2])
    mov al, byte [esi+Game_N_NEXT_FIGURES-2]
    movzx eax, al
    push eax
    call Game_random_figure_type
    mov byte [esi+Game_N_NEXT_FIGURES-1], al

    ; return result
    mov eax, dword [ebp+.result]

    add esp, .stack_size

    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; Game::random_figure_type(prev: FigureType) -> FigureType
Game_random_figure_type:
    push ebp
    mov ebp, esp

    .argbase            equ 8
    .prev               equ .argbase+0
    
    .args_size          equ .prev-.argbase+4

    ; loop {
    .try_again:
        ; let (result := edx) = rand() % 7 + 1
        call rand
        xor edx, edx
        mov ecx, 7
        div ecx
        inc edx
    
        ; if result != prev { break }
        cmp edx, dword [ebp+.prev]
        je .try_again
    ; }

    ; if result != FigureType_I { Game::N_I_SKIPS += 1 }
    cmp edx, FigureType_I
    setne al
    movzx eax, al
    add dword [Game_N_I_SKIPS], eax

    ; if N_I_SKIPS == 10 {
    cmp dword [Game_N_I_SKIPS], 10
    jne .N_I_SKIPS_is_10
    
        ; N_I_SKIPS = 0
        mov dword [Game_N_I_SKIPS], 0

        ; return FigureType_I
        mov eax, FigureType_I
        jmp .exit
    ; }
    .N_I_SKIPS_is_10:

    ; return result
    mov eax, edx
    
.exit:
    pop ebp
    ret .args_size


; #[stdcall]
; fn Game::draw(&self, image: &mut ScreenImage)
Game_draw:
    push ebp
    push esi
    push edi
    mov ebp, esp

    .argbase            equ 16
    .self               equ .argbase+0
    .image              equ .argbase+4

    .args_size          equ .image-.argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

    ; image := edi
    mov edi, dword [ebp+.image]

    ; self.field.draw(image)
    push edi
    lea eax, dword [esi+Game.field]
    push eax
    call GameField_draw

    %assign relative_row 0
    %rep 4
        %assign relative_col 0
        %rep 4
        %push

            ; if self.cur_figure[relative_row * 4 + relative_col] != 0 {
            cmp byte [esi+Game.cur_figure+relative_row*4+relative_col], 0
            je %$.figure_is_not_empty

                ; GameField::draw_cell(image,
                ;                 self.figure_row + relative_row,
                ;                 self.figure_col + relative_col,
                ;                 self.cur_figure_type as u32)
                mov al, byte [esi+Game.cur_figure_type]
                movzx eax, al
                push eax
                mov eax, dword [esi+Game.figure_col]
                add eax, relative_col
                push eax
                mov eax, dword [esi+Game.figure_row]
                add eax, relative_row
                push eax
                push edi
                call GameField_draw_cell
            ; }
            %$.figure_is_not_empty:

            ; if self.projected_figure[relative_row * 4 + relative_col] != 0 {
            cmp byte [esi+Game.projected_figure+relative_row*4+relative_col], 0
            je %$.projection_is_not_empty

                ; GameField::draw_empty_cell(image,
                ;                 self.projection_row + relative_row,
                ;                 self.projection_col + relative_col,
                ;                 Game_PROJECTION_THICKNESS,
                ;                 self.cur_figure_type as u32)
                mov al, byte [esi+Game.cur_figure_type]
                movzx eax, al
                push eax
                push Game_PROJECTION_THICKNESS
                mov eax, dword [esi+Game.projection_col]
                add eax, relative_col
                push eax
                mov eax, dword [esi+Game.projection_row]
                add eax, relative_row
                push eax
                push edi
                call GameField_draw_empty_cell
            ; }
            %$.projection_is_not_empty:

        %pop
        %assign relative_col relative_col+1
        %endrep
    %assign relative_row relative_row+1
    %endrep

    ; self.draw_next_pieces(image)
    push edi
    push esi
    call Game_draw_next_pieces

    ; self.draw_saved_piece(image)
    push edi
    push esi
    call Game_draw_saved_piece

    pop edi
    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; Game::draw_next_pieces(&self, image: &mut ScreenImage)
Game_draw_next_pieces:
    push ebp
    push esi
    push edi
    mov ebp, esp

    .color              equ -12
    .bottom             equ -8
    .left               equ -4

    .argbase            equ 16
    .self               equ .argbase+0
    .image              equ .argbase+4

    .args_size          equ .image-.argbase+4
    .stack_size         equ -.color

    sub esp, .stack_size

    ; self := esi
    mov esi, dword [ebp+.self]

    ; image := edi
    mov edi, dword [ebp+.image]

    %assign i 0
    %rep Game.next_figure_types.len
        ; left = image.width / 2 + FIELD_WIDTH_PIXELS / 2 + CELL_SIZE_PIXELS
        mov eax, dword [edi+ScreenImage.width]
        shr eax, 1
        add eax, FIELD_WIDTH_PIXELS / 2 + CELL_SIZE_PIXELS
        mov dword [ebp+.left], eax

        ; bottom = image.height / 2 - FIELD_HEIGHT_PIXELS / 2 + 6 * CELL_SIZE_PIXELS + i * 5 * CELL_SIZE_PIXELS
        mov eax, dword [edi+ScreenImage.height]
        shr eax, 1
        sub eax, FIELD_HEIGHT_PIXELS / 2 - 6 * CELL_SIZE_PIXELS - i * 5 * CELL_SIZE_PIXELS
        mov dword [ebp+.bottom], eax

        ; image.fill_rect(left,
        ;                 bottom,
        ;                 4 * CELL_SIZE_PIXELS,
        ;                 4 * CELL_SIZE_PIXELS,
        ;                 Game_BACKGROUNG_COLOR)
        push Game_BACKGROUND_COLOR
        push 4 * CELL_SIZE_PIXELS
        push 4 * CELL_SIZE_PIXELS
        push dword [ebp+.bottom]
        push dword [ebp+.left]
        push edi
        call ScreenImage_fill_rect

        %assign row 0
        %rep 4
            %assign col 0
            %rep 4
            %push

                ; let (piece_index := ecx) = self.next_figure_types[Game_N_NEXT_FIGURES - i - 1]
                mov cl, byte [esi+Game.next_figure_types+Game_N_NEXT_FIGURES-i-1]
                movzx ecx, cl

                ; if 0 == Game::FIGURES[piece_index][row, col] {
                mov edx, ecx
                shl edx, 4
                cmp byte [Game_FIGURES+edx+(row*4+col)], 0
                jne %$.piece_not_empty

                    ; color = Game::CELL_COLORS[0]
                    mov eax, dword [Game_CELL_COLORS+0]
                    mov dword [ebp+.color], eax

                jmp %$.piece_handle_end
                ; } else {
                %$.piece_not_empty:

                    ; color = Game::CELL_COLORS[piece_index]
                    mov eax, dword [Game_CELL_COLORS+4*ecx]
                    mov dword [ebp+.color], eax
                ; }
                %$.piece_handle_end:

                ; image.fill_rect(left + col * CELL_SIZE_PIXELS + CELL_PADDING_PIXELS,
                ;                 bottom + row * CELL_SIZE_PIXELS + CELL_PADDING_PIXELS,
                ;                 CELL_SIZE_PIXELS - 2 * CELL_PADDING_PIXELS,
                ;                 CELL_SIZE_PIXELS - 2 * CELL_PADDING_PIXELS,
                ;                 color)
                push dword [ebp+.color]
                push CELL_SIZE_PIXELS - 2 * CELL_PADDING_PIXELS
                push CELL_SIZE_PIXELS - 2 * CELL_PADDING_PIXELS
                mov eax, dword [ebp+.bottom]
                add eax, row * CELL_SIZE_PIXELS + CELL_PADDING_PIXELS
                push eax
                mov eax, dword [ebp+.left]
                add eax, col * CELL_SIZE_PIXELS + CELL_PADDING_PIXELS
                push eax
                push edi
                call ScreenImage_fill_rect

            %pop
            %assign col col+1
            %endrep
        %assign row row+1
        %endrep
    %assign i i+1
    %endrep

    add esp, .stack_size

    pop edi
    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; Game::draw_saved_piece(&self, image: &mut ScreenImage)
Game_draw_saved_piece:
    push ebp
    push esi
    push edi
    mov ebp, esp

    .color              equ -12
    .bottom             equ -8
    .left               equ -4

    .argbase            equ 16
    .self               equ .argbase+0
    .image              equ .argbase+4

    .args_size          equ .image-.argbase+4
    .stack_size         equ -.color

    sub esp, .stack_size

    ; self := esi
    mov esi, dword [ebp+.self]

    ; image := edi
    mov edi, dword [ebp+.image]

    ; left = image.width / 2 - FIELD_WIDTH_PIXELS / 2 - 5 * CELL_SIZE_PIXELS
    mov eax, dword [edi+ScreenImage.width]
    shr eax, 1
    sub eax, FIELD_WIDTH_PIXELS / 2
    sub eax, 5 * CELL_SIZE_PIXELS
    mov dword [ebp+.left], eax

    ; bottom = image.height / 2 - FIELD_HEIGHT_PIXELS / 2 + (GameField_HEIGHT - 4) * CELL_SIZE_PIXELS
    mov eax, dword [edi+ScreenImage.height]
    shr eax, 1
    sub eax, FIELD_HEIGHT_PIXELS / 2
    add eax, (GameField_HEIGHT - 4) * CELL_SIZE_PIXELS
    mov dword [ebp+.bottom], eax

    ; image.fill_rect(left,
    ;                 bottom,
    ;                 4 * CELL_SIZE_PIXELS,
    ;                 4 * CELL_SIZE_PIXELS,
    ;                 Game_BACKGROUNG_COLOR)
    push Game_BACKGROUND_COLOR
    push 4 * CELL_SIZE_PIXELS
    push 4 * CELL_SIZE_PIXELS
    push dword [ebp+.bottom]
    push dword [ebp+.left]
    push edi
    call ScreenImage_fill_rect

    %assign row 0
    %rep 4
        %assign col 0
        %rep 4
        %push

            ; let (piece_index := ecx) = self.saved_figure_type
            mov cl, byte [esi+Game.saved_figure_type]
            movzx ecx, cl

            ; if 0 == Game::FIGURES[piece_index][row, col] {
            mov edx, ecx
            shl edx, 4
            cmp byte [Game_FIGURES+edx+(row*4+col)], 0
            jne %$.piece_not_empty

                ; color = Game::CELL_COLORS[0]
                mov eax, dword [Game_CELL_COLORS+0]
                mov dword [ebp+.color], eax

            jmp %$.piece_handle_end
            ; } else {
            %$.piece_not_empty:

                ; color = Game::CELL_COLORS[piece_index]
                mov eax, dword [Game_CELL_COLORS+4*ecx]
                mov dword [ebp+.color], eax
            ; }
            %$.piece_handle_end:

            ; image.fill_rect(left + col * CELL_SIZE_PIXELS + CELL_PADDING_PIXELS,
            ;                 bottom + row * CELL_SIZE_PIXELS + CELL_PADDING_PIXELS,
            ;                 CELL_SIZE_PIXELS - 2 * CELL_PADDING_PIXELS,
            ;                 CELL_SIZE_PIXELS - 2 * CELL_PADDING_PIXELS,
            ;                 color)
            push dword [ebp+.color]
            push CELL_SIZE_PIXELS - 2 * CELL_PADDING_PIXELS
            push CELL_SIZE_PIXELS - 2 * CELL_PADDING_PIXELS
            mov eax, dword [ebp+.bottom]
            add eax, row * CELL_SIZE_PIXELS + CELL_PADDING_PIXELS
            push eax
            mov eax, dword [ebp+.left]
            add eax, col * CELL_SIZE_PIXELS + CELL_PADDING_PIXELS
            push eax
            push edi
            call ScreenImage_fill_rect

        %pop
        %assign col col+1
        %endrep
    %assign row row+1
    %endrep

    add esp, .stack_size

    pop edi
    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; fn Game::set_moving_direction(&mut self, direction: i32)
Game_set_moving_direction:
    push ebp
    push esi
    mov ebp, esp

    .argbase            equ 12
    .self               equ .argbase+0
    .direction          equ .argbase+4

    .args_size          equ .direction-.argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

    ; self.moving_direction = direction
    mov eax, dword [ebp+.direction]
    mov dword [esi+Game.moving_direction], eax

    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; fn Game::update(&mut self, time_delta: f32)
Game_update:
    push ebp
    push esi
    mov ebp, esp

    .lie_offset         equ -12
    .hoffset            equ -8
    .voffset            equ -4

    .argbase            equ 12
    .self               equ .argbase+0
    .time_delta         equ .argbase+4

    .args_size          equ .time_delta-.argbase+4
    .stack_size         equ -.lie_offset

    sub esp, .stack_size

    ; self := esi
    mov esi, dword [ebp+.self]

    ; if self.handle_collisions(0, -1) != CollisionType::None {
    push -1
    push 0
    push esi
    call Game_handle_collisions
    cmp al, CollisionType_None
    je .collision_did_not_happen

        ; self.lie_time += time_delta * self.speed_multiplier
        fld dword [ebp+.time_delta]
        fmul dword [esi+Game.speed_multiplier]
        fadd dword [esi+Game.lie_time]
        fstp dword [esi+Game.lie_time]

        jmp .collision_handle_end
    ; } else {
    .collision_did_not_happen:

        ; self.lie_time = 0.0
        fldz
        fstp dword [esi+Game.lie_time]
    ; }
    .collision_handle_end:
    
    ; lie_offset = (self.lie_time * self.fall_speed) as i32
    fld dword [esi+Game.lie_time]
    fmul dword [esi+Game.fall_speed]
    fistp dword [ebp+.lie_offset]

    ; if lie_offset >= Game_LIE_TIMEOUT {
    cmp dword [ebp+.lie_offset], Game_LIE_TIMEOUT
    jl .lie_offset_less_than_1

        ; let (next_type := al) = Self::next_figure(&mut self.next_figure_types)
        lea eax, dword [esi+Game.next_figure_types]
        push eax
        call Game_next_figure

        ; self.switch_piece(next_type, do_write=true)
        push 1
        movzx eax, al
        push eax
        push esi
        call Game_switch_piece

        ; return;
        jmp .exit
    ; }
    .lie_offset_less_than_1:

    ; if self.lie_time == 0.0 {
    cmp dword [esi+Game.lie_time], 0
    jne .self_lie_time_is_not_0

        ; self.last_fall_time += time_delta * self.speed_multiplier
        fld dword [ebp+.time_delta]
        fmul dword [esi+Game.speed_multiplier]
        fadd dword [esi+Game.last_fall_time]
        fstp dword [esi+Game.last_fall_time]

        ; voffset = (self.last_fall_time * self.fall_speed) as i32
        fld dword [esi+Game.last_fall_time]
        fmul dword [esi+Game.fall_speed]
        fistp dword [ebp+.voffset]

        ; self.figure_row = GameField_HEIGHT - 4 - voffset
        mov eax, Game_DEFAULT_FIGURE_ROW
        sub eax, dword [ebp+.voffset]
        mov dword [esi+Game.figure_row], eax
    ; }
    .self_lie_time_is_not_0:

    ; hoffset = self.moving_direction
    mov eax, dword [esi+Game.moving_direction]
    mov dword [ebp+.hoffset], eax

    ; if self.can_move_in(hoffset) {
    push dword [ebp+.hoffset]
    push esi
    call Game_can_move_in
    test al, al
    jz .cannot_move_in_hoffset

        ; self.figure_col += hoffset
        mov eax, dword [ebp+.hoffset]
        add dword [esi+Game.figure_col], eax
    ; }
    .cannot_move_in_hoffset:

    ; game.project_piece()
    push esi
    call Game_project_piece
    
    ; game.clear_lines()
    push esi
    call Game_clear_lines

.exit:
    add esp, .stack_size

    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; fn Game::switch_piece(&mut self, next_type: CellType, do_write: bool)
Game_switch_piece:
    push ebp
    push esi
    mov ebp, esp

    .argbase            equ 12
    .self               equ .argbase+0
    .next_type          equ .argbase+4
    .do_write           equ .argbase+8

    .args_size          equ .do_write-.argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

    ; if do_write {
    cmp dword [ebp+.do_write], 0
    je .do_not_write

        %assign relative_row 0
        %rep 4
            %assign relative_col 0
            %rep 4
            %push
                
                ; if 0 == self.cur_figure[relative_row, relative_col] { continue }
                cmp byte [esi+Game.cur_figure+relative_row*4+relative_col], 0
                je %$.continue

                ; self.field.cells[self.figure_row + relative_row,
                ;                  self.figure_col + relative_col].type = self.cur_figure_type
                mov eax, dword [esi+Game.figure_row]
                add eax, relative_row
                mov edx, GameField_WIDTH
                mul edx
                add eax, dword [esi+Game.figure_col]
                add eax, relative_col
                mov dl, byte [esi+Game.cur_figure_type]
                movzx edx, dl
                mov byte [esi+Game.field+GameField.cells+4*eax+Cell.type], dl

                %$.continue:
            %pop
            %assign relative_col relative_col+1
            %endrep
        %assign relative_row relative_row+1
        %endrep

        ; self.saved_last_time = false
        mov byte [esi+Game.saved_last_time], 0
    ; }
    .do_not_write:

    ; self.cur_figure_type = next_type
    mov eax, dword [ebp+.next_type]
    mov byte [esi+Game.cur_figure_type], al

    ; self.cur_figure = Self::FIGURES[next_type]
    mov edx, eax
    shl edx, 4
    MEM_COPY esi+Game.cur_figure, Game_FIGURES+edx, 16

    ; self.projected_figure = Self::FIGURES[next_type]
    mov edx, eax
    shl edx, 4
    MEM_COPY esi+Game.projected_figure, Game_FIGURES+edx, 16

    ; self.figure_row = Game_DEFAULT_FIGURE_ROW
    mov dword [esi+Game.figure_row], Game_DEFAULT_FIGURE_ROW

    ; self.figure_col = Game_DEFAULT_FIGURE_COL
    mov dword [esi+Game.figure_col], Game_DEFAULT_FIGURE_COL

    ; self.projection_row = Game_DEFAULT_FIGURE_ROW
    mov dword [esi+Game.projection_row], Game_DEFAULT_FIGURE_ROW

    ; self.projection_col = Game_DEFAULT_FIGURE_COL
    mov dword [esi+Game.projection_col], Game_DEFAULT_FIGURE_COL

    ; self.last_fall_time = 0.0
    fldz
    fstp dword [esi+Game.last_fall_time]

    ; self.lie_time = 0.0
    fldz
    fstp dword [esi+Game.lie_time]

    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; fn Game::project_piece(&mut self)
Game_project_piece:
    push ebp
    push esi
    mov ebp, esp

    .row                equ -8
    .col                equ -4

    .argbase            equ 12
    .self               equ .argbase+0

    .args_size          equ .self-.argbase+4
    .stack_size         equ -.row

    sub esp, .stack_size

    ; self := esi
    mov esi, dword [ebp+.self]

    ; self.projected_figure = self.cur_figure
    MEM_COPY esi+Game.projected_figure, esi+Game.cur_figure, 1 * Game.cur_figure.len

    ; row = self.figure_row
    mov eax, dword [esi+Game.figure_row]
    mov dword [ebp+.row], eax

    ; col = self.figure_col
    mov eax, dword [esi+Game.figure_col]
    mov dword [ebp+.col], eax

    ; while (self.handle_collisions(0, -1) == CollisionType::None) {
    .while_no_collisions_start:
    push -1
    push 0
    push esi
    call Game_handle_collisions
    cmp al, CollisionType_None
    jne .while_no_collisions_end

        ; self.figure_row -= 1
        dec dword [esi+Game.figure_row]

    jmp .while_no_collisions_start
    ; }
    .while_no_collisions_end:

    ; self.projection_row = self.figure_row
    mov eax, dword [esi+Game.figure_row]
    mov dword [esi+Game.projection_row], eax

    ; self.projection_col = self.figure_col
    mov eax, dword [esi+Game.figure_col]
    mov dword [esi+Game.projection_col], eax

    ; self.figure_row = row
    mov eax, dword [ebp+.row]
    mov dword [esi+Game.figure_row], eax

    ; self.figure_col = col
    mov eax, dword [ebp+.col]
    mov dword [esi+Game.figure_col], eax

    add esp, .stack_size

    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; Game::drop_piece(&mut self)
Game_drop_piece:
    push ebp
    push esi
    mov ebp, esp

    .argbase            equ 12
    .self               equ .argbase+0

    .args_size          equ .self-.argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

    ; self.figure_row = self.projection_row
    mov eax, dword [esi+Game.projection_row]
    mov dword [esi+Game.figure_row], eax

    ; self.figure_col = self.projection_col
    mov eax, dword [esi+Game.projection_col]
    mov dword [esi+Game.figure_col], eax

    ; let (next_type := al) = Self::next_figure(&mut self.next_figure_types)
    lea eax, dword [esi+Game.next_figure_types]
    push eax
    call Game_next_figure

    ; self.switch_piece(next_type, do_write=true)
    push 1
    movzx eax, al
    push eax
    push esi
    call Game_switch_piece

    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; fn Game::handle_collisions(&mut self, hoffset: i32, voffset: i32) -> CollisionType
Game_handle_collisions:
    push ebp
    push esi
    mov ebp, esp

    .argbase            equ 12
    .self               equ .argbase+0
    .hoffset            equ .argbase+4
    .voffset            equ .argbase+8

    .args_size          equ .voffset-.argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

    %assign relative_row 0
    %rep 4
        %assign relative_col 0
        %rep 4
        %push

            ; if 0 == self.cur_figure[relative_row, relative_col]
            cmp byte [esi+Game.cur_figure+(relative_row*4+relative_col)], 0
            je %$.continue

            ; if self.figure_row + relative_row + voffset >= GameField_HEIGHT { return CollisionType::BottomBoundary }
            mov eax, dword [esi+Game.figure_row]
            add eax, relative_row
            add eax, dword [ebp+.voffset]
            cmp eax, GameField_HEIGHT
            mov al, CollisionType_BottomBoundary
            jae .exit

            ; if self.figure_col + hoffset + relative_col >= GameField_WIDTH { return CollisionType::SideBoundary }
            mov eax, dword [esi+Game.figure_col]
            add eax, relative_col
            add eax, dword [ebp+.hoffset]
            cmp eax, GameField_WIDTH
            mov al, CollisionType_SideBoundary
            jae .exit

            ; if CellType_Empty != self.field.cells[self.figure_row + relative_row + voffset,
            ;                                       self.figure_col + hoffset + relative_col].type
            ; { return CollisionType_GamePiece }
            mov eax, dword [esi+Game.figure_row]
            add eax, relative_row
            add eax, dword [ebp+.voffset]
            mov edx, GameField_WIDTH
            mul edx
            add eax, dword [esi+Game.figure_col]
            add eax, relative_col
            add eax, dword [ebp+.hoffset]
            cmp byte [esi+Game.field+GameField.cells+Cell.sizeof*eax+Cell.type], CellType_Empty
            mov al, CollisionType_GamePiece
            jne .exit

            %$.continue:

        %pop
        %assign relative_col relative_col+1
        %endrep
    %assign relative_row relative_row+1
    %endrep

    mov al, CollisionType_None

.exit:
    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; fn Game::rotate_figure_left(figure: &mut [u8; 16])
Game_rotate_figure_left:
    push ebp
    push esi
    mov ebp, esp

    .tmp_figure         equ -16

    .argbase            equ 12
    .figure             equ .argbase+0

    .args_size          equ .figure-.argbase+4
    .stack_size         equ -.tmp_figure

    sub esp, .stack_size

    ; figure := esi
    mov esi, dword [ebp+.figure]

    ; tmp_figure = figure
    MEM_COPY ebp+.tmp_figure, esi, 16

    mov al, byte [ebp+.tmp_figure+3]
    mov byte [esi+0], al

    mov al, byte [ebp+.tmp_figure+7]
    mov byte [esi+1], al

    mov al, byte [ebp+.tmp_figure+11]
    mov byte [esi+2], al

    mov al, byte [ebp+.tmp_figure+15]
    mov byte [esi+3], al

    mov al, byte [ebp+.tmp_figure+2]
    mov byte [esi+4], al

    mov al, byte [ebp+.tmp_figure+6]
    mov byte [esi+5], al

    mov al, byte [ebp+.tmp_figure+10]
    mov byte [esi+6], al

    mov al, byte [ebp+.tmp_figure+14]
    mov byte [esi+7], al

    mov al, byte [ebp+.tmp_figure+1]
    mov byte [esi+8], al

    mov al, byte [ebp+.tmp_figure+5]
    mov byte [esi+9], al

    mov al, byte [ebp+.tmp_figure+9]
    mov byte [esi+10], al

    mov al, byte [ebp+.tmp_figure+13]
    mov byte [esi+11], al

    mov al, byte [ebp+.tmp_figure+0]
    mov byte [esi+12], al

    mov al, byte [ebp+.tmp_figure+4]
    mov byte [esi+13], al

    mov al, byte [ebp+.tmp_figure+8]
    mov byte [esi+14], al

    mov al, byte [ebp+.tmp_figure+12]
    mov byte [esi+15], al

    add esp, .stack_size

    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; fn Game::rotate(&mut self)
Game_rotate:
    push ebp
    push esi
    mov ebp, esp

    .figure_state       equ -16

    .argbase            equ 12
    .self               equ .argbase+0

    .args_size          equ .self-.argbase+4
    .stack_size         equ -.figure_state

    sub esp, .stack_size

    ; self := esi
    mov esi, dword [ebp+.self]

    ; figure_state = self.cur_figure
    MEM_COPY ebp+.figure_state, esi+Game.cur_figure, 16

    ; Self::rotate_figure_left(&mut self.cur_figure)
    lea eax, dword [esi+Game.cur_figure]
    push eax
    call Game_rotate_figure_left

    ; if !self.kick_figure() {
    push esi
    call Game_kick_figure
    test al, al
    jnz .kick_success

        ; self.cur_figure = figure_state
        MEM_COPY esi+Game.cur_figure, ebp+.figure_state, 16
    ; }
    .kick_success:

    add esp, .stack_size

    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; Game::try_swap_saved(&mut self) -> success: bool
Game_try_swap_saved:
    push ebp
    push esi
    mov ebp, esp

    .argbase            equ 12
    .self               equ .argbase+0
    
    .args_size          equ .self-.argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

    ; if self.saved_last_time { return false }
    xor al, al
    cmp byte [esi+Game.saved_last_time], 0
    jne .exit
    
    ; self.save_load_piece()
    push esi
    call Game_save_load_piece

    ; return true
    mov al, 1

.exit:
    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; Game::save_load_piece(&mut self)
Game_save_load_piece:
    push ebp
    push esi
    mov ebp, esp

    .next_type          equ -4

    .argbase            equ 12
    .self               equ .argbase+0

    .args_size          equ .self-.argbase+4
    .stack_size         equ -.next_type

    sub esp, .stack_size

    ; self := esi
    mov esi, dword [ebp+.self]

    ; if self.saved_figure_type == 0 {
    cmp byte [esi+Game.saved_figure_type], 0
    jne .saved_figure_type_is_not_zero

        ; next_type = Self::next_figure(&mut self.next_figure_types)
        lea eax, dword [esi+Game.next_figure_types]
        push eax
        call Game_next_figure
        movzx eax, al
        mov dword [ebp+.next_type], eax
    
        ; self.saved_figure_type = self.cur_figure_type
        mov al, byte [esi+Game.cur_figure_type]
        mov byte [esi+Game.saved_figure_type], al

        jmp .next_type_handle_exit
    ; } else {
    .saved_figure_type_is_not_zero:

        ; swap(&mut self.cur_figure_type, &mut self.saved_figure_type)
        mov al, byte [esi+Game.cur_figure_type]
        xchg al, byte [esi+Game.saved_figure_type]
        mov byte [esi+Game.cur_figure_type], al

        ; next_type = self.cur_figure_type
        mov al, byte [esi+Game.cur_figure_type]
        movzx eax, al
        mov dword [ebp+.next_type], eax
    ; }
    .next_type_handle_exit:

    ; self.saved_last_time = true
    mov byte [esi+Game.saved_last_time], 1

    ; self.switch_piece(next_type, false)
    push 0
    push dword [ebp+.next_type]
    push esi
    call Game_switch_piece

.exit:
    add esp, .stack_size

    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; Game::kick_figure(&mut self) -> success: bool
Game_kick_figure:
    push ebp
    push esi
    mov ebp, esp

    .row_before         equ -8
    .col_before         equ -4

    .argbase            equ 12
    .self               equ .argbase+0

    .args_size          equ .self-.argbase+4
    .stack_size         equ -.row_before

    sub esp, .stack_size

    ; self := esi
    mov esi, dword [ebp+.self]

    ; row_before = self.figure_row
    mov eax, dword [esi+Game.figure_row]
    mov dword [ebp+.row_before], eax

    ; col_before = self.figure_col
    mov eax, dword [esi+Game.figure_col]
    mov dword [ebp+.col_before], eax

    ; if self.handle_collisions(0, 0) == CollisionType::None { return true }
    push 0
    push 0
    push esi
    call Game_handle_collisions
    cmp al, CollisionType_None
    sete al
    je .exit

    %assign hoffset -1
    %rep 3
        %assign voffset -1
        %rep 2
        %push

            ; self.figure_row = row_before + voffset
            mov eax, dword [ebp+.row_before]
            add eax, voffset
            mov dword [esi+Game.figure_row], eax

            ; self.figure_col = col_before + hoffset
            mov eax, dword [ebp+.col_before]
            add eax, hoffset
            mov dword [esi+Game.figure_col], eax

            ; if self.handle_collisions(0, 0) == CollisionType::None {
            push 0
            push 0
            push esi
            call Game_handle_collisions
            cmp al, CollisionType_None
            jne %$.collision

                ; return true
                mov al, 1
                jmp .exit
            ; }
            %$.collision:

        %pop
        %assign voffset voffset+1
        %endrep
    %assign hoffset hoffset+1
    %endrep

    ; if self.cur_figure_type == FigureType_I {
    cmp byte [esi+Game.cur_figure_type], FigureType_I
    jne .cur_figure_type_is_not_FigureType_I

        %assign hoffset -2
        %rep 5
            %assign voffset -2
            %rep 2
            %push

                ; self.figure_row = row_before + voffset
                mov eax, dword [ebp+.row_before]
                add eax, voffset
                mov dword [esi+Game.figure_row], eax

                ; self.figure_col = col_before + hoffset
                mov eax, dword [ebp+.col_before]
                add eax, hoffset
                mov dword [esi+Game.figure_col], eax

                ; if self.handle_collisions(0, 0) == CollisionType::None {
                push 0
                push 0
                push esi
                call Game_handle_collisions
                cmp al, CollisionType_None
                jne %$.collision

                    ; return true
                    mov al, 1
                    jmp .exit
                ; }
                %$.collision:

            %pop
            %assign voffset voffset+1
            %endrep
        %assign hoffset hoffset+1
        %endrep
    ; }
    .cur_figure_type_is_not_FigureType_I:

    ; self.figure_row = row_before
    mov eax, dword [ebp+.row_before]
    mov dword [esi+Game.figure_row], eax

    ; self.figure_col = col_before
    mov eax, dword [ebp+.col_before]
    mov dword [esi+Game.figure_col], eax

    xor al, al

.exit:
    add esp, .stack_size

    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; fn Game::can_move_in(&self, direction: i32) -> bool
Game_can_move_in:
    push ebp
    push esi
    mov ebp, esp

    .argbase            equ 12
    .self               equ .argbase+0
    .direction          equ .argbase+4

    .args_size          equ .direction-.argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

    ; if direction == 0 { return true }
    cmp dword [ebp+.direction], 0
    sete al
    je .exit

    ; return CollisionType::None == self.handle_collisions(direction, 0)
    push 0
    push dword [ebp+.direction]
    push esi
    call Game_handle_collisions
    cmp al, CollisionType_None
    sete al

.exit:
    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; fn Game::clear_lines(&mut self)
Game_clear_lines:
    push ebp
    push edi
    push esi
    mov ebp, esp

    .tmp_field          equ -GameField.sizeof

    .argbase            equ 16
    .self               equ .argbase+0
    
    .args_size          equ .self-.argbase+4
    .stack_size         equ -.tmp_field

    ; self := esi
    mov esi, dword [ebp+.self]

    sub esp, .stack_size

    ; tmp_field = self.field.clone()
    MEM_COPY ebp+.tmp_field, esi+Game.field, GameField.sizeof

    ; self.field = mem::zeroed()
    MEM_ZEROED GameField, esi+Game.field

    ; let (dest_index := edi) = 0
    xor edi, edi

    %assign row 0
    %rep GameField_HEIGHT
    %push

        ; let (skip_line := al) = 0
        xor al, al

        %assign col 0
        %rep GameField_WIDTH

            ; if tmp_field.cells[row, col].type == CellType_Empty { skip_line = 1; break }
            cmp byte [ebp+.tmp_field+GameField.cells+Cell.sizeof*(row*GameField_WIDTH+col)+Cell.type], CellType_Empty
            sete al
            je %$.end_col

        %assign col col+1
        %endrep
        %$.end_col:

        ; if skip_line { continue }
        test al, al
        jz %$.continue

        ; memcpy(&mut self.field.cells[dest_index, 0]
        ;        &tmp_field.cells[row, 0]
        ;        GameField_WIDTH * sizoef(Cell))
        push eax
        push GameField_WIDTH * Cell.sizeof
        lea eax, dword [ebp+.tmp_field+GameField.cells+Cell.sizeof*(row*GameField_WIDTH)]
        push eax
        mov eax, GameField_WIDTH
        mul edi
        lea eax, dword [esi+Game.field+GameField.cells+Cell.sizeof*eax]
        push eax
        call memcpy
        add esp, 12
        pop eax

        ; dest_index += 1
        inc edi

        %$.continue:

    %pop
    %assign row row+1
    %endrep

    add esp, .stack_size

    pop esi
    pop edi
    pop ebp
    ret .args_size