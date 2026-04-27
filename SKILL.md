---
name: maybeai-sheet
description: "MaybeAI Sheet skill for full Excel/spreadsheet lifecycle management. Upload, read, edit, and analyze Excel files via the MaybeAI platform. Use when the user wants to: upload or import an Excel file, read spreadsheet data, inspect worksheet headers, update cell ranges, insert/delete rows or columns, manage worksheets, add charts or images, apply filters or conditional formatting, calculate formulas, generate SQL-assisted pivot/result tables, export files, manage versions, or perform any Excel data operation."
version: 0.3.0
metadata:
  openclaw:
    requires:
      env:
        - MAYBEAI_API_TOKEN
    primaryEnv: MAYBEAI_API_TOKEN
    emoji: "📊"
    homepage: https://github.com/OmniMCP-AI/maybeai-uni
---

# MaybeAI Sheet Skill

Full Excel/spreadsheet lifecycle management powered by the [MaybeAI](https://maybe.ai) platform. Upload files, read and write data, manage worksheets, add charts, apply formatting, and build SQL-assisted pivot/result tables via natural language.

## Scripts

Ready-to-run curl examples are in the [`scripts/`](./scripts/) folder. Each script reads credentials from environment variables — no hardcoded tokens.

```bash
export MAYBEAI_API_TOKEN=your_token_here
export DOC_ID=your_document_id_here          # needed by most scripts

bash scripts/01-file-management.sh   # upload, import, list, rename, delete, export
bash scripts/02-read-data.sh         # read sheet, list worksheets, versions
bash scripts/03-write-data.sh        # update range, append rows, copy range
bash scripts/04-rows-columns.sh      # insert/delete/move rows & columns, widths/heights
bash scripts/05-worksheets.sh        # create, rename, move, duplicate, delete worksheets
bash scripts/06-formulas.sh          # calc single/batch formulas, recalculate all
bash scripts/07-charts-pictures.sh   # add/edit/delete charts and pictures
bash scripts/08-formatting.sh        # freeze panes, auto filter, conditional formats
bash scripts/09-end-to-end.sh        # 3 complete workflow examples (upload→edit→export)
```

> **Requires**: `curl` and `jq`. Install jq with `brew install jq` (macOS) or `apt install jq` (Linux).

---

## Setup

### Get your API token

1. Go to **[https://maybe.ai/user/my-plan](https://maybe.ai/user/my-plan)** in your browser.
   *(Or click your avatar / name at the bottom-left of the app → **My Plan**.)*
2. Find the **API Token** card below the plan summary — it shows a masked Bearer token with copy and reveal buttons.
3. Copy the token and set it as an environment variable:

```bash
export MAYBEAI_API_TOKEN=your_token_here
```

### Required environment variable

| Variable | Description |
|---|---|
| `MAYBEAI_API_TOKEN` | Your MaybeAI Bearer token. Get it from [maybe.ai/user/my-plan](https://maybe.ai/user/my-plan). |

### Base URL

```
https://play-be.omnimcp.ai
```

All authenticated endpoints require the header:

```
Authorization: Bearer <MAYBEAI_API_TOKEN>
```

---

## Quick Reference

| User says | Action |
|---|---|
| "Upload this Excel file" | `POST /api/v1/excel/upload` |
| "Import from URL" | `POST /api/v1/excel/import_by_url` |
| "Read Sheet1 data" | `POST /api/v1/excel/read_sheet` |
| "List my files" | `POST /api/v1/excel/list_files` |
| "List worksheets" | `POST /api/v1/excel/list_worksheets` |
| "Update cells A1:B3" | `POST /api/v1/excel/update_range` |
| "Replace all data rows but keep headers" | `POST /api/v1/excel/update_data_keep_headers` |
| "Upsert rows by key, append new ones" | `POST /api/v1/excel/update_range_by_lookup` |
| "Append new rows" | `POST /api/v1/excel/append_rows` |
| "Insert 2 rows at row 5" | `POST /api/v1/excel/insert_rows` |
| "Delete rows 3–5" | `POST /api/v1/excel/delete_rows` |
| "Add a new worksheet" | `POST /api/v1/excel/write_new_worksheet` |
| "Inspect existing charts on a sheet" | `POST /api/v1/excel/read_sheet` and inspect `formatting.charts` |
| "Add a bar chart" | `POST /api/v1/excel/add_chart` |
| "Edit or move an existing chart" | `POST /api/v1/excel/set_chart` |
| "Delete a chart" | `POST /api/v1/excel/delete_chart` |
| "Freeze the header row" | `POST /api/v1/excel/freeze_panes` |
| "Format one or more ranges" | `POST /api/v1/excel/batch_set_cell_style` |
| "Add auto filter" | `POST /api/v1/excel/set_auto_filter` |
| "Calculate formula =SUM(A1:A10)" | `POST /api/v1/excel/calc_formulas` |
| "Build a pivot/result sheet from worksheet data" | `POST /api/v1/excel/sql/compile` then `POST /api/v1/excel/sql/write_result` |
| "Export/download the file" | `GET /api/v1/excel/export/{document_id}` |
| "Copy this spreadsheet" | `POST /api/v1/excel/copy_excel` |

---

## API Reference

### File Management

#### Upload Excel File
```
POST /api/v1/excel/upload
Content-Type: multipart/form-data

file: <xlsx file>
user_id: (optional)
```
Returns `{ document_id, uri, ... }`. Use `document_id` (also called `uri`) in all subsequent calls.

#### Import File by URL
```
POST /api/v1/excel/import_by_url
Authorization: Bearer <token>

{ "url": "https://..." }
```
Downloads the file from the URL into MaybeAI storage. Returns `document_id`.

#### List Files
```
POST /api/v1/excel/list_files
Authorization: Bearer <token>

{}
```

#### Search Files
```
POST /api/v1/excel/search_files
Authorization: Bearer <token>

{ "keyword": "sales" }
```

#### Rename File
```
POST /api/v1/excel/rename_file
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "new_filename": "new_name.xlsx" }
```

#### Delete File
```
POST /api/v1/excel/delete_file
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>" }
```

#### Export (Download) File
```
GET /api/v1/excel/export/{document_id}
```
Returns the raw `.xlsx` file.

#### Download File (from GridFS)
```
POST /api/v1/excel/download

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>" }
```

#### Copy Excel Document
```
POST /api/v1/excel/copy_excel
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>" }
```

---

### Reading Data

#### Get Spreadsheet Data (MOST USEFUL & FREQUENTLY USE) (JSON)
```
GET /api/v1/excel/spreadsheets/{doc_id}?gid=<sheet_index>
```
Returns spreadsheet data as JSON. `gid` selects the worksheet (0-indexed).

#### View Spreadsheet (HTML)
```
GET /api/v1/excel/spreadsheets/d/{doc_id}
```
Returns an HTML preview of the spreadsheet.

#### List Worksheets
```
POST /api/v1/excel/list_worksheets

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>" }
```

#### Read Sheet
```
POST /api/v1/excel/read_sheet

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1" }
```
Returns all cell data from the specified worksheet.

`read_sheet` also returns worksheet formatting metadata. For chart work, inspect:

- `formatting.charts`: current charts on the worksheet, including `cell`, `chart_id`, `type`, `title`, `legend`, `sql`, `series`, and optional `format`.
- `formatting.pictures`: current pictures on the worksheet.

Use `read_sheet` before `set_chart` or `delete_chart` when you need to identify the exact chart to edit, especially if multiple charts share the same anchor cell.

#### Read Headers
```
POST /api/v1/excel/read_headers

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>?gid=0" }
```
Use this first for fast schema inspection before writing SQL for pivot/result output.

#### Worksheet Targeting Rule

- Do not rely on `"sheet"` for `excelize-mcp`-backed read/write calls.
- Use `"worksheet_name"` when the endpoint supports it, such as `read_sheet`, `update_range`, `clear_range`, and `update_data_keep_headers`.
- Use `?gid=<sheet_index>` inside `uri` when the endpoint does not expose `worksheet_name`, such as `read_headers`, `append_rows`, and `update_range_by_lookup`.
- If neither `worksheet_name` nor `?gid=` is provided, the backend resolves to the first worksheet, which is effectively `gid=0`.

#### List Versions
```
POST /api/v1/excel/list_versions

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>" }
```

#### Read Version
```
POST /api/v1/excel/read_version

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "version": 1 }
```

---

### Writing & Editing Data

#### Update Range
```
POST /api/v1/excel/update_range
Authorization: Bearer <token>

{

  "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>",
  "worksheet_name": "Sheet1",
  "range_address": "A1:B3",
  "values": [["Name", "Score"], ["Alice", 95], ["Bob", 87]]
}
```

Use `uri: "https://www.maybe.ai/docs/spreadsheets/d/<document_id>?gid=2"` instead of `worksheet_name` if you want to target a sheet by gid.

#### Update Data Keep Headers
Use this when the sheet already has the correct header row and you want to replace the data rows underneath it without rebuilding column order manually.

```
POST /api/v1/excel/update_data_keep_headers
Authorization: Bearer <token>

{
  "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>",
  "worksheet_name": "Sheet1",
  "data": [
    {"Name": "Alice", "Score": 95, "Rate": "12%"},
    {"Name": "Bob", "Score": 87, "Rate": "18%"}
  ],
  "preserve_formulas": true,
  "start_row": 2
}
```

What it does:
- Keeps the existing header row unchanged and preserves its column order.
- Rewrites data rows using header names, so agents can send list-of-dict data instead of manually ordered row arrays.
- Can preserve formula columns that are not present in `data` and auto-fill those formulas down.
- Is often easier than `update_range` when the goal is "replace the table contents but keep the sheet structure".

#### Update Range by Lookup
Use this for key-based updates or upserts. It is more agent-friendly than low-level `update_range` when rows should be matched by business keys such as `id`, `sku`, or composite keys.

```
POST /api/v1/excel/update_range_by_lookup
Authorization: Bearer <token>

{

  "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>?gid=0",
  "data": [
    { "ID": "001", "Status": "Done" }
  ],
  "on": ["ID"],
  "override": false,
  "skip_recalculation": false
}
```

What it does:
- Matches existing rows by the `on` key column(s), then updates only the matching rows.
- Automatically appends unmatched rows as new rows, so one call can do update + append.
- Preserves existing headers and appends new columns to the right if the incoming data contains unseen fields.
- Does not overwrite existing formula cells.
- With `override: false`, empty values in the incoming data do not blank out existing cells.

#### Clear Range
```
POST /api/v1/excel/clear_range
Authorization: Bearer <token>


{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1", "range_address": "A1:D10" }
```

#### Append Rows
```
POST /api/v1/excel/append_rows
Authorization: Bearer <token>

{

  "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>?gid=0",
  "data": [
    {"Name": "Alice", "Score": 95},
    {"Name": "Bob", "Score": 87}
  ]
}
```

`append_rows` selects the target worksheet from `uri`. If you omit `?gid=`, it appends to the first worksheet.

#### Choosing the right write API

- Use `append_rows` when you have object rows keyed by existing headers and want a simple blind append.
- Use `update_data_keep_headers` when you have list-of-dict data and want to replace all table rows while keeping row 1, column order, styles, and optional formula columns.
- Use `update_range_by_lookup` when you need upsert behavior: update rows that match a key and append rows that do not exist yet.
- Use `update_range` when you truly need exact A1 targeting such as `B7:D12`, header rewrites, or non-tabular cell edits.
- Use `batch_set_cell_style` for visual formatting on one or more ranges. Even a single range must be sent as `range_addresses: ["B2:B100"]`.
- For non-first worksheets, always set `worksheet_name` or `uri?gid=N` explicitly. Otherwise writes can land on the first sheet.

#### Agent-friendly patterns

- Easier append than `append_rows`:
  If the agent has object-shaped rows like `{"sku":"A1","qty":2,"price":10}` and does not want to manually map them into the sheet's column order, prefer `update_range_by_lookup` for upsert-or-append or `update_data_keep_headers` for full-table replacement.
- Easier update than `update_range`:
  If the user says "update rows by order ID" or "sync these records into the sheet", prefer `update_range_by_lookup` so the agent does not need to read row numbers and construct A1 ranges first.
- Keep formulas intact:
  If the sheet has computed columns like `Total` or `Margin`, prefer `update_data_keep_headers` with `preserve_formulas: true` or `update_range_by_lookup`, which avoids overwriting existing formula cells.
- Simpler styling for agents:
  Prefer `batch_set_cell_style` over low-level Excel style objects or style IDs. It fits common LLM-safe actions like date formatting, currency formatting, header emphasis, alignment, and wrap text.

#### Write New Sheet (creates a new workbook)
```
POST /api/v1/excel/write_new_sheet
Authorization: Bearer <token>

{
  "sheet_name": "Summary",
  "data": [
    {"Col1": 1, "Col2": 2},
    {"Col1": 3, "Col2": 4}
  ]
}
```

#### Copy Range with Formulas
```
POST /api/v1/excel/copy_range_with_formulas
Authorization: Bearer <token>

{
  "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>",
  "worksheet_name": "Sheet1",
  "from_range": "A1:D10",
  "to_range": "F1",
  "auto_fill": false
}
```

#### Copy Range by Lookup
```
POST /api/v1/excel/copy_range_by_lookup
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>?gid=0", "from_range": "A2:D2", "lookup_column": "ID", "on": ["ID"], "skip_if_exists": true }
```

---

### Row & Column Operations

#### Insert Rows
```
POST /api/v1/excel/insert_rows
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1", "start_row": 3, "row_count": 2 }
```
Inserts `row_count` blank rows starting at `start_row` (1-indexed).

#### Delete Rows
```
POST /api/v1/excel/delete_rows
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1", "start_row": 3, "row_count": 2 }
```

#### Move Row
```
POST /api/v1/excel/move_row
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1", "from_row": 5, "to_row": 2 }
```

#### Move Rows (batch)
```
POST /api/v1/excel/move_rows
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1", "from_row": 5, "count": 2, "to_row": 2 }
```

#### Undo Delete Rows
```
POST /api/v1/excel/undo_delete_rows
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1", "version_before": 12, "start_row": 3, "row_count": 2 }
```

#### Insert Columns
```
POST /api/v1/excel/insert_columns
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1", "start_column": 3, "column_count": 1 }
```

#### Delete Columns
```
POST /api/v1/excel/delete_columns
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1", "start_column": 3, "column_count": 1 }
```

#### Move Column
```
POST /api/v1/excel/move_column
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1", "from_column": "E", "to_column": "B" }
```

#### Move Columns (batch)
```
POST /api/v1/excel/move_columns
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1", "from_column": "E", "count": 2, "to_column": "B" }
```

#### Undo Delete Columns
```
POST /api/v1/excel/undo_delete_columns
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1", "version_before": 12, "start_column": 3, "column_count": 1 }
```

#### Add Header Columns
```
POST /api/v1/excel/add_header_columns
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>?gid=0", "headers": ["NewCol1", "NewCol2"], "position": "end" }
```

#### Set Columns Width
```
POST /api/v1/excel/set_columns_width
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1", "start_column": "A", "end_column": "A", "width": 20 }
```

#### Set Rows Height
```
POST /api/v1/excel/set_rows_height
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1", "start_row": 1, "end_row": 1, "height": 30 }
```

---

### Worksheet Management

#### Write New Worksheet
```
POST /api/v1/excel/write_new_worksheet
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "NewSheet", "values": [["A", "B"], ["1", "2"]] }
```

#### Delete Worksheet
```
POST /api/v1/excel/delete_worksheet
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>?gid=2" }
```

#### Rename Worksheet
```
POST /api/v1/excel/rename_worksheet
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "old_name": "Sheet1", "new_name": "Sales" }
```

#### Move Worksheet
```
POST /api/v1/excel/move_worksheet
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Summary", "new_index": 0 }
```

#### Duplicate Worksheet
```
POST /api/v1/excel/copy_worksheet
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1", "new_worksheet_name": "Sheet1_copy" }
```

#### List Worksheets (with versions)
```
POST /api/v1/excel/list_worksheets_version

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>" }
```

---

### Formulas

#### Calculate Single Formula
```
POST /api/v1/excel/calc-formula
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>?gid=0", "cellAddress": "A11", "formula": "=SUM(A1:A10)" }
```

#### Calculate Multiple Formulas
```
POST /api/v1/excel/calc_formulas
Authorization: Bearer <token>

{
  "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>?gid=0",
  "formulas": [
    { "cell": "B11", "formula": "=SUM(B1:B10)" },
    { "cell": "C11", "formula": "=AVERAGE(C1:C10)" }
  ]
}
```

#### Compile SQL for Pivot/Result Output
```
POST /api/v1/excel/sql/compile
Authorization: Bearer <token>

{
  "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>?gid=2",
  "sql": "select \"Region\", sum(\"Revenue\") as \"Revenue\" from gid_2 group by \"Region\" order by \"Revenue\" desc"
}
```
Validate SQL against backend SQLite + worksheet/gid rules before writing any output.

#### Write SQL Result to Worksheet
```
POST /api/v1/excel/sql/write_result
Authorization: Bearer <token>

{
  "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>?gid=2",
  "sql": "select \"Region\", sum(\"Revenue\") as \"Revenue\" from gid_2 group by \"Region\" order by \"Revenue\" desc",
  "target_worksheet_name": "Pivot_RegionRevenue",
  "target_start_cell": "A1",
  "create_sheet_if_missing": true,
  "clear_target_range": true,
  "include_headers": true
}
```
Execute SQL and write the pivot/result matrix into a worksheet.

#### SQL Pivot Workflow

Use this for SQL-assisted pivot/result-table generation from worksheet data. Do not describe it as a general SQL engine on sheets. The recommended path is raw SQL authoring, compile-only validation, then dedicated result writing.

Default sequence:

1. Inspect source worksheet names with `POST /api/v1/excel/list_worksheets`.
2. Inspect headers with `POST /api/v1/excel/read_headers`, or inspect a small sample with `POST /api/v1/excel/read_sheet` and a narrow `range_address`.
3. Draft SQL using either the worksheet name or a `gid_*` table reference.
4. Validate SQL with `POST /api/v1/excel/sql/compile`.
5. If compile succeeds, write the result block with `POST /api/v1/excel/sql/write_result`.
6. Optionally verify the written output with `POST /api/v1/excel/read_sheet`.

Table naming rules:

- SQL can reference a worksheet name directly.
- SQL can reference `gid_*` such as `gid_2`.
- `gid_*` uses the backend worksheet gid mapping returned by worksheet inspection.
- Quote worksheet names when they contain spaces, for example `from "Sales Data"`.
- Compile first to catch unsupported syntax or unsupported SQL features.

Examples:

```sql
select "Region", sum("Revenue") as "Revenue"
from gid_2
group by "Region"
order by "Revenue" desc
```

```sql
select "SKU", sum("Qty") as "Qty"
from "Sales Data"
group by "SKU"
order by "Qty" desc
```

Important limitations:

- Not every SQL feature is supported.
- Backend behavior follows the current SQL formula compatibility rules and SQLite-based worksheet resolution.
- `POST /api/v1/excel/calc_formulas` remains useful for preview/debug of formula-driven work, but it is not the main recommended path for pivot/result output.
- If compile fails, fix the SQL before calling `sql/write_result`.

Example: Revenue by Region

Inspect headers first:

```http
POST /api/v1/excel/read_headers
```

```json
{
  "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>?gid=2"
}
```

If headers are not enough, read a small sample:

```http
POST /api/v1/excel/read_sheet
```

```json
{
  "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>?gid=2",
  "range_address": "A1:F10"
}
```

Draft SQL:

```sql
select "Region", sum("Revenue") as "Revenue"
from gid_2
group by "Region"
order by "Revenue" desc
```

Compile before write:

```http
POST /api/v1/excel/sql/compile
```

```json
{
  "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>?gid=2",
  "sql": "select \"Region\", sum(\"Revenue\") as \"Revenue\" from gid_2 group by \"Region\" order by \"Revenue\" desc"
}
```

Write the result:

```http
POST /api/v1/excel/sql/write_result
```

```json
{
  "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>?gid=2",
  "sql": "select \"Region\", sum(\"Revenue\") as \"Revenue\" from gid_2 group by \"Region\" order by \"Revenue\" desc",
  "target_worksheet_name": "Pivot_RegionRevenue",
  "target_start_cell": "A1",
  "create_sheet_if_missing": true,
  "clear_target_range": true,
  "include_headers": true
}
```

Verify the final output:

```http
POST /api/v1/excel/read_sheet
```

```json
{
  "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>",
  "worksheet_name": "Pivot_RegionRevenue",
  "range_address": "A1:B20"
}
```

#### Recalculate All Formulas
```
POST /api/v1/excel/recalculate_formulas
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>" }
```

---

### Charts

#### Chart Rules

- `add_chart` and `set_chart` both require `chart.type`.
- `add_chart` and `set_chart` require either `chart.series` or `chart.sql`.
- For sheet chart tasks, prefer `chart.sql` and omit `chart.series`.
- Do not send `series: []` when `chart.sql` is present unless the backend explicitly requires it for a specific chart type.
- Use `chart.series` only when the user explicitly wants to chart fixed worksheet ranges instead of SQL.
- If a series is provided, each series item must include `values`. `name`, `categories`, and `sizes` are optional.
- `title` is a plain string, not an Excelize nested object.
- `legend` is a plain string: `bottom`, `left`, `right`, `top`, or `none`.
- `x_axis_name` and `y_axis_name` are plain strings.
- `chart_id` is optional on add, but strongly recommended when the chart will be edited, moved, or deleted later.
- `width`, `height`, `show_blanks`, and `format` are supported chart fields when you need explicit rendering or placement control.
- Default chart size is `width: 480`, `height: 290`.
- `worksheet_name` is supported for all chart endpoints. If omitted, the backend resolves the worksheet from `uri`, including `?gid=<sheet_index>` when present.
- Prefer reading the sheet first and reusing `formatting.charts[*].chart_id` for follow-up edits or deletes.

#### add_chart Practical Payload

Use this shape as the baseline when authoring dashboard charts:

```json
{
  "uri": "https://www.maybe.ai/docs/spreadsheets/d/<doc_id>",
  "worksheet_name": "Dashboard",
  "cell": "B2",
  "chart": {
    "chart_id": "unique-id",
    "type": "line|bar|col|area|gauge|pie|doughnut|radar",
    "title": "Chart Title",
    "legend": "none|bottom|top|left|right",
    "x_axis_name": "",
    "y_axis_name": "",
    "width": 480,
    "height": 360,
    "show_blanks": "gap",
    "sql": "select ... from gid_0",
    "format": { "...": "..." }
  }
}
```

Practical guidance:

- Use `chart_id` for any chart that may be revised later.
- Prefer `sql` as the chart data source. Do not include `series` for normal sheet chart creation.
- Use `show_blanks: "gap"` for trend charts unless the user explicitly wants blanks connected.
- Keep `title`, `legend`, `x_axis_name`, and `y_axis_name` flat. Do not send nested Excelize objects.
- For dashboard charts, `480x360` is a practical explicit size when you want a taller aspect ratio than the backend default.

#### Supported Chart Types

Common types:

- `line`, `bar`, `col`, `pie`, `scatter`, `area`, `doughnut`, `radar`, `bubble`

Also supported:

- `line_3d`
- `bar_stacked`, `bar_percent_stacked`
- `bar_3d_clustered`, `bar_3d_stacked`, `bar_3d_percent_stacked`
- `bar_3d_cone_clustered`, `bar_3d_cone_stacked`, `bar_3d_cone_percent_stacked`
- `bar_3d_pyramid_clustered`, `bar_3d_pyramid_stacked`, `bar_3d_pyramid_percent_stacked`
- `bar_3d_cylinder_clustered`, `bar_3d_cylinder_stacked`, `bar_3d_cylinder_percent_stacked`
- `col_stacked`, `col_percent_stacked`
- `col_3d`, `col_3d_clustered`, `col_3d_stacked`, `col_3d_percent_stacked`
- `col_3d_cone`, `col_3d_cone_clustered`, `col_3d_cone_stacked`, `col_3d_cone_percent_stacked`
- `col_3d_pyramid`, `col_3d_pyramid_clustered`, `col_3d_pyramid_stacked`, `col_3d_pyramid_percent_stacked`
- `col_3d_cylinder`, `col_3d_cylinder_clustered`, `col_3d_cylinder_stacked`, `col_3d_cylinder_percent_stacked`
- `area_stacked`, `area_percent_stacked`, `area_3d`, `area_3d_stacked`, `area_3d_percent_stacked`
- `pie_3d`, `pie_of_pie`, `bar_of_pie`
- `surface_3d`, `wireframe_surface_3d`, `contour`, `wireframe_contour`
- `bubble_3d`
- `stock_high_low_close`, `stock_open_high_low_close`
- `gauge` is accepted as an alias and is stored as a doughnut-style chart

#### Add Chart
```
POST /api/v1/excel/add_chart
Authorization: Bearer <token>

{
  "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>",
  "worksheet_name": "Sheet1",
  "cell": "E2",
  "chart": {
    "type": "bar",
    "title": "Monthly Sales",
    "legend": "bottom",
    "x_axis_name": "Month",
    "y_axis_name": "Revenue",
    "sql": "select \"Month\", sum(\"Revenue\") as \"Revenue\" from \"Sheet1\" group by \"Month\" order by \"Month\""
  }
}
```

Notes:

- `chart_id` is optional on add, but you should set one if the chart will be edited later.
- Prefer `sql` for sheet charts and omit `series`.
- Use absolute Excel ranges like `Sheet1!$A$2:$A$10` in `series` only for fixed-range charts.
- SQL-only chart example:

```
POST /api/v1/excel/add_chart
Authorization: Bearer <token>

{
  "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>",
  "worksheet_name": "Dashboard",
  "cell": "M2",
  "chart": {
    "type": "col",
    "title": "Revenue by Region",
    "sql": "select \"Region\", sum(\"Revenue\") as \"Revenue\" from \"Sales\" group by \"Region\" order by \"Revenue\" desc"
  }
}
```

For sheet chart workflows, prefer this sequence:

```
1. POST /api/v1/excel/list_worksheets
2. POST /api/v1/excel/read_headers
3. POST /api/v1/excel/add_chart with chart.sql and no chart.series
```

#### Gauge SQL Rules

For `gauge` charts, the SQL shape matters:

- Prefer SQL that returns a single numeric value column.
- Good example: `select sum("访客") from gid_0`
- Do not send a normal label-plus-value result like `select "label" as ..., sum(...) as ...` for a gauge chart.
- The one practical exception is a deliberately constructed 2-row result for a custom doughnut-style gauge, but that is a special-case layout, not the default gauge pattern.

#### Legend Conventions

Recommended `legend` values by chart family:

| chart type | legend |
| --- | --- |
| `gauge`, `pie`, `doughnut`, `radar` | `none` |
| `line`, `bar`, `col`, `area` | `bottom` or `top` |

#### Chart Positioning With `format`

Use `chart.format` when you need deterministic placement or want to size a chart independently from default dimensions.

```
"format": {
  "offset_x": 8,
  "offset_y": 4,
  "scale_x": 1.0,
  "scale_y": 1.0,
  "lock_aspect_ratio": false,
  "from": { "col": 4, "row": 1 },
  "to": { "col": 11, "row": 16 }
}
```

Rules:

- `from.col` and `from.row` are 0-indexed.
- `to.col` and `to.row` are 0-indexed.
- `from` and `to` define a two-cell anchor for the chart.
- `col_off` and `row_off` are EMU offsets, not pixels. `offset_x` and `offset_y` are pixels.
- In Duke's dashboard measurements, 1 column is about `101px` and 1 row is about `27px`.
- `col_off: 0` and `row_off: 0` place the chart from the top-left corner of the anchor cell.
- `to.row_off` should stay `0` in the stable dashboard layout pattern.
- `to.col_off: 76` is a practical reference value for the right edge in the tested layout.
- Do not set identical `from` and `to`; the backend rejects zero-size anchors.
- If you care about layout stability across repeated edits, use `format.from` and `format.to` instead of relying only on `cell`.

Precision layout example:

```json
{
  "format": {
    "from": { "col": 1, "col_off": 0, "row": 1, "row_off": 0 },
    "to": { "col": 6, "col_off": 76, "row": 23, "row_off": 0 },
    "lock_aspect_ratio": true,
    "offset_x": 0,
    "offset_y": 0,
    "scale_x": 1,
    "scale_y": 1
  }
}
```

#### Edit or Replace Chart
```
POST /api/v1/excel/set_chart
Authorization: Bearer <token>

{
  "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>",
  "worksheet_name": "Sheet1",
  "cell": "E2",
  "chart": {
    "chart_id": "sales-chart-1",
    "type": "col",
    "title": "Monthly Sales (Updated)",
    "legend": "right",
    "x_axis_name": "Month",
    "y_axis_name": "Revenue",
    "sql": "select \"Month\", \"Revenue\" from \"Sheet1\"",
    "format": {
      "from": { "col": 4, "row": 1 },
      "to": { "col": 11, "row": 16 }
    }
  }
}
```

`set_chart` guidance:

- Prefer passing `chart.chart_id` when editing an existing chart.
- Use `cell` as the target anchor you want after the update.
- Set `x_axis_name` and `y_axis_name` whenever the chart should display explicit axis titles.
- If multiple charts share one cell, `chart_id` is the only safe way to edit the intended chart.
- Backend behavior follows excelize `SetChart` semantics. If the requested chart is not found, the backend may create a chart at the target cell, so verify with `read_sheet` afterward.

#### Delete Chart
```
POST /api/v1/excel/delete_chart
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1", "chart_id": "sales-chart-1" }
```

Delete rules:

- You must provide either `cell` or `chart_id`.
- Prefer `chart_id` for precise deletion.
- If you delete by `cell` and multiple charts share that anchor cell, backend deletion is cell-based and can remove all charts anchored there.
- After deletion, use `read_sheet` and confirm the chart is gone from `formatting.charts`.

#### Recommended Chart Workflow

```
1. Inspect worksheet and existing chart layout: POST /api/v1/excel/read_sheet
2. If editing, capture the target chart's chart_id from formatting.charts
3. Add or set the chart with explicit worksheet_name and cell
4. For stable placement, include chart.format.from and chart.format.to
5. Read the sheet again and verify formatting.charts
```

#### Recommended Sheet-Chart Authoring Flow

When building a chart from worksheet data, prefer a schema-first workflow:

```
1. List worksheets: POST /api/v1/excel/list_worksheets
2. Read headers for every relevant worksheet first: POST /api/v1/excel/read_headers
3. Generate the SQL formula after you know the exact headers
4. Add the chart with POST /api/v1/excel/add_chart and include that SQL in chart.sql
5. Read back with POST /api/v1/excel/read_sheet and verify formatting.charts
```

Why this order:

- `read_headers` is the safest way to understand available dimensions and measures before drafting chart SQL.
- If multiple worksheets may be used, inspect each relevant worksheet header set first instead of guessing column names.
- The SQL should be derived from real worksheet headers, not from user prose alone.

Recommended request pattern:

```
1. POST /api/v1/excel/list_worksheets
2. POST /api/v1/excel/read_headers for each worksheet or gid you may chart from
3. Draft SQL using worksheet names or gid_* table names
4. POST /api/v1/excel/add_chart with:
   - chart.type
   - chart.sql
   - chart.x_axis_name when the x-axis should be labeled
   - chart.y_axis_name when the y-axis should be labeled
```

Important backend rule:

- `chart.sql` is the preferred sheet-chart data source.
- Do not include `chart.series` for normal sheet chart creation or revision.
- Use `chart.series` only for explicit fixed-range charting requests.
- If the user explicitly asks to materialize SQL results into a worksheet table before charting, use:

```
1. POST /api/v1/excel/sql/compile
2. POST /api/v1/excel/sql/write_result
3. POST /api/v1/excel/add_chart with chart.sql, and add chart.series only if the user explicitly requires range-based charting
```

Minimal example:

```json
{
  "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>",
  "worksheet_name": "Dashboard",
  "cell": "E2",
  "chart": {
    "chart_id": "region-revenue-chart",
    "type": "col",
    "title": "Revenue by Region",
    "x_axis_name": "Region",
    "y_axis_name": "Revenue",
    "sql": "select \"Region\", sum(\"Revenue\") as \"Revenue\" from \"Sales\" group by \"Region\" order by \"Revenue\" desc"
  }
}
```

Agent rule:

- For sheet chart tasks, do not draft SQL first and inspect headers later.
- Always inspect worksheet headers first, then generate SQL, then call `add_chart`.

#### Arranging N Charts On a Worksheet

If you need to place `n` charts on one worksheet, use a dashboard layout instead of dropping charts directly into the raw data grid.

- Prefer a dedicated worksheet such as `Dashboard` or `Charts`.
- Keep source tables on the left or on separate worksheets; keep charts in a clean visual grid.
- In the tested dashboard layout, a practical 2-column anchor pattern is `E2`, `M2`, `E18`, `M18`, `E34`, `M34`, ...
- Leave at least 1 blank column and 1 blank row between neighboring chart bands.
- Do not intentionally anchor multiple charts to the same `cell` unless you plan to manage them by `chart_id`.
- For 1-3 charts, use a single column with larger charts.
- For 4-8 charts, use a 2-column grid.
- For more than 8 charts, split across multiple dashboard worksheets by topic or audience instead of shrinking everything into one sheet.
- When charts must align exactly, define every chart with `format.from` and `format.to` rather than relying on default cell anchoring.

A good default tiling plan for `n` charts is:

```
column anchors: E, M
row anchors:    2, 18, 34, 50, ...

chart 1 -> E2
chart 2 -> M2
chart 3 -> E18
chart 4 -> M18
chart 5 -> E34
chart 6 -> M34
...
```

Use this only as a starting point. If row heights or column widths have been customized, anchor by `format.from` and `format.to` so layout does not drift.

#### Dashboard Layout Template

Use this template when the user asks to build a worksheet-level dashboard with multiple charts.

Dashboard structure:

- Prefer keeping the visible dashboard area within columns `A:N` when possible.
- One row should usually hold at most 2 charts, with a 1-column gap between them.
- Use a 1-row vertical gap between chart bands. Do not use a 2-row gap unless the user explicitly wants extra whitespace.
- Row 1: dashboard title or KPI summary
- Rows 2+: chart grid
- Keep raw data tables off the dashboard when possible
- If the dashboard must reference local tables, place them far left or below the chart area

Practical chart sizes in the tested dashboard grid:

| type | columns | rows | pixels | aspect ratio |
| --- | --- | --- | --- | --- |
| Gauge | 3 columns | 8 rows | about `303x216` | about `1.4:1` |
| Other charts | 6 columns | 16 rows | about `606x432` | about `1.4:1` |

Column strategy:

- `n <= 3`: single-column layout
- `4 <= n <= 8`: two-column layout
- `n > 8`: split across multiple dashboard worksheets

Single-column template:

```
anchors: E2, E18, E34, E50, ...
from/to: (4,1)->(11,16), (4,17)->(11,32), ...
```

Two-column template:

```
left column anchors:  E2, E18, E34, E50, ...
right column anchors: M2, M18, M34, M50, ...

left chart format:  from {col: 4,  row: r}  to {col: 11, row: r+15}
right chart format: from {col: 12, row: r}  to {col: 19, row: r+15}
where r = 1, 17, 33, 49, ...
```

Band template with 1-row gaps:

```
KPI Band 1:   rows 1-8,   from_row=1,  to_row=8
gap:          row 9
KPI Band 2:   rows 10-17, from_row=9,  to_row=16
gap:          row 17
Chart Band 1: rows 18-33, from_row=17, to_row=32
gap:          row 33
Chart Band 2: rows 34-49, from_row=33, to_row=48
gap:          row 49
Chart Band 3: rows 50-65, from_row=49, to_row=64
```

Chart allocation rule:

```
chart 1  -> E2
chart 2  -> M2
chart 3  -> E18
chart 4  -> M18
chart 5  -> E34
chart 6  -> M34
chart 7  -> E50
chart 8  -> M50
...
```

Practical algorithm for `n` charts:

```
if n <= 3:
  use 1 column
  row_step = 16
  anchors = [E2, E18, E34, ...]
else if n <= 8:
  use 2 columns
  row_step = 16
  columns = [E, M]
  fill row by row
else:
  split by topic across Dashboard_1, Dashboard_2, ...
```

Recommended chart grouping:

- Top row: overview KPIs, trend, total distribution
- Middle rows: segment comparisons such as region, product, channel
- Lower rows: diagnostic or long-tail breakdown charts
- Important trend charts such as visitors or revenue can take the full width (`cols 1-12`).
- Comparison charts such as store share or product ranking work well as 2 side-by-side 6-column charts.
- Multi-metric analysis charts such as radar comparisons usually deserve the full width.

Copyable planning template:

```json
{
  "worksheet_name": "Dashboard",
  "layout": "two_column",
  "charts": [
    { "chart_id": "chart-1", "cell": "E2",  "format": { "from": { "col": 4,  "row": 1 },  "to": { "col": 11, "row": 16 } } },
    { "chart_id": "chart-2", "cell": "M2",  "format": { "from": { "col": 12, "row": 1 },  "to": { "col": 19, "row": 16 } } },
    { "chart_id": "chart-3", "cell": "E18", "format": { "from": { "col": 4,  "row": 17 }, "to": { "col": 11, "row": 32 } } },
    { "chart_id": "chart-4", "cell": "M18", "format": { "from": { "col": 12, "row": 17 }, "to": { "col": 19, "row": 32 } } }
  ]
}
```

Agent rule for dashboard authoring:

- Decide the full layout first.
- Reserve all chart positions before writing any chart.
- Give every chart a stable `chart_id`.
- Use the same `cell` and `format` when revising a chart with `set_chart`.
- After every 2-4 charts, run `read_sheet` and verify `formatting.charts`.

#### Common Chart Mistakes

- Do not pass `values` to `write_new_worksheet` when you only want to create an empty dashboard sheet. Send only `worksheet_name`.
- Do not pass `series` or `series: []` for normal sheet charts. Prefer `chart.sql`.
- Do not use a standard label-plus-value SQL result for a gauge chart. Prefer a single numeric value column.
- Do not set `format.to.row_off` to a non-zero value in the tested dashboard layout.
- Do not leave a 2-row vertical gap between chart bands if you want the compact dashboard layout described above.

---

### Pictures

#### Add Picture
```
POST /api/v1/excel/add_picture
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1", "cell": "D2", "picture": { "file_base64": "<base64_png>", "extension": "png" } }
```

#### Read Picture
```
POST /api/v1/excel/read_picture

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1", "cell": "D2" }
```

#### Delete Picture
```
POST /api/v1/excel/delete_picture
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1", "cell": "D2" }
```

---

### Formatting

#### Freeze Panes
```
POST /api/v1/excel/freeze_panes
Authorization: Bearer <token>

{
  "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>",
  "worksheet_name": "Sheet1",
  "freeze_rows": 1,
  "freeze_columns": 0
}
```
Set `freeze_rows: 1` to lock the header row while scrolling.

#### Batch Set Cell Style
Use this for both single-range and multi-range styling. There is no separate `set_cell_style` API. For a single range, pass a one-item `range_addresses` array.

Simplest single-range request:

```
POST /api/v1/excel/batch_set_cell_style
Authorization: Bearer <token>

{
  "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>",
  "worksheet_name": "Sheet1",
  "range_addresses": ["B2:B100"],
  "style": {
    "format": "date"
  }
}
```

Typical multi-range request:

```
POST /api/v1/excel/batch_set_cell_style
Authorization: Bearer <token>

{
  "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>",
  "worksheet_name": "Sheet1",
  "range_addresses": ["B2:B100", "E2:E100", "A1:F1"],
  "style": {
    "bold": true,
    "horizontal": "center",
    "wrap_text": true,
    "bg_color": "#D9EAD3"
  }
}
```

Use only the simplified `style` keys:
- `format`: `date`, `datetime`, `currency`, `percent`, `integer`, `decimal`, `text`
- `format_code`
- `bold`, `italic`, `wrap_text`
- `font_color`, `bg_color`
- `horizontal`, `vertical`
- `font_size`, `font_family`

This API applies only the specified keys and preserves existing unspecified style properties.

#### Set Auto Filter
```
POST /api/v1/excel/set_auto_filter
Authorization: Bearer <token>

{
  "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>",
  "worksheet_name": "Sheet1",
  "auto_filter": {
    "ref": "A1:F100",
    "filter_columns": []
  }
}
```

#### Remove Auto Filter
```
POST /api/v1/excel/remove_auto_filter
Authorization: Bearer <token>

{ "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1" }
```

#### Set Conditional Formats
```
POST /api/v1/excel/set_conditional_formats
Authorization: Bearer <token>

{
  "uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>",
  "worksheet_name": "Sheet1",
  "formats": [
    {
      "sqref": "B2:B100",
      "type": "cell",
      "criteria": ">",
      "value": "90",
      "format": { "font": { "color": "FF0000" } }
    }
  ]
}
```

---

## Common Workflows

### Workflow 1: Upload and read a file

```
1. Upload: POST /api/v1/excel/upload  → get document_id
2. List sheets: POST /api/v1/excel/list_worksheets  {"uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>"}
3. Read data: POST /api/v1/excel/read_sheet  {"uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1"}
```

### Workflow 2: Build a SQL-assisted pivot/result sheet

```
1. List worksheets: POST /api/v1/excel/list_worksheets  {"uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>"}
2. Inspect headers: POST /api/v1/excel/read_headers  {"uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>?gid=2"}
3. Compile SQL: POST /api/v1/excel/sql/compile  {"uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>?gid=2", "sql": "select \"Region\", sum(\"Revenue\") as \"Revenue\" from gid_2 group by \"Region\" order by \"Revenue\" desc"}
4. Write result: POST /api/v1/excel/sql/write_result  {"uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>?gid=2", "sql": "select \"Region\", sum(\"Revenue\") as \"Revenue\" from gid_2 group by \"Region\" order by \"Revenue\" desc", "target_worksheet_name": "Pivot_RegionRevenue", "target_start_cell": "A1", "create_sheet_if_missing": true, "clear_target_range": true, "include_headers": true}
5. Verify: POST /api/v1/excel/read_sheet  {"uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Pivot_RegionRevenue", "range_address": "A1:B20"}
```

### Workflow 3: Update existing data

```
1. Find file: POST /api/v1/excel/search_files  {"keyword": "sales"}
2. Read current data: POST /api/v1/excel/read_sheet  {"uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1"}
3. Upsert changed rows by key: POST /api/v1/excel/update_range_by_lookup  {"uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>?gid=2", "data": [...], "on": ["Order ID"]}
4. Recalculate: POST /api/v1/excel/recalculate_formulas  {"uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>"}
```

### Workflow 4: Bulk data append

```
1. Identify document_id (list_files or upload)
2. Choose the target worksheet first: either `worksheet_name` or `uri?gid=N`
3. Append object rows: POST /api/v1/excel/append_rows  {"uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>?gid=2", "data": [...]}
4. Upsert object rows by key: POST /api/v1/excel/update_range_by_lookup  {"uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>?gid=2", "data": [...], "on": [...]}
5. Replace the table under existing headers: POST /api/v1/excel/update_data_keep_headers  {"uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1", "data": [...]}
6. Read back to verify: POST /api/v1/excel/read_sheet  {"uri": "https://www.maybe.ai/docs/spreadsheets/d/<document_id>", "worksheet_name": "Sheet1"}
```

### Workflow 5: Refresh a table but keep headers and formulas

```
1. Identify document_id and worksheet
2. Read current data or headers if needed: POST /api/v1/excel/read_sheet or /read_headers
3. Replace table rows: POST /api/v1/excel/update_data_keep_headers
4. Use preserve_formulas=true if computed columns should remain
5. Read back to verify: POST /api/v1/excel/read_sheet
```

### Workflow 6: Build a dashboard worksheet with multiple charts

```
1. Inspect worksheet names and source tables: POST /api/v1/excel/list_worksheets and /read_sheet
2. Create or reuse a clean dashboard sheet: POST /api/v1/excel/write_new_worksheet
3. Choose anchor cells in a 1-column or 2-column grid, for example E2, M2, E18, M18
4. Add each chart with POST /api/v1/excel/add_chart and set chart_id for every chart
5. If exact placement matters, define chart.format.from and chart.format.to for each chart
6. Read back with POST /api/v1/excel/read_sheet and verify formatting.charts before adding more charts
7. Use POST /api/v1/excel/set_chart for later revisions and POST /api/v1/excel/delete_chart by chart_id for cleanup
```

---

## Notes

- **`uri` format**: Build `uri` from the returned `document_id` as `https://www.maybe.ai/docs/spreadsheets/d/{document_id}`. Add `?gid={gid}` only when the API needs worksheet selection from the URI itself.
- **SQL authoring**: For pivot/result-table generation, inspect worksheet names first, then use `read_headers` or a small `read_sheet` sample before writing SQL. Prefer `sql/compile` plus `sql/write_result` over `calc_formulas` for this workflow.
- **SQL table references**: Use either the worksheet name or `gid_*`. Quote worksheet names with spaces, for example `"Sales Data"`.
- **Range format**: Use Excel-style ranges like `A1`, `A1:B10`, `A:A`.
- **Style API rule**: Use only `batch_set_cell_style` for cell formatting. For a single target range, still send `range_addresses` as a one-item array.
- **Style input rule**: Keep style payloads small and explicit. Prefer keys like `format`, `bold`, `bg_color`, `horizontal`, and `wrap_text` instead of low-level Excel style structures.
- **Row/column indexing**: Row numbers are 1-indexed (row 1 = first data row). Columns use Excel letters (`A`, `B`, ...).
- **Worksheet targeting is explicit**: If you do not pass `worksheet_name` or `?gid=` in `uri`, many endpoints fall back to the first worksheet. This is the common reason writes appear to go to `gid=0`.
- **Header-aware tools are usually safer for agents**: `update_data_keep_headers` and `update_range_by_lookup` work with header names instead of raw column positions, which reduces mistakes when sheet layouts change.
- **Authentication**: Endpoints marked `AUTH` require `Authorization: Bearer <MAYBEAI_API_TOKEN>`. Public endpoints work without a token.
- **Spreadsheet viewer URL**: `https://www.maybe.ai/docs/spreadsheets/d/{doc_id}` renders a live HTML preview of the file and is the same base format used for request `uri` values.
