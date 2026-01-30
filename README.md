# YouTube to MP3 CLI Tool

A simple command-line tool to download audio from YouTube videos and save them as MP3 files, with options to trim the beginning and end of the audio.

## Features

- Download audio from YouTube videos in high quality
- Automatic conversion to MP3 format
- Trim the beginning of the audio (skip intros, ads, etc.)
- Trim the end of the audio (remove outros, credits, etc.)
- Custom filename support or auto-generate from video title
- Progress indicator during download
- Color-coded output for easy reading

## Prerequisites

Before using this tool, you need to install the following dependencies:

### Python Package

Install Python dependencies using the requirements file:

```bash
pip install -r requirements.txt
```

### System Dependencies

Install the following system packages:

**Ubuntu/Debian:**
```bash
sudo apt install ffmpeg bc
```

**macOS:**
```bash
brew install ffmpeg bc
```

**Windows:**
- Download ffmpeg from https://ffmpeg.org
- bc is not required on Windows (the script will need modification for Windows compatibility)

## Installation

1. Clone or download the project files
2. Install Python dependencies:

```bash
pip install -r requirements.txt
```

3. Install system dependencies (see Prerequisites above)

4. Make the script executable:

```bash
chmod +x yt-mp3.sh
```

## Usage

### Basic Syntax

```bash
./yt-mp3.sh <youtube_url> [output_filename] [trim_start] [trim_end]
```

### Parameters

| Parameter | Required | Description | Example |
|-----------|----------|-------------|---------|
| `youtube_url` | Yes | The YouTube video URL | `https://www.youtube.com/watch?v=dQw4w9WgXcQ` |
| `output_filename` | No | Custom filename (without extension) | `my_song` |
| `trim_start` | No | Seconds to trim from beginning | `5` or `2.5` |
| `trim_end` | No | Seconds to trim from end | `10` or `7.5` |

### Examples

#### Download without trimming

```bash
./yt-mp3.sh "https://www.youtube.com/watch?v=dQw4w9WgXcQ"
```

Downloads the audio and uses the video title as the filename.

#### Download with custom filename

```bash
./yt-mp3.sh "https://www.youtube.com/watch?v=dQw4w9WgXcQ" "my_favorite_song"
```

Saves the file as `my_favorite_song.mp3`.

#### Trim first 5 seconds

```bash
./yt-mp3.sh "https://www.youtube.com/watch?v=dQw4w9WgXcQ" "my_song" 5
```

Skips the first 5 seconds of the audio.

#### Trim first 5 seconds and last 10 seconds

```bash
./yt-mp3.sh "https://www.youtube.com/watch?v=dQw4w9WgXcQ" "my_song" 5 10
```

Removes the first 5 seconds and last 10 seconds.

#### Trim only the last 8 seconds

```bash
./yt-mp3.sh "https://www.youtube.com/watch?v=dQw4w9WgXcQ" "my_song" 0 8
```

Use `0` for trim_start to skip beginning trim.

#### Auto-filename with trimming

```bash
./yt-mp3.sh "https://www.youtube.com/watch?v=dQw4w9WgXcQ" "" 3 5
```

Use empty quotes `""` for filename to auto-generate, while still trimming 3 seconds from start and 5 from end.

## Output

All downloaded files are saved in the `./downloads` directory, which is automatically created if it doesn't exist.

The script provides colored output:
- **Green** - Success messages
- **Yellow** - Information messages
- **Red** - Error messages

## Common Use Cases

### Skip YouTube intro ads (usually 5-15 seconds)

```bash
./yt-mp3.sh "URL" "" 5
```

### Remove intro and outro from music videos

```bash
./yt-mp3.sh "URL" "clean_song" 10 15
```

### Extract specific portion of a long video

```bash
# If video is 300 seconds and you want seconds 30-270
./yt-mp3.sh "URL" "excerpt" 30 30
```

## Troubleshooting

### "yt-dlp is not installed"

Install yt-dlp using pip or your package manager.

### "ffmpeg is not installed"

Install ffmpeg using your system's package manager.

### "bc: command not found"

Install bc calculator for end-trim calculations.

### Download fails

- Check your internet connection
- Verify the YouTube URL is correct and accessible
- Some videos may be region-locked or age-restricted

### Trimming doesn't work

- Ensure ffmpeg and bc are installed
- Check that trim values don't exceed the audio duration
- Values can be decimals (e.g., `2.5` for 2.5 seconds)

## Technical Details

- Audio quality is set to maximum (`--audio-quality 0`)
- Trimming uses ffmpeg's `-acodec copy` for fast processing without re-encoding
- The script automatically gets the audio duration to calculate end-trim positions
- Temporary files are cleaned up after successful trimming

## License

This is a simple utility script provided as-is for personal use.