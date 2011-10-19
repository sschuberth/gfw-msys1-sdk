#! /bin/bash

name=openssl
ver=1.0.0e
dllver=100
rev=1
subsys=mingw32
srcname=${name}-${ver}
prefix=/mingw
openssldir=/var/ssl
enginedir=engines-1.0.0
reldoc=share/doc/${name}/${ver}
SOURCE_ARCHIVE_FORMAT=.tar.gz
SOURCE_ARCHIVE=${name}-${ver}${SOURCE_ARCHIVE_FORMAT}
preconf_patches=
docfiles="CHANGES \
CHANGES.SSLeay \
FAQ \
INSTALL \
LICENSE \
NEWS \
PROBLEMS \
README \
README.ASN1 \
README.ENGINE"
licfiles=

url=http://www.openssl.org/source/${SOURCE_ARCHIVE}
md5='7040b89c4c58c7a1016c0dfa6e821c86'

if test ! "$MSYSTEM" == "MSYS" -a "$subsys" == "msys"
then
  echo "You must be in an MSYS shell to build a msys package"
  exit 4
fi

if test ! "$MSYSTEM" == "MINGW32" -a "$subsys" == "mingw32"
then
  echo "You must be in an MINGW shell to build a mingw32 package"
  exit 5
fi

pkgbuilddir=`pwd` || fail $LINENO
echo Acting from the directory ${pkgbuilddir}

patchfiles=`for i in ${pkgbuilddir}/patches/*.${subsys}.patch ${pkgbuilddir}/patches/*.all.patch; do if test $(expr index "$i" "*") -ge 1; then : ;else echo $i; fi; done`

instdir=${pkgbuilddir}/inst
blddir=${pkgbuilddir}/bld
logdir=${pkgbuilddir}/logs
srcdir=${pkgbuilddir}/${name}-${ver}
echo The source directory is ${srcdir}

srcdirname=$(basename ${srcdir})

pkgtmp=${name}-${ver}-${rev}-${subsys}
BINPKG=${pkgtmp}-bin.tar.xz
DOCPKG=${pkgtmp}-doc.tar.xz
LICPKG=${pkgtmp}-lic.tar.xz
SRCPKG=${pkgtmp}-src.tar.xz
pkgtmp=lib${name}-${ver}-${rev}-${subsys}
DLLPKG=${pkgtmp}-dll-${dllver}.tar.xz
DEVPKG=${pkgtmp}-dev.tar.xz
BIN_CONTENTS='--exclude=bin/*.dll var/ssl bin'
DLL_CONTENTS="bin/*.dll lib/openssl/${enginedir}"
DEV_CONTENTS='include/openssl lib/lib*.a share/man/man3 lib/pkgconfig'
LIC_CONTENTS="${reldoc}/LICENSE"
DOC_CONTENTS="--exclude=${reldoc}/LICENSE share/doc/ share/man/man[157]"
SRC_CONTENTS="pkgbuild.sh \
${subsys}-${name}.RELEASE_NOTES \
patches \
Makefile.certificate \
make-dummy-cert \
${SOURCE_ARCHIVE}"

do_download=1
do_unpack=1
do_patch=1
do_preconfigure=0
do_reconfigure=0
do_configure=1
do_make=1
do_check=0
do_install=1
do_fixinstall=1
do_pack=1

zeroall() {
      do_download=0
      do_unpack=0
      do_patch=0
      do_preconfigure=0
      do_reconfigure=0
      do_configure=0
      do_make=0
      do_check=0
      do_install=0
      do_fixinstall=0
      do_pack=0
}

while [ $# -gt 0 ]
do
  case $1 in
    --download) do_download=1 ; shift 1 ;;
    --unpack) do_unpack=1 ; shift 1 ;;
    --patch) do_patch=1 ; shift 1 ;;
    --preconfigure) do_preconfigure=1 ; shift 1 ;;
    --reconfigure) do_reconfigure=1 ; shift 1 ;;
    --configure) do_configure=1 ; shift 1 ;;
    --make) do_make=1 ; shift 1 ;;
    --check) do_check=1 ; shift 1 ;;
    --install) do_install=1 ; shift 1 ;;
    --fixinstall) do_fixinstall=1 ; shift 1 ;;
    --pack) do_pack=1 ; shift 1 ;;
    --download-only) zeroall; do_download=1 ; shift 1 ;;
    --unpack-only) zeroall; do_unpack=1 ; shift 1 ;;
    --patch-only) zeroall; do_patch=1 ; shift 1 ;;
    --preconfigure-only) zeroall; do_preconfigure=1 ; shift 1 ;;
    --reconfigure-only) zeroall; do_reconfigure=1 ; shift 1 ;;
    --configure-only) zeroall; do_configure=1 ; shift 1 ;;
    --make-only) zeroall; do_make=1 ; shift 1 ;;
    --check-only) zeroall; do_check=1 ; shift 1 ;;
    --install-only) zeroall; do_install=1 ; shift 1 ;;
    --fixinstall-only) zeroall; do_fixinstall=1 ; shift 1 ;;
    --pack-only) zeroall; do_pack=1 ; shift 1 ;;
    *) shift 1 ;;
  esac
