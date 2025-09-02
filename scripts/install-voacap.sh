#!/bin/bash
# Author  : Gaston Gonzalez
# Date    : 5 June 2023
# Updated : 2 September 2025
# Purpose : Install voacapl
#
# References:
# 1. https://github.com/jawatson/voacapl
# 2. https://github.com/jawatson/voacapl/wiki
# 3. http://www.greg-hand.com/hfwin32.html
set -e
trap 'last_command=$current_command; current_command=$BASH_COMMAND' DEBUG
trap 'et-log "\"${last_command}\" command failed with exit code $?."' ERR

. ./env.sh
. ../overlay/opt/emcomm-tools/bin/et-common

APP=voacapl
VERSION=0.7.6
DOWNLOAD_FILE=voacapl-master.zip
INSTALL_DIR="/opt/${APP}-${VERSION}"
LINK_PATH="/opt/${APP}"

et-log "Installing voacapl build dependencies..."
apt install gfortran -y

if [[ ! -e ${ET_DIST_DIR}/${DOWNLOAD_FILE} ]]; then

  URL="https://github.com/thetechprepper/voacapl/archive/refs/heads/master.zip"

  et-log "Downloading ${APP}: ${URL}"
  download_with_retries ${URL} ${DOWNLOAD_FILE}

  mv -v ${DOWNLOAD_FILE} ${ET_DIST_DIR}
fi

CWD_DIR=`pwd`

# Only build once
if [[ ! -e "${ET_SRC_DIR}/${APP}/${BIN_FILE}" ]]; then
  cd ${ET_SRC_DIR}
  unzip -o ${ET_DIST_DIR}/${DOWNLOAD_FILE}

  cd voacapl-master

  et-log "Building ${APP}.."
  ./configure --prefix=${INSTALL_DIR}
  make && make install

  # patch prefix location
  sed -i 's|__PREFIX__|/opt/voacapl-0.7.6|' makeitshfbc
fi

[[ -e /root/itshfbc ]] && rm -rf /root/itshfbc
[[ -e /etc/skel/itshfbc ]] && rm -rf /etc/skel/itshfbc

./makeitshfbc && mv /root/itshfbc /etc/skel

[[ -e ${LINK_PATH} ]] && rm ${LINK_PATH}
ln -s ${INSTALL_DIR} ${LINK_PATH}

cd ${CWD_DIR}

stow -v -d /opt ${APP} -t /usr/local
