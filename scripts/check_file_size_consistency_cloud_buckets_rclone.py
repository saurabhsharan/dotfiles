#!/usr/bin/env python3

# Verifies that files with the same name have the same file size across different cloud buckets.
# Usage: ./check_file_size_consistency_cloud_buckets_rclone.py <rclone-bucket-1> <rclone-bucket-2>

import subprocess
import sys
from collections import defaultdict
from typing import Dict, List, Tuple

def parse_rclone_output(output: str) -> Dict[str, int]:
    """Parse rclone ls output and return a dictionary of filename to size mappings."""
    files = {}
    for line in output.splitlines():
        if not line.strip():
            continue
        # Split on first space to separate size from filename
        parts = line.strip().split(' ', 1)
        if len(parts) != 2:
            continue
        size_str, filename = parts
        try:
            size = int(size_str)
            files[filename] = size
        except ValueError:
            print(f"Warning: Could not parse size for line: {line}", file=sys.stderr)
    return files

def get_bucket_contents(bucket: str) -> Dict[str, int]:
    """Run rclone ls for given bucket and return parsed results."""
    try:
        result = subprocess.run(['rclone', 'ls', bucket],
                              capture_output=True,
                              text=True,
                              check=True)
        return parse_rclone_output(result.stdout)
    except subprocess.CalledProcessError as e:
        print(f"Error running rclone for bucket {bucket}: {e}", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error processing bucket {bucket}: {e}", file=sys.stderr)
        sys.exit(1)

def compare_buckets(buckets: List[str]) -> List[Tuple[str, Dict[str, int]]]:
    """
    Compare files across multiple buckets and return list of files with size conflicts.
    Returns list of (filename, {bucket: size}) for files with differing sizes.
    """
    # Dictionary to store all sizes seen for each file
    file_sizes = defaultdict(dict)

    # Collect all file sizes from all buckets
    for bucket in buckets:
        contents = get_bucket_contents(bucket)
        for filename, size in contents.items():
            file_sizes[filename][bucket] = size

    # Find files with different sizes
    conflicts = []
    for filename, sizes in file_sizes.items():
        if len(sizes) > 1 and len(set(sizes.values())) > 1:
            conflicts.append((filename, sizes))

    return conflicts

def main():
    if len(sys.argv) < 2:
        print("Usage: script.py bucket1 [bucket2 ...]")
        sys.exit(1)

    buckets = sys.argv[1:]
    conflicts = compare_buckets(buckets)

    if not conflicts:
        print("All files are the same size")
    else:
        print("Files with different sizes across buckets:")
        for filename, sizes in conflicts:
            print(f"\nFile: {filename}")
            for bucket, size in sizes.items():
                print(f"  {bucket}: {size:,} bytes")

if __name__ == "__main__":
    main()
