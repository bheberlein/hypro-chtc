#!/usr/bin/bash

# Staging directory
STAGING=/staging/groups/townsend_airborne
# Python environment
ENVNAME=htconda
ENVDIR=$ENVNAME
# Packages
ENVTAR=$ENVNAME-pelican.tar.gz
HYPROTAR=hypro_1.0.1dev7.tar.gz

# NOTE: Need to set at least `STAGING` & `ENVNAME`
source utils/execute.sh
prepare_workspace && prepare_hypro $HYPROTAR

# Override PIP-installed PelicanFS with latest from GitHub
git clone https://github.com/PelicanPlatform/pelicanfs ./pelicanfs
source utils/conda.sh
make_importable pelicanfs/src

python deploy.py "$@"
