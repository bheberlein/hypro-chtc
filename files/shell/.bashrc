export STAGING=/staging/groups/townsend_airborne

ENVNAME=htconda-brdf
export ENVDIR=$HOME/conda/envs/$ENVNAME

export CHTC_REPO=$HOME/git/hypro-chtc
source $CHTC_REPO/utils/htcondor.sh

export ENSPEC_REPO=$HOME/git/enspec

SRC=$CHTC_REPO/source
