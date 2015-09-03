
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
	../include/cachedmeasure.hpp
EXAMPLES := $(SOURCES:%.cpp=%.example) $(SOURCES:%.hpp=%.example) 

chunkedseq.html5: chunkedseq.md $(EXAMPLES)
	pandoc --filter includes.hs chunkedseq.md --toc --number-sections -s -c chunkedseq.css -o chunkedseq.html5

clean:
	rm -rf chunkedseq.html5 ../examples/*.example.* ../include/*.example.* ../examples/*.example ../include/*.example
