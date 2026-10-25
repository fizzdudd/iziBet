#!/bin/bash
# Build de la versión web para Vercel. Vercel no trae Flutter instalado,
# así que se descarga la misma versión que usamos en local y se compila.
set -e

FLUTTER_VERSION=3.47.8

if [ ! -d "_flutter" ]; then
  git clone https://github.com/flutter/flutter.git -b "$FLUTTER_VERSION" --depth 1 _flutter
fi
export PATH="$PWD/_flutter/bin:$PATH"

flutter config --no-analytics
flutter --version
flutter pub get
flutter build web --release
