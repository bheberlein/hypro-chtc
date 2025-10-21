#!/usr/bin/bash

# : ------------------------------------------------------------------------- :
# Script Name: prepare_modtran.sh
# Description: Prepare MODTRAN software package for remote deployment.
# Usage:       ./prepare_modtran.sh
# Author:      Brendan Heberlein
# Date:        2025-01-23
# : ------------------------------------------------------------------------- :

PACKAGE_NAME=Mod6_0_3r1full_allplat
TMP=/mnt/farnsworth/Enspec/users/bheberlein/modtran

# MODTRAN_PACKAGE=$PACKAGE_NAME.tar

# Extracts to ...
7z x $TMP/$PACKAGE_NAME.7z.001 -o/mnt/farnsworth/Enspec/users/bheberlein/modtran/zip

