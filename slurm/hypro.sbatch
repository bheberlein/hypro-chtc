#!/bin/sh
#SBATCH --job-name="HyPro"
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=35G
#SBATCH --partition=aerosol
#SBATCH --time=20:00:00
#SBATCH --output=logs/%x_%A_%a_%j.out
#SBATCH --error=logs/%x_%A_%a_%j.err

PARAMETERS_FILE=${SESSION}_SlurmJobList.txt

ENVDIR=htconda

LAKEVIEW=/ships19/hercules/LakeView
SCRATCH=/scratch/tmp/$SESSION/$FLIGHTLINE

# Activate Python environment
export PATH=$(pwd)/$ENVDIR:$(pwd)/$ENVDIR/lib:$(pwd)/$ENVDIR/share:$PATH
. $ENVDIR/bin/activate

mkdir -p $SCRATCH/{data,output}

cp $LAKEVIEW/raw/$SESSION/${FLIGHTLINE}_* $SCRATCH/data

# Make HyPro modules importable
source utils/conda.sh
make_importable $(pwd)/hypro/src

# Determine grid rotation
ORIENTATION=$(awk -v ArrayTaskID=1 '$1==ArrayTaskID {print $3}' $PARAMETERS_FILE)

# Run processing
python hypro/src/hypro/workflow/main.py LAKE_Config.json --lines $SLURM_ARRAY_TASK_ID --rotation $ORIENTATION


OUTPUT=$LAKEVIEW/processed/$SESSION

mv output $OUTPUT
rm -r $SCRATCH

exit
