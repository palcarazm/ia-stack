---
title: IA Stack Scripts Index
version: 1.0.0
last_updated: 2026-04-07
---

# Scripts Index

This index documents all bash scripts in the `ia-stack` collection. Each script generates markdown output files that feed into AI prompts.

---

## Quick Reference

| Script                                 | Purpose                                     | Output File             | Dependencies |
| -------------------------------------- | ------------------------------------------- | ----------------------- | ------------ |
| [`bundle.sh`](bundle.sh)               | Bundle project files into a single markdown | `outputs/bundle.md`     | `find`       |
| [`diff.sh`](diff.sh)                   | Capture staged git changes                  | `outputs/diff.md`       | `git`        |
| [`log.sh`](log.sh)                     | Unified interface for log scripts           | Varies                  | `git`        |
| - [`log-complete.sh`](log-complete.sh) | Full commit history (HEAD)                  | `outputs/log.md`        | `git`        |
| - [`log-branch.sh`](log-branch.sh)     | Compare branches                            | `outputs/log-branch.md` | `git`        |
| - [`log-tag.sh`](log-tag.sh)           | Commits from last tag to HEAD               | `outputs/log-tag.md`    | `git`        |
| [`validate.sh`](validate.sh)           | Project validation report                   | `outputs/validate.md`   | `npm`, `git` |

---