#!/usr/bin/bash

prepare_workspace () {
  # Setup Python environment
  source utils/conda.sh
  conda_setup
  # Local code repository at `src/` that we can import from in Python
  make_importable $(pwd)/src
}

prepare_hypro () {
  
  # HyPro tarball
  # TODO: Publish on PyPi/conda-forge & just install with a package manager
  HYPROTAR=${1:-"hypro.tar.gz"}
  # Source directory for prepared packages
  PACKAGE_DIR=${2:-"${STAGING:-$DEFAULT_STAGING}/source/packages"}
  
  # Copy over HyPro source files & unpack
  cp $PACKAGE_DIR/$HYPROTAR .
  mkdir hypro
  source utils/archive.sh
  unpack $HYPROTAR -C hypro
  
  # Make Python packages importable
  make_importable $(pwd)/hypro/src
}