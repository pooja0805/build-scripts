#!/bin/bash -e
# -----------------------------------------------------------------------------
#
# Package          : rope
# Version          : 1.10.0
# Source repo      : https://github.com/python-rope/rope.git
# Tested on        : UBI 8.7
# Language         : Python
# Travis-Check     : True
# Script License   : GNU General Public License v3.0
# Maintainer       : Abhishek Dwivedi <Abhishek.Dwivedi6@ibm.com>
#
# Disclaimer       : This script has been tested in root mode on given
# ==========         platform using the mentioned version of the package.
#                    It may not work as expected with newer versions of the
#                    package and/or distribution. In such case, please
#                    contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

PACKAGE_NAME=rope
PACKAGE_VERSION=${1:-1.10.0}
PACKAGE_URL=https://github.com/python-rope/rope.git

wrkdir=`pwd`

OS_NAME=$(grep ^PRETTY_NAME /etc/os-release | cut -d= -f2)

yum install -y --allowerasing gcc gcc-c++ yum-utils make automake autoconf libtool gdb* binutils rpm-build gettext wget git --skip-broken
yum install python39 python39-devel -y

python3 -m pip install --upgrade pip
python3 -m pip install --upgrade git+https://github.com/cython/cython@master

git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout $PACKAGE_VERSION

if ! python3 -m pip install -e .[dev] ; then
    echo "------------------$PACKAGE_NAME:Install_fails-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_Fails"
    exit 1
fi

#Skipping ropetest/contrib/autoimporttest.py test as mulitple github issues are still open related to the same test.
if ! python3 -m pytest --ignore=ropetest/contrib/autoimporttest.py ; then
    echo "------------------$PACKAGE_NAME:Install_success_but_test_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub | Fail |  Install_success_but_test_Fails"
    exit 2
else
    echo "------------------$PACKAGE_NAME:Install_&_test_both_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | GitHub  | Pass |  Both_Install_and_Test_Success"
    exit 0
fi
