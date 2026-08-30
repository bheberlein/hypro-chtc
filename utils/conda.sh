#!/usr/bin/bash

conda_install () {
  system=$(uname -s)
  architecture=$(uname -m)
  conda_dir=$(pwd)/conda
  conda_repo=https://repo.anaconda.com/miniconda
  conda_installer=$conda_repo/Miniconda3-latest-${system}-${architecture}.sh
  wget $conda_installer -O conda.sh
  sh conda.sh -b -p $conda_dir
  rm conda.sh
  $conda_dir/condabin/conda init
  # NOTE: To use the prepared environment immediately, run
  # > . conda/etc/profile.d/conda.sh && conda activate
}

conda_build () {
  # Create conda environment from YAML definition file
  conda env create -f $2
  # Clean up unnecessary files
  conda clean -afy
  # Install `conda-pack` in the base environment, if needed
  conda activate base
  conda install -y -S -c conda-forge conda-pack
  # Package the environment for deployment
  conda pack -n $1 -o $1.tar.gz
}

conda_setup () {
  # NOTE: User should define `ENVNAME`, `STAGING`
  : "${ENVNAME:?Error: ENVNAME is not set.}" || return 1
  : "${STAGING:?Error: STAGING is not set.}" || return 1
  # Resolve environment local directory & source package
  [[ ! -v ENVDIR ]] && ENVDIR=$ENVNAME
  [[ ! -v ENVTAR ]] && ENVTAR=$ENVNAME.tar.gz
  # Resolve environment source directory
  [[ ! -v SOURCE_DIR  ]] && SOURCE_DIR=$STAGING/source/environment
  # Copy over Miniconda/Python environment
  cp $SOURCE_DIR/$ENVTAR ./
  # Unpack environment files
  mkdir -p $ENVDIR
  tar -xzf $ENVTAR -C $ENVDIR
  rm $ENVTAR
  # Update system path
  export PATH=$(pwd)/$ENVDIR:$(pwd)/$ENVDIR/lib:$(pwd)/$ENVDIR/share:$PATH
  # Activate the conda environment
  . $ENVDIR/bin/activate
  # Localize hardcoded library filepaths
  $ENVDIR/bin/conda-unpack
}

conda_reboot () {
  # Deactivate conda environment
  . $ENVDIR/bin/deactivate
  # Remove environment files
  rm -r $ENVDIR
  # Reset PATH environment variable
  PATH=$(getconf PATH)
  # Reinitialize conda environment
  conda_setup
}

make_importable () {
  # Resolve `site-packages` directory for active Python installation
  SITE=$(python -c "import site; print(site.getsitepackages()[0])")
  # Resolve conda `.pth` file path
  PTH_FILE=${SITE}/conda.pth
  # Make code importable from packages within the input directory
  for p in "$@"; do
    echo $p >> $PTH_FILE
  done
  # NOTE: This is functionally similar to `pip install -e`, without
  #  package management overhead (e.g. installing dependencies)
}

from_yml () {
  # Shorthand to build a Conda environment from a YML file
  conda env create -f $1
}
