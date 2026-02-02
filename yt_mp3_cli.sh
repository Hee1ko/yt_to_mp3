#!/bin/bash

# YouTube to MP3 Downloader with Trim Options
# Usage: ./yt-mp3.sh <youtube_url> [output_dir] [output_filename] [trim_start] [trim_end]

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# Check if yt-dlp is installed
if ! command -v yt-dlp &> /dev/null; then
    print_error "yt-dlp is not installed."
    echo "Install it with: pip install yt-dlp"
    echo "Or on macOS: brew install yt-dlp"
    exit 1
fi

# Check if ffmpeg is installed
if ! command -v ffmpeg &> /dev/null; then
    print_error "ffmpeg is not installed."
    echo "Install it with:"
    echo "  Ubuntu/Debian: sudo apt install ffmpeg"
    echo "  macOS: brew install ffmpeg"
    echo "  Windows: Download from https://ffmpeg.org"
    exit 1
fi

# Check if URL is provided
if [ -z "$1" ]; then
    print_error "No YouTube URL provided"
    echo "Usage: $0 <youtube_url> [output_dir] [output_filename] [trim_start] [trim_end]"
    echo ""
    echo "Examples:"
    echo "  $0 https://www.youtube.com/watch?v=dQw4w9WgXcQ"
    echo "  $0 https://www.youtube.com/watch?v=dQw4w9WgXcQ ~/Desktop/my_music"
    echo "  $0 https://www.youtube.com/watch?v=dQw4w9WgXcQ ~/Desktop/my_music my_song"
    echo "  $0 https://www.youtube.com/watch?v=dQw4w9WgXcQ ~/Desktop/my_music my_song 5"
    echo "  $0 https://www.youtube.com/watch?v=dQw4w9WgXcQ ~/Desktop/my_music my_song 5 10"
    echo ""
    echo "Arguments:"
    echo "  youtube_url     - YouTube video URL (required)"
    echo "  output_dir      - Output directory (optional, defaults to ./downloads)"
    echo "  output_filename - Custom filename (optional, defaults to video title)"
    echo "  trim_start      - Seconds to trim from beginning (optional, e.g., 5 or 2.5)"
    echo "  trim_end        - Seconds to trim from end (optional, e.g., 10 or 7.5)"
    exit 1
fi

URL=$1
OUTPUT_DIR=${2:-"./downloads"}
FILENAME=${3:-"%(title)s"}
TRIM_START=${4:-0}
TRIM_END=${5:-0}

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

print_info "Downloading audio from: $URL"
print_info "Output directory: $OUTPUT_DIR"

if [ "$TRIM_START" != "0" ] || [ "$TRIM_END" != "0" ]; then
    [ "$TRIM_START" != "0" ] && print_info "Will trim first $TRIM_START seconds"
    [ "$TRIM_END" != "0" ] && print_info "Will trim last $TRIM_END seconds"
fi

# Download and convert to MP3
TEMP_FILE="$OUTPUT_DIR/temp_audio.mp3"

yt-dlp \
    --extract-audio \
    --audio-format mp3 \
    --audio-quality 0 \
    --output "$TEMP_FILE" \
    --progress \
    --extractor-args "youtube:player_client=android" \
    "$URL"

if [ $? -ne 0 ]; then
    print_error "Download failed"
    exit 1
fi

# Determine final filename
if [ "$FILENAME" = "%(title)s" ]; then
    # Get video title for filename
    TITLE=$(yt-dlp --get-title "$URL" | tr '/' '-' | tr '?' '-')
    FINAL_FILE="$OUTPUT_DIR/${TITLE}.mp3"
else
    FINAL_FILE="$OUTPUT_DIR/${FILENAME}.mp3"
fi

# Trim audio if trim parameters are specified
if [ "$TRIM_START" != "0" ] || [ "$TRIM_END" != "0" ]; then
    print_info "Trimming audio..."
    
    # Get duration of the audio file
    DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$TEMP_FILE")
    
    # Calculate end time if trimming from end
    if [ "$TRIM_END" != "0" ]; then
        END_TIME=$(echo "$DURATION - $TRIM_END" | bc)
        DURATION_PARAM="-to $END_TIME"
    else
        DURATION_PARAM=""
    fi
    
    # Trim the audio
    if [ "$TRIM_START" != "0" ]; then
        ffmpeg -i "$TEMP_FILE" -ss "$TRIM_START" $DURATION_PARAM -acodec copy "$FINAL_FILE" -y -loglevel error
    else
        ffmpeg -i "$TEMP_FILE" $DURATION_PARAM -acodec copy "$FINAL_FILE" -y -loglevel error
    fi
    
    if [ $? -eq 0 ]; then
        rm "$TEMP_FILE"
        print_success "Audio trimmed and saved to: $FINAL_FILE"
    else
        print_error "Trimming failed"
        mv "$TEMP_FILE" "$FINAL_FILE"
        print_info "Original file saved to: $FINAL_FILE"
    fi
else
    mv "$TEMP_FILE" "$FINAL_FILE"
    print_success "Audio downloaded successfully to: $FINAL_FILE"
fi