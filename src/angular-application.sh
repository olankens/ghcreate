#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2129

# Handle errors
set -euo pipefail

# Handle parameters
cursor=false
ghpage=false
ssr=false
tailwind=false
zoneless=false
title=""
description=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --cursor) cursor=true ;;
        --ghpage) ghpage=true ;;
        --ssr) ssr=true ;;
        --tailwind) tailwind=true ;;
        --zoneless) zoneless=true ;;
        --title) shift; title="$1" ;;
        --description) shift; description="$1" ;;
    esac
    shift
done

# Create repository
# gh repo create "$title" -d "$description" --disable-wiki --public --clone && cd "$title"
mkdir -p "$title" && cd "$title"

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

# Config ghpage
# TODO: Update the build command to handle i18n
if [[ "$ghpage" == true ]]; then
    mkdir -p .github/workflows
    {
        echo "name: Deploy Angular App to GitHub Pages"
        echo
        echo "on:"
        echo "  push:"
        echo "    branches: [\"main\"]"
        echo "  workflow_dispatch:"
        echo
        echo "permissions:"
        echo "  contents: read"
        echo "  pages: write"
        echo "  id-token: write"
        echo
        echo "concurrency:"
        echo "  group: \"pages\""
        echo "  cancel-in-progress: false"
        echo
        echo "jobs:"
        echo "  build:"
        echo "    runs-on: ubuntu-latest"
        echo "    steps:"
        echo "      - name: Checkout"
        echo "        uses: actions/checkout@v4"
        echo
        echo "      - name: Set up Node.js"
        echo "        uses: actions/setup-node@v4"
        echo "        with:"
        echo "          node-version: '22'"
        echo "          cache: 'npm'"
        echo
        echo "      - name: Install Dependencies"
        echo "        run: npm ci"
        echo
        echo "      - name: Build Angular App"
        echo "        run: npm run build -- --configuration production --base-href /\${{ github.event.repository.name }}/"
        echo
        echo "      - name: Add .nojekyll file"
        echo "        run: touch ./dist/${title}/browser/.nojekyll"
        echo
        echo "      - name: Copy index.html to 404.html"
        echo "        run: cp ./dist/${title}/browser/index.html ./dist/${title}/browser/404.html"
        echo
        echo "      - name: Setup Pages"
        echo "        uses: actions/configure-pages@v4"
        echo
        echo "      - name: Upload artifact"
        echo "        uses: actions/upload-pages-artifact@v3"
        echo "        with:"
        echo "          path: './dist/${title}/browser'"
        echo
        echo "  deploy:"
        echo "    environment:"
        echo "      name: github-pages"
        echo "      url: \${{ steps.deployment.outputs.page_url }}"
        echo "    runs-on: ubuntu-latest"
        echo "    needs: build"
        echo "    steps:"
        echo "      - name: Deploy to GitHub Pages"
        echo "        id: deployment"
        echo "        uses: actions/deploy-pages@v4"
    } > .github/workflows/ghpage.yml
fi

# Config tailwind
if [[ "$tailwind" == true ]]; then
    npm install tailwindcss @tailwindcss/postcss postcss --force
    {
        echo '{'
        echo '  "plugins": {'
        echo '    "@tailwindcss/postcss": {}'
        echo '  }'
        echo '}'
    } > .postcssrc.json
    echo '@import "tailwindcss";' >> src/styles.css
fi
