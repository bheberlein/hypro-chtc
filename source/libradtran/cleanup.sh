#!/bin/bash

STAGING=/staging/groups/townsend_airborne
PREFIX=$STAGING/data/lut/raw

if [[ $1 ]]; then
  rm $PREFIX/${1}_*.out
fi
