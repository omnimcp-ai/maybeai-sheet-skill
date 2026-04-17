#!/usr/bin/env bash
# MaybeAI Sheet — Charts & Pictures
# Usage: export MAYBEAI_API_TOKEN=your_token_here
#        export DOC_ID=your_document_id_here
#        bash 07-charts-pictures.sh

BASE_URL="https://play-be.omnimcp.ai"
TOKEN="${MAYBEAI_API_TOKEN:?Please set MAYBEAI_API_TOKEN}"
DOC_ID="${DOC_ID:?Please set DOC_ID}"
DOC_URI="https://www.maybe.ai/docs/spreadsheets/d/$DOC_ID"
PICTURE_FILE_BASE64="${PICTURE_FILE_BASE64:-iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4////fwAJ+wP9KobjigAAAABJRU5ErkJggg==}"
CHART_ID="${CHART_ID:-sales-chart-1}"
SQL_CHART_ID="${SQL_CHART_ID:-revenue-sql-chart-1}"

# ── Add Chart ─────────────────────────────────────────────────────────────────
# Supported types include: line, bar, col, pie, scatter, area, doughnut,
# radar, bubble, gauge, plus stacked/3D variants.
echo "=== Add Bar Chart ==="
curl -s -X POST "$BASE_URL/api/v1/excel/add_chart" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"uri\": \"$DOC_URI\",
    \"worksheet_name\": \"Sheet1\",
    \"cell\": \"E2\",
    \"chart\": {
      \"type\": \"bar\",
      \"title\": \"Monthly Revenue\",
      \"legend\": \"bottom\",
      \"x_axis_name\": \"Month\",
      \"y_axis_name\": \"Revenue\",
      \"series\": [
        {
          \"name\": \"Sheet1!\$B\$1\",
          \"categories\": \"Sheet1!\$A\$2:\$A\$10\",
          \"values\": \"Sheet1!\$B\$2:\$B\$10\"
        }
      ]
    }
  }" \
  | jq .

# ── Add Chart With SQL Metadata ───────────────────────────────────────────────
echo "=== Add Column Chart With SQL Metadata ==="
curl -s -X POST "$BASE_URL/api/v1/excel/add_chart" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"uri\": \"$DOC_URI\",
    \"worksheet_name\": \"Sheet1\",
    \"cell\": \"M2\",
    \"chart\": {
      \"type\": \"col\",
      \"title\": \"Revenue By Region\",
      \"sql\": \"select \\\"Region\\\", sum(\\\"Revenue\\\") as \\\"Revenue\\\" from \\\"Sheet1\\\" group by \\\"Region\\\" order by \\\"Revenue\\\" desc\",
      \"format\": {
        \"from\": {\"col\": 12, \"row\": 1},
        \"to\": {\"col\": 19, \"row\": 16}
      }
    }
  }" \
  | jq .

# ── Add Gauge Chart ───────────────────────────────────────────────────────────
echo "=== Add Gauge Chart ==="
curl -s -X POST "$BASE_URL/api/v1/excel/add_chart" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"uri\": \"$DOC_URI\",
    \"worksheet_name\": \"Sheet1\",
    \"cell\": \"E20\",
    \"chart\": {
      \"type\": \"gauge\",
      \"title\": \"Quota Attainment\",
      \"series\": [
        {
          \"name\": \"Sheet1!\$B\$1\",
          \"categories\": \"Sheet1!\$A\$2:\$A\$3\",
          \"values\": \"Sheet1!\$B\$2:\$B\$3\"
        }
      ]
    }
  }" \
  | jq .

# ── Inspect Charts ────────────────────────────────────────────────────────────
echo "=== Read Sheet And Inspect Chart Metadata ==="
curl -s -X POST "$BASE_URL/api/v1/excel/read_sheet" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"uri\": \"$DOC_URI\",
    \"worksheet_name\": \"Sheet1\"
  }" \
  | jq '.formatting.charts'

# ── Edit Chart ────────────────────────────────────────────────────────────────
echo "=== Edit Chart By chart_id ==="
curl -s -X POST "$BASE_URL/api/v1/excel/set_chart" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"uri\": \"$DOC_URI\",
    \"worksheet_name\": \"Sheet1\",
    \"cell\": \"E2\",
    \"chart\": {
      \"chart_id\": \"$CHART_ID\",
      \"type\": \"col\",
      \"title\": \"Monthly Revenue Updated\",
      \"legend\": \"right\",
      \"x_axis_name\": \"Month\",
      \"y_axis_name\": \"Revenue\",
      \"sql\": \"select \\\"Month\\\", \\\"Revenue\\\" from \\\"Sheet1\\\"\",
      \"series\": [
        {
          \"name\": \"Sheet1!\$B\$1\",
          \"categories\": \"Sheet1!\$A\$2:\$A\$10\",
          \"values\": \"Sheet1!\$B\$2:\$B\$10\"
        }
      ],
      \"format\": {
        \"from\": {\"col\": 4, \"row\": 1},
        \"to\": {\"col\": 11, \"row\": 16}
      }
    }
  }" \
  | jq .

# ── Delete Chart ──────────────────────────────────────────────────────────────
echo "=== Delete Chart By chart_id ==="
curl -s -X POST "$BASE_URL/api/v1/excel/delete_chart" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"uri\": \"$DOC_URI\", \"worksheet_name\": \"Sheet1\", \"chart_id\": \"$CHART_ID\"}" \
  | jq .

# ── Add Picture ───────────────────────────────────────────────────────────────
echo "=== Add Picture ==="
curl -s -X POST "$BASE_URL/api/v1/excel/add_picture" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"uri\": \"$DOC_URI\",
    \"worksheet_name\": \"Sheet1\",
    \"cell\": \"H2\",
    \"picture\": {
      \"file_base64\": \"$PICTURE_FILE_BASE64\",
      \"extension\": \"png\"
    }
  }" \
  | jq .

# ── Read Pictures ─────────────────────────────────────────────────────────────
echo "=== Read Pictures ==="
curl -s -X POST "$BASE_URL/api/v1/excel/read_picture" \
  -H "Content-Type: application/json" \
  -d "{\"uri\": \"$DOC_URI\", \"worksheet_name\": \"Sheet1\", \"cell\": \"H2\"}" \
  | jq .

# ── Delete Picture ────────────────────────────────────────────────────────────
echo "=== Delete Picture ==="
curl -s -X POST "$BASE_URL/api/v1/excel/delete_picture" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"uri\": \"$DOC_URI\", \"worksheet_name\": \"Sheet1\", \"cell\": \"H2\"}" \
  | jq .
