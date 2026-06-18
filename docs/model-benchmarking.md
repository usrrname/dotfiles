# Model Response Time Testing

## Why

The AMD Radeon 780M iGPU shares DDR5 system RAM (~45 GB/s bandwidth).
For an 8B model at Q4_K_M (~3.2 GB in GPU memory), the theoretical ceiling is
~14 t/s (tokens per second) just from memory bandwidth alone. At that speed,
a Hermes session with multi-round tool calling (500+ tokens per round) takes
30+ seconds per exchange, which adds up to minutes for a full response.

Benchmarking tells us exactly where we are relative to that ceiling, and
whether a smaller model or lower quantization gives usable real-world speed.

---

## 1. Baseline: Prompt Eval vs. Token Generation

Ollama reports two distinct metrics:

```
prompt eval rate     How fast the model reads/processes your input
eval rate            How fast it generates new tokens (the bottleneck)
```

Test with a single short prompt (no streaming):

```bash
time ollama run hermes-gemma --verbose "Say hello" 2>&1 | grep -E "eval rate|total duration|prompt eval rate|load duration"
```

The first run includes model loading (`load duration`). Run it again
immediately to get cached speed:

```bash
time ollama run hermes-gemma --verbose "Say hello" 2>&1 | grep -E "eval rate|total duration"
```

---

## 2. Measure Generation Speed for Realistic Payloads

Hermes tool calling generates hundreds of tokens per round. Simulate a
medium-length generation:

```bash
curl -s http://localhost:11434/api/generate \
  -d '{"model":"hermes-gemma","prompt":"Write a detailed paragraph about the benefits of declarative configuration management using Nix. Include specific examples.","stream":false}' \
  | python3 -c "
import sys, json
d = json.load(sys.stdin)
tokens = d.get('eval_count', 0)
duration = d.get('eval_duration', 0) / 1e9
rate = tokens / duration if duration > 0 else 0
print(f'Eval count: {tokens}')
print(f'Eval duration: {duration:.2f}s')
print(f'Eval rate: {rate:.2f} t/s')
"
```

Compare across models (see section 4).

---

## 3. End-to-End Hermes API Test

Test the OpenAI-compatible endpoint that Hermes uses directly:

```bash
curl -s http://localhost:11434/v1/chat/completions \
  -d '{
    "model":"hermes-gemma",
    "messages":[{"role":"user","content":"Say exactly: GPU test passed."}],
    "stream":false
  }' | python3 -c "
import sys, json
d = json.load(sys.stdin)
usage = d.get('usage', {})
print(f'Prompt tokens: {usage.get(\"prompt_tokens\")}')
print(f'Completion tokens: {usage.get(\"completion_tokens\")}')
msg = d['choices'][0]['message']['content']
print(f'Response: {msg}')
"
```

To measure wall-clock time add `time` before `curl`, or use `%time` in
Jupyter / IPython.

---

## 4. Models to Test

Sorted from fastest (smallest) to slowest (largest). All must support
tool calling for Hermes to use them.

| Model                 | Params | Est. t/s (780M) | Notes                                |
|-----------------------|--------|-----------------|--------------------------------------|
| `llama3.2:3b`         | 3B     | ~35-45          | Fastest tool-capable option          |
| `qwen2.5:7b`          | 7B     | ~15-20          | Good tool support, mature            |
| `gemma4:2b`           | 2B     | ~50-60          | If tool support is available         |
| `hermes-gemma` (8B)   | 8B     | ~11-17          | Current, functional but slow         |

Install and test:

```bash
# Pull a new model
ollama pull llama3.2:3b

# Quick benchmark
time ollama run llama3.2:3b --verbose "Say hello" 2>&1 | grep eval_rate

# Long-form generation test
curl -s http://localhost:11434/api/generate \
  -d '{"model":"llama3.2:3b","prompt":"Write a paragraph about Nix.","stream":false}' \
  | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'{d[\"eval_count\"]} tokens, {d[\"eval_duration\"]/1e9:.1f}s, {d[\"eval_count\"]/(d[\"eval_duration\"]/1e9):.1f} t/s')"
```

---

## 5. Quantization Comparison

The same model at different quantizations trades quality for speed:

```bash
# Check current quantization
ollama show hermes-gemma | grep quantization

# Pull a different quant (example)
ollama pull llama3.2:3b-q4_K_M   # 4-bit, balanced
ollama pull llama3.2:3b-q3_K_M   # 3-bit, faster, lower quality
ollama pull llama3.2:3b-q2_K     # 2-bit, fastest, noticeable quality loss
```

Benchmark each the same way and compare.

---

## 6. Context Length Impact

Longer context means more KV cache and slower attention. Test at different
context lengths by recreating the Modelfile:

```bash
cat > /tmp/Modelfile.test << 'EOF'
FROM <base-blob-sha>
PARAMETER num_ctx 8192
PARAMETER num_thread 14
EOF

ollama create test-model-8k -f /tmp/Modelfile.test
```

The current `hermes-gemma` uses `num_ctx 32768`. For Telegram chat
(short message history), 8192 may be sufficient and significantly faster.

---

## 7. GPU vs. CPU Comparison

On a system with an iGPU, CPU inference with many threads can sometimes
match or exceed iGPU bandwidth. Compare:

```bash
# Force CPU by setting no GPU vars (temporarily)
OLLAMA_IGPU_ENABLE=0 ollama run hermes-gemma --verbose "hello" 2>&1 | grep eval_rate

# Normal GPU mode for comparison
ollama run hermes-gemma --verbose "hello" 2>&1 | grep eval_rate
```

---

## 8. ROCm Override (RDNA 3 iGPU)

The 780M (gfx1103) is dropped by ROCm because rocBLAS lacks support for
this target. You can force an override:

```bash
# Check current GPU detection
journalctl -u ollama | grep -i gpu

# HSA_OVERRIDE_GFX_VERSION=gfx1100 maps to RDNA 2 (tested, works)
# gfx1101/gfx1102 are RDNA 3 dGPU targets
sudo systemctl edit ollama.service
# Add:
# [Service]
# Environment="HSA_OVERRIDE_GFX_VERSION=gfx1100"

sudo systemctl daemon-reload && sudo systemctl restart ollama
journalctl -u ollama | grep -i gpu
```

Then re-run benchmarks. ROCm may be faster or slower than Vulkan depending
on the workload. Benchmark both.

---

## 9. Interpreting Results

For Hermes Agent via Telegram:

| t/s range | 200-token response | 500-token response | Vibe check        |
|-----------|-------------------|--------------------|--------------------|
| >50       | < 4s              | < 10s              | Snappy             |
| 25-50     | 4-8s              | 10-20s             | Acceptable         |
| 15-25     | 8-13s             | 20-33s             | Noticeable lag     |
| 10-15     | 13-20s            | 33-50s             | Slow (current)     |
| <10       | >20s              | >50s               | Painful            |

Target: **25+ t/s** for a good Telegram experience.

---

## 10. Quick Reference

```bash
# One-liner: eval rate for any model
bench() { curl -s http://localhost:11434/api/generate -d "{\"model\":\"$1\",\"prompt\":\"Write a short paragraph about Linux.\",\"stream\":false}" | python3 -c "import sys,json; d=json.load(sys.stdin); print(f'{d[\"eval_count\"]}t in {d[\"eval_duration\"]/1e9:.1f}s = {d[\"eval_count\"]/(d[\"eval_duration\"]/1e9):.1f} t/s');"; }

# Usage
bench hermes-gemma
bench llama3.2:3b

# Cache status
ollama ps
```
