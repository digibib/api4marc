FROM debian:jessie

RUN apt-get update && apt-get install -y \
    libmarc-xml-perl \
    libnet-z3950-zoom-perl \
    libmojolicious-perl \
    libyaml-perl \
    libswitch-perl \
    && rm -fr /var/lib/apt/lists/*

ENV updated_source=2016-02-23

COPY . /api4marc

WORKDIR /api4marc

EXPOSE 3000

ENTRYPOINT ./entrypoint.sh