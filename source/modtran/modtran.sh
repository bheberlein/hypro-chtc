#!/usr/bin/bash

# : ------------------------------------------------------------------------- :
# Script Name: modtran.sh
# Description: Job executable for MODTRAN deployment on CHTC.
# Usage:       ./modtran.sh
# Author:      Brendan Heberlein
# Date:        2025-01-23
# : ------------------------------------------------------------------------- :

STAGING=/staging/groups/townsend_airborne
MODTRAN_PACKAGE=modtran.tar.gz

MODTRAN_DIR=$(pwd)/modtran

# Set MODTRAN environment variables
export MODTRAN_LIC_SERVER=krusty.russell.wisc.edu:13
export MODTRAN_DATA=$MODTRAN_DIR/DATA

# Copy MODTRAN 6.0 package
cp $STAGING/$MODTRAN_PACKAGE ./
# Extract MODTRAN
mkdir modtran
tar -xzf $MODTRAN_PACKAGE -C modtran

alias modtran6="$MODTRAN_DIR/bin/linux/mod6c_cons"
# modtran6 -license_status


