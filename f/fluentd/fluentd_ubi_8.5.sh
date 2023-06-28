#!/bin/bash -e
# -----------------------------------------------------------------------------
#
# Package	    : fluentd
# Version	    : v1.16.1
# Source repo	: https://github.com/fluent/fluentd
# Tested on	    : UBI: 8.5
# Language      : Ruby
# Travis-Check  : True
# Script License: Apache License, Version 2 or later
# Maintainer	: Muskaan Sheik <Muskaan.Sheik@ibm.com>
#
# Disclaimer: This script has been tested in root mode on given
# ==========  platform using the mentioned version of the package.
#             It may not work as expected with newer versions of the
#             package and/or distribution. In such case, please
#             contact "Maintainer" of this script.
#
# ----------------------------------------------------------------------------

PACKAGE_NAME=fluentd
PACKAGE_VERSION=${1:-v1.16.1}
PACKAGE_URL=https://github.com/fluent/fluentd
HOME_DIR=$PWD

sudo yum install -y yum-utils openssl-devel git gdbm-devel gcc make wget tar libyaml-devel

sudo yum-config-manager --add-repo http://rpmfind.net/linux/centos/8-stream/AppStream/ppc64le/os/
sudo yum-config-manager --add-repo http://rpmfind.net/linux/centos/8-stream/PowerTools/ppc64le/os/
sudo yum-config-manager --add-repo http://rpmfind.net/linux/centos/8-stream/BaseOS/ppc64le/os/
wget https://www.centos.org/keys/RPM-GPG-KEY-CentOS-Official
sudo mv RPM-GPG-KEY-CentOS-Official /etc/pki/rpm-gpg/.
sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-Official

sudo yum install -y flex flex-devel bison readline-devel

cd $HOME_DIR
wget http://cache.ruby-lang.org/pub/ruby/3.2/ruby-3.2.2.tar.gz
tar zxf ruby-3.2.2.tar.gz
cd ruby-3.2.2
./configure
make
sudo make install
export PATH=/usr/local/bin:$PATH
ruby -v

cd $HOME_DIR
git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout $PACKAGE_VERSION

gem install bundler

if ! bundle install --path vendor/bundle; then
    echo "Install Fails"
    exit 1
fi

if ! bundle exec rake test TEST=test/test_*.rb; then
    echo "Test Fails"
    exit 2
else
    echo "Install & Test Success"
    exit 0
fi
