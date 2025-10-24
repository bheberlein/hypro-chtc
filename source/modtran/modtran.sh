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
# rsync -avPh $STAGING/$MODTRAN_PACKAGE ./$MODTRAN_PACKAGE

# Extract MODTRAN
mkdir modtran
tar -xzf $MODTRAN_PACKAGE -C modtran

alias modtran6="$MODTRAN_DIR/bin/linux/mod6c_cons"

# Check license: `modtran6 -license_status`
# Should print: `STAT_VALID MODTRAN floating License acquired: $MODTRAN_LIC_SERVER`

# Prepare output directory
OUTPUT_DIR=$(pwd)/output
mkdir $OUTPUT_DIR

# # Run test case
# modtran6 $MODTRAN_DIR/TEST/JSON/SolarIrrad.json -workpath $OUTPUT_DIR

# # ls output
# # SolarIrrad.7sc  SolarIrrad.plt  SolarIrrad.psc  SolarIrrad._pth  SolarIrrad.tp6  SolarIrrad.tp7

# NOTE: It seems MODTRAN won't accept a relative path here
FARNSWORTH=/Volumes/Enspec
CASE_FILE=$(pwd)/isofit-lut-config.json
# CASE_FILE=$FARNSWORTH/users/bheberlein/isofit-lut/FLIGHT-2_20240424_02_modtran_tpl.json
# vim $CASE_FILE

modtran6 $CASE_FILE -workpath ./output/
