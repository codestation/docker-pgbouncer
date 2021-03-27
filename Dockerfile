FROM alpine:3.13

FROM alpine:3.13 AS build_stage

LABEL maintainer "codestation404@gmail.com"

RUN apk --no-cache add \
        autoconf \
        autoconf-doc \
        automake \
        c-ares \
        c-ares-dev \
        curl \
        gcc \
        libc-dev \
        libevent \
        libevent-dev \
        libtool \
        make \
        libressl-dev \
        file \
        patch \
        pkgconf

ARG PGBOUNCER_VERSION=1.15.0

RUN curl -Lso  "/tmp/pgbouncer.tar.gz" "https://pgbouncer.github.io/downloads/files/${PGBOUNCER_VERSION}/pgbouncer-${PGBOUNCER_VERSION}.tar.gz" && \
        file "/tmp/pgbouncer.tar.gz"

WORKDIR /tmp

RUN mkdir /tmp/pgbouncer && \
        tar -zxvf pgbouncer.tar.gz -C /tmp/pgbouncer --strip-components 1

WORKDIR /tmp/pgbouncer

COPY auth_dbname.patch .

RUN patch -p1 < auth_dbname.patch

RUN ./configure --prefix=/usr && \
        make

FROM alpine:3.13

RUN apk --no-cache add \
        libevent \
        libressl \
        ca-certificates \
        c-ares

RUN addgroup -g 70 -S postgres && adduser -u 70 -S postgres -G postgres -h /var/lib/postgresql -s /bin/sh -g "Postgres user"

WORKDIR /etc/pgbouncer
WORKDIR /var/log/pgbouncer

RUN chown -R postgres:root \
        /etc/pgbouncer \
        /var/log/pgbouncer

USER postgres

COPY --from=build_stage --chown=postgres ["/tmp/pgbouncer", "/opt/pgbouncer"]
COPY --chown=postgres ["entrypoint.sh", "/opt/pgbouncer"]

WORKDIR /opt/pgbouncer
ENTRYPOINT ["/opt/pgbouncer/entrypoint.sh"]
