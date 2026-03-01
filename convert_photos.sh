#!/bin/bash
markdown_target="When is an Administrator, not an Administrator.md"
if [[ ! -f "$markdown_target.bak" ]]; then
    cp "$markdown_target" "$markdown_target.bak"
fi
sed -i -E 's/!\[]\((.*)\)/!\[\1]\(attachments\/\1\)/g' "$markdown_target" 