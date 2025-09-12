# !/usr/bin/env bash

# Handle errors
set -euo pipefail

# Handle parameters
cursor=false
ghpage=false
i18n=false
tailwind=false
title=""
description=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --cursor) cursor=true ;;
        --ghpage) ghpage=true ;;
        --i18n) i18n=true ;;
        --tailwind) tailwind=true ;;
        --title) shift; title="$1" ;;
        --description) shift; description="$1" ;;
    esac
    shift
done

# Create repository
gh repo create "$title" -d "$description" --disable-wiki --public --clone
cd "$title"

# Create readme
mkdir -p .assets/
curl -L https://upload.wikimedia.org/wikipedia/commons/c/ca/1x1.png -o "./.assets/res0.png"
curl -L https://lipsum.app/852x480/aaa/000 -o "./.assets/res1.png"
curl -L https://lipsum.app/852x480/aaa/000 -o "./.assets/res2.png"
cat <<"EOF" > README.md
# <samp>OVERVIEW</samp>

$description

<img src=".assets/res1.png" width="49.25%"/><img src=".assets/res0.png" width="1.5%"/><img src=".assets/res2.png" width="49.25%"/>

Maecenas id metus nisl.
Donec iaculis sollicitudin enim, facilisis accumsan orci posuere sed.
Nunc in ante sit amet mauris volutpat suscipit quis in leo.
Morbi non felis dictum, maximus neque ac, pellentesque dui.

# <samp>OVERVIEW</samp>

```

```
EOF

# Create project
ng new $title --directory . --skip-git --routing --style=css --skip-install
npm install

# Config cursor
# Config ghpage
# Config i18n
# Config tailwind