#!/usr/bin/bash

# : ------------------------------------------------------------------------- :
# Script Name: libradtran.sh
# Description: Job executable for libRadtran deployment on CHTC.
# Usage:       ./libradtran.sh
# Author:      Brendan Heberlein
# Date:        2025-01-23
# : ------------------------------------------------------------------------- :

STAGING=/staging/groups/townsend_airborne

cp $STAGING/source/packages/libradtran.tar.gz ./
tar -xzf libradtran.tar.gz

export LD_LIBRARY_PATH=$HOME/compiled/gsl/lib/

alias uvspec="$HOME/software/libradtran/bin/uvspec"
