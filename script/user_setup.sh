#!/usr/bin/bash

# Update Bash configuration
cat $CHTC_REPO/files/shell/.bashrc >> ~/.bashrc

# Install Miniconda
. $CHTC_REPO/utils/conda.sh
conda_install

# Create directory structure
mkdir -p ~/logs/{hypro,brdf,test}
# Symlink shell utilities
ln -s $CHTC_REPO/utils utils

# Import HTCondor utilities
. $CHTC_REPO/utils/htcondor.sh
