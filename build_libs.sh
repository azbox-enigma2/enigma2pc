#!/bin/bash

if [ "$(id -u)" != "0" ]; then
	echo "Error: Permission denied. Must be root user to run $0"
	exit 1
fi

DO_BACKUP=0
DO_RESTORE=0
DO_XINE=1
DO_CONFIGURE=1
DO_PARALLEL=1
DO_MAKEINSTALL="--install"

echo "Starting at $(date)"
timestart=$(date +"%s")

echo "-----------------------------------------"
echo "*** INSTALL REQUIRED PACKAGES ***"
echo "-----------------------------------------"
REQPKG="autoconf automake build-essential debhelper gettext subversion mercurial git autopoint \
	libdvdnav-dev libfreetype6-dev libfribidi-dev \
	libgif-dev libjpeg62-dev libpng12-dev \
	libsdl1.2-dev libsigc++-1.2-dev \
	libtool libxml2-dev libxslt1-dev python-dev swig libssl-dev libssl0.9.8 \
	libvdpau-dev vdpau-va-driver \
	libcdio-dev libvcdinfo-dev libxext-dev \
	libavcodec-dev libpostproc-dev \
	python-setuptools \
	checkinstall \
	"
	# libnl2-dev \

apt-get install -y $REQPKG

mkdir -p ../deb/ ../libs/

cd ../libs

echo "-----------------------------------------"
echo "Build and install xine-lib"
echo "-----------------------------------------"

git clone https://github.com/pingflood/xine-lib.git

cd xine-lib

if [ "$DO_CONFIGURE" -eq "1" ]; then
	echo "-----------------------------------------"
	echo "configuring xine-lib"
	echo "-----------------------------------------"

	./autogen.sh --disable-xinerama --disable-musepack --prefix=/usr
fi

echo "--------------------------------------"
echo "build xine-lib, please wait..."
echo "--------------------------------------"

checkinstall \
	--default $DO_MAKEINSTALL \
	--pakdir=../../deb \
	--maintainer=pingflood \
	--pkgversion=$(date +%Y%m%d) \
	--pkgrelease=pingflood-git \
	--nodoc \
	--include=include.list \
	make -j"$DO_PARALLEL" install

if [ ! $? -eq 0 ]; then
	echo ""
	echo "An error occured while building xine-lib"
	exit
fi

cd ..


echo "-----------------------------------------"
echo "Build and install libdvbsi++"
echo "-----------------------------------------"

#git clone git://git.opendreambox.org/git/obi/libdvbsi++.git
git clone https://github.com/pingflood/libdvbsi--.git
cd libdvbsi--
dpkg-buildpackage -uc -us
cd ..
mv libdvbsi*.deb ../deb/
dpkg -i ../deb/libdvbsi*.deb


echo "-----------------------------------------"
echo "Build and install libxmlccwrap"
echo "-----------------------------------------"

#git clone git://git.opendreambox.org/git/obi/libxmlccwrap.git
git clone https://github.com/pingflood/libxmlccwrap.git
cd libxmlccwrap
dpkg-buildpackage -uc -us
cd ..
mv libxmlccwrap*.deb ../deb/
dpkg -i ../deb/libxmlccwrap*.deb


echo "-----------------------------------------"
echo "Build and install libdreamdvd"
echo "-----------------------------------------"

#git clone git://schwerkraft.elitedvb.net/libdreamdvd/libdreamdvd.git
git clone https://github.com/pingflood/libdreamdvd.git
cd libdreamdvd
dpkg-buildpackage -uc -us
cd ..
mv libdreamdvd*.deb ../deb/
dpkg -i ../deb/libdreamdvd*.deb


echo "-----------------------------------------"
echo "Build and install libdvbcsa"
echo "-----------------------------------------"

# svn co svn://svn.videolan.org/libdvbcsa/trunk libdvbcsa
git clone https://github.com/pingflood/libdvbcsa.git
cd libdvbcsa
autoreconf -i
./configure --prefix=/usr --enable-sse2
make

checkinstall \
	--default $DO_MAKEINSTALL \
	--pakdir=../../deb \
	--maintainer=pingflood \
	--pkgversion=$(date +%Y%m%d) \
	--pkgrelease=pingflood-git \
	--nodoc \
	--include=include.list \
	make -j"$DO_PARALLEL" install

cd ..


echo "-----------------------------------------"
echo "Build and install libbluray"
echo "-----------------------------------------"

#git clone git://git.videolan.org/libbluray.git
git clone https://github.com/pingflood/libbluray.git
cd libbluray
#git checkout "6d88105783fa3a83963178d31f624717334ca9e0"
autoreconf -vif
./configure --prefix=/usr
make

checkinstall \
	--default $DO_MAKEINSTALL \
	--pakdir=../../deb \
	--maintainer=pingflood \
	--pkgversion=$(date +%Y%m%d) \
	--pkgrelease=pingflood-git \
	--nodoc \
	--include=include.list \
	make -j"$DO_PARALLEL" install

cd ..


echo "-----------------------------------------"
echo "Build and install pythonwifi"
echo "-----------------------------------------"

# git clone git://git.berlios.de/pythonwifi
git clone https://github.com/pingflood/pythonwifi.git
cd pythonwifi
python setup.py install

cd ..

#Build dvbsoftwareca kernel module:
# echo "-----------------------------------------"
# echo "Build and install dvbsoftwareca"
# echo "-----------------------------------------"
#cd dvbsoftwareca
#make   # You must have installed dvb-core (for example from s2-liplianin).
#insmod dvbsoftwareca.ko  # It will create ca0 device for adapter0
# cd ..

chmod 777 -R ../deb/ ../libs/

timeend=$(date +"%s")
timedelta=$(($timeend-$timestart))

echo "Finished at $(date) ($(date -u -d @"$timedelta" +"%-Mm %-Ss"))"
