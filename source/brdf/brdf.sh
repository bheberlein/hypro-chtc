#!/usr/bin/bash

# :---------- DEFINE VARIABLES ----------: #

# User
GROUP=townsend_group
# File storage
STAGING=/staging/groups/townsend_airborne
# Resource directories
SOURCE_DIR=$STAGING/source/environment
PACKAGE_DIR=$STAGING/source/packages
# Python environment
ENVNAME=htconda-brdf
ENVDIR=$ENVNAME
# Packages
ENVTAR=${ENVNAME}.tar.gz
PYTAR=hyprotools_0.0.1.tar.gz

# :--------- SET UP ENVIRONMENT ---------: #

# Set up Conda/Python environment
source utils/conda.sh
conda_setup

make_importable $(pwd)/src

# :---------- PROCESSING SETUP ----------: #

cp $STAGING/source/packages/$PYTAR ./
mkdir src
tar -xzf $PYTAR -C src/ && rm $PYTAR

# Session name comes directly from command-line argument
SESSION=$1

mkdir -p data/refl/$SESSION

# Copy lines dictionary
# TODO: Auto-generate or allow user to specify alternative file
cp $STAGING/linesdict/${SESSION}_LinesDict.json data/${SESSION}_LinesDict.json
# Copy over processed reflectance images
cp $STAGING/data/processed/hypro/$SESSION/${SESSION}_*_Processed.tar.gz data/refl/$SESSION

cd data/refl/$SESSION
# Unpack HyPro outputs
for f in *.tar.gz; do
  echo "Unpacking: $f";
  tar -xzf $f && rm $f;
done

(
  # Discard radiance images, to save disk space
  shopt -s globstar;
  rm **/*_{RawRdn,MergedRadiance}{,.hdr};
)
cd -

# :----------- RUN PROCESSING -----------: #

# TODO: Handle options, e.g. `--invert-mask`, `--grouped-by-site`?
python src/enspec/processing/workflows/brdf_batch_process.py -d data/ -f data/${SESSION}_LinesDict.json --invert-mask

# :----------- PACK UP OUTPUTS ----------: #

PROCESSED_DIRECTORY=$STAGING/data/processed/brdf

# Pack outputs into .TAR.GZ archive
OUTPUT_ARCHIVE=${SESSION}_BRDF.tar.gz
tar -czf $OUTPUT_ARCHIVE -C data/brdf .

# Move outputs back to CHTC staging (NOTE: No need to remove after)
mv $OUTPUT_ARCHIVE $PROCESSED_DIRECTORY/

# :--------- MANAGE PERMISSIONS ---------: #

# Set group write permissions (important if using group storage allocation on Staging)
source utils/permissions.sh
share $GROUP 660 $PROCESSED_DIRECTORY/$OUTPUT_ARCHIVE

# -------------- CLEAN UP -------------- #

rm -r $ENVDIR
rm -r src data

exit 0