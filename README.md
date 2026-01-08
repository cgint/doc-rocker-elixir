# Doc-Rocker

**Doc-Rocker** is an intelligent documentation search assistant that helps you find answers across multiple documentation sources. It combines the power of AI search engines to provide comprehensive, cited answers to your technical questions.

## What Does It Do?

Doc-Rocker searches documentation from popular frameworks and libraries (like Svelte, React, Vue, and more) and presents you with:

- **AI-synthesized answers** combining results from multiple sources
- **Live citations** linking back to official documentation
- **Real-time streaming responses** so you see results as they arrive
- **Progressive Web App (PWA)** support for offline access

Simply type your question, select your documentation sources, and get instant, well-researched answers with proper attribution.

## Quick Start with Docker

The easiest way to run Doc-Rocker is with Docker:

```bash
docker compose up --build
```

Then open your browser to `http://localhost:4000`

## Configuration

Doc-Rocker requires API keys for search services. Create a `.env` file or set environment variables:

- `VITE_PERPLEXITY_API_KEY` — API key for Perplexity AI
- `VITE_PERPLEXITY_MODEL` — Model to use (optional)
- `VITE_TAVILY_API_KEY` — API key for Tavily search
- `VITE_COMBINER_PROVIDER` — LLM provider for combining results
- `VITE_COMBINER_PROVIDER_MODEL` — Model for combining results
- `VITE_COMBINER_API_KEY` — API key for combiner service
- `SECRET_KEY_BASE` — Phoenix secret key (for production)

See `dev.env.example` for a template.

## Development Setup

If you want to run Doc-Rocker locally without Docker:

```bash
mix setup
cp dev.env.example dev.env
# Edit dev.env with your API keys
./start_dev.sh
```

## Features

- 🔍 **Multi-source search** — searches multiple documentation sources simultaneously
- ⚡ **Real-time streaming** — see answers appear as they're generated
- 📱 **Progressive Web App** — install on your device for offline access
- 🎯 **Smart citations** — every answer includes links to source documentation
- 🎨 **Clean, modern UI** — simple and intuitive interface
