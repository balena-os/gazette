FROM debian as binaries

RUN apt-get update && apt-get install -y --no-install-recommends systemd

COPY create-sysroot.sh /
RUN /create-sysroot.sh /bin/journalctl
    
FROM alpine

LABEL org.opencontainers.image.description "A lightweight log collection service for sending system logs to the balena API"

RUN apk --update add --no-cache jq

# Copy journalctl and dependenciest to the local image
COPY --from=binaries /sysroot /
COPY start.sh format.jq /

CMD ["/start.sh"]
