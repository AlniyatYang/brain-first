# Changelog

版本号对应 `skills/brain-first/SKILL.md` 中的 `metadata.version`。

## [1.2.0] - 2026-11-24

### Skill 行为

- 新增"用户完成 TODO(human) 后"环节：先读用户代码、能编译/测试就验证，有问题只给提示让用户自己改，通过后删除 `TODO(human)` 标记再验收
- 写入 `TODO(human)` 前先全库搜索：本会话遗留的先清理，非本会话产生的先询问用户
- 统一行数规则：每次邀请 2-10 行；学习目标相关操作即使 1 行也邀请，超过 10 行拆成多次
- 统一教学要点节奏：每步验收通过后 1 条，全部完成后 2-3 条，其余时候不额外讲解
- 节奏约束与"一回合改多个文件"红旗限定为学习/改造类任务，普通任务不受影响
- 示例：MyBatis-Plus 改造中"Mapper 继承 BaseMapper"改为【用户做】，与"学习目标反转"一致；调试示例改为由用户决定日志观察点

### 安装与规范

- `install.sh` 加上可执行权限
- `install.sh` 以 agent 根目录判断是否安装，自动创建缺失的 `skills/` 目录（修复全新 Claude Code 安装检测不到的问题）
- 每个 agent 只装一份：不再安装到 `~/.agents/skills`，已装 Claude Code 时跳过 OpenCode，并清理旧版本残留，避免重复加载
- `install.sh` 新增 `--help`
- `compatibility` 改为字符串，符合 Agent Skills 规范
- 新增 `scripts/validate_skill.py` 与 GitHub Actions CI（shellcheck、skill 校验、安装脚本冒烟测试）
- README：修正 `<repo-url>` 占位符与 `npx skills add` 命令、错字、仓库结构；新增英文 README

## [1.1.0] - 2026-08-03

- 学习/改造类任务强制走开场协议（概念地图 + 步骤总览），新增节奏约束、验收问题、卡住兜底与红旗清单
- 新增 MyBatis → MyBatis-Plus 项目级改造示例
- `install.sh` 改为先删后拷，保证安装副本与源一致

## [1.0.0] - 2026-08-03

- 首个版本：关键代码让渡、`TODO(human)` 契约、三段式请求、教学要点、退出机制
- 支持 Claude Code、Codex、OpenCode、Kimi Code
