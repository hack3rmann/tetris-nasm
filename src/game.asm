%include "src/game.inc"
%include "lib/mem.inc"
%include "lib/debug/print.inc"

extern printf



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

    %assign i 0
    %rep GameField_N_CELLS
        ; return.cells[i] = mem::zeroed()
        MEM_ZEROED Cell, edi + GameField.cells + i * Cell.sizeof
    %assign i i+1
    %endrep

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
    ;                 BACKGROUND_COLOR)
    push BACKGROUND_COLOR
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
            push dword [esi+GameField.cells+4*(row*GameField_WIDTH+col)+Cell.type]
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

    ; cur_color = cell_colors[type]
    mov eax, dword [ebp+.type]
    mov eax, dword [cell_colors+4*eax]
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



; [stdcall]
; fn Game::new() -> Self
Game_new:
    push ebp
    push edi
    mov ebp, esp

    .argbase            equ 12
    .return             equ .argbase+0

    .args_size          equ .return-.argbase+4

    ; return := edi
    mov edi, dword [ebp+.return]

    DEBUGLN `Game::new()`

    ; return.field = GameField::new()
    lea eax, dword [edi+Game.field]
    push eax
    call GameField_new

    ; return.cur_figure_type = CellType::I
    mov byte [edi+Game.cur_figure_type], CellType_I

    ; return.cur_figure = FIGURES.i
    MEM_COPY edi+Game.cur_figure, FIGURES.i, 16

    ; self.figure_row = Game_DEFAULT_FIGURE_ROW
    mov dword [edi+Game.figure_row], Game_DEFAULT_FIGURE_ROW

    ; self.figure_col = Game_DEFAULT_FIGURE_COL
    mov dword [edi+Game.figure_col], Game_DEFAULT_FIGURE_COL

    ; return.fall_speed = initial_fall_speed
    fld dword [Game_INITIAL_FALL_SPEED]
    fstp dword [edi+Game.fall_speed]

    ; return.last_fall_time = 0.0
    fldz
    fstp dword [edi+Game.last_fall_time]

    pop edi
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

        %pop
        %assign relative_col relative_col+1
        %endrep
    %assign relative_row relative_row+1
    %endrep

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

    .hoffset            equ -8
    .voffset            equ -4

    .argbase            equ 12
    .self               equ .argbase+0
    .time_delta         equ .argbase+4

    .args_size          equ .time_delta-.argbase+4
    .stack_size         equ -.hoffset

    sub esp, .stack_size

    ; self := esi
    mov esi, dword [ebp+.self]

    ; hoffset = self.moving_direction
    mov eax, dword [esi+Game.moving_direction]
    mov dword [ebp+.hoffset], eax

    ; self.last_fall_time += time_delta
    fld dword [esi+Game.last_fall_time]
    fadd dword [ebp+.time_delta]
    fstp dword [esi+Game.last_fall_time]

    ; if self.handle_collisions() != CollisionType::None {
    push esi
    call Game_handle_collisions
    cmp al, CollisionType_None
    je .collision_did_not_happen

        ; self.switch_piece((self.cur_figure_type as u32 + 1) % 8)
        mov al, byte [esi+Game.cur_figure_type]
        movzx eax, al
        inc eax
        and eax, 7
        test al, al
        mov edx, 1
        cmovz eax, edx
        push eax
        push esi
        call Game_switch_piece
    ; }
    .collision_did_not_happen:

    ; voffset = self.last_fall_time * self.fall_speed
    fld dword [esi+Game.last_fall_time]
    fmul dword [esi+Game.fall_speed]
    fistp dword [ebp+.voffset]

    ; self.figure_row = GameField_HEIGHT - 4 - voffset
    mov eax, GameField_HEIGHT - 4
    sub eax, dword [ebp+.voffset]
    mov dword [esi+Game.figure_row], eax

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

    add esp, .stack_size

    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; fn Game::switch_piece(&mut self, next_type: CellType)
Game_switch_piece:
    push ebp
    push esi
    mov ebp, esp

    .argbase            equ 12
    .self               equ .argbase+0
    .next_type          equ .argbase+4

    .args_size          equ .next_type-.argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

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

    ; self.cur_figure_type = next_type
    mov eax, dword [ebp+.next_type]
    mov byte [esi+Game.cur_figure_type], al

    ; self.cur_figure = FIGURES[next_type]
    shl eax, 4
    MEM_COPY esi+Game.cur_figure, FIGURES+eax, 16

    ; self.figure_row = Game_DEFAULT_FIGURE_ROW
    mov dword [esi+Game.figure_row], Game_DEFAULT_FIGURE_ROW

    ; self.figure_col = Game_DEFAULT_FIGURE_COL
    mov dword [esi+Game.figure_col], Game_DEFAULT_FIGURE_COL

    ; self.last_fall_time -= self.last_fall_time as u32 as f32
    fld dword [esi+Game.last_fall_time]
    fld dword [esi+Game.last_fall_time]
    frndint
    fsubp
    fstp dword [esi+Game.last_fall_time]

    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; fn Game::handle_collisions(&mut self) -> CollisionType
