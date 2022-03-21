all: flashos.a

flashos.a: _flash_os_header.s
	tigcc -c _flash_os_header.s -o _flash_os_header.o
	ar-tigcc -o flashos.a _flash_os_header.o

clean:
	rm -f *.o *.a *~
