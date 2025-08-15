# ai-coding-guide Makefile
# Claude agents and commands deployment

.PHONY: help install install-config install-settings install-agents install-commands import-settings clean clean-config clean-settings clean-agents clean-commands

# Default target
help:
	@echo "Available targets:"
	@echo "  make install         - Install CLAUDE.md, settings, agents and commands to ~/.claude/"
	@echo "  make install-config  - Install CLAUDE.md to ~/.claude/"
	@echo "  make install-settings - Install settings.json and statusline-readable.sh to ~/.claude/"
	@echo "  make install-agents  - Install agents to ~/.claude/agents/"
	@echo "  make install-commands - Install commands to ~/.claude/commands/"
	@echo "  make import-settings  - Copy settings from ~/.claude/ to claude/ directory"
	@echo "  make clean           - Remove installed files"
	@echo "  make clean-config    - Remove installed CLAUDE.md"
	@echo "  make clean-settings  - Remove installed settings"
	@echo "  make clean-agents    - Remove installed agents"
	@echo "  make clean-commands  - Remove installed commands"

# Install all
install: install-config install-settings install-agents install-commands
	@echo "✓ Installation complete"

# Install CLAUDE.md
install-config:
	@echo "Installing CLAUDE.md to ~/.claude/"
	@mkdir -p ~/.claude
	@cp -v claude/CLAUDE.md ~/.claude/CLAUDE.md
	@echo "✓ CLAUDE.md installed"

# Install settings
install-settings:
	@echo "Installing settings to ~/.claude/"
	@mkdir -p ~/.claude
	@cp -v claude/settings.json ~/.claude/settings.json
	@cp -v claude/statusline-readable.sh ~/.claude/statusline-readable.sh
	@echo "✓ Settings installed"

# Import settings
import-settings:
	@echo "Importing settings from ~/.claude/ to claude/"
	@mkdir -p claude
	@cp -v ~/.claude/settings.json claude/settings.json
	@cp -v ~/.claude/statusline-readable.sh claude/statusline-readable.sh
	@echo "✓ Settings imported"

# Install agents
install-agents:
	@echo "Installing agents to ~/.claude/agents/"
	@mkdir -p ~/.claude/agents
	@cp -v claude/agents/*.md ~/.claude/agents/
	@echo "✓ Agents installed"

# Install commands
install-commands:
	@echo "Installing commands to ~/.claude/commands/"
	@mkdir -p ~/.claude/commands
	@cp -v claude/commands/*.md ~/.claude/commands/
	@echo "✓ Commands installed"

# Clean all
clean: clean-config clean-settings clean-agents clean-commands
	@echo "✓ Cleanup complete"

# Clean CLAUDE.md
clean-config:
	@echo "Removing CLAUDE.md from ~/.claude/"
	@rm -fv ~/.claude/CLAUDE.md
	@echo "✓ CLAUDE.md removed"

# Clean settings
clean-settings:
	@echo "Removing settings from ~/.claude/"
	@rm -fv ~/.claude/settings.json
	@rm -fv ~/.claude/statusline-readable.sh
	@echo "✓ Settings removed"

# Clean agents
clean-agents:
	@echo "Removing agents from ~/.claude/agents/"
	@for file in claude/agents/*.md; do \
		basename=$$(basename "$$file"); \
		rm -fv ~/.claude/agents/"$$basename"; \
	done
	@echo "✓ Agents removed"

# Clean commands
clean-commands:
	@echo "Removing commands from ~/.claude/commands/"
	@for file in claude/commands/*.md; do \
		basename=$$(basename "$$file"); \
		rm -fv ~/.claude/commands/"$$basename"; \
	done
	@echo "✓ Commands removed"