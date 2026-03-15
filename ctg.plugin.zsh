# shellcheck shell=bash
# ctg.plugin.zsh
# Command-Line-Generate (CTG) - Text generation and transformation utilities for ZSH

# CTG configuration variables
typeset -g _CTG_OPENAI_API_KEY=""
typeset -g _CTG_OPENAI_API_URL="https://api.groq.com/openai"
typeset -g _CTG_OPENAI_MODEL="llama-3.1-8b-instant"

# Load configuration from environment variables if set
[[ -n "$CTG_OPENAI_API_KEY" ]] && _CTG_OPENAI_API_KEY="$CTG_OPENAI_API_KEY"
[[ -n "$CTG_OPENAI_API_URL" ]] && _CTG_OPENAI_API_URL="$CTG_OPENAI_API_URL"
[[ -n "$CTG_OPENAI_MODEL" ]] && _CTG_OPENAI_MODEL="$CTG_OPENAI_MODEL"

# generate - Generates bash command completions using AI
#
# Usage: generate "prompt"
#
# Arguments:
#   $1 - Prompt describing the bash command to generate
#
# Returns:
#   Generated bash command from AI model
generate() {
  curl --location "$_CTG_OPENAI_API_URL/v1/chat/completions" \
    --header 'Content-Type: application/json' \
    --header "Authorization: Bearer $_CTG_OPENAI_API_KEY" \
    --data "{
      \"model\": \"$_CTG_OPENAI_MODEL\",
      \"stream\": false,
      \"messages\": [{\"content\": \"You are a bash command line autocompletion program. Your task is to generate only raw bash command in 1 line. Do not include any explanations. Do not use markdown format.\", \"role\":\"system\"},{\"content\": \"$1\", \"role\": \"user\"}],
      \"temperature\": 0.2,
      \"max_tokens\": 50,
      \"seed\": 0,
      \"top_p\": 1
    }" -s | jq '.choices[].message.content' -r
}

# State variables for capture mode
typeset -g _ctg_pre_capture_buffer=""
typeset -g _ctg_pre_capture_cursor=0

# _ctg_start_capture - Enter capture mode and save pre-capture state
_ctg_start_capture() {
  _ctg_pre_capture_buffer="$BUFFER"
  _ctg_pre_capture_cursor=$CURSOR

  bindkey -A ctg-capture main
}

# _ctg_submit_capture - Generate result and exit capture mode
_ctg_submit_capture() {
  # Extract captured text from pre-capture position to current cursor
  local captured="${BUFFER:$_ctg_pre_capture_cursor:$(( CURSOR - _ctg_pre_capture_cursor ))}"
  # Generate uppercase result
  local result
  result=$(generate "$captured")

  # Replace captured portion with result, preserving text before and after
  BUFFER="${BUFFER[1,$_ctg_pre_capture_cursor]}${result}${BUFFER[$((CURSOR+1)),-1]}"
  CURSOR=$(( _ctg_pre_capture_cursor + ${#result} ))
  region_highlight=()

  bindkey -A emacs main 
}

# _ctg_cancel_capture - Cancel capture mode and restore original buffer state
_ctg_cancel_capture() {
  # Restore original buffer state
  BUFFER="$_ctg_pre_capture_buffer"
  CURSOR=$_ctg_pre_capture_cursor
  region_highlight=()

  bindkey -A emacs main 
}

# _ctg_self_insert - Wrapper for self-insert with underline during capture
_ctg_self_insert() {
  zle .self-insert

  # shellcheck disable=SC2034  # region_highlight is a ZSH built-in variable
  region_highlight=("${_ctg_pre_capture_cursor} ${CURSOR} underline")
}

# _ctg_backward_delete_char - Handle backspace during capture mode
_ctg_backward_delete_char() {
  # Prevent deleting past capture start point
  if (( CURSOR > _ctg_pre_capture_cursor )); then
    zle .backward-delete-char
    # shellcheck disable=SC2034  # region_highlight is a ZSH built-in variable
    region_highlight=("${_ctg_pre_capture_cursor} ${CURSOR} underline")
  fi
}

# Create a new keymap for capture mode
bindkey -N ctg-capture

# Register widgets
zle -N _ctg_start_capture
zle -N _ctg_submit_capture
zle -N _ctg_cancel_capture
zle -N _ctg_self_insert
zle -N _ctg_backward_delete_char # temporarily disabled

# Key bindings
bindkey '^G' _ctg_start_capture # Ctrl+G to start capture mode
bindkey -M ctg-capture -R ' '-'~' _ctg_self_insert          # Self-insert with underline in capture mode
bindkey -M ctg-capture '^?' _ctg_backward_delete_char # Backspace handling in capture mode
bindkey -M ctg-capture '^[' _ctg_cancel_capture  # ESC to cancel capture mode
bindkey -M ctg-capture '^I' _ctg_submit_capture    # Tab key to submit, generate and exit capture mode
