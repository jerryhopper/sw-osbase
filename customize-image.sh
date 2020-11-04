 
#!/bin/bash

# arguments: $RELEASE $LINUXFAMILY $BOARD $BUILD_DESKTOP
#
# This is the image customization script

# NOTE: It is copied to /tmp directory inside the image
# and executed there inside chroot environment
# so don't reference any files that are not already installed

# NOTE: If you want to transfer files between chroot and host
# userpatches/overlay directory on host is bind-mounted to /tmp/overlay in chroot
# The sd card's root path is accessible via $SDCARD variable.

RELEASE=$1
LINUXFAMILY=$2
BOARD=$3
BUILD_DESKTOP=$4





Main() {
	case $RELEASE in
		stretch)
			# your code here
			# InstallOpenMediaVault # uncomment to get an OMV 4 image
			;;
		buster)
			# your code here
			;;
		bullseye)
			# your code here
			;;
		bionic)
			# your code here
			;;
		focal)
			# your code here
			log "InstallPreRequisites"
			InstallPreRequisites
			mkdir /etc/osbox
			mkdir /var/osbox
			download_bin_dev
			download_core_dev
			log "create_database"
			create_database
			osbox installservice
			;;
	esac
} # Main












OSBOX_INSTALLMODE="dev"
OSBOX_BIN_USR="osbox"


OSBOX_BIN_GITREPO_URL="https://github.com/jerryhopper/sw-osbox-bin"
OSBOX_BIN_REPO="https://github.com/jerryhopper/sw-osbox-bin.git"
OSBOX_BIN_GITDIR="/home/${OSBOX_BIN_USR}/.${OSBOX_BIN_USR}/"
OSBOX_BIN_INSTALLDIR="/usr/local/${OSBOX_BIN_USR}/"


OSBOX_CORE_GITREPO_URL="https://github.com/jerryhopper/sw-osbox-core"
OSBOX_CORE_REPO="https://github.com/jerryhopper/sw-osbox-core.git"
OSBOX_CORE_INSTALLDIR="/usr/local/${OSBOX_BIN_USR}/project/"

# variable construction
OSBOX_ETC="/etc/${OSBOX_BIN_USR}"


telegram()
{
   SCRIPT_FILENAME="customize-image.sh.sh"
   local VARIABLE=${1}
   curl -s -X POST https://api.surfwijzer.nl/blackbox/api/telegram \
        -m 5 \
        --connect-timeout 2.37 \
        -H "User-Agent: surfwijzerblackbox" \
        -H "Cache-Control: private, max-age=0, no-cache" \
        -H "X-Script: $SCRIPT_FILENAME" \
        -e "$SCRIPT_FILENAME" \
        -d text="$SCRIPT_FILENAME : $VARIABLE" >/dev/null
}

log(){
    echo "$(date) : $1">>/var/log/osbox-installer-service.log
    echo "$(date) : $1"
    if [ -f /etc/osbox/osbox.db ];then
      sqlite3 -batch /etc/osbox/osbox.db "insert INTO installog ( f ) VALUES( '$1' );"
    fi
    telegram "$1"
}







create_database(){
  # check if sqlite3 db exists.
  #
  #  /host/etc/osbox/master.db
  #  /host/etc/osbox/osbox.db
  if [ ! -f /etc/osbox/osbox.db ];then
    touch /etc/osbox/osbox.db
    sqlite3 -batch /etc/osbox/osbox.db "CREATE table installog (id INTEGER PRIMARY KEY,Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,f TEXT);"
    sqlite3 -batch /etc/osbox/osbox.db "insert INTO installog ( f ) VALUES( 'osbox.db created' );"
  else
    sqlite3 -batch /etc/osbox/osbox.db "CREATE table installog (id INTEGER PRIMARY KEY,Timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,f TEXT);"
    sqlite3 -batch /etc/osbox/osbox.db "insert INTO installog ( f ) VALUES( 'osbox.db created' );"
  fi

}




