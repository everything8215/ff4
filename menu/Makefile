
NAME = menu
OBJ_DIR = obj
TARGET = $(OBJ_DIR)/$(NAME)_$(VERSION_EXT).o

SRC_MAIN = $(NAME).asm
SRC_FILES = $(wildcard *.asm)
INC_DIR = ../include
INC_FILES = $(wildcard $(INC_DIR)/*.inc)
DATA_FILES = $(wildcard data/*)
GFX_FILES = $(wildcard gfx/*)
TEXT_FILES = $(wildcard text/*)
TOOLS_DIR = ../tools

ENCODE_MENU_TEXT = $(TOOLS_DIR)/encode_menu_text.js

.PHONY: all clean

# disable default suffix rules
.SUFFIXES:

LANG_SUFFIX = $(shell echo $(VERSION_EXT) | head -c 2)

MENU_TEXT_JSON = $(INC_DIR)/menu_text_$(LANG_SUFFIX).json
MENU_TEXT_INC = text/menu_text_$(LANG_SUFFIX).inc

all: $(MENU_TEXT_INC) $(TARGET)

clean:
	$(RM) -r $(OBJ_DIR) data gfx text

$(TARGET): $(SRC_FILES) $(INC_FILES) $(DATA_FILES) $(GFX_FILES) $(TEXT_FILES)
	@mkdir -p $(OBJ_DIR)
	$(ASM) $(ASMFLAGS) -I $(INC_DIR) -l $(@:o=lst) $(SRC_MAIN) -o $@

text/menu_text_%.inc: $(INC_DIR)/menu_text_%.json
	node $(ENCODE_MENU_TEXT) $(LANG_SUFFIX)
