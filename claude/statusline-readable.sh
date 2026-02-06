#!/bin/bash

# Claude Code Readable Status Line
# Optimized for readability with improved spacing, colors, and information hierarchy

input=$(cat)
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
model_name=$(echo "$input" | jq -r '.model.display_name')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir')
# username removed

# Token usage information
# Try to use pre-calculated percentage from Claude Code
usage_percent=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Fallback to manual calculation if used_percentage is not available
if [ -z "$usage_percent" ] || [ "$usage_percent" = "null" ]; then
    total_input=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')
    total_output=$(echo "$input" | jq -r '.context_window.total_output_tokens // 0')
    context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 0')

    if [ "$context_size" -gt 0 ] 2>/dev/null; then
        total_tokens=$((total_input + total_output))
        usage_percent=$((total_tokens * 100 / context_size))
    else
        usage_percent=0
    fi
fi

# Colors for better readability (brighter colors for improved visibility)
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
BLUE='\033[94m'  # Bright blue
GREEN='\033[92m'  # Bright green
YELLOW='\033[93m'  # Bright yellow
CYAN='\033[96m'  # Bright cyan
PURPLE='\033[95m'  # Bright purple

# Generate progress bar
# Args: $1=percentage (0-100), $2=width (default 10)
generate_progress_bar() {
    local percent=$1
    local width=${2:-10}
    local filled=$((percent * width / 100))
    local empty=$((width - filled))

    local bar=""
    for ((i=0; i<filled; i++)); do bar+="█"; done
    for ((i=0; i<empty; i++)); do bar+="░"; done

    echo "$bar"
}

# Calculate directory display - show only current directory name
dir_display=$(basename "$current_dir")

# Git information with workflow status, worktree info, and cleaner formatting
git_info=""
if [ -d "$current_dir/.git" ] || git -C "$current_dir" rev-parse --git-dir >/dev/null 2>&1; then
    git_dir=$(git -C "$current_dir" --no-optional-locks rev-parse --git-dir 2>/dev/null)
    
    branch=$(git -C "$current_dir" --no-optional-locks branch --show-current 2>/dev/null)
    if [ -z "$branch" ]; then
        branch=$(git -C "$current_dir" --no-optional-locks describe --always --short HEAD 2>/dev/null || echo 'HEAD')
    fi
    
    # Check for git worktree information
    worktree_info=""
    if git -C "$current_dir" --no-optional-locks worktree list >/dev/null 2>&1; then
        # Get the current worktree path
        worktree_path=$(git -C "$current_dir" --no-optional-locks rev-parse --show-toplevel 2>/dev/null)
        if [ -n "$worktree_path" ]; then
            # Get all worktrees and check if we're in a linked worktree
            worktree_list=$(git -C "$current_dir" --no-optional-locks worktree list --porcelain 2>/dev/null)
            if echo "$worktree_list" | grep -q "^worktree $worktree_path$"; then
                # We're in a worktree, check if it's the main one
                main_worktree=$(echo "$worktree_list" | head -1 | cut -d' ' -f2-)
                if [ "$worktree_path" != "$main_worktree" ]; then
                    # This is a linked worktree, show the worktree name
                    worktree_name=$(basename "$worktree_path")
                    # Build worktree info with proper escape handling
                    worktree_info=$(printf " %b(%bwt:%s%b%b)%b" "$DIM" "$CYAN" "$worktree_name" "$RESET" "$DIM" "$RESET")
                fi
            fi
        fi
    fi
    
    # Check for git workflows with progress and conflict information
    workflow_info=""
    RED='\033[31m'
    ORANGE='\033[33m'
    
    # Rebase workflow
    if [ -d "$git_dir/rebase-merge" ] || [ -d "$git_dir/rebase-apply" ]; then
        if [ -f "$git_dir/rebase-merge/interactive" ]; then
            workflow_type="rebase -i"
            rebase_dir="$git_dir/rebase-merge"
        elif [ -d "$git_dir/rebase-merge" ]; then
            workflow_type="rebase"
            rebase_dir="$git_dir/rebase-merge"
        else
            workflow_type="rebase"
            rebase_dir="$git_dir/rebase-apply"
        fi
        
        # Get rebase progress
        if [ -f "$rebase_dir/msgnum" ] && [ -f "$rebase_dir/end" ]; then
            current=$(cat "$rebase_dir/msgnum" 2>/dev/null || echo "0")
            total=$(cat "$rebase_dir/end" 2>/dev/null || echo "0")
            progress="$current/$total"
        else
            progress="?"
        fi
        
        # Check for conflicts
        conflicts=""
        if git -C "$current_dir" --no-optional-locks ls-files --unmerged >/dev/null 2>&1; then
            conflict_count=$(git -C "$current_dir" --no-optional-locks ls-files --unmerged | wc -l | tr -d ' ')
            conflicts=" ${RED}conflicts:$conflict_count${RESET}"
        fi
        
        workflow_info=" ${ORANGE}$workflow_type $progress${RESET}$conflicts"
    
    # Merge workflow
    elif [ -f "$git_dir/MERGE_HEAD" ]; then
        workflow_type="merge"
        conflicts=""
        if git -C "$current_dir" --no-optional-locks ls-files --unmerged >/dev/null 2>&1; then
            conflict_count=$(git -C "$current_dir" --no-optional-locks ls-files --unmerged | wc -l | tr -d ' ')
            conflicts=" ${RED}conflicts:$conflict_count${RESET}"
        fi
        workflow_info=" ${ORANGE}$workflow_type${RESET}$conflicts"
    
    # Cherry-pick workflow
    elif [ -f "$git_dir/CHERRY_PICK_HEAD" ]; then
        workflow_type="cherry-pick"
        conflicts=""
        if git -C "$current_dir" --no-optional-locks ls-files --unmerged >/dev/null 2>&1; then
            conflict_count=$(git -C "$current_dir" --no-optional-locks ls-files --unmerged | wc -l | tr -d ' ')
            conflicts=" ${RED}conflicts:$conflict_count${RESET}"
        fi
        workflow_info=" ${ORANGE}$workflow_type${RESET}$conflicts"
    
    # Revert workflow
    elif [ -f "$git_dir/REVERT_HEAD" ]; then
        workflow_type="revert"
        conflicts=""
        if git -C "$current_dir" --no-optional-locks ls-files --unmerged >/dev/null 2>&1; then
            conflict_count=$(git -C "$current_dir" --no-optional-locks ls-files --unmerged | wc -l | tr -d ' ')
            conflicts=" ${RED}conflicts:$conflict_count${RESET}"
        fi
        workflow_info=" ${ORANGE}$workflow_type${RESET}$conflicts"
    
    # Bisect workflow
    elif [ -f "$git_dir/BISECT_LOG" ]; then
        workflow_type="bisect"
        # Try to get bisect status
        bisect_status=$(git -C "$current_dir" --no-optional-locks bisect log 2>/dev/null | tail -1 | grep -o 'bad\|good\|skip' || echo "running")
        workflow_info=" ${ORANGE}$workflow_type $bisect_status${RESET}"
    fi
    
    # Git status with clear indicators
    git_status=""
    if git -C "$current_dir" --no-optional-locks diff --quiet --exit-code 2>/dev/null; then
        if ! git -C "$current_dir" --no-optional-locks diff --cached --quiet --exit-code 2>/dev/null; then
            git_status=" staged"
        fi
    else
        git_status=" modified"
        if ! git -C "$current_dir" --no-optional-locks diff --cached --quiet --exit-code 2>/dev/null; then
            git_status=" modified+staged"
        fi
    fi
    
    if [ -n "$(git -C "$current_dir" --no-optional-locks ls-files --others --exclude-standard 2>/dev/null)" ]; then
        git_status="${git_status} untracked"
    fi
    
    git_info="$branch$worktree_info$workflow_info$git_status"
fi

# Model name simplification for readability
case "$model_name" in
    *"Claude 3.5 Sonnet"*) model_short="Sonnet 3.5" ;;
    *"Claude 3.5 Haiku"*) model_short="Haiku 3.5" ;;
    *"Claude 3 Opus"*) model_short="Opus 3" ;;
    *"Sonnet 4"*) model_short="Sonnet 4" ;;
    *) model_short="$model_name" ;;
esac

# Context usage display with progress bar
context_info=""
progress_bar=""
# Display context usage even if it's 0% (change -gt to -ge)
if [ "$usage_percent" -ge 0 ] 2>/dev/null; then
    # Cap at 100% for safety
    if [ "$usage_percent" -gt 100 ]; then
        usage_percent=100
    fi
    progress_bar=$(generate_progress_bar "$usage_percent")
    context_info="[${progress_bar}] ${usage_percent}%"
fi

# Construct readable status line with enhanced visibility and hierarchy
printf "%b%b%s%b" "$BOLD" "$CYAN" "$dir_display" "$RESET"

if [ -n "$git_info" ]; then
    printf " %bon%b %b%b%s%b" "$DIM" "$RESET" "$BOLD" "$GREEN" "$git_info" "$RESET"
fi

printf " %busing%b %b%b%s%b" "$DIM" "$RESET" "$BOLD" "$PURPLE" "$model_short" "$RESET"

# Add context usage percentage at the end
if [ -n "$context_info" ]; then
    # Color based on usage level
    if [ "$usage_percent" -ge 90 ]; then
        BAR_COLOR='\033[91m'  # Red for high usage
    elif [ "$usage_percent" -ge 70 ]; then
        BAR_COLOR='\033[93m'  # Yellow for medium usage
    else
        BAR_COLOR='\033[92m'  # Green for low usage
    fi
    printf " %b[%d%%]%b" "$BAR_COLOR" "$usage_percent" "$RESET"
fi
