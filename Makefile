TARGET_DIR = target
EXECUTABLE_NAME = tetris.exe

SASM_PATH = "D:/Program Files (x86)/SASM"
NASM = $(SASM_PATH)/NASM/nasm.exe
NASM_FLAGS = --gprefix _ -f win32

LINKER = $(SASM_PATH)/MinGW/bin/gcc.exe
LINKER_FLAGS = -g -m32
ADDITIONAL_LIBRARIES = Gdi32
ADDITIONAL_LINK_DIRECTORIES = lib/winapi


compile: $(TARGET_DIR)
	@$(foreach \
		file,\
		$(wildcard src/*.asm lib/*.asm lib/winapi/*.asm lib/debug/*.asm),\
		$(shell $(NASM) \
			$(NASM_FLAGS) \
			$(file) \
			-o $(addprefix $(TARGET_DIR)/,$(call path_to_name,$(file)).obj))\
	)


link: compile
	@$(LINKER) \
		$(LINKER_FLAGS) \
		$(wildcard $(TARGET_DIR)/*.obj) \
		$(foreach lib, $(ADDITIONAL_LIBRARIES), -l$(lib)) \
		$(foreach dir, $(ADDITIONAL_LINK_DIRECTORIES), -L$(dir)) \
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