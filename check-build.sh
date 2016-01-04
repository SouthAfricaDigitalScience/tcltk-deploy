#!/bin/bash -e
# check-build for tcltk
. /etc/profile.d/modules.sh
module add ci
# first check tcl
cd ${WORKSPACE}/tcl${VERSION}/unix/build-${BUILD_NUMBER}
make test
make install

# if this passes, we good :)

# now, check tk
cd ${WORKSPACE}/tk${VERSION}/unix/build-${BUILD_NUMBER}
# TK tests need X, so not much use in making test, but we'll check if wish and libtk are there
ls  -lht wish
ls -lht *.so

make install
echo "tests have passed - making module"
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
setenv TCL_DIR /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
setenv TK_DIR /apprepo/$::env(SITE)/$::env(OS)/$::env(ARCH)/$NAME/$VERSION
prepend-path LD_LIBRARY_PATH $::env(TCL_DIR}/lib
prepend-path PATH $::env(TCL_DIR)/bin
MODULE_FILE
) > modules/${VERSION}
mkdir -p ${LIBRARIES_MODULES}/${NAME}
cp modules/${VERSION} ${LIBRARIES_MODULES}/${NAME}
module rm ci
module avail
module add ci
module add tcltk
echo "wish : "
which wish
echo "tclsh : "
which tclsh