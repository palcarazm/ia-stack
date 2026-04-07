# Contributing to ia-stack

Thank you for considering contributing to ia-stack! This project thrives on community input. Whether you're fixing a bug, adding a prompt, or improving a script, your help is welcome.

To ensure a smooth contribution process, please follow the guidelines below.

---

## 📋 Table of Contents

- [Contributing to ia-stack](#contributing-to-ia-stack)
  - [📋 Table of Contents](#-table-of-contents)
  - [🚀 How to Contribute](#-how-to-contribute)
    - [1. Fork and Clone](#1-fork-and-clone)
    - [2. Keep Your Fork Updated](#2-keep-your-fork-updated)
    - [3. Create a Branch](#3-create-a-branch)
  - [🌿 Branch Structure](#-branch-structure)
  - [✍️ Commit Messages](#️-commit-messages)
    - [Format](#format)
    - [Allowed Types](#allowed-types)
    - [Examples](#examples)
  - [🔄 Pull Requests](#-pull-requests)
    - [PR Template](#pr-template)
    - [PR Requirements](#pr-requirements)
  - [🧪 Testing and Validation](#-testing-and-validation)
    - [For Scripts](#for-scripts)
    - [For Prompts](#for-prompts)
  - [🐛 Reporting Issues](#-reporting-issues)
  - [🎨 Code Style and Standards](#-code-style-and-standards)
    - [Bash Scripts](#bash-scripts)
    - [Prompts](#prompts)
  - [📚 Documentation](#-documentation)
    - [Documentation Files](#documentation-files)
  - [📜 Code of Conduct](#-code-of-conduct)
  - [📧 Contact](#-contact)
  - [🙏 Thank You](#-thank-you)

---

## 🚀 How to Contribute

### 1. Fork and Clone

```bash
# Fork the repository on GitHub first, then:
git clone https://github.com/YOUR_USERNAME/ia-stack.git
cd ia-stack
git remote add upstream https://github.com/palcarazm/ia-stack.git
```

### 2. Keep Your Fork Updated

```bash
git checkout main
git pull upstream main
git push origin main
```

### 3. Create a Branch

Create a branch for your contribution:

```bash
git checkout -b feat/add-new-prompt     # for features
git checkout -b fix/output-helper-bug   # for fixes
git checkout -b docs/update-readme      # for documentation
```

---

## 🌿 Branch Structure

| Branch Type | Naming Convention        | Example                   | Description                             |
| ----------- | ------------------------ | ------------------------- | --------------------------------------- |
| Feature     | `feat/<description>`     | `feat/code-review-prompt` | New prompt or script functionality      |
| Fix         | `fix/<description>`      | `fix/output-helper-path`  | Bug fix for existing code               |
| Docs        | `docs/<description>`     | `docs/update-readme`      | Documentation improvements              |
| Refactor    | `refactor/<description>` | `refactor/log-scripts`    | Code cleanup without functional changes |

**Rule:** If your change relates to a GitHub Issue, include the issue number in the branch name and commit messages. If no issue exists, create one first and wait for it to be validated.

---

## ✍️ Commit Messages

We follow **[Conventional Commits](https://www.conventionalcommits.org/)** specification.

### Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Allowed Types

| Type       | Purpose                                                 |
| ---------- | ------------------------------------------------------- |
| `feat`     | New prompt or script feature                            |
| `fix`      | Bug fix                                                 |
| `docs`     | Documentation only changes                              |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `style`    | Formatting, missing semicolons, etc. (no code change)   |
| `test`     | Adding missing tests or correcting existing tests       |
| `chore`    | Maintenance tasks (dependencies, config, etc.)          |

### Examples

```txt
feat(prompts): add code-review prompt with anti-sycophancy rules

- Includes Aim & Scope section
- Adds Operating Principles
- Specifies output format with ``` for code blocks

Implements #12
```

```txt
fix(scripts): resolve output_helper.sh path resolution

Paths are now relative to the helper script location
instead of the caller script.

Fixes #8
```

```txt
docs(readme): add quick start section and workflow diagram
```

---

## 🔄 Pull Requests

### PR Template

When opening a pull request, use the template.

### PR Requirements

- **Minimum approval:** 1 review from maintainer
- **CI checks:** All must pass (if configured)
- **Branch status:** Must be up to date with `main`
- **Description:** Must be complete and clear

---

## 🧪 Testing and Validation

### For Scripts

Test your bash script changes:

```bash
# Make script executable
chmod +x scripts/your-script.sh

# Run with --help
./scripts/your-script.sh --help

# Run normally
./scripts/your-script.sh

# Verify output is generated in outputs/
ls -la outputs/
```

### For Prompts

Validate prompt structure:

1. Check front-matter has all required fields (`name`, `version`, `description`, `scripts`)
2. Verify ''' is used for code blocks (not ```)
3. Ensure Aim & Scope is defined
4. Confirm Output Format is specified

---

## 🐛 Reporting Issues

- **Bug Reports**: Create an [Issue](https://github.com/palcarazm/ia-stack/issues) of type `bug` following the issue template. We will review, categorize, and prioritize the issue as needed. Contributors will be credited in the Release Notes. For support, use the [Discussions](https://github.com/palcarazm/ia-stack/discussions) section. For security issues, follow the instructions in `SECURITY.md` and **do not open a public issue**.
- **Feature Requests**: Create an [Issue](https://github.com/palcarazm/ia-stack/issues) of type `feature` using the template provided. We will analyze, categorize, and prioritize the request. Contributors will be credited in the Release Notes. For ambitious features, we may move the discussion to a thread in the [Discussions](https://github.com/palcarazm/ia-stack/discussions) section.

---

## 🎨 Code Style and Standards

### Bash Scripts

- Use `#!/bin/bash` (not `#!/bin/sh`)
- Include `show_help` function with `-h` or `--help` flag
- Use the shared `output_helper.sh` for file generation
- Output files go to `outputs/` directory
- Comments in English

### Prompts

- Front-matter required at top of file
- Use English only
- Follow the template structure from `templates/prompt.md`
- Include Anti-Sycophancy Rules
- Specify output format with ''' for code blocks

## 📚 Documentation

Update documentation when you change:

- **Scripts:** Update `scripts/index.md` scripts table
- **Prompts:** Update `prompts/index.md` and the prompt file itself
- **Project structure:** Update the tree in `README.md`

### Documentation Files

| File                  | Purpose                    |
| --------------------- | -------------------------- |
| `README.md`           | Main project documentation |
| `scripts/index.md`    | Catalog of all scripts     |
| `prompts/index.md`    | Catalog of all prompts     |
| `templates/prompt.md` | Template for new prompts   |

---

## 📜 Code of Conduct

Please adhere to our [Code of Conduct](CODE_OF_CONDUCT.md). We strive to create a welcoming and inclusive environment for all contributors.

Our Code of Conduct is based on the [Contributor Covenant](https://www.contributor-covenant.org/), version 2.1.

---

## 📧 Contact

For questions, suggestions, or security issues:
- **GitHub Discussions:** [Q&A Section](https://github.com/palcarazm/ia-stack/discussions/categories/q-a)
- **Issues:** [GitHub Issues](https://github.com/palcarazm/ia-stack/issues)


---

## 🙏 Thank You

Every contribution matters. Whether you're fixing a typo, improving a prompt, or adding a new script, you're helping make ia-stack better for everyone.

**Happy contributing!**

— The ia-stack maintainers