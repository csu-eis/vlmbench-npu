# VLM-Bench-NPU: How Far Are We From On-Device VLM Inference?

**VLM-Bench-NPU** is an empirical measurement study of vision-language model (VLM) inference on edge NPUs. We benchmark **six representative VLMs** (Qwen3.5-2B, Gemma4-E2B, InternVL3.5-1B, SmolVLM2-500M, NEO1.5-2B, and Mono-InternVL-2B) on **three real-world edge platforms** (OnePlus 13T, Rhino Pi-X1, and Orange Pi 5 Plus) across **ten multimodal benchmarks**, drilling down from end-to-end application-level latency and thermal traces to low-level kernel-scale execution behaviors.

📄 **Paper**: [arXiv:2610.40039](https://arxiv.org/abs/2610.40039)
🌐 **Project page**: <https://csu-eis.github.io/vlmbench-npu/>

## Key findings

- **Prefill dominates visual workloads.** Qwen3.5-2B spends 97.6 s on vision encoding and prefill before decoding a 512-frame video even begins.
- **Decode is slow and backend-dependent.** Qwen3.5-2B and NEO1.5-2B-SFT average only 16.7 and 11.4 output tokens/s across the measured NPUs.
- **Softmax dominates attention cost.** Lookup-table softmax still leaves pipeline bubbles that severely underutilize NPU matrix units.
- **Linear-attention speedups vanish on real NPUs** due to prohibitive tensor-rearrangement overhead.
- **No hardware backend universally wins** autoregressive decoding: attention-tensor-shaped parallelism dictates NPU efficiency and shifts the CPU–NPU balance.
- **Sweet Resolutions exist** — task-specific resolutions deliver meaningful accuracy gains at only modest latency overhead.

We will keep expanding the benchmark to more NPU architectures and newly released models, and continue to uncover new performance issues in on-device NPU inference.

## Repository layout

- [`src/paper.mdx`](src/paper.mdx) — the source of the project page (abstract, figures, findings).
- [`src/components/`](src/components/) — page sections: benchmark setting, measurement figures, and findings.
- [`src/assets/`](src/assets/) — figures used on the project page.

## Project page

This site is built with [Astro](https://astro.build/) and deployed via GitHub Pages.

```bash
npm install   # Node.js >= 24
npm run dev   # live preview at http://localhost:4321
npm run build # static site in ./dist/
```

## Citation

If you find this work useful, please cite:

```bibtex
@misc{yang2026farondevicevlminference,
      title={How Far Are We From On-Device VLM Inference? A Measurement Study on Edge NPUs},
      author={Huan Yang and Shiqi Jiang and Yu Mao and Chuanyue Xiong and Deyu Zhang},
      year={2026},
      eprint={2610.40039},
      archivePrefix={arXiv},
      primaryClass={cs.PF},
      url={https://arxiv.org/abs/2610.40039},
}
```
