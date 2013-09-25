#!/bin/bash
#To build vdpauinfo and qvdpautest

echo "-----------------------------------------"
echo "*** INSTALL REQUIRED PACKAGES ***"
echo "-----------------------------------------"
REQPKG="autoconf automake build-essential \
	qt4-dev-tools \
	"

# for p in $REQPKG; do
# 	echo -n ">>> Checking \"$p\" : "
# 	dpkg -s $p >/dev/null
# 	if [ "$?" -eq "0" ]; then
# 		echo "package is installed, skip it"
# 	else
# 		echo "package NOT present, installing it"
# 		sudo apt-get -y install $p
# 	fi
# done
apt-get install -y $REQPKG

mkdir -p ../libs

cd ../libs

# PKG="vdpauinfo-0.0.6"
echo "-----------------------------------------"
echo "Build and install vdpauinfo"
echo "-----------------------------------------"
# if [ -d $PKG ]; then
# 	echo "Erasing older build dir"
# 	rm -Rf $PKG
# fi

# tar xzf $PKG.tar.gz

git clone https://github.com/pingflood/vdpauinfo.git

cd vdpauinfo
./autogen.sh
./configure
make
cd ..


# PKG="qvdpautest-0.5.1"
echo "-----------------------------------------"
echo "Build and install qvdpautest"
echo "-----------------------------------------"
# if [ -d $PKG ]; then
# 	echo "Erasing older build dir"
# 	rm -Rf $PKG
# fi

# tar xzf qvdpautest-0.5.1.tar.gz

git clone https://github.com/pingflood/qvdpautest.git

cd qvdpautest
qmake
make
cd ..

# cd ..
echo "*********************<END>*********************"