Game_handle_collisions:
    push ebp
    push esi
    mov ebp, esp

    .argbase            equ 12
    .self               equ .argbase+0

    .args_size          equ .self-.argbase+4

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

            ; if self.figure_row + relative_row - 1 >= GameField_HEIGHT { return CollisionType::BottomBoundary }
            mov eax, dword [esi+Game.figure_row]
            add eax, relative_row
            dec eax
            cmp eax, GameField_HEIGHT
            mov al, CollisionType_BottomBoundary
            jnb .exit

            ; if self.figure_col + relative_col >= GameField_WIDTH { return CollisionType::SideBoundary }
            mov eax, dword [esi+Game.figure_col]
            add eax, relative_col
            cmp eax, GameField_WIDTH
            mov al, CollisionType_SideBoundary
            jnb .exit

            ; if CellType_Empty != self.field.cells[self.figure_row + relative_row - 1, self.figure_col + relative_col].type
            mov eax, dword [esi+Game.figure_row]
            add eax, relative_row
            dec eax
            mov edx, GameField_WIDTH
            mul edx
            add eax, dword [esi+Game.figure_col]
            add eax, relative_col
            mov al, byte [esi+Game.field+GameField.cells+4*eax+Cell.type]
            cmp al, CellType_Empty
            je %$.cell_is_empty
            
                ; return CollisionType::GamePiece
                mov al, CollisionType_GamePiece
                jmp .exit

            ; }
            %$.cell_is_empty:

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
; fn Game::is_colliding_with_left_boundary(&self) -> bool
Game_is_colliding_with_left_boundary:
    push ebp
    push esi
    mov ebp, esp

    .argbase            equ 12
    .self               equ .argbase+0

    .args_size          equ .self-.argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

    %assign relative_row 0
    %rep 4
        %assign relative_col 0
        %rep 4
        %push

            ; if 0 == self.cur_figure[relative_row, relative_col] { continue }
            cmp byte [esi+Game.cur_figure+(relative_row*4+relative_col)], 0
            je %$.continue

            ; if 0 == relative_col + self.figure_col { return true }
            mov eax, dword [esi+Game.figure_col]
            add eax, relative_col
            test eax, eax
            setz al
            jz .exit
            
            %$.continue:
        %pop
        %assign relative_col relative_col+1
        %endrep
    %assign relative_row relative_row+1
    %endrep

    xor al, al

.exit:
    pop esi
    pop ebp
    ret .args_size


; #[stdcall]
; fn Game::is_colliding_with_right_boundary(&self) -> bool
Game_is_colliding_with_right_boundary:
    push ebp
    push esi
    mov ebp, esp

    .argbase            equ 12
    .self               equ .argbase+0

    .args_size          equ .self-.argbase+4

    ; self := esi
    mov esi, dword [ebp+.self]

    %assign relative_row 0
    %rep 4
        %assign relative_col 0
        %rep 4
        %push

            ; if 0 == self.cur_figure[relative_row, relative_col] { continue }
            cmp byte [esi+Game.cur_figure+(relative_row*4+relative_col)], 0
            je %$.continue

            ; if GameField_WIDTH - 1 == relative_col + self.figure_col { return true }
            mov eax, dword [esi+Game.figure_col]
            add eax, relative_col
            cmp eax, GameField_WIDTH - 1
            sete al
            je .exit
            
            %$.continue:
        %pop
        %assign relative_col relative_col+1
        %endrep
    %assign relative_row relative_row+1
    %endrep

    xor al, al

.exit:
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

    ; direction == -1 {
    cmp dword [ebp+.direction], -1
    jne .direction_is_not_neg_one

        ; return !self.is_colliding_with_left_boundary()
        push esi
        call Game_is_colliding_with_left_boundary
        not al
        and al, 1
        jmp .exit
    ; }
    .direction_is_not_neg_one:

    ; direction == 1 {
    cmp dword [ebp+.direction], 1
    jne .direction_is_not_one

        ; return !self.is_colliding_with_right_boundary()
        push esi
        call Game_is_colliding_with_right_boundary
        not al
        and al, 1
        jmp .exit
    ; }
    .direction_is_not_one:

    xor al, al

.exit:
    pop esi
    pop ebp
    ret .args_size
