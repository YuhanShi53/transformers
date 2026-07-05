# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

This is a local ML model architecture analysis workspace. The workflow is:
1. Download model artifacts (configs, tokenizers, PDFs, inference source) from HuggingFace
2. Run the `model-architecture-source-analyzer` skill to produce source-grounded architecture reports
3. Output lands as Markdown (and optionally HTML) in the repo root or the model's subdirectory

There is no build system, test runner, or application code.

## Downloading Artifacts

Use the HF mirror endpoint when direct HuggingFace access is blocked:

```bash
HF_ENDPOINT=https://hf-mirror.com huggingface-cli download <org>/<model> \
  --exclude "*.safetensors" --exclude "*.bin" \
  --local-dir <family>/<ModelName>
```

Exclude weight files (`*.safetensors`, `*.bin`) — only configs, tokenizers, source code, and PDFs are needed for analysis.

## Directory Layout

```
<family>/              # e.g. deepseek-v4/, qwen3.5/
  <ModelName>/         # mirrors HF repo structure
    config.json        # primary architecture config
    tokenizer*.json
    generation_config.json
    README.md          # model card (often has architecture table)
    inference/         # model.py, kernel.py, generate.py (when available)
    *.pdf              # technical report
  <ModelName>-Analysis.md   # generated analysis report
```

HTML exports of analyses (e.g. `*_analysis_report.html`) are generated artifacts and not committed.

## Running Analysis

Use the `model-architecture-source-analyzer` skill. Point it at the relevant subdirectory. The skill reads:
- `config.json` for architecture hyperparameters
- Inference source (`model.py`, `kernel.py`) for implementation details
- The PDF technical report for paper concepts
- `README.md` and `tokenizer_config.json` for supplementary details

Analysis documents are written in Chinese by default and should be source-grounded — every architectural claim traced to a specific file and line.

## Key Architecture Patterns in This Repo

**DeepSeek-V4-Pro**: 1.6T/49B activated MoE, 61 layers, `hidden_size=7168`. Uses Manifold-Constrained Hyper-Connections (`hc_mult=4`, 4 residual streams), Hybrid Attention (HCA with `compress_ratio=128` + CSA with `compress_ratio=4`), FP4 expert weights + FP8 other params, MTP block at layer 61 (`compress_ratio=0`). Inference source is in `deepseek-v4/DeepSeek-V4-Pro/inference/`.

**Qwen3.5-27B**: 64-layer hybrid linear-attention model, `hidden_size=5120`. Layer pattern: 3× Gated DeltaNet + 1× GQA full-attention (`full_attention_interval=4`). Vision encoder (27-layer ViT, `spatial_merge_size=2`) + MTP head. Config is in `qwen3.5/Qwen3.5-27B/config.json`.
