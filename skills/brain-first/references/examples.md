# 完整示例参考

主 SKILL.md 内联了一个整函数示例。这里是其余场景的完整示例，覆盖"局部函数"、"调试"、"项目优先"、"分级提示"与"项目级改造"。请求格式统一为 **背景 / 你的任务 / 提示** 三段式，锚点标记为 `TODO(human)`。

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

## 项目优先示例（填空档）

用户说"我想做个记账小工具，能按月统计每个分类花了多少钱。vibe coding 写多了，手有点生"。用户没有声明要学某项技术，走项目优先；提到"手生"，从填空档开始。

AI 第一条响应用一句话说明模式，然后照常把 CLI 入口、数据读写、输出格式化一次写完，只把"按月按分类汇总"这个核心留给用户，并预先写好骨架：

```python
def summarize(records, month):
    totals = {}
    for r in records:
        # TODO(human): 只统计 month 这个月的记录，把 r.amount 累加到 totals[r.category]
        pass
    return totals
```

> 当前模式：项目优先——我把功能做完，只留 1-2 处关键代码给你。想一步步来就说"认真练"。

> **背景:** 记账工具的读写和输出都已经接好，`summarize()` 返回的字典会直接被打印成月度报表。现在缺的是最核心的汇总逻辑。
>
> **你的任务:** 在 ledger.py 的 summarize() 循环里找到 TODO(human)，补上 2-3 行：过滤月份，并按分类累加金额。
>
> **提示:** `r.date` 是 `datetime.date`，可以用 `r.date.strftime("%Y-%m")` 和 month 比较；累加时注意分类第一次出现时字典里还没有这个键，`dict.get(key, 0)` 能省掉一个 if。
>
> （当前：填空档，想难一点就说"难一点"）

用户写完、检查通过后，功能结束，AI 提一个验收问题（用户可回复"跳过"）：

> 如果以后要同时统计多个月，这个函数的结构哪里需要变？

## 分级提示示例

接上例，用户说"卡住了，不知道怎么判断月份"。AI 每次只给一级：

> #### 💡 提示（第 1 级）
> 先把每条记录的日期变成和 month 同样格式的字符串，再比较是否相等；不相等就跳过这条。

用户仍然卡住：

> #### 💡 提示（第 2 级）
> 伪代码：
> 1. key = 把 r.date 格式化成 "年-月"
> 2. 如果 key 不等于 month：continue
> 3. totals[分类] = 原来的值（没有就当 0）+ 金额

用户还是写不出来：

> #### 💡 提示（第 3 级）
> 已经很接近了，补上两个空：
>
> ```python
> if r.date.strftime(____) != month:
>     continue
> totals[r.category] = totals.get(r.category, ____) + r.amount
> ```

这一点用到了第 3 级提示，满足"值得记录"的条件。弱项本文件不存在时，AI 在本次验收消息末尾问一次是否记录。

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
| 项目优先 | 本文件第三个示例 | 用户想把东西做出来：AI 写完常规部分，每个功能只留 1-2 处关键点 |
| 分级提示 | 本文件第四个示例 | 用户卡住时逐级给提示：方向 → API/伪代码 → 挖空半成品 → 答案 |
| 项目级改造 | 本文件第五个示例 | 框架迁移/改造（练习优先）：先走开场协议（概念地图+步骤总览），再按步骤逐个留 TODO(human)，每步验收 |

选择原则：**一次只让用户做一个决策点**。多个关键点分散在几处时，逐个请求，不要一次抛三个 TODO(human)（见 SKILL.md 关键准则第 3 条）。
