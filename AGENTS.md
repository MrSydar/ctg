# Agent Guidelines for CTG ZSH Plugin

This document provides coding conventions and development guidelines for AI coding agents working on this ZSH plugin project.

## Project Overview

**Type:** ZSH Plugin  
**Language:** Shell Script (Zsh)  
**Purpose:** Command-Line-Generate (CTG) - Text generation and transformation utilities with interactive capture mode  
**Repository:** git@github.com:MrSydar/ctg.git

## Build, Test & Lint Commands

### Testing
Currently, this project has no automated testing framework. When adding tests:

```bash
# Recommended: Install and use shunit2 for ZSH testing
git clone https://github.com/kward/shunit2.git tests/shunit2

# Run tests (once implemented)
zsh tests/run_tests.sh
```

### Manual Testing
```bash
# Test the generate function
# Note: Requires CTG_OPENAI_API_KEY to be set
export CTG_OPENAI_API_KEY="your-api-key"
zsh -c "source ./ctg.plugin.zsh && generate 'list all files'"
# Expected output: A bash command like "ls -la" or "find . -type f"

# Test interactive capture mode (Ctrl+G):
# 1. Set your API key: export CTG_OPENAI_API_KEY="your-api-key"
# 2. Source the plugin: source ./ctg.plugin.zsh
# 3. Press Ctrl+G to start capture mode
# 4. Type a prompt (should appear underlined), e.g., "find large files"
# 5. Press Tab to generate bash command
# 6. Press ESC to cancel if needed

# Test configuration variables
export CTG_OPENAI_API_URL="https://api.groq.com/openai"
export CTG_OPENAI_MODEL="llama-3.1-8b-instant"
zsh -c "source ./ctg.plugin.zsh && echo 'Config loaded successfully'"
```

### Linting
```bash
# Recommended: Install shellcheck for shell script linting
shellcheck ctg.plugin.zsh

# Check ZSH syntax
zsh -n ctg.plugin.zsh
```

### No Build Process
This is a pure shell script project - no compilation or build step required.

## Code Style Guidelines

### File Structure
- **Plugin files:** Must end with `.plugin.zsh` suffix
- **Main plugin:** `ctg.plugin.zsh` (entry point)
- **File header:** Include comment with filename and brief description
- **ZLE widgets:** Prefix internal ZLE functions with `_ctg_` to avoid conflicts

### Shell Script Conventions

#### Functions
```zsh
# Good: Lowercase function names, descriptive comments
# function_name - Brief description of what it does
function_name() {
  # Function body with 2-space indentation
  echo "example"
}

# Also acceptable: function keyword (less common in ZSH)
function function_name {
  echo "example"
}
```

#### Indentation & Formatting
- Use **2 spaces** for indentation (no tabs)
- One blank line between functions
- Comments above functions describing their purpose
- Keep lines under 80 characters when practical

#### Naming Conventions
- **Functions:** Lowercase with underscores (snake_case): `my_function`
- **Variables:** Lowercase with underscores: `my_variable`
- **Constants:** Uppercase with underscores: `MY_CONSTANT`
- **Private functions:** Prefix with underscore: `_private_helper`

#### Variables & Quoting
```zsh
# Always quote variables: echo "$my_var"
# Use 'local' for function-scoped variables (only works inside functions)
# For top-level plugin variables, use 'typeset' or no keyword
typeset plugin_config="value"
local files=("file1.txt" "file2.txt")  # Arrays for lists
```

#### Comments
```zsh
# Single-line comments start with # followed by space
# Document all public functions with purpose and usage

# Multi-line descriptions:
# Line 1 of description
# Line 2 of description
my_function() {
  # Inline comments explain complex logic
  echo "result"
}
```

#### Error Handling
```zsh
# Check command success with conditionals
if ! some_command; then
  echo "Error: command failed" >&2
  return 1
fi

# Use return codes (0 = success, non-zero = failure)
validate_input() {
  [[ -n "$1" ]] || return 1
  return 0
}
```

#### Command Substitution
```zsh
# Prefer $() over backticks
result=$(command arg)

# NOT: result=`command arg`
```

### Import/Sourcing Conventions
```zsh
# Source other ZSH files at the top of the file
# Use absolute paths relative to plugin directory

# Get plugin directory (at top level - don't use 'local')
# Using %x prompt expansion works reliably in all sourcing contexts
typeset plugin_dir="${${(%):-%x}:A:h}"

# Source dependencies
source "${plugin_dir}/lib/helper.zsh"
```

### Documentation
```zsh
# function_name - One-line description
#
# Usage: function_name arg1 [arg2]
#
# Arguments:
#   arg1 - Description of first argument
#   arg2 - (Optional) Description of second argument
#
# Returns:
#   0 on success, 1 on failure
function_name() {
  # Implementation
}
```

## Git Workflow

### Commits
- Use conventional commit format: `type: description`
- Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
- Keep first line under 72 characters
- Add detailed description if needed after blank line

```
feat: add new greeting function

Implements customizable greeting function that accepts
user name as parameter.
```

### Branch Naming
- Feature: `feature/description`
- Bug fix: `fix/description`
- Documentation: `docs/description`

## Plugin-Specific Guidelines

- Export only necessary functions (avoid polluting user's environment)
- Prefix internal helper functions with underscore
- Use unique function names to avoid conflicts with other plugins
- Consider namespacing for complex plugins: `pluginname_function`
- Document all user-facing functions in README.md

## ZLE (Zsh Line Editor) Widgets

This plugin uses ZLE widgets for interactive capture mode. Follow these conventions:

```zsh
# Prefix all internal ZLE widget functions with _ctg_
_ctg_my_widget() {
  # Widget implementation
}

# Register widgets with zle -N
zle -N _ctg_my_widget

# Override built-in widgets by creating wrapper
_ctg_self_insert() {
  zle .self-insert  # Call original with dot prefix
  # Custom behavior
}
zle -N self-insert _ctg_self_insert
```

**Key ZLE Variables:**
- `$BUFFER` - Current command line content
- `$CURSOR` - Cursor position (0-indexed)
- `region_highlight` - Array for highlighting text (format: "start end style")

**Widget Best Practices:**
- Always use `zle .widget-name` to call original widget behavior
- Use `typeset -g` for global state variables shared across widgets
- Clear `region_highlight=()` when canceling operations
- Test interactive behavior manually (cannot be easily automated)
