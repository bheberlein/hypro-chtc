#!/bin/bash

STAGING=/staging/groups/townsend_airborne

ENVNAME=impute
. utils/conda.sh
conda_setup

PACKAGE_DIR=$STAGING/source/packages
HYPROTAR=hypro_1.0.1dev5.tar.gz

cp $PACKAGE_DIR/$HYPROTAR ./
source utils/archive.sh
unpack $HYPROTAR

# TODO: `numpy.tostring()` in `hypro.Radiometry`
sed -i 's/.tostring()/.tobytes()/g' src/hypro/Radiometry.py

make_importable $(pwd)/src/

mkdir -p data/raw output/rdn

# Resolve command-line arguments
BASENAME=$1
SENSOR=VNIR_1800_SN00840_FOVx2

# Transfer input data
cp $STAGING/data/imputed/input/${BASENAME}_${SENSOR}_raw.* data/raw/

# Run gross linear sensor artifact correction workflow
python -m enspec.processing.workflows.impute --name $BASENAME ${@:2}

# Resolve output directory
if [[ ! -v OUTPUT_DIRECTORY ]]; then
  OUTPUT_DIRECTORY=$STAGING/data/imputed/output
fi

echo "Copy to: $OUTPUT_DIRECTORY"

# Transfer outputs
mkdir -p $OUTPUT_DIRECTORY/$BASENAME
cp -r output/* $OUTPUT_DIRECTORY/$BASENAME/

# Clean up
rm -r $ENVDIR/ utils/ src/ data/ output/
