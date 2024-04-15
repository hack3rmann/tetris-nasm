# Tetris (NASM)

## Overview

This is classic game named 'Tetris' written in plain old pure assembly (NASM).

![Tetris Gameplay](https://i.ibb.co/vkQ6L0x/tetris-3za-P2e-Amh-G.png)

## Implementation goals

- [x] Basic Tetris gameplay: falling figures, clearing lines
- [x] Figure fall trajectories
- [x] Next figures window
- [x] Figure holding possibility
- [x] Statistics: score and cleared lines
- [x] Levels: speed up game on each level
- [ ] Game over message
- [ ] Original music
- [ ] Pause menu
- [ ] Main menu

## Implementation details

`tetris-nasm` uses NASM as the only programming language, `libc` and `WIN32 API` (with `GDI`) as external libraries.

## How to build

1. Ensure You have installed SASM IDE.
2. Configure `SASM_PATH` variable in `Makefile` in the project root directory.
3. Run `make build` (or `make run` to run game on success build) in the project root directory.
4. If build succeeds You can find the executable in `target/` directory from the project root directory.
