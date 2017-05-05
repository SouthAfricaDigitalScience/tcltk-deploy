#!/bin/bash -e
# Copyright 2016 C.S.I.R. Meraka Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# build script for Tcl/Tk
# This builds first tcl then tk
# Since there are actually two different packages, we have to use the names hardcoded.

. /etc/profile.d/modules.sh
module add ci
mkdir -p $WORKSPACE
mkdir -p $SRC_DIR
mkdir -p $SOFT_DIR
STEPS=("tcl" "tk")

#  Download each of the source files
for STEP in ${STEPS[@]} ; do
  SOURCE_FILE=${STEP}${VERSION}-src.tar.gz
  echo "Source  file is ${SOURCE_FILE}"
  if [ ! -e ${SRC_DIR}/${SOURCE_FILE}.lock ] && [ ! -s ${SRC_DIR}/${SOURCE_FILE} ] ; then
    touch  ${SRC_DIR}/${SOURCE_FILE}.lock
    echo "seems like this is the first build - let's get the source"
    wget http://prdownloads.sourceforge.net/tcl/${SOURCE_FILE} -O $SRC_DIR/$SOURCE_FILE
    echo "releasing lock"
    rm -v ${SRC_DIR}/${SOURCE_FILE}.lock
  elif [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; then
    # Someone else has the file, wait till it's released
    while [ -e ${SRC_DIR}/${SOURCE_FILE}.lock ] ; do
      echo " There seems to be a download currently under way, will check again in 5 sec"
      sleep 5
    done
  else
    echo "continuing from previous builds, using source at " ${SRC_DIR}/${SOURCE_FILE}
  fi
# Untar both files
  tar xzf  ${SRC_DIR}/${SOURCE_FILE} -C ${WORKSPACE} --skip-old-files
# make the build directories
  mkdir -p ${WORKSPACE}/${STEP}${VERSION}/unix/build-${BUILD_NUMBER}
done


# now build tcl and tk - these have different configs and need to be done in sequence, so we can do without a loop here.
echo "making tcl"
cd ${WORKSPACE}/tcl${VERSION}/unix/build-${BUILD_NUMBER}
../configure \
--enable-64bit \
--enable-shared \
--enable-threads \
--prefix=${SOFT_DIR}

make
echo ""

echo "making Tk"
cd ${WORKSPACE}/tk${VERSION}/unix/build-${BUILD_NUMBER}
../configure \
--with-tcl=${WORKSPACE}/tcl${VERSION}/unix/build-${BUILD_NUMBER} \
--enable-threads  \
--enable-shared \
--enable-64bit \
--enable-xft \
--prefix=${SOFT_DIR}

make
echo ""
