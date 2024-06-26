#!/bin/bash

CLASS_NAME="org.owasp.mastestapp.MastgTest"
OUTPUT_DIR="output"
TEMP_APKTOOL_DIR="$OUTPUT_DIR/temp_apktool_output"
TEMP_APK="$OUTPUT_DIR/temp_base.apk"
APK_PATH="./app/build/outputs/apk/debug/app-debug.apk"

# Create a temporary directory for jadx output
TEMP_JADX_OUTPUT_DIR="$OUTPUT_DIR/temp_jadx_output"

# Build Android Studio project
gradle assembleDebug

# Create temporary directories for output
mkdir -p "$OUTPUT_DIR"
mkdir -p "$TEMP_APKTOOL_DIR"
mkdir -p "$TEMP_JADX_OUTPUT_DIR"

# Copy the APK to the temporary location
cp "$APK_PATH" "$TEMP_APK"

# Get the APK path from the device
# APK_PATH=$(adb shell pm path org.owasp.mastestapp | sed 's/package://')

# Pull the APK to a temporary location
# adb pull "$APK_PATH" "$TEMP_APK"

# Use apktool to extract the AndroidManifest.xml
apktool d -s -f -o "$TEMP_APKTOOL_DIR" "$TEMP_APK"

# Run jadx on the specific class
jadx --single-class "$CLASS_NAME" -d "$TEMP_JADX_OUTPUT_DIR" "$TEMP_APK"

# Copy the specific class file to the output directory
JAVA_FILE="$TEMP_JADX_OUTPUT_DIR/sources/org/owasp/mastestapp/MastgTest.java"
if [ -f "$JAVA_FILE" ]; then
    cp "$JAVA_FILE" "$OUTPUT_DIR/MastgTest_reversed.java"
    echo "Copied $JAVA_FILE to $OUTPUT_DIR"
else
    echo "File $JAVA_FILE not found!"
fi

# Copy the AndroidManifest.xml to the output directory and rename it
MANIFEST_FILE="$TEMP_APKTOOL_DIR/AndroidManifest.xml"
if [ -f "$MANIFEST_FILE" ]; then
    cp "$MANIFEST_FILE" "$OUTPUT_DIR/AndroidManifest_reversed.xml"
    echo "Copied $MANIFEST_FILE to $OUTPUT_DIR/AndroidManifest_reversed.xml"
else
    echo "File $MANIFEST_FILE not found!"
fi

# Copy the original AndroidManifest.xml and MastgTest.kt to the output directory

cp app/src/main/AndroidManifest.xml "$OUTPUT_DIR/AndroidManifest.xml"
cp app/src/main/java/org/owasp/mastestapp/MastgTest.kt "$OUTPUT_DIR/MastgTest.kt"

# Clean up temporary files
rm -rf "$TEMP_APK" "$TEMP_JADX_OUTPUT_DIR" "$TEMP_APKTOOL_DIR"
