#!/bin/bash

echo "[INFO] Killing open-webui and LLM backend..."

pkill -f "open-webui serve" || echo "[WARN] open-webui not initialized."

# Try catch between backends
if pkill -f "llama-server" >/dev/null 2>&1; then
  echo "[INFO] Llama.cpp killed."
elif pkill -f "ollama" >/dev/null 2>&1; then
  echo "[INFO] Ollama killed."
else
  echo "[WARN] No LLM backend in execution."
fi

echo "[INFO] Finished."
