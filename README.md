# Command-Line-Generate (CTG)

A ZSH plugin that provides text generation and transformation utilities directly in your command line.

## Installation

### Oh My Zsh

1. Clone this repository into Oh My Zsh's custom plugins directory:
   ```bash
   git clone git@github.com:MrSydar/ctg.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/ctg
   ```

2. Add the plugin to your `.zshrc`:
   ```bash
   plugins=(... ctg)
   ```

3. Reload your shell:
   ```bash
   source ~/.zshrc
   ```

### Manual Installation

1. Clone this repository:
   ```bash
   git clone git@github.com:MrSydar/ctg.git /path/to/ctg
   ```

2. Source the plugin in your `.zshrc`:
   ```bash
   source /path/to/ctg/ctg.plugin.zsh
   ```

3. Reload your shell:
   ```bash
   source ~/.zshrc
   ```

### zinit

Add to your `.zshrc`:
```bash
zinit light MrSydar/ctg
```

### antigen

Add to your `.zshrc`:
```bash
antigen bundle MrSydar/ctg
```

## Usage

After installation, the following functions are available:

### `generate`

Generates bash command completions using AI.

```bash
$ generate "list all files modified in the last 24 hours"
find . -type f -mtime -1
```

### Interactive Capture Mode (Ctrl+G)

Press `Ctrl+G` to start capture mode, type your prompt (it will be underlined), then press `Tab` to generate and insert the bash command. Press `ESC` to cancel.

**Hotkeys in Capture Mode:**
- `Tab` - Submit prompt and generate bash command
- `ESC` - Cancel capture mode
- `Backspace` - Delete characters (won't delete past capture start)

## Functions

- **generate** - Generates bash command completions using AI

## Configuration

**Note:** This is a proof-of-concept (POC). The plugin uses [Groq](https://groq.com/) as an example inference provider, but it is compatible with any OpenAI-compatible API endpoint.

### Required Configuration

Before loading the plugin in your `.zshrc`, set the following environment variables:

```bash
# Required: Your API key
export CTG_OPENAI_API_KEY="your-api-key-here"

# Optional: Custom API endpoint (defaults to Groq)
export CTG_OPENAI_API_URL="https://api.groq.com/openai"

# Optional: Model to use (defaults to llama-3.1-8b-instant)
export CTG_OPENAI_MODEL="llama-3.1-8b-instant"
```

**Example `.zshrc` configuration:**

```bash
# CTG Plugin Configuration
export CTG_OPENAI_API_KEY="gsk_xxxxxxxxxxxxxxxxxxxx"  # Your Groq API key
export CTG_OPENAI_API_URL="https://api.groq.com/openai"
export CTG_OPENAI_MODEL="llama-3.1-8b-instant"

# Load Oh My Zsh
plugins=(... ctg)
source $ZSH/oh-my-zsh.sh
```

### OpenAI-Compatible Endpoints

This plugin works with any OpenAI-compatible API endpoint. Examples:

**Groq (default):**
```bash
export CTG_OPENAI_API_KEY="gsk_xxxxxxxxxxxxxxxxxxxx"
export CTG_OPENAI_API_URL="https://api.groq.com/openai"
export CTG_OPENAI_MODEL="llama-3.1-8b-instant"
```

**OpenAI:**
```bash
export CTG_OPENAI_API_KEY="sk-xxxxxxxxxxxxxxxxxxxx"
export CTG_OPENAI_API_URL="https://api.openai.com"
export CTG_OPENAI_MODEL="gpt-4"
```

**Local (e.g., Ollama, LM Studio):**
```bash
export CTG_OPENAI_API_KEY="not-needed"  # Some local servers don't require a key
export CTG_OPENAI_API_URL="http://localhost:11434"
export CTG_OPENAI_MODEL="llama2"
```

### Getting API Keys

- **Groq (Free):** Get your free API key at [console.groq.com](https://console.groq.com/)
- **OpenAI:** Sign up at [platform.openai.com](https://platform.openai.com/)

## License

MIT
