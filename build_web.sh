#!/bin/bash
# Build Flutter web and set up landing page + app structure
set -e

# Build Flutter
flutter build web --release --base-href /app/

# Move Flutter output to /app/ subdirectory
mkdir -p build/web_final/app
cp -r build/web/* build/web_final/app/

# Copy landing page to root
cp public/index.html build/web_final/index.html

# Copy favicon for landing page
cp build/web/favicon.png build/web_final/favicon.png

# Replace build/web with the final structure
rm -rf build/web
mv build/web_final build/web

echo "Build complete: landing page at / , app at /app/"
