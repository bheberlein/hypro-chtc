#!/bin/bash

STAGING=/staging/groups/townsend_airborne

[[ -v 1 ]] && rm $STAGING/data/lut/raw/${1}_*.out
