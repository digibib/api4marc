# api4marc

simple API to allow external base lookups for MARC records.
Uses perl's ZOOM module to handle the insanely ugly Z39.50 protocol

## INSTALL

sudo apt-get install libmarc-xml-perl libnet-z3950-zoom-perl libmojolicious-perl libyaml-perl libswitch-perl

copy config.yaml.example to config.yaml and add bases 

## USE

### Test route

perl api4marc.pl GET /

### Start as daemon

perl api4marc.pl daemon 

## API

Parameters:
  * apikey (secret)
  * base (loc|...)
  * format (normarc|usmarc)
  * query JSON Obj { isbn: "1234", ean: "1234", title: "abc", author: "abc def" }
  * maxRecords: 10

Response:
  * marcxml collection