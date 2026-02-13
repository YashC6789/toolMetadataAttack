# AMA: Attractive Metadata Attack

---

## Overview

This repository provides the local implementation of Attractive Metadata Attack (AMA). AMA crafts “attractive” tool metadata to induce LLM agents to invoke malicious tools during tool selection, enabling systematic evaluation and study of agent security.

Paper: Attractive Metadata Attack: Inducing LLM Agents to Invoke Malicious Tools (NeurIPS 2025, Poster)  
Authors: Kanghua Mo, Li Hu, Yucheng Long, Zhihao Li  
Poster link: https://neurips.cc/virtual/2025/loc/san-diego/poster/116046

---

## Installation

- Python 3.11 is required.
- We recommend `uv` for environment management.

Using uv:

```bash
uv venv --python=3.11
source .venv/bin/activate
uv pip install -r requirements.txt
```

---

## Configuration (.env)

All API access is configured via environment variables. Edit the `.env` file at the repository root (a placeholder is provided):

```env
# Xinference
XINFERENCE_API_BASE=
XINFERENCE_API_KEY=
```

Guidance:
- If you plan to use Xinference, set `XINFERENCE_API_BASE` to your Xinference REST endpoint (e.g., `http://<host>:<port>/v1`) and `XINFERENCE_API_KEY` if required by your deployment.
- The code automatically loads these values at runtime; use real credentials for actual runs. To evaluate locally served models (e.g., Qwen3, Qwen2.5) or non-GPT commercial endpoints, set up Xinference and configure `XINFERENCE_API_BASE`/`XINFERENCE_API_KEY`. For launch instructions, see https://github.com/xorbitsai/inference.

---

## Optional: Deploy Xinference and Configure API

You can run AMA against models served by Xinference. After deployment, update `.env` with your Xinference endpoint and key.

Then set in `.env` (example):

```env
XINFERENCE_API_BASE=http://<your-ip>:9997/v1
XINFERENCE_API_KEY=sk-xxxx
```

### Local model configuration examples

- See `config/local_llm.yml` for example settings to run locally served models via Xinference or other OpenAI-compatible endpoints.
- See `main_attacker.py` for how CLI arguments map to runtime parameters; align your config values and command-line flags accordingly when running local models.

---

## Quickstart
Use the sbatch files to see how to run it.

## Acknowledgments

We thank the Agent Security Bench (ASB) project for inspiration and resources:
- https://github.com/agiresearch/ASB

BibTeX (ASB):

```bibtex
@inproceedings{
   zhang2025agent,
   title={Agent Security Bench ({ASB}): Formalizing and Benchmarking Attacks and Defenses in {LLM}-based Agents},
   author={Hanrong Zhang and Jingyuan Huang and Kai Mei and Yifei Yao and Zhenting Wang and Chenlu Zhan and Hongwei Wang and Yongfeng Zhang},
   booktitle={The Thirteenth International Conference on Learning Representations},
   year={2025},
   url={https://openreview.net/forum?id=V4y0CpX4hK}
}
```

---

## Citation

If you find this repository helpful, please cite our NeurIPS 2025 poster:

```
@inproceedings{mo2025ama,
   title={Attractive Metadata Attack: Inducing LLM Agents to Invoke Malicious Tools},
   author={Mo, Kanghua and Hu, Li and Long, Yucheng and Li, Zhihao},
   booktitle={Thirty-Ninth Conference on Neural Information Processing Systems (NeurIPS 2025), Poster},
   year={2025},
   url={https://neurips.cc/virtual/2025/loc/san-diego/poster/116046}
}
```
---
