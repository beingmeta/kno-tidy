KNOCONFIG         = knoconfig
KNOBUILD          = knobuild

prefix		::= $(shell ${KNOCONFIG} prefix)
libsuffix	::= $(shell ${KNOCONFIG} libsuffix)
KNO_CFLAGS	::= -I. -fPIC $(shell ${KNOCONFIG} cflags)
KNO_LDFLAGS	::= -fPIC $(shell ${KNOCONFIG} ldflags)
INIT_CFLAGS	::= ${CFLAGS}
INIT_LDFLAGS	::= ${LDFLAGS}
CMODULES	::= $(DESTDIR)$(shell ${KNOCONFIG} cmodules)
LIBS		::= $(shell ${KNOCONFIG} libs)
LIB		::= $(shell ${KNOCONFIG} lib)
INCLUDE		::= $(shell ${KNOCONFIG} include)
KNO_VERSION	::= $(shell ${KNOCONFIG} version)
KNO_MAJOR	::= $(shell ${KNOCONFIG} major)
KNO_MINOR	::= $(shell ${KNOCONFIG} minor)
PKG_RELEASE	::= $(cat ./etc/release)
DPKG_NAME	::= $(shell ./etc/dpkgname)
SUDO            ::= $(shell which sudo)

CFLAGS		  = ${INIT_CFLAGS} ${KNO_CFLAGS}
LDFLAGS		  = ${INIT_LDFLAGS} ${KNO_LDFLAGS}
MKSO		  = $(CC) -shared $(LDFLAGS) $(LIBS)
MSG		  = echo
SYSINSTALL        = /usr/bin/install -c

PKG_NAME	::= tidy
GPGID             = FE1BC737F9F323D732AA26330620266BE5AFF294
PKG_VERSION	  = ${KNO_MAJOR}.${KNO_MINOR}.${PKG_RELEASE}
PKG_RELEASE     ::= $(shell cat etc/release)
CODENAME	::= $(shell ${KNOCONFIG} codename)
RELSTATUS	::= $(shell ${KNOBUILD} getbuildopt BUILDSTATUS stable)
ARCH            ::= $(shell ${KNOBUILD} getbuildopt BUILD_ARCH || uname -m)
APKREPO         ::= $(shell ${KNOBUILD} getbuildopt APKREPO /srv/repo/kno/apk)
APK_ARCH_DIR      = ${APKREPO}/staging/${ARCH}

TIDY_OBJECTS=\
	tidy5/access.o 	\
	tidy5/alloc.o 	\
	tidy5/attrask.o 	\
	tidy5/attrdict.o 	\
	tidy5/attrget.o 	\
	tidy5/attrs.o 	\
	tidy5/buffio.o 	\
	tidy5/charsets.o 	\
	tidy5/clean.o 	\
	tidy5/config.o 	\
	tidy5/entities.o 	\
	tidy5/fileio.o 	\
	tidy5/gdoc.o 	\
	tidy5/iconvtc.o 	\
	tidy5/istack.o 	\
	tidy5/language.o 	\
	tidy5/lexer.o 	\
	tidy5/mappedio.o 	\
	tidy5/message.o 	\
	tidy5/parser.o 	\
	tidy5/pprint.o 	\
	tidy5/sprtf.o 	\
	tidy5/streamio.o 	\
	tidy5/tagask.o 	\
	tidy5/tags.o 	\
	tidy5/tidylib.o 	\
	tidy5/tmbstr.o 	\
	tidy5/utf8.o 	\
	tidy5/win32tc.o

TIDY_H_FILES=\
	tidy5/access.h 	\
	tidy5/attrdict.h 	\
	tidy5/attrs.h 	\
	tidy5/buffio.h 	\
	tidy5/charsets.h 	\
	tidy5/clean.h 	\
	tidy5/config.h 	\
	tidy5/entities.h 	\
	tidy5/fileio.h 	\
	tidy5/forward.h 	\
	tidy5/gdoc.h 	\
	tidy5/iconvtc.h 	\
	tidy5/language_en_gb.h 	\
	tidy5/language_en.h 	\
	tidy5/language_es.h 	\
	tidy5/language_es_mx.h 	\
	tidy5/language_fr.h 	\
	tidy5/language.h 	\
	tidy5/language_zh_cn.h 	\
	tidy5/lexer.h 	\
	tidy5/mappedio.h 	\
	tidy5/message.h 	\
	tidy5/parser.h 	\
	tidy5/platform.h 	\
	tidy5/pprint.h 	\
	tidy5/sprtf.h 	\
	tidy5/streamio.h 	\
	tidy5/tags.h 	\
	tidy5/tidybuffio.h 	\
	tidy5/tidyenum.h 	\
	tidy5/tidy.h 	\
	tidy5/tidy-int.h 	\
	tidy5/tidyplatform.h 	\
	tidy5/tmbstr.h 	\
	tidy5/utf8.h 	\
	tidy5/version.h 	\
	tidy5/win32tc.h

default build: ${PKG_NAME}.${libsuffix}

