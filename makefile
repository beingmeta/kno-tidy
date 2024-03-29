KNOCONFIG         = knoconfig
KNOBUILD          = knobuild

prefix		::= $(shell ${KNOCONFIG} prefix)
libsuffix	::= $(shell ${KNOCONFIG} libsuffix)
CMODULES	::= $(DESTDIR)$(shell ${KNOCONFIG} cmodules)
LIBS		::= $(shell ${KNOCONFIG} libs)
LIB		::= $(shell ${KNOCONFIG} lib)
INCLUDE		::= $(shell ${KNOCONFIG} include)
KNO_VERSION	::= $(shell ${KNOCONFIG} version)
KNO_MAJOR	::= $(shell ${KNOCONFIG} major)
KNO_MINOR	::= $(shell ${KNOCONFIG} minor)
PKG_VERSION     ::= $(shell u8_gitversion ./etc/knomod_version)
PKG_MAJOR       ::= $(shell cat ./etc/knomod_version | cut -d. -f1)
FULL_VERSION    ::= ${KNO_MAJOR}.${KNO_MINOR}.${PKG_VERSION}
PATCHLEVEL      ::= $(shell u8_gitpatchcount ./etc/knomod_version)
PATCH_VERSION   ::= ${FULL_VERSION}-${PATCHLEVEL}

PKG_NAME	::= tidy
DPKG_NAME	::= ${PKG_NAME}_${PATCH_VERSION}

INIT_CFLAGS	::= ${CFLAGS}
INIT_LDFLAGS	::= ${LDFLAGS}
KNO_CFLAGS	::= -I. -fPIC $(shell ${KNOCONFIG} cflags)
KNO_LDFLAGS	::= -fPIC $(shell ${KNOCONFIG} ldflags)
KNO_LIBS	::= $(shell ${KNOCONFIG} libs)
SUDO            ::= $(shell which sudo)

CFLAGS		  = ${INIT_CFLAGS} ${KNO_CFLAGS}
LDFLAGS		  = ${INIT_LDFLAGS} ${KNO_LDFLAGS}
MKSO		  = $(CC) -shared $(LDFLAGS) $(LIBS)
MSG		  = echo
SYSINSTALL        = /usr/bin/install -c
MACLIBTOOL	  = $(CC) -dynamiclib -single_module -undefined dynamic_lookup \
			$(LDFLAGS)

GPGID           ::= ${OVERRIDE_GPGID:-FE1BC737F9F323D732AA26330620266BE5AFF294}
CODENAME	::= $(shell ${KNOCONFIG} codename)
REL_BRANCH	::= $(shell ${KNOBUILD} getbuildopt REL_BRANCH current)
REL_STATUS	::= $(shell ${KNOBUILD} getbuildopt REL_STATUS stable)
REL_PRIORITY	::= $(shell ${KNOBUILD} getbuildopt REL_PRIORITY medium)
ARCH            ::= $(shell ${KNOBUILD} getbuildopt BUILD_ARCH || uname -m)
APKREPO         ::= $(shell ${KNOBUILD} getbuildopt APKREPO /srv/repo/kno/apk)
APK_ARCH_DIR      = ${APKREPO}/staging/${ARCH}
RPMDIR            = dist

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

%.o: %.c
	@$(CC) $(CFLAGS) -D_FILEINFO="\"$(shell u8_fileinfo ./$< $(dirname $(pwd))/)\"" -o $@ -c $<
	@$(MSG) CC $@ $<

default build: ${PKG_NAME}.${libsuffix}

tidy.so: tidy.c $(TIDY_OBJECTS)
	@$(MKSO) $(CFLAGS) -o $@ tidy.c $(TIDY_OBJECTS)
	@$(MSG) MKSO  $@ $<
	@ln -sf $(@F) $(@D)/$(@F).${KNO_MAJOR}
tidy.dylib: tidy.c $(TIDY_OBJECTS)
	@$(MACLIBTOOL) -install_name \
		`basename $(@F) .dylib`.${KNO_MAJOR}.dylib \
		${CFLAGS} -o $@ $(DYLIB_FLAGS) \
		tidy.c $(TIDY_OBJECTS)
	@$(MSG) MACLIBTOOL  $@ $<

TAGS: tidy.c tidy5/*.c tidy5/*.h
	etags -o TAGS tidy.c tidy5/*.c tidy5/*.h

${CMODULES}:
	install -d $@

install: build ${CMODULES}
	${SUDO} u8_install_shared ${PKG_NAME}.${libsuffix} ${CMODULES} ${FULL_VERSION} "${SYSINSTALL}"

clean:
	rm -f *.o ${PKG_NAME}/*.o *.${libsuffix}
fresh:
	make clean
	make default

gitup gitup-trunk:
	git checkout trunk && git pull

# Debian packaging

DEBFILES=changelog.base control.base compat copyright dirs docs install

debian: dist/debian/compat dist/debian/control.base dist/debian/changelog.base
	rm -rf debian
	cp -r dist/debian debian
	cd debian; chmod a-x ${DEBFILES}

debian/compat: dist/debian/compat
	rm -rf debian
	cp -r dist/debian debian

debian/changelog: debian/compat dist/debian/changelog.base
	cat dist/debian/changelog.base | \
		u8_debchangelog kno-${PKG_NAME} ${CODENAME} ${PATCH_VERSION} \
			${REL_BRANCH} ${REL_STATUS} ${REL_PRIORITY} \
	    > $@.tmp
	if test ! -f debian/changelog; then \
	  mv debian/changelog.tmp debian/changelog; \
	elif diff debian/changelog debian/changelog.tmp 2>&1 > /dev/null; then \
	  mv debian/changelog.tmp debian/changelog; \
	else rm debian/changelog.tmp; fi
debian/control: debian/compat dist/debian/control.base
	u8_xsubst debian/control dist/debian/control.base "KNO_MAJOR" "${KNO_MAJOR}"

dist/debian.built: makefile debian/changelog debian/control
	dpkg-buildpackage -sa -us -uc -b -rfakeroot && \
	touch $@

dist/debian.signed: dist/debian.built
	@if test "${GPGID}" = "none" || test -z "${GPGID}"; then  	\
	  echo "Skipping debian signing";				\
	  touch $@;							\
	else 								\
	  echo debsign --re-sign -k${GPGID} ../kno-${PKG_NAME}_*.changes;	\
	  debsign --re-sign -k${GPGID} ../kno-${PKG_NAME}_*.changes && 	\
	  touch $@;							\
	fi;

deb debs dpkg dpkgs: dist/debian.signed

debfresh: clean debclean
	rm -rf debian
	make dist/debian.signed

debinstall: dist/debian.signed
	${SUDO} dpkg -i ../kno-${PKG_NAME}_*.deb

debclean: clean
	rm -rf ../kno-${PKG_NAME}-* debian dist/debian.*

# RPM packaging

dist/kno-${PKG_NAME}.spec: dist/kno-${PKG_NAME}.spec.in makefile
	u8_xsubst dist/kno-${PKG_NAME}.spec dist/kno-${PKG_NAME}.spec.in \
		"VERSION" "${FULL_VERSION}" \
		"PKG_NAME" "${PKG_NAME}" && \
	touch $@
kno-${PKG_NAME}.tar: dist/kno-${PKG_NAME}.spec
	git archive -o $@ --prefix=kno-${PKG_NAME}-${FULL_VERSION}/ HEAD
	tar -f $@ -r dist/kno-${PKG_NAME}.spec

dist/rpms.ready: kno-${PKG_NAME}.tar
	rpmbuild $(RPMFLAGS)  			\
	   --define="_rpmdir $(RPMDIR)"			\
	   --define="_srcrpmdir $(RPMDIR)" 		\
	   --nodeps -ta 				\
	    kno-${PKG_NAME}.tar && 	\
	touch dist/rpms.ready
dist/rpms.done: dist/rpms.ready
	@if (test "$(GPGID)" = "none" || test "$(GPGID)" = "" ); then 			\
	    touch dist/rpms.done;				\
	else 						\
	     echo "Enter passphrase for '$(GPGID)':"; 		\
	     rpm --addsign --define="_gpg_name $(GPGID)" 	\
		--define="__gpg_sign_cmd $(RPMGPG)"		\
		$(RPMDIR)/kno-${PKG_NAME}-${FULL_VERSION}*.src.rpm 		\
		$(RPMDIR)/*/kno*-@KNO_VERSION@-*.rpm; 	\
	fi && touch dist/rpms.done;
	@ls -l $(RPMDIR)/kno-${PKG_NAME}-${FULL_VERSION}-*.src.rpm \
		$(RPMDIR)/*/kno*-${FULL_VERSION}-*.rpm;

rpms: dist/rpms.done

cleanrpms:
	rm -rf dist/rpms.done dist/rpms.ready kno-${PKG_NAME}.tar dist/kno-${PKG_NAME}.spec

rpmupdate update-rpms freshrpms: cleanrpms
	make cleanrpms
	make -s dist/rpms.done

dist/rpms.installed: dist/rpms.done
	sudo rpm -Uvh ${RPMDIR}/*.rpm && sudo rpm -Uvh ${RPMDIR}/${ARCH}/*.rpm && touch $@

installrpms install-rpms: dist/rpms.installed

# Alpine packaging

staging/alpine:
	@install -d $@

staging/alpine/APKBUILD: dist/alpine/APKBUILD staging/alpine
	cp dist/alpine/APKBUILD staging/alpine

staging/alpine/kno-${PKG_NAME}.tar: staging/alpine
	git archive --prefix=kno-${PKG_NAME}/ -o staging/alpine/kno-${PKG_NAME}.tar HEAD

dist/alpine.setup: staging/alpine/APKBUILD makefile ${STATICLIBS} \
	staging/alpine/kno-${PKG_NAME}.tar
	if [ ! -d ${APK_ARCH_DIR} ]; then mkdir -p ${APK_ARCH_DIR}; fi && \
	( cd staging/alpine; \
		abuild -P ${APKREPO} clean cleancache cleanpkg && \
		abuild checksum ) && \
	touch $@

dist/alpine.done: dist/alpine.setup
	cd staging/alpine; abuild -P ${APKREPO}
dist/alpine.installed: dist/alpine.setup
	cd staging/alpine; apk add --repository=${APKREPO}/staging kno-${PKG_NAME}


alpine: dist/alpine.done
install-alpine: dist/alpine.done

.PHONY: alpine

