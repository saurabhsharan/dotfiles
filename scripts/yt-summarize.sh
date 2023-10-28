#!/usr/bin/env bash

set -euo pipefail
set -x

YOUTUBE_URL=$1

OUTPUT_FILE="audio.m4a"
CONVERTED_AUDIO_FILE="audio-conv.wav"

TRANSCRIPT_FILENAME="transcript"

yt-dlp -f 'bestaudio[ext=m4a]' "$YOUTUBE_URL" -o "$OUTPUT_FILE" > /dev/null

ffmpeg -i "$OUTPUT_FILE" -y -ar 16000 -ac 1 -c:a pcm_s16le "$CONVERTED_AUDIO_FILE" > /dev/null

~/Downloads/whisper.cpp/main -m ~/Downloads/whisper.cpp/models/ggml-base.en.bin -f "$CONVERTED_AUDIO_FILE" --no-timestamps --threads 6 -otxt -of "$TRANSCRIPT_FILENAME"

cat "$TRANSCRIPT_FILENAME.txt" | llm -t summarize

rm "$OUTPUT_FILE"
rm "$CONVERTED_AUDIO_FILE"
