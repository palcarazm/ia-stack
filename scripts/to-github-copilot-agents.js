#!/usr/bin/env node

import fs from "fs-extra";
import matter from "gray-matter";
import { join } from "node:path";
import { execSync } from "node:child_process";

const PROMPTS_DIR = "./prompts";
const OUTPUT_DIR = "./dist/.github/agents";

fs.removeSync(OUTPUT_DIR);
fs.ensureDirSync(OUTPUT_DIR);

const lastCommit = execSync("git rev-parse HEAD").toString().trim();
const createdAt = new Date().toISOString();

const files = fs.readdirSync(PROMPTS_DIR).filter(f => f.endsWith(".md"));

for (const file of files) {
  if(file.endsWith("index.md")) continue; // Skip index.md files
  
  const fullPath = join(PROMPTS_DIR, file);
  const raw = fs.readFileSync(fullPath, "utf8");

  const parsed = matter(raw);

  const content = parsed.content.trim();

  const name = parsed.data.name || file.replace(".md", "");

  const aimRegex = /## Aim & Scope([\s\S]*?)(##|$)/;
  const aimMatch = content.match(aimRegex);

  if (!aimMatch) {
    console.error(`❌ File ${file} do not have a section "Aim & Scope"`);
    continue;
  }

  const roleSection = aimMatch[1].trim();

  const instructions = content.replace(aimRegex, "##").replaceAll("# ", "## ").trim();

  const newFrontMatter = ``.trim();

  const agent = `---
name: ${name}
version: ${parsed.data.version || "1.0.0"}
description: ${parsed.data.description || ""}
scripts: ${parsed.data.scripts || []}
source: "[palcarazm/ia-stack](https://github.com/palcarazm/ia-stack)"
refs: \`${lastCommit}\`
createdAt: \`${createdAt}\`
---

## Role
${roleSection}

## Instructions
${instructions}

## Tools
- file-system
- workspace
- search
- terminal

`.trim() + "\n";

  const outputFile = join(OUTPUT_DIR, `${name}.agent.md`);
  fs.writeFileSync(outputFile, agent);

  console.log(`✅ File generated: ${outputFile}`);
}
