#!/bin/bash

STAGING=/staging/groups/townsend_airborne

[[ $1 ]] && rm $STAGING/data/lut/raw/${1}_*.out
