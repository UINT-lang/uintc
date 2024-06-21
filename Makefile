all: build/uintc

clean:
	rm -f build/uintc build/*.cpp build/*.hpp

test: all
	tests/run.sh

.PHONY: all clean test

build/uintc: build/scanner.cpp build/scanner.hpp build/parser.cpp build/parser.hpp Makefile
	g++ -O2 -Ibuild -o build/uintc build/scanner.cpp build/parser.cpp

build/scanner.cpp build/scanner.hpp: src/scanner.l Makefile
	flex -o build/scanner.cpp --header-file=build/scanner.hpp src/scanner.l

build/parser.cpp build/parser.hpp: src/parser.y Makefile
	bison -d -Wcounterexamples -o build/parser.cpp src/parser.y
