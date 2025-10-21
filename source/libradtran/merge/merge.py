import argparse

from pathlib import Path

from lut.build import build_tile


def parse_basename(basename):
    parts = basename.split('_')
    elev = int(parts[1])
    zout = int(parts[3])
    sza = int(parts[5])
    return elev, zout, sza


def main(basename):
    data_directory = Path('./raw/')
    output_directory = data_directory.parent/'tiles'
    output_directory.mkdir(exist_ok=True)
    elev, zout, sza = parse_basename(basename)
    build_tile(elev, zout, sza, data_directory, output_directory=output_directory)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-n', '--name', type=str, help='LUT tile basename ("ELEV_*_ZOUT_*_SZA_*").')
    args = parser.parse_args()
    
    main(args.name)
