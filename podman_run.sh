#!/bin/bash -e

which podman

if [ $# -lt 3 ]; then
    echo "Usage: $0 <data_dir> <post_dir> <vnc_port> [shell]"
    exit 1
fi

cd ${0%/*}
podman build . -t smap_novnc

set -x

DATA_DIR=`realpath ${1}`
POST_DIR=`realpath ${2}`
VNC_PORT=${3}

if [[ $# -eq 4 && $4 = shell ]]; then
    podman run -it --rm \
    --device /dev/dri:/dev/dri \
    smap_novnc \
    bash -l
else
    podman run \
    --rm \
    --device /dev/dri:/dev/dri \
    -v ${DATA_DIR}:/root/.config/Spacemesh \
    -v ${POST_DIR}:/root/post \
    -p ${VNC_PORT}:8080 \
    -e DISPLAY_WIDTH=1440 \
    -e DISPLAY_HEIGHT=900 \
    smap_novnc
fi
