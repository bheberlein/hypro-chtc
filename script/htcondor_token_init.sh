#!/usr/bin/env bash

user=bheberlein
access_point=townsend-ap2000.chtc.wisc.edu

mkdir -p ~/.condor/tokens.d
ssh ${user}@${access_point} condor_token_fetch > ~/.condor/tokens.d/${access_point%%.*}
chmod 600 ~/.condor/tokens.d/*