tidy.so: tidy.c $(TIDY_OBJECTS)
	@$(MKSO) $(CFLAGS) -o $@ tidy.c $(TIDY_OBJECTS)
	@if test ! -z "${COPY_CMODS}"; then cp $@ ${COPY_CMODS}; fi;
	@$(MSG) MKSO  $@ $<
	@ln -sf $(@F) $(@D)/$(@F).${KNO_MAJOR}
tidy.dylib: tidy.c $(TIDY_OBJECTS)
	@$(MACLIBTOOL) -install_name \
		`basename $(@F) .dylib`.${KNO_MAJOR}.dylib \
		${CFLAGS} -o $@ $(DYLIB_FLAGS) \
		tidy.c $(TIDY_OBJECTS)
	@if test ! -z "${COPY_CMODS}"; then cp $@ ${COPY_CMODS}; fi;
	@$(MSG) MACLIBTOOL  $@ $<

TAGS: tidy.c tidy5/*.c tidy5/*.h
	etags -o TAGS tidy.c tidy5/*.c tidy5/*.h

${CMODULES}:
	install -d $@

install: build ${CMODULES}
	@${SUDO} ${SYSINSTALL} ${PKG_NAME}.${libsuffix} \
			${CMODULES}/${PKG_NAME}.so.${PKG_VERSION}
	@echo === Installed ${CMODULES}/${PKG_NAME}.so.${PKG_VERSION}
	@${SUDO} ln -sf ${PKG_NAME}.so.${PKG_VERSION} \
			${CMODULES}/${PKG_NAME}.so.${KNO_MAJOR}.${KNO_MINOR}
	@echo === Linked ${CMODULES}/${PKG_NAME}.so.${KNO_MAJOR}.${KNO_MINOR} \
		to ${PKG_NAME}.so.${PKG_VERSION}
	@${SUDO} ln -sf ${PKG_NAME}.so.${PKG_VERSION} \
			${CMODULES}/${PKG_NAME}.so.${KNO_MAJOR}
	@echo === Linked ${CMODULES}/${PKG_NAME}.so.${KNO_MAJOR} \
		to ${PKG_NAME}.so.${PKG_VERSION}
	@${SUDO} ln -sf ${PKG_NAME}.so.${PKG_VERSION} ${CMODULES}/${PKG_NAME}.so
	@echo === Linked ${CMODULES}/${PKG_NAME}.so to ${PKG_NAME}.so.${PKG_VERSION}

clean:
	rm -f *.o ${PKG_NAME}/*.o *.${libsuffix}
fresh:
	make clean
	make default

gitup gitup-trunk:
	git checkout trunk && git pull

# Debian packaging

debian: tidy.c makefile \
	dist/debian/rules dist/debian/control \
	dist/debian/changelog.base
	rm -rf debian
	cp -r dist/debian debian

debian/changelog: debian tidy.c makefile
	cat debian/changelog.base | \
		knomod debchangelog kno-${PKG_NAME} ${CODENAME} ${RELSTATUS} > $@.tmp
	if test ! -f debian/changelog; then \
	  mv debian/changelog.tmp debian/changelog; \
	elif diff debian/changelog debian/changelog.tmp 2>&1 > /dev/null; then \
	  mv debian/changelog.tmp debian/changelog; \
	else rm debian/changelog.tmp; fi

dist/debian.built: tidy.c makefile debian debian/changelog
	dpkg-buildpackage -sa -us -uc -b && \
	touch $@

dist/debian.signed: dist/debian.built
	debsign --re-sign -k${GPGID} ../kno-tidy_*.changes && \
	touch $@

dist/debian.updated: dist/debian.signed
	dupload -c ./dist/dupload.conf --nomail --to bionic ../kno-tidy_*.changes && touch $@

deb debs dpkg dpkgs: dist/debian.signed

debinstall: dist/debian.signed
	sudo dpkg -i ../kno-tidy_${PKG_VERSION}*.deb

update-apt: dist/debian.updated

debclean: clean
	rm -rf ../kno-tidy_* ../kno-tidy-* debian dist/debian.*

debfresh:
	make debclean
	make dist/debian.signed

# Alpine packaging

staging/alpine:
	@install -d $@

staging/alpine/APKBUILD: dist/alpine/APKBUILD staging/alpine
	cp dist/alpine/APKBUILD staging/alpine

staging/alpine/kno-${PKG_NAME}.tar: staging/alpine
	git archive --prefix=kno-${PKG_NAME}/ -o staging/alpine/kno-${PKG_NAME}.tar HEAD

dist/alpine.done: staging/alpine/APKBUILD makefile \
	staging/alpine/kno-${PKG_NAME}.tar
	if [ ! -d ${APK_ARCH_DIR} ]; then mkdir -p ${APK_ARCH_DIR}; fi;
	cd staging/alpine; \
		abuild -P ${APKREPO} clean cleancache cleanpkg && \
		abuild checksum && \
		abuild -P ${APKREPO} && \
		touch ../../$@

alpine: dist/alpine.done

.PHONY: alpine

