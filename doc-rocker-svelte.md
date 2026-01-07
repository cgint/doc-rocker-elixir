# Directory Structure
_Includes files where the actual content might be omitted. This way the LLM can still use the file structure to understand the project._
```
.
├── .env.example
├── README.md
├── package.json
├── src
│   ├── app.d.ts
│   ├── app.html
│   ├── lib
│   │   ├── api
│   │   │   └── client.ts
│   │   ├── components
│   │   │   ├── DocumentationPicks.svelte
│   │   │   ├── InputField.svelte
│   │   │   ├── LogoGfx.svelte
│   │   │   ├── LogoText.svelte
│   │   │   ├── MarkdownDisplay.svelte
│   │   │   ├── ResponseDisplay.svelte
│   │   │   └── SendButton.svelte
│   │   ├── constants.ts
│   │   ├── index.ts
│   │   ├── llm
│   │   │   ├── LlmConnectService.ts
│   │   │   ├── prompts.ts
│   │   │   └── types_chat.ts
│   │   ├── search-engines
│   │   │   ├── perplexity.ts
│   │   │   ├── tavily.ts
│   │   │   └── types.ts
│   │   ├── services
│   │   │   ├── SearchService.test.ts
│   │   │   └── SearchService.ts
│   │   └── types.ts
│   └── routes
│       ├── +layout.server.ts
│       ├── +layout.ts
│       ├── +page.svelte
│       ├── api
│       │   ├── chat
│       │   │   └── +server.ts
│       │   └── rock
│       │       ├── +server.ts
│       │       └── server.test.ts
│       └── markdown-demo
│           └── +page.svelte
└── wrangler.toml
```

# File Contents

## File: `.env.example`
```
# Perplexity API Configuration (Required)
VITE_PERPLEXITY_API_KEY=your-perplexity-api-key
VITE_PERPLEXITY_MODEL=sonar-pro

# Tavily API Configuration (Required)
VITE_TAVILY_API_KEY=your-tavily-api-key

# Gemini API Configuration (Required)
VITE_COMBINER_PROVIDER=gemini
VITE_COMBINER_PROVIDER_MODEL=gemini-2.0-flash-thinking-exp-01-21
VITE_COMBINER_API_KEY=your-combiner-api-key
```

## File: `README.md`
```
# Doc-Rocker

A SvelteKit application that provides AI-powered documentation search with MCP (Model Context Protocol) support. Search through multiple documentation sources using Perplexity and Tavily search engines, with AI-combined results.

## Features

- **Documentation Search**: Multi-source documentation search using Perplexity and Tavily APIs
- **AI-Powered Results**: LLM-combined and enhanced search results
- **MCP Protocol Support**: Standards-compliant MCP server for AI assistant integration
- **Real-time Streaming**: Server-sent events for live search progress
- **TypeScript Support**: Full type safety throughout the application
- **Cloudflare Pages Ready**: Optimized for serverless deployment

## Prerequisites

1. **API Keys Required**:
   - Perplexity API key
   - Tavily API key  
   - AI Provider API key (Gemini, OpenAI, Anthropic, etc.)
2. **Development**:
   - Node.js 18+ installed
   - npm or yarn package manager
3. **Deployment**:
   - Cloudflare account (for Pages deployment)

## Setup

1. Clone the repository
2. Install dependencies:
   ```bash
   npm install
   ```

3. Create a `.env` file based on `.env.example`:
   ```bash
   cp .env.example .env
   ```

4. Set up Google OAuth credentials:
   a. Go to the [Google Cloud Console](https://console.cloud.google.com/)
   b. Create a new project or select an existing one
   c. Enable the Google OAuth2 API
   d. Go to Credentials > Create Credentials > OAuth Client ID
   e. Configure the OAuth consent screen:
      - User Type: External
      - Add your email as a test user
   f. Create OAuth Client ID:
      - Application Type: Web Application
      - Name: Your app name
      - Authorized JavaScript Origins: 
        - http://localhost:5173 (for development)
        - https://your-cloudflare-domain.pages.dev (for production)
      - Authorized Redirect URIs:
        - http://localhost:5173/auth/callback/google (for development)
        - https://your-cloudflare-domain.pages.dev/auth/callback/google (for production)

5. Configure environment variables in `.env`:
   ```bash
   # Generate AUTH_SECRET
   openssl rand -base64 32

   # Create and populate .env file
   cp .env.example .env
   ```
   Then edit `.env` with your values:
   - `VITE_GOOGLE_CLIENT_ID`: Your Google OAuth client ID from step 4
   - `VITE_GOOGLE_CLIENT_SECRET`: Your Google OAuth client secret from step 4
   - `VITE_CLOUD_RUN_SERVICE_URL`: Your Cloud Run service URL
   - `AUTH_SECRET`: The generated secret from openssl command

5. Start the development server:
   ```bash
   npm run dev
   ```

## MCP (Model Context Protocol) Integration

Doc-Rocker includes a built-in MCP server that exposes documentation search capabilities to AI assistants and MCP clients.

### MCP Server Details

- **Endpoint**: `POST /api/mcp`
- **Protocol**: JSON-RPC 2.0 over HTTP
- **Transport**: HTTP (suitable for Cloudflare Pages)
- **Version**: MCP Protocol 2024-11-05

### Available MCP Tools

#### 1. `search_documentation`
Search through documentation using both Perplexity and Tavily search engines, then combine results with AI.

**Parameters:**
- `query` (string, required): The search query or question
- `domains` (array of strings, required): List of domains to search within

**Example:**
```json
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "tools/call",
  "params": {
    "name": "search_documentation",
    "arguments": {
      "query": "How to use SvelteKit server-side rendering?",
      "domains": ["kit.svelte.dev", "svelte.dev"]
    }
  }
}
```

#### 2. `list_documentation_sources`
Get a list of available documentation sources that can be searched.

**Parameters:** None

**Example:**
```json
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "tools/call",
  "params": {
    "name": "list_documentation_sources",
    "arguments": {}
  }
}
```

### Testing the MCP Server

You can test the MCP server using curl:

1. **Initialize the MCP connection:**
```bash
curl -X POST http://localhost:5173/api/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 1,
    "method": "initialize",
    "params": {
      "protocolVersion": "2024-11-05",
      "capabilities": {},
      "clientInfo": {
        "name": "test-client",
        "version": "1.0.0"
      }
    }
  }'
```

2. **List available tools:**
```bash
curl -X POST http://localhost:5173/api/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 2,
    "method": "tools/list",
    "params": {}
  }'
```

3. **Get documentation sources:**
```bash
curl -X POST http://localhost:5173/api/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "jsonrpc": "2.0",
    "id": 3,
    "method": "tools/call",
    "params": {
      "name": "list_documentation_sources",
      "arguments": {}
    }
  }'
```

### Connecting AI Assistants

To connect AI assistants like Claude Desktop or Cursor to your Doc-Rocker MCP server:

1. **For local development:** Use `http://localhost:5173/api/mcp`
2. **For production:** Use your deployed URL `https://doc-rocker.com/api/mcp`

### MCP Client Configuration

Example configuration for MCP clients:

**Claude Desktop (via mcp-remote):**
```json
{
  "mcpServers": {
    "doc-rocker": {
      "command": "npx",
      "args": ["mcp-remote", "https://doc-rocker.com/api/mcp"]
    }
  }
}
```

**Direct HTTP Client:**
```javascript
const mcpClient = {
  endpoint: 'https://doc-rocker.com/api/mcp',
  initialize: async () => {
    const response = await fetch(endpoint, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        jsonrpc: '2.0',
        id: 1,
        method: 'initialize',
        params: {
          protocolVersion: '2024-11-05',
          capabilities: {},
          clientInfo: { name: 'my-client', version: '1.0.0' }
        }
      })
    });
    return response.json();
  }
};
```

## Development

The application is built with:
- SvelteKit
- TypeScript
- @auth/sveltekit for authentication
- Cloudflare Pages adapter

## Deployment

1. Configure your Cloudflare Pages project:
   - Connect your repository
   - Set build command: `npm run build`
   - Set build output directory: `build`
   - Add environment variables from `.env`

2. Deploy:
   ```bash
   npm run build
   ```

## Project Structure

```
├── src/
│   ├── lib/
│   │   ├── api/
│   │   │   └── client.ts           # API client utilities
│   │   ├── components/             # Svelte components
│   │   │   ├── DocumentationPicks.svelte
│   │   │   ├── InputField.svelte
│   │   │   ├── MarkdownDisplay.svelte
│   │   │   ├── ResponseDisplay.svelte
│   │   │   └── SendButton.svelte
│   │   ├── llm/
│   │   │   ├── LlmConnectService.ts # LLM integration service
│   │   │   ├── prompts.ts          # AI prompts
│   │   │   └── types_chat.ts       # Chat-related types
│   │   ├── search-engines/
│   │   │   ├── perplexity.ts       # Perplexity API integration
│   │   │   ├── tavily.ts           # Tavily API integration
│   │   │   └── types.ts            # Search engine types
│   │   ├── services/
│   │   │   ├── SearchService.ts    # Core search functionality
│   │   │   └── SearchService.test.ts # Tests for SearchService
│   │   ├── constants.ts            # Environment variables and constants
│   │   └── types.ts                # TypeScript type definitions
│   ├── routes/
│   │   ├── +page.svelte            # Main documentation search UI
│   │   ├── +layout.ts              # Layout configuration
│   │   └── api/
│   │       ├── chat/
│   │       │   └── +server.ts      # Chat API endpoint (streaming)
│   │       └── mcp/
│   │           └── +server.ts      # MCP server endpoint
│   └── app.html                    # HTML template
├── static/                         # Static assets
├── wrangler.toml                   # Cloudflare configuration
├── package.json                    # Dependencies and scripts
└── README.md                       # This file
```

## Security Notes

- Never commit `.env` file
- Keep OAuth credentials secure
- Regularly rotate AUTH_SECRET
- Use HTTPS in production

## License

MIT
```

## File: `package.json`
```
{
	"name": "doc-rocker",
	"version": "0.0.1",
	"private": true,
	"scripts": {
		"dev": "vite dev",
		"build": "vite build",
		"preview": "vite preview",
		"check": "svelte-kit sync && svelte-check --tsconfig ./tsconfig.json",
		"check:watch": "svelte-kit sync && svelte-check --tsconfig ./tsconfig.json --watch",
		"test": "vitest",
		"p": "sh precommit.sh",
		"pdev": "npm run p && npm run dev",
		"pprev": "npm run p && npm run preview"
	},
	"devDependencies": {
		"@sveltejs/adapter-cloudflare": "5.*",
		"@sveltejs/kit": "2.*",
		"@sveltejs/vite-plugin-svelte": "5.*",
		"@types/marked": "5.*",
		"@types/node": "22.*",
		"prettier": "3.*",
		"prettier-plugin-svelte": "3.*",
		"svelte": "5.*",
		"svelte-check": "4.*",
		"svelte-preprocess": "6.*",
		"typescript": "5.*",
		"vite": "6.*",
		"vitest": "2.*",
		"wrangler": "3.*"
	},
	"dependencies": {
		"highlight.js": "11.*",
		"marked": "15.*"
	},
	"type": "module"
}
```

## File: `src/app.d.ts`
```
/// <reference types="@auth/sveltekit" />
import type { CustomSession } from '$lib/types';

declare global {
	namespace App {
		interface Locals {
			getSession(): Promise<CustomSession | null>;
		}

		interface PageData {
			session: CustomSession | null;
		}
	}
}

export {};
```

## File: `src/app.html`
```
<!doctype html>
<html lang="en">
	<head>
		<meta charset="utf-8" />
		<link rel="icon" href="%sveltekit.assets%/favicon.png" />
		<meta name="viewport" content="width=device-width, initial-scale=1" />
		
		<!-- PWA Essential Meta Tags -->
		<meta name="theme-color" content="#4361ee" />
		<meta name="mobile-web-app-capable" content="yes" />
		<meta name="mobile-web-app-status-bar-style" content="default" />
		<meta name="apple-mobile-web-app-capable" content="yes" />
		<meta name="apple-mobile-web-app-status-bar-style" content="default" />
		<meta name="apple-mobile-web-app-title" content="Doc-Rocker" />
		
		<!-- PWA Manifest -->
		<link rel="manifest" href="/manifest.json" />
		
		<!-- Apple Touch Icons -->
		<link rel="apple-touch-icon" href="%sveltekit.assets%/icon-192x192.png" />
		<link rel="apple-touch-icon" sizes="192x192" href="%sveltekit.assets%/icon-192x192.png" />
		<link rel="apple-touch-icon" sizes="512x512" href="%sveltekit.assets%/icon-512x512.png" />
		
		<!-- Basic SEO Meta Tags -->
		<title>Doc-Rocker - AI-Powered Documentation Assistant</title>
		<meta name="description" content="Get instant answers about documentation with AI. Ask questions about LangChain, LlamaIndex, Google APIs and more. This is how to make docs rock!" />
		<meta name="keywords" content="documentation, AI assistant, chatbot, LangChain, LlamaIndex, Google API, developer tools, code documentation" />
		
		<!-- Open Graph Meta Tags for Social Media -->
		<meta property="og:title" content="Doc-Rocker - AI-Powered Documentation Assistant" />
		<meta property="og:description" content="Get instant answers about documentation with AI. Ask questions about LangChain, LlamaIndex, Google APIs and more. This is how to make docs rock!" />
		<meta property="og:image" content="%sveltekit.assets%/favicon.png" />
		<meta property="og:url" content="https://doc-rocker.com/" />
		<meta property="og:type" content="website" />
		<meta property="og:site_name" content="Doc-Rocker" />
		
		<!-- Twitter Card Meta Tags -->
		<meta name="twitter:card" content="summary_large_image" />
		<meta name="twitter:title" content="Doc-Rocker - AI-Powered Documentation Assistant" />
		<meta name="twitter:description" content="Get instant answers about documentation with AI. Ask questions about LangChain, LlamaIndex, Google APIs and more." />
		<meta name="twitter:image" content="%sveltekit.assets%/favicon.png" />
		
		<!-- Additional Meta Tags -->
		<meta name="robots" content="index, follow" />
		<meta name="author" content="Doc-Rocker" />

		<style>
			:root {
				--primary-color: #4361ee;
				--secondary-color: #3f37c9;
				--background-color: #f8fafc;
				--text-color: #1e293b;
				--border-color: #e2e8f0;
				--hover-color: #4895ef;
				--error-color: #ef4444;
				--success-color: #10b981;
			}
			
			body {
				margin: 0;
				padding: 0;
				font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen-Sans, Ubuntu, Cantarell, sans-serif;
				background-color: var(--background-color);
				color: var(--text-color);
				line-height: 1.5;
				-webkit-font-smoothing: antialiased;
				-moz-osx-font-smoothing: grayscale;
				/* PWA Mobile Optimizations */
				-webkit-text-size-adjust: 100%;
				-ms-text-size-adjust: 100%;
				overscroll-behavior: none;
				/* Safe area padding for notched devices */
				padding-top: env(safe-area-inset-top);
				padding-bottom: env(safe-area-inset-bottom);
				padding-left: env(safe-area-inset-left);
				padding-right: env(safe-area-inset-right);
			}

			* {
				box-sizing: border-box;
			}

			button {
				font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
				/* PWA Touch-friendly button sizes */
				min-height: 44px;
				min-width: 44px;
			}

			h3 {
				margin: 0 0 1.25rem 0;
				color: var(--text-color);
				font-size: 1.125rem;
				font-weight: 600;
			}

			h4 {
				margin: 1rem 0;
				color: var(--text-color);
				font-size: 1rem;
				font-weight: 600;
			}
		</style>
		%sveltekit.head%
	</head>
	<body data-sveltekit-preload-data="hover">
		<div style="display: contents">%sveltekit.body%</div>
		
		<!-- Service Worker Registration -->
		<script>
			if ('serviceWorker' in navigator) {
				window.addEventListener('load', () => {
					navigator.serviceWorker.register('/sw.js')
						.then((registration) => {
							console.log('[SW] Registration successful with scope: ', registration.scope);
							
							// Check for updates
							registration.addEventListener('updatefound', () => {
								const newWorker = registration.installing;
								newWorker.addEventListener('statechange', () => {
									if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
										// New content is available, notify user
										console.log('[SW] New content is available; please refresh.');
									}
								});
							});
						})
						.catch((error) => {
							console.log('[SW] Registration failed: ', error);
						});
				});
			}
		</script>
	</body>
</html>
```

## File: `src/lib/api/client.ts`
```
export async function callProtectedApi(accessToken?: string) {
    if (!accessToken) {
        throw new Error('No access token available');
    }

    const response = await fetch('/api/auth', {
        method: 'POST',
        headers: {
            'Authorization': `Bearer ${accessToken}`,
            'Content-Type': 'application/json'
        }
    });

    if (!response.ok) {
        const errorText = await response.text();
        throw new Error(errorText || 'API call failed');
    }

    return response.json();
}
```

## File: `src/lib/components/DocumentationPicks.svelte`
```
<script lang="ts">
    import { createEventDispatcher } from 'svelte';
    import type { DocumentationPick } from '$lib/types';
    import { DOCUMENTATION_PICKS } from '$lib/constants';
    import { onMount } from 'svelte';

    let picks = [...DOCUMENTATION_PICKS];
    let customDomain = '';
    let showCustomInput = false;
    let customDomainError = '';

    const dispatch = createEventDispatcher<{
        change: DocumentationPick[];
    }>();

    onMount(() => {
        // Load previously selected picks from localStorage
        const savedPicks = localStorage.getItem('selectedDocumentationPicks');
        if (savedPicks) {
            try {
                const savedPickNames = JSON.parse(savedPicks) as string[];
                
                // Check if the saved pick is a custom domain
                const customPickPrefix = 'custom:';
                const customPick = savedPickNames.find(name => name.startsWith(customPickPrefix));
                
                if (customPick) {
                    customDomain = customPick.replace(customPickPrefix, '');
                    // Add the custom domain as a pick
                    addCustomDomain(false);
                } else {
                    // Apply saved selections but ensure only one is selected
                    // If multiple are found in saved data, only select the first one
                    const firstSavedPick = savedPickNames.length > 0 ? savedPickNames[0] : null;
                    
                    picks = picks.map(pick => ({
                        ...pick,
                        selected: pick.name === firstSavedPick
                    }));
                }
                
                // Dispatch the initially selected picks
                dispatch('change', picks.filter(pick => pick.selected));
            } catch (error) {
                console.error('Error parsing saved documentation picks:', error);
            }
        }
    });

    function togglePick(index: number, shouldSave: boolean = true) {
        // When clicking on an item, deselect all others and select only the clicked one
        // If clicking on an already selected item, keep it selected (no deselection)
        const isAlreadySelected = picks[index].selected;
        
        if (!isAlreadySelected) {
            // Deselect all, then select only the clicked one
            picks = picks.map((pick, i) => ({
                ...pick,
                selected: i === index
            }));
        }
        
        picks = [...picks]; // Trigger reactivity
        const selectedPicks = picks.filter(pick => pick.selected);
        dispatch('change', selectedPicks);

        // Save the selected picks to localStorage
        if (shouldSave) {
            saveSelectedPicksToLocalStorage(selectedPicks);
        }
    }

    function toggleCustomInput() {
        showCustomInput = !showCustomInput;
        // If hiding custom input, clear any custom domain error
        if (!showCustomInput) {
            customDomainError = '';
        }
    }

    function addCustomDomain(shouldSave: boolean = true) {
        if (!customDomain.trim()) {
            customDomainError = 'Please enter a domain';
            return;
        }

        // Basic validation for domain format
        const domainRegex = /^[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,}$/i;
        if (!domainRegex.test(customDomain.trim())) {
            customDomainError = 'Please enter a valid domain (e.g., example.com)';
            return;
        }

        customDomainError = '';
        
        // Remove any previous custom domain pick
        picks = picks.filter(pick => !pick.name.startsWith('Custom: '));
        
        // Add the new custom domain pick
        const newCustomPick: DocumentationPick = {
            name: `Custom: ${customDomain}`,
            domain: customDomain,
            selected: true
        };
        
        // Deselect all other picks and add custom pick
        picks = picks.map(pick => ({
            ...pick,
            selected: false
        }));
        
        picks = [...picks, newCustomPick];
        
        // Dispatch change event with selected picks
        const selectedPicks = picks.filter(pick => pick.selected);
        dispatch('change', selectedPicks);
        
        // Save to localStorage
        if (shouldSave) {
            saveSelectedPicksToLocalStorage(selectedPicks);
        }
        
        // Hide the custom input after adding
        showCustomInput = false;
    }

    function saveSelectedPicksToLocalStorage(selectedPicks: DocumentationPick[]) {
        const selectedPickNames = selectedPicks.map(pick => {
            // For custom domains, store with a prefix to identify them
            if (pick.name.startsWith('Custom: ')) {
                return `custom:${pick.domain}`;
            }
            return pick.name;
        });
        
        localStorage.setItem('selectedDocumentationPicks', JSON.stringify(selectedPickNames));
    }

    function handleKeydown(event: KeyboardEvent) {
        if (event.key === 'Enter') {
            addCustomDomain();
        }
    }

    // Wrapper function to handle click event
    function handleAddDomainClick() {
        addCustomDomain();
    }
</script>

<div class="documentation-picks">
    <div class="header">
        <h2>Predefined Picks <span class="beta-tag">beta</span></h2>
        <button 
            class="custom-toggle-button" 
            on:click={toggleCustomInput}
            aria-label={showCustomInput ? "Hide custom domain input" : "Add custom domain"}
        >
            {showCustomInput ? '✕' : '+'}
        </button>
    </div>
    
    {#if showCustomInput}
        <div class="custom-domain-input">
            <div class="input-group">
                <input 
                    type="text" 
                    bind:value={customDomain} 
                    placeholder="Enter custom domain (e.g., example.com)" 
                    on:keydown={handleKeydown}
                />
                <button on:click={handleAddDomainClick}>Add</button>
            </div>
            {#if customDomainError}
                <div class="error-message">{customDomainError}</div>
            {/if}
        </div>
    {/if}
    
    <div class="picks-grid">
        {#each picks as pick, index}
            <button
                class="pick-button"
                class:selected={pick.selected}
                on:click={() => togglePick(index)}
            >
                {pick.name}
            </button>
        {/each}
    </div>
</div>

<style>
    .documentation-picks {
        width: 100%;
        max-width: 800px;
        margin: 0rem auto;
    }

    .header {
        margin-bottom: 0.5rem;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }

    h2 {
        font-size: 1.25rem;
        color: var(--text-color);
        margin: 0 0 0.5rem 0;
        font-weight: 600;
    }

    .beta-tag {
        font-size: 0.75rem;
        background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
        color: white;
        padding: 0.25rem 0.75rem;
        border-radius: 20px;
        font-weight: 500;
        text-transform: uppercase;
        letter-spacing: 0.05em;
    }

    .custom-toggle-button {
        font-size: 1.25rem;
        width: 2rem;
        height: 2rem;
        border-radius: 50%;
        background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
        color: white;
        border: none;
        cursor: pointer;
        display: flex;
        justify-content: center;
        align-items: center;
        padding: 0;
        transition: transform 0.2s;
    }

    .custom-toggle-button:hover {
        transform: scale(1.1);
    }

    .custom-domain-input {
        margin-bottom: 1rem;
        width: 100%;
        max-width: 95%;
        margin-left: auto;
        margin-right: auto;
    }

    .input-group {
        display: flex;
        gap: 0.5rem;
    }

    .input-group input {
        flex: 1;
        padding: 0.5rem;
        border: 1px solid var(--border-color);
        border-radius: 12px;
        font-size: 0.95rem;
    }

    .input-group button {
        padding: 0.5rem 1rem;
        background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
        color: white;
        border: none;
        border-radius: 12px;
        cursor: pointer;
        font-weight: 500;
    }

    .error-message {
        color: #ff4c4c;
        font-size: 0.85rem;
        margin-top: 0.25rem;
        padding-left: 0.5rem;
    }

    .picks-grid {
        margin: 0 auto;
        max-width: 95%;
        display: grid;
        grid-template-columns: repeat(auto-fit, minmax(11em, 1fr));
        gap: 0.25rem;
    }

    .pick-button {
        padding: 0rem 0.5rem;
        border: 1px solid var(--border-color);
        border-radius: 12px;
        background-color: rgb(232, 236, 253);
        color: var(--text-color);
        font-size: 0.95rem;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.2s ease;
        text-align: left;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
        height: 2.5rem;
        display: flex;
        align-items: center;
    }

    .pick-button:hover {
        border-color: var(--primary-color);
        color: var(--primary-color);
        transform: translateY(-1px);
        box-shadow: 0 4px 8px rgba(67, 97, 238, 0.1);
    }

    .pick-button:active {
        transform: translateY(0);
    }

    .pick-button.selected {
        background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
        border-color: transparent;
        color: white;
        box-shadow: 0 4px 12px rgba(67, 97, 238, 0.2);
    }

    .pick-button.selected:hover {
        transform: translateY(-1px);
        box-shadow: 0 6px 16px rgba(67, 97, 238, 0.25);
    }

    @media (max-width: 400px) {
        .documentation-picks {
            margin: 0.5rem auto;
        }

        h2 {
            font-size: 1.125rem;
        }

        .picks-grid {
            grid-template-columns: 1fr;
        }

        .pick-button {
            padding: 0.875rem 1rem;
            height: 3rem;
        }
        
        .custom-domain-input {
            padding: 0 0.5rem;
        }
        
        .input-group {
            flex-direction: column;
        }
        
        .input-group button {
            margin-top: 0.5rem;
        }
    }
</style>
```

## File: `src/lib/components/InputField.svelte`
```
<script lang="ts">
    import { createEventDispatcher } from 'svelte';

    export let value: string = '';
    export let placeholder: string = 'Ask a question about documented knowledge...';
    export let disabled: boolean = false;

    const MAX_CHARACTERS = 400;
    
    const dispatch = createEventDispatcher<{
        input: string;
        submit: string;
        tooLong: boolean;
    }>();

    $: characterCount = value.length;
    $: isOverLimit = characterCount > MAX_CHARACTERS;
    $: isNearLimit = characterCount > MAX_CHARACTERS * 0.8; // Show warning at 80% (320 chars)
    
    // Dispatch tooLong event whenever isOverLimit changes
    $: dispatch('tooLong', isOverLimit);

    function handleInput(event: Event) {
        const target = event.target as HTMLTextAreaElement;
        value = target.value;
        dispatch('input', value);
    }

    function handleKeydown(event: KeyboardEvent) {
        if (event.key === 'Enter' && event.metaKey && !disabled && !isOverLimit) {
            event.preventDefault();
            dispatch('submit', value);
        }
    }
</script>

<div class="input-container">
    <textarea
        {placeholder}
        {disabled}
        bind:value
        on:input={handleInput}
        on:keydown={handleKeydown}
        class="input-field"
        class:over-limit={isOverLimit}
        class:near-limit={isNearLimit && !isOverLimit}
        rows="3"
    ></textarea>
    
    <span class="character-count" class:over-limit={isOverLimit} class:near-limit={isNearLimit && !isOverLimit}>
        {characterCount}/{MAX_CHARACTERS}
    </span>
    
    {#if isOverLimit}
        <div class="warning-message">
            Query too long! Tavily search requires 400 characters or less.
        </div>
    {/if}
</div>

<style>
    .input-container {
        width: 95%;
        max-width: 800px;
        margin: 0 auto;
        position: relative;
    }

    .input-field {
        width: 100%;
        padding: 1rem 1.25rem;
        border: 1px solid var(--border-color);
        border-radius: 36px;
        background-color: rgb(232, 236, 253);
        font-size: 1rem;
        line-height: 1.6;
        resize: none;
        transition: all 0.2s ease;
        box-shadow: 0 2px 4px rgba(0, 0, 0, 0.05);
        /* color: white; */
    }

    .input-field::placeholder {
        color: #94a3b8;
        font-size: 0.95rem;
    }

    .input-field:focus {
        outline: none;
        border-color: var(--primary-color);
        box-shadow: 0 4px 12px rgba(67, 97, 238, 0.1);
    }

    .input-field:hover:not(:disabled) {
        border-color: var(--hover-color);
    }

    .input-field:disabled {
        background-color: var(--background-color);
        cursor: not-allowed;
        opacity: 0.7;
    }

    .input-field.near-limit {
        border-color: #f59e0b;
        box-shadow: 0 4px 12px rgba(245, 158, 11, 0.1);
    }

    .input-field.over-limit {
        border-color: #ef4444;
        box-shadow: 0 4px 12px rgba(239, 68, 68, 0.1);
    }

    .character-count {
        position: absolute;
        top: 0.15rem;
        right: 0.25rem;
        font-size: 0.75rem;
        color: #64748b;
        background-color: rgba(255, 255, 255, 0.9);
        padding: 0.125rem 0.375rem;
        border-radius: 0.25rem;
        font-weight: 500;
        z-index: 10;
    }

    .character-count.near-limit {
        color: #f59e0b;
        background-color: rgba(255, 255, 255, 0.95);
    }

    .character-count.over-limit {
        color: #ef4444;
        background-color: rgba(255, 255, 255, 0.95);
        font-weight: 600;
    }

    .warning-message {
        font-size: 0.875rem;
        color: #ef4444;
        font-weight: 500;
        margin-top: 0.5rem;
        text-align: center;
    }

    @media (max-width: 640px) {
        .input-field {
            font-size: 0.95rem;
            padding: 0.875rem 1rem;
        }

        .character-count {
            top: 0.625rem;
            right: 1rem;
            font-size: 0.7rem;
        }
    }
</style>
```

## File: `src/lib/components/LogoGfx.svelte`
```
<script lang="ts">
    // Logo component for Doc-Rocker
    export let loading: boolean = false;
</script>

<div class="logo-container">
    <img src="/logo.webp" alt="Doc-Rocker Logo" class="logo-gfx" class:loading>
</div>

<style>
    .logo-container {
        display: flex;
        flex-direction: column;
        align-items: center;
        margin-top: 0px;
        margin-bottom: 0px;
        padding: calc(1rem + 20px);
        border-radius: 30%;
        width: fit-content;
        margin-left: auto;
        margin-right: auto;
        position: relative;
        padding: 20px;
    }

    .logo-container::before {
        content: '';
        position: absolute;
        top: 0;
        right: 0;
        bottom: 0;
        left: 0;
        border-radius: 30%;
        background: linear-gradient(135deg, rgb(67, 97, 238), rgb(63, 55, 201));
        mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
        mask-composite: exclude;
        -webkit-mask: linear-gradient(#fff 0 0) content-box, linear-gradient(#fff 0 0);
        -webkit-mask-composite: xor;
        padding: 20px;
    }

    .logo-gfx {
        width: 200px;
        height: 200px;
        transform-origin: 65% 50%; /* Position for the hand in the logo */
        transition: transform 0.3s ease;
    }

    /* Rock on animation for the loading state */
    .logo-gfx.loading {
        animation: rockOn 0.8s ease-in-out infinite;
    }

    @keyframes rockOn {
        0% {
            transform: rotate(0deg) scale(1);
        }
        20% {
            transform: rotate(-15deg) scale(1.03);
        }
        40% {
            transform: rotate(12deg) scale(1.02);
        }
        60% {
            transform: rotate(-10deg) scale(1.01);
        }
        80% {
            transform: rotate(8deg) scale(1.01);
        }
        100% {
            transform: rotate(0deg) scale(1);
        }
    }

    @media (max-width: 520px) {
        .logo-gfx {
            width: 100px;
            height: 100px;
        }
    }
</style>
```

## File: `src/lib/components/LogoText.svelte`
```
<script lang="ts">
    // Logo component for Doc-Rocker
</script>


<div class="logo-container">
    <h1 class="logo-text">Doc-Rocker</h1>
    <p class="logo-subtext">This is how to make docs rock!</p>
</div>
<style>
    .logo-container {
        display: flex;
        flex-direction: column;
        align-items: center;
        margin-bottom: 3rem;
        padding: 1rem;
    }

    .logo-text {
        font-size: 3rem;
        font-weight: 600;
        color: var(--primary-color);
        margin: 0;
        letter-spacing: -0.02em;
        background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
        -webkit-background-clip: text;
        background-clip: text;
        -webkit-text-fill-color: transparent;
        transition: transform 0.3s ease;
    }

    .logo-text:hover {
        transform: scale(1.02);
    }

    .logo-subtext {
        font-size: 1.1rem;
        color: #64748b;
        margin: 0.75rem 0 0 0;
        font-weight: 500;
        opacity: 0.9;
    }

    @media (max-width: 640px) {
        .logo-text {
            font-size: 2.5rem;
        }

        .logo-subtext {
            font-size: 1rem;
        }
    }
</style>
```

## File: `src/lib/components/MarkdownDisplay.svelte`
```
<script lang="ts">
    import { marked } from 'marked';
    import type { MarkedOptions } from 'marked';
    import { onMount } from 'svelte';
    import hljs from 'highlight.js';
    import 'highlight.js/styles/github.css';

    export let markdown: string;
    export let showCopyButtons = true;

    let markdownRef: HTMLDivElement;

    // Set up marked with a simple configuration
    marked.setOptions({
        breaks: true,
        gfm: true,
        highlight: function(code: string, lang: string) {
            if (lang && hljs.getLanguage(lang)) {
                try {
                    return hljs.highlight(code, { language: lang }).value;
                } catch (err) {
                    console.error('Highlight.js error:', err);
                }
            }
            try {
                return hljs.highlightAuto(code).value;
            } catch (err) {
                console.error('Highlight.js error:', err);
                return code;
            }
        }
    } as MarkedOptions);

    $: renderedHtml = marked(markdown || '');

    onMount(() => {
        if (showCopyButtons) {
            addCopyButtonsToCodeBlocks();
        }
    });

    function addCopyButtonsToCodeBlocks() {
        if (!markdownRef) return;
        
        const codeBlocks = markdownRef.querySelectorAll('pre code');
        codeBlocks.forEach((codeBlock) => {
            const pre = codeBlock.parentNode as HTMLElement;
            if (!pre) return;
            
            // Ensure the pre element has position relative for absolute positioning
            pre.style.position = 'relative';
            
            const copyButton = document.createElement('button');
            copyButton.className = 'code-copy-button';
            copyButton.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>';
            copyButton.title = 'Copy code';
            
            copyButton.addEventListener('click', () => {
                const code = codeBlock.textContent || '';
                navigator.clipboard.writeText(code)
                    .then(() => {
                        copyButton.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6L9 17l-5-5"></path></svg>';
                        setTimeout(() => {
                            copyButton.innerHTML = '<svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2" ry="2"></rect><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"></path></svg>';
                        }, 2000);
                    })
                    .catch(err => console.error('Failed to copy:', err));
            });
            
            pre.appendChild(copyButton);
        });
    }

    function copyAsMarkdown() {
        navigator.clipboard.writeText(markdown)
            .catch(err => console.error('Failed to copy markdown:', err));
    }

    function copyAsRichText() {
        if (!markdownRef) return;
        
        // Create a range and selection
        const range = document.createRange();
        range.selectNodeContents(markdownRef);
        
        const selection = window.getSelection();
        if (!selection) return;
        
        // Clear current selection and add new range
        selection.removeAllRanges();
        selection.addRange(range);
        
        // Execute copy command
        document.execCommand('copy');
        
        // Clean up selection
        selection.removeAllRanges();
    }
</script>

<div class="markdown-container">
    <div class="markdown-content-wrapper">
        {#if showCopyButtons}
            <div class="action-buttons">
                <button on:click={copyAsMarkdown} class="action-button" title="Copy Markdown" aria-label="Copy Markdown">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                        <polyline points="14 2 14 8 20 8"></polyline>
                    </svg>
                </button>
                <button on:click={copyAsRichText} class="action-button" title="Copy Rich Text" aria-label="Copy Rich Text">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"></path>
                        <polyline points="16 17 21 12 16 7"></polyline>
                        <line x1="21" y1="12" x2="9" y2="12"></line>
                    </svg>
                </button>
            </div>
        {/if}
        
        <div bind:this={markdownRef} class="markdown-content">
            {@html renderedHtml}
        </div>
    </div>
</div>

<style>
    .markdown-container {
        width: 100%;
        margin: 0 auto;
    }

    .markdown-content-wrapper {
        position: relative;
    }

    .action-buttons {
        position: absolute;
        top: 0;
        right: 0;
        display: flex;
        gap: 0.25rem;
        z-index: 10;
    }

    .action-button {
        display: flex;
        align-items: center;
        justify-content: center;
        width: 24px;
        height: 24px;
        padding: 0;
        background-color: var(--option-btn-bg, rgba(255, 255, 255, 0.8));
        border: 1px solid var(--option-btn-border, rgba(0, 0, 0, 0.1));
        border-radius: 4px;
        color: var(--option-btn-color, #4a5568);
        cursor: pointer;
        transition: all 0.2s ease;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    }

    .action-button:hover {
        background-color: var(--option-btn-hover-bg, rgba(255, 255, 255, 0.9));
        color: var(--primary-color, #3182ce);
    }

    .markdown-content {
        line-height: 1.6;
        color: var(--text-color, #111);
        padding: 1rem;
        background-color: var(--bg-color, #fff);
        border-radius: 8px;
        border: 1px solid var(--border-color, #e2e8f0);
    }

    .markdown-content :global(h1),
    .markdown-content :global(h2),
    .markdown-content :global(h3),
    .markdown-content :global(h4),
    .markdown-content :global(h5),
    .markdown-content :global(h6) {
        margin-top: 1.5rem;
        margin-bottom: 1rem;
        font-weight: 600;
        line-height: 1.25;
    }

    .markdown-content :global(h1) {
        font-size: 2rem;
    }

    .markdown-content :global(h2) {
        font-size: 1.5rem;
    }

    .markdown-content :global(h3) {
        font-size: 1.25rem;
    }

    .markdown-content :global(p) {
        margin: 1rem 0;
    }

    .markdown-content :global(ul),
    .markdown-content :global(ol) {
        margin: 1rem 0;
        padding-left: 2rem;
    }

    .markdown-content :global(li) {
        margin: 0.5rem 0;
    }

    .markdown-content :global(code) {
        font-family: 'Fira Code', 'Consolas', monospace;
        font-size: 0.9em;
        padding: 0.2rem 0.4rem;
        background-color: var(--code-bg, #f1f5f9);
        border-radius: 4px;
    }

    .markdown-content :global(pre) {
        position: relative;
        padding: 1rem;
        margin: 1rem 0;
        background-color: var(--pre-bg, #f8fafc);
        border-radius: 8px;
        overflow: auto;
        font-family: 'Fira Code', 'Consolas', monospace;
    }

    .markdown-content :global(pre code) {
        background: none;
        padding: 0;
        font-size: 0.9rem;
        white-space: pre;
        line-height: 1.5;
    }

    .markdown-content :global(blockquote) {
        margin: 1rem 0;
        padding: 0 1rem;
        color: var(--blockquote-color, #4a5568);
        border-left: 4px solid var(--blockquote-border, #cbd5e0);
    }

    .markdown-content :global(a) {
        color: var(--link-color, #3182ce);
        text-decoration: none;
    }

    .markdown-content :global(a:hover) {
        text-decoration: underline;
    }

    .markdown-content :global(img) {
        max-width: 100%;
        height: auto;
        margin: 1rem 0;
        border-radius: 4px;
    }

    .markdown-content :global(table) {
        width: 100%;
        border-collapse: collapse;
        margin: 1rem 0;
    }

    .markdown-content :global(th),
    .markdown-content :global(td) {
        padding: 0.5rem;
        border: 1px solid var(--table-border, #e2e8f0);
    }

    .markdown-content :global(th) {
        background-color: var(--th-bg, #f8fafc);
    }

    /* Style for the code block copy button */
    :global(.code-copy-button) {
        position: absolute;
        top: 2px;
        right: 2px;
        padding: 0.25rem;
        background-color: var(--copy-btn-bg, rgba(255, 255, 255, 0.8));
        border: 1px solid var(--copy-btn-border, rgba(0, 0, 0, 0.1));
        border-radius: 4px;
        color: var(--copy-btn-color, #718096);
        cursor: pointer;
        transition: all 0.2s ease;
        display: flex;
        align-items: center;
        justify-content: center;
        box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        z-index: 5;
    }

    :global(.code-copy-button:hover) {
        background-color: var(--copy-btn-hover-bg, rgba(255, 255, 255, 0.9));
        color: var(--primary-color, #3182ce);
    }

    @media (max-width: 640px) {
        .action-buttons {
            top: 0.25rem;
            right: 0.25rem;
        }
        
        .action-button {
            width: 28px;
            height: 28px;
        }
        
        .action-button svg {
            width: 14px;
            height: 14px;
        }
    }
</style> 
```

## File: `src/lib/components/ResponseDisplay.svelte`
```
<script lang="ts">
     import MarkdownDisplay from './MarkdownDisplay.svelte';
     import type { SingleChatResponse } from '$lib/types';
    
     export let response: string;
     export let citations: string[] = [];
     export let error: string | null = null;
     export let rawResults: SingleChatResponse[] | null = null;
</script>

<div class="response-container">
    {#if error}
        <div class="error">
            <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="error-icon">
                <circle cx="12" cy="12" r="10"></circle>
                <line x1="12" y1="8" x2="12" y2="12"></line>
                <line x1="12" y1="16" x2="12.01" y2="16"></line>
            </svg>
            <p>{error}</p>
        </div>
    {:else if response}
        <div id="combined_result" class="response">
            <div class="content-wrapper">
                <MarkdownDisplay markdown={response} />
            </div>
            {#if citations && citations.length > 0}
                <div class="citations">
                    <h3>Sources:</h3>
                    <ul>
                        {#each citations as citation}
                            <li>
                                <a href={citation} target="_blank" rel="noopener noreferrer">
                                    {citation}
                                </a>
                            </li>
                        {/each}
                    </ul>
                </div>
            {/if}
        </div>

        {#if rawResults && rawResults.length > 0}
            <div class="raw-results response">
                <h2>Individual Results the AI Answer is based on</h2>
                {#each rawResults as result, i}
                    <div class="raw-result response">
                        <div class="content-wrapper">
                            <MarkdownDisplay markdown={result.answer} />
                        </div>
                        {#if result.citations && result.citations.length > 0}
                            <div class="citations">
                                <h3>Sources:</h3>
                                <ul>
                                    {#each result.citations as citation}
                                        <li>
                                            <a href={citation} target="_blank" rel="noopener noreferrer">
                                                {citation}
                                            </a>
                                        </li>
                                    {/each}
                                </ul>
                            </div>
                        {/if}
                    </div>
                {/each}
            </div>
        {/if}
    {/if}
</div>

<style>
    .response-container {
        width: 100%;
        max-width: 800px;
        margin: 1rem auto;
    }

    .response {
        padding: 0rem 1.5rem;
        background-color: rgb(232, 236, 253);
        border-radius: 12px;
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.05);
        margin-bottom: 1rem;
        border: 1px solid var(--border-color);
    }

    .raw-results {
        margin-top: 1rem;
    }

    .raw-result {
        padding: 0rem 1.5rem;
        background-color: rgb(240, 240, 240);
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
        margin-bottom: 1.25rem;
        border: 1px solid var(--border-color);
    }

    .content-wrapper {
        padding-top: 1rem;
    }

    :global(.markdown-container) {
        width: 100%;
        margin: 0 !important;
    }

    :global(.markdown-content) {
        padding: 0 !important;
        border: none !important;
        background-color: transparent !important;
    }

    .citations {
        margin-top: 0.5rem;
        margin-bottom: 1.5rem;
        padding-top: 0.5rem;
        border-top: 1px solid var(--border-color);
    }

    .citations ul {
        list-style: disc;
        padding: 0;
        margin: 0;
        margin-left: 1.5rem;
    }
    
    .raw-results .citations ul {
        list-style: decimal;
    }

    .citations li {
        margin: 0.25rem 0;
        font-size: 0.75rem;
    }

    .citations a {
        color: var(--primary-color);
        text-decoration: none;
        transition: color 0.2s ease;
        word-break: break-all;
    }

    .citations a:hover {
        color: var(--hover-color);
    }

    .error {
        padding: 1.25rem;
        background-color: #fef2f2;
        border: 1px solid #fee2e2;
        border-radius: 12px;
        color: var(--error-color);
        display: flex;
        align-items: flex-start;
        gap: 0.75rem;
    }

    .error p {
        margin: 0;
        font-size: 0.95rem;
        line-height: 1.5;
    }

    .error-icon {
        flex-shrink: 0;
        margin-top: 0.125rem;
    }

    @media (max-width: 640px) {
        .response-container {
            margin: 1.5rem auto;
        }

        .response, .raw-result {
            padding: 1.25rem;
        }

        h3 {
            font-size: 1rem;
        }
    }
</style>
```

## File: `src/lib/components/SendButton.svelte`
```
<script lang="ts">
    import { createEventDispatcher } from 'svelte';

    export let disabled: boolean = false;
    export let loading: boolean = false;

    const dispatch = createEventDispatcher<{
        click: void;
    }>();

    function handleClick() {
        if (!disabled && !loading) {
            dispatch('click');
        }
    }
</script>

<button
    class="send-button"
    on:click={handleClick}
    {disabled}
    aria-label="Send message"
>
    {#if loading}
        <span class="loading"></span>
    {:else}
        <svg
            xmlns="http://www.w3.org/2000/svg"
            width="20"
            height="20"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            stroke-width="2"
            stroke-linecap="round"
            stroke-linejoin="round"
            class="send-icon"
        >
            <line x1="22" y1="2" x2="11" y2="13"></line>
            <polygon points="22 2 15 22 11 13 2 9 22 2"></polygon>
        </svg>
    {/if}
</button>

<style>
    .send-button {
        position: absolute;
        bottom: 1rem;
        right: 2rem;
        display: flex;
        align-items: center;
        justify-content: center;
        width: 36px;
        height: 36px;
        border: none;
        border-radius: 10px;
        background: linear-gradient(135deg, var(--primary-color), var(--secondary-color));
        color: white;
        cursor: pointer;
        transition: all 0.2s ease;
        box-shadow: 0 2px 4px rgba(67, 97, 238, 0.15);
    }

    .send-button:hover:not(:disabled) {
        transform: translateY(-1px);
        box-shadow: 0 4px 8px rgba(67, 97, 238, 0.2);
    }

    .send-button:active:not(:disabled) {
        transform: translateY(0);
        box-shadow: 0 2px 4px rgba(67, 97, 238, 0.15);
    }

    .send-button:disabled {
        background: #e2e8f0;
        cursor: not-allowed;
        opacity: 0.7;
    }

    .send-icon {
        transition: transform 0.2s ease;
    }

    .send-button:hover:not(:disabled) .send-icon {
        transform: translate(1px, -1px);
    }

    .loading {
        width: 16px;
        height: 16px;
        border: 2px solid rgba(255, 255, 255, 0.8);
        border-radius: 50%;
        border-top-color: transparent;
        animation: spin 0.8s linear infinite;
    }

    @keyframes spin {
        to {
            transform: rotate(360deg);
        }
    }

    @media (max-width: 640px) {
        .send-button {
            width: 34px;
            height: 34px;
        }

        .send-icon {
            width: 18px;
            height: 18px;
        }

        .loading {
            width: 14px;
            height: 14px;
        }
    }
</style>
```

## File: `src/lib/constants.ts`
```
import type { DocumentationPick } from './types';

export const PERPLEXITY_API_KEY: string = import.meta.env.VITE_PERPLEXITY_API_KEY;
export const PERPLEXITY_MODEL: string = import.meta.env.VITE_PERPLEXITY_MODEL;

export const PERPLEXITY_API_URL = 'https://api.perplexity.ai/chat/completions';

export const TAVILY_API_KEY: string = import.meta.env.VITE_TAVILY_API_KEY;
export const TAVILY_API_URL = 'https://api.tavily.com/search';
export const TAVILY_EXTRACT_API_URL = 'https://api.tavily.com/extract';

export const DOCUMENTATION_PICKS: DocumentationPick[] = [
    {
        name: 'EU Alternatives',
        domain: 'european-alternatives.eu',
        selected: false
    },
    {
        name: 'Drugs.com Effects',
        domain: 'drugs.com',
        selected: false
    },
    {
        name: 'Worldwide Search',
        domain: '*',
        selected: false
    },
    {
        name: 'Langchain-JS',
        domain: 'js.langchain.com',
        selected: false
    },
    {
        name: 'Langchain-Python',
        domain: 'python.langchain.com',
        selected: false
    },
    {
        name: 'LlamaIndex',
        domain: 'docs.llamaindex.ai',
        selected: false
    },
    {
        name: 'Google Shopping API',
        domain: 'developers.google.com',
        selected: false
    },
    {
        name: 'Google Ads API',
        domain: 'developers.google.com',
        selected: false
    },
    {
        name: 'Intercom',
        domain: 'intercom.com',
        selected: false
    }
    
];
```

## File: `src/lib/index.ts`
```
// place files you want to import through the `$lib` alias in this folder.

export * from './types';
export { default as MarkdownDisplay } from './components/MarkdownDisplay.svelte';
```

## File: `src/lib/llm/LlmConnectService.ts`
```
import type { Provider } from "$lib/llm/types_chat";

interface LLMConnectServiceTokenInfo {
    // Common fields across providers
    total_tokens: number;
    
    // OpenAI, Mistral, OpenRouter specific
    prompt_tokens?: number;
    completion_tokens?: number;
    
    // Anthropic specific
    input_tokens?: number;
    output_tokens?: number;
    cache_creation_input_tokens?: number;
    cache_read_input_tokens?: number;

    // Gemini specific
    promptTokenCount?: number;
    candidatesTokenCount?: number;
    promptTokensDetails?: any;
    candidatesTokensDetails?: any;
}

interface LLMConnectServiceResponse {
    answer: string;
    token_info: LLMConnectServiceTokenInfo;
    
    // Common metadata
    id?: string;
    model?: string;
    
    // Provider specific
    provider?: string;          // OpenRouter specific
    object?: string;           // OpenAI, Mistral, OpenRouter
    created?: number;          // Timestamp
    stop_reason?: string;      // Anthropic
    type?: string;            // Anthropic
    role?: string;            // Anthropic
}

export const API_ENDPOINTS_BASE: Record<Provider, string> = {
    openai: 'https://api.openai.com/v1',
    anthropic: 'https://api.anthropic.com/v1',
    gemini: 'https://generativelanguage.googleapis.com/v1beta',
    mistral: 'https://api.mistral.ai/v1',
    openrouter: 'https://openrouter.ai/api/v1'
};

export class LlmConnectService {

    API_ENDPOINTS: Record<Provider, string> = {
        openai: API_ENDPOINTS_BASE.openai + '/chat/completions',
        anthropic: API_ENDPOINTS_BASE.anthropic + '/messages',
        gemini: API_ENDPOINTS_BASE.gemini,
        mistral: API_ENDPOINTS_BASE.mistral + '/chat/completions',
        openrouter: API_ENDPOINTS_BASE.openrouter + '/chat/completions'
    };

    private TEMPERATURE: number = 0.3;
    private MAX_OUTPUT_TOKENS: number = 8192;

    async callOpenAI(model: string, apiKey: string, messages: Array<{ role: string; content: string }>): Promise<LLMConnectServiceResponse> {
        const response = await fetch(this.API_ENDPOINTS.openai, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${apiKey}`,
            },
            body: JSON.stringify({
                model,
                messages,
                temperature: this.TEMPERATURE,
                max_tokens: this.MAX_OUTPUT_TOKENS,
            }),
        });

        if (!response.ok) {
            throw new Error(`OpenAI API error: ${response.statusText}`);
        }

        const data = await response.json();
        if (data.error) {
            console.log('OpenAI response error:', data);
            throw new Error(`OpenAI API error: ${JSON.stringify(data.error)}`);
        }

        return {
            answer: data.choices[0].message.content,
            token_info: {
                total_tokens: data.usage.total_tokens,
                prompt_tokens: data.usage.prompt_tokens,
                completion_tokens: data.usage.completion_tokens
            },
            id: data.id,
            model: data.model,
            object: data.object,
            created: data.created
        } as LLMConnectServiceResponse;
    }

    async callAnthropic(model: string, apiKey: string, messages: Array<{ role: string; content: string }>): Promise<LLMConnectServiceResponse> {
        const requestBody = {
            model,
            system: `You are a helpful AI assistant that answers questions in a concise and friendly manner.
            You are given a question and a context.
            You need to answer the question based on the context.
            Answer the question in natural language.
            If you don't know the answer, just say "I don't know".
            `,
            messages: messages.map(msg => ({
                role: msg.role === 'user' ? 'user' : 'assistant',
                content: msg.content
            })),
            max_tokens: this.MAX_OUTPUT_TOKENS,
            temperature: this.TEMPERATURE,
        };

        const response = await fetch(this.API_ENDPOINTS.anthropic, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'x-api-key': apiKey,
                'anthropic-version': '2023-06-01',
            },
            body: JSON.stringify(requestBody),
        });

        if (!response.ok) {
            throw new Error(`Anthropic API error: ${response.statusText}`);
        }

        const data = await response.json();
        if (data.error) {
            console.log('Anthropic response error:', data);
            throw new Error(`Anthropic API error: ${JSON.stringify(data.error)}`);
        }

        return {
            answer: data.content[0].text,
            token_info: {
                total_tokens: data.usage.input_tokens + data.usage.output_tokens,
                input_tokens: data.usage.input_tokens,
                output_tokens: data.usage.output_tokens,
                cache_creation_input_tokens: data.usage.cache_creation_input_tokens,
                cache_read_input_tokens: data.usage.cache_read_input_tokens
            },
            id: data.id,
            model: data.model,
            type: data.type,
            role: data.role,
            stop_reason: data.stop_reason
        } as LLMConnectServiceResponse;
    }

    async callGemini(model: string, apiKey: string, messages: Array<{ role: string; content: string }>): Promise<LLMConnectServiceResponse> {
        const prompt = messages.map(m => m.content).join('\n');
        const modelEndpoint = `${this.API_ENDPOINTS.gemini}/${model}:generateContent?key=${apiKey}`;

        const requestBody = {
            contents: [{
                parts: [{
                    text: prompt
                }]
            }],
            generationConfig: {
                temperature: this.TEMPERATURE,
                // topK: 40,
                // topP: 0.95,
                maxOutputTokens: this.MAX_OUTPUT_TOKENS,
            },
            safetySettings: [{
                category: "HARM_CATEGORY_HARASSMENT",
                threshold: "BLOCK_NONE"
            }]
        };

        const response = await fetch(modelEndpoint, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(requestBody),
        });

        if (!response.ok) {
            const resData = await response.text();
            throw new Error(`Gemini API error: ${response.statusText} (${response.status}) - resData: ${resData}`);
        }

        const data = await response.json();
        if (data.error) {
            console.log('Gemini response error:', data);
            throw new Error(`Gemini API error: ${JSON.stringify(data.error)}`);
        }

        return {
            answer: data.candidates[0].content.parts[0].text,
            token_info: {
                total_tokens: data.usageMetadata.totalTokenCount,
                promptTokenCount: data.usageMetadata.promptTokenCount,
                candidatesTokenCount: data.usageMetadata.candidatesTokenCount,
                promptTokensDetails: data.usageMetadata.promptTokensDetails,
                candidatesTokensDetails: data.usageMetadata.candidatesTokensDetails
            },
            model: model
        } as LLMConnectServiceResponse;
    }

    async callMistral(model: string, apiKey: string, messages: Array<{ role: string; content: string }>): Promise<LLMConnectServiceResponse> {
        const requestBody = {
            model,
            messages,
            temperature: this.TEMPERATURE,
            max_tokens: this.MAX_OUTPUT_TOKENS,
        };

        const response = await fetch(this.API_ENDPOINTS.mistral, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${apiKey}`,
            },
            body: JSON.stringify(requestBody),
        });

        if (!response.ok) {
            throw new Error(`Mistral API error: ${response.statusText}`);
        }

        const data = await response.json();
        if (data.error) {
            console.log('Mistral response error:', data);
            throw new Error(`Mistral API error: ${JSON.stringify(data.error)}`);
        }
        
        return {
            answer: data.choices[0].message.content,
            token_info: {
                total_tokens: data.usage.total_tokens,
                prompt_tokens: data.usage.prompt_tokens,
                completion_tokens: data.usage.completion_tokens
            },
            id: data.id,
            model: model,
            object: data.object,
            created: data.created
        } as LLMConnectServiceResponse;
    }

    async callOpenRouter(model: string, apiKey: string, messages: Array<{ role: string; content: string }>): Promise<LLMConnectServiceResponse> {
        const requestBody = {
            model,
            messages,
            temperature: this.TEMPERATURE,
            max_tokens: this.MAX_OUTPUT_TOKENS,
        };

        const response = await fetch(this.API_ENDPOINTS.openrouter, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${apiKey}`,
            },
            body: JSON.stringify(requestBody),
        });

        if (!response.ok) {
            throw new Error(`OpenRouter API error: ${response.statusText}`);
        }

        const data = await response.json();
        if (data.error) {
            console.log('OpenRouter response error:', data);
            throw new Error(`OpenRouter API error: ${JSON.stringify(data.error)}`);
        }
        
        return {
            answer: data.choices[0].message.content,
            token_info: {
                total_tokens: data.usage.total_tokens,
                prompt_tokens: data.usage.prompt_tokens,
                completion_tokens: data.usage.completion_tokens
            },
            id: data.id,
            model: data.model,
            provider: data.provider,
            object: data.object,
            created: data.created
        } as LLMConnectServiceResponse;
    }

    async generateAnswerRaw(provider: string, model: string, apiKey: string, messages: Array<{ role: string; content: string }>): Promise<LLMConnectServiceResponse> {
        let llmResponse: LLMConnectServiceResponse;
        try {
            switch (provider) {
                case 'openai':
                    llmResponse = await this.callOpenAI(model, apiKey, messages);
                    break;
                case 'anthropic':
                    llmResponse = await this.callAnthropic(model, apiKey, messages);
                    break;
                case 'gemini':
                    llmResponse = await this.callGemini(model, apiKey, messages);
                    break;
                case 'mistral':
                    llmResponse = await this.callMistral(model, apiKey, messages);
                    break;
                case 'openrouter':
                    llmResponse = await this.callOpenRouter(model, apiKey, messages);
                    break;
                default:
                    throw new Error('Unsupported provider "' + provider + '"');
            }
        } catch (error) {
            console.error('Error in chat endpoint:', error);
            throw new Error('An error occurred while calling the LLM for the final response. ' + error);
        }
        console.log('LlmResponse.token_info:', llmResponse.token_info);
        return llmResponse;
    }

    async generateAnswer(provider: string, model: string, apiKey: string, messages: Array<{ role: string; content: string }>): Promise<string> {
        try {
            let llmResponse: LLMConnectServiceResponse = await this.generateAnswerRaw(provider, model, apiKey, messages);
            return llmResponse.answer;
        } catch (error) {
            return (error as Error).message;
        }
    }
}
```

## File: `src/lib/llm/prompts.ts`
```
const COMBINER_PROMPT = `
You are a precise and helpful AI assistant helping to answer questions based on search results.
Your task is to combine the following search results into a comprehensive, coherent answer in the language of the users request.

<search-results>
{theAnswer}
</search-results>

<user-request>
{query}
</user-request>

<important-guidelines>
    <guideline>Rely exclusively on information from the provided search results.</guideline>
    <guideline>Respond in the same language as the user's original request.</guideline>
    <guideline>Create a clear, concise, and accurate answer based only on the given information.</guideline>
    <guideline>Avoid adding any information not found in the search results or making speculations.</guideline>
    <guideline>Include relevant facts from the search results without direct quotations or attributions.</guideline>
    <guideline>Present each fact only once, even if it appears in multiple sources.</guideline>
    <guideline>Never mention or reference the search engines or sources by name in your answer.</guideline>
    <guideline>Do not use phrases like "according to the search results" or similar references.</guideline>
    <guideline>Do not include direct quotes with attribution markers like [" "] or source references.</guideline>
    <guideline>Keep your answer concise and directly relevant to the user's question.</guideline>
    <guideline>For simple factual questions, provide just the specific information requested without unnecessary details.</guideline>
</important-guidelines>
    
<answer-format-instructions>
    <format-instruction>Structure the answer using markdown formatting.</format-instruction>
    <format-instruction>Answer in a strutured, clear, correct and easily consumable way.</format-instruction>
    <format-instruction>If applicable, use for structuring elements like bold names, bullet points, lists, tables, ... to make the answer more readable</format-instruction>
    <format-instruction>If the topic needs a larger answer then use shorter sentences and paragraphs and think about using more structuring elements.</format-instruction>
</answer-format-instructions>
`;

export function getCombinerPrompt(query: string, theAnswer: string) {
    return COMBINER_PROMPT.replace('{query}', query).replace('{theAnswer}', theAnswer);
}
```

## File: `src/lib/llm/types_chat.ts`
```
export interface ChatMessage {
    id: string;
    role: 'user' | 'assistant';
    content: string;
    timestamp: number;
    provider: string;
    model: string;
}

export interface ChatSession {
    id: string;
    title: string;
    messages: ChatMessage[];
    provider: string;
    model: string;
    created: number;
    updated: number;
    usePerplexity: boolean;
    useResearchAssistant?: boolean;
}

export type Provider = 'openai' | 'anthropic' | 'gemini' | 'mistral' | 'openrouter';

export interface ProviderConfig {
    name: Provider;
    apiKey?: string;
    models: string[];
    enabled: boolean;
}

export interface SearchEngineConfig {
    apiKey?: string;
    enabled: boolean;
}

export interface GetKeysStateResponse {
    providers: Record<Provider, boolean>;
    searchEngines: Record<string, boolean>;
    hasGroupApiKey: boolean;
}

export interface Settings {
    providers: Record<Provider, ProviderConfig>;
    searchEngines: {
        perplexity: SearchEngineConfig;
        tavily: SearchEngineConfig;
    };
    theme: 'light' | 'dark';
    groupApiKey?: string;
}
```

## File: `src/lib/search-engines/perplexity.ts`
```
import { PERPLEXITY_API_KEY, PERPLEXITY_API_URL, PERPLEXITY_MODEL } from '$lib/constants';
import type { SingleChatResponse, PerplexityResponse } from '$lib/types';
import type { ISearchEngine } from './types';

export class PerplexitySearchEngine implements ISearchEngine {
    async search(query: string, pickedDomains: string[]): Promise<SingleChatResponse> {
        if (!PERPLEXITY_API_KEY) {
            throw new Error('Perplexity API key is not set');
        }

        // Check if worldwide is selected
        const isWorldwide = pickedDomains.includes('*');

        // Create the system message with domain restrictions only if not worldwide
        const systemMessage = isWorldwide
            ? 'You are a helpful assistant that answers questions about any topic. Be precise and concise.'
            : `You are a helpful assistant that answers questions about documentation. Please only use information from these domains: ${pickedDomains.join(', ')}. Be precise and concise.`;

        const requestBody = {
            model: PERPLEXITY_MODEL,
            messages: [
                {
                    role: 'system',
                    content: systemMessage
                },
                {
                    role: 'user',
                    content: query
                }
            ],
            // Only include domain filter if not worldwide
            ...(isWorldwide ? {} : { search_domain_filter: pickedDomains })
        };

        const response = await fetch(PERPLEXITY_API_URL, {
            method: 'POST',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${PERPLEXITY_API_KEY}`
            },
            body: JSON.stringify(requestBody)
        });

        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`Perplexity API error: ${response.status} ${errorText}`);
        }

        const perplexityResponse = await response.json() as PerplexityResponse;
        
        // Extract the message content
        const choice = perplexityResponse.choices[0];
        if (!choice || !choice.message || !choice.message.content) {
            throw new Error('Invalid response from Perplexity API');
        }

        return {
            answer: "## Perplexity Search-Agent Result\n" + choice.message.content,
            citations: perplexityResponse.citations
        };
    }
}
```

## File: `src/lib/search-engines/tavily.ts`
```
import { TAVILY_API_KEY, TAVILY_API_URL, TAVILY_EXTRACT_API_URL } from '$lib/constants';
import type { SingleChatResponse } from '$lib/types';
import type { ISearchEngine } from './types';

interface TavilyResponse {
    query: string;
    answer: string;
    results: {
        title: string;
        url: string;
        content: string;
        score: number;
    }[];
}

interface TavilyExtractResponse {
    results: {
        url: string;
        raw_content: string;
        images: string[];
    }[];
    failed_results: {
        url: string;
        error: string;
    }[];
    response_time: number;
}

export class TavilySearchEngine implements ISearchEngine {
    async search(query: string, pickedDomains: string[]): Promise<SingleChatResponse> {
        if (!TAVILY_API_KEY) {
            throw new Error('Tavily API key is not set');
        }

        // Check if worldwide is selected
        const isWorldwide = pickedDomains.includes('*');

        const requestBody = {
            query,
            include_answer: "advanced" as const,
            // Only include domain restrictions if not worldwide
            ...(isWorldwide ? {} : { include_domains: pickedDomains })
        };

        const response = await fetch(TAVILY_API_URL, {
            method: 'POST',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${TAVILY_API_KEY}`
            },
            body: JSON.stringify(requestBody)
        });

        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`Tavily API error: ${response.status} ${errorText}`);
        }

        const tavilyResponse = await response.json() as TavilyResponse;
        
        if (!tavilyResponse.answer) {
            throw new Error('Invalid response from Tavily API');
        }

        // Extract citations from the results
        const citations = tavilyResponse.results.map(result => result.url);

        return {
            answer: "## Doc-Rocker Search-Agent Result\n" + tavilyResponse.answer,
            citations
        };
    }

    async extract(url: string): Promise<string> {
        if (!TAVILY_API_KEY) {
            throw new Error('Tavily API key is not set');
        }

        const requestBody = {
            urls: url,
            include_images: false,
            extract_depth: "basic" as const
        };

        const response = await fetch(TAVILY_EXTRACT_API_URL, {
            method: 'POST',
            headers: {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${TAVILY_API_KEY}`
            },
            body: JSON.stringify(requestBody)
        });

        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`Tavily Extract API error: ${response.status} ${errorText}`);
        }

        const extractResponse = await response.json() as TavilyExtractResponse;
        
        if (!extractResponse.results || extractResponse.results.length === 0) {
            throw new Error('No content extracted from the URL');
        }

        return extractResponse.results[0].raw_content;
    }
}
```

## File: `src/lib/search-engines/types.ts`
```
import type { SingleChatResponse } from '$lib/types';

export interface ISearchEngine {
    /**
     * Performs a search query against the documentation
     * @param query The user's question
     * @param pickedDomains The selected documentation sources
     * @returns A promise that resolves to the search response
     */
    search(query: string, pickedDomains: string[]): Promise<SingleChatResponse>;
}
```

## File: `src/lib/services/SearchService.test.ts`
```
import { describe, it, expect, vi, beforeEach } from 'vitest';
import type { SingleChatResponse, CombinedChatResponse } from '$lib/types';

// Mock the search engines - we'll create a mock SearchService
const mockPerplexitySearch = vi.fn();
const mockTavilySearch = vi.fn();
const mockLlmGenerate = vi.fn();

// Mock SearchService implementation
class MockSearchService {
  async searchDocumentation(query: string, pickedDomains: string[]): Promise<CombinedChatResponse> {
    if (!query) {
      throw new Error('Query is required');
    }
    if (!pickedDomains || pickedDomains.length === 0) {
      throw new Error('At least one documentation source must be selected');
    }

    const pickedDomainsQueryString = pickedDomains.map(domain => `site:${domain}`).join(' ');
    const perplexityQuery = query + ' ' + pickedDomainsQueryString;

    let perplexityResult: SingleChatResponse;
    let tavilyResult: SingleChatResponse;

    try {
      perplexityResult = await mockPerplexitySearch(perplexityQuery, []);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      perplexityResult = { answer: `**Perplexity Search Error:** ${errorMessage}`, citations: [] };
    }

    try {
      tavilyResult = await mockTavilySearch(query, pickedDomains);
    } catch (error) {
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      tavilyResult = { answer: `**Doc-Rocker Search Error:** ${errorMessage}`, citations: [] };
    }

    let combinedAnswer = tavilyResult.answer + "\n\n" + perplexityResult.answer;

    try {
      const llmResponse = await mockLlmGenerate();
      const modelInfoString = "_AI-Model: " + llmResponse.model + "_";
      const warningString = "_**Please verify the information before using it.** The answer is based on search results still may contain errors. Check the links below for more information._";
      let llmAnswerCleaned = llmResponse.answer.trim();
      combinedAnswer = "## AI Answer\n" + llmAnswerCleaned + "\n\n---\n\n" + warningString + "\n\n" + modelInfoString;
    } catch (error) {
      combinedAnswer = "Error retrieving combined answer. Here is the raw answer from the search engines: " + combinedAnswer;
    }

    const combinedResult: SingleChatResponse = {
      answer: combinedAnswer,
      citations: [...(tavilyResult.citations || []), ...(perplexityResult.citations || [])]
    };

    return {
      combined_search_result: combinedResult,
      raw_search_results: [tavilyResult, perplexityResult]
    };
  }
}

describe('SearchService', () => {
  let searchService: MockSearchService;

  beforeEach(async () => {
    vi.clearAllMocks();
    searchService = new MockSearchService();
  });

  describe('searchDocumentation', () => {
    it('should combine search results from both Perplexity and Tavily', async () => {
      // Arrange
      const query = 'How to use SvelteKit?';
      const pickedDomains = ['kit.svelte.dev'];

      const perplexityResult: SingleChatResponse = {
        answer: 'Perplexity answer about SvelteKit',
        citations: ['https://perplexity.source.com']
      };

      const tavilyResult: SingleChatResponse = {
        answer: 'Tavily answer about SvelteKit',
        citations: ['https://tavily.source.com']
      };

      const llmCombinedResult = {
        answer: 'Combined AI answer about SvelteKit',
        model: 'gemini-2.0-flash-exp'
      };

      mockPerplexitySearch.mockResolvedValue(perplexityResult);
      mockTavilySearch.mockResolvedValue(tavilyResult);
      mockLlmGenerate.mockResolvedValue(llmCombinedResult);

      // Act
      const result = await searchService.searchDocumentation(query, pickedDomains);

      // Assert
      expect(result).toBeDefined();
      expect(result.combined_search_result).toBeDefined();
      expect(result.raw_search_results).toHaveLength(2);
      expect(result.combined_search_result.answer).toContain('Combined AI answer about SvelteKit');
      expect(result.combined_search_result.citations).toEqual([
        'https://tavily.source.com',
        'https://perplexity.source.com'
      ]);
    });

    it('should handle search engine failures gracefully', async () => {
      // Arrange
      const query = 'Test query';
      const pickedDomains = ['test.com'];

      mockPerplexitySearch.mockRejectedValue(new Error('Perplexity API error'));
      mockTavilySearch.mockResolvedValue({
        answer: 'Tavily result',
        citations: ['https://tavily.source.com']
      });
      mockLlmGenerate.mockResolvedValue({
        answer: 'Combined answer despite error',
        model: 'gemini-2.0-flash-exp'
      });

      // Act
      const result = await searchService.searchDocumentation(query, pickedDomains);

      // Assert
      expect(result).toBeDefined();
      expect(result.raw_search_results).toHaveLength(2);
      expect(result.raw_search_results[1].answer).toContain('Perplexity Search Error');
    });

    it('should format domain restrictions for Perplexity correctly', async () => {
      // Arrange
      const query = 'Test query';
      const pickedDomains = ['kit.svelte.dev', 'svelte.dev'];

      mockPerplexitySearch.mockResolvedValue({ answer: 'Result', citations: [] });
      mockTavilySearch.mockResolvedValue({ answer: 'Result', citations: [] });
      mockLlmGenerate.mockResolvedValue({ answer: 'Combined', model: 'test' });

      // Act
      await searchService.searchDocumentation(query, pickedDomains);

      // Assert
      expect(mockPerplexitySearch).toHaveBeenCalledWith(
        'Test query site:kit.svelte.dev site:svelte.dev',
        []
      );
      expect(mockTavilySearch).toHaveBeenCalledWith(
        query,
        ['kit.svelte.dev', 'svelte.dev']
      );
    });

    it('should throw error for empty pickedDomains array', async () => {
      // Arrange
      const query = 'Test query';
      const pickedDomains: string[] = [];

      // Act & Assert
      await expect(searchService.searchDocumentation(query, pickedDomains))
        .rejects.toThrow('At least one documentation source must be selected');
    });

    it('should throw error for empty query', async () => {
      // Arrange
      const query = '';
      const pickedDomains = ['test.com'];

      // Act & Assert
      await expect(searchService.searchDocumentation(query, pickedDomains))
        .rejects.toThrow('Query is required');
    });
  });
}); 
```

## File: `src/lib/services/SearchService.ts`
```
import { PerplexitySearchEngine } from '$lib/search-engines/perplexity';
import { TavilySearchEngine } from '$lib/search-engines/tavily';
import { LlmConnectService } from '$lib/llm/LlmConnectService';
import { getCombinerPrompt } from '$lib/llm/prompts';
import type { 
  SingleChatResponse, 
  CombinedChatResponse 
} from '$lib/types';

/**
 * Service class that handles documentation search functionality.
 * Extracted from the original /api/chat endpoint to be reusable.
 */
export class SearchService {
  private perplexitySearchEngine: PerplexitySearchEngine;
  private tavilySearchEngine: TavilySearchEngine;
  private llm: LlmConnectService;
  private combinerProvider: string;
  private combinerProviderModel: string;
  private combinerApiKey: string;

  constructor() {
    this.perplexitySearchEngine = new PerplexitySearchEngine();
    this.tavilySearchEngine = new TavilySearchEngine();
    this.llm = new LlmConnectService();
    this.combinerProvider = import.meta.env.VITE_COMBINER_PROVIDER;
    this.combinerProviderModel = import.meta.env.VITE_COMBINER_PROVIDER_MODEL;
    this.combinerApiKey = import.meta.env.VITE_COMBINER_API_KEY;
  }

  /**
   * Search documentation using both Perplexity and Tavily search engines,
   * then combine the results using an LLM.
   */
  async searchDocumentation(
    query: string, 
    pickedDomains: string[]
  ): Promise<CombinedChatResponse> {
    
    if (!query) {
      throw new Error('Query is required');
    }

    if (!pickedDomains || pickedDomains.length === 0) {
      throw new Error('At least one documentation source must be selected');
    }

    // Prepare search queries
    const pickedDomainsQueryString = pickedDomains.map(domain => `site:${domain}`).join(' ');
    const perplexityQuery = query + ' ' + pickedDomainsQueryString;

    // Start both searches in parallel
    const perplexityPromise = this.perplexitySearchEngine.search(perplexityQuery, []);
    const tavilyPromise = this.tavilySearchEngine.search(query, pickedDomains);

    // Wait for both searches to complete and handle errors gracefully
    let perplexityResult: SingleChatResponse;
    let tavilyResult: SingleChatResponse;

    try {
      perplexityResult = await perplexityPromise;
    } catch (error) {
      console.error('Perplexity search error:', error);
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      perplexityResult = { 
        answer: `**Perplexity Search Error:** ${errorMessage}`, 
        citations: [] 
      };
    }

    try {
      tavilyResult = await tavilyPromise;
    } catch (error) {
      console.error('Tavily search error:', error);
      const errorMessage = error instanceof Error ? error.message : 'Unknown error';
      tavilyResult = { 
        answer: `**Doc-Rocker Search Error:** ${errorMessage}`, 
        citations: [] 
      };
    }

    // Combine the answers
    let combinedAnswer = tavilyResult.answer + "\n\n" + perplexityResult.answer;

    // Use LLM to create a better combined answer
    try {
      const llmResponse = await this.llm.generateAnswerRaw(
        this.combinerProvider, 
        this.combinerProviderModel, 
        this.combinerApiKey, 
        [{ role: 'user', content: getCombinerPrompt(query, combinedAnswer) }]
      );
      
      const modelInfoString = "_AI-Model: " + llmResponse.model + "_";
      const warningString = "_**Please verify the information before using it.** The answer is based on search results still may contain errors. Check the links below for more information._";
      let llmAnswerCleaned = llmResponse.answer.trim();
      combinedAnswer = "## AI Answer\n" + llmAnswerCleaned + "\n\n---\n\n" + warningString + "\n\n" + modelInfoString;
    } catch (error) {
      console.error('Failed to get combined answer:', error);
      combinedAnswer = "Error retrieving combined answer. Here is the raw answer from the search engines: " + combinedAnswer;
    }

    // Create the final response
    const combinedResult: SingleChatResponse = {
      answer: combinedAnswer,
      citations: [...(tavilyResult.citations || []), ...(perplexityResult.citations || [])]
    };

    return {
      combined_search_result: combinedResult,
      raw_search_results: [tavilyResult, perplexityResult]
    };
  }
} 
```

## File: `src/lib/types.ts`
```

export interface DocumentationPick {
    name: string;
    domain: string;
    selected?: boolean;
}

export interface ChatMessage {
    role: 'system' | 'user' | 'assistant';
    content: string;
}

export interface ChatRequest {
    query: string;
    documentationPicks: DocumentationPick[];
}

export interface CombinedChatResponse {
    combined_search_result: SingleChatResponse;
    raw_search_results: SingleChatResponse[];
}

export interface SingleChatResponse {
    answer: string;
    citations?: string[];
}

export interface PerplexityResponse {
    id: string;
    model: string;
    object: string;
    created: number;
    citations: string[];
    choices: {
        index: number;
        finish_reason: 'stop' | 'length';
        message: {
            role: string;
            content: string;
        };
        delta?: {
            role: string;
            content: string;
        };
    }[];
    usage: {
        prompt_tokens: number;
        completion_tokens: number;
        total_tokens: number;
    };
}
```

## File: `src/routes/+layout.server.ts`
```
export const load = async () => {
    return {};
};
```

## File: `src/routes/+layout.ts`
```
export const ssr = true;
export const prerender = false;
```

## File: `src/routes/+page.svelte`
```
<script lang="ts">
    import LogoGfx from '$lib/components/LogoGfx.svelte';
    import InputField from '$lib/components/InputField.svelte';
    import SendButton from '$lib/components/SendButton.svelte';
    import DocumentationPicks from '$lib/components/DocumentationPicks.svelte';
    import ResponseDisplay from '$lib/components/ResponseDisplay.svelte';
    import type { DocumentationPick, CombinedChatResponse, SingleChatResponse } from '$lib/types';

    let query: string = '';
    let loading: boolean = false;
    let error: string | null = null;
    let response: string = '';
    let citations: string[] = [];
    let rawResults: SingleChatResponse[] = [];
    let selectedPicks: DocumentationPick[] = [];
    let statusMessage: string = '';
    let queryTooLong: boolean = false;

    function processSSEMessage(line: string) {
        if (line.startsWith('data: ')) {
            try {
                const data = JSON.parse(line.slice(5));
                if (data.type === 'status') {
                    if (statusMessage !== '') {
                        statusMessage += "<br>";
                    }
                    statusMessage += data.message;
                } else if (data.type === 'final') {
                    const combinedResult = data.result as CombinedChatResponse;
                    response = combinedResult.combined_search_result.answer;
                    citations = combinedResult.combined_search_result.citations || [];
                    rawResults = combinedResult.raw_search_results;
                }
            } catch (parseError) {
                console.error('Error parsing SSE message:', parseError);
            }
        }
    }

    function processSSEMessages(messageText: string) {
        const lines = messageText.split('\n');
        for (const line of lines) {
            processSSEMessage(line);
        }
    }

    async function handleSubmit() {
        if (!query.trim()) {
            error = 'Please enter a query';
            return;
        }

        if (query.length > 400) {
            error = 'Query is too long. Tavily search requires 400 characters or less.';
            return;
        }

        if (selectedPicks.length === 0) {
            error = 'Please select at least one documentation source';
            return;
        }

        // Check if worldwide is selected
        const hasWorldwide = selectedPicks.some(pick => pick.domain === '*');
        
        // Only apply the single source limit if not worldwide and in beta
        if (!hasWorldwide && selectedPicks.length > 1) {
            error = 'Currently limited to 1 documentation source while in beta. This limit will be increased over time.';
            return;
        }
        
        loading = true;
        error = null;
        response = '';
        citations = [];
        rawResults = [];
        statusMessage = '';

        setTimeout(() => {
            const statusMessageElement = document.getElementById('status_message');
            if (statusMessageElement) {
                statusMessageElement.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
            }
        }, 10);
        
        try {
            const res = await fetch('/api/chat', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({
                    query,
                    documentationPicks: selectedPicks
                })
            });

            if (!res.ok) {
                const data = await res.json();
                throw new Error(data.error || 'Failed to get response');
            }

            // Make sure we're getting a proper streaming response
            const contentType = res.headers.get('Content-Type');
            if (!contentType || !contentType.includes('text/event-stream')) {
                throw new Error('Server did not return an event stream');
            }

            const reader = res.body?.getReader();
            if (!reader) {
                throw new Error('No response stream available');
            }

            const decoder = new TextDecoder();
            let buffer = ''; // Buffer for incomplete chunks

            while (true) {
                const { done, value } = await reader.read();
                if (done) break;

                // Append the new chunk to any existing buffered data
                buffer += decoder.decode(value, { stream: true });
                
                // Process complete SSE messages (they end with double newlines)
                const messages = buffer.split('\n\n');
                buffer = messages.pop() || ''; // Keep the last incomplete chunk in the buffer
                
                for (const message of messages) {
                    processSSEMessages(message);
                }
            }

            // Process any remaining data in the buffer
            if (buffer.trim()) {
                processSSEMessages(buffer);
            }
        } catch (e) {
            error = e instanceof Error ? e.message : 'An error occurred';
        } finally {
            loading = false;
            statusMessage = '';
            
            // Add a small delay to ensure DOM is updated before scrolling
            setTimeout(() => {
                const combinedResult = document.getElementById('combined_result');
                if (combinedResult && response) {
                    combinedResult.scrollIntoView({ behavior: 'smooth', block: 'start' });
                }
            }, 10);
        }
    }

    function handlePicksChange(event: CustomEvent<DocumentationPick[]>) {
        selectedPicks = event.detail;
    }

    function handleQueryTooLong(event: CustomEvent<boolean>) {
        queryTooLong = event.detail;
    }
</script>

<main class="container">
    <LogoGfx {loading} />

    <div class="chat-interface">

        <div class="input-area">
            <InputField
            bind:value={query}
            disabled={loading}
            on:submit={handleSubmit}
            on:tooLong={handleQueryTooLong}
            />
            <SendButton
            {loading}
            disabled={loading || !query.trim() || selectedPicks.length === 0 || queryTooLong}
            on:click={handleSubmit}
            />
        </div>

        <DocumentationPicks on:change={handlePicksChange} />

        {#if loading}
            <div id="status_message" class="status-message">
                {@html statusMessage}
            </div>
        {/if}

        <ResponseDisplay 
            {response} 
            {citations} 
            {error}
            {rawResults}
        />
    </div>
</main>

<style>
    .container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 2rem;
        padding-top: 10px;
        min-height: 100vh;
        display: flex;
        flex-direction: column;
    }

    .chat-interface {
        flex: 1;
        display: flex;
        flex-direction: column;
        gap: 1rem;
        margin-top: 1rem;
    }

    .input-area {
        position: relative;
        width: 100%;
        max-width: 800px;
        margin: 0 auto;
    }
    .status-message {
        text-align: center;
        padding: 0.5rem;
        color: #666;
        font-style: italic;
        animation: fadeInOut 2s ease-in-out infinite;
        height: 200px; /* Added height to ensure the message reserves space */
    }

    @keyframes fadeInOut {
        0% { opacity: 0.4; }
        50% { opacity: 1; }
        100% { opacity: 0.4; }
    }
</style>
```

## File: `src/routes/api/chat/+server.ts`
```
import { json } from '@sveltejs/kit';
import type { RequestEvent } from '@sveltejs/kit';
import type { ChatRequest, CombinedChatResponse } from '$lib/types';
import { SearchService } from '$lib/services/SearchService';

function sendStreamMessage(writer: WritableStreamDefaultWriter, type: 'status' | 'final', data: any) {
    const message = `data: ${JSON.stringify({ type, ...data })}\n\n`;
    try {
        return writer.write(new TextEncoder().encode(message));
    } catch (error) {
        console.warn('Error writing to stream:', error);
        // Return a resolved promise to prevent unhandled rejections
        return Promise.resolve();
    }
}

export const POST = async ({ request }: RequestEvent) => {
    try {
        const { query, documentationPicks } = await request.json() as ChatRequest;

        console.log('Received request:', { query, documentationPicks });

        if (!query) {
            return json({ error: 'Query is required' }, { status: 400 });
        }

        if (!documentationPicks || documentationPicks.length === 0) {
            return json({ error: 'At least one documentation source must be selected' }, { status: 400 });
        }

        const pickedDomains = documentationPicks.map(pick => pick.domain);

        // Create a TransformStream instead of ReadableStream
        const { readable, writable } = new TransformStream();
        const writer = writable.getWriter();
        const searchService = new SearchService();

        // Start the async processing
        (async () => {
            try {
                await sendStreamMessage(writer, 'status', { message: 'Starting search engines...' });
                
                // Use the SearchService instead of duplicating logic
                const result: CombinedChatResponse = await searchService.searchDocumentation(query, pickedDomains);

                await sendStreamMessage(writer, 'status', { message: 'Search completed. Preparing results...' });

                try {
                    // Send the final result
                    await sendStreamMessage(writer, 'final', { 
                        result: result
                    });

                    // Ensure all messages have been sent
                    await new Promise(resolve => setTimeout(resolve, 250));
                } catch (error) {
                    console.warn('Error sending final results:', error);
                } finally {
                    try {
                        await writer.close();
                    } catch (error) {
                        console.warn('Error closing writer:', error);
                    }
                }
            } catch (error) {
                console.error('Error in chat endpoint:', error);
                try {
                    await sendStreamMessage(writer, 'status', { message: 'An error occurred while processing your request: ' + (error instanceof Error ? error.message : 'Unknown error') });
                    await writer.close();
                } catch (closeError) {
                    console.warn('Error while closing writer after error:', closeError);
                }
            }
        })().catch(error => {
            console.error('Unhandled error in stream processing:', error);
        });

        return new Response(readable, {
            headers: {
                'Content-Type': 'text/event-stream',
                'Cache-Control': 'no-cache',
                'Connection': 'keep-alive'
            }
        });
    } catch (error) {
        console.error('Error in chat endpoint:', error);
        return json(
            { error: error instanceof Error ? error.message : 'An error occurred' },
            { status: 500 }
        );
    }
};
```

## File: `src/routes/api/rock/+server.ts`
```
import { json } from '@sveltejs/kit';
import type { RequestEvent } from '@sveltejs/kit';
import { SearchService } from '$lib/services/SearchService';

interface RockRequest {
  query: string;
  domainRestriction: string;
}

/**
 * HTTP POST handler for /api/rock requests
 * Takes a POST request with query and domainRestriction and performs actual web search
 */
export const POST = async ({ request }: RequestEvent) => {
  try {
    // Get request metadata
    const url = new URL(request.url);
    const contentType = request.headers.get('content-type') || '';
    const userAgent = request.headers.get('user-agent') || '';
    const method = request.method;
    
    console.log('🪨 Rock API POST request received:');
    console.log('  URL:', url.href);
    console.log('  Method:', method);
    console.log('  Content-Type:', contentType);
    console.log('  User-Agent:', userAgent);
    
    // Validate User-Agent header
    const requiredUserAgent = 'Web-Search-Doc-Rocker-MCP/0.1.0';
    if (userAgent !== requiredUserAgent) {
      console.log('❌ Unauthorized User-Agent:', userAgent);
      console.log('❌ Expected User-Agent:', requiredUserAgent);
      return json(
        { 
          error: 'Unauthorized: Invalid User-Agent header',
          expected: requiredUserAgent,
          received: userAgent
        },
        { status: 401 }
      );
    }
    
    console.log('✅ User-Agent validation passed');
    
    // Read and parse the request body
    const rawBody = await request.text();
    console.log('📜 Raw request body:', rawBody);
    
    const body = JSON.parse(rawBody) as RockRequest;
    console.log('🔥 Rock POST Request parsed:', JSON.stringify(body, null, 2));
    
    // Validate the request structure
    if (!body.query || typeof body.query !== 'string') {
      return json(
        { error: 'Query parameter is required and must be a string' },
        { status: 400 }
      );
    }
    
    if (!body.domainRestriction || typeof body.domainRestriction !== 'string') {
      return json(
        { error: 'Domain restriction parameter is required and must be a string' },
        { status: 400 }
      );
    }
    
    // Convert domainRestriction string to array format expected by SearchService
    const pickedDomains = body.domainRestriction === '*' 
      ? ['*'] 
      : [body.domainRestriction];
    
    console.log('🔍 Starting search with domains:', pickedDomains);
    
    // Perform the actual search using SearchService
    const searchService = new SearchService();
    const searchResult = await searchService.searchDocumentation(body.query, pickedDomains);
    
    console.log('📤 Rock API search completed successfully');
    
    return json({
      message: 'Rock API - Search completed successfully',
      timestamp: new Date().toISOString(),
      request: {
        query: body.query,
        domainRestriction: body.domainRestriction,
        pickedDomains: pickedDomains
      },
      result: searchResult
    });
    
  } catch (error) {
    console.error('Rock API Error:', error);
    
    // Handle JSON parsing errors specifically
    if (error instanceof SyntaxError) {
      return json(
        { error: 'Invalid JSON in request body' },
        { status: 400 }
      );
    }
    
    // Handle SearchService errors
    if (error instanceof Error) {
      return json(
        { error: `Search error: ${error.message}` },
        { status: 500 }
      );
    }
    
    return json(
      { error: 'Internal server error' },
      { status: 500 }
    );
  }
}; 
```

## File: `src/routes/api/rock/server.test.ts`
```
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { POST } from './+server.js';

// Mock the SearchService
vi.mock('$lib/services/SearchService', () => {
  return {
    SearchService: vi.fn().mockImplementation(() => {
      return {
        searchDocumentation: vi.fn().mockResolvedValue({
          combined_search_result: {
            answer: "## AI Answer\nMocked search result for testing purposes.\n\n---\n\n_**Please verify the information before using it.** The answer is based on search results still may contain errors. Check the links below for more information._\n\n_AI-Model: gpt-4o-mini_",
            citations: ["https://example.com/result1", "https://example.com/result2"]
          },
          raw_search_results: [
            {
              answer: "## Doc-Rocker Search-Agent Result\nMocked Tavily result",
              citations: ["https://example.com/result1"]
            },
            {
              answer: "## Perplexity Search-Agent Result\nMocked Perplexity result", 
              citations: ["https://example.com/result2"]
            }
          ]
        })
      };
    })
  };
});

// Helper function to create a mock Request object
function createMockRequest(
  url: string,
  headers: Record<string, string> = {},
  body: string = ''
): Request {
  const request = {
    url,
    method: 'POST',
    headers: new Headers(headers),
    text: vi.fn().mockResolvedValue(body)
  } as unknown as Request;
  
  return request;
}

// Helper function to create a mock RequestEvent
function createMockRequestEvent(request: Request) {
  return {
    request,
    url: new URL(request.url),
    params: {},
    route: { id: '/api/rock' },
    platform: undefined,
    locals: {},
    getClientAddress: vi.fn(),
    cookies: {
      get: vi.fn(),
      set: vi.fn(),
      delete: vi.fn(),
      serialize: vi.fn(),
      getAll: vi.fn()
    },
    fetch: vi.fn(),
    setHeaders: vi.fn(),
    isDataRequest: false,
    isSubRequest: false
  } as any; // Use 'as any' to bypass strict typing for test mocks
}

describe('/api/rock endpoint', () => {
  const validUserAgent = 'Web-Search-Doc-Rocker-MCP/0.1.0';
  const testUrl = 'http://localhost:5173/api/rock';
  
  beforeEach(() => {
    vi.clearAllMocks();
  });
  
  describe('User-Agent validation', () => {
    it('should accept requests with correct User-Agent and return search results', async () => {
      // Arrange
      const validBody = JSON.stringify({
        query: 'test query',
        domainRestriction: '*'
      });
      
      const request = createMockRequest(testUrl, {
        'content-type': 'application/json',
        'user-agent': validUserAgent
      }, validBody);
      
      const requestEvent = createMockRequestEvent(request);
      
      // Act
      const response = await POST(requestEvent);
      const responseData = await response.json();
      
      // Assert
      expect(response.status).toBe(200);
      expect(responseData.message).toBe('Rock API - Search completed successfully');
      expect(responseData).toHaveProperty('timestamp');
      expect(responseData).toHaveProperty('request');
      expect(responseData).toHaveProperty('result');
      expect(responseData.request).toEqual({
        query: 'test query',
        domainRestriction: '*',
        pickedDomains: ['*']
      });
      expect(responseData.result).toHaveProperty('combined_search_result');
      expect(responseData.result).toHaveProperty('raw_search_results');
    });
    
    it('should reject requests with incorrect User-Agent', async () => {
      // Arrange
      const validBody = JSON.stringify({
        query: 'test query',
        domainRestriction: '*'
      });
      
      const request = createMockRequest(testUrl, {
        'content-type': 'application/json',
        'user-agent': 'curl/8.7.1'
      }, validBody);
      
      const requestEvent = createMockRequestEvent(request);
      
      // Act
      const response = await POST(requestEvent);
      const responseData = await response.json();
      
      // Assert
      expect(response.status).toBe(401);
      expect(responseData.error).toBe('Unauthorized: Invalid User-Agent header');
      expect(responseData.expected).toBe(validUserAgent);
      expect(responseData.received).toBe('curl/8.7.1');
    });
    
    it('should reject requests with missing User-Agent', async () => {
      // Arrange
      const validBody = JSON.stringify({
        query: 'test query',
        domainRestriction: '*'
      });
      
      const request = createMockRequest(testUrl, {
        'content-type': 'application/json'
      }, validBody);
      
      const requestEvent = createMockRequestEvent(request);
      
      // Act
      const response = await POST(requestEvent);
      const responseData = await response.json();
      
      // Assert
      expect(response.status).toBe(401);
      expect(responseData.error).toBe('Unauthorized: Invalid User-Agent header');
      expect(responseData.expected).toBe(validUserAgent);
      expect(responseData.received).toBe('');
    });
    
    it('should reject requests with empty User-Agent', async () => {
      // Arrange
      const validBody = JSON.stringify({
        query: 'test query',
        domainRestriction: '*'
      });
      
      const request = createMockRequest(testUrl, {
        'content-type': 'application/json',
        'user-agent': ''
      }, validBody);
      
      const requestEvent = createMockRequestEvent(request);
      
      // Act
      const response = await POST(requestEvent);
      const responseData = await response.json();
      
      // Assert
      expect(response.status).toBe(401);
      expect(responseData.error).toBe('Unauthorized: Invalid User-Agent header');
      expect(responseData.expected).toBe(validUserAgent);
      expect(responseData.received).toBe('');
    });
  });
  
  describe('Request body validation', () => {
    it('should reject requests with missing query parameter', async () => {
      // Arrange
      const invalidBody = JSON.stringify({
        domainRestriction: '*'
      });
      
      const request = createMockRequest(testUrl, {
        'content-type': 'application/json',
        'user-agent': validUserAgent
      }, invalidBody);
      
      const requestEvent = createMockRequestEvent(request);
      
      // Act
      const response = await POST(requestEvent);
      const responseData = await response.json();
      
      // Assert
      expect(response.status).toBe(400);
      expect(responseData.error).toBe('Query parameter is required and must be a string');
    });
    
    it('should reject requests with empty query parameter', async () => {
      // Arrange
      const invalidBody = JSON.stringify({
        query: '',
        domainRestriction: '*'
      });
      
      const request = createMockRequest(testUrl, {
        'content-type': 'application/json',
        'user-agent': validUserAgent
      }, invalidBody);
      
      const requestEvent = createMockRequestEvent(request);
      
      // Act
      const response = await POST(requestEvent);
      const responseData = await response.json();
      
      // Assert
      expect(response.status).toBe(400);
      expect(responseData.error).toBe('Query parameter is required and must be a string');
    });
    
    it('should reject requests with non-string query parameter', async () => {
      // Arrange
      const invalidBody = JSON.stringify({
        query: 123,
        domainRestriction: '*'
      });
      
      const request = createMockRequest(testUrl, {
        'content-type': 'application/json',
        'user-agent': validUserAgent
      }, invalidBody);
      
      const requestEvent = createMockRequestEvent(request);
      
      // Act
      const response = await POST(requestEvent);
      const responseData = await response.json();
      
      // Assert
      expect(response.status).toBe(400);
      expect(responseData.error).toBe('Query parameter is required and must be a string');
    });
    
    it('should reject requests with missing domainRestriction parameter', async () => {
      // Arrange
      const invalidBody = JSON.stringify({
        query: 'test query'
      });
      
      const request = createMockRequest(testUrl, {
        'content-type': 'application/json',
        'user-agent': validUserAgent
      }, invalidBody);
      
      const requestEvent = createMockRequestEvent(request);
      
      // Act
      const response = await POST(requestEvent);
      const responseData = await response.json();
      
      // Assert
      expect(response.status).toBe(400);
      expect(responseData.error).toBe('Domain restriction parameter is required and must be a string');
    });
    
    it('should reject requests with empty domainRestriction parameter', async () => {
      // Arrange
      const invalidBody = JSON.stringify({
        query: 'test query',
        domainRestriction: ''
      });
      
      const request = createMockRequest(testUrl, {
        'content-type': 'application/json',
        'user-agent': validUserAgent
      }, invalidBody);
      
      const requestEvent = createMockRequestEvent(request);
      
      // Act
      const response = await POST(requestEvent);
      const responseData = await response.json();
      
      // Assert
      expect(response.status).toBe(400);
      expect(responseData.error).toBe('Domain restriction parameter is required and must be a string');
    });
    
    it('should reject requests with non-string domainRestriction parameter', async () => {
      // Arrange
      const invalidBody = JSON.stringify({
        query: 'test query',
        domainRestriction: 123
      });
      
      const request = createMockRequest(testUrl, {
        'content-type': 'application/json',
        'user-agent': validUserAgent
      }, invalidBody);
      
      const requestEvent = createMockRequestEvent(request);
      
      // Act
      const response = await POST(requestEvent);
      const responseData = await response.json();
      
      // Assert
      expect(response.status).toBe(400);
      expect(responseData.error).toBe('Domain restriction parameter is required and must be a string');
    });
  });
  
  describe('JSON parsing', () => {
    it('should reject requests with invalid JSON', async () => {
      // Arrange
      const invalidJson = '{invalid json}';
      
      const request = createMockRequest(testUrl, {
        'content-type': 'application/json',
        'user-agent': validUserAgent
      }, invalidJson);
      
      const requestEvent = createMockRequestEvent(request);
      
      // Act
      const response = await POST(requestEvent);
      const responseData = await response.json();
      
      // Assert
      expect(response.status).toBe(400);
      expect(responseData.error).toBe('Invalid JSON in request body');
    });
    
    it('should reject requests with malformed JSON', async () => {
      // Arrange
      const invalidJson = '{"query": "test", "domainRestriction":}';
      
      const request = createMockRequest(testUrl, {
        'content-type': 'application/json',
        'user-agent': validUserAgent
      }, invalidJson);
      
      const requestEvent = createMockRequestEvent(request);
      
      // Act
      const response = await POST(requestEvent);
      const responseData = await response.json();
      
      // Assert
      expect(response.status).toBe(400);
      expect(responseData.error).toBe('Invalid JSON in request body');
    });
  });
  
  describe('Search functionality', () => {
    it('should return correct response structure for valid requests', async () => {
      // Arrange
      const testQuery = 'MCP server testing connectivity verification';
      const testDomain = 'kit.svelte.dev';
      
      const validBody = JSON.stringify({
        query: testQuery,
        domainRestriction: testDomain
      });
      
      const request = createMockRequest(testUrl, {
        'content-type': 'application/json',
        'user-agent': validUserAgent,
        'accept': '*/*',
        'host': 'localhost:5173'
      }, validBody);
      
      const requestEvent = createMockRequestEvent(request);
      
      // Act
      const response = await POST(requestEvent);
      const responseData = await response.json();
      
      // Assert
      expect(response.status).toBe(200);
      expect(responseData).toHaveProperty('message', 'Rock API - Search completed successfully');
      expect(responseData).toHaveProperty('timestamp');
      expect(responseData).toHaveProperty('request');
      expect(responseData).toHaveProperty('result');
      
      // Check request details
      expect(responseData.request).toEqual({
        query: testQuery,
        domainRestriction: testDomain,
        pickedDomains: [testDomain]
      });
      
      // Check search result structure
      expect(responseData.result).toHaveProperty('combined_search_result');
      expect(responseData.result).toHaveProperty('raw_search_results');
      expect(responseData.result.combined_search_result).toHaveProperty('answer');
      expect(responseData.result.combined_search_result).toHaveProperty('citations');
      expect(Array.isArray(responseData.result.raw_search_results)).toBe(true);
      expect(responseData.result.raw_search_results).toHaveLength(2);
      
      // Check timestamp format (ISO string)
      expect(responseData.timestamp).toMatch(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}\.\d{3}Z$/);
    });
    
    it('should handle requests with wildcard domain restriction', async () => {
      // Arrange
      const validBody = JSON.stringify({
        query: 'test query',
        domainRestriction: '*'
      });
      
      const request = createMockRequest(testUrl, {
        'content-type': 'application/json',
        'user-agent': validUserAgent
      }, validBody);
      
      const requestEvent = createMockRequestEvent(request);
      
      // Act
      const response = await POST(requestEvent);
      const responseData = await response.json();
      
      // Assert
      expect(response.status).toBe(200);
      expect(responseData.request.domainRestriction).toBe('*');
      expect(responseData.request.pickedDomains).toEqual(['*']);
      expect(responseData.result).toHaveProperty('combined_search_result');
    });
    
    it('should handle requests with specific domain restriction', async () => {
      // Arrange
      const validBody = JSON.stringify({
        query: 'SvelteKit documentation',
        domainRestriction: 'kit.svelte.dev'
      });
      
      const request = createMockRequest(testUrl, {
        'content-type': 'application/json',
        'user-agent': validUserAgent
      }, validBody);
      
      const requestEvent = createMockRequestEvent(request);
      
      // Act
      const response = await POST(requestEvent);
      const responseData = await response.json();
      
      // Assert
      expect(response.status).toBe(200);
      expect(responseData.request.domainRestriction).toBe('kit.svelte.dev');
      expect(responseData.request.pickedDomains).toEqual(['kit.svelte.dev']);
      expect(responseData.result).toHaveProperty('combined_search_result');
    });
  });
  
  describe('Error handling', () => {
    it('should handle SearchService errors gracefully', async () => {
      // Override the mock to throw an error for this test
      const { SearchService } = await import('$lib/services/SearchService');
      vi.mocked(SearchService).mockImplementationOnce(() => {
        return {
          searchDocumentation: vi.fn().mockRejectedValue(
            new Error('Search API is unavailable')
          )
        } as any;
      });
      
      // Arrange
      const validBody = JSON.stringify({
        query: 'test query',
        domainRestriction: '*'
      });
      
      const request = createMockRequest(testUrl, {
        'content-type': 'application/json',
        'user-agent': validUserAgent
      }, validBody);
      
      const requestEvent = createMockRequestEvent(request);
      
      // Act
      const response = await POST(requestEvent);
      const responseData = await response.json();
      
      // Assert
      expect(response.status).toBe(500);
      expect(responseData.error).toContain('Search error:');
    });
  });
}); 
```

## File: `src/routes/markdown-demo/+page.svelte`
```
<script lang="ts">
  import MarkdownDisplay from '$lib/components/MarkdownDisplay.svelte';
  
  let sampleMarkdown = `# Markdown Display Component
  
This is a demo of the markdown display component.

## Features
- Syntax highlighting for code blocks
- Copy buttons for code blocks
- Copy as Markdown or Rich Text buttons

### Code Example

\`\`\`javascript
// This is a JavaScript code block
function helloWorld() {
  console.log('Hello, world!');
  return 42;
}
\`\`\`

\`\`\`python
# This is a Python code block
def hello_world():
    print("Hello, world!")
    return 42
\`\`\`

\`\`\`bash
# Bash script
echo "Hello World"
ls -la
\`\`\`

### Tables

| Header 1 | Header 2 | Header 3 |
|----------|----------|----------|
| Row 1    | Data     | Data     |
| Row 2    | Data     | Data     |

### Links

[Visit GitHub](https://github.com)

### Images

![Placeholder](https://doc-rocker.com/logo.webp)

### Blockquotes

> This is a blockquote.
> It can span multiple lines.

### Lists

1. First item
2. Second item
3. Third item

- Unordered list
- Another item
- And another one
`;
</script>

<div class="container">
  <h1>Markdown Display Demo</h1>
  <p>This is a demo of the MarkdownDisplay component for SvelteKit</p>
  
  <div class="demo-section">
    <MarkdownDisplay markdown={sampleMarkdown} />
  </div>
</div>

<style>
  .container {
    max-width: 800px;
    margin: 0 auto;
    padding: 2rem 1rem;
  }
  
  h1 {
    margin-bottom: 0.5rem;
  }
  
  p {
    margin-bottom: 2rem;
    color: #4a5568;
  }
  
  .demo-section {
    border-radius: 8px;
  }
</style> 
```

## File: `wrangler.toml`
```
name = "doc-rocker"
pages_build_output_dir = ".svelte-kit/cloudflare"
compatibility_date = "2025-01-01"
compatibility_flags = ["nodejs_compat"]

[vars]
VITE_PERPLEXITY_MODEL="sonar"
VITE_COMBINER_PROVIDER="gemini"
# VITE_COMBINER_PROVIDER_MODEL="models/gemini-2.0-flash-thinking-exp-01-21"
VITE_COMBINER_PROVIDER_MODEL="models/gemini-2.0-flash-exp"

# secret - VITE_PERPLEXITY_API_KEY="---secret---"
# secret - VITE_TAVILY_API_KEY="---secret---"
# secret - VITE_COMBINER_API_KEY="---secret---"
```
