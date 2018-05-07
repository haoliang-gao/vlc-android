# see
# * https://wiki.videolan.org/AndroidCompile/
# * https://github.com/uber-archive/android-build-environment/blob/master/Dockerfile
FROM ubuntu:18.04

RUN apt-get update && apt-get install -y automake ant autopoint cmake build-essential libtool \
        patch pkg-config protobuf-compiler ragel subversion unzip git \
        openjdk-8-jre openjdk-8-jdk flex \
        curl neovim

# sdk
RUN cd /tmp \
        && curl -SLq 'https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip' -o tools.zip \
        && unzip -q tools.zip && rm tools.zip \
        && mkdir /opt/android-sdk && mv tools /opt/android-sdk/tools
# see https://stackoverflow.com/questions/47150410/failed-to-run-sdkmanager-list-android-sdk-with-java-9
RUN cd /opt/android-sdk && sed -i "s/^DEFAULT_JVM_OPTS='[^']*/& --add-modules java.se.ee/" ./tools/bin/sdkmanager \
        && yes y | /opt/android-sdk/tools/bin/sdkmanager --update
# bug above, `yes | y` no-interactive

# ndk
RUN cd /tmp \
        && curl -SLq 'https://dl.google.com/android/repository/android-ndk-r14b-linux-x86_64.zip' -o ndk.zip \
        && unzip -q ndk.zip && rm ndk.zip \
        && mv android-ndk-r14b /opt/android-ndk

# env

ENV ANDROID_SDK=/opt/android-sdk
ENV ANDROID_NDK=/opt/android-ndk

ENV PATH=$PATH:$ANDROID_SDK/platform-tools:$ANDROID_SDK/tools:$ANDROID_NDK

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64/

# cleanup

RUN apt-get clean && rm -rf /tmp/*

# todo
# cleanup
# * cache file
# * dev program

VOLUME /app
WORKDIR /app

RUN apt-get -y install wget
