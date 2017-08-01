#!/bin/bash
set -e

folder=$1

ls -p "$folder" | grep -v / > ls-files.txt

test -e data && rm -fr data
mkdir -p data

#Reads all the file names and extract the contents
while read -r filename; do
  case "$filename" in
  *.tar.gz):
  	tar --directory data --extract --file "$folder/$filename"
    ;;
  *.zip)
    unzip "$folder/$filename" -d data
    ;;
  *)
    mv "$folder/$filename" data/
    ;;
  esac
done < ls-files.txt

bash -x build-run-scan.sh
status=$?
rm -fr data

exit $status