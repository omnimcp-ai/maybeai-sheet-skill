# Read/Write Reference

## 目录

1. 适用场景
2. Worksheet 定位规则
3. 读取端点
4. 写入 API 选择
5. 行列操作
6. Worksheet 管理
7. 写后验证

## 1. 适用场景

当任务涉及读表、抽样、读表头、更新单元格、替换整表、按 key 更新、追加行、插删行列、创建或重命名 worksheet 时，读这份文档。

## 2. Worksheet 定位规则

这是最重要的操作规则。

- 优先使用 `worksheet_name`
- 某些端点只认 `uri?gid=<index>`
- 两者都不传时，后端常默认第一张表

典型规则：

- `read_sheet` / `update_range` / `clear_range` / `update_data_keep_headers`
  优先用 `worksheet_name`
- `read_headers` / `append_rows` / `update_range_by_lookup`
  常用 `uri?gid=<index>`

如果用户说“改第二张表”“追加到 Summary”，先定位表，再执行。

## 3. 读取端点

### 读全表或局部范围

```text
POST /api/v1/excel/read_sheet
```

常用参数：

- `worksheet_name`
- `range_address`
- `value_render_option`
- `filter_tokens`
- `auto_filter`

适用：

- 看数据
- 抽样验证
- 读图表/格式元数据

### 读表头

```text
POST /api/v1/excel/read_headers
```

适用：

- 快速拿 schema
- SQL 写之前确认列名

### 列 worksheet / versions

```text
POST /api/v1/excel/list_worksheets
POST /api/v1/excel/list_worksheets_version
POST /api/v1/excel/list_versions
POST /api/v1/excel/read_version
```

## 4. 写入 API 选择

### `update_data_keep_headers`

适合：

- 表头已经正确
- 需要整表覆盖数据区
- 想保留列顺序
- 想保留公式列

优点：

- 输入可以是 list-of-dict
- 对 agent 更安全

### `update_range_by_lookup`

适合：

- 业务主键同步
- 更新已存在行
- 自动追加不存在的新行

常见 key：

- `Order ID`
- `SKU`
- `ID`

### `append_rows`

适合：

- 盲追加对象行
- 已知目标 sheet 和 header

### `update_range`

适合：

- 精确改某个 A1 区域
- 非表格化写入
- 手工修改小块单元格

### `clear_range`

适合：

- 清空指定区域
- 写入前先做局部 reset

## 5. 行列操作

相关端点：

```text
POST /api/v1/excel/insert_rows
POST /api/v1/excel/delete_rows
POST /api/v1/excel/move_row
POST /api/v1/excel/move_rows
POST /api/v1/excel/undo_delete_rows
POST /api/v1/excel/insert_columns
POST /api/v1/excel/delete_columns
POST /api/v1/excel/move_column
POST /api/v1/excel/move_columns
POST /api/v1/excel/undo_delete_columns
POST /api/v1/excel/add_header_columns
POST /api/v1/excel/set_columns_width
POST /api/v1/excel/set_rows_height
```

注意：

- 行号是 1-based
- 列通常用 Excel 字母，如 `A`、`B`

## 6. Worksheet 管理

相关端点：

```text
POST /api/v1/excel/write_new_worksheet
POST /api/v1/excel/delete_worksheet
POST /api/v1/excel/rename_worksheet
POST /api/v1/excel/move_worksheet
POST /api/v1/excel/copy_worksheet
```

建议：

- 新建报表页时先写数据，再单独做样式
- 删除 worksheet 前先确认 `gid` 或名称，避免删错

## 7. 写后验证

至少执行一个：

- `read_sheet`
- `read_headers`
- `list_worksheets`

强烈建议验证的场景：

- `update_data_keep_headers`
- `update_range_by_lookup`
- 非首个 worksheet 的写入
- `write_new_worksheet`

对应脚本：

- `scripts/02-read-data.sh`
- `scripts/03-write-data.sh`
- `scripts/04-rows-columns.sh`
- `scripts/05-worksheets.sh`
