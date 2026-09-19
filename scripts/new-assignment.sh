#!/usr/bin/env bash
#
# new-assignment.sh — Tạo khung thư mục cho một bài tập mới.
#
# Làm phần CƠ HỌC: dựng aN/, labN/ hoặc <prefix>N/, render README, copy sẵn file nộp từ template Word
# với đúng mẫu tên giảng viên yêu cầu.
#
# Phần CẦN PHÁN ĐOÁN (trích đề bài từ transcript, cập nhật bảng tham chiếu)
# do skill `new-assignment` lo — xem .claude/skills/new-assignment/SKILL.md
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TPL="$REPO/templates"
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

usage() {
  cat <<'USAGE'
new-assignment.sh — Tạo khung thư mục cho một mục nộp mới

CÁCH DÙNG
  scripts/new-assignment.sh --course IE105 --num 8 [--prefix a] [--title "..."]
                            [--due 2026-09-25] [--lecture L08]
                            [--submission "Bài tập 8_Họ tên_MSSV.docx"]
                            [--semester 2025-2026-S3] [--no-doc] [--dry-run]

THAM SỐ
  --course      BẮT BUỘC  Mã môn, vd IE105
  --num         BẮT BUỘC  Số giảng viên đặt: 8, 3A, 12B
  --prefix      Tiền tố thư mục, mặc định a. Ví dụ: a → a3a; lab → lab3; quiz → quiz2
  --title       Tên mục nộp
  --due         Hạn nộp YYYY-MM-DD
  --lecture     Buổi học liên quan, vd L08
  --submission  Tên file nộp. Không có → suy ra từ mục cùng loại đã nộp trong cùng môn
  --no-doc      Không copy template Word
  --semester    Mã học kỳ. Mặc định: học kỳ mới nhất
  --dry-run     Chỉ in ra sẽ làm gì
  -h, --help    Trợ giúp

VÍ DỤ
  scripts/new-assignment.sh --course IE105 --num 8 \
      --title "Bảo mật ứng dụng web" --due 2026-09-25 --lecture L08
  scripts/new-assignment.sh --course IE105 --prefix lab --num 3 \
      --title "Dò tìm mật khẩu bằng tấn công chủ động" --due 2026-09-02 --lecture L07 --no-doc
USAGE
}

COURSE=""; NUM=""; PREFIX="a"; TITLE=""; DUE=""; LECTURE=""; SUBMISSION=""; SEMESTER=""
NODOC=0; DRY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --course)     COURSE="${2:-}";     shift 2 ;;
    --num)        NUM="${2:-}";        shift 2 ;;
    --prefix)     PREFIX="${2:-}";     shift 2 ;;
    --title)      TITLE="${2:-}";      shift 2 ;;
    --due)        DUE="${2:-}";        shift 2 ;;
    --lecture)    LECTURE="${2:-}";    shift 2 ;;
    --submission) SUBMISSION="${2:-}"; shift 2 ;;
    --semester)   SEMESTER="${2:-}";   shift 2 ;;
    --no-doc)     NODOC=1;             shift   ;;
    --dry-run)    DRY=1;               shift   ;;
    -h|--help)    usage; exit 0 ;;
    *) die "Tham số không hiểu: $1  (chạy --help)" ;;
  esac
done

[[ -n "$COURSE" ]] || { usage >&2; die "Thiếu --course"; }
[[ -n "$NUM"    ]] || { usage >&2; die "Thiếu --num"; }
COURSE="$(printf '%s' "$COURSE" | tr '[:lower:]' '[:upper:]')"

# Số bài: chữ số, có thể kèm một chữ cái phần (3A, 12B)
NUM="$(printf '%s' "$NUM" | tr '[:lower:]' '[:upper:]')"
[[ "$NUM" =~ ^[0-9]{1,2}[A-Z]?$ ]] \
  || die "--num '$NUM' sai định dạng. Cần: số, kèm chữ cái phần nếu có.
  Đúng: 1, 8, 3A, 12B    Sai: BT8, bai-8, 3-A"
