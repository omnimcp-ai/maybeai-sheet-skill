---
name: maybeai-sheet
description: "Manages MaybeAI spreadsheets across upload, read/write, worksheet operations, formulas, formatting, and SQL result-table workflows. Use when working on Excel or spreadsheet tasks in MaybeAI, including file import, worksheet inspection, cell or range updates, row or column changes, formula execution, readable report sheets, sharing, or export. Use sheet-dashboard instead for chart-authoring or dashboard-first workflows."
version: 0.6.0
metadata:
  openclaw:
    requires:
      env:
        - MAYBEAI_API_TOKEN
    primaryEnv: MAYBEAI_API_TOKEN
    emoji: "📊"
    homepage: https://github.com/OmniMCP-AI/maybeai-uni
---

# MaybeAI Sheet

Use this skill for MaybeAI spreadsheet lifecycle work: upload/import files, inspect sheets, read and write data, manage worksheets, run formulas, build SQL result sheets, apply lightweight formatting, share, and export.

Do not use this skill as the primary workflow for chart-authoring or dashboard composition. For dashboard-first work, use `sheet-dashboard`.

## Quick Start

Required environment:

- `MAYBEAI_API_TOKEN`

Common script prerequisites:

- `curl`
- `jq`

Base URL:

```text
https://play-be.omnimcp.ai
```

Authorization header:

```text
Authorization: Bearer <MAYBEAI_API_TOKEN>
```

Ready-to-run examples live in `scripts/`:

```bash
bash scripts/01-file-management.sh
bash scripts/02-read-data.sh
bash scripts/03-write-data.sh
bash scripts/04-rows-columns.sh
bash scripts/05-worksheets.sh
bash scripts/06-formulas.sh
bash scripts/07-charts-pictures.sh
bash scripts/08-formatting.sh
bash scripts/09-end-to-end.sh
```

## When To Use Which Path

| User intent | Recommended path |
|---|---|
| 上传或导入 Excel | `references/file-management.md` |
| 查看工作表、读表头、抽样看数据 | `references/read-write.md` |
| 替换表格数据但保留表头/公式 | `references/read-write.md` |
| 按业务主键更新或追加行 | `references/read-write.md` |
| 插入/删除/移动行列，管理 worksheet | `references/read-write.md` |
| 写公式、重算、生成 SQL 结果表 | `references/formulas-sql.md` |
| 加轻量样式、冻结表头、自动筛选 | `references/charts-formatting.md` |
| 排查鉴权、写错 sheet、样式不生效、SQL 编译失败 | `references/errors-recovery.md` |
| 做图表或 dashboard 版面 | 转到 `sheet-dashboard`；本 skill 只覆盖底层表格和低层图表 API |

## Core Rules

### 1. 先选 worksheet，再读写

对非首个工作表，不要依赖默认行为。

- 端点支持时优先传 `worksheet_name`
- 某些端点必须在 `uri` 上追加 `?gid=<index>`
- 若两者都不传，很多调用会落到第一张表，也就是常见的“写到错 sheet”

详细规则见 `references/read-write.md`。

### 2. 先选高层 API，再退回底层 A1 写入

优先级：

1. `update_data_keep_headers`
2. `update_range_by_lookup`
3. `append_rows`
4. `update_range`

含义：

- “保留表头和列顺序，整表替换” 用 `update_data_keep_headers`
- “按主键更新并自动追加新行” 用 `update_range_by_lookup`
- “简单追加对象行” 用 `append_rows`
- “必须精确改 A1 区域或非表格单元格” 才用 `update_range`

### 3. 数据写入和样式写入分开

不要假设 `write_new_worksheet`、`update_range`、`sql/write_result` 会自动带格式。

如果用户要“可读报表”或“管理层表格”：

1. 先写数据
2. 再调用 `freeze_panes`
3. 再调用 `batch_set_cell_style`
4. 必要时再调列宽/行高/自动筛选

详细样式套路见 `references/charts-formatting.md`。

### 4. SQL 结果表先编译再落表

SQL 透视/结果表流程默认是：

1. `read_headers`
2. 必要时 `read_sheet` 抽样
3. `sql/compile`
4. `sql/write_result`
5. `read_sheet` 回读验证

不要直接跳过 `sql/compile`。

### 5. 写后必须回读验证

至少做其中之一：

- `read_sheet`
- `list_worksheets`
- `read_headers`
- 导出文件再人工检查

尤其是以下情况必须验证：

- SQL 结果表
- 非首个 worksheet 写入
- 保留公式/样式的覆盖更新
- 图表、图片、样式相关改动

## Agent-Safe Playbooks

### 上传并检查文件

1. 上传或导入文件
2. 拿到 `document_id` / `uri`
3. `list_worksheets`
4. `read_headers`
5. 必要时 `read_sheet` 看小范围样本

参考：

- `references/file-management.md`
- `references/read-write.md`
- `scripts/01-file-management.sh`
- `scripts/02-read-data.sh`

### 保留表头和公式，刷新整张表

1. 明确目标 worksheet
2. 用 `update_data_keep_headers`
3. 若有计算列，设置 `preserve_formulas: true`
4. `read_sheet` 回读

参考：

- `references/read-write.md`
- `scripts/03-write-data.sh`

### 按主键同步业务记录

1. 确认 key 列，如 `Order ID` / `SKU`
2. 用 `update_range_by_lookup`
3. 如需重算，再调 `recalculate_formulas`
4. `read_sheet` 验证结果

参考：

- `references/read-write.md`
- `references/formulas-sql.md`

### 生成 SQL 结果表

1. 查 worksheet 名或 gid
2. `read_headers`
3. 写 SQLite 风格 SQL
4. `sql/compile`
5. `sql/write_result`
6. `read_sheet` 验证输出

参考：

- `references/formulas-sql.md`
- `scripts/06-formulas.sh`

### 输出可读报表 worksheet

1. 用 `write_new_worksheet` 或数据写入 API 生成表格
2. `freeze_panes`
3. `batch_set_cell_style`
4. 可选列宽/行高/auto filter
5. 如果响应含 `source_info.styles_ignored=true`，明确告知用户当前引擎未应用样式

参考：

- `references/charts-formatting.md`
- `references/errors-recovery.md`
- `scripts/08-formatting.sh`

## Reference Map

- `references/file-management.md`
  适合上传、导入、搜索、复制、分享、导出、版本入口问题。
- `references/read-write.md`
  适合读表、目标 worksheet 选择、写入 API 选择、行列操作、worksheet 管理。
- `references/formulas-sql.md`
  适合公式、重算、SQL compile、SQL result table。
- `references/charts-formatting.md`
  适合低层图表 API、图片、冻结、样式、自动筛选、条件格式。
- `references/errors-recovery.md`
  适合失败排查、限制说明、恢复路径。

## What This Skill Intentionally Excludes

- 不负责完整 dashboard 编排、图表布局策略、信息图设计；这些由 `sheet-dashboard` 负责。
- 不把整份 API 手册塞进主 `SKILL.md`；具体请求体和长示例放在 `references/` 与 `scripts/`。
- 不默认替用户做样式重构、图表重排或复杂视觉设计，除非用户明确要求。
