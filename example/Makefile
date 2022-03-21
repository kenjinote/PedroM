CC=tigcc
CFLAGS=-O2 -fomit-frame-pointer -Wall
INCLUDES=-Iinclude
MV=mv -f
CP=cp -f

all: ex01 ex00 ex02

.c.o:
	$(CC) $(CFLAGS) $(INCLUDE) -c $<

ex02: ex02.c
	$(CC) $(CFLAGS) $(INCLUDES) $<
	$(CP) ex02.9xz ex02


ex01: ex01.c
	$(CC) $(CFLAGS) $(INCLUDES) $<
	$(CP) ex01.9xz ex01

ex00: ex00.c
	$(CC) $(CFLAGS) $(INCLUDES) $<
	$(CP) ex00.9xz ex00

clean:
	$(RM) *~ *.89z *.9xz *.v2z
	$(RM) ex01 ex00

