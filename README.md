# ia-stack

[![Version](https://img.shields.io/badge/version-1.0.0-blue.svg)](https://github.com/palcarzm/ia-stack)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A curated collection of bash commands, scripts, and reusable prompts for AI interaction. Human-orchestrated pipeline to generate markdown files and manage AI-assisted workflows. **No agents — just CLI and copy-paste.**

---

## 📋 Table of Contents

- [ia-stack](#ia-stack)
  - [📋 Table of Contents](#-table-of-contents)
  - [🎯 Philosophy](#-philosophy)
  - [📁 Project Structure](#-project-structure)
  - [🚀 Quick Start](#-quick-start)
  - [🛠️ Installation](#️-installation)
    - [From GitHub](#from-github)
    - [As a Git Submodule (for other projects)](#as-a-git-submodule-for-other-projects)

---

## 🎯 Philosophy

This repository is built on a simple premise:

> **You are the orchestrator. The AI is your assistant. The scripts are your tools.**

No complex agent frameworks. No API dependencies. Just:
1. **Bash scripts** that capture your project context
2. **Markdown outputs** that feed into AI chats
3. **Reusable prompts** that get consistent results

You copy. You paste. You review. You commit.

---

## 📁 Project Structure
```bash
ia-stack/
├── outputs/ # Generated context files
├── prompts/ # Reusable AI prompts
├── scripts/ # Bash automation scripts
└── templates/ # File templates

```
---

## 🚀 Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/palcarzm/ia-stack.git
cd ia-stack

# 2. Make scripts executable
chmod +x scripts/*.sh

# 3. Generate your first context file
./scripts/bundle.sh

# 4. Check the output
cat outputs/bundle.md

# 5. Copy the content, paste into your AI chat with a prompt
# Example: "Run code-review" (after running ./scripts/diff.sh && ./scripts/validate.sh)
```

---

## 🛠️ Installation
### From GitHub
```bash
git clone https://github.com/palcarzm/ia-stack.git
cd ia-stack
chmod +x scripts/*.sh
```

### As a Git Submodule (for other projects)
```bash
git submodule add https://github.com/palcarzm/ia-stack.git .ia-stack
ln -s .ia-stack/scripts scripts
ln -s .ia-stack/prompts prompts
```