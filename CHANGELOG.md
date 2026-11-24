# Changelog

版本号对应 `skills/brain-first/SKILL.md` 中的 `metadata.version`。

## [1.3.0] - 2026-11-24

面向"有想法、但 vibe coding 写多了手生了"的用户。

- 新增两种模式：项目优先（默认，照常把功能做出来，每个功能只留 1-2 处关键代码给用户）与练习优先（原有的开场协议 + 逐步推进）；节奏约束只作用于练习优先
- 新增难度档位：填空档 / 标准档 / 挑战档，手生时从填空档起步，"简单点 / 难一点"随时调整，并按表现自动降档或提议升档
- "卡住兜底"改为四级分级提示：方向 → 关键 API / 伪代码 → 挖空半成品 → 答案（由用户自己写入）
- 新增弱项本 `~/.brain-first/weak-spots.md`（需用户同意）：记录反复卡住的主题，之后优先练
- description 补充触发词："别全替我写"、"手生了"、"vibe coding 写多了"、"忘了怎么写代码"
- 新增项目优先与分级提示示例；新增红旗"用户刚说卡住就直接给答案"
- README 注明参考了 Claude Code 的 Learning 输出风格，并提示不要与其同时开启
- 明确定位为主要服务 Codex、Kimi Code、OpenCode 等没有内置 Learning 风格的 agent：README 以 Codex 为先，补充各 agent 的手动调用方式（Codex `$brain-first`、Kimi Code `/skill:brain-first`）与通过 `AGENTS.md` 长期开启的方法
- 新增"运行环境适配"：非交互运行（如 `codex exec`、CI）不启用；沙箱拦截验证命令时请用户自己运行；计划/待办集成不再只写 TodoList

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
