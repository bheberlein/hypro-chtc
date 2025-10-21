from collections import defaultdict

import re
import pandas as pd

CAPITAL = '[A-Z]'
DECIMAL = r'\d+\.\d+'
DATE = r'\d+/\d+'
TIME = r'\d+:\d+'

CONDOR_JOB_PATTERN = re.compile(r'^\s*' + r'\s+'.join((
    rf'({x})' for x in (
        DECIMAL, rf'{DATE} {TIME}', rf'\d+\+{TIME}:\d+',
        CAPITAL, *(rf'{DECIMAL} {CAPITAL}+',)*4, r'.*',
    ))) + r'$',
)

# Formatted column labels from `condor_q -pr usage.cpf`
CONDOR_JOB_COLUMNS = [
    'job_id', 'submitted', 'runtime', 'status', 'disk_request', 'disk_usage',
    'memory_request', 'memory_usage', 'command',
]


def get_factors(lines):
    """Read factors from plain text file (currently prepared manually).
    
    Returns
    -------
    disk_factors, memory_factors : tuple[float]
        ...
    
    Examples
    --------
    
    .. code-block:: text
       
       # boost_all 1.0 1.2
       6382.004
       6382.049
       6382.099
       6382.106
       6382.118
       
       # boost_all 1.0 1.2
       6382.076
       6382.107
    
    """
    job_factors = defaultdict(lambda: [1.0, 1.0])
    
    for line in lines:
        if not line:
            continue
        elif line.startswith('# boost_all'):
            disk_factor, memory_factor = list(map(float, line[12:].split(' ')))
        else:
            cluster_id, job_id = map(int, line.split('.'))
            factors = job_factors[f'{cluster_id}.{job_id:03d}']
            factors[0] *= disk_factor
            factors[1] *= memory_factor
    
    job_ids, disk_factors, memory_factors = zip(*(
        (job_id, disk_factor, memory_factor)
        for job_id, (disk_factor, memory_factor)
        in job_factors.items()
    ))
    
    return job_ids, disk_factors, memory_factors


def parse_resource_column(jobs, column):
    """Parse resource columns (e.g. disk & memory requests) from to usable values.
    
    Notes
    -----
    Input should be the text output from ``condor_q -pr usage.cpf``.
    """
    
    # Human-readable resource values (plain text)
    readable_value = jobs[column]
    # Parse resource into value & unit columns
    resource = readable_value.str.split(' ', n=2, expand=True)
    resource.columns = ['value', 'unit']
    # Get resource value & unit scale
    value = resource.value.astype(float)
    scale = resource.unit.replace({'GB': 1e9, 'MB': 1e6, 'KB': 1e3})
    # Calculate resource total bytes
    total_bytes = (value*scale).astype(int)
    
    return pd.DataFrame({
        f'{column}_readable': readable_value,
        f'{column}_decimal': value,
        f'{column}_unit': resource.unit,
        f'{column}_bytes': total_bytes,
    })


def make_readable(df):
    """Drop accessory resource columns."""
    column_groups = ('memory_request', 'memory_usage', 'disk_request', 'disk_usage')
    return df.drop(columns=[
        col for grp in column_groups
        for col in (f'{grp}_decimal', f'{grp}_unit', f'{grp}_bytes')
    ]).rename(columns={
        f'{grp}_readable': grp
        for grp in column_groups
    })


def parse_condor_status(status):
    """Parse job status from output of ``condor_q -pr usage.cpf``."""
    
    # Parse lines for each job
    lines = [line for line in status.split('\n') if line.strip()]
    
    jobs = pd.DataFrame(
        # NOTE: Skip the header & footer rows
        data=[CONDOR_JOB_PATTERN.match(line).groups() for line in lines[1:-1]],
        columns=CONDOR_JOB_COLUMNS,
    )
    
    return jobs


def process_job_status(jobs):
    
    # TODO: Add column for time of last status update
    
    # NOTE: This is specific to HyPro jobs, for which the `command` field will start with `hypro.sh `
    
    arguments = jobs.command.str[9:].str.split(expand=True)
    arguments.columns = ['site', 'isodate', 'image']
    
    arguments['image'] = arguments.image.astype(int)
    
    jobs.loc[jobs.command.str[:8] == 'hypro.sh', 'job_type'] = 'HyPro'
    
    jobs['status'] = jobs.status.replace({'R': 'ACTIVE', 'I': 'IDLE', 'H': 'HELD'})
    
    # Restructure
    jobs = pd.concat([
        jobs[['job_type', 'job_id', 'submitted', 'runtime', 'status']],
        arguments,
        parse_resource_column(jobs, 'memory_request'),
        parse_resource_column(jobs, 'memory_usage'),
        parse_resource_column(jobs, 'disk_request'),
        parse_resource_column(jobs, 'disk_usage'),
    ], axis=1)
    
    return jobs
