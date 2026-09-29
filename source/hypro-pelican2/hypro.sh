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

source utils/conda.sh

# Get latest PelicanFS from GitHub
git clone https://github.com/PelicanPlatform/pelicanfs ./pelicanfs
make_importable $(pwd)/pelicanfs/src

# Override PIP-installed PelicanFS
python template.py --template sitecustomize.py.jinja --name pelicanfs --path $(pwd)/pelicanfs/src
mv sitecustomize.py $SITE/sitecustomize.py

python deploy.py "$@"
