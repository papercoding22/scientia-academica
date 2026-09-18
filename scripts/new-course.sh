#!/usr/bin/env bash
#
# new-course.sh — Tạo khung thư mục cho một môn học mới.
#
# Script này chỉ làm phần CƠ HỌC: tạo thư mục và render file từ templates/.
# Việc nối môn mới vào các file khác (README học kỳ, curriculum, schedule…)
# do skill `new-course` lo — xem .claude/skills/new-course/SKILL.md
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TPL="$REPO/templates"

# ── màu ──────────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  R=$'\033[31m'; G=$'\033[32m'; Y=$'\033[33m'; B=$'\033[1m'; N=$'\033[0m'
else
  R=''; G=''; Y=''; B=''; N=''
fi
die()  { printf '%s✗ %s%s\n' "$R" "$*" "$N" >&2; exit 1; }
ok()   { printf '%s✓%s %s\n' "$G" "$N" "$*"; }
warn() { printf '%s!%s %s\n' "$Y" "$N" "$*"; }

usage() {
  cat <<'USAGE'
new-course.sh — Tạo khung thư mục cho một môn học mới

CÁCH DÙNG
  scripts/new-course.sh --code IT007 --slug operating-systems \
                        --name "Hệ điều hành" --lecturer "Nguyễn Thanh Thiện" \
                        [--class-code IT007.F31.CN1.CNTT] \
                        [--name-en "Operating Systems"] \
                        [--semester 2025-2026-S3] [--dry-run]

THAM SỐ
  --code        BẮT BUỘC  Mã môn, vd IT007, IE105
  --slug        BẮT BUỘC  Tên thư mục tiếng Anh, kebab-case, vd operating-systems
  --name        BẮT BUỘC  Tên môn tiếng Việt, vd "Hệ điều hành"
  --lecturer    BẮT BUỘC  Tên giảng viên
  --class-code  Mã lớp đầy đủ. Mặc định: <CODE>.F31.CN1.CNTT
  --name-en     Tên tiếng Anh. Mặc định suy ra từ --slug
  --semester    Mã học kỳ. Mặc định: học kỳ mới nhất trong semesters/
  --dry-run     Chỉ in ra sẽ tạo gì, không ghi file
  -h, --help    In trợ giúp này

VÍ DỤ
  scripts/new-course.sh --code IT008 --slug computer-networks \
                        --name "Mạng máy tính" --lecturer "Trần Văn A"
USAGE
}

# ── đọc tham số ──────────────────────────────────────────────────────────────
CODE=""; SLUG=""; NAME_VI=""; LECTURER=""; CLASS_CODE=""; NAME_EN=""; SEMESTER=""; DRY=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --code)       CODE="${2:-}";       shift 2 ;;
    --slug)       SLUG="${2:-}";       shift 2 ;;
    --name)       NAME_VI="${2:-}";    shift 2 ;;
    --lecturer)   LECTURER="${2:-}";   shift 2 ;;
    --class-code) CLASS_CODE="${2:-}"; shift 2 ;;
    --name-en)    NAME_EN="${2:-}";    shift 2 ;;
    --semester)   SEMESTER="${2:-}";   shift 2 ;;
    --dry-run)    DRY=1;               shift   ;;
    -h|--help)    usage; exit 0 ;;
    *)            die "Tham số không hiểu: $1  (chạy --help để xem cách dùng)" ;;
  esac
done

# ── kiểm tra ─────────────────────────────────────────────────────────────────
[[ -n "$CODE"     ]] || { usage >&2; die "Thiếu --code"; }
[[ -n "$SLUG"     ]] || { usage >&2; die "Thiếu --slug"; }
[[ -n "$NAME_VI"  ]] || { usage >&2; die "Thiếu --name"; }
[[ -n "$LECTURER" ]] || { usage >&2; die "Thiếu --lecturer"; }

[[ "$CODE" =~ ^[A-Z]{2,4}[0-9]{3}$ ]] \
  || die "Mã môn '$CODE' sai định dạng. Cần dạng 2–4 chữ HOA + 3 số, vd IT007, IE105"

