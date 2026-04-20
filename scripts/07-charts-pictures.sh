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
DATA_SHEET="${DATA_SHEET:-Sheet1}"
DASHBOARD_SHEET="${DASHBOARD_SHEET:-Dashboard}"
CHART_ID="${CHART_ID:-visitors-trend-chart-1}"
SQL_CHART_ID="${SQL_CHART_ID:-revenue-by-region-chart-1}"
GAUGE_CHART_ID="${GAUGE_CHART_ID:-revenue-kpi-gauge-1}"

# Notes:
# - If you need to create the dashboard sheet first, call write_new_worksheet
#   with only worksheet_name. Do not pass values unless you want to write cells.
# - Sheet charts should prefer chart.sql and omit chart.series.
# - This script demonstrates a compact dashboard layout:
#   gauge KPI at B2, full-width trend at B18, and a 6-column comparison chart at H34.

# ── Add Chart ─────────────────────────────────────────────────────────────────
# Supported types include: line, bar, col, pie, scatter, area, doughnut,
# radar, bubble, gauge, plus stacked/3D variants.
echo "=== Add Gauge KPI Chart ==="
curl -s -X POST "$BASE_URL/api/v1/excel/add_chart" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"uri\": \"$DOC_URI\",
    \"worksheet_name\": \"$DASHBOARD_SHEET\",
    \"cell\": \"B2\",
    \"chart\": {
      \"chart_id\": \"$GAUGE_CHART_ID\",
      \"type\": \"gauge\",
      \"title\": \"Revenue KPI\",
      \"legend\": \"none\",
      \"width\": 303,
      \"height\": 216,
      \"sql\": \"select sum(\\\"Revenue\\\") from \\\"$DATA_SHEET\\\"\",
      \"format\": {
        \"from\": {\"col\": 1, \"col_off\": 0, \"row\": 1, \"row_off\": 0},
        \"to\": {\"col\": 4, \"col_off\": 76, \"row\": 8, \"row_off\": 0},
        \"lock_aspect_ratio\": true,
        \"offset_x\": 0,
        \"offset_y\": 0,
        \"scale_x\": 1,
        \"scale_y\": 1
      }
    }
  }" \
  | jq .

# ── Add Full-Width Trend Chart ────────────────────────────────────────────────
echo "=== Add Full-Width Trend Chart ==="
curl -s -X POST "$BASE_URL/api/v1/excel/add_chart" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"uri\": \"$DOC_URI\",
    \"worksheet_name\": \"$DASHBOARD_SHEET\",
    \"cell\": \"B18\",
    \"chart\": {
      \"chart_id\": \"$CHART_ID\",
      \"type\": \"line\",
      \"title\": \"Monthly Revenue Trend\",
      \"legend\": \"bottom\",
      \"x_axis_name\": \"Month\",
      \"y_axis_name\": \"Revenue\",
      \"width\": 1212,
      \"height\": 432,
      \"show_blanks\": \"gap\",
      \"sql\": \"select \\\"Month\\\", sum(\\\"Revenue\\\") as \\\"Revenue\\\" from \\\"$DATA_SHEET\\\" group by \\\"Month\\\" order by \\\"Month\\\"\",
      \"format\": {
        \"from\": {\"col\": 1, \"col_off\": 0, \"row\": 17, \"row_off\": 0},
        \"to\": {\"col\": 12, \"col_off\": 76, \"row\": 32, \"row_off\": 0},
        \"lock_aspect_ratio\": true,
        \"offset_x\": 0,
        \"offset_y\": 0,
        \"scale_x\": 1,
        \"scale_y\": 1
      }
    }
  }" \
  | jq .

# ── Add Side-By-Side Comparison Chart With SQL Metadata ──────────────────────
echo "=== Add Comparison Chart With SQL Metadata ==="
curl -s -X POST "$BASE_URL/api/v1/excel/add_chart" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"uri\": \"$DOC_URI\",
    \"worksheet_name\": \"$DASHBOARD_SHEET\",
    \"cell\": \"H34\",
    \"chart\": {
      \"chart_id\": \"$SQL_CHART_ID\",
      \"type\": \"col\",
      \"title\": \"Revenue By Region\",
      \"legend\": \"bottom\",
      \"x_axis_name\": \"Region\",
      \"y_axis_name\": \"Revenue\",
      \"width\": 606,
      \"height\": 432,
      \"sql\": \"select \\\"Region\\\", sum(\\\"Revenue\\\") as \\\"Revenue\\\" from \\\"$DATA_SHEET\\\" group by \\\"Region\\\" order by \\\"Revenue\\\" desc\",
      \"format\": {
        \"from\": {\"col\": 7, \"col_off\": 0, \"row\": 33, \"row_off\": 0},
        \"to\": {\"col\": 12, \"col_off\": 76, \"row\": 48, \"row_off\": 0},
        \"lock_aspect_ratio\": true,
        \"offset_x\": 0,
        \"offset_y\": 0,
        \"scale_x\": 1,
        \"scale_y\": 1
      }
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
    \"worksheet_name\": \"$DASHBOARD_SHEET\"
  }" \
  | jq '.formatting.charts'

# ── Edit Chart ────────────────────────────────────────────────────────────────
echo "=== Edit Trend Chart By chart_id ==="
curl -s -X POST "$BASE_URL/api/v1/excel/set_chart" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"uri\": \"$DOC_URI\",
    \"worksheet_name\": \"$DASHBOARD_SHEET\",
    \"cell\": \"B18\",
    \"chart\": {
      \"chart_id\": \"$CHART_ID\",
      \"type\": \"line\",
      \"title\": \"Monthly Revenue Trend Updated\",
      \"legend\": \"top\",
      \"x_axis_name\": \"Month\",
      \"y_axis_name\": \"Revenue\",
      \"width\": 1212,
      \"height\": 432,
      \"show_blanks\": \"gap\",
      \"sql\": \"select \\\"Month\\\", sum(\\\"Revenue\\\") as \\\"Revenue\\\" from \\\"$DATA_SHEET\\\" group by \\\"Month\\\" order by \\\"Month\\\"\",
      \"format\": {
        \"from\": {\"col\": 1, \"col_off\": 0, \"row\": 17, \"row_off\": 0},
        \"to\": {\"col\": 12, \"col_off\": 76, \"row\": 32, \"row_off\": 0},
        \"lock_aspect_ratio\": true,
        \"offset_x\": 0,
        \"offset_y\": 0,
        \"scale_x\": 1,
        \"scale_y\": 1
      }
    }
  }" \
  | jq .

# ── Delete Chart ──────────────────────────────────────────────────────────────
echo "=== Delete Comparison Chart By chart_id ==="
curl -s -X POST "$BASE_URL/api/v1/excel/delete_chart" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"uri\": \"$DOC_URI\", \"worksheet_name\": \"$DASHBOARD_SHEET\", \"chart_id\": \"$SQL_CHART_ID\"}" \
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
