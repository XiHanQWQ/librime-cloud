CC = gcc
CC_mingw = i686-w64-mingw32-gcc
CC_mingw64 = x86_64-w64-mingw32-gcc

LUAV ?= 5.4
LUAINC = thirdparty/lua${LUAV}
LUALIB = -Llibrime-lua${LUAV}/dist/lib -lrime
LUALIB64 = -Llibrime-lua${LUAV}-x64/dist/lib -lrime

CURLV ?= 8.22.0
CURLINC = curl-${CURLV}/include
CURLLIB = -Lcurl-${CURLV}/build32/lib/.libs -lcurl -lsecur32 -lbcrypt -ladvapi32 -lcrypt32 -lws2_32 -liphlpapi
CURLLIB64 = -Lcurl-${CURLV}/build64/lib/.libs -lcurl -lsecur32 -lbcrypt -ladvapi32 -lcrypt32 -lws2_32 -liphlpapi

ICONV_V ?= 1.18
LUA_ICONV_V ?= 7.1.0
ICONV_INC = libiconv-${ICONV_V}/build32/include
ICONV_INC64 = libiconv-${ICONV_V}/build64/include
ICONV_LIB = -Llibiconv-${ICONV_V}/build32/lib/.libs -liconv
ICONV_LIB64 = -Llibiconv-${ICONV_V}/build64/lib/.libs -liconv

PLAT ?= linux
LDFLAGS_linux = -Wl,--gc-sections -Wl,-s
LDFLAGS_macos = -Wl,-bundle -Wl,-undefined,dynamic_lookup
LDFLAGS = ${LDFLAGS_${PLAT}}
MINGWLDFLAGS = -Wl,--gc-sections -Wl,-s -static-libgcc

RIME_X86_URL ?= https://github.com/rime/librime/releases/download/1.17.0/rime-33e7814-Windows-msvc-x86.7z
RIME_X64_URL ?= https://github.com/rime/librime/releases/download/1.17.0/rime-33e7814-Windows-msvc-x64.7z

-include DEPS.mk

.PHONY: all prepare update-deps clean purge

all: simplehttp.so simplehttp.dll simplehttpx64.dll iconv.so iconv.dll iconvx64.dll

update-deps:
	@set -e; \
	curlv=`curl -s https://api.github.com/repos/curl/curl/releases/latest | sed -n 's/.*"tag_name": *"curl-\([^"]*\)".*/\1/p' | tr _ .`; \
	rime=`curl -s https://api.github.com/repos/rime/librime/releases/latest`; \
	x86=`printf '%s' "$$rime" | sed -n 's/.*"browser_download_url": *"\([^"]*Windows-msvc-x86\.7z\)".*/\1/p'`; \
	x64=`printf '%s' "$$rime" | sed -n 's/.*"browser_download_url": *"\([^"]*Windows-msvc-x64\.7z\)".*/\1/p'`; \
	test -n "$$curlv" -a -n "$$x86" -a -n "$$x64" || { echo 'github api: failed to resolve latest releases'; exit 1; }; \
	printf 'CURLV = %s\nRIME_X86_URL = %s\nRIME_X64_URL = %s\n' "$$curlv" "$$x86" "$$x64" > DEPS.mk; \
	echo 'DEPS.mk updated (commit it for reproducible builds):'; cat DEPS.mk

librime-lua${LUAV}:
	curl -L -o rime-x86.7z ${RIME_X86_URL}
	7z x -olibrime-lua${LUAV} rime-x86.7z

librime-lua${LUAV}-x64:
	curl -L -o rime-x64.7z ${RIME_X64_URL}
	7z x -olibrime-lua${LUAV}-x64 rime-x64.7z

thirdparty:
	git clone -b thirdparty http://github.com/hchunhui/librime-lua.git thirdparty

curl-${CURLV}:
	curl -L -O https://curl.se/download/curl-${CURLV}.tar.gz
	tar xvf curl-${CURLV}.tar.gz

libiconv-${ICONV_V}:
	curl -L -O https://ftp.gnu.org/pub/gnu/libiconv/libiconv-${ICONV_V}.tar.gz
	tar xvf libiconv-${ICONV_V}.tar.gz

lua-iconv-${LUA_ICONV_V}:
	git clone -b v${LUA_ICONV_V} https://github.com/lunarmodules/lua-iconv.git lua-iconv-${LUA_ICONV_V}

prepare: librime-lua${LUAV} librime-lua${LUAV}-x64 thirdparty curl-${CURLV} lua-iconv-${LUA_ICONV_V}

curl-${CURLV}/build32/lib/.libs: curl-${CURLV}
	cd curl-${CURLV} && sh ../tinycurl.sh

curl-${CURLV}/build64/lib/.libs: curl-${CURLV}
	cd curl-${CURLV} && sh ../tinycurlx64.sh

libiconv-${ICONV_V}/build32/lib/.libs: libiconv-${ICONV_V}
	cd libiconv-${ICONV_V} && sh ../iconv.sh

libiconv-${ICONV_V}/build64/lib/.libs: libiconv-${ICONV_V}
	cd libiconv-${ICONV_V} && sh ../iconvx64.sh

simplehttp.so: main.c thirdparty curl-${CURLV}
	${CC} -I${LUAINC} -I${CURLINC} -Os -fPIC -shared ${LDFLAGS} -o $@ $<

simplehttp.dll: main.c librime-lua${LUAV} thirdparty curl-${CURLV}/build32/lib/.libs
	${CC_mingw} -I${LUAINC} -I${CURLINC} -Os -shared -o $@ $< ${MINGWLDFLAGS} ${LUALIB} ${CURLLIB}

simplehttpx64.dll: main.c librime-lua${LUAV}-x64 thirdparty curl-${CURLV}/build64/lib/.libs
	${CC_mingw64} -I${LUAINC} -I${CURLINC} -Os -shared -o $@ $< ${MINGWLDFLAGS} ${LUALIB64} ${CURLLIB64}

lua-iconv-${LUA_ICONV_V}/luaiconv.c: lua-iconv-${LUA_ICONV_V}

iconv.so: lua-iconv-${LUA_ICONV_V}/luaiconv.c
	${CC} -I${LUAINC} -Os -fPIC -shared ${LDFLAGS} -o $@ $<

iconv.dll: lua-iconv-${LUA_ICONV_V}/luaiconv.c librime-lua${LUAV} libiconv-${ICONV_V}/build32/lib/.libs
	${CC_mingw} -I${LUAINC} -I${ICONV_INC} -Os -shared -o $@ $< ${MINGWLDFLAGS} ${LUALIB} ${ICONV_LIB}

iconvx64.dll: lua-iconv-${LUA_ICONV_V}/luaiconv.c librime-lua${LUAV}-x64 libiconv-${ICONV_V}/build64/lib/.libs
	${CC_mingw64} -I${LUAINC} -I${ICONV_INC64} -Os -shared -o $@ $< ${MINGWLDFLAGS} ${LUALIB64} ${ICONV_LIB64}

clean:
	rm -f simplehttp.so simplehttp.dll simplehttpx64.dll iconv.so iconv.dll iconvx64.dll

purge: clean
	rm -rf lua-iconv-* curl-* libiconv-* librime-* thirdparty
	rm -rf *.zip *.tar.gz *.7z
