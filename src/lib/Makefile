# Recursive Make
CC=../../bin/titigcc $(LDFLAGS)
CFLAGS=-O2 -fomit-frame-pointer --cut-ranges --optimize-code  --remove-unused --optimize-relocs --merge-constants
INCLUDES=-I. -Igmp -Igmp/tests -Impfr -Impfr/tests

# Compile
%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -DPEDROM -c $< -o $@

# Define the targets which are always to be done.
.PHONY: clean

# Define the default target
all: t-ihm.o

# Extract archives
gmp: gmp-*.tar.bz2
	tar jxf gmp-*.tar.bz2
	mv $$(for i in gmp-* ; do test -d $$i && echo $$i ; done) gmp
	cd gmp && patch -p0 < ../diff-gmp.txt
mpfr: mpfr-*.tar.bz2
	tar jxf mpfr-*.tar.bz2
	mv $$(for i in mpfr-* ; do test -d $$i && echo $$i ; done) mpfr
	cd mpfr && patch -p0 < ../diff-mpfr.txt
may: may-*.tar.bz2
	tar jxf may-*.tar.bz2
	mv $$(for i in may-* ; do test -d $$i && echo $$i ; done) may
	cd may && patch < ../diff-may.txt

# Build libraries
libgmp.a: gmp
	cd gmp && export CFLAGS="$(CFLAGS)" && $(PWD)/../../bin/ticonfigure --disable-fft
	cd gmp && make
	cp gmp/.libs/libgmp.a .
libmpfr.a: gmp mpfr libgmp.a
	cd mpfr && export CFLAGS="$(CFLAGS)" && $(PWD)/../../bin/ticonfigure --with-gmp-build=$(PWD)/gmp
	cd mpfr && make
	cp mpfr/.libs/libmpfr.a .
include:
	mkdir include
gmp.h: libgmp.a include
	cp gmp/gmp.h include
mpfr.h: libmpfr.a include
	cp mpfr/mpfr.h include

libmay.a: may gmp mpfr libgmp.a libmpfr.a gmp.h mpfr.h
	cd may && make libmay.a CC=$(PWD)/../../bin/titigcc CFLAGS="$(CFLAGS)" GMP=$(PWD) AR="$(TIGCC)/bin/ar-tigcc -o"  RANLIB=echo
	cp may/libmay.a .

libtests-gmp.a: libgmp.a
	cd gmp/tests && make libtests.la
	cp gmp/tests/.libs/libtests.a libtests-gmp.a
libtests-mpfr.a: libmpfr.a
	cd mpfr/tests && make libfrtests.la
	cp mpfr/tests/.libs/libfrtests.a libtests-mpfr.a

# Main program:
t-pika.o: libmay.a
	cd may && make t-pika.o CC=$(PWD)/../../bin/titigcc CFLAGS="$(CFLAGS)" GMP=$(PWD)
	cp may/t-pika.o .
t-ihm.o: libmay.a
	cd may && make t-ihm.o CC=$(PWD)/../../bin/titigcc CFLAGS="$(CFLAGS)" GMP=$(PWD)
	cp may/t-ihm.o .

# Tests Program
test-gmp.o: test-gmp.c libmay.a libtests-gmp.a
test-mpfr.o: test-mpfr.c libmay.a libtests-mpfr.a

tst-ieee754.o: tst-ieee754.c

# Clean
clean:
	rm -rf gmp mpfr may include
	rm -f *.a *.o *~
