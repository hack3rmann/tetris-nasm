%ifndef _TETRIS_LIB_FONTS_
%define _TETRIS_LIB_FONTS_



%define UNIMPLEMENTED_GLYPH \
    1, 1, 1, 1, 1, 1, 1, \
    1, 0, 0, 0, 0, 1, 1, \
    1, 0, 0, 0, 1, 1, 1, \
    1, 0, 0, 1, 1, 0, 1, \
    1, 0, 1, 1, 0, 0, 1, \
    1, 1, 1, 0, 0, 0, 1, \
    1, 1, 1, 1, 1, 1, 1, FONT_ALIGN_BYTES



%define FONT_SIZE_TEXELS 7
%define FONT_ADVANCE_TEXELS 1
%define FONT_N_ALIGN_BYTES (3 + FONT_SIZE_TEXELS * FONT_SIZE_TEXELS)
%define FONT_ALIGN_BYTES 0, 0, 0



section .rodata align 4
GLYPHS:
    %rep 32
    %push
    %$.unknown_symbol db UNIMPLEMENTED_GLYPH
    %pop
    %endrep

    .SPACE db 0, 0, 0, 0, 0, 0, 0, \
              0, 0, 0, 0, 0, 0, 0, \
              0, 0, 0, 0, 0, 0, 0, \
              0, 0, 0, 0, 0, 0, 0, \
              0, 0, 0, 0, 0, 0, 0, \
              0, 0, 0, 0, 0, 0, 0, \
              0, 0, 0, 0, 0, 0, 0, FONT_ALIGN_BYTES
    
    %rep 15
    %push
    %$.unknown_symbol db UNIMPLEMENTED_GLYPH
    %pop
    %endrep

    ._0 db 0, 0, 1, 1, 1, 0, 0, \
           0, 1, 0, 0, 1, 1, 0, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           0, 1, 1, 0, 0, 1, 0, \
           0, 0, 1, 1, 1, 0, 0, FONT_ALIGN_BYTES
    
    ._1 db 0, 0, 0, 1, 1, 0, 0, \
           0, 0, 1, 1, 1, 0, 0, \
           0, 0, 0, 1, 1, 0, 0, \
           0, 0, 0, 1, 1, 0, 0, \
           0, 0, 0, 1, 1, 0, 0, \
           0, 0, 0, 1, 1, 0, 0, \
           0, 1, 1, 1, 1, 1, 1, FONT_ALIGN_BYTES
    
    ._2 db 0, 1, 1, 1, 1, 1, 0, \
           1, 1, 0, 0, 0, 1, 1, \
           0, 0, 0, 0, 1, 1, 1, \
           0, 0, 1, 1, 1, 1, 0, \
           0, 1, 1, 1, 1, 0, 0, \
           1, 1, 1, 0, 0, 0, 0, \
           1, 1, 1, 1, 1, 1, 1, FONT_ALIGN_BYTES
    
    ._3 db 0, 1, 1, 1, 1, 1, 1, \
           0, 0, 0, 0, 1, 1, 0, \
           0, 0, 0, 1, 1, 0, 0, \
           0, 0, 1, 1, 1, 1, 0, \
           0, 0, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           0, 1, 1, 1, 1, 1, 0, FONT_ALIGN_BYTES

    ._4 db 0, 0, 0, 1, 1, 1, 0, \
           0, 0, 1, 1, 1, 1, 0, \
           0, 1, 1, 0, 1, 1, 0, \
           1, 1, 0, 0, 1, 1, 0, \
           1, 1, 1, 1, 1, 1, 1, \
           0, 0, 0, 0, 1, 1, 0, \
           0, 0, 0, 0, 1, 1, 0, FONT_ALIGN_BYTES
    
    ._5 db 1, 1, 1, 1, 1, 1, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 1, 1, 1, 1, 0, \
           0, 0, 0, 0, 0, 1, 1, \
           0, 0, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           0, 1, 1, 1, 1, 1, 0, FONT_ALIGN_BYTES
    
    ._6 db 0, 0, 1, 1, 1, 1, 0, \
           0, 1, 1, 0, 0, 0, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 1, 1, 1, 1, 0, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           0, 1, 1, 1, 1, 1, 0, FONT_ALIGN_BYTES
    
    ._7 db 1, 1, 1, 1, 1, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           0, 0, 0, 0, 1, 1, 0, \
           0, 0, 0, 1, 1, 0, 0, \
           0, 0, 1, 1, 0, 0, 0, \
           0, 0, 1, 1, 0, 0, 0, \
           0, 0, 1, 1, 0, 0, 0, FONT_ALIGN_BYTES
    
    ._8 db 0, 1, 1, 1, 1, 0, 0, \
           1, 1, 0, 0, 0, 1, 0, \
           1, 1, 1, 0, 0, 1, 0, \
           0, 1, 1, 1, 1, 0, 0, \
           1, 0, 0, 1, 1, 1, 1, \
           1, 0, 0, 0, 0, 1, 1, \
           0, 1, 1, 1, 1, 1, 0, FONT_ALIGN_BYTES

    ._9 db 0, 1, 1, 1, 1, 1, 0, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           0, 1, 1, 1, 1, 1, 1, \
           0, 0, 0, 0, 0, 1, 1, \
           0, 0, 0, 0, 1, 1, 0, \
           0, 1, 1, 1, 1, 0, 0, FONT_ALIGN_BYTES
    
    .COLON db 0, 0, 0, 0, 0, 0, 0, \
              0, 1, 1, 0, 0, 0, 0, \
              0, 1, 1, 0, 0, 0, 0, \
              0, 0, 0, 0, 0, 0, 0, \
              0, 0, 0, 0, 0, 0, 0, \
              0, 1, 1, 0, 0, 0, 0, \
              0, 1, 1, 0, 0, 0, 0, FONT_ALIGN_BYTES

    %rep 6
    %push
    %$.unknown_symbol db UNIMPLEMENTED_GLYPH
    %pop
    %endrep

    .A  db 0, 0, 1, 1, 1, 0, 0, \
           0, 1, 1, 0, 1, 1, 0, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 1, 1, 1, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, FONT_ALIGN_BYTES

    .B  db 1, 1, 1, 1, 1, 1, 0, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 1, 1, 1, 0, 0, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 1, 1, 1, 1, 0, FONT_ALIGN_BYTES
    
    .C  db 0, 0, 1, 1, 1, 1, 0, \
           0, 1, 1, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           0, 1, 1, 0, 0, 1, 1, \
           0, 0, 1, 1, 1, 1, 0, FONT_ALIGN_BYTES

    .D  db UNIMPLEMENTED_GLYPH
    
    .E  db 1, 1, 1, 1, 1, 1, 1, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 1, 1, 1, 0, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 1, 1, 1, 1, 1, FONT_ALIGN_BYTES

    .F  db UNIMPLEMENTED_GLYPH
    .G  db UNIMPLEMENTED_GLYPH
    .H  db UNIMPLEMENTED_GLYPH

    .I  db 1, 1, 1, 1, 1, 1, 0, \
           0, 0, 1, 1, 0, 0, 0, \
           0, 0, 1, 1, 0, 0, 0, \
           0, 0, 1, 1, 0, 0, 0, \
           0, 0, 1, 1, 0, 0, 0, \
           0, 0, 1, 1, 0, 0, 0, \
           1, 1, 1, 1, 1, 1, 0, FONT_ALIGN_BYTES

    .J  db UNIMPLEMENTED_GLYPH
    .K  db UNIMPLEMENTED_GLYPH

    .L  db 1, 1, 0, 0, 0, 0, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 1, 1, 1, 1, 0, FONT_ALIGN_BYTES

    .M  db UNIMPLEMENTED_GLYPH

    .N  db 1, 1, 0, 0, 0, 1, 1, \
           1, 1, 1, 0, 0, 1, 1, \
           1, 1, 1, 1, 0, 1, 1, \
           1, 1, 1, 1, 1, 1, 1, \
           1, 1, 0, 1, 1, 1, 1, \
           1, 1, 0, 0, 1, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, FONT_ALIGN_BYTES

    .O  db 0, 1, 1, 1, 1, 1, 0, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           0, 1, 1, 1, 1, 1, 0, FONT_ALIGN_BYTES

    .P  db UNIMPLEMENTED_GLYPH
    .Q  db UNIMPLEMENTED_GLYPH

    .R  db 1, 1, 1, 1, 1, 1, 0, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 1, 1, 1, \
           1, 1, 1, 1, 1, 0, 0, \
           1, 1, 0, 1, 1, 1, 0, \
           1, 1, 0, 0, 1, 1, 1, FONT_ALIGN_BYTES

    .S  db 0, 1, 1, 1, 1, 0, 0, \
           1, 1, 0, 0, 1, 1, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           0, 1, 1, 1, 1, 1, 0, \
           0, 0, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           0, 1, 1, 1, 1, 1, 0, FONT_ALIGN_BYTES

    .T  db UNIMPLEMENTED_GLYPH
    .U  db UNIMPLEMENTED_GLYPH

    .V  db 1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 1, 0, 1, 1, 1, \
           0, 1, 1, 1, 1, 1, 0, \
           0, 0, 1, 1, 1, 0, 0, \
           0, 0, 0, 1, 0, 0, 0, FONT_ALIGN_BYTES

    .W  db UNIMPLEMENTED_GLYPH
    .X  db UNIMPLEMENTED_GLYPH
    .Y  db UNIMPLEMENTED_GLYPH
    .Z  db UNIMPLEMENTED_GLYPH

    %rep 6
    %push
    %$.unknown_symbol db UNIMPLEMENTED_GLYPH
    %pop
    %endrep

    .a  db 0, 0, 1, 1, 1, 0, 0, \
           0, 1, 1, 0, 1, 1, 0, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 1, 1, 1, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, FONT_ALIGN_BYTES

    .b  db 1, 1, 1, 1, 1, 1, 0, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 1, 1, 1, 0, 0, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 1, 1, 1, 1, 0, FONT_ALIGN_BYTES
    
    .c  db 0, 0, 1, 1, 1, 1, 0, \
           0, 1, 1, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           0, 1, 1, 0, 0, 1, 1, \
           0, 0, 1, 1, 1, 1, 0, FONT_ALIGN_BYTES

    .d  db UNIMPLEMENTED_GLYPH
    
    .e  db 1, 1, 1, 1, 1, 1, 1, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 1, 1, 1, 0, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 1, 1, 1, 1, 0, FONT_ALIGN_BYTES

    .f  db UNIMPLEMENTED_GLYPH
    .g  db UNIMPLEMENTED_GLYPH
    .h  db UNIMPLEMENTED_GLYPH

    .i  db 1, 1, 1, 1, 1, 1, 0, \
           0, 0, 1, 1, 0, 0, 0, \
           0, 0, 1, 1, 0, 0, 0, \
           0, 0, 1, 1, 0, 0, 0, \
           0, 0, 1, 1, 0, 0, 0, \
           0, 0, 1, 1, 0, 0, 0, \
           1, 1, 1, 1, 1, 1, 0, FONT_ALIGN_BYTES

    .j  db UNIMPLEMENTED_GLYPH
    .k  db UNIMPLEMENTED_GLYPH

    .l  db 1, 1, 0, 0, 0, 0, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           1, 1, 1, 1, 1, 1, 0, FONT_ALIGN_BYTES

    .m  db UNIMPLEMENTED_GLYPH

    .n  db 1, 1, 0, 0, 0, 1, 1, \
           1, 1, 1, 0, 0, 1, 1, \
           1, 1, 1, 1, 0, 1, 1, \
           1, 1, 1, 1, 1, 1, 1, \
           1, 1, 0, 1, 1, 1, 1, \
           1, 1, 0, 0, 1, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, FONT_ALIGN_BYTES

    .o  db 0, 1, 1, 1, 1, 1, 0, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           0, 1, 1, 1, 1, 1, 0, FONT_ALIGN_BYTES

    .p  db UNIMPLEMENTED_GLYPH
    .q  db UNIMPLEMENTED_GLYPH

    .r  db 1, 1, 1, 1, 1, 1, 0, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 1, 1, 1, \
           1, 1, 1, 1, 1, 0, 0, \
           1, 1, 0, 1, 1, 1, 0, \
           1, 1, 0, 0, 1, 1, 1, FONT_ALIGN_BYTES

    .s  db 0, 1, 1, 1, 1, 0, 0, \
           1, 1, 0, 0, 1, 1, 0, \
           1, 1, 0, 0, 0, 0, 0, \
           0, 1, 1, 1, 1, 1, 0, \
           0, 0, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           0, 1, 1, 1, 1, 1, 0, FONT_ALIGN_BYTES

    .t  db UNIMPLEMENTED_GLYPH
    .u  db UNIMPLEMENTED_GLYPH

    .v  db 1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 0, 0, 0, 1, 1, \
           1, 1, 1, 0, 1, 1, 1, \
           0, 1, 1, 1, 1, 1, 0, \
           0, 0, 1, 1, 1, 0, 0, \
           0, 0, 0, 1, 0, 0, 0, FONT_ALIGN_BYTES

    .w  db UNIMPLEMENTED_GLYPH
    .x  db UNIMPLEMENTED_GLYPH
    .y  db UNIMPLEMENTED_GLYPH
    .z  db UNIMPLEMENTED_GLYPH

    %rep 5
    %push
    %$.unknown_symbol db UNIMPLEMENTED_GLYPH
    %pop
    %endrep



%endif ; !_TETRIS_LIB_FONTS_