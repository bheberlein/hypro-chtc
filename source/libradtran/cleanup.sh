#!/bin/bash

STAGING=/staging/groups/townsend_airborne
PREFIX=$STAGING/data/lut/raw

if [[ $1 ]]; then
  (
    shopt -s nullglob
    for out in $PREFIX/${1}_*.out; do
      # Remove libRadtran output
      rm $out
    done
    for err in $PREFIX/${1}_*.err; do
      # Only remove error file if it is empty
      [[ ! -s "$FILE" ]] && rm $err
    done
  )
fi
