#!/usr/bin/env bash

set -uo pipefail

AUTHOR=''
FILENAME=''
DESCRIPTION=''
TITLE=''
DATE=''
CURRENT_DIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
OUTPUT_PATH="$CURRENT_DIR/content/$(date -u +%Y)"
THUMBNAIL=""

is_valid_date() {
    local date_value=$1

    [[ $date_value =~ ^([0-9]{4})-(0[1-9]|1[0-2])-(0[1-9]|[1-2][0-9]|3[01])$ ]]
}

trim() {
    local text=$1

    text=${text##+([[:space:]])} 
    text=${text%%+([[:space:]])}

    echo "$text"
}

create_markdown_file() {
    local markdown=$1
    touch "$markdown"

    cat << EOF > "$markdown"
---
author: $AUTHOR
date: $DATE
human_date: $(date -j -f "%Y-%m-%d" "$DATE" +"%d %B, %Y")
description: $DESCRIPTION
title: $TITLE
path: blog/$(date -u +%Y)/$FILENAME
thumbnail: $THUMBNAIL
---
EOF

printf "Created markdown file in %s" "$FINAL_PATH"
}

while [ -z "$AUTHOR" ];  do
    read -rp "Choose the author name for your new markdown file (default $(id -un || whoami)): " AUTHOR
    AUTHOR=$(trim "$AUTHOR")
    if [[ -z $AUTHOR ]]; then
        AUTHOR=$(id -un || whoami)
    fi 
done 

while [ -z "$FILENAME" ];  do
    read -rp "Choose a filename for your new markdown file: " FILENAME
    FILENAME=$(trim "$FILENAME")

done 

while [ -z "$TITLE" ];  do
    read -rp "Choose a frontmatter title for your new markdown file: " TITLE
    TITLE=$(trim "$TITLE")
done 

while [ -z "$DESCRIPTION" ];  do
    read -rp "Choose a frontmatter description for your new markdown file: " DESCRIPTION
    DESCRIPTION=$(trim "$DESCRIPTION")
done 

while [ -z "$THUMBNAIL" ];  do
    read -rp "Choose a header thumbnail for your new markdown file: (default path /assets/images): " THUMBNAIL
    THUMBNAIL=$(trim "$THUMBNAIL")

    if [[ $(dirname "$THUMBNAIL") =~ ^/?.*$ ]]; then
        THUMBNAIL="/assets/images/$THUMBNAIL"
    fi
done 

while ! is_valid_date "$DATE" ; do
    read -rp "Choose a date (default $(date -u +%Y-%m-%d)): " input_date
    input_date=$(trim "$input_date")
    
    if [[ -z "$input_date" ]]; then
       DATE=$(date -u +%Y-%m-%d)
    else 
        DATE=$input_date
    fi
done        

FINAL_PATH="$OUTPUT_PATH/$DATE-$FILENAME.md"
OVERWRITE=''

if [[ -f $FINAL_PATH ]]; then 
    while [[ "$OVERWRITE" != "y" && "$OVERWRITE" != "n" ]]; do
        read -rp "Ya existe un archivo con este nombre ¿desea sobreescribirlo? (y)es / (n)o: " OVERWRITE
    done

    if [[ $OVERWRITE = 'y' ]]; then 
        create_markdown_file "$FINAL_PATH"
    fi
else 
    create_markdown_file "$FINAL_PATH"
fi
