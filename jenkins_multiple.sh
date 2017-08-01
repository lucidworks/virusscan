#!/bin/bash
set -e

ls -p | grep -v / > ls-files.txt

test -e data && rm -fr data
mkdir -p data

#Reads all the file names and extract the contents
while read -r filename; do

  case "$filename" in
  *.tar.gz):
  	tar --directory data --extract --file "${filename}_tar"
    ;;
  *.zip)
    unzip "$filename" -d data
    ;;
  *)
    mv "$filename" data/
    ;;
  esac

done < ls-files.txt

bash -x build-run-scan.sh
status=$?
rm -fr data

while read -r filename; do
  test -f "$filename" && rm "$filename"
done < ls-files.txt

exit $status