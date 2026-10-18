# OldNet OS - one Containerfile, three images selected via BASE_IMAGE
ARG BASE_IMAGE=ghcr.io/ublue-os/bazzite-dx:stable
FROM ${BASE_IMAGE}

ARG IMAGE_NAME=oldnet
ARG IMAGE_VENDOR=oldnet-os

COPY system_files/ /
COPY build_files/ /tmp/build_files/

RUN IMAGE_NAME=${IMAGE_NAME} bash /tmp/build_files/build.sh && \
    rm -rf /tmp/build_files /var/cache /var/log/* && \
    ostree container commit

RUN bootc container lint || true
