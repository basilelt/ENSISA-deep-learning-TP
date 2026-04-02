# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Context

This is **CP2** of a 7-checkpoint ENSISA teaching project on putting a deep learning model into production. Each CP builds on the previous:

- CP1: Containerize a Google Colab model (no Python on host)
- **CP2 (here)**: Structure into two concerns — `config()` and `classify()`
- CP3: Add a web server with routes, keep process alive
- CP4: Add local model cache
- CP5: Spring Boot frontend proxy
- CP6: Docker Compose orchestration
- CP7: Build Java inside a container (remove host dependencies)

The model is an ImageNet classifier loaded from TensorFlow Hub — no custom training, pure transfer learning inference.

## ARM64 Adaptation

This repo runs on Apple Silicon (and ARM servers). Two substitutions are required in all Dockerfiles:

- `tensorflow/tensorflow:2.8.0` → `basilelt/tensorflow-arm64:2.8.0`
- `openjdk:21` → `eclipse-temurin:21-jdk`

The custom TF image was built locally via `./build.sh` at the repo root.

## Running the Code

**Via Docker (recommended):**
```bash
./go   # stops/removes old container, builds, runs in background
```

**Locally:**
```bash
cd ia
pip install -r requirements.txt
python main.py
```

The `go` script does: stop existing `ia` container → `docker build` from `./ia` → `docker run --name ia ia`.

## Architecture

Two public functions in `ia/classify.py`:

**`config(model_name)`** — call once at startup:
1. Downloads model from TensorFlow Hub
2. Downloads ImageNet labels (1001 classes) from Google Storage
3. Sets global `image_size` from `model_image_size_map`
4. Runs a warm-up inference (random tensor) to initialize the model

**`classify(image_name)`** — call per image:
1. Loads image via `tf.io.gfile.GFile` (supports local paths)
2. Preprocesses: reshape → float32 → normalize to [0,1] → resize with padding
3. Runs `softmax(classifier(image))`
4. Returns top-5 predictions as `[{"class": str, "probabilitiy": float}, ...]`

Note: `probabilitiy` (double-i) is a typo that exists in the output dict — preserved across checkpoints for compatibility.

**Global state** in `classify.py`: `classifier`, `image_size`, `dynamic_size`, `max_dynamic_size`, `classes` — not thread-safe.

## Changing Models

Edit `ia/main.py`:
```python
classify.config("efficientnetv2-s")   # change model here
classify.classify("picture.jpg")       # change image here
```

All supported model names are keys in `model_handle_map` (lines 16–67 of `classify.py`). Models without an entry in `model_image_size_map` use dynamic sizing (capped at 512px).
