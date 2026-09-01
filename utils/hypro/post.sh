tidy_hypro_outputs () {

  VNIR_SENSOR=VNIR_1800_SN00840
  SWIR_SENSOR=SWIR_384_SN3142

  # TODO: Not sure if all the renaming & reorganizing is appropriate; maybe change the way HyPro does it instead?
  # TODO: It might be conceptually cleaner to just delete the files you don't want to keep? Could even do this in HyPro

  # Remove atmospheric database files
  rm -r output/$FLIGHTLINE/atm
  # Remove single-sensor products from merged directory
  rm output/$FLIGHTLINE/merge/${FLIGHTLINE}_{VNIR,SWIR}_*
  # Remove temporary files from orthorectification
  rm output/${FLIGHTLINE}/{vnir,swir}/OrthorectifiedImageData{,.hdr,.aux.xml}

  mkdir $FLIGHTLINE

  # Processing log
  mv output/*.log $FLIGHTLINE/
  # Merged orthorectified imagery & ancillary datasets
  mv output/$FLIGHTLINE/merge/* $FLIGHTLINE/

  if [ $KEEP_RDN = 0 ]; then
    rm $FLIGHTLINE/${FLIGHTLINE}_MergedRadiance{,.hdr}
  fi

  # Single-sensor products
  for SENSOR in VNIR_SENSOR SWIR_SENSOR; do
    mkdir $FLIGHTLINE/$SENSOR
    SENSOR_DIRECTORY=output/$FLIGHTLINE/${SENSOR,,}

    # Filepath prefix
    PREFIX=$SENSOR_DIRECTORY/${FLIGHTLINE}_${SENSOR}_*_FOVx2

    # Smile effect model
    mv ${PREFIX}_SmileEffect{,AtAtmFeatures}{,.hdr} $FLIGHTLINE/$SENSOR
    # Water vapor model
    mv ${PREFIX}_WVCModel.json $FLIGHTLINE/$SENSOR
    # Plots & figures
    mv ${PREFIX}_*.png $FLIGHTLINE/$SENSOR

    # Data footprint
    mv ${PREFIX}_DataFootprint{,CoReg}.{dbf,prj,sh[px]} $FLIGHTLINE/$SENSOR

    # Raw sensor products
    if [ $KEEP_RAW = 1 ]; then
      mv ${PREFIX}_IGM{,.hdr} $FLIGHTLINE/$SENSOR
      mv ${PREFIX}_PreClass{,.hdr} $FLIGHTLINE/$SENSOR
      mv ${PREFIX}_ProcessedNavData.txt $FLIGHTLINE/$SENSOR
      mv ${PREFIX}_RadioCaliCoeff{,.hdr} $FLIGHTLINE/$SENSOR
      mv ${PREFIX}_Raw{Rdn,PathLength,SCA}{,.hdr,.aux.xml} $FLIGHTLINE/$SENSOR
    fi

    # Coregistration files
    # NOTE: Use subshell to localize `shopt`
    (
      shopt -s nullglob
      for f in ${PREFIX}_*CoRegPoints.{csv,png} \
               ${PREFIX}_*{,Corrected}{IGM,RawSCA}{,.hdr,.aux.xml} \
               ${PREFIX}_CoregistrationShifts{,.hdr}; do
        mv $f $FLIGHTLINE/$SENSOR
      done
    )
  done
}