#!/bin/bash
set -e

folder=$1

#Gets the contains of the downloaded files
ls -p "$folder" | grep -v / > ls-files.txt

test -e data && rm -fr data

#Creating folders for extracting the data
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

#Executes the scan
bash -x build-run-scan.sh
status=$?

#Removes the extracted files
rm -fr data

exit $status