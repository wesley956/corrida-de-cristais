#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/.."

export ANDROID_HOME="$HOME/android-sdk"
export ANDROID_SDK_ROOT="$HOME/android-sdk"
export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/build-tools/33.0.2:$PATH"

export GODOT_ANDROID_KEYSTORE_DEBUG_PATH="$HOME/.android/debug.keystore"
export GODOT_ANDROID_KEYSTORE_DEBUG_USER="androiddebugkey"
export GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD="android"

mkdir -p build/android

echo "== Exportando APK debug =="
./Godot_v4.2.2-stable_linux.x86_64 --headless --path . --export-debug "Android Debug" "build/android/fragment-rush-debug.apk"

echo
echo "== APK gerado =="
ls -lh build/android/fragment-rush-debug.apk
