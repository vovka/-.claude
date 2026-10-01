# Transcript Extraction Skill

Transcribe and diarize (speaker-label) audio/video files using local GPU tools.

## Tools available

| Tool | Location | Purpose |
|------|----------|---------|
| `whisper-cli` | `~/.local/bin/whisper-cli` | Fast transcription via whisper.cpp + CUDA |
| `whisper-diarization` Docker | `~/dev/_utils/whisper-diarization-docker/` | Transcription + speaker diarization (NeMo SortFormer) |
| Models cache | `~/.cache/whisper.cpp/` | ggml-large-v3, ggml-small, ggml-base, silero VAD |
| Diarization model cache | `~/.cache/whisper-diarization/` | faster-whisper large-v3, MMS aligner, SortFormer 4spk |

GPU: NVIDIA RTX 4060 Laptop (8GB VRAM). Use `--runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=all -e NVIDIA_DRIVER_CAPABILITIES=compute,utility` — CDI (`--gpus all`) is broken due to snap-docker confinement.

## Decision: which tool to use?

- **Transcription only** → use `whisper-cli` (faster, ~7 min for 90 min audio with large-v3)
- **Speaker-labeled output** → use `whisper-diarization` Docker (slower due to model loading, ~30 min total for 90 min audio including first-run downloads)

---

## Step 1 — Extract audio (always required)

```bash
ffmpeg -y -i "<input>" -vn -ac 1 -ar 16000 -c:a pcm_s16le "<output_dir>/audio16k.wav"
```

---

## Step 2a — Transcription only (whisper-cli)

```bash
whisper-cli \
  -m ~/.cache/whisper.cpp/ggml-large-v3.bin \
  -f "<output_dir>/audio16k.wav" \
  -l <LANG> \
  -t 8 \
  -pp \
  --vad \
  -vm ~/.cache/whisper.cpp/ggml-silero-v5.1.2.bin \
  -otxt -osrt -ovtt -oj \
  -of "<output_dir>/<basename>"
```

- `-l ru` for Russian/Ukrainian/mixed; `-l en` for English; `-l auto` for unknown
- Outputs: `.txt`, `.srt`, `.vtt`, `.json` named after `-of` value
- Run in background with `nohup ... &` for long files; monitor with `tail -f` or the Monitor tool
- ~7 min for 90 min audio on RTX 4060 with large-v3

---

## Step 2b — Diarized transcription (whisper-diarization Docker)

```bash
cd ~/dev/_utils/whisper-diarization-docker
./run.sh "<output_dir>/audio16k.wav" \
  --whisper-model large-v3 \
  --language <LANG> \
  --device cuda \
  --diarizer sortformer \
  --no-stem \
  --suppress_numerals
```

- `run.sh` handles GPU passthrough, cache mounts, and USER env vars automatically
- Outputs: `<output_dir>/audio16k.txt` and `audio16k.srt` with `Speaker 0:`, `Speaker 1:` labels
- SortFormer supports up to 4 speakers
- First run downloads ~4GB of models into `~/.cache/whisper-diarization/` (cached for future runs)
- Punctuation restoration for Russian is skipped (not supported); whisper punctuation is used as-is
- Run in background and monitor GPU util / cache size for progress since output is buffered

### Monitoring diarization progress (no log output until completion)
1. GPU util: `nvidia-smi --query-gpu=utilization.gpu,memory.used --format=csv,noheader`
2. Model downloads: `du -sh ~/.cache/whisper-diarization`
3. Container alive: `docker ps --filter ancestor=whisper-diarization:latest`

---

## Language codes

| Language | Code |
|----------|------|
| Russian | `ru` |
| Ukrainian | `uk` |
| English | `en` |
| Auto-detect | `None` (diarize) / `auto` (whisper-cli) |

For mixed Russian/Ukrainian/English: use `ru` (large-v3 handles inline code-switches).

---

## Cleanup

After transcription is complete, the extracted WAV can be deleted to save space:
```bash
rm "<output_dir>/audio16k.wav"
```
