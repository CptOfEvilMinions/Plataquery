FROM golang:1.18 as builder
RUN mkdir /build
COPY main.go /build/main.go
COPY go.mod /build/go.mod
WORKDIR /build
RUN CGO_ENABLED=0 GOOS=linux go build -a -o osq-ext-s3.ext

FROM ubuntu:20.04

ARG OSQUERY_VERSION=5.2.2

#### Install Osquery ####
RUN apt-get update -q -y && apt-get install curl -y
RUN curl -L https://github.com/osquery/osquery/releases/download/${OSQUERY_VERSION}/osquery_${OSQUERY_VERSION}-1.linux_amd64.deb \
    --output /tmp/osquery_${OSQUERY_VERSION}-1.linux_amd64.deb
RUN dpkg -i /tmp/osquery_${OSQUERY_VERSION}-1.linux_amd64.deb
COPY conf/osquery/osquery.flags /etc/osquery/osquery.flags

#### Install extension ####
RUN mkdir -p /var/osquery/extensions
COPY --from=builder /build/osq-ext-s3.ext /var/osquery/extensions/osq-ext-s3.ext
RUN chown root:root /var/osquery/extensions/osq-ext-s3.ext && \
    chmod 755 /var/osquery/extensions/osq-ext-s3.ext
COPY conf/osquery/extension.load /etc/osquery/extension.load

CMD [ "/opt/osquery/bin/osqueryd", "--flagfile", "/etc/osquery/osquery.flags", "--verbose" ]