# SEAM library documentation generator (mirrors grame-cncm/faustlibraries/doc)
SEAMLIB ?= ../src
BUILD   ?= build
AWK     ?= gawk   # gensub() in faustlib2md.awk is a gawk extension (BSD awk fails)

# Active libraries = uncommented `xx = library("seam.NAME.lib")` lines in seam.lib
SRC := $(shell grep -oE '^[a-z][a-z]* = library\("seam\.[a-z]+\.lib"\)' $(SEAMLIB)/seam.lib \
         | sed -E 's/.*"(seam\.[a-z]+\.lib)".*/\1/')
MD  := $(SRC:%.lib=$(BUILD)/%.md)

.PHONY: md svg doc index list clean
md: $(MD)

$(BUILD)/%.md: $(SEAMLIB)/%.lib
	@mkdir -p $(BUILD)
	@echo "  building $<"
	@cat $< | $(AWK) -f scripts/faustlib2md.awk > $@

svg: md
	@for f in $(BUILD)/*.md; do python3 scripts/svg-embed.py $$f -I $(SEAMLIB); done

doc: md svg

index: $(BUILD)/index.md
$(BUILD)/index.md: $(MD)
	@$(AWK) -f scripts/makeindex.awk $(BUILD)/*.md > $@

list:
	@echo $(SRC)

clean:
	rm -rf $(BUILD)
