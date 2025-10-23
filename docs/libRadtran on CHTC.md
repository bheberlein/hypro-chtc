# Deploying libRadtran on CHTC

## Batch LUT Generation

```shell
condor_submit_dag $DAG_FILE
```

## Standalone Jobs

For single processing runs, or tasks that do not fit neatly into the batch LUT generation framework, you may want to use libRadtran directly.

> **NOTE:** For batch generation of lookup tables (LUTs) with libRadtran, it is recommended to use the [batch workflow](#batch-lut-generation) that relies on HTCondor's DAGMan. 

### Apptainer Workflow

### Building the Apptainer Image

> **NOTE:** CHTC asks that build jobs be run **only as interactive jobs**.

1. Navigate to the repo directory:

   ```shell
   cd git/hypro-chtc
   ```

2. Submit the build job, making sure to use `condor_submit -i` so that it runs as an interactive job:

   ```shell
   condor_submit -i source/libradtran/apptainer/build.sub
   ```

   > **NOTE:** You can also submit from e.g. your user home directory by specifying `initialdir`, e.g.
   >
   > ```shell
   > REPO_DIR=git/hypro-chtc
   > condor_submit -i $REPO_DIR/source/libradtran/apptainer/build.sub initialdir=$REPO_DIR/
   > ```
   > 
   > In this case, there is no need to `cd` into the repository first.

3. Wait for the remote session to start.

4. Build the container image on the worker node. This may take some time (approx. 10 – 20 minutes).

     ```shell
     apptainer build libradtran.sif libradtran.def > build.log 2>&1
     ```

5. Generate container metadata.

   ```shell
   bash metadata.sh
   ```

6. Clean up & transfer outputs.

   - Fetch the checksum hashes for the container & definition file:

     ```shell
     CONTAINER_SHA=$(jq -r '.software.metadata.checksum' versions.json)
     DEFINITION_SHA=$(jq -r '.software.metadata.source.checksum' versions.json)
     ```

   - Append the container & definition SHA to the build log:

     ```shell
     echo "container_sha = $CONTAINER_SHA" >> build.log
     echo "definition_sha = $DEFINITION_SHA" >> build.log
     ```

   - Copy & rename the compiled container image & logs to Staging:

     ```shell
     # Target location on Staging 
     STAGING=/staging/groups/townsend_airborne
     OUTPUT_DIR=$STAGING/source/libradtran
     # Output file basename
     BASENAME=libradtran.${CONTAINER_SHA::10}
     # Copy & rename
     cp libradtran.sif $OUTPUT_DIR/
     cp build.log $OUTPUT_DIR/$BASENAME.log
     cp versions.json $OUTPUT_DIR/$BASENAME.json
     ```

   - Finally, exit the job:

     ```shell
     exit
     ```

## Merging Outputs

There are some limitations to the ways in which parameters can be passed to libRadtran's `uvspec` command. In particular, certain parameters can only take a single fixed value per processing run. This means that outputs from many jobs must be assembled into finalized LUT tiles of reasonable size.  The current LUT tiling scheme builds 1 finalized tile from the combined outputs of 180 processing jobs.

The output merging workflow is agnostic to the workflow chosen to generate the `uvspec` output files, as long as they are unmodified raw outputs & the processing has completed normally.

