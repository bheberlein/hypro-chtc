
## Interactive Testing Job

### Job Package Creation

Package up the `enspec` & `hytools` source code:
```bash
tar -czf hyprotools_0.0.1.tar.gz -C git/enspec/src enspec -C ../../hytools hytools
```

Prepare a Conda environment using the following YML definition:


```bash
source utils/conda.sh
conda_build htconda-brdf htconda-brdf.yml
```

Then put the packages in place on Staging:
```bash
mv hyprotools_0.0.1.tar.gz /staging/groups/townsend_airborne/source/packages
mv htconda-brdf.tar.gz /staging/groups/townsend_airborne/source/environment
```


### Processing

```bash
# NOTE: This session has 4 images, matching the requested number of CPU cores
SESSION=TFCF_20240918
````

Write the following into `data/${SESSION}_LinesDict.json`:
```json
{
  "TFCF_20240918": [1, 2, 3, 4]
}
```


```bash
condor_submit -i git/hypro-chtc/source/interact/interact.sub disk=120GB memory=45GB request_cpus=4
```
