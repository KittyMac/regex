config ?= release

PACKAGE := regex
COMPILE_WITH := ponyc

BUILD_DIR ?= build/$(config)
SRC_DIR ?= $(PACKAGE)
tests_binary := $(BUILD_DIR)/$(PACKAGE)
docs_dir := build/$(PACKAGE)-docs
lib_dir=./lib

ifdef config
	ifeq (,$(filter $(config),debug release))
		$(error Unknown configuration "$(config)")
	endif
endif

ifeq ($(config),release)
	PONYC = ${COMPILE_WITH}
else
	PONYC = ${COMPILE_WITH} --debug
endif

SOURCE_FILES := $(shell find $(SRC_DIR) -name \*.pony)

test: unit-tests build-examples

unit-tests: $(tests_binary)
	$^ --exclude=integration --sequential

$(tests_binary): $(GEN_FILES) $(SOURCE_FILES) | $(BUILD_DIR)
	${PONYC} -o ${BUILD_DIR} $(SRC_DIR)

build-examples:
	find examples/*/* -name '*.pony' -print | xargs -n 1 dirname  | sort -u | grep -v ffi- | xargs -n 1 -I {} ${PONYC} -s --checktree -o ${BUILD_DIR} {}

clean:
	rm -rf $(BUILD_DIR)

realclean:
	rm -rf build

$(docs_dir): $(GEN_FILES) $(SOURCE_FILES)
	rm -rf $(docs_dir)
	${PONYC} --docs-public --pass=docs --output build $(SRC_DIR)

docs: $(docs_dir)
	
copy-libs:
	@mkdir -p $(lib_dir)
	@cp ./libpcre2/ios/prefix/iphone-build/lib/libpcre2-8.a $(lib_dir)/libpcre2-8-ios.a
	@cp ./libpcre2/ios/prefix/macosx-build/lib/libpcre2-8.a $(lib_dir)/libpcre2-8-osx.a

TAGS:
	ctags --recurse=yes $(SRC_DIR)

all: test copy-libs

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

.PHONY: all clean realclean TAGS test
