
### Manually Edit Job Resource Requirements

1. Use `condor_q $job_id -af HoldReason` to determine whether it is the disk or memory request that needs to be increased (or both).

2. Check the current usage of the job using `condor_q` to query either the `DiskUsage` or `MemoryUsage` of the job:
   
   ```shell
   condor_q $job_id -af DiskUsage
   ```
   
   **Note that the reported units will be different for disk (MiB) vs. memory (KiB).**

3. Determine boosting factors for disk & memory. To leave either one unchanged, pass a value of `1` or `1.0`.
   
   - Usually a 10–30% increase will be sufficient to get the job to complete successfully; often, you can just go for a boost factor of 1.2 (20% increase).

4. Use `condor_qedit` to update the resource requests by modifying either the `RequestDisk` or `RequestMemory` job attributes:
   
   ```shell
   condor_qedit $job_id RequestDisk $disk_request
   ```
   
   where `$disk_request` is the updated disk resource request, calculated by multiplying the original request by the boosting factor. Or, if this value is still less than the current disk usage of the job as reported by `condor_q`, instead multiply the current usage by the boot factor.

5. Release the job with `condor_release`:
   
   ```shell
   condor_release $job_id
   ```

   The job will return to the queue in an idle state & wait to be matched with a machine for job execution.
