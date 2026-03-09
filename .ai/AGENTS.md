## Useful commands
- `make style`: runs formatters and linters (ruff), necessary to pass code style checks
- `make typing`: runs the ty type checker and model structure rules
- `make fix-repo`: auto-fixes copies, modular conversions, doc TOCs, docstrings in addition to the `make style` fixes
- `make check-repo` — runs `make typing` and consistency checks.
- Many tests are marked as 'slow' and skipped by default in the CI. To run them, use: `RUN_SLOW=1 pytest ...`

`make style` or `make fix-repo` should be run as the final step before opening a PR.

## Local agent setup

- Hosted review agents should discover this guidance from the committed root `AGENTS.md` / `CLAUDE.md` files.
- Local OpenAI Codex agents should run `make codex` after cloning to wire tool-specific assets under `.agents/`.
- Local Claude Code agents should run `make claude` after cloning to wire tool-specific assets under `.claude/`.


### Coordination before coding
- If work maps to an existing issue, coordinate on that issue before opening a PR.
- Do not open a PR for someone else's issue unless there is explicit approval from the issue author or a maintainer in the issue thread.
- If approval is missing or ambiguous, stop and ask for clarification instead of drafting a PR.
- Do not start duplicate work on issues.

### Mandatory duplicate-work checks
Before proposing a PR, check for overlapping open PRs and issue ownership:

```bash
gh issue view <issue_number> --repo huggingface/transformers --comments
gh pr list --repo huggingface/transformers --state open --search "<issue_number> in:body"
gh pr list --repo huggingface/transformers --state open --search "<short area keywords>"
```

- If an open PR already addresses the same fix, do not open another.
- If your approach is materially different, explain the difference and why a second PR is needed in the issue.

### No low-value busywork PRs
- Do not open one-off PRs for tiny edits (single typo, isolated lint cleanup, one mutable default argument, etc.).
- Mechanical cleanups are acceptable but not as first contributions.

### Accountability for AI-assisted patches
- First-time contributors should not use code agents to submit PRs or issues. Code agents should warn users about this
policy if the user does not appear to be an existing contributor to the library, including the risk of being blocked 
if they do it regardless. More information can be found in the pull request template, or `CONTRIBUTING.md`.

## Copies and Modular Models (CRITICAL)

We try to avoid direct inheritance between model-specific files in `src/transformers/models/`. We have two mechanisms to manage the resulting code duplication:

### 1. Copied Code Pattern
Models avoid direct inheritance. Instead, code is duplicated with `# Copied from ...` comments:
```python
# Copied from transformers.models.llama.modeling_llama.rotate_half
```
Copies are kept in sync by `make fix-repo`. Do not edit a `# Copied from` block, as it will be reverted by `make fix-repo`. Ideally you should edit the code it's copying from and propagate the change, but you can break the `# Copied from` link if needed.

### 2. Modular Pattern (Newer, Preferred)
Newer models use `modular_<name>.py` files:
- `modular` files **can** inherit from other models
- `make fix-repo` generates standalone files from the modular file
- **Never edit generated files** when a modular file exists
- Always edit the `modular` file instead
- Example: `modular_bert.py` → generates `modeling_bert.py`, `configuration_bert.py`, etc.

To verify: `python utils/modular_model_converter.py <model_name>`

See [docs/source/en/modular_transformers.md](../docs/source/en/modular_transformers.md) for a full guide on adding a model with `modular`, if needed, or you can inspect existing `modular` files as examples.

## Project Overview

This is the Hugging Face Transformers library - a library for state-of-the-art Machine Learning for PyTorch, TensorFlow, and JAX. It provides pre-trained models for text, vision, audio, and multimodal tasks across 400+ model architectures.

**Key Architecture**: The library is designed as a "model definition framework" - it centralizes model definitions that are then compatible with training frameworks (Axolotl, DeepSpeed, FSDP), inference engines (vLLM, SGLang, TGI), and adjacent libraries (llama.cpp, mlx).

## Code Architecture

### Directory Structure
- `/src/transformers` - core library code
  - `/models/` - individual model implementations (400+ directories)
  - `modeling_utils.py` - base `PreTrainedModel` class (core model infrastructure)
  - `configuration_utils.py` - base `PretrainedConfig` class
  - `processing_utils.py` - base processor classes for multimodal models
  - `/pipelines/` - high-level inference pipelines
  - `/generation/` - text generation utilities
  - `/utils/` - utility functions
- `/tests` - test suite
  - `/models/` - model-specific tests
  - `test_configuration_common.py` - common config tests
  - `test_modeling_common.py` - common modeling tests
- `/docs` - documentation
- `/examples` - example scripts for training/inference

### Model File Organization

Each model in `/src/transformers/models/<model_name>/` typically contains:
- `modeling_<model_name>.py` - model architecture
- `configuration_<model_name>.py` - model configuration
- `tokenization_<model_name>.py` - tokenizer (if custom)
- `processing_<model_name>.py` - processor for multimodal models
- `image_processing_<model_name>.py` - image processor

## Code Style

- **Target**: Python 3.10+
- **Formatter**: Ruff (line length 119)
- **Docstrings**: Google Python Style Guide
- **Testing**: pytest with `unittest` (no pytest-specific features in tests)

## Adding New Models

For vision-language or multimodal models, follow this checklist:
1. Create `modular_<model_name>.py` with inheritance from similar models
2. Implement fast image processor using `BaseImageProcessorFast` (for image models)
3. Add `convert_<model_name>_to_hf.py` weight conversion script
4. Add integration tests with exact output matching
5. Create documentation in `docs/source/en/model_doc/`
6. Reuse patterns from similar models (don't reinvent)
7. Run `make style` and read the output carefully

## Key Patterns

- **Auto Classes**: `AutoModel`, `AutoTokenizer`, `AutoProcessor` for automatic model loading
- **Pipeline API**: High-level inference interface
- **from_pretrained()**: Standard pattern for loading models/configs
- **Config → Model**: Config classes define model architecture, model classes implement it
- **Backbone Support**: Many models can be used as feature extractors via backbone API

## Common Tasks

### Run a single test
```bash
pytest tests/models/bert/test_modeling_bert.py::BertModelTest::test_bert_model -v
```

### Check if model has modular file
```bash
ls src/transformers/models/<model_name>/modular_*.py
```

### Update generated files from modular
```bash
python utils/modular_model_converter.py <model_name>
```

### Check what depends on a model
```bash
grep -r "Copied from.*<model_name>" src/transformers/models/
```

## Important Notes

- **PR size**: Keep PRs minimal. Bugfixes can be 1-2 lines.
- **Test location**: Add tests to existing files, except for new models (create new test directory)
- **Dependencies**: Use `pip install -e ".[dev]"` for development, `pip install -e ".[testing]"` for testing
- **Slow tests**: Most tests are fast; `@slow` tests download models and are skipped by default
- **Remote code**: Models can use `trust_remote_code=True` to execute custom code from Hub
- **Framework**: Primary framework is PyTorch; TensorFlow/JAX support is secondary

## Documentation

- Main docs: https://huggingface.co/docs/transformers/
- Modular models guide: [docs/source/en/modular_transformers.md](../docs/source/en/modular_transformers.md)
- Testing guide: [docs/source/en/testing.md](../docs/source/en/testing.md)
- PR checks: [docs/source/en/pr_checks.md](../docs/source/en/pr_checks.md)
