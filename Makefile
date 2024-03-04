all: build/uintc

clean:
	rm -f build/uintc build/*.cpp build/*.hpp

.PHONY: all clean

build/uintc: build/scanner.cpp build/scanner.hpp build/parser.cpp build/parser.hpp
	g++ -Ibuild -o build/uintc build/scanner.cpp build/parser.cpp

build/scanner.cpp build/scanner.hpp: src/scanner.l
	flex -o build/scanner.cpp --header-file=build/scanner.hpp src/scanner.l

build/parser.cpp build/parser.hpp: src/parser.y
	bison -d -o build/parser.cpp src/parser.y
