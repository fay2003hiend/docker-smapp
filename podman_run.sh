#!/bin/bash -e

which podman

if [ $# -ne 3 ]; then
    echo "Usage: $0 <data_dir> <post_dir> <vnc_port>"
    exit 1
fi

cd ${0%/*}

DATA_DIR=`realpath ${1}`
POST_DIR=`realpath ${2}`
VNC_PORT=${3}

podman build . -t smap_novnc

podman run \
    -v ${DATA_DIR}:/root/.config/Spacemesh \
    -v ${POST_DIR}:/root/post:ro \
    -p ${VNC_PORT}:8080 \
    -e DISPLAY_WIDTH=1280 \
    -e DISPLAY_HEIGHT=800 \
    smap_novnc
