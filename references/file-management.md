# File Management Reference

## 目录

1. 适用场景
2. 基本约定
3. 核心端点
4. 分享与权限
5. 推荐流程

## 1. 适用场景

当用户要上传、导入、搜索、复制、重命名、删除、分享或导出 MaybeAI 表格时，读这份文档。

## 2. 基本约定

- Base URL: `https://play-be.omnimcp.ai`
- 认证头：`Authorization: Bearer <MAYBEAI_API_TOKEN>`
- 后续请求普遍使用：

```text
https://www.maybe.ai/docs/spreadsheets/d/<document_id>
```

- 上传成功后优先记录：
  - `document_id`
  - `uri`

## 3. 核心端点

### 上传文件

```text
POST /api/v1/excel/upload
```

说明：

- `multipart/form-data`
- 必填 `file`
- `user_id` 仅作为兼容字段，可选

脚本：`scripts/01-file-management.sh`

### 从 URL 导入

```text
POST /api/v1/excel/import_by_url
```

适合已有公网下载链接的 xlsx 文件。

### 列出或搜索文件

```text
POST /api/v1/excel/list_files
POST /api/v1/excel/search_files
```

搜索适合按关键词找历史文件。

### 重命名、删除、复制

```text
POST /api/v1/excel/rename_file
POST /api/v1/excel/delete_file
POST /api/v1/excel/copy_excel
```

这几个端点都围绕同一个 `uri` 工作。

### 导出

```text
GET /api/v1/excel/export/{document_id}
POST /api/v1/excel/download
```

建议：

- 想直接拿 `.xlsx` 文件时优先 `export`
- 已经拿着 `uri` 时可以用 `download`

## 4. 分享与权限

### 可见性

```text
POST /api/v1/share/sheet/visibility
```

### 共享给指定用户

```text
POST /api/v1/share/sheet/update-permission
```

### 查看权限

```text
POST /api/v1/share/sheet/list
POST /api/v1/share/sheet/permission
```

## 5. 推荐流程

### 新文件进入系统

1. `upload` 或 `import_by_url`
2. 记录 `document_id` 和 `uri`
3. `list_worksheets`
4. `read_headers` 或小范围 `read_sheet`

### 交付前导出

1. 完成写入
2. `read_sheet` 关键区域回读
3. `export` 下载最终文件

### 历史文件复用

1. `search_files`
2. `copy_excel`
3. 在副本上编辑，避免误改原件
