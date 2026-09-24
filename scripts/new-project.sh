#!/usr/bin/env bash
#
# new-project.sh — Tạo khung thư mục cho một đồ án môn học mới.
#
# Làm phần CƠ HỌC: dựng projects/prjN/, render README từ templates/project.md,
# copy template Word khi đã biết tên file nộp (.docx).
#
# Phần CẦN PHÁN ĐOÁN (tìm đề bài, tiêu chí chấm, mốc thời gian, nối vào deadlines
# và Notion) do skill `new-project` lo — xem .claude/skills/new-project/SKILL.md
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TPL="$REPO/templates"
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

usage() {
  cat <<'USAGE'
new-project.sh — Tạo khung thư mục cho một đồ án môn học

CÁCH DÙNG
  scripts/new-project.sh --course IE101 --num 1 [--title "..."] [--due 2026-11-15]
                         [--lecture L03] [--team | --solo]
                         [--submission "<tên file nộp giảng viên quy định>"]
                         [--semester 2025-2026-S3] [--dry-run]

THAM SỐ
  --course      BẮT BUỘC  Mã môn, vd IE101
  --num         BẮT BUỘC  Số đồ án giảng viên đặt: 1, 2, 1A
  --title       Tên đồ án / đề tài
  --due         Hạn nộp cuối YYYY-MM-DD
  --lecture     Buổi giao đồ án, vd L03
  --team        Làm nhóm
  --solo        Làm cá nhân
  --submission  Tên file nộp. Không có → để ❓ (KHÔNG đoán — AGENTS.md § 13.3).
                Đuôi .docx → copy templates/ASSIGNMENT_TEMPLATE.docx vào docs/
  --semester    Mã học kỳ. Mặc định: học kỳ mới nhất
  --dry-run     Chỉ in ra sẽ làm gì
  -h, --help    Trợ giúp

VÍ DỤ
  scripts/new-project.sh --course IE101 --num 1 --team \
      --title "Thiết kế hạ tầng mạng cho doanh nghiệp vừa" --due 2026-11-15 --lecture L03
USAGE
}

COURSE=""; NUM=""; TITLE=""; DUE=""; LECTURE=""; MODE=""; SUBMISSION=""; SEMESTER=""
DRY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --course)     COURSE="${2:-}";     shift 2 ;;
    --num)        NUM="${2:-}";        shift 2 ;;
    --title)      TITLE="${2:-}";      shift 2 ;;
    --due)        DUE="${2:-}";        shift 2 ;;
    --lecture)    LECTURE="${2:-}";    shift 2 ;;
    --team)       MODE="Nhóm";         shift   ;;
    --solo)       MODE="Cá nhân";      shift   ;;
    --submission) SUBMISSION="${2:-}"; shift 2 ;;
    --semester)   SEMESTER="${2:-}";   shift 2 ;;
    --dry-run)    DRY=1;               shift   ;;
    -h|--help)    usage; exit 0 ;;
    *) die "Tham số không hiểu: $1  (chạy --help)" ;;
  esac
done

[[ -n "$COURSE" ]] || { usage >&2; die "Thiếu --course"; }
[[ -n "$NUM"    ]] || { usage >&2; die "Thiếu --num"; }
COURSE="$(printf '%s' "$COURSE" | tr '[:lower:]' '[:upper:]')"
NUM="$(printf '%s' "$NUM" | tr '[:lower:]' '[:upper:]')"
[[ "$NUM" =~ ^[0-9]{1,2}[A-Z]?$ ]] \
  || die "--num '$NUM' sai định dạng. Cần: số, kèm chữ cái phần nếu có.
  Đúng: 1, 2, 1A    Sai: prj1, DA1, do-an-1"
FOLDER="prj$(printf '%s' "$NUM" | tr '[:upper:]' '[:lower:]')"

# ── tìm môn ─────────────────────────────────────────────────────────────────
SEMESTER="$(resolve_semester "$REPO" "$SEMESTER")"
MATCHES=$(find "$REPO/semesters/$SEMESTER" -maxdepth 1 -type d -name "${COURSE}-*" | sort)
COUNT=$(printf '%s' "$MATCHES" | grep -c . || true)
[[ "$COUNT" -eq 0 ]] && die "Không có môn '$COURSE' trong $SEMESTER.
  Các môn đang có: $(ls -1 "$REPO/semesters/$SEMESTER" | grep -v '\.md$' | tr '\n' ' ')"
[[ "$COUNT" -gt 1 ]] && die "Mơ hồ: '$COURSE' khớp nhiều môn:
$MATCHES"
CDIR="$MATCHES"; CREL="${CDIR#$REPO/}"
DIR="$CDIR/projects/$FOLDER"

[[ -e "$DIR" ]] && die "Thư mục đã tồn tại: $CREL/projects/$FOLDER
  Script không ghi đè."

NAME_VI="$(sed -n '1s/^# [A-Z0-9]* — //p' "$CDIR/README.md" 2>/dev/null || true)"
[[ -n "$NAME_VI" ]] || NAME_VI="$COURSE"

TEMPLATE="$TPL/ASSIGNMENT_TEMPLATE.docx"
COPYDOC=0
if [[ "$SUBMISSION" == *.docx ]]; then
  if [[ -f "$TEMPLATE" ]]; then COPYDOC=1; else warn "Không thấy $TEMPLATE — bỏ qua bước copy"; fi
fi

[[ -n "$TITLE"   ]] || TITLE="❓ chưa đặt tên"
[[ -n "$DUE"     ]] || DUE="❓ chưa biết"
[[ -n "$LECTURE" ]] || LECTURE="❓"
[[ -n "$MODE"    ]] || MODE="❓"
[[ "$DUE" == "❓ chưa biết" || "$DUE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] \
  || die "--due phải dạng YYYY-MM-DD, nhận được '$DUE'"

# ── in kế hoạch ─────────────────────────────────────────────────────────────
printf '\n%sTạo Đồ án %s%s\n' "$B" "$NUM" "$N"
printf '  Môn        %s  %s\n' "$COURSE" "$NAME_VI"
printf '  Thư mục    %s%s%s\n' "$B" "$FOLDER" "$N"
printf '  Tên        %s\n' "$TITLE"
printf '  Hạn nộp    %s\n' "$DUE"
printf '  Buổi giao  %s\n' "$LECTURE"
printf '  Hình thức  %s\n' "$MODE"
if [[ -n "$SUBMISSION" ]]; then
  printf '  File nộp   %s\n' "$SUBMISSION"
  [[ $COPYDOC -eq 1 ]] && printf '             %s(copy template Word vào docs/)%s\n' "$Y" "$N"
else
  printf '  File nộp   %s❓ chưa xác nhận — không đoán%s\n' "$Y" "$N"
fi
echo

if [[ $DRY -eq 1 ]]; then
  printf '%s[dry-run] Sẽ tạo:%s\n' "$Y" "$N"
  printf '  %s/projects/%s/README.md\n' "$CREL" "$FOLDER"
  for d in brief docs src images; do printf '  %s/projects/%s/%s/\n' "$CREL" "$FOLDER" "$d"; done
  [[ $COPYDOC -eq 1 ]] && printf '  %s/projects/%s/docs/%s\n' "$CREL" "$FOLDER" "$SUBMISSION"
  printf '\n%s[dry-run] Chưa ghi gì cả.%s\n' "$Y" "$N"
  exit 0
fi

# ── tạo ─────────────────────────────────────────────────────────────────────
for d in brief docs src images; do mkdir -p "$DIR/$d"; : > "$DIR/$d/.gitkeep"; done

sed -e "s|{{CODE}}|$(esc "$COURSE")|g" \
    -e "s|{{NAME_VI}}|$(esc "$NAME_VI")|g" \
    -e "s|{{NUM}}|$(esc "$NUM")|g" \
    -e "s|{{TITLE}}|$(esc "$TITLE")|g" \
    -e "s|{{DUE}}|$(esc "$DUE")|g" \
    -e "s|{{LECTURE}}|$(esc "$LECTURE")|g" \
    -e "s|{{MODE}}|$(esc "$MODE")|g" \
    -e "s|{{SUBMISSION}}|$(esc "${SUBMISSION:-❓ chưa xác nhận}")|g" \
    "$TPL/project.md" > "$DIR/README.md"
ok "Tạo $CREL/projects/$FOLDER/README.md"

if [[ $COPYDOC -eq 1 ]]; then
  cp "$TEMPLATE" "$DIR/docs/$SUBMISSION"
  ok "Copy template Word → docs/$SUBMISSION"
fi

cat <<NEXT

${B}Còn lại:${N}

  1. Ghi hạn nộp (và mốc giảng viên đặt) vào ${B}admin/deadlines.md${N}
  2. Thêm dòng vào bảng "Bài tập và đồ án" trong ${B}$CREL/README.md${N}
  3. Bỏ file đề bài của giảng viên vào ${B}$FOLDER/brief/${N}
  4. Điền "Đề bài" và "Tiêu chí chấm" — thường có trong transcript buổi giao đồ án

  ${B}Bảo AI làm nốt:  /new-project $COURSE $NUM${N}
NEXT
