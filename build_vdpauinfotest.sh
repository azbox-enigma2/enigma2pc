#!/bin/bash

if [ "$(id -u)" != "0" ]; then
	echo "Error: Permission denied. Must be root user to run $0"
	exit 1
fi

echo "-----------------------------------------"
echo "*** INSTALL REQUIRED PACKAGES ***"
echo "-----------------------------------------"
REQPKG="autoconf automake build-essential \
	qt4-dev-tools \
	"

apt-get install -y $REQPKG

mkdir -p ../libs

cd ../libs


echo "-----------------------------------------"
echo "Build and install vdpauinfo"
echo "-----------------------------------------"

# tar xzf vdpauinfo-0.0.6.tar.gz
git clone https://github.com/pingflood/vdpauinfo.git

cd vdpauinfo
./autogen.sh
./configure
make
cd ..

echo "-----------------------------------------"
echo "Build and install qvdpautest"
echo "-----------------------------------------"

# tar xzf qvdpautest-0.5.1.tar.gz
git clone https://github.com/pingflood/qvdpautest.git

cd qvdpautest
qmake
make
cd ..
