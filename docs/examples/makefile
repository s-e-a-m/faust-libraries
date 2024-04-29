SVGFILES := $(wildcard *.svg)

all: $(SVGFILES:%.svg=%.pdf)

%.pdf : %.svg
        inkscape -A $*.pdf $*.svg
