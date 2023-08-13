#!/bin/bash

dirHtml="/var/www/html"

function report() {

  sed -n '/<div class="card border-primary mb-3">/,/title="dist-reference: ">[0-9.]*<\/a>/p' $dirHtml/index.html | \
  sed -n 's/.*\/dist\(\/[^"]\+\)\(-[0-9.]\+\)\.zip".*/\1\2/p' | \
  awk 'BEGIN{FS=OFS="/"} {gsub(/[^0-9.]/, "", $NF); print substr($0, index($0, $2))}'  | \
  awk -F'/' '{print $1 ";" $0}' | \
  sed 's#\(.*\)/#\1;#' > $dirHtml/ext.txt

  echo "vendor;composer;version" > $dirHtml/extension.csv
  while IFS=';' read -r col1 col2 col3; do
    echo "$col1;$col2;$col3" >> $dirHtml/extension.csv
  done < $dirHtml/ext.txt

  rm -rf $dirHtml/ext.txt

  sed -i 's/;/,/g' $dirHtml/extension.csv
  sed -i 's/,/","/g; s/^/"/; s/$/"/' $dirHtml/extension.csv
  unix2dos $dirHtml/extension.csv

}

report