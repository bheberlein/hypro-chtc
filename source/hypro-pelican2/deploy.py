#!/usr/bin/env python3

from pathlib import Path

from enspec.ext.pelican import PelicanAccessor

# TODO: Set up enspec/condor config on execute node

DEFAULT_FEDERATION = 'uwdf-director.chtc.wisc.edu'
DEFAULT_NAMESPACE = 'fwe/townsend/Enspec'

RAW_DATA_SOURCE_DIRECTORY = Path('data/collection/airborne/raw')
DEM_DATA_SOURCE_DIRECTORY = Path('library/sites/SurfaceModels/hyspex_dems')

STAGING = Path('/staging/groups/townsend_airborne')
print(f'{STAGING.exists() = }')


class Deployment:
    """Job deployment environment with remote file access via Pelican .
    
    Todo
    ----
    #. Suppress Pelican logs in logging setup (StreamHandler)... where is that coded, anyway?
    #. Pelican RuntimeWarning
       
       In ``self._handle_token_generation(collections_url, director_response, operation)``,
       
       .. code-block:: text
          
          pelicanfs/core.py:794: RuntimeWarning: coroutine 'PelicanFileSystem._handle_token_generation' was never awaited
       
       The prompt suggests ``Enable tracemalloc to get the object allocation traceback``.
    
    #. Unclosed connection
       
       .. code-block:: text
          
          client_connection: Connection<ConnectionKey(host='marvin.russell.wisc.edu', port=8443, is_ssl=True, ssl=True, proxy=None, proxy_auth=None, proxy_headers_hash=None, server_hostname=None)>
    
    """
    
    def __init__(self, federation=DEFAULT_FEDERATION, namespace=DEFAULT_NAMESPACE):
        # Establish remote filesystem access via Pelican
        self.remote = PelicanAccessor(federation=federation, namespace=namespace)
        self.remote.connect()


class HyProDeployment(Deployment):
    
    def __init__(self, site_code, date, image_number, line_number,
                 site_name=None, project_code=None, project_name=None,
                 config_file=None, named_as=None, working_path=None, **kwargs):
        
        super().__init__(**kwargs)
        
        self.working_path = working_path or Path.cwd()
        
        # TODO: What about a lightweight `NamingScheme` or `ImageInfo` class? e.g. raw & nice basename, site code vs name, project code vs name, ...
        self.site_code = site_code
        self.site_name = site_name
        
        self.date = date
        self.isodate = self.make_isodate(date)
        
        self.image_number = image_number
        self.line_number = line_number
        
        self.project_code = project_code
        self.project_name = project_name
        
        self.config_file = config_file
        
        self.raw_basename = self.make_basename(named_as or self.site_code, self.isodate, image_number)
        self.nice_basename = self.make_basename(site_code, self.isodate, line_number)
    
    @staticmethod
    def make_isodate(date):
        return date.strftime('%Y%m%d')
    
    @staticmethod
    def make_basename(site, isodate, line_number):
        return f'{site}_{isodate}_{line_number:02d}'
    
    def get_hyspex_inputs(self, file_list, working_path=None):
        
        working_path = working_path or self.working_path
        local_data_directory = working_path / 'data'
        local_data_directory.mkdir(exist_ok=True, parents=True)
        
        for src, dst in file_list:
            # Target filepath
            target = local_data_directory / dst
            
            # try:
            # Copy data from remote
            self.remote.get_file(src, target)
            # except:
            #     pass
    
    def get_surface_model(self, working_path=None):
        
        working_path = working_path or self.working_path
        local_data_directory = working_path / 'data'
        local_data_directory.mkdir(exist_ok=True, parents=True)
        
        # dem_directory = staging / 'data/surface'
        
        remote_dem_directory = Path('library/sites/SurfaceModels/hyspex_dems')
        dem_source = remote_dem_directory / 'WI_Statewide_DEM/WI_DEM_HAE_32616_10m'
        dem_file = local_data_directory / dem_source.relative_to(remote_dem_directory)
        
        # TODO: Clip access window
        
        # NOTE: DEM must be in ENVI format
        if self.remote.has_file(dem_source):
            dem_file.parent.mkdir(exist_ok=True)
            self.remote.get_file(dem_source, dem_file)
            self.remote.get_file(dem_source.with_suffix('.hdr'),
                                 dem_file.with_suffix('.hdr'))
        
        return dem_file
    
    def get_config(self, dem_file=None, swir_pixel_size=None, target_sampling=None, config_file=None):
        
        from enspec.processing.utilities.config import make_config
        
        if config_file:
            # Use pre-generated configuration
            pass
        else:
            config_file = Path.cwd() / f'{self.nice_basename}_Config.json'
            
            make_config(config_file,
                        dem_file=dem_file,
                        swir_pixel_size=swir_pixel_size,
                        target_sampling=target_sampling)
        
        return config_file
    
    def copy_outputs(self):
        # remote_output = 'users/bheberlein/data/pelican-output'
        
        remote_processed_dir = 'data/processed/airborne'
        relpath = f'{self.project_name}/{self.date.year}/{self.isodate}/{self.nice_basename}'
        remote_output = f'{remote_processed_dir}/{relpath}'
        
        # TODO: Test
        self.remote.fs.mkdir(self.remote.get_remote_url(remote_output))
        
        # Transfer output directories
        for d in ('merge', 'swir', 'vnir'):
            
            local_directory = Path(f'output/{self.nice_basename}/{d}')
            remote_directory = self.remote.get_remote_url(f'{remote_output}/{d}')
            
            print(f'Transferring: "{local_directory.as_posix()}" → "{remote_directory}"')
            
            self.remote.fs.put(local_directory, remote_directory, recursive=True)
    
    def cleanup(self):
        pass
    
    def run(self, hyspex_files, **options):
        
        # Copy HySpex images & navigation data
        self.get_hyspex_inputs(hyspex_files)
        # Copy surface elevation model
        # TODO: Specify input DEM
        dem_file = self.get_surface_model()
        
        from hypro.workflow.main import main as run_hypro
        
        # Copy or prepare HyPro configuration file
        config_file = self.get_config(dem_file=dem_file, **options)
        # Run reflectance processing
        run_hypro(config_file)
        
        # Copy processed outputs to storage drive
        self.copy_outputs()
        
        # Clean up workspace before exit
        self.cleanup()


def list_input_files(raw_session, nice_session, isodate, image_number, line_number, vdatum):
    """Generator for raw file list of ``(source, target)`` file names."""
    
    SENSORS = ('SWIR_384_SN3142', 'VNIR_1800_SN00840')
    
    def _core_files(name, vdatum):
        return f'{name}.hyspex', f'{name}.hdr', f'nav_{vdatum}/{name}.txt'
    
    for sensor in SENSORS:
        
        # File basename
        name = f'{raw_session}_{isodate}_{image_number:02d}_{sensor}_raw'
        # Nicer file naming
        renamed = f'{nice_session}_{isodate}_{line_number:02d}_{sensor}_raw'
        
        yield from zip(_core_files(name, vdatum), _core_files(renamed, vdatum))


def get_source_directory(basename, acquisition_date, data_directory=RAW_DATA_SOURCE_DIRECTORY):
    
    isodate = acquisition_date.strftime('%Y%m%d')
    session = f'{basename}_{isodate}'
    session_directory = data_directory / f'{acquisition_date.year}/{isodate}/{session}'
    
    return session_directory


def resolve_input_files(files, source_directory, target_directory):
    return [(source_directory / src_name, target_directory / Path(tgt_name).name)
            for src_name, tgt_name in files]


def list_input_batches(target_directory, raw_basename, nice_basename, date,
                       image_number_first, image_number_last, vdatum='ellipsoid'):
    
    session_directory = get_source_directory(raw_basename, date, data_directory=RAW_DATA_SOURCE_DIRECTORY)
    
    isodate = date.strftime('%Y%M%D')
    
    for i, k in enumerate(range(image_number_first, image_number_last+1)):
        yield resolve_input_files(
            list_input_files(raw_basename, nice_basename, isodate, k, i+1, vdatum),
            session_directory, target_directory
        )


def main(site_code, flight_date, image_number, line_number, swir_pixel_size,
         raw_basename='FLIGHT', vdatum='ellipsoid', target_sampling='highest',
         site_name=None, project_code=None, project_name=None, local_data_directory=None):
    
    isodate = flight_date.strftime('%Y%m%d')
    
    # Remote source directory for raw imaging session data
    session_directory = get_source_directory(raw_basename, flight_date, data_directory=RAW_DATA_SOURCE_DIRECTORY)
    
    # Get source & target names of input files to transfer
    file_names = list(list_input_files(raw_basename, site_code, isodate, image_number, line_number, vdatum))
    # Resolve input file source & target paths
    files = resolve_input_files(file_names, session_directory, local_data_directory)
    
    job = HyProDeployment(
        site_code, flight_date, image_number, line_number, named_as=raw_basename,
        site_name=site_name, project_code=project_code, project_name=project_name,
    )
    
    job.run(files, swir_pixel_size=swir_pixel_size, target_sampling=target_sampling)


if __name__ == '__main__':
    
    import argparse
    from datetime import datetime
    
    # : ------------------------------------------ :
    
    parser = argparse.ArgumentParser()
    
    parser.add_argument('--date', type=str, required=True)
    
    parser.add_argument('--site-code', type=str, required=True)
    parser.add_argument('--site-name', type=str, required=False, default=None)
    parser.add_argument('--project-code', type=str, required=False)
    parser.add_argument('--project-name', type=str, required=True)
    parser.add_argument('--raw-basename', type=str, default='FLIGHT')
    
    parser.add_argument('--image-number', type=int, required=True)
    parser.add_argument('--line-number', type=int, required=False, default=None)
    
    parser.add_argument('--swir-pixel-size', type=float, required=True)
    parser.add_argument('--target-sampling', type=str, default='highest')
    
    parser.add_argument('--vdatum', type=str, default='ellipsoid')
    
    args = parser.parse_args()
    
    # : ------------------------------------------ :
    
    if args.line_number is None:
        args.line_number = args.image_number
    
    local_data_directory = Path.cwd() / 'data'
    
    flight_date = datetime.strptime(args.date, '%Y%m%d').date()
    
    main(
        args.site_code, flight_date,
        args.image_number, args.line_number,
        args.swir_pixel_size,
        raw_basename=args.raw_basename,
        vdatum=args.vdatum,
        target_sampling=args.target_sampling,
        site_name=args.site_name,
        project_code=args.project_code,
        project_name=args.project_name,
        local_data_directory=local_data_directory
    )
