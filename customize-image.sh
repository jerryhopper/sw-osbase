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

ORG_NAME=jerryhopper
REPO_NAME=sw-osbox-bin
BIN_DIR=/usr/local/osbox
ETC_DIR=/etc/osbox



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

      			# Download
      			log "Download the binary"
			REMOTEVERSION="$(GetRemoteVersion '${ORG_NAME}' '${REPO_NAME}')"
			echo "Remoteversion: ${REMOTEVERSION}"
			DownloadUnpack "${ORG_NAME}" "${REPO_NAME}" "${REMOTEVERSION}" "/usr/local/osbox"
			
		      	# Run the installer.
		      	log "Run the installer."
		      	bash ${BIN_DIR}/extra/install.sh

		      	log "Image custormization finished."
			;;
	esac
} # Main

# is_command function
is_command() {
    # Checks for existence of string passed in as only function argument.
    # Exit value of 0 when exists, 1 if not exists. Value is the result
    # of the `command` shell built-in call.
    local check_command="$1"
    command -v "${check_command}" >/dev/null 2>&1
}


DownloadUnpackx(){
      # Get the latest version
      LATEST_VERSION=$(curl -s https://api.github.com/repos/${ORG_NAME}/${REPO_NAME}/releases/latest | grep "tag_name" | cut -d'v' -f2 | cut -d'"' -f4)
      log "Latest version: ${LATEST_VERSION}"
      # Check the download url, if it responds with 200
      DOWNLOAD_CODE=$(curl -L -s -o /dev/null -I -w "%{http_code}" https://github.com/${ORG_NAME}/${REPO_NAME}/archive/${LATEST_VERSION}.tar.gz)
      if [ "$DOWNLOAD_CODE" != "200" ];then
      	log "Download error (${DOWNLOAD_CODE}) https://github.com/${ORG_NAME}/${REPO_NAME}/archive/${LATEST_VERSION}.tar.gz"
	exit 1
      fi
      
      # Download the file
      curl -L -o ${REPO_NAME}.tar.gz https://github.com/${ORG_NAME}/${REPO_NAME}/archive/${LATEST_VERSION}.tar.gz
      mkdir -p ${BIN_DIR}
      tar -C ${BIN_DIR} -xvf ${REPO_NAME}.tar.gz --strip 1
      # Doublecheck if binary is available
      if [ ! -f "$BIN_DIR/osbox" ];then
      	log "Osbox binary missing!"
	ls -latr ${BIN_DIR}
      	exit 1
      fi
      if [ ! -d $ETC_DIR ];then
      	mkdir -p $ETC_DIR
	echo "$BOARD" > "${ETC_DIR}/.board"
      fi
}

GetRemoteVersion(){
      _ORG_NAME=$1
      _REPO_NAME=$2
      if ! is_command "jq"; then
        LATEST_VERSION=$(curl -s https://api.github.com/repos/${_ORG_NAME}/${_REPO_NAME}/releases/latest | grep "tag_name" | cut -d'v' -f2 | cut -d'"' -f4)
      else
        LATEST_VERSION=$(curl -s https://api.github.com/repos/${_ORG_NAME}/${_REPO_NAME}/releases/latest|jq .tag_name -r )
      fi
      echo $LATEST_VERSION
}

DownloadUnpack(){
      _ORG_NAME=$1
      _REPO_NAME=$2
      _LATEST_VERSION=$3
      _BIN_DIR=$4

      echo "https://github.com/${_ORG_NAME}/${_REPO_NAME}/archive/${_LATEST_VERSION}.tar.gz"
      # Check the download url, if it responds with 200
      DOWNLOAD_CODE=$(curl -L -s -o /dev/null -I -w "%{http_code}" https://github.com/${_ORG_NAME}/${_REPO_NAME}/archive/${_LATEST_VERSION}.tar.gz)
      if [ "$DOWNLOAD_CODE" != "200" ];then
        log "Download error! ( ${DOWNLOAD_CODE} ) "https://github.com/${_ORG_NAME}/${_REPO_NAME}/archive/${_LATEST_VERSION}.tar.gz""
              exit 1
      fi

      # Download the file
      curl -s -L -o ${_REPO_NAME}.tar.gz https://github.com/${_ORG_NAME}/${_REPO_NAME}/archive/${_LATEST_VERSION}.tar.gz &> /dev/null
      mkdir -p ${_BIN_DIR}
      tar -C ${_BIN_DIR} -xf ${_REPO_NAME}.tar.gz --strip 1 > /dev/null
      rm -rf ${_REPO_NAME}.tar.gz
      echo "ok"
}

InstallPreRequisites(){
	#
	export LANG=C LC_ALL="en_US.UTF-8"
	export DEBIAN_FRONTEND=noninteractive
	export APT_LISTCHANGES_FRONTEND=none
	#sudo apt-get update
	#sudo apt-get install -y jq git unzip
	#apt-get install -y docker docker.io avahi-daemon avahi-utils libsodium23 build-essential libzip5 libedit2 libxslt1.1 nmap curl jq wget git unzip sqlite3 php-dev


	# remove new user prompt
	rm /root/.not_logged_in_yet
	# change to weak password
	# echo "root:password" | chpasswd

	#/usr/lib/armbian/armbian-firstrun



	# SWOOLE
	#log "Cloning and compiling swoole"
	#git clone https://github.com/swoole/swoole-src.git && cd swoole-src
	#git checkout v4.5.5
	#phpize && ./configure --enable-sockets --enable-openssl && make && make install
	#log "Installing swoole"
	#echo "extension=swoole.so" >> $(php -i | grep php.ini|grep Loaded | awk '{print $5}')

	#log  "Remove unneccesary files"
	#cd .. && rm -rf ./swoole-src


	#sudo apt-get -y remove build-essential
	#sudo apt -y autoremove && apt clean


}









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









Main "$@"
