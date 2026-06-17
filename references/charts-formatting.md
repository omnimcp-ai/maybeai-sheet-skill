# Charts and Formatting Reference

## 目录

1. 适用场景
2. 图表边界
3. 低层图表与图片 API
4. 样式与冻结
5. 报表美化最小流程

## 1. 适用场景

当任务涉及低层图表 API、图片、冻结窗格、单元格样式、自动筛选、条件格式时，读这份文档。

## 2. 图表边界

这个 skill 只覆盖底层表格能力和低层图表 API。

以下情况应切换到 `sheet-dashboard`：

- 图表编排是主任务
- dashboard 版面和讲故事是主任务
- 需要图表布局、样式体系、仪表板工作流

如果只是：

- 查看已有图表元数据
- 调底层 add/set/delete chart
- 绑定 chart 到已有 sheet

本 skill 足够。

脚本：`scripts/07-charts-pictures.sh`

## 3. 低层图表与图片 API

相关端点：

```text
POST /api/v1/excel/add_chart
POST /api/v1/excel/set_chart
POST /api/v1/excel/delete_chart
POST /api/v1/excel/add_picture
POST /api/v1/excel/read_picture
POST /api/v1/excel/delete_picture
```

建议：

- 先 `read_sheet` 看 `formatting.charts` / `formatting.pictures`
- 改已有图表前，先确认 `chart_id`、锚点 cell、worksheet

## 4. 样式与冻结

核心端点：

```text
POST /api/v1/excel/freeze_panes
POST /api/v1/excel/batch_set_cell_style
POST /api/v1/excel/set_auto_filter
POST /api/v1/excel/remove_auto_filter
POST /api/v1/excel/set_conditional_formats
POST /api/v1/excel/set_columns_width
POST /api/v1/excel/set_rows_height
```

重要规则：

- 单个区域也要用 `range_addresses: ["A1:G1"]`
- 样式 payload 保持小而明确
- 优先用高层样式键：
  - `format`
  - `bold`
  - `bg_color`
  - `font_color`
  - `horizontal`
  - `wrap_text`

## 5. 报表美化最小流程

适合用户说“做得更像管理报表”“加可读性”“加表头样式”。

1. 先写数据
2. `freeze_panes`
3. `batch_set_cell_style` 设表头样式
4. `batch_set_cell_style` 设重点行/汇总行
5. `set_columns_width` / `set_rows_height`
6. 必要时 `set_auto_filter`
7. `read_sheet` 回读

如果响应里出现：

```text
source_info.styles_ignored=true
```

要明确告诉用户当前 worksheet 引擎没有应用样式，不能宣称已完成美化。

脚本：

- `scripts/07-charts-pictures.sh`
- `scripts/08-formatting.sh`
