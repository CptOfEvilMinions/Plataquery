FROM golang:1.18 as builder
RUN mkdir /build
COPY main.go /build/main.go
COPY go.mod /build/go.mod
COPY go.sum /build/go.sum
WORKDIR /build
RUN CGO_ENABLED=0 GOOS=linux go build -a -o osq-ext-s3.ext

FROM ubuntu:20.04

ARG OSQUERY_VERSION=5.1.0

#### Install Osquery ####
RUN apt-get update -q -y && apt-get install curl -y
RUN curl -L https://github.com/osquery/osquery/releases/download/${OSQUERY_VERSION}/osquery_${OSQUERY_VERSION}-1.linux_amd64.deb \
    --output /tmp/osquery_${OSQUERY_VERSION}-1.linux_amd64.deb
RUN dpkg -i /tmp/osquery_${OSQUERY_VERSION}-1.linux_amd64.deb
COPY conf/osquery/osquery_linux.flags.example /etc/osquery/osquery.flags
COPY conf/osquery/osquery_test.secret.example /etc/osquery/osquery.secret

#### Install extension ####
RUN mkdir -p /var/osquery/extensions
COPY --from=builder /build/osq-ext-s3.ext /var/osquery/extensions/osq-ext-s3.ext
RUN chown root:root /var/osquery/extensions/osq-ext-s3.ext && \
    chmod 755 /var/osquery/extensions/osq-ext-s3.ext
COPY conf/osquery/extension_linux.load /etc/osquery/extensions.load

COPY conf/docker/entrypoint.sh /entrypoint.sh
RUN chown root:root entrypoint.sh && \
    chmod 755 /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]