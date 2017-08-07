#!/bin/bash
set -e
file_url=$1
if [[ -z "$file_url" ]]; then
  echo "Usage: jenkins.sh FILE_URL"
  exit 1
fi
test -e data && rm -fr data
mkdir -p data
curl -O -s "$file_url"
filename=$(sed -e 's,^.*/,,' <<<$file_url)
sha256sum "$filename"|tee file.sha256
case "$filename" in
  *.tar.gz):
  	tar --directory data --extract --file "$filename"
    ;;
  *.zip)
    unzip "$filename" -d data
    ;;
  *)
    mv "$filename" data/
    ;;
esac
bash -x build-run-scan.sh
status=$?
rm -fr data
test -f "$filename" && rm "$filename"
exit $status