PREFIX="$(printf '%s' "$PREFIX" | tr '[:upper:]' '[:lower:]')"
[[ "$PREFIX" =~ ^[a-z][a-z0-9-]*$ ]] \
  || die "--prefix '$PREFIX' sai định dạng. Dùng chữ thường, số, gạch nối; ví dụ a, lab, quiz."
FOLDER="${PREFIX}$(printf '%s' "$NUM" | tr '[:upper:]' '[:lower:]')"
case "$PREFIX" in
  a)   ITEM_LABEL="Bài tập" ;;
  lab) ITEM_LABEL="Bài thực hành" ;;
  *)   ITEM_LABEL="Mục nộp" ;;
esac

# ── tìm môn ─────────────────────────────────────────────────────────────────
SEMESTER="$(resolve_semester "$REPO" "$SEMESTER")"
MATCHES=$(find "$REPO/semesters/$SEMESTER" -maxdepth 1 -type d -name "${COURSE}-*" | sort)
COUNT=$(printf '%s' "$MATCHES" | grep -c . || true)
[[ "$COUNT" -eq 0 ]] && die "Không có môn '$COURSE' trong $SEMESTER.
  Các môn đang có: $(ls -1 "$REPO/semesters/$SEMESTER" | grep -v '\.md$' | tr '\n' ' ')"
[[ "$COUNT" -gt 1 ]] && die "Mơ hồ: '$COURSE' khớp nhiều môn:
$MATCHES"
CDIR="$MATCHES"; CREL="${CDIR#$REPO/}"
DIR="$CDIR/assignments/$FOLDER"

[[ -e "$DIR" ]] && die "Thư mục đã tồn tại: $CREL/assignments/$FOLDER
  Script không ghi đè."

NAME_VI="$(sed -n '1s/^# [A-Z0-9]* — //p' "$CDIR/README.md" 2>/dev/null || true)"
[[ -n "$NAME_VI" ]] || NAME_VI="$COURSE"

# ── suy ra tên file nộp từ bài đã nộp trong cùng môn ─────────────────────────
# Mẫu tên do GIẢNG VIÊN quy định, mỗi môn mỗi khác (AGENTS.md § 13.3).
# Chỉ bắt chước mục cùng loại (cùng prefix) của chính môn này.
INFERRED=""
if [[ -z "$SUBMISSION" && $NODOC -eq 0 ]]; then
  while IFS= read -r -d '' f; do
    b="$(basename "$f")"
    [[ "$b" == "README.md" || "$b" == ".gitkeep" || "$b" == ".DS_Store" ]] && continue
    prev_folder="$(basename "$(dirname "$f")")"
    [[ "$prev_folder" == "$PREFIX"* ]] || continue
    prev_num="${prev_folder#$PREFIX}"
    [[ "$prev_num" =~ ^[0-9]{1,2}[a-z]?$ ]] || continue
    # thay số bài cũ bằng số mới, giữ nguyên phần còn lại của mẫu tên
    cand="$(printf '%s' "$b" | sed -E "s/${prev_num}/${NUM}/I")"
    if [[ "$cand" != "$b" ]]; then
      SUBMISSION="${cand%.*}.${b##*.}"; INFERRED="$b"
      break
    fi
  done < <(find "$CDIR/assignments" -mindepth 2 -maxdepth 2 -type f -print0 2>/dev/null | sort -z)
fi

TEMPLATE="$TPL/ASSIGNMENT_TEMPLATE.docx"
if [[ $NODOC -eq 0 ]]; then
  [[ -f "$TEMPLATE" ]] || { warn "Không thấy $TEMPLATE — bỏ qua bước copy"; NODOC=1; }
fi
if [[ $NODOC -eq 0 && -z "$SUBMISSION" ]]; then
  warn "Chưa biết mẫu tên file nộp cùng loại '$PREFIX' của môn $COURSE."
  warn "  Tra mẫu ở IMPORTANT_NOTES.md mục 4 của môn, rồi chạy lại với --submission"
  warn "  Bỏ qua bước copy template Word."
  NODOC=1
fi

[[ -n "$TITLE"   ]] || TITLE="❓ chưa đặt tên"
[[ -n "$DUE"     ]] || DUE="❓ chưa biết"
[[ -n "$LECTURE" ]] || LECTURE="❓"
[[ "$DUE" == "❓ chưa biết" || "$DUE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] \
  || die "--due phải dạng YYYY-MM-DD, nhận được '$DUE'"

# ── in kế hoạch ─────────────────────────────────────────────────────────────
printf '\n%sTạo %s%s\n' "$B" "$ITEM_LABEL" "$N"
printf '  Môn        %s  %s\n' "$COURSE" "$NAME_VI"
printf '  Mục nộp   %s  →  thư mục %s%s%s\n' "$NUM" "$B" "$FOLDER" "$N"
printf '  Tên bài    %s\n' "$TITLE"
printf '  Hạn nộp    %s\n' "$DUE"
printf '  Buổi học   %s\n' "$LECTURE"
if [[ $NODOC -eq 0 ]]; then
  printf '  File nộp   %s\n' "$SUBMISSION"
  [[ -n "$INFERRED" ]] && printf '             %s(suy ra từ: %s)%s\n' "$Y" "$INFERRED" "$N"
else
  printf '  File nộp   %s(không copy template)%s\n' "$Y" "$N"
fi
echo

if [[ $DRY -eq 1 ]]; then
  printf '%s[dry-run] Sẽ tạo:%s\n' "$Y" "$N"
  printf '  %s/assignments/%s/README.md\n' "$CREL" "$FOLDER"
  for d in brief resources images; do printf '  %s/assignments/%s/%s/\n' "$CREL" "$FOLDER" "$d"; done
  [[ $NODOC -eq 0 ]] && printf '  %s/assignments/%s/%s\n' "$CREL" "$FOLDER" "$SUBMISSION"
  printf '\n%s[dry-run] Chưa ghi gì cả.%s\n' "$Y" "$N"
  exit 0
fi

# ── tạo ─────────────────────────────────────────────────────────────────────
for d in brief resources images; do mkdir -p "$DIR/$d"; : > "$DIR/$d/.gitkeep"; done

sed -e "s|{{CODE}}|$(esc "$COURSE")|g" \
    -e "s|{{NAME_VI}}|$(esc "$NAME_VI")|g" \
    -e "s|{{NUM}}|$(esc "$NUM")|g" \
    -e "s|{{ITEM_LABEL}}|$(esc "$ITEM_LABEL")|g" \
    -e "s|{{FOLDER}}|$(esc "$FOLDER")|g" \
    -e "s|{{TITLE}}|$(esc "$TITLE")|g" \
    -e "s|{{DUE}}|$(esc "$DUE")|g" \
    -e "s|{{LECTURE}}|$(esc "$LECTURE")|g" \
    -e "s|{{SUBMISSION}}|$(esc "${SUBMISSION:-❓ chưa có}")|g" \
    "$TPL/assignment.md" > "$DIR/README.md"
ok "Tạo $CREL/assignments/$FOLDER/README.md"

if [[ $NODOC -eq 0 ]]; then
  cp "$TEMPLATE" "$DIR/$SUBMISSION"
  ok "Copy template Word → $SUBMISSION"
fi

cat <<NEXT

${B}Còn lại:${N}

  1. Ghi hạn nộp vào ${B}admin/deadlines.md${N}
  2. Thêm dòng vào bảng "Bài tập và đồ án" trong ${B}$CREL/README.md${N}
  3. Bỏ file đề bài của giảng viên vào ${B}$FOLDER/brief/${N}
  4. Điền mục "Yêu cầu đề bài" trong README — đề bài thường có trong
     transcript buổi học, ở ${B}$CREL/lectures/_raw/${N}

  ${B}Bảo AI làm nốt:  /new-assignment $COURSE --prefix $PREFIX $NUM${N}
NEXT
