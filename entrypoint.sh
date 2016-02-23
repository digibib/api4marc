#!/bin/bash

config="appsecret: '$APPSECRET'
bases:
  bibbi:
    host: $BS_SERVER
    port: $BS_PORT
    db: $BS_DB
    user: $BS_USER
    pass: $BS_PASS
  loc:
    host: lx2.loc.gov
    port: 210
    db: LCDB
"

#make echo proeserve whitespace
IFS= 

echo "$(eval echo -e '$config')" > config.yaml

perl api4marc.pl daemon