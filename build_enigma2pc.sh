#!/bin/bash

if [ "$(id -u)" != "0" ]; then
	echo "Error: Permission denied. Must be root user to run $0"
	exit 1
fi

# where install Enigma2 tree
E2DIR_EXEC_PREFIX="/usr"		# will contain /bin, /lib
E2DIR_ETC_PREFIX=""			# contains /etc, /var, /share

BACKUP_E2="${E2DIR_ETC_PREFIX}/etc/enigma2 etc/tuxbox/*.xml ${E2DIR_ETC_PREFIX}/etc/tuxbox/nim_sockets ${E2DIR_ETC_PREFIX}/share/enigma2/xine.conf"

DO_BACKUP=0
DO_RESTORE=0
DO_CONFIGURE=1
DO_PARALLEL=1
DO_MAKEINSTALL="--install"

echo "Starting at $(date)"
timestart=$(date +"%s")

function e2_backup {
	echo "-----------------------------"
	echo "BACKUP E2 CONFIG"
	echo "-----------------------------"

#	tar -C $E2DIR_ETC_PREFIX -v -c -z -f e2backup.tgz $BACKUP_E2
}

function e2_restore {
	echo "-----------------------------"
	echo "RESTORE OLD E2 CONFIG"
	echo "-----------------------------"

#	if [ -f e2backup.tgz ]; then
#		tar -C $E2DIR_ETC_PREFIX -v -x -z -f e2backup.tgz
#	fi
}

function usage {
	echo "Usage:"
	echo " -b : backup E2 conf file before re-compile"
	echo " -r : restore E2 conf file after re-compile"
	echo " -nc: don't start configure/autoconf"
	echo " -py: parallel compile (y threads) e.g. -p2"
	echo " -ni: only execute make and no make install"
	echo " -h : this help"
	echo ""
	echo "common usage:"
	echo "  $0 -b -r : make E2 backup, compile E2, restore E2 conf files"
	echo ""
}

while [ -n "$1" ]; do
	case $1 in
		-b )	DO_BACKUP=1; shift;;
		-r ) 	DO_RESTORE=1; shift;;
		-nc )	DO_CONFIGURE=0; shift;;
		-ni )	DO_MAKEINSTALL=""; shift;;
		-p* )	if [ "`expr substr "$1" 3 3`" = "" ]; then
					echo "Number threads is missing"
					usage
					exit
				else
					DO_PARALLEL=`expr substr "$1" 3 3`
				fi
				shift;;
		-h )	usage; exit;;
		* )  	echo "Unknown parameter $1"
				usage
				exit;;
	esac
done

# if [ "$DO_BACKUP" -eq "1" ]; then
# 	e2_backup
# fi

mkdir -p ../deb/

echo "-----------------------------------------"
echo "Build and install enigma2pc"
echo "-----------------------------------------"

cd enigma2

if [ "$DO_CONFIGURE" -eq "1" ]; then
	autoreconf -i
	./configure --prefix=$E2DIR_ETC_PREFIX --exec_prefix=$E2DIR_EXEC_PREFIX --datarootdir=$E2DIR_EXEC_PREFIX/share --includedir=$E2DIR_EXEC_PREFIX/include --with-xlib --with-debug
fi

checkinstall \
	--default $DO_MAKEINSTALL \
	--pakdir=../../deb \
	--maintainer=pingflood \
	--pkgversion=$(date +%Y%m%d) \
	--pkgrelease=pingflood-git \
	--nodoc \
	--exclude=$E2DIR_EXEC_PREFIX/bin/enigma2.sh,*.pyo,*.pyc \
	--strip \
	--stripso \
	--reset-uids \
	--include=include.list \
	make -j"$DO_PARALLEL" install

if [ $? -eq 0 ]; then
	# removing pre-compiled py files
	find $E2DIR_EXEC_PREFIX/lib/enigma2/python/ -name "*.py[oc]" -exec rm {} \;

	# if [ "$DO_RESTORE" -eq "1" ]; then
	# 	e2_restore
	# fi

	timeend=$(date +"%s")
	timedelta=$(($timeend-$timestart))

	echo "Finished at $(date) ($(date -u -d @"$timedelta" +"%-Mm %-Ss"))"

	echo ""
	echo "Enigma2pc installed. Run it with:"
	echo "enigma2"
	echo ""
else
	echo ""
	echo "An error occured while building enigma2pc"
	exit
fi

# cd ..
