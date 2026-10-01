---
name: telegram-video-fix
description: Diagnose and fix video files that don't play on Telegram mobile (unknown codec errors) by inspecting codec properties and re-encoding to mobile-compatible H.264/AAC format
allowed-tools: Read, Bash, Grep, Edit, Write, Glob
---

# Telegram Video Format Fix

## When to Use This

- Video plays on desktop Telegram but fails on mobile with "unknown codec"
- Screencast or exported video won't play inline on Telegram mobile
- User asks why a video file is not playing on Telegram
- Need to convert any video to a Telegram-compatible format

## Core Workflow

### Step 1: Inspect the file with ffprobe

Run ffprobe to identify the video stream codec, profile, pixel format, and audio codec:

```bash
ffprobe -v quiet -print_format json -show_format -show_streams <filepath> 2>&1 | head -80
```

Key fields to check:
- `codec_name`: should be `h264` for video
- `profile`: must be `High` (NOT `High 4:4:4 Predictive`, `High 10`, etc.)
- `pix_fmt`: must be `yuv420p` (NOT `yuv444p`, `yuv422p`, etc.)
- `codec_name` for audio: should be `aac` (NOT `mp3`, `flac`, `opus`, etc.)

### Step 2: Identify incompatibility

Common causes of mobile playback failure:

| Issue | Incompatible value | Compatible value |
|-------|-------------------|------------------|
| H.264 profile | `High 4:4:4 Predictive`, `High 10`, `High 4:2:2` | `High` |
| Pixel format | `yuv444p`, `yuv422p` | `yuv420p` |
| Video codec | `hevc`, `vp9`, `av1` | `h264` |
| Audio codec | `mp3`, `flac`, `opus` | `aac` |

Mobile Telegram uses hardware decoding — it only supports baseline H.264 with 4:2:0 chroma. Desktop has a software decoder that can handle exotic profiles.

### Step 3: Re-encode with ffmpeg

```bash
ffmpeg -i <input> -c:v libx264 -profile:v high -pix_fmt yuv420p -crf 23 -preset fast -c:a aac -b:a 128k <output>
```

Parameters explained:
- `-c:v libx264`: use x264 encoder for H.264
- `-profile:v high`: force High profile (baseline would also work, high is safe)
- `-pix_fmt yuv420p`: force 4:2:0 chroma subsampling
- `-crf 23`: quality (lower = better, 18-28 is good range)
- `-preset fast`: encoding speed vs compression tradeoff
- `-c:a aac`: re-encode audio to AAC
- `-b:a 128k`: audio bitrate

### Step 4: Verify the output

Run ffprobe on the output file to confirm:

```bash
ffprobe -v quiet -print_format json -show_streams <output> 2>&1 | head -40
```

Confirm:
- `profile` is `High`
- `pix_fmt` is `yuv420p`
- Audio `codec_name` is `aac`

## Examples

### Screencast from Kazam not playing on mobile

Original file issues:
- `profile`: `High 4:4:4 Predictive`
- `pix_fmt`: `yuv444p`
- Audio: `mp3`

Fix:
```bash
ffmpeg -i 'Kazam_screencast_00001.mp4' -c:v libx264 -profile:v high -pix_fmt yuv420p -crf 23 -preset fast -c:a aac -b:a 128k 'Kazam_screencast_mobile.mp4'
```

## Common Pitfalls

- **Don't use `-c:v copy`**: stream copying preserves the incompatible profile, re-encode is required
- **Don't assume MP4 = compatible**: container format is fine, but the codec profile matters
- **Audio codec matters too**: MP3 audio in MP4 container can also cause issues, always convert to AAC
- **Level 5.0 is fine**: 2880x1800 at level 5.0 is supported by modern mobile hardware

## References

- Telegram API docs: https://core.telegram.org/api/files
- H.264 profiles: https://en.wikipedia.org/wiki/H.264/MPEG-4_AVC#Profiles
