from pathlib import Path


def repair_joblist(joblist_file):
    """Add spaces & leading zeros to a joblist file.
    
    Examples
    --------
    
    .. code-block:: python
       
       joblist_directory = Path('/staging/groups/townsend_airborne/joblist')
       repair_joblist(joblist_directory/'LAKE_2024_H120_JobList.txt')
    
    """
    
    joblist_file = Path(joblist_file)
    
    if not joblist_file.exists():
        raise FileNotFoundError(joblist_file)
    
    input_joblist = joblist_file.with_suffix(joblist_file.suffix + '.bak')
    joblist_file.rename(input_joblist)
    
    with open(input_joblist, mode='r') as f, open(joblist_file, mode='w+') as g:
        for line in f.readlines():
            parts = [part.strip() for part in line.split(',')]
            parts[2] = f'{int(parts[2]):02d}'
            g.write(', '.join(parts)+'\n')
