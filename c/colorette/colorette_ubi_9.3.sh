#!/bin/bash -e
# ----------------------------------------------------------------------------
#
# Package       : colorette
# Version       : 2.0.20
# Source repo   : https://github.com/jorgebucaran/colorette.git
# Tested on     : UBI: 9.3
# Language      : Javascript
# Travis-Check  : True
# Script License: Apache License, Version 2 or later
# Maintainer    : Pooja Shah <Pooja.Shah4@ibm.com>
#
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

set -ex

PACKAGE_NAME=colorette
PACKAGE_VERSION=${1:-2.0.20}
PACKAGE_URL=https://github.com/jorgebucaran/colorette.git
HOME_DIR=${PWD}

yum install -y wget tar git gzip

export LC_ALL=C.UTF-8
export LANG=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

#Installing Nodejs 
NODE_VERSION=20.12.2
wget -q https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-ppc64le.tar.gz
tar -xzf node-v$NODE_VERSION-linux-ppc64le.tar.gz
export PATH=$PWD/node-v$NODE_VERSION-linux-ppc64le/bin:$PATH
node -v
npm -v

#Cloning repo
git clone $PACKAGE_URL
cd $PACKAGE_NAME/
git checkout $PACKAGE_VERSION

if !(npm install; npm audit fix --force; npm audit fix); then
    echo "------------------$PACKAGE_NAME:install_fails-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_Fails"
    exit 1
elif ! npm test ; then
   echo "------------------$PACKAGE_NAME:install_success_but_test_fails---------------------"
   echo "$PACKAGE_URL $PACKAGE_NAME"
   echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_success_but_test_Fails"
   exit 2
else
   echo "------------------$PACKAGE_NAME:install_&_test_both_success-------------------------"
   echo "$PACKAGE_URL $PACKAGE_NAME"
   echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub  | Pass |  Both_Install_and_Test_Success"
   exit 0
fi