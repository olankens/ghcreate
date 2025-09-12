# !/usr/bin/env bash

# Handle errors
set -euo pipefail

# Handle parameters
cursor=false
ghpage=false
i18n=false
ssr=false
tailwind=false
zoneless=false
title=""
description=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --cursor) cursor=true ;;
        --ghpage) ghpage=true ;;
        --i18n) i18n=true ;;
        --ssr) ssr=true ;;
        --tailwind) tailwind=true ;;
        --zoneless) zoneless=true ;;
        --title) shift; title="$1" ;;
        --description) shift; description="$1" ;;
    esac
    shift
done

# Handle dependencies

# Create repository
gh repo create "$title" -d "$description" --disable-wiki --public --clone
# mkdir -p "$title" && cd "$title"

# Create project
options=( 
    --directory .
    --inline-style
    --inline-template
    --routing
    --skip-git
    --skip-install
    --standalone
    --strict
    --style=css
)
[[ "$cursor" == true ]] && options=(--ai-config=cursor "${options[@]}")
[[ "$ssr" == true ]] && options=(--ssr "${options[@]}")
[[ "$zoneless" == true ]] && options=(--zoneless "${options[@]}")
ng new "$title" "${options[@]}"

# Update readme
mkdir -p .assets/
curl -L https://upload.wikimedia.org/wikipedia/commons/c/ca/1x1.png -o "./.assets/res0.png"
curl -L https://lipsum.app/852x480/aaa/000 -o "./.assets/res1.png"
curl -L https://lipsum.app/852x480/aaa/000 -o "./.assets/res2.png"
cat <<EOF > README.md
# <samp>OVERVIEW</samp>

<img src=".assets/res1.png" width="49.25%"/><img src=".assets/res0.png" width="1.5%"/><img src=".assets/res2.png" width="49.25%"/>

# <samp>GUIDANCE</samp>

\`\`\`

\`\`\`
EOF

# Config cursor
if [[ "$cursor" == true ]]; then
    mv .vscode/launch.json .cursor/
    mv .vscode/tasks.json .cursor/
    mv .cursor/rules/cursor.mdc .cursor/rules/angular.mdc
    rm -fr ./vscode
fi

# Config ghpage
# Config i18n
# Config tailwind