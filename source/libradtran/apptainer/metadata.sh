#!/bin/bash
# metadata.sh
# Usage: bash ./metadata.sh libradtran.sif versions.json libradtran.def

SIF_FILE="${1:-libradtran.sif}"
OUT_FILE="${2:-versions.json}"
DEF_FILE="${3:-libradtran.def}"

# Fetch SIF build date from file creation time
BUILD_DATE=$(stat -c %y "$SIF_FILE" | cut -d' ' -f1)

# Compute SHA256 checksum of the container & definition file
IMG_CHECKSUM=$(sha256sum "$SIF_FILE" | awk '{print $1}')
DEF_CHECKSUM=$(sha256sum "$DEF_FILE" | awk '{print $1}')

apptainer exec "$SIF_FILE" bash version.sh \
  "$BUILD_DATE" "$SIF_FILE" "$IMG_CHECKSUM" "$DEF_FILE" "$DEF_CHECKSUM" > "$OUT_FILE"
