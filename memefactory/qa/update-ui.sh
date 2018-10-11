#!/bin/bash

# get source code
wget --no-check-certificate -O master.zip https://github.com/district0x/memefactory/archive/master.zip \
     && unzip master.zip \
     && mv memefactory-master memefactory

cd memefactory/

# build ui
lein deps
lein garden once
lein cljsbuild once "ui"

# publish new UI content
HASH=$(ipfs add -r resources/public/ |  tail -1 | grep -o -P '(?<=added).*(?=public)')

echo "IPFS hash: $HASH"

ipfs name publish --lifetime "99999h" --ttl "99999h" --key=memefactory-qa $HASH

# clean up
cd ../
rm -rf master.zip memefactory/

echo "Done"
exit $?
