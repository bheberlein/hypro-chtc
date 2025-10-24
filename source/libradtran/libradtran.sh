#!/usr/bin/bash

# : ------------------------------------------------------------------------- :
# Script Name: libradtran.sh
# Description: Job executable for libRadtran deployment on CHTC.
# Usage:       ./libradtran.sh
# Author:      Brendan Heberlein
# Date:        2025-01-23
# : ------------------------------------------------------------------------- :

STAGING=/staging/groups/townsend_airborne
LOCAL=$(pwd)

INP_FILE=$1
OUT_FILE=${INP_FILE%.*}.out
ERR_FILE=${INP_FILE%.*}.err

echo "INP file: $INP_FILE"
echo "OUT file: $OUT_FILE"

cp $STAGING/source/libradtran/libradtran.tar.gz ./
tar -xzf libradtran.tar.gz

export LD_LIBRARY_PATH=$LOCAL/compiled/gsl/lib/

alias uvspec="$LOCAL/software/libradtran/bin/uvspec"

echo "Running libRadtran..."
(uvspec < $INP_FILE > $OUT_FILE) >& $ERR_FILE
echo "...Done!"

cp $OUT_FILE $STAGING/data/processed/lut/

rm -r ./*

exit 0
