# Formulas and SQL Reference

## 目录

1. 适用场景
2. 公式端点
3. SQL 结果表流程
4. SQL 写法约束
5. 常见工作流

## 1. 适用场景

当任务涉及写公式、公式重算、SQL 透视、结果表输出、结果页验证时，读这份文档。

## 2. 公式端点

```text
POST /api/v1/excel/formula/set
POST /api/v1/excel/calc-formula
POST /api/v1/excel/calc_formulas
POST /api/v1/excel/recalculate_formulas
```

建议：

- 真正写回工作簿中的公式，用 `formula/set`
- 临时预览或调试公式，用 `calc-formula` / `calc_formulas`
- 改完大量数据后，需要统一刷新时，用 `recalculate_formulas`

脚本：`scripts/06-formulas.sh`

## 3. SQL 结果表流程

标准流程：

1. `list_worksheets`
2. `read_headers`
3. 必要时 `read_sheet` 抽样
4. `sql/compile`
5. `sql/write_result`
6. `read_sheet` 回读结果表

核心端点：

```text
POST /api/v1/excel/sql/compile
POST /api/v1/excel/sql/write_result
```

不要跳过 `compile`。

## 4. SQL 写法约束

优先写 SQLite 风格 SQL。

允许的方向：

- `select`
- `group by`
- `order by`
- `limit`
- `left join`
- `with`
- `coalesce`
- `round`

不推荐直接使用：

- MySQL 反引号
- SQL Server `TOP`
- PostgreSQL `ILIKE`
- BigQuery 专属结构

表名规则：

- 可以直接引用 worksheet 名
- 也可以引用 `gid_*`
- worksheet 名有空格时要加双引号，例如 `"Sales Data"`

如果 `WITH` 被后端拒绝，改成 inline subquery 再编译。

## 5. 常见工作流

### 生成区域收入结果表

1. `read_headers`
2. 编写 SQL：

```sql
select "Region", sum("Revenue") as "Revenue"
from gid_2
group by "Region"
order by "Revenue" desc
```

3. `sql/compile`
4. `sql/write_result`
5. `read_sheet` 验证 `Pivot_RegionRevenue`

### 同步业务数据后重算

1. `update_range_by_lookup`
2. `recalculate_formulas`
3. `read_sheet`

### 新报表页写公式

1. `write_new_worksheet`
2. `formula/set`
3. `recalculate_formulas`
4. `read_sheet`