[[ "$SLUG" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] \
  || die "Slug '$SLUG' sai định dạng.
  Cần: tiếng Anh, chữ thường, không dấu, nối bằng dấu gạch (kebab-case).
  Đúng:  operating-systems, it-infrastructure
  Sai:   he-dieu-hanh (tiếng Việt), Operating_Systems (hoa + gạch dưới)"

# Bẫy dễ mắc nhất: viết tên tiếng Việt bỏ dấu. Nó vẫn đúng kebab-case nên regex
# ở trên không bắt được — chỉ cảnh báo, không chặn, vì có thể nhầm (vd "han" trong "hanoi").
VN_WORDS="he|dieu|hanh|mang|may|tinh|co|so|du|lieu|quan|ly|nhap|mon|lap|trinh|an|ninh|thong|tin|ha|tang|ky|thuat|phan|mem|giai|thuat|cau|truc|xac|suat|ke|dai|toan|hoc|bao|dam|tri|tue|nhan|tao|kien|chuc|nang|vien|web|ung|dung|phat|trien"
if printf '%s' "$SLUG" | tr '-' '\n' | grep -qxE "$VN_WORDS"; then
  warn "Slug '${B}$SLUG${N}' trông giống ${B}tiếng Việt bỏ dấu${N}."
  warn "  Quy ước của repo: tên đường dẫn phải là ${B}tiếng Anh${N}."
  warn "  vd: he-dieu-hanh → ${G}operating-systems${N}   co-so-du-lieu → ${G}databases${N}"
  warn "  Nếu cố ý thì bỏ qua cảnh báo này."
fi

# Học kỳ: mặc định lấy cái mới nhất trong semesters/
if [[ -z "$SEMESTER" ]]; then
  SEMESTER="$(ls -1 "$REPO/semesters" 2>/dev/null | sort -r | head -1 || true)"
  [[ -n "$SEMESTER" ]] || die "Không tìm thấy học kỳ nào trong semesters/. Dùng --semester để chỉ rõ."
  warn "Không có --semester, dùng học kỳ mới nhất: ${B}$SEMESTER${N}"
fi
[[ -d "$REPO/semesters/$SEMESTER" ]] \
  || die "Học kỳ '$SEMESTER' không tồn tại. Có: $(ls -1 "$REPO/semesters" | tr '\n' ' ')"

# Suy ra giá trị mặc định
[[ -n "$CLASS_CODE" ]] || CLASS_CODE="${CODE}.F31.CN1.CNTT"
if [[ -z "$NAME_EN" ]]; then
  NAME_EN="$(printf '%s' "$SLUG" | tr '-' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)}1')"
fi

# 2025-2026-S3 → HK3 2025–2026
if [[ "$SEMESTER" =~ ^([0-9]{4}-[0-9]{4})-S([0-9])$ ]]; then
  SEMESTER_VI="HK${BASH_REMATCH[2]} ${BASH_REMATCH[1]//-/–}"
else
  SEMESTER_VI="$SEMESTER"
fi

DIR="$REPO/semesters/$SEMESTER/${CODE}-${SLUG}"
REL="semesters/$SEMESTER/${CODE}-${SLUG}"

[[ -e "$DIR" ]] && die "Thư mục đã tồn tại: $REL
  Script này không ghi đè. Muốn tạo lại thì xoá thủ công trước."

# Cảnh báo nếu mã môn đã có ở học kỳ này với slug khác
EXISTING="$(find "$REPO/semesters/$SEMESTER" -maxdepth 1 -type d -name "${CODE}-*" 2>/dev/null | head -1 || true)"
[[ -n "$EXISTING" ]] && warn "Học kỳ này đã có môn mã $CODE: $(basename "$EXISTING")"

for t in course-readme important-notes flashcards cheatsheet materials-readme; do
  [[ -f "$TPL/$t.md" ]] || die "Thiếu template: templates/$t.md"
done

# ── render ───────────────────────────────────────────────────────────────────
TODAY="$(date +%F)"
esc() { printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'; }

render() {  # render <template> <đích>
  sed -e "s|{{CODE}}|$(esc "$CODE")|g" \
      -e "s|{{SLUG}}|$(esc "$SLUG")|g" \
      -e "s|{{NAME_VI}}|$(esc "$NAME_VI")|g" \
      -e "s|{{NAME_EN}}|$(esc "$NAME_EN")|g" \
      -e "s|{{LECTURER}}|$(esc "$LECTURER")|g" \
      -e "s|{{CLASS_CODE}}|$(esc "$CLASS_CODE")|g" \
      -e "s|{{SEMESTER}}|$(esc "$SEMESTER")|g" \
      -e "s|{{SEMESTER_VI}}|$(esc "$SEMESTER_VI")|g" \
      -e "s|{{TODAY}}|$(esc "$TODAY")|g" \
      "$TPL/$1.md" > "$2"
}

SUBDIRS=(
  materials/syllabus materials/slides materials/books materials/references
  lectures/_raw notes assignments projects research code exam-prep
)
# Thư mục cần .gitkeep (thư mục sẽ rỗng sau khi tạo)
KEEP=(
  materials/syllabus materials/slides materials/books materials/references
  lectures/_raw notes assignments projects research code
)

printf '\n%sTạo môn học%s\n' "$B" "$N"
printf '  Mã môn       %s\n' "$CODE"
printf '  Tên          %s\n' "$NAME_VI"
printf '  Tên tiếng Anh %s\n' "$NAME_EN"
printf '  Giảng viên   %s\n' "$LECTURER"
printf '  Mã lớp       %s\n' "$CLASS_CODE"
printf '  Học kỳ       %s  (%s)\n' "$SEMESTER" "$SEMESTER_VI"
printf '  Thư mục      %s\n\n' "$REL"

if [[ $DRY -eq 1 ]]; then
  printf '%s[dry-run] Sẽ tạo:%s\n' "$Y" "$N"
  for d in "${SUBDIRS[@]}"; do printf '  %s/%s/\n' "$REL" "$d"; done
  printf '  %s/README.md\n'                      "$REL"
  printf '  %s/IMPORTANT_NOTES.md\n'             "$REL"
  printf '  %s/materials/README.md\n'            "$REL"
  printf '  %s/exam-prep/flashcards.md\n'        "$REL"
  printf '  %s/exam-prep/flashcards.csv\n'       "$REL"
  printf '  %s/exam-prep/cheatsheet.md\n'        "$REL"
  printf '\n%s[dry-run] Chưa ghi gì cả.%s\n' "$Y" "$N"
  exit 0
fi

for d in "${SUBDIRS[@]}"; do mkdir -p "$DIR/$d"; done
for d in "${KEEP[@]}";    do : > "$DIR/$d/.gitkeep"; done

render course-readme    "$DIR/README.md"
render important-notes  "$DIR/IMPORTANT_NOTES.md"
render materials-readme "$DIR/materials/README.md"
render flashcards       "$DIR/exam-prep/flashcards.md"
render cheatsheet       "$DIR/exam-prep/cheatsheet.md"

# Anki cần UTF-8 BOM, nếu không sẽ vỡ dấu tiếng Việt
printf '\xEF\xBB\xBF#separator:semicolon\n#html:false\n#tags column:3\n' \
  > "$DIR/exam-prep/flashcards.csv"

ok "Đã tạo $(find "$DIR" -type d | wc -l | tr -d ' ') thư mục, $(find "$DIR" -type f ! -name .gitkeep | wc -l | tr -d ' ') file"
printf '   %s\n' "$REL"

# ── việc còn lại ─────────────────────────────────────────────────────────────
cat <<NEXT

${B}Script chỉ tạo khung. Còn 6 file khác đang giữ danh sách môn cần cập nhật:${N}

  semesters/$SEMESTER/README.md      bảng môn + bảng tiến độ + mục "gắn với nhau thế nào"
  admin/schedule.md                  bảng môn + lịch tuần
  admin/deadlines.md                 dòng lịch thi cho $CODE
  program/curriculum.md              trạng thái → 🔄 đang học
  program/transcript.md              dòng ở $SEMESTER_VI
  program/specialization/README.md   bảng cảm nhận từng môn

Và trong ${REL}/README.md còn mục "Môn này nói về cái gì" đang bỏ trống.

${B}Bảo AI làm nốt:${N}  /new-course $CODE
NEXT
