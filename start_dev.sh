#!/bin/bash

set -euo pipefail

ENV_FILE="dev.env"

echo "Starting Doc-Rocker development server..."

if [ ! -f "$ENV_FILE" ]; then
  echo "Error: dev.env file not found."
  echo "Create it from dev.env.example:"
  echo "  cp dev.env.example dev.env"
  exit 1
fi

echo "Loading environment variables from .env..."
set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

missing=()
for var in \
  VITE_PERPLEXITY_API_KEY \
  VITE_PERPLEXITY_MODEL \
  VITE_TAVILY_API_KEY \
  VITE_COMBINER_PROVIDER \
  VITE_COMBINER_PROVIDER_MODEL \
  VITE_COMBINER_API_KEY; do
  if [ -z "${!var:-}" ]; then
    missing+=("$var")
  fi
done

if [ "${#missing[@]}" -gt 0 ]; then
  echo "Error: Missing required environment variables in dev.env:"
  printf '  - %s\n' "${missing[@]}"
  exit 1
fi

echo "Environment variables loaded."
echo "Starting Phoenix server at http://localhost:4000"
echo "Press Ctrl+C to stop the server."
echo ""

mix phx.server
