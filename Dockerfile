FROM golang:alpine as builder

ENV USER=proxy APPNAME=proxy USER_ID=1000

RUN apk add make && adduser -D -H -u ${USER_ID} ${USER}

RUN go env -w GO111MODULE=on && go env -w GOPROXY=https://goproxy.cn,direct

ADD go.mod /build/
RUN cd /build && go mod download

ARG VERSION=0.0.1

ADD . /build/
RUN cd /build && VERSION=${VERSION} BINARY=${APPNAME} make build

FROM alpine
ENV USER=proxy APPNAME=proxy APPDIR=/app

RUN apk update && apk add ca-certificates && rm -rf /var/cache/apk/* && update-ca-certificates

COPY --from=builder /build/${APPNAME} ${APPDIR}/
COPY --from=builder /etc/passwd /etc/passwd
COPY config.yaml /home/proxy/config.yaml

WORKDIR ${APPDIR}
USER ${USER}
ENTRYPOINT ["/app/proxy"]
