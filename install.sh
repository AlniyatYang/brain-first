#!/usr/bin/env bash
set -euo pipefail

# brain-first — 多 coding agent 一键安装/卸载
# 用法:
#   ./install.sh              # 安装到所有已安装的 agent（幂等）
#   ./install.sh --uninstall  # 从所有目录卸载
#
# Windows 用户请用 Git Bash 运行；PowerShell 可执行 `bash install.sh`

SKILL_NAME="brain-first"
SKILL_SRC="$(cd "$(dirname "$0")" && pwd)/skills/$SKILL_NAME"
MODE="${1:-install}"

# 每个 agent 一行："名称|agent 根目录|skill 目录"
# 根目录存在即视为已安装该 agent；skills 子目录不存在会自动创建。
# 每个 agent 只装一份，避免同一个 skill 被重复加载。
# 注意：Claude Code 必须排在 OpenCode 之前（OpenCode 的去重判断依赖它）。
AGENTS=(
  "Codex|$HOME/.codex|$HOME/.codex/skills"
  "Kimi Code|$HOME/.kimi-code|$HOME/.kimi-code/skills"
  "Claude Code|$HOME/.claude|$HOME/.claude/skills"
  "OpenCode|$HOME/.config/opencode|$HOME/.config/opencode/skills"
)

# 旧版本（≤1.1.0）还会装到这些目录；Codex / OpenCode 会同时读取它们，
# 留着会导致重复加载，所以安装和卸载时都清理。
LEGACY_DIRS=(
  "$HOME/.agents/skills"
)

usage() {
  echo "用法: ./install.sh [install|--uninstall|--help]"
}

remove_legacy() {
  for dir in "${LEGACY_DIRS[@]}"; do
    if [ -e "$dir/$SKILL_NAME" ] || [ -L "$dir/$SKILL_NAME" ]; then
      rm -rf "${dir:?}/$SKILL_NAME"
      echo "已清理旧版本残留 <- $dir/$SKILL_NAME"
    fi
  done
}

case "$MODE" in
  install)
    if [ ! -d "$SKILL_SRC" ]; then
      echo "错误：找不到 skill 源目录 $SKILL_SRC" >&2
      exit 1
    fi
    installed=0
    claude_installed=0
    for entry in "${AGENTS[@]}"; do
      IFS='|' read -r name root dir <<< "$entry"
      [ -d "$root" ] || continue
      # OpenCode 会读取 ~/.claude/skills，已装到 Claude Code 时不再重复安装
      if [ "$name" = "OpenCode" ] && [ "$claude_installed" -eq 1 ]; then
        echo "跳过 OpenCode：它会读取 ~/.claude/skills 中已安装的副本"
        if [ -e "$dir/$SKILL_NAME" ] || [ -L "$dir/$SKILL_NAME" ]; then
          rm -rf "${dir:?}/$SKILL_NAME"
          echo "已清理重复副本 <- $dir/$SKILL_NAME"
        fi
        continue
      fi
      mkdir -p "$dir"
      # 先删后拷，保证与源完全一致（cp -r 合并复制不会删除源中已移除的文件）
      rm -rf "${dir:?}/$SKILL_NAME"
      cp -r "$SKILL_SRC" "$dir/"
      echo "已安装 [$name] -> $dir/$SKILL_NAME"
      installed=$((installed + 1))
      [ "$name" = "Claude Code" ] && claude_installed=1
    done
    remove_legacy
    if [ "$installed" -eq 0 ]; then
      echo "未检测到任何已安装的 coding agent（~/.claude、~/.codex、~/.kimi-code、~/.config/opencode）。" >&2
      echo "手动安装：将 skills/$SKILL_NAME 复制到对应工具的 skills 目录（见 README）。" >&2
      exit 1
    fi
    echo "完成：已安装到 $installed 个目录。新开会话即可使用。"
    ;;
  --uninstall|uninstall)
    removed=0
    for entry in "${AGENTS[@]}"; do
      IFS='|' read -r _ _ dir <<< "$entry"
      if [ -e "$dir/$SKILL_NAME" ] || [ -L "$dir/$SKILL_NAME" ]; then
        rm -rf "${dir:?}/$SKILL_NAME"
        echo "已卸载 <- $dir/$SKILL_NAME"
        removed=$((removed + 1))
      fi
    done
    remove_legacy
    echo "完成：从 $removed 个目录卸载。"
    ;;
  -h|--help)
    usage
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
