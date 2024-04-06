TARGET_DIR = target
EXECUTABLE_NAME = tetris.exe

NASM = "D:/Program Files (x86)/SASM/NASM/nasm.exe"
NASM_FLAGS = --gprefix _ -f win32

LINKER = "D:/Program Files (x86)/SASM/MinGW/bin/gcc.exe"
LINKER_FLAGS = -g -m32


compile: $(TARGET_DIR)
	@$(foreach \
		file,\
		$(wildcard src/*.asm lib/*.asm lib/winapi/*.asm lib/debug/*.asm),\
		$(NASM) \
			$(NASM_FLAGS) \
			$(file) \
			-o $(addprefix $(TARGET_DIR)/,$(call path_to_name,$(file)).obj);\
	)


link: compile
	@$(LINKER) \
		$(LINKER_FLAGS) \
		$(wildcard $(TARGET_DIR)/*.obj) \
		-o $(TARGET_DIR)/$(EXECUTABLE_NAME)


build: link


run: build
	@target/$(EXECUTABLE_NAME)


$(TARGET_DIR):
	@mkdir $(TARGET_DIR)


clean:
	rm -rf $(TARGET_DIR)


define path_to_name
	$(subst .,_,$(subst /,_,$(1)))
endef