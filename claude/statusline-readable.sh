#!/bin/bash

# Claude Code Readable Status Line
# Optimized for readability with improved spacing, colors, and information hierarchy

input=$(cat)
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
model_name=$(echo "$input" | jq -r '.model.display_name')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir')
username=$(whoami)

# Colors for better readability (brighter colors for improved visibility)
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
BLUE='\033[94m'  # Bright blue
GREEN='\033[92m'  # Bright green
YELLOW='\033[93m'  # Bright yellow
CYAN='\033[96m'  # Bright cyan
PURPLE='\033[95m'  # Bright purple
LIGHT_BLUE='\033[94m'  # Additional bright blue for directories

# Calculate directory display with improved hierarchy and readability
dir_display=""

# Replace home directory with ~ for shorter display
display_dir="$current_dir"
if [[ "$current_dir" == "$HOME"* ]]; then
    display_dir="~${current_dir#$HOME}"
fi

# Handle project-relative paths with smart truncation
if [ "$current_dir" = "$project_dir" ]; then
    # We're at the project root
    if [[ "$project_dir" == "$HOME"* ]]; then
        dir_display="~${project_dir#$HOME}"
    else
        dir_display=$(basename "$project_dir")
    fi
else
    # We're in a subdirectory of the project
    rel_path=$(realpath --relative-to="$project_dir" "$current_dir" 2>/dev/null || echo "")
    
    if [ -n "$rel_path" ] && [ "$rel_path" != "." ]; then
        # Count directory levels in relative path
        level_count=$(echo "$rel_path" | tr '/' '\n' | wc -l | tr -d ' ')
        
        if [ "$level_count" -gt 2 ]; then
            # For deep paths, show .../<parent>/<current>
            parent_dir=$(dirname "$rel_path")
            parent_name=$(basename "$parent_dir")
            current_name=$(basename "$rel_path")
            dir_display=".../$parent_name/$current_name"
        else
            # For shallow paths, show full relative path from project
            project_name=$(basename "$project_dir")
            dir_display="$project_name/$rel_path"
        fi
    else
        # Fallback: show home-relative or absolute path with smart truncation
        if [[ "$display_dir" == "~/"* ]]; then
            # Count levels from home
            home_rel_path="${display_dir#~/}"
            if [ -n "$home_rel_path" ]; then
                level_count=$(echo "$home_rel_path" | tr '/' '\n' | wc -l | tr -d ' ')
                if [ "$level_count" -gt 2 ]; then
                    parent_dir=$(dirname "$home_rel_path")
                    parent_name=$(basename "$parent_dir")
                    current_name=$(basename "$home_rel_path")
                    dir_display="~/.../$parent_name/$current_name"
                else
                    dir_display="$display_dir"
                fi
            else
                dir_display="~"
            fi
        else
            # For non-home paths, show with smart truncation
            level_count=$(echo "$current_dir" | tr '/' '\n' | wc -l | tr -d ' ')
            if [ "$level_count" -gt 3 ]; then
                parent_dir=$(dirname "$current_dir")
                parent_name=$(basename "$parent_dir")
                current_name=$(basename "$current_dir")
                dir_display=".../$parent_name/$current_name"
            else
                dir_display="$display_dir"
            fi
        fi
    fi
fi

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

# Construct readable status line with enhanced visibility and hierarchy
# Enhance directory display by highlighting the current directory name with brighter colors
if [[ "$dir_display" == *"/" ]]; then
    # Split path to highlight current directory
    path_prefix=$(dirname "$dir_display")
    current_name=$(basename "$dir_display")
    if [ "$path_prefix" = "." ]; then
        printf "%b%b%s%b %bin%b %b%b%s%b" "$BOLD" "$LIGHT_BLUE" "$username" "$RESET" "$DIM" "$RESET" "$BOLD" "$CYAN" "$current_name" "$RESET"
    else
        printf "%b%b%s%b %bin%b %b%s%b/%b%b%s%b" "$BOLD" "$LIGHT_BLUE" "$username" "$RESET" "$DIM" "$RESET" "$CYAN" "$path_prefix" "$RESET" "$BOLD" "$CYAN" "$current_name" "$RESET"
    fi
else
    printf "%b%b%s%b %bin%b %b%b%s%b" "$BOLD" "$LIGHT_BLUE" "$username" "$RESET" "$DIM" "$RESET" "$BOLD" "$CYAN" "$dir_display" "$RESET"
fi

if [ -n "$git_info" ]; then
    printf " %bon%b %b%b%s%b" "$DIM" "$RESET" "$BOLD" "$GREEN" "$git_info" "$RESET"
fi

printf " %busing%b %b%b%s%b" "$DIM" "$RESET" "$BOLD" "$PURPLE" "$model_short" "$RESET"