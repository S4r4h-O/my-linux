#!/bin/bash

# --- Main directories ---
OPENWEBUI_DIR="/opt/open-webui"
LLAMA_DIR="/opt/llama.cpp"

# --- Threads and ports ---
THREADS=8
PORT=10000

# --- Init open-webui ---
echo "[INFO] Initializing..."
cd "$OPENWEBUI_DIR" || exit 1
source .venv/bin/activate
nohup open-webui serve >/tmp/openwebui.log 2>&1 &

# --- LLM backend ---
BACKEND=$(printf "ollama\nllama.cpp" | fzf)
if [ -z "$BACKEND" ]; then
  echo "[ERROR] No LLM backend selected."
  exit 1
fi

if [ "$BACKEND" = "llama.cpp" ]; then
  cd "$LLAMA_DIR/models" || exit 1
  MODEL_FILE=$(ls | fzf)
  if [ -z "$MODEL_FILE" ]; then
    echo "[ERROR] No model selected."
    exit 1
  fi
  MODEL_PATH="$LLAMA_DIR/models/$MODEL_FILE"

  # --- Init llama.cpp ---
  echo "[INFO] Initializing llama.cpp with the model '$MODEL_FILE', port $PORT..."
  cd "$LLAMA_DIR" || exit 1
  nohup ./build/bin/llama-server -m "$MODEL_PATH" -t "$THREADS" --port "$PORT" >/tmp/llama.log 2>&1 &

  echo "[INFO] Both services initialized:"
  echo " - OpenWebUI: http://127.0.0.1:8080"
  echo " - Llama.cpp: http://127.0.0.1:$PORT"

elif [ "$BACKEND" = "ollama" ]; then
  echo "[INFO] Initializing Ollama..."
  nohup ollama serve >/tmp/ollama.log 2>&1 &

  echo "[INFO] Both services initialized:"
  echo " - OpenWebUI: http://127.0.0.1:8080"
  echo " - Ollama: http://127.0.0.1:11434"
fi
