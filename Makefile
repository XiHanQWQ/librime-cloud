.PHONY: all linux win32 macos clean purge

ARCH = $(shell uname -m)

all: linux win32

linux:
	$(MAKE) -C lib clean simplehttp.so iconv.so
	rm -rf out-linux && mkdir out-linux && cp lib/simplehttp.so lib/iconv.so out-linux
	tar czvf linux-$(ARCH)-lua5.4.tar.gz out-linux scripts README.md

win32:
	$(MAKE) -C lib clean simplehttp.dll simplehttpx64.dll iconv.dll iconvx64.dll
	rm -rf out-mingw && mkdir out-mingw && cp lib/simplehttp.dll lib/iconv.dll out-mingw
	rm -rf out-mingw64 && mkdir out-mingw64 && cp lib/simplehttpx64.dll out-mingw64/simplehttp.dll && cp lib/iconvx64.dll out-mingw64/iconv.dll
	zip -r win32-lua5.4.zip out-mingw out-mingw64 scripts README.md

macos:
	$(MAKE) -C lib PLAT=macos clean simplehttp.so iconv.so
	rm -rf out-macos && mkdir out-macos && cp lib/simplehttp.so lib/iconv.so out-macos
	tar czvf macos-$(ARCH)-lua5.4.tar.gz out-macos scripts README.md

clean:
	rm -rf out-linux out-macos out-mingw out-mingw64
	rm -f linux-*.tar.gz macos-*.tar.gz win32-*.zip

purge: clean
	$(MAKE) -C lib purge