done


fail() {
  echo "failure at line $1"
  exit 1
}

capname=Unknown
if test "x${subsys}" == "xmingw32"
then
capname=MinGW
elif test "x${subsys}" == "xmsys"
then
capname=MSYS
fi

if test ! -d ${logdir}
then
  mkdir -p ${logdir} || fail $LINENO
fi

if test "x$do_download" == "x1"
then
  rm -f ${logdir}/download.log
  test -f ${pkgbuilddir}/${SOURCE_ARCHIVE} || {
    echo "Downloading ${SOURCE_ARCHIVE} ..." 2>&1 | tee ${logdir}/download.log
    wget -O ${pkgbuilddir}/${SOURCE_ARCHIVE} $url 2>&1 | tee -a ${logdir}/download.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  }

  echo "Verifying md5 sum ..." | tee -a ${logdir}/download.log
  echo "$md5 *${pkgbuilddir}/${SOURCE_ARCHIVE}" > ${SOURCE_ARCHIVE}.md5
  md5sum -c --status ${SOURCE_ARCHIVE}.md5 2>&1 | tee -a ${logdir}/download.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  rm ${SOURCE_ARCHIVE}.md5 2>&1 | tee -a ${logdir}/download.log
  echo "Done downloading"
fi

if test "x$do_unpack" == "x1"
then
  rm -f ${logdir}/unpack.log
  if test ! "x${srcdir}" == "x/" -a ! "x${srcdir}" == "x" -a ! "x${srcdir}" == "x${pkgbuilddir}"
  then
    echo "Deleting ${srcdir} contents" | tee ${logdir}/unpack.log
    rm -rf ${srcdir}/* 2>&1 | tee -a ${logdir}/unpack.log
  else
    echo "I think it is unsafe to delete ${srcdir}" | tee ${logdir}/unpack.log
    exit 2
  fi

  echo Cleaning up inst and build directories | tee -a ${logdir}/unpack.log
  rm -rf ${blddir} ${instdir} 2>&1 | tee -a ${logdir}/unpack.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi

  cd ${pkgbuilddir} && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi

  echo "Unpacking $SOURCE_ARCHIVE in `pwd`" | tee -a ${logdir}/unpack.log
  case "$SOURCE_ARCHIVE" in
  *.tar.bz2 ) tar xjf $SOURCE_ARCHIVE 2>&1 | tee -a ${logdir}/unpack.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi;;
  *.tar.gz  ) tar xzf $SOURCE_ARCHIVE 2>&1 | tee -a ${logdir}/unpack.log  && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi;;
  *.zip     ) unzip -q $SOURCE_ARCHIVE  2>&1 | tee -a ${logdir}/unpack.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi;;
  *.tar.lzma) tar --lzma -xf $SOURCE_ARCHIVE 2>&1 | tee -a ${logdir}/unpack.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi;;
  esac
  if test $(ls ${srcdir} -l | wc -l) -ge 2
  then
    echo "Unpacked into ${srcdir} successfully!" | tee -a ${logdir}/unpack.log
  else
    echo "${srcdir} is empty - didn't unpack into it?" | tee -a ${logdir}/unpack.log
    exit 3
  fi
  echo "Done unpacking"
fi

patch_list=
if test "x$do_patch" == "x1"
then
  rm -f ${logdir}/patch.log
  echo cd ${srcdir}
  cd ${srcdir} && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi

  if test ! "x${patchfiles}" == "x"
  then
    echo "Patching in `pwd` from patchfiles ${patchfiles}" | tee -a ${logdir}/patch.log
  fi
  for patchfile in ${patchfiles}
  do
    if test ! "x${patchfiles}" == "x"
    then
      echo "Applying ${patchfile}" | tee -a ${logdir}/patch.log
      patch -p1 -i ${patchfile} 2>&1 | tee -a ${logdir}/patch.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
    fi
    patch_list="$patch_list $patchfile"
  done
  echo "Done patching"
fi

if test "x$do_reconfigure" == "x1"
then
  cd ${srcdir}  && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi

  echo Reconfiguring in `pwd` | tee -a ${logdir}/reconfigure.log
  autoreconf -fi 2>&1 | tee -a ${logdir}/reconfigure.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
elif test "x$do_preconfigure" == "x1"
then
  cd ${srcdir}  && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi

  echo Patching in `pwd` from ${preconf_patches} | tee -a ${logdir}/reconfigure.log
  for patchfile in ${pkgbuilddir}/preconf-patches/*${subsys}.patch
  do
    patch -p1 -i ${patchfile} 2>&1 | tee -a ${logdir}/reconfigure.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  done
fi

mkdir -p ${blddir} || fail $LINENO

if test "x$do_configure" == "x1"
then
  cd ${blddir}  && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi

  lndir ${srcdir} . 2>&1 | tee -a ${logdir}/configure.log
  echo Configuring in `pwd` | tee -a ${logdir}/configure.log
  ${srcdir}/config --prefix=${prefix} --openssldir=${prefix}${openssldir} --enginesdir=${prefix}/lib/openssl/${enginedir} enable-zlib-dynamic enable-threads enable-shared 2>&1 | tee -a ${logdir}/configure.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
fi

if test "x$do_make" == "x1"
then
  rm -f ${logdir}/make.log
  cd ${blddir}  && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi

  echo Making
  make depend 2>&1 | tee -a ${logdir}/make.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  make all 2>&1 | tee -a ${logdir}/make.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  make rehash 2>&1 | tee -a ${logdir}/make.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
fi

if test "x$do_install" == "x1"
then
  rm -f ${logdir}/install.log
  cd ${blddir}  && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi

  echo Installing into ${instdir} from `pwd` | tee ${logdir}/install.log
  make install MANDIR=${prefix}/share/man MANSUFFIX=ssl INSTALL_PREFIX=${instdir} 2>&1 | tee -a ${logdir}/install.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
fi

if test "x$do_check" == "x1"
then
  rm -f ${logdir}/test.log
  cd ${blddir}  && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi

  echo "Testing" | tee -a ${logdir}/test.log
  OPENSSL_CONF=`cd ${instdir}${prefix}${openssldir}; pwd -W`/openssl.cnf make -k -C test apps tests 2>&1 | tee -a ${logdir}/test.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
fi


if test "x$do_fixinstall" == "x1"
then
  rm -f ${logdir}/fixinstall.log
  echo Fixing the installation | tee ${logdir}/fixinstall.log
  mkdir -p ${instdir}${prefix}/share/doc/${name}/${ver} 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  cd ${srcdir}  && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  #for f in ${docfiles} ${licfiles}
  #do
  #  if test -f ${instdir}${prefix}/share/doc/${name}/${ver}/$(basename ${f})
  #  then
  #    cp -r ${f} ${instdir}${prefix}/share/doc/${name}/${ver}/${f}
  #  else
  #    cp -r ${f} ${instdir}${prefix}/share/doc/${name}/${ver}/$(basename ${f})
  #  fi
  #done
  mkdir -p ${instdir}${prefix}/share/doc/${capname} 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  cp ${pkgbuilddir}/${subsys}-${name}.RELEASE_NOTES \
    ${instdir}${prefix}/share/doc/${capname}/${name}-${ver}-${rev}-${subsys}.RELEASE_NOTES.txt 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi

  /usr/bin/install -d -m 0755 ${instdir}${prefix}${openssldir}/certs 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  (cd certs; find . -type f | tar -cf - -T -) | tar -C ${instdir}${prefix}${openssldir}/certs -x -v -f -

  # make the rootcerts dir
  /usr/bin/install -d -m 0755 ${instdir}${prefix}${openssldir}/rootcerts 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi

  # Install a makefile for generating keys and self-signed certs, and a script
  # for generating them on the fly.
  /usr/bin/install -m 0644 ${pkgbuilddir}/Makefile.certificate ${instdir}${prefix}${openssldir}/certs/Makefile 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  /usr/bin/install -m 0755 ${pkgbuilddir}/make-dummy-cert ${instdir}${prefix}${openssldir}/certs/make-dummy-cert 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi

  # Pick a CA script.
  mv ${instdir}${prefix}${openssldir}/misc/CA.sh ${instdir}${prefix}${openssldir}/misc/CA 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  perl -p -e "s|^CATOP=.*|CATOP=${prefix}${openssldir}|g;s|\./demoCA|${prefix}${openssldir}|g" \
	< ${instdir}${prefix}${openssldir}/misc/CA \
	> ${instdir}${prefix}${openssldir}/misc/CA_ && \
  mv ${instdir}${prefix}${openssldir}/misc/CA_ ${instdir}${prefix}${openssldir}/misc/CA 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi

  perl -p -e "s|^\\\$CATOP\=\".*|\\\$CATOP\=\"${prefix}${openssldir}\";|g" \
	< ${instdir}${prefix}${openssldir}/misc/CA.pl \
	> ${instdir}${prefix}${openssldir}/misc/CA.pl_ && \
  mv ${instdir}${prefix}${openssldir}/misc/CA.pl_ ${instdir}${prefix}${openssldir}/misc/CA.pl 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi

  perl -p -e "s|\./demoCA|${prefix}${openssldir}|g" \
	< ${instdir}${prefix}${openssldir}/openssl.cnf \
	> ${instdir}${prefix}${openssldir}/openssl.cnf_ && \
  mv ${instdir}${prefix}${openssldir}/openssl.cnf_ ${instdir}${prefix}${openssldir}/openssl.cnf 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi

  #(rm -f ${instdir}${PREFIX}/share/info/dir 2>&1 || fail $LINENO) | tee -a ${logdir}/fixinstall.log

  mkdir -p ${instdir}${prefix}/${reldoc} 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  for f in $docfiles
  do
    cp -p ${srcdir}/$f ${instdir}${prefix}/${reldoc} 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  done
  chmod 0755 ${instdir}${prefix}/lib/openssl/${enginedir}/*dll 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  chmod 0755 ${instdir}${prefix}/bin/* 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  chmod 0644 ${instdir}${prefix}/lib/*.a 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  chmod 0755 ${instdir}${prefix}${openssldir}/misc/* 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  chmod 0644 ${instdir}${prefix}/share/man/man[1357]/* 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi

  chmod 0644 ${instdir}${prefix}${openssldir}/openssl.cnf 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  chmod 0755 ${instdir}${prefix}${openssldir}/certs 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  chmod 0755 ${instdir}${prefix}${openssldir}/rootcerts 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  chmod 0755 ${instdir}${prefix}${openssldir}/misc 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  chmod 0755 ${instdir}${prefix}${openssldir}/private 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi

  chmod 0644 ${instdir}${prefix}/lib/pkgconfig/openssl.pc 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  chmod 0644 ${instdir}${prefix}/include/openssl/* 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi

  mv ${instdir}${prefix}/share/man/man1/passwd.1ssl \
	${instdir}${prefix}/share/man/man1/openssl-passwd.1ssl 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  mv ${instdir}${prefix}/share/man/man1/rand.1ssl \
	${instdir}${prefix}/share/man/man1/openssl-rand.1ssl 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  mv ${instdir}${prefix}/share/man/man5/config.5ssl \
	${instdir}${prefix}/share/man/man5/openssl-config.5ssl 2>&1 | tee -a ${logdir}/fixinstall.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi

  # We 'tar' from ${instdir}/mingw, so as to move everything from
  # /mingw/* to /* in the tarball to comply with the package specs.
  # However, this means that ${instdir}/var will be missed. So:
  #verbose mv ${instdir}/var ${instdir}${prefix}/

fi

if test "x$do_pack" == "x1"
then
  rm -f ${logdir}/pack.log
  cd ${instdir}${prefix}  && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  echo Packing | tee -a ${logdir}/pack.log
  tar cv --xz --hard-dereference -f ${pkgbuilddir}/${BINPKG} ${BIN_CONTENTS} 2>&1 | tee -a ${logdir}/pack.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  tar cv --xz --hard-dereference -f ${pkgbuilddir}/${DLLPKG} ${DLL_CONTENTS} 2>&1 | tee -a ${logdir}/pack.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  tar cv --xz --hard-dereference -f ${pkgbuilddir}/${DEVPKG} ${DEV_CONTENTS} 2>&1 | tee -a ${logdir}/pack.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  tar cv --xz --hard-dereference -f ${pkgbuilddir}/${DOCPKG} ${DOC_CONTENTS} 2>&1 | tee -a ${logdir}/pack.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  tar cv --xz --hard-dereference -f ${pkgbuilddir}/${LICPKG} ${LIC_CONTENTS} 2>&1 | tee -a ${logdir}/pack.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  cd ${pkgbuilddir}  && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
  tar cv --xz --hard-dereference -f ${pkgbuilddir}/${SRCPKG} ${SRC_CONTENTS} 2>&1 | tee -a ${logdir}/pack.log && if ! test "x${PIPESTATUS[0]}" == "x0"; then fail $LINENO; fi
fi

echo "Done"
exit 0
