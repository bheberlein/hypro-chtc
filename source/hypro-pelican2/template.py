import argparse

from pathlib import Path

from jinja2 import Template


def main(template_file, package, source_dir):
    
    if isinstance(source_dir, Path):
        # We want source directory path as a string since it will be passed to Jinja
        source_dir = source_dir.as_posix()
    
    if not isinstance(template_file, Path):
        # We want template file as a Path for convenience
        template_file = Path(template_file)
    
    template_string = template_file.read_text()
    template = Template(template_string)
    
    # Render by passing keyword arguments directly
    output = template.render(package=package, path=source_dir)
    
    output_file = template_file.with_suffix(template_file.suffix.replace('.jnja', ''))
    
    with open(output_file, mode='w') as f:
        f.write(output)


if __name__ == '__main__':
    
    parser = argparse.ArgumentParser()
    parser.add_argument('--template', required=True)
    parser.add_argument('--name', required=True)
    parser.add_argument('--path', required=True)
    
    args = parser.parse_args()
    
    main(args.template, args.name, args.path)
