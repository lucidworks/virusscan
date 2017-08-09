#!/bin/bash
set -e

#Checks if we are using a link or a Version as a parameter
if ! grep -P '^\d+\.\d+\.\d+$' <<<"$1"; then

  #Regex for checking the file link
  regex='(https?|ftp|file|s3)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]'
  file_url=$1

  #if the link is valid
  if [[ $file_url =~ $regex ]];  then

    #Checks and creates data folder
    test -e data && rm -fr data
    mkdir -p data

    #Gets the file and verifies checksum
    curl -O -s "$file_url"
    filename=$(sed -e 's,^.*/,,' <<<$file_url)
    sha256sum "$filename"|tee file.sha256

    #Reads the filename and extract the contents
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

    # Executes the scan
    bash -x build-run-scan.sh
    status=$?

    #Removes data folder and the downloaded file
    rm -fr data
    test -f "$filename" && rm "$filename"

  else
    echo "File Link not valid"
    exit 1
  fi

else
  Version=$1
  # are we newer than 3.1.0?
  oldest_version=$( (echo "$Version"; echo 3.1.0)|sort -t '.' -k 1,1 -k 2,2 -k 3,3 -g | head -n 1)
  if [[ $oldest_version != '3.1.0' ]]; then
    echo "Version=$Version is no longer supported by this job; the paths and checksums have changed from 3.1.0"
    exit 1
  fi

  #S3 artifacts will be downloaded in this folder
  FOLDER="from_s3"

  # Creates the folder for the s3 artifacts
  mkdir "$FOLDER"

  # Syncs the s3 folder with the local folder
  S3_PREFIX="s3://download.lucidworks.com/fusion-$Version/"
  aws s3 sync $S3_PREFIX "$FOLDER"

  # Gets the contents of the downloaded files
  find "$folder" -mindepth 1 -maxdepth 1 -type f -printf '%f\n' > files.txt

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

  #Removes the s3 folder
  rm -rf "$FOLDER"

fi

exit $status