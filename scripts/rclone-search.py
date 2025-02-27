#!/usr/bin/env python3
import sys
import subprocess
from typing import List, Tuple
from collections import defaultdict

def search_bucket(query: str, bucket: str) -> List[Tuple[str, str]]:
    """
    Search a single bucket for files matching the query.
    Returns a list of (bucket, filename) tuples for matches.
    """
    try:
        # Run rclone ls command
        result = subprocess.run(
            ['rclone', 'ls', bucket],
            capture_output=True,
            text=True,
            check=True
        )

        # Process each line of output
        matches = []
        for line in result.stdout.splitlines():
            # rclone ls output format is: "   <size> <filename>"
            # Split on first space after size to get filename
            parts = line.strip().split(None, 1)
            if len(parts) < 2:
                continue

            filename = parts[1]
            if query.lower() in filename.lower():
                matches.append((bucket, filename))

        return matches

    except subprocess.CalledProcessError as e:
        print(f"Error searching bucket {bucket}:", file=sys.stderr)
        print(f"  {e.stderr.strip()}", file=sys.stderr)
        return []
    except Exception as e:
        print(f"Unexpected error searching bucket {bucket}: {e}", file=sys.stderr)
        return []

def main():
    # Check arguments
    if len(sys.argv) < 3:
        print("Usage: search_clouds.py <search_query> <bucket1> [bucket2 ...]")
        sys.exit(1)

    query = sys.argv[1]
    buckets = sys.argv[2:]

    print(f"Searching for '{query}' across {len(buckets)} buckets...")

    # Group matches by filename
    filename_to_buckets = defaultdict(list)
    for bucket in buckets:
        matches = search_bucket(query, bucket)
        for bucket_name, filename in matches:
            filename_to_buckets[filename].append(bucket_name)

    if not filename_to_buckets:
        print("\nNo matches found.")
        return

    # First print files that exist in multiple buckets
    print("\nFiles found in multiple buckets:")
    multi_bucket_files = {
        filename: buckets 
        for filename, buckets in filename_to_buckets.items() 
        if len(buckets) > 1
    }

    if multi_bucket_files:
        for filename, bucket_list in sorted(multi_bucket_files.items()):
            print(f"\n{filename}")
            for bucket in sorted(bucket_list):
                print(f"  - {bucket}")
    else:
        print("  None found")

    # Then print files that exist in only one bucket, grouped by bucket
    print("\nFiles found in single buckets:")
    single_bucket_files = {
        filename: buckets[0] 
        for filename, buckets in filename_to_buckets.items() 
        if len(buckets) == 1
    }

    if single_bucket_files:
        # Group by bucket
        bucket_to_files = defaultdict(list)
        for filename, bucket in single_bucket_files.items():
            bucket_to_files[bucket].append(filename)

        # Print each bucket's unique files
        for bucket in sorted(bucket_to_files.keys()):
            print(f"\n{bucket}:")
            for filename in sorted(bucket_to_files[bucket]):
                print(f"  - {filename}")
    else:
        print("  None found")

    # Print summary
    print(f"\nSummary:")
    print(f"- Total unique files: {len(filename_to_buckets)}")
    print(f"- Files in multiple buckets: {len(multi_bucket_files)}")
    print(f"- Files in single buckets: {len(single_bucket_files)}")

if __name__ == "__main__":
    main()
