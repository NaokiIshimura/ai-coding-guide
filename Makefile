# ai-coding-guide Makefile
# Claude agents and commands deployment

.PHONY: help install install-config install-agents install-commands clean clean-config clean-agents clean-commands

# Default target
help:
	@echo "Available targets:"
	@echo "  make install         - Install CLAUDE.md, agents and commands to ~/.claude/"
	@echo "  make install-config  - Install CLAUDE.md to ~/.claude/"
	@echo "  make install-agents  - Install agents to ~/.claude/agents/"
	@echo "  make install-commands - Install commands to ~/.claude/commands/"
	@echo "  make clean           - Remove installed files"
	@echo "  make clean-config    - Remove installed CLAUDE.md"
	@echo "  make clean-agents    - Remove installed agents"
	@echo "  make clean-commands  - Remove installed commands"

# Install all
install: install-config install-agents install-commands
	@echo "✓ Installation complete"

# Install CLAUDE.md
install-config:
	@echo "Installing CLAUDE.md to ~/.claude/"
	@mkdir -p ~/.claude
	@cp -v claude/CLAUDE.md ~/.claude/CLAUDE.md
	@echo "✓ CLAUDE.md installed"

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
clean: clean-config clean-agents clean-commands
	@echo "✓ Cleanup complete"

# Clean CLAUDE.md
clean-config:
	@echo "Removing CLAUDE.md from ~/.claude/"
	@rm -fv ~/.claude/CLAUDE.md
	@echo "✓ CLAUDE.md removed"

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