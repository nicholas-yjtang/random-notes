#!/bin/bash

photofiles=$(find attachments -name "*Pasted*"  | sed -E 's/attachments\///g' | sed -E 's/ /%20/g')
for photofile in $photofiles; do
    #echo "Checking $photofile"
    for markdown_target in *.md; do
        if grep -q "$photofile" "$markdown_target"; then
            continue 2
        fi
        #echo "Removing $photofile from $markdown_target"
    done
    photofile=$(echo "$photofile" | sed -E 's/%20/ /g')
    echo "rm 'attachments/$photofile'"
done

