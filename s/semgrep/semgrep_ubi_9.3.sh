#!/bin/bash -e
# -----------------------------------------------------------------------------
#
# Package          : semgrep
# Version          : v1.85.0
# Source repo      : https://github.com/semgrep/semgrep.git
# Tested on        : UBI 9.3
# Language         : OCaml, Python
# Travis-Check     : True
# Script License   : GNU Lesser General Public License v2.1
# Maintainer       : Pooja Shah <Pooja.Shah4@ibm.com>
#
# Disclaimer       : This script has been tested in non-root mode on given
# ==========         platform using the mentioned version of the package.
#                    It may not work as expected with newer versions of the
#                    package and/or distribution. In such case, please
#                    contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

PACKAGE_NAME=semgrep
PACKAGE_VERSION=${1:-v1.85.0}
PACKAGE_URL=https://github.com/semgrep/semgrep.git

# Adding repos to install required dependencies
sudo yum install -y yum-utils vim wget tar curl gzip procps-ng --allowerasing
sudo yum-config-manager --add-repo https://rpmfind.net/linux/centos-stream/9-stream/AppStream/ppc64le/os/
sudo yum-config-manager --add-repo https://rpmfind.net/linux/centos-stream/9-stream/BaseOS/ppc64le/os/
wget https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official
sudo mv RPM-GPG-KEY-CentOS-Official /etc/pki/rpm-gpg/.
sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Official
sudo yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm
sudo yum install -y pcre2 pcre2-devel libev-devel libffi-devel python3.11 python3.11-devel python3.11-pip gcc gcc-c++ wget tar git gmp-devel pcre-devel make m4 perl patch unzip bubblewrap which bzip2 diffutils rsync libcurl-devel --allowerasing
sudo dnf install -y mercurial

#Create soft link for python3.11
sudo ln -sf /usr/bin/python3.11 /usr/bin/python3

# Install OCaml
wget https://caml.inria.fr/pub/distrib/ocaml-5.2/ocaml-5.2.0.tar.gz
tar -xzf ocaml-5.2.0.tar.gz
cd ocaml-5.2.0
./configure -target ppc64le-linux
make
sudo make install
export PATH=/usr/local/bin:$PATH
ocaml --version

# Install OPam
cd ..
git clone https://github.com/ocaml/opam.git
cd opam
git checkout 2.2.1
./configure --with-vendored-deps
make
sudo make install
opam --version
echo "5" | opam init --disable-sandboxing
eval $(opam env --switch=default)

# Build, Install and Test Semgrep
cd ..
git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout $PACKAGE_VERSION

git submodule update --init --recursive

make setup
python3 -m pip install pipenv pre-commit
# sed -i 's/jsonnet/jsonnet-binary/g' cli/Pipfile.lock 
# sed -i 's/7e770c7bf3a366b97b650a39430450f77612e74406731eb75c5bd59f3f104d4f/fbadf25f28161b0ccf29e0b72ef689790d14a9b23a681ab6846bd7cb12e17f1d/g' cli/Pipfile.lock 
# sed -i 's/0.20.0/0.17.0/g' cli/Pipfile.lock

if ! make core; sudo make install; then
    echo "------------------$PACKAGE_NAME:install_fails-------------------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail | Install_Fails"
    exit 1
elif ! make test; make check; then
    echo "------------------$PACKAGE_NAME:install_success_but_test_fails---------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub | Fail | Install_success_but_test_Fails"
    exit 2
else
    export PATH=/usr/local/bin:$PATH
    semgrep --version | grep ${PACKAGE_VERSION:1}
    echo "------------------$PACKAGE_NAME:install_&_test_both_success-------------------------"
    echo "$PACKAGE_URL $PACKAGE_NAME"
    echo "$PACKAGE_NAME  |  $PACKAGE_URL | $PACKAGE_VERSION | $OS_NAME | GitHub | Pass | Both_Install_and_Test_Success"
    exit 0
fi