#!/bin/bash

STAGING=/staging/groups/townsend_airborne
PREFIX=$STAGING/data/lut/raw

[[ $1 ]] && rm $PREFIX/${1}_*.out
