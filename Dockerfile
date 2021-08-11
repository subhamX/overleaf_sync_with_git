FROM alpine:3.10

RUN apk update
RUN apk upgrade

RUN apk --no-cache add curl
RUN apk --no-cache add unzip

COPY src/entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh", "tmp"]

