#!/bin/bash
# version.sh
# Called inside container by metadata.sh
# Usage: bash version.sh <BUILD_DATE> <SIF_FILE> <SIF_CHECKSUM> <DEF_FILE> <DEF_CHECKSUM>

BUILD_DATE="$1"
SIF_FILE="$2"
SIF_CHECKSUM="$3"
DEF_FILE="$4"
DEF_CHECKSUM="$5"

# Check operating system
OS=$(awk -F= "/^PRETTY_NAME/{gsub(/\"/,\"\",\$2); print \$2}" /etc/os-release)

# Check software versions for libRadtran & dependenceis
GCC_VERSION=$(gcc -dumpfullversion 2>/dev/null || echo unknown)
GSL_VERSION=$(/opt/local/bin/gsl-config --version 2>/dev/null || echo unknown)
HDF5_VERSION=$(/opt/local/bin/h5cc -showconfig 2>/dev/null | grep 'HDF5 Version' | awk '{print $NF}' || echo unknown)
LIBRADTRAN_VERSION=$(uvspec -version 2>&1 | sed -n 's/^uvspec, version //p' | awk '{print $1}' || echo unknown)
NETCDFC_VERSION=$(/opt/local/bin/nc-config --version 2>/dev/null | awk '{print $NF}' || echo unknown)
NETCDFF_VERSION=$(/opt/local/bin/nf-config --version 2>/dev/null | awk '{print $NF}' || echo unknown)

cat <<EOF
{
  "software": {
    "metadata": {
      "type": "container::apptainer",
      "file": "$SIF_FILE",
      "build_date": "$BUILD_DATE",
      "checksum": "$SIF_CHECKSUM",
      "source": {
        "file": "$DEF_FILE",
        "checksum": "$DEF_CHECKSUM"
      }
    },
    "environment": {
      "os": "$OS",
      "compiler": "GCC"
    },
    "version": {
      "gcc": "$GCC_VERSION",
      "gsl": "$GSL_VERSION",
      "hdf5": "$HDF5_VERSION",
      "libradtran": "$LIBRADTRAN_VERSION",
      "netcdf_c": "$NETCDFC_VERSION",
      "netcdf_fortran": "$NETCDFF_VERSION"
    }
  }
}
EOF
