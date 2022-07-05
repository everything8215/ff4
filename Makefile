
# exported variables used by module makefiles
export ASM = ca65
export ASMFLAGS =
export VERSION_EXT

# the linker
LINK = ld65
LINKFLAGS =

# list of ROM versions
VERSIONS = ff4-jp ff4-jp1 ff4-en ff4-en1 #ff4-jpez
ROM_DIR = rom
ROMS = $(foreach V, $(VERSIONS), $(ROM_DIR)/$(V).sfc)

# list of modules
MODULES = field menu btlgfx battle sound cutscene

.PHONY: all rip encode-jp encode-en clean $(VERSIONS) $(MODULES)

# disable default suffix rules
.SUFFIXES:

# make all versions
all: $(VERSIONS)

# rip data from ROMs
rip:
	node tools/decode-ff4.js

encode-jp: ff4-jp-data.json
	node tools/encode-ff4.js ff4-jp-data.json

encode-en: ff4-en-data.json
	node tools/encode-ff4.js ff4-en-data.json

# clean module subdirectories
MODULES_CLEAN = $(foreach M, $(MODULES), $(M)_clean)

%_clean:
	$(MAKE) -C $* clean

clean: $(MODULES_CLEAN)
	$(RM) -r $(ROM_DIR)

# ROM filenames
FF4_JP_PATH = $(ROM_DIR)/ff4-jp.sfc
FF4_JP1_PATH = $(ROM_DIR)/ff4-jp1.sfc
FF4_EN_PATH = $(ROM_DIR)/ff4-en.sfc
FF4_EN1_PATH = $(ROM_DIR)/ff4-en1.sfc
FF4_JPEZ_PATH = $(ROM_DIR)/ff4-jpez.sfc

ff4-jp: $(FF4_JP_PATH)
ff4-jp1: $(FF4_JP1_PATH)
ff4-en: $(FF4_EN_PATH)
ff4-en1: $(FF4_EN1_PATH)
ff4-jpez: $(FF4_JPEZ_PATH)

# set up target-specific variables
ff4-jp: VERSION_EXT = jp
ff4-jp: ASMFLAGS += -D ROM_VERSION=0

ff4-jp1: VERSION_EXT = jp1
ff4-jp1: ASMFLAGS += -D BUGFIX_WORLD_BATTLE=1 -D ROM_VERSION=1

ff4-en: VERSION_EXT = en
ff4-en: ASMFLAGS += -D LANG_EN=1 -D ROM_VERSION=0 -D SIMPLE_CONFIG=1 \
	-D BUGFIX_WORLD_BATTLE=1 -D BUGFIX_SYLPH_EFFECT=1

ff4-en1: VERSION_EXT = en1
ff4-en1: ASMFLAGS += -D LANG_EN=1 -D BUGFIX_REV1=1 -D ROM_VERSION=1 \
	-D SIMPLE_CONFIG=1 -D BUGFIX_WORLD_BATTLE=1 -D BUGFIX_SYLPH_EFFECT=1

ff4-jpez: VERSION_EXT = jpez
ff4-jpez: ASMFLAGS += -D ROM_VERSION=0 -D BUGFIX_WORLD_BATTLE=1 \
	-D EASY_VERSION=1 -D BUGFIX_REV1=1

# target-specific object filenames
OBJ_FILES_JP = $(foreach M, $(MODULES), $(M)/obj/$(M)_jp.o)
OBJ_FILES_JP1 = $(foreach M, $(MODULES), $(M)/obj/$(M)_jp1.o)
OBJ_FILES_EN = $(foreach M, $(MODULES), $(M)/obj/$(M)_en.o)
OBJ_FILES_EN1 = $(foreach M, $(MODULES), $(M)/obj/$(M)_en1.o)
OBJ_FILES_JPEZ = $(foreach M, $(MODULES), $(M)/obj/$(M)_jpez.o)

# rules for making ROM files
$(FF4_JP_PATH): ff4-jp.lnk encode-jp $(OBJ_FILES_JP)
	@mkdir -p rom
	$(LINK) $(LINKFLAGS) -m $(@:sfc=map) -o $@ -C $< $(OBJ_FILES_JP)
	node tools/calc-checksum.js $@

$(FF4_JP1_PATH): ff4-jp.lnk encode-jp $(OBJ_FILES_JP1)
	@mkdir -p rom
	$(LINK) $(LINKFLAGS) -m $(@:sfc=map) -o $@ -C $< $(OBJ_FILES_JP1)
	node tools/calc-checksum.js $@

$(FF4_EN_PATH): ff4-en.lnk encode-en $(OBJ_FILES_EN)
	@mkdir -p rom
	$(LINK) $(LINKFLAGS) -m $(@:sfc=map) -o $@ -C $< $(OBJ_FILES_EN)
	node tools/calc-checksum.js $@

$(FF4_EN1_PATH): ff4-en.lnk encode-en $(OBJ_FILES_EN1)
	@mkdir -p rom
	$(LINK) $(LINKFLAGS) -m $(@:sfc=map) -o $@ -C $< $(OBJ_FILES_EN1)
	node tools/calc-checksum.js $@

$(FF4_JPEZ_PATH): ff4-jp.lnk encode-jp $(OBJ_FILES_JPEZ)
	@mkdir -p rom
	$(LINK) $(LINKFLAGS) -m $(@:sfc=map) -o $@ -C $< $(OBJ_FILES_JPEZ)
	node tools/calc-checksum.js $@

# run sub-make to create object files for each module
$(OBJ_FILES_JP): $(MODULES)
$(OBJ_FILES_JP1): $(MODULES)
$(OBJ_FILES_EN): $(MODULES)
$(OBJ_FILES_EN1): $(MODULES)
$(OBJ_FILES_JPEZ): $(MODULES)

# rules for making modules in subdirectories
define MAKE_MODULE
$1/obj/$1_%.o:
	$$(MAKE) -C $1
endef

$(foreach M, $(MODULES), $(eval $(call MAKE_MODULE,$(M))))
