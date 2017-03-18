#!/bin/bash
set -euo pipefail
(cd docker; docker build -t clamd .)
docker kill clamd || true
docker rm clamd || true
docker run -d --name clamd -v $PWD/data:/data -v $PWD/clamd.conf:/etc/clamav/clamd.conf clamd
sleep 3
docker logs clamd
echo
mkdir -p data
docker exec clamd bash -c 'while ! test -S /var/run/clamav/clamd.ctl; do sleep 1; done && echo "scanning..." && clamdscan --verbose /data/' | tee report.txt
status=$?
docker kill clamd || true
docker rm clamd || true
exit $status
