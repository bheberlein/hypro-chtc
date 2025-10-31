#!/bin/bash

STAGING=/staging/groups/townsend_airborne

ENVNAME=htconda
ENVTAR=$ENVNAME-new.tar.gz

source utils/conda.sh
conda_setup

make_importable $(pwd)/src

mkdir raw
# Copy only raw sub-tiles relevant to current tile job
cp $STAGING/data/lut/raw/${1}*.out ./raw/

python -m enspec.processing.workflows.lut.merge --name "$1"

cp tiles/* $STAGING/data/lut/tiles/
