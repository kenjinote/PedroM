RM=rm -f

all: strip ld-tigcc/ld-tigcc flashos/flashos.a rabbitsign

strip: strip.c
	cc -Os -fomit-frame-pointer -Wall strip.c -o strip$(EXEEXT)

ld-tigcc/ld-tigcc:
	cd ld-tigcc && make

rabbitsign:
	tar zxf rabbitsign.tar.gz && cd rabbitsign-* && ./configure && make && cp src/rabbitsign$(EXEEXT) ..

flashos/flashos.a:
	cd flashos && make

clean:
	$(RM) strip$(EXEEXT) *~
	cd ld-tigcc && make clean
	cd flashos && make clean
	$(RM) -rf rabbitsign-* rabbitsign$(EXEEXT)

