#!/usr/bin/bash

REPO=~/git/hypro-chtc

# Update Bash configuration
cat $REPO/files/shell/.bashrc >> ~/.bashrc

# Install Miniconda
. $REPO/utils/conda.sh
conda_install

# Create directory structure
mkdir -p ~/logs/{hypro,brdf,test}

# Import HTCondor utilities
. $REPO/utils/htcondor.sh
