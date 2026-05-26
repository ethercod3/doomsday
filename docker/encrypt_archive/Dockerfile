FROM alpine:3.22

RUN apk add --no-cache \
    7zip \
    nushell

WORKDIR /workspace

COPY scripts/encrypt_archive.nu /opt/safe-archive/encrypt_archive.nu

ENTRYPOINT ["nu", "/opt/safe-archive/encrypt_archive.nu"]
