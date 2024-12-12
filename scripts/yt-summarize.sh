#!/usr/bin/env bash

set -euo pipefail

# Check if URL is provided
if [ $# -lt 1 ]; then
  echo "Usage: $0 <youtube-url>"
  exit 1
fi

YOUTUBE_URL=$1

# Get video title and clean it up
CLEAN_TITLE=$(yt-dlp --get-title "$YOUTUBE_URL" 2>/dev/null |
  tr '[:upper:]' '[:lower:]' |
  tr -cd '[:alnum:] -' |
  tr ' ' '-' |
  tr -s '-')

OUTPUT_FILE="${CLEAN_TITLE}.m4a"

echo $OUTPUT_FILE

yt-dlp -f 'bestaudio[ext=m4a]' "$YOUTUBE_URL" -o "$OUTPUT_FILE" 2>/dev/null

mlx_whisper --model mlx-community/whisper-large-v3-turbo --verbose False "$OUTPUT_FILE"

cat "$CLEAN_TITLE.txt" | llm -t summarize
