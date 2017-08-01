#!/bin/bash
set -e

folder=$1

ls -p "$folder" | grep -v / > ls-files.txt

test -e data && rm -fr data

mkdir -p data
mkdir -p data/zip
mkdir -p data/tar

#Reads all the file names and extract the contents
while read -r filename; do
  case "$filename" in
  *.tar.gz):
    mkdir "data/tar/$filename"
  	tar --directory "data/tar/$filename" --extract --file "$folder/$filename"
    ;;
  *.zip)
    mkdir "data/zip/$filename"
    unzip "$folder/$filename" -d "data/zip/$filename"
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