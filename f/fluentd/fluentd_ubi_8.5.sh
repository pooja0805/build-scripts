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

yum install -y nodejs nodejs-devel nodejs-packaging npm python38 python38-devel ncurses git jq curl make gcc-c++ procps gnupg2 ruby libcurl-devel libffi-devel ruby-devel redhat-rpm-config sqlite sqlite-devel java-1.8.0-openjdk-devel rubygem-rake ruby rubygems wget

cd $HOME_DIR
gem sources --add https://rubygems.org/
wget https://rubygems.org/rubygems/rubygems-3.3.15.tgz
tar zxvf rubygems-3.3.15.tgz
cd rubygems-3.3.15
ruby setup.rb

cd $HOME_DIR
git clone $PACKAGE_URL
cd $PACKAGE_NAME
git checkout $PACKAGE_VERSION

gem install bundler

if ! bundle install --path vendor/bundle; then
    echo "Install Fails"
    exit 1
fi

export PATH=vendor/bundle/ruby/2.5.0/bin:$PATH

if ! bundle exec rake test; then
    echo "Test Fails"
    exit 2
else
    echo "Install & Test Success"
    exit 0
fi
