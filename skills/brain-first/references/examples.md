# 完整示例参考

主 SKILL.md 内联了一个整函数示例。这里是其余教学粒度的完整示例，覆盖"局部函数"、"调试"与"项目级改造"三种场景。请求格式统一为 **背景 / 你的任务 / 提示** 三段式，锚点标记为 `TODO(human)`。

## 局部函数示例

> **背景:** 我构建了上传组件，提交前会校验文件。主校验逻辑已完成，但 switch 语句里需要针对不同文件类型分类处理。
>
> **你的任务:** 在 upload.js 的 validateFile() 函数 switch 语句中，实现 'case "document":' 分支。找到 TODO(human)。该分支校验文档文件（pdf、doc、docx）。
>
> **提示:** 考虑校验文件大小限制（文档类建议 10MB？）、校验扩展名与 MIME 类型一致、返回 {valid: boolean, error?: string}。file 对象具有 name、size、type 属性。

## 调试示例

> **背景:** 用户报告计算器中数字输入不工作。我已定位 handleInput() 是疑似源头，但需要理解实际处理的值。
>
> **你的任务:** 在 calculator.js 的 handleInput() 函数中找到 TODO(human)，添加 2-3 条日志。记录哪些值、放在哪一步之后，由你来决定——目标是用最少的日志判断输入在哪一环被丢掉。
>
> **提示:** 先画出数据流：原始事件 → 解析 → 校验 → 更新状态。像二分查找一样选观察点：先在中间一环打日志，看问题在它之前还是之后。注意 `"0"`、`""`、`NaN` 这类边界值在解析后的样子。

## 项目级改造示例（MyBatis → MyBatis-Plus）

用户说"我想学习把项目改造为 MyBatis-Plus"时，AI 的第一条响应**不碰任何代码**，先走开场协议：

> **概念地图**
>
> MyBatis-Plus（MP）是在 MyBatis 之上的增强工具，只做增强不做改变：
> - `BaseMapper`：免写单表 CRUD 的 Mapper 方法和 XML
> - `Wrapper`：用条件构造器替代手写 SQL 拼条件
> - 分页插件：取代 PageHelper，用显式的 `Page` 对象贯穿调用链
>
> 本项目的痛点：大量 PageHelper 分页调用 + 一堆模板化的单表 CRUD Mapper/XML。

> **步骤总览**
>
> 1. 盘点旧触点（PageHelper、模板 Mapper、XML 清单）【AI 做】
> 2. pom 换依赖，选 spring-boot3 starter 版本【用户做——版本选择是真实坑：3.5.9 起分页需单独引 `mybatis-plus-jsqlparser`】
> 3. yml 平移与 `mapper-locations` 配置【用户做 1 行】
> 4. 实体注解 `@TableId` / `@TableField`【用户做】
> 5. Mapper 继承 `BaseMapper`【用户做——这是 MP 的核心用法，按"学习目标反转"由用户亲手完成；AI 只负责删除被取代的模板方法】
> 6. 分页范式 PageHelper → `IPage`【用户做，核心决策点】
> 7. 条件查询改 `LambdaQueryWrapper`【用户做】
> 8. XML 去留裁决【用户做判断、AI 执行】
> 9. 编译 + 接口回归【AI 做】
>
> 以上分工如无异议，回复"开始"，我们按步骤逐个来。

用户确认后，AI 按步骤推进，遇到决策点时留 TODO(human) 并发出三段式请求。以第 6 步（分页范式改造）为例：

> **背景:** 依赖和配置已就绪。EmpServiceImpl 里的 `PageHelper.startPage` 需要换成 MP 的 `IPage` 范式——这是本次改造的核心决策点。
>
> **你的任务:** 在 EmpServiceImpl 的 page() 方法中找到 TODO(human)，用 `new Page<>(page, pageSize)` 传给 `empMapper.list`，并用 `getRecords()` / `getTotal()` 封装回 PageResult。
>
> **提示:** 两种分页模型理念不同：PageHelper 靠 ThreadLocal 静态拦截，MP 用显式 Page 参数贯穿 Mapper 签名。自定义 XML 分页方法需把 `IPage` 放第一个参数并加 `@Param`。

## 教学粒度选择

| 场景 | 示例 | 适用时机 |
|---|---|---|
| 整函数 | 主文件内联（selectHintCell） | 功能的核心算法或接口定义，值得用户写完整函数 |
| 局部函数 | 本文件第一个示例 | 大函数中的一个分支/分支块，用户补一小段 |
| 调试 | 本文件第二个示例 | 定位问题时，用户亲手加日志观察数据流 |
| 项目级改造 | 本文件第三个示例 | 框架迁移/改造：先走开场协议（概念地图+步骤总览），再按步骤逐个留 TODO(human)，每步验收 |

选择原则：**一次只让用户做一个决策点**。多个关键点分散在几处时，逐个请求，不要一次抛三个 TODO(human)（见 SKILL.md 关键准则第 3 条）。
