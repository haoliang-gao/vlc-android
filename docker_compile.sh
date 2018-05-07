#!/usr/bin/env bash

# todo not mandatory
readonly PROXY_ADDR="${proxy_addr?required proxy_addr. eg, 192.168.1.3:8118}"

readonly MY_DIR=$(dirname $(realpath $0))
readonly ANDROID_IMAGE=android-vlc
readonly CONTAINER_NAME="android-vlc"

# todo build image

build_image() {
    if docker images | grep "/^$ANDROID_IMAGE" &>/dev/null; then
        return
    fi
    docker build -t $ANDROID_IMAGE .
}

start_container() {
    docker run \
        -d \
        --name $CONTAINER_NAME \
        -v $MY_DIR:/app \
        -e http_proxy=http://$PROXY_ADDR \
        -e https_proxy=https://$PROXY_ADDR \
        $ANDROID_IMAGE \
        tail -f /dev/null
}

# todo interactive as a noneprivileged user
interact() {
    docker exec -it $CONTAINER_NAME bash
}

cleanup() {
    {
        docker stop $CONTAINER_NAME
        docker rm $CONTAINER_NAME
    } &>/dev/null
}

main() {
    build_image || {
        >&2 echo "failed to build image $ANDROID_IMAGE"
        return 1
    }

    if start_container; then
        trap "cleanup" EXIT
    else
        return 1
    fi

    interact
}

cd "$MY_DIR" || exit 1
main
