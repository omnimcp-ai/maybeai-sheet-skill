# Errors and Recovery Reference

## 目录

1. 适用场景
2. 鉴权失败
3. 写到错 worksheet
4. 样式不生效
5. SQL 编译失败
6. 上传返回异常
7. 交付前验证

## 1. 适用场景

当任务失败、结果落错位置、样式没生效、SQL 不通过、上传结果不完整时，读这份文档。

## 2. 鉴权失败

常见现象：

- `401`
- `403`
- 文件能预览，但 API 调用失败

排查：

1. 确认 `MAYBEAI_API_TOKEN` 已设置
2. 确认请求头包含 `Authorization: Bearer <token>`
3. 确认当前端点是否需要认证

恢复：

- 重新设置 token
- 用 `list_files` 或 `list_worksheets` 做最小化鉴权测试

## 3. 写到错 worksheet

这是最常见错误。

原因：

- 没传 `worksheet_name`
- 需要 `?gid=` 的端点却只传了裸 `uri`
- 误以为后端会记住上一轮选择

恢复：

1. `list_worksheets`
2. 确认目标名称和 gid
3. 重写请求，显式传 `worksheet_name` 或 `uri?gid=N`
4. `read_sheet` 回读确认

## 4. 样式不生效

常见现象：

- 接口成功，但视觉上没变化
- 返回中出现 `source_info.styles_ignored=true`

恢复：

1. 不要宣称样式已成功
2. 明确告知当前引擎忽略了样式
3. 如果任务要求强样式输出，切到支持样式的 workbook/引擎

## 5. SQL 编译失败

常见原因：

- 列名拼错
- worksheet 名没加双引号
- 方言太偏
- `WITH` 或复杂结构被后端拒绝

恢复：

1. `read_headers`
2. 必要时小范围 `read_sheet`
3. 把 SQL 改成更接近 SQLite
4. 先 `sql/compile`，通过后再 `sql/write_result`

## 6. 上传返回异常

常见现象：

- 上传成功但缺 `document_id`
- 只返回 `uri`
- 文件路径错误

恢复：

1. 从 `uri` 里解析 `document_id`
2. 如果本地文件不存在，先修正 `EXCEL_FILE_PATH`
3. 用 `scripts/01-file-management.sh` 的上传逻辑复现

## 7. 交付前验证

最低验证标准：

- `list_worksheets`
- `read_sheet` 关键区域
- 必要时 `export`

以下操作后不要跳过验证：

- `sql/write_result`
- `update_data_keep_headers`
- `update_range_by_lookup`
- 新建或删除 worksheet
- 图表/图片/样式调整
