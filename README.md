# api4marc

simple API to allow external base lookups for MARC records.
Uses perl's ZOOM module to handle the insanely ugly Z39.50 protocol

## INSTALL (ubuntu)

    sudo apt-get install libmarc-xml-perl libnet-z3950-zoom-perl libmojolicious-perl libyaml-perl libswitch-perl

copy config.yaml.example to config.yaml and add bases, apikey and appsecret

## USE

### Test route

    perl api4marc.pl GET /

### Start as daemon

    perl api4marc.pl daemon [-l host:port]

## API

Parameters:
  * apikey (secret)
  * base (loc|...)
  * format (normarc|usmarc)
  * maxRecords: 10
  * query params (in prioritized order) 
    * isbn
    * ean
    * title
    * author

Response:
  * marcxml collection

## LOGGING

Logs by default to ./log/[env].log