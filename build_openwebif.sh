#!/bin/bash

if [ "$(id -u)" != "0" ]; then
	echo "Error: Permission denied. Must be root user to run $0"
	exit 1
fi

echo "-----------------------------------------"
echo "*** INSTALL REQUIRED PACKAGES ***"
echo "-----------------------------------------"
REQPKG="python-cheetah python-twisted-web \
	"

apt-get install -y $REQPKG

INSTALL_E2PDIR="/usr/lib/enigma2/python/Plugins"

mkdir -p ../libs
cd ../libs

# ----------------------------------------------------------------------

echo "-----------------------------------------"
echo "Build and install e2openplugin-OpenWebif"
echo "-----------------------------------------"

git clone git://github.com/E2OpenPlugins/e2openplugin-OpenWebif.git
cd e2openplugin-OpenWebif/plugin

mkdir -p $INSTALL_E2PDIR/Extensions/OpenWebif

cp -R . $INSTALL_E2PDIR/Extensions/OpenWebif

cheetah-compile -R --nobackup $INSTALL_E2PDIR/Extensions/OpenWebif

python -O -m compileall $INSTALL_E2PDIR/Extensions/OpenWebif
