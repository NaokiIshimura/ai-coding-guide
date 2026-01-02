# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an AI coding guide repository that provides reusable configurations, agents, commands, and skills for Claude Code and other AI assistants. The repository is structured as a library of best practices and workflows that can be installed into `~/.claude/` or used directly in projects.

## Installation Commands

```bash
# Install everything to ~/.claude/
make install

# Install specific components
make install-config      # Install CLAUDE.md
make install-settings    # Install settings.json
make install-agents      # Install agent definitions
make install-commands    # Install slash commands
make install-skills      # Install skill definitions

# Import settings from ~/.claude/ back to this repo
make import-settings

# Clean up installations
make clean
```

## Architecture

### Three-Layer System: Agents, Commands, and Skills

This repository implements a three-layer architecture for Claude Code:

1. **Agents** (`claude/agents/`)
   - Invoked via: `Task` tool with `subagent_type` parameter
   - Execution: Run in separate subprocess with independent context
   - Use case: Complex, multi-step tasks requiring autonomous operation
   - Examples: `code-collector`, `requirements-writer`, `debugger`

2. **Commands** (`claude/commands/`)
   - Invoked via: `/command-name` slash commands
   - Execution: Run in main process, shares conversation context
   - Use case: Project-specific workflows and common operations
   - Examples: `/git.commit.push.pr`, `/jira.issue.develop`, `/md.output`

3. **Skills** (`claude/skills/`)
   - Invoked via: `Skill` tool
   - Execution: Run in main process, shares conversation context
   - Use case: Reusable capabilities that can be composed
   - Examples: `git`, `pull-request`, `markdown`, `qiita`

### File Synchronization Rule

When updating files in `claude/agents/`, `claude/commands/`, or `claude/skills/`, you must also update the corresponding index files:

- Update `claude/agents/*` → Update `claude/AGENTS.md`
- Update `claude/commands/*` → Update `claude/COMMANDS.md`
- Update `claude/skills/*` → Update `claude/SKILLS.md`

This rule is documented in `CMAUDE.md` at the project root.

## Key Workflows

### Development from JIRA Ticket

```bash
/jira.issue.develop      # Fetch ticket, create plan (requirements/design/tasks.md), implement
/git.commit.push.pr      # Commit, push, create PR
/jira.issue.feedback     # Post feedback to JIRA ticket
```

### Plan-Based Development

```bash
/plan.create             # Create requirements.md, design.md, tasks.md
/tasks.execute          # Implement tasks from tasks.md
/git.commit.push.pr     # Commit, push, create PR
/pr.comment.resolve     # Address review comments
```

### Working with Markdown Documentation

```bash
/md.output              # Export current work status to markdown
/md.input               # Import and review past work from markdown files
/md.output.spec         # Generate implementation plan (requirements/design/tasks.md)
/md.develop            # Develop from markdown file contents
```

## File Output Conventions

All generated markdown files follow these conventions:

- **Timestamp format**: `YYYY_MMDD_HHMM_SS_<topic>.md` (Japan time)
- **Output location**:
  - With ticket number: `.claude/tasks/<ticket-number>/`
  - Without ticket number: `.claude/tasks/tmp/`
- **File endings**: All files must end with a blank line

## Important Guidelines

### Git Operations

- **Never commit** `.claude`, `.vscode`, or `.serena` directories
- Branch names should be ticket numbers only (e.g., `ABC-123`, not `feature/ABC-123`)
- Commit messages must be in Japanese
- Never use `--no-verify` to skip pre-commit hooks; fix issues instead

### Pull Request Creation

- Use GitHub MCP instead of `gh` CLI commands
- PR title format: `[<ticket-number>] <ticket-title>`
- PR descriptions must follow template at `.github/pull_request_template.md`
- Set `NaokiIshimura` as assignee
- Enable Copilot review

### Sub-Agent Usage

- Sub-agent results should be written to temporary markdown files
- For large file operations, use `file-collector` agent to avoid context bloat
- Agents run with independent context and return results when complete

## Agent Color Coding

Agents are color-coded by role:

- **Blue**: Collectors (file-collector, code-collector, web-collector, etc.)
- **Magenta**: Writers (requirements-writer, design-writer, tasks-writer)
- **Yellow**: Reviewers/Analyzers (code-reviewer, debugger, data-scientist)
- **Red**: Implementers (code-implementer)
- **Cyan**: Claude Comment managers (claude-comment-finder, executor, cleaner)
- **Green**: Operators/Orchestrators (git-operator, plan-create, tasks-executor)

## Common Tasks Reference

See detailed workflows in:
- `claude/AGENTS.md` - Agent descriptions and usage
- `claude/COMMANDS.md` - Command reference and workflow examples
- `claude/SKILLS.md` - Skill descriptions and composition patterns
- `README.md` - Installation and setup instructions
