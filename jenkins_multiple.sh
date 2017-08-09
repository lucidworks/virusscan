#!/bin/bash
set -e

folder=$1

# Gets the contents of the downloaded files
find "$folder" -mindepth 1 -maxdepth 1 -type f > files.txt

test -e data && rm -fr data

# Creating folders for extracting the data
mkdir -p data
mkdir -p data/zip
mkdir -p data/tar

# Reads all the file names and extract the contents
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
done < files.txt

# Executes the scan
bash -x build-run-scan.sh
status=$?

# Removes the extracted files
rm -fr data

exit $status
