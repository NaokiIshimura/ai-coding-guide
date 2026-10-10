# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is an AI coding guide repository that provides reusable configurations, agents, and skills for Claude Code and other AI assistants. The repository is structured as a library of best practices and workflows that can be installed into `~/.claude/` or used directly in projects.

## Installation Commands

```bash
# Install everything to ~/.claude/
make install

# Install specific components
make install-config      # Install CLAUDE.md
make install-settings    # Install settings.json
make install-agents      # Install agent definitions
make install-skills      # Install skill definitions

# Import settings from ~/.claude/ back to this repo
make import-settings

# Clean up installations
make clean
```

## Architecture

### Two-Layer System: Agents and Skills

Slash commands were merged into skills in Claude Code, so this repository no longer has a `claude/commands/` directory.

1. **Agents** (`claude/agents/`)
   - Invoked via: `Agent` tool with `subagent_type` parameter
   - Execution: Run with an independent context and return results when complete
   - Use case: Collecting information or autonomous work that should not bloat the main context
   - Examples: `jira-collector`, `pr-collector`, `code-implementer`, `debugger`

2. **Skills** (`claude/skills/<name>/SKILL.md`)
   - Execution: Run in the main session and share the conversation context
   - **Shared skills** (`git`, `pull-request`, `plan-writer`, `spec-writer`, `tasks-execute`, `markdown`, `codex`)
     - Hold the procedure and templates (`templates/`, referenced via `${CLAUDE_SKILL_DIR}`)
     - Invoked via the `Skill` tool by the model or by other skills
   - **Wrapper skills** (dot-separated names such as `/git.commit.push.pr`, `/plan.create`)
     - Former slash commands; invoked by the user as `/<name>`
     - Set `disable-model-invocation: true`, receive arguments via `$ARGUMENTS`, and call a shared skill via the `Skill` tool (list `Skill` in `allowed-tools`)
     - Keep them thin: put procedures in the shared skill, not in the wrapper

### File Synchronization Rule

When updating files in `claude/agents/` or `claude/skills/`, you must also update the corresponding index files:

- Update `claude/agents/*` → Update `claude/AGENTS.md`
- Update `claude/skills/*` → Update `claude/SKILLS.md`

## Key Workflows

### Development from JIRA Ticket

```bash
/jira.issue.develop      # Fetch ticket, create plan (requirements/design/tasks.md), implement
/git.commit.push.pr      # Commit, push, create PR
/jira.issue.feedback     # Post feedback to JIRA ticket
```

### Spec-Based Development

```bash
/spec.create            # Create requirements.md, design.md, tasks.md
/tasks.execute          # Implement tasks from tasks.md
/git.commit.push.pr     # Commit, push, create PR
/pr.comment.resolve     # Address review comments
```

### Plan-Based Development

```bash
/plan.create            # Create plan.md (execution plan)
/plan.implement         # Implement according to plan
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
  - With ticket number: `.claude/plans/<ticket-number>/`
  - Without ticket number: `.claude/plans/tmp/`
- **File endings**: All files must end with a blank line

## Important Guidelines

### Git Operations

- **Never commit** `.claude`, `.vscode`, or `.serena` directories
- Branch names should be ticket numbers only (e.g., `ABC-123`, not `feature/ABC-123`)
- Commit messages must be in Japanese
- Never use `--no-verify` to skip pre-commit hooks; fix issues instead

### Pull Request Creation

- Use GitHub MCP or the `gh` CLI (see `guides/git.md`)
- PR title format: `[<ticket-number>] <ticket-title>`
- PR descriptions must follow template at `.github/pull_request_template.md`
- Set `NaokiIshimura` as assignee

### Sub-Agent Usage

- Sub-agent results should be written to temporary markdown files (the main session writes them when the sub-agent has no `Write` tool, e.g. the built-in `Explore` agent)
- For large file operations or broad searches, use the built-in `Explore` agent to avoid context bloat
- Agents run with independent context and return results when complete

## Agent Color Coding

Agents are color-coded by role:

- **Blue**: Collectors (confluence-collector, jira-collector, pr-collector, slack-collector, web-collector)
- **Yellow**: Analyzers (debugger, data-scientist)
- **Red**: Implementers (code-implementer)
- **Cyan**: Claude Comment managers (claude-comment-finder, claude-comment-executor, claude-comment-cleaner)

## Common Tasks Reference

See detailed workflows in:
- `claude/AGENTS.md` - Agent descriptions and usage
- `claude/SKILLS.md` - Skill descriptions, workflow examples and composition patterns
- `README.md` - Installation and setup instructions
