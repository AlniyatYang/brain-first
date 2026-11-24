#!/usr/bin/env python3
"""校验 skills/*/SKILL.md 是否符合 Agent Skills 规范及本仓库约定。

用法: python3 scripts/validate_skill.py   （需要 PyYAML）
"""
import re
import sys
from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parent.parent
ALLOWED_FIELDS = {"name", "description", "license", "compatibility", "metadata", "allowed-tools"}
NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
VERSION_RE = re.compile(r"^\d+\.\d+\.\d+$")
MAX_LINES = 500


def validate(skill_md: Path) -> list[str]:
    errors = []
    text = skill_md.read_text(encoding="utf-8")
    match = re.match(r"^---\n(.*?)\n---\n", text, re.S)
    if not match:
        return [f"{skill_md}: 缺少 YAML frontmatter"]
    try:
        fm = yaml.safe_load(match.group(1)) or {}
    except yaml.YAMLError as e:
        return [f"{skill_md}: frontmatter 不是合法 YAML: {e}"]

    def err(msg):
        errors.append(f"{skill_md.relative_to(ROOT)}: {msg}")

    for key in fm.keys() - ALLOWED_FIELDS:
        err(f"未知字段 `{key}`（规范允许: {', '.join(sorted(ALLOWED_FIELDS))}）")

    name = fm.get("name")
    if not isinstance(name, str) or not NAME_RE.match(name) or len(name) > 64:
        err("`name` 必须是 1-64 位小写字母/数字/连字符")
    elif name != skill_md.parent.name:
        err(f"`name`（{name}）必须与目录名（{skill_md.parent.name}）一致")

    desc = fm.get("description")
    if not isinstance(desc, str) or not desc.strip():
        err("`description` 必填且为字符串")
    elif len(desc) > 1024:
        err(f"`description` 超过 1024 字符（当前 {len(desc)}）")

    compat = fm.get("compatibility")
    if compat is not None and (not isinstance(compat, str) or len(compat) > 500):
        err("`compatibility` 必须是不超过 500 字符的字符串")

    metadata = fm.get("metadata", {})
    if not isinstance(metadata, dict) or not all(
        isinstance(k, str) and isinstance(v, str) for k, v in metadata.items()
    ):
        err("`metadata` 必须是 字符串 -> 字符串 的映射")
    elif not VERSION_RE.match(metadata.get("version", "")):
        err("`metadata.version` 必须是 x.y.z 形式的版本号")
    else:
        changelog = ROOT / "CHANGELOG.md"
        if changelog.exists() and f"[{metadata['version']}]" not in changelog.read_text(encoding="utf-8"):
            err(f"CHANGELOG.md 缺少版本 [{metadata['version']}] 的记录")

    lines = text.count("\n") + 1
    if lines > MAX_LINES:
        err(f"SKILL.md 超过 {MAX_LINES} 行（当前 {lines}），细节请移到 references/")

    # SKILL.md 中引用的 references/ 文件必须存在
    for ref in set(re.findall(r"references/[\w./-]+\.md", text)):
        if not (skill_md.parent / ref).exists():
            err(f"引用的文件不存在: {ref}")

    return errors


def main() -> int:
    skills = sorted((ROOT / "skills").glob("*/SKILL.md"))
    if not skills:
        print("未找到 skills/*/SKILL.md", file=sys.stderr)
        return 1
    errors = [e for s in skills for e in validate(s)]
    for e in errors:
        print(f"✗ {e}", file=sys.stderr)
    if errors:
        return 1
    for s in skills:
        print(f"✓ {s.relative_to(ROOT)}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
