VERSION=0.83

# Make the tools, build the TIB, and sign them if there are any key to use.
all:
	cd bin && make
	cd src && make CAS=1
	ls bin/keys/0*.key 2> /dev/null >/dev/null && cd bin/keys && for i in ../../*.tib ; do ../rabbitsign -r $$i ; done && cd ../../ && rm -f *.tib

clean:
	cd bin && make clean
	cd src && make clean
	rm -f *~
	cd doc && rm -f *~
	cd example && make clean

dist: clean
	cd .. && 7zr a -mx9 '-xr!*.o' '-xr!.git' '-xr!*~' '-xr!*.7z'  '-xr!*.key' pedrom-$(VERSION).7z pedrom/ && mv pedrom-$(VERSION).7z pedrom
