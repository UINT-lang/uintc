all: build/uintc

clean:
	rm -f build/uintc build/*.cpp build/*.hpp

test: all
	tests/run.sh

.PHONY: all clean test

INCS = $(patsubst template/%,build/%.inc,$(wildcard template/*))

build/uintc: build/scanner.cpp build/scanner.hpp build/parser.cpp build/parser.hpp $(INCS) Makefile
	g++ -O2 -Ibuild -o build/uintc build/scanner.cpp build/parser.cpp

build/scanner.cpp build/scanner.hpp: src/scanner.l Makefile
	flex -o build/scanner.cpp --header-file=build/scanner.hpp src/scanner.l

build/parser.cpp build/parser.hpp: src/parser.y Makefile
	TIME_LIMIT=20 bison -d -Wcounterexamples -o build/parser.cpp src/parser.y

build/%.inc: template/% Makefile
	xxd -i template/$* > build/$*.inc
