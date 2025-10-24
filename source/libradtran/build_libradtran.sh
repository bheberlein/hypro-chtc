#!/usr/bin/bash

# : ------------------------------------------------------------------------- :
# Script Name: build_libradtran.sh
# Description: Build libRadtran software package for remote deployment.
# Usage:       ./build_libradtran.sh
# Author:      Brendan Heberlein
# Date:        2025-01-23
# : ------------------------------------------------------------------------- :

STAGING=/staging/groups/townsend_airborne

LOCAL=$(pwd)
mkdir $LOCAL/{packages,software,compiled}
mkdir $LOCAL/software/{gsl,netcdf,libradtran}

SOFTWARE_DIR=$LOCAL/software
cd $SOFTWARE_DIR

# : --- COMPILE GSL --- :

# Download GSL libraries
wget https://mirror.ibcp.fr/pub/gnu/gsl/gsl-latest.tar.gz
# tar -xzf gsl-latest.tar.gz
# # Resolve GSL directory path
# mv $(find $SOFTWARE_DIR -name 'gsl-*' -type d) $SOFTWARE_DIR/gsl
tar -xzf gsl-latest.tar.gz --transform s/^gsl-[0-9]\.[0-9]/gsl/

(
  # Change working directory within subshell
  cd gsl
  # Generate GSL Makefile
  ./configure --prefix=$LOCAL/compiled/gsl
  # Compile GSL with all available CPU cores
  make -j$(nproc)
  # Install compiled binaries
  make install
) > gsl-compile.log

# : --- GET NETCDF --- :

UCAR=https://downloads.unidata.ucar.edu
NETCDF_VERSION=4.9.2
NETCDF_PACKAGE=netcdf-c-$NETCDF_VERSION

wget $UCAR/netcdf-c/$NETCDF_VERSION/$NETCDF_PACKAGE.tar.gz
tar -xzf $NETCDF_PACKAGE.tar.gz --transform s/^$NETCDF_PACKAGE/netcdf/

(
  export CPPFLAGS=-I$LOCAL/compiled/netcdf/include
  export LDFLAGS=-L$LOCAL/compiled/netcdf/lib
  cd netcdf
  ./configure --prefix=$LOCAL/compiled/netcdf
  make check install
) > netcdf-compile.log

# NOTE: Test with `nc-config --help`

# : --- COMPILE LIBRADTRAN --- :

# NOTE: Add `history/` prefix for old archived distributions
LIBRADTRAN_PACKAGE=libRadtran-2.0.6

# Download libRadtran
wget https://www.libradtran.org/download/$LIBRADTRAN_PACKAGE.tar.gz
tar -xzf $LIBRADTRAN_PACKAGE.tar.gz --transform s/^$LIBRADTRAN_PACKAGE/libradtran/

(
  # Set GSL paths so compiler can find them
  export CPPFLAGS="-I$LOCAL/compiled/gsl/include"
  export LDFLAGS="-L$LOCAL/compiled/gsl/lib"
  
  # Register shared libraries path
  if [ -v LD_LIBRARY_PATH ]; then
    export LD_LIBRARY_PATH=$LOCAL/compiled/gsl/lib/:$LD_LIBRARY_PATH
  else
    export LD_LIBRARY_PATH=$LOCAL/compiled/gsl/lib/
  fi
  
  # Change working directory within subshell
  cd libradtran
  # Generate libRadtran Makefile
  ./configure --with-libnetcdf=$LOCAL/compiled/netcdf
  # Compile libRadtran
  # NOTE: Must use GNU Make, try `make --version` to check
  make
  # Run tests
  make check
) > libradtran-compile.log

  # TODO: GSL not being found?
  # >>> make[1]: Entering directory '/var/lib/condor/execute/slot3/dir_257979/software/libradtran/src'
  # >>> flex  -o uvspec_lex.c ../src_py/uvspec_lex.l
  # >>> gawk 'NF==2{print "#define "$1" "$2}' sbtaugas.param > sbtaugas.h
  # >>> make[1]: *** No rule to make target '/opt/local/include/gsl/gsl_math.h', needed by 'angres.o'.  Stop.
  # >>> make[1]: Leaving directory '/var/lib/condor/execute/slot3/dir_257979/software/libradtran/src'
  # >>> make: *** [Makefile:39: all] Error 2

alias uvspec="$SOFTWARE_DIR/libradtran/bin/uvspec"

# : --- ADDITIONAL FEATURES --- :

# TODO: What about extras, like TENSTREAM or HAMSTER?
# https://www.meteo.physik.uni-muenchen.de/~libradtran/lib/exe/fetch.php?media=download:tenstream_lookup.tar.gz
# https://www.meteo.physik.uni-muenchen.de/~libradtran/lib/exe/fetch.php?media=download:hamster_1140_720.tar.gz

REPTRAN_PACKAGE=reptran-2024-all.tar.gz
#curl "https://www.meteo.physik.uni-muenchen.de/~libradtran/lib/exe/fetch.php?media=download:reptran_2024_all.tar.gz" -o $REPTRAN_PACKAGE
wget 'https://www.meteo.physik.uni-muenchen.de/~libradtran/lib/exe/fetch.php?media=download:reptran_2024_all.tar.gz' -O $REPTRAN_PACKAGE
# NOTE: Some files already exist in data/reptran
tar -xzf $REPTRAN_PACKAGE -C $SOFTWARE_DIR/libradtran

# : --- CONSTRUCT PACKAGE --- :

tar -czf libradtran.tar.gz compiled software
cp libradtran.tar.gz $STAGING/source/packages
