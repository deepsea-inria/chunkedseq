
%.example: %.cpp
	./extract_snippets.sh $< $@

%.example: %.hpp
	./extract_snippets.sh $< $@

BUILDDIR := snippets
SOURCEDIR := ../examples/
SOURCES := $(shell find $(SOURCEDIR) -name '*.cpp') \
	../include/measure.hpp \
	../include/fixedcapacitybase.hpp \
	../examples/map.hpp \
	../include/segment.hpp \
	../include/algebra.hpp \
	../examples/map_1.cpp \
	../include/cachedmeasure.hpp
EXAMPLES := $(SOURCES:%.cpp=%.example) $(SOURCES:%.hpp=%.example)

build: chunkedseq.html5 chunkedseq.pdf

chunkedseq.html: chunkedseq.md $(EXAMPLES)
	pandoc --filter includes.hs chunkedseq.md --toc --number-sections -s -c chunkedseq.css -o chunkedseq.html

chunkedseq.pdf: chunkedseq.md $(EXAMPLES)
	pandoc --filter includes.hs chunkedseq.md --toc --number-sections -s -o chunkedseq.pdf

WEB=~/Work/deepsea-web/chunkedseq/

publish: chunkedseq.html5 chunkedseq.pdf
	cp chunkedseq.html chunkedseq.pdf chunkedseq.css $(WEB)/doc
	(cd $(WEB) && make publish)

clean_examples:
	rm -f ../examples/*.example.* ../include/*.example.* ../examples/*.example ../include/*.example 

clean: clean_examples
	rm -f chunkedseq.html5 chunkedseq.pdf 
