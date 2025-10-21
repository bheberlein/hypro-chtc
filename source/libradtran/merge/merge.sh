#!/bin/bash

STAGING=/staging/groups/townsend_airborne

ENVNAME=htconda
ENVTAR=$ENVNAME-new.tar.gz

source utils/conda.sh
conda_setup

mkdir -p py/lut
cp $STAGING/source/libradtran/pylut.tar.gz ./
tar -xzf pylut.tar.gz -C py/lut/ && rm pylut.tar.gz
make_importable $(pwd)/py

mkdir raw
# Copy only raw sub-tiles relevant to current tile job
cp $STAGING/data/lut/raw/${1}*.out ./raw/

python -m lut.merge --name "$1"

cp tiles/* $STAGING/data/lut/tiles/
