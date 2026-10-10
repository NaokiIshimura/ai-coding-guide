# ai-coding-guide Makefile
# Claude agents and skills deployment

# Install destination (override for testing: make install CLAUDE_DIR=/tmp/claude-test)
CLAUDE_DIR ?= $(HOME)/.claude
TMUX_CONF ?= $(HOME)/.tmux.conf
TIMESTAMP := $(shell TZ=Asia/Tokyo date +%Y%m%d_%H%M%S)
BACKUP_DIR := $(CLAUDE_DIR)/backups/ai-coding-guide_$(TIMESTAMP)

# Definitions managed by this repository
AGENTS := $(basename $(notdir $(wildcard claude/agents/*.md)))
SKILLS := $(notdir $(patsubst %/,%,$(wildcard claude/skills/*/)))

# Definitions removed from this repository (deleted from $(CLAUDE_DIR) by `make migrate`)
LEGACY_COMMANDS := claude.comment codex.debug codex.implement codex.refactor codex.review \
	git.branch git.commit git.commit.push git.commit.push.pr git.pull git.push git.switch.default \
	jira.issue.develop jira.issue.develop.old jira.issue.develop.old2 jira.issue.feedback \
	md.develop md.input md.output md.output.plan md.output.spec memory.read memory.write \
	plan.create plan.implement pr.ci.wait pr.comment.check pr.comment.resolve pr.create pr.update \
	spec.create storybook.docgen.disable task.init tasks.execute
LEGACY_AGENTS := code-collector code-reviewer codex-implementer codex-reviewer file-collector \
	git-operator markdown-handler plan-writer spec-writer tasks-executor

.PHONY: help install install-config install-settings install-statusline install-agents install-skills install-tmux-conf import-settings migrate clean clean-config clean-settings clean-agents clean-skills clean-tmux-conf

# Default target
help:
	@echo "Available targets:"
	@echo "  make install          - Install CLAUDE.md, settings, agents and skills to ~/.claude/"
	@echo "  make install-config   - Install CLAUDE.md to ~/.claude/"
	@echo "  make install-settings - Merge settings.json into ~/.claude/settings.json (backup is created)"
	@echo "  make install-statusline - Install statusline-readable.sh to ~/.claude/"
	@echo "  make install-agents   - Install agents to ~/.claude/agents/"
	@echo "  make install-skills   - Install skills to ~/.claude/skills/"
	@echo "  make install-tmux-conf - Install tmux.conf to ~/.tmux.conf"
	@echo "  make import-settings  - Copy managed settings from ~/.claude/ to claude/ directory"
	@echo "  make migrate          - Back up and remove legacy commands/agents from ~/.claude/"
	@echo "  make clean            - Remove installed files"
	@echo "  make clean-config     - Remove installed CLAUDE.md"
	@echo "  make clean-settings   - Remove managed keys from settings.json (backup is created)"
	@echo "  make clean-agents     - Remove installed agents"
	@echo "  make clean-skills     - Remove installed skills"
	@echo "  make clean-tmux-conf  - Remove installed tmux.conf"
	@echo ""
	@echo "Install destination: CLAUDE_DIR=$(CLAUDE_DIR)"

# Install all
install: install-config install-settings install-statusline install-agents install-skills install-tmux-conf
	@echo "✓ Installation complete"

# Install CLAUDE.md
install-config:
	@echo "Installing CLAUDE.md to $(CLAUDE_DIR)/"
	@mkdir -p $(CLAUDE_DIR)
	@cp -v claude/CLAUDE.md $(CLAUDE_DIR)/CLAUDE.md
	@echo "✓ CLAUDE.md installed"

# Install settings.json
# 既存の settings.json がある場合はバックアップしてからマージする（リポジトリ側の値を優先し、既存のみのキーは残す）
install-settings:
	@echo "Installing settings.json to $(CLAUDE_DIR)/"
	@command -v jq > /dev/null 2>&1 || { echo "✗ jq is required"; exit 1; }
	@mkdir -p $(CLAUDE_DIR)
	@if [ -f $(CLAUDE_DIR)/settings.json ]; then \
		cp -v $(CLAUDE_DIR)/settings.json $(CLAUDE_DIR)/settings.json.bak.$(TIMESTAMP); \
		jq -s '.[0] * .[1]' $(CLAUDE_DIR)/settings.json claude/settings.json > $(CLAUDE_DIR)/settings.json.tmp \
			&& mv $(CLAUDE_DIR)/settings.json.tmp $(CLAUDE_DIR)/settings.json; \
		echo "merged claude/settings.json -> $(CLAUDE_DIR)/settings.json"; \
	else \
		cp -v claude/settings.json $(CLAUDE_DIR)/settings.json; \
	fi
	@echo "✓ settings.json installed"

# Install statusline-readable.sh
install-statusline:
	@echo "Installing statusline-readable.sh to $(CLAUDE_DIR)/"
	@mkdir -p $(CLAUDE_DIR)
	@cp -v claude/statusline-readable.sh $(CLAUDE_DIR)/statusline-readable.sh
	@echo "✓ statusline-readable.sh installed"

# Import settings
# リポジトリで管理しているキーだけを ~/.claude/settings.json から取り込む（autoMode などの個人設定は取り込まない）
import-settings:
	@echo "Importing settings from $(CLAUDE_DIR)/ to claude/"
	@command -v jq > /dev/null 2>&1 || { echo "✗ jq is required"; exit 1; }
	@mkdir -p claude
	@jq --slurpfile home $(CLAUDE_DIR)/settings.json \
		'with_entries(.value = ($$home[0][.key] // .value))' claude/settings.json > claude/settings.json.tmp \
		&& mv claude/settings.json.tmp claude/settings.json
	@echo "imported managed keys -> claude/settings.json"
	@cp -v $(CLAUDE_DIR)/statusline-readable.sh claude/statusline-readable.sh
	@echo "✓ Settings imported"

# Install agents
install-agents:
	@echo "Installing agents to $(CLAUDE_DIR)/agents/"
	@mkdir -p $(CLAUDE_DIR)/agents
	@cp -v claude/agents/*.md $(CLAUDE_DIR)/agents/
	@echo "✓ Agents installed"

# Install skills
# skill ごとに同期し、リポジトリで削除した補助ファイルはインストール先からも削除する
install-skills:
	@echo "Installing skills to $(CLAUDE_DIR)/skills/"
	@mkdir -p $(CLAUDE_DIR)/skills
	@for name in $(SKILLS); do \
		rsync -a --delete "claude/skills/$$name/" "$(CLAUDE_DIR)/skills/$$name/"; \
		echo "claude/skills/$$name/ -> $(CLAUDE_DIR)/skills/$$name/"; \
	done
	@echo "✓ Skills installed"

# Install tmux.conf
install-tmux-conf:
	@echo "Installing tmux.conf to $(TMUX_CONF)"
	@cp -v config/tmux.conf $(TMUX_CONF)
	@echo "✓ tmux.conf installed"

# Migrate from the commands-based layout
# 旧 commands と削除済み agent をバックアップしてから削除する（リポジトリ由来の名前のみ）
migrate:
	@echo "Backing up agents/commands/skills to $(BACKUP_DIR)/"
	@mkdir -p $(BACKUP_DIR)
	@for dir in agents commands skills; do \
		if [ -d $(CLAUDE_DIR)/$$dir ]; then cp -R $(CLAUDE_DIR)/$$dir $(BACKUP_DIR)/; fi; \
	done
	@echo "Removing legacy commands from $(CLAUDE_DIR)/commands/"
	@for name in $(LEGACY_COMMANDS); do rm -fv "$(CLAUDE_DIR)/commands/$$name.md"; done
	@rmdir $(CLAUDE_DIR)/commands 2> /dev/null || true
	@echo "Removing legacy agents from $(CLAUDE_DIR)/agents/"
	@for name in $(LEGACY_AGENTS); do rm -fv "$(CLAUDE_DIR)/agents/$$name.md"; done
	@echo "✓ Migration complete (backup: $(BACKUP_DIR))"

# Clean all
clean: clean-config clean-settings clean-agents clean-skills clean-tmux-conf
	@echo "✓ Cleanup complete"

# Clean CLAUDE.md
clean-config:
	@echo "Removing CLAUDE.md from $(CLAUDE_DIR)/"
	@rm -fv $(CLAUDE_DIR)/CLAUDE.md
	@echo "✓ CLAUDE.md removed"

# Clean settings
# リポジトリで管理しているキーだけを削除する（バックアップを作成）
clean-settings:
	@echo "Removing managed settings from $(CLAUDE_DIR)/"
	@command -v jq > /dev/null 2>&1 || { echo "✗ jq is required"; exit 1; }
	@if [ -f $(CLAUDE_DIR)/settings.json ]; then \
		cp -v $(CLAUDE_DIR)/settings.json $(CLAUDE_DIR)/settings.json.bak.$(TIMESTAMP); \
		jq --slurpfile repo claude/settings.json 'with_entries(select(.key as $$k | $$repo[0] | has($$k) | not))' \
			$(CLAUDE_DIR)/settings.json > $(CLAUDE_DIR)/settings.json.tmp \
			&& mv $(CLAUDE_DIR)/settings.json.tmp $(CLAUDE_DIR)/settings.json; \
	fi
	@rm -fv $(CLAUDE_DIR)/statusline-readable.sh
	@echo "✓ Settings removed"

# Clean agents
clean-agents:
	@echo "Removing agents from $(CLAUDE_DIR)/agents/"
	@for name in $(AGENTS); do rm -fv "$(CLAUDE_DIR)/agents/$$name.md"; done
	@echo "✓ Agents removed"

# Clean skills
clean-skills:
	@echo "Removing skills from $(CLAUDE_DIR)/skills/"
	@for name in $(SKILLS); do rm -rf "$(CLAUDE_DIR)/skills/$$name" && echo "removed $(CLAUDE_DIR)/skills/$$name"; done
	@echo "✓ Skills removed"

# Clean tmux.conf
clean-tmux-conf:
	@echo "Removing tmux.conf from $(TMUX_CONF)"
	@rm -fv $(TMUX_CONF)
	@echo "✓ tmux.conf removed"
