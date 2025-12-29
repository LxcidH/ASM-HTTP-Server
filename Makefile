all:
	mkdir build
	nasm -f elf64 src/main.asm -o build/main.o
	ld build/main.o -o NaServer

clean:
	rm -rf build
	rm NaServer
