#!/usr/bin/env python3

import subprocess
import glob
from pathlib import Path
import sys
import argparse
import os

def check_file_integrity(filepath: str, verbose: bool = False) -> tuple[bool, str | None]:
    """Check the integrity of a media file using ffmpeg."""
    try:
        output = subprocess.check_output(
            ["ffmpeg", "-v", "error", "-i", filepath, "-f", "null", "-"],
            stderr=subprocess.STDOUT,
            universal_newlines=True
        )
        is_valid = not bool(output)
        if verbose:
            print(f"{filepath} ... {'ok' if is_valid else 'ERROR'}")
        elif not is_valid:
            print(f"{filepath} ... ERROR")
        return is_valid, output if output else None
    except subprocess.CalledProcessError as e:
        if verbose or True:  # Always print errors
            print(f"{filepath} ... ERROR")
        return False, e.output
    except FileNotFoundError:
        print("Error: ffmpeg not found. Please install ffmpeg first.")
        sys.exit(1)

def find_media_files(paths: list[str]) -> list[str]:
    """
    Find all supported media files from given paths.
    Paths can be files or directories.
    """
    extensions = ('.mp3', '.m4a', '.m4v', '.mov', '.mp4')
    files = set()  # Use set to avoid duplicates
    
    for path in paths:
        path = os.path.abspath(path)
        if os.path.isfile(path):
            if path.lower().endswith(extensions):
                files.add(path)
        else:  # Directory
            for ext in extensions:
                pattern = os.path.join(path, f"**/*{ext}")
                files.update(glob.glob(pattern, recursive=True))
    
    return sorted(files)

def main():
    parser = argparse.ArgumentParser(description='Check media file integrity using ffmpeg')
    parser.add_argument('paths', nargs='*', default=['.'],
                      help='Files or directories to check (default: current directory)')
    parser.add_argument('--verbose', action='store_true',
                      help='Print status for all files, not just errors')
    parser.add_argument('-y', '--yes', action='store_true',
                      help='Skip confirmation prompt')
    args = parser.parse_args()

    # Check if ffmpeg is installed
    try:
        subprocess.run(["ffmpeg", "-version"], capture_output=True)
    except FileNotFoundError:
        print("Error: ffmpeg is not installed. Please install it first.")
        sys.exit(1)

    # Find media files
    files = find_media_files(args.paths)
    file_count = len(files)

    if file_count == 0:
        print("No media files found.")
        sys.exit(0)

    # Show summary and prompt for confirmation
    paths_str = "current directory" if args.paths == ['.'] else ", ".join(args.paths)
    print(f"Found {file_count} media files in {paths_str}")
    
    if not args.yes:
        response = input("Do you want to proceed? [y/N] ")
        if response.lower() != 'y':
            print("Aborted.")
            sys.exit(0)

    # Process files
    errors = 0
    try:
        for filepath in files:
            is_valid, error = check_file_integrity(filepath, args.verbose)
            if not is_valid:
                errors += 1
                
        print(f"\nProcessed {file_count} files, found {errors} errors.")
        sys.exit(1 if errors > 0 else 0)

    except KeyboardInterrupt:
        print("\nProcess interrupted by user")
        sys.exit(130)

if __name__ == "__main__":
    main()