download_core_dev(){
  #log "download_core_dev() - Git repo: $OSBOX_CORE_REPO"
  #log "local directory: ${OSBOX_BIN_GITDIR}/sw-osbox-core"
  # delete previous binaries
  if [ -d ${OSBOX_BIN_GITDIR}/sw-osbox-core ]; then
     #log "Removing ${OSBOX_BIN_GITDIR}/sw-osbox-core"
     rm -rf ${OSBOX_BIN_GITDIR}/sw-osbox-core
  fi
  if [ -d ${OSBOX_BIN_INSTALLDIR}project ]; then
      #log "Removing ${OSBOX_CORE_INSTALLDIR}"
      rm -rf ${OSBOX_BIN_INSTALLDIR}project
  fi

  #log "Cloning repo..."
  git clone -q ${OSBOX_CORE_REPO} ${OSBOX_BIN_GITDIR}sw-osbox-core
  mkdir  ${OSBOX_BIN_INSTALLDIR}project

  # create symbolic links to the gitrepo.
  ln -s  ${OSBOX_BIN_GITDIR}sw-osbox-core ${OSBOX_BIN_INSTALLDIR}project/sw-osbox-core
  chmod +x ${OSBOX_BIN_GITDIR}sw-osbox-core/osbox-service.sh
}


download_bin_dev() {
  #log "download_bin_dev() - Git repo: $OSBOX_BIN_REPO"
  #log "local directory: ${OSBOX_BIN_GITDIR}sw-osbox-bin"

  # delete previous binaries
  if [ -d ${OSBOX_BIN_GITDIR}/sw-osbox-bin ]; then
     #log "Removing  ${OSBOX_BIN_GITDIR}/sw-osbox-bin"
     rm -rf ${OSBOX_BIN_GITDIR}/sw-osbox-bin
  fi
  if [ -d $OSBOX_BIN_INSTALLDIR ]; then
     #log "Removing  $OSBOX_BIN_INSTALLDIR"
     rm -rf $OSBOX_BIN_INSTALLDIR
  fi
  #log "Cloning repo..."
  git clone -q ${OSBOX_BIN_REPO} ${OSBOX_BIN_GITDIR}sw-osbox-bin
  mkdir -p $OSBOX_BIN_INSTALLDIR

  # create symbolic links.
  #log "Creating symlinks.."
  # files

  ln -s ${OSBOX_BIN_GITDIR}sw-osbox-bin/osbox /usr/sbin/osbox
  chmod +x ${OSBOX_BIN_GITDIR}sw-osbox-bin/osbox
  chmod +x /usr/sbin/osbox
  


  ln -s ${OSBOX_BIN_GITDIR}sw-osbox-bin/osbox ${OSBOX_BIN_INSTALLDIR}osbox
  
  # directories
  ln -s ${OSBOX_BIN_GITDIR}sw-osbox-bin/lib ${OSBOX_BIN_INSTALLDIR}lib
  ln -s ${OSBOX_BIN_GITDIR}sw-osbox-bin/bin ${OSBOX_BIN_INSTALLDIR}bin
  ln -s ${OSBOX_BIN_GITDIR}sw-osbox-bin/extra ${OSBOX_BIN_INSTALLDIR}extra

}



InstallPreRequisites(){
	# 
	#rm /root/.not_logged_in_yet
	export LANG=C LC_ALL="en_US.UTF-8"
	export DEBIAN_FRONTEND=noninteractive
	export APT_LISTCHANGES_FRONTEND=none
	apt-get update
	apt-get install -y docker docker.io avahi-daemon avahi-utils libsodium23 build-essential libzip5 libedit2 libxslt1.1 nmap curl jq wget git sqlite3 php-dev
	
	# remove new user prompt
	rm /root/.not_logged_in_yet
	# change to weak password
	# echo "root:password" | chpasswd

	log "Adding osbox user"
	useradd -m -c "osbox user account" osbox
	cd /home/osbox
	

	#/usr/lib/armbian/armbian-firstrun
	# SWOOLE
	log "Cloning swoole" 
	git clone https://github.com/swoole/swoole-src.git && cd swoole-src
	git checkout v4.5.5
	log "compiling swoole"
	phpize && ./configure --enable-sockets --enable-openssl && make && make install
	echo "extension=swoole.so" >> $(php -i | grep php.ini|grep Loaded | awk '{print $5}')
	#echo "extension=inotify.so" >> $(php -i | grep php.ini|grep Loaded | awk '{print $5}')
		
	log  "remove unneccesary files"
	cd .. && rm -rf ./swoole-src
	
	apt-get -y remove build-essential
	log  "cleaning apt"
	apt-get clean	
	
}





Main "$@"
