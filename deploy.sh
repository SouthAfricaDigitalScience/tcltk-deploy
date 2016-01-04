#!/bin/bash -e
# deploy script for Tcl/Tk
# This builds first tcl then tk
# Since there are actually two different packages, we have to use the names hardcoded.
. /etc/profile.d/modules.sh
module add deploy

# now build tcl and tk - these have different configs and need to be done in sequence, so we can do without a loop here.
echo "making tcl"
cd ${WORKSPACE}/tcl${VERSION}/unix/build-${BUILD_NUMBER}
../configure \
--enable-64bit \
--enable-shared \
--enable-threads \
--prefix=${SOFT_DIR}

make -j2
make install
echo ""

echo "making Tk"
cd ${WORKSPACE}/tk${VERSION}/unix/build-${BUILD_NUMBER}
../configure \
--with-tcl=${SOFT_DIR}/lib \
--enable-threads  \
--enable-shared \
--enable-64bit \
--enable-xft \
--prefix=${SOFT_DIR}

make -j2
echo ""
make install

mkdir -p modules
(
cat <<MODULE_FILE
#%Module1.0
## $NAME modulefile
##
proc ModulesHelp { } {
  puts stderr "\\tAdds $NAME ($VERSION.) to your environment."
}
module-whatis "Sets the environment for using $NAME ($VERSION.) See https://github.com/SouthAfricaDigitalScience/tcltk-deploy"
setenv TCL_VERSION $VERSION
setenv TK_VERSION  $VERSION
setenv TCL_DIR $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
setenv TK_DIR $::env(CVMFS_DIR)/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH $::env(TCL_DIR)/lib
prepend-path PATH $::env(TCL_DIR)/bin
MODULE_FILE
) > modules/${VERSION}
mkdir -p ${LIBRARIES_MODULES}/${NAME}
cp modules/${VERSION} ${LIBRARIES_MODULES}/${NAME}
module rm deploy
module avail
module add deploy
module add tcltk
echo "wish : "
which wish${VERSION:0:3} # should give wish8.6 for version 8.6.4
echo "tclsh : "
which tclsh${VERSION:0:3}
cd ${SOFT_DIR}/bin

echo "linking"
for bin in `ls` ; do
  short=`echo $bin | cut -d '8' -f 1`
  echo "Short version is $short"
  if [ ! -h ${short} ]; then
    ln -s ${bin} $short
  fi
done

which wish
which tclsh
