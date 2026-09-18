#!/usr/bin/env bash
#
# check-layout.sh — Tìm file đặt sai chỗ hoặc sai tên so với quy ước repo.
#
# CHỈ BÁO CÁO, không tự sửa. Việc quyết định file nào đi đâu cần đọc nội dung,
# đó là việc của skill `tidy-files` — xem .claude/skills/tidy-files/SKILL.md
#
set -uo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

usage() {
  cat <<'USAGE'
check-layout.sh — Tìm file đặt sai chỗ hoặc sai tên

CÁCH DÙNG
  scripts/check-layout.sh                 Quét toàn repo
  scripts/check-layout.sh --course IE105  Chỉ quét một môn
  scripts/check-layout.sh --quiet         Chỉ in số lượng vấn đề

Thoát 0 nếu sạch, 1 nếu có vấn đề.
USAGE
}

COURSE=""; QUIET=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --course) COURSE="$(printf '%s' "${2:-}" | tr '[:lower:]' '[:upper:]')"; shift 2 ;;
    --quiet)  QUIET=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "Tham số không hiểu: $1" ;;
  esac
done

ISSUES=0
report() {  # report <đường dẫn> <vấn đề> <cách sửa>
  ISSUES=$((ISSUES+1))
  [[ $QUIET -eq 1 ]] && return
  printf '\n%s%s%s\n' "$Y" "${1#$REPO/}" "$N"
  printf '   vấn đề : %s\n' "$2"
  printf '   nên là : %s\n' "$3"
}

SCOPE="$REPO/semesters"
[[ -n "$COURSE" ]] && SCOPE="$(find "$REPO/semesters" -maxdepth 2 -type d -name "${COURSE}-*" | head -1)"
[[ -d "${SCOPE:-}" ]] || die "Không tìm thấy môn '$COURSE'"

# ── 1. File nằm trơ trong thư mục chứa, đáng lẽ phải ở thư mục con ──────────
while IFS= read -r -d '' f; do
  b="$(basename "$f")"
  [[ "$b" == ".gitkeep" || "$b" == "README.md" || "$b" == ".DS_Store" ]] && continue
  report "$f" "File nằm trơ trong assignments/" \
         "Chuyển vào assignments/a<số bài>/ — vd a3a/, a4/"
done < <(find "$SCOPE" -type f -path '*/assignments/*' -not -path '*/assignments/*/*' -print0 2>/dev/null)

while IFS= read -r -d '' f; do
  b="$(basename "$f")"
  [[ "$b" == ".gitkeep" || "$b" == "README.md" || "$b" == ".DS_Store" ]] && continue
  report "$f" "File nằm trơ trong projects/" "Chuyển vào projects/prj<n>/"
done < <(find "$SCOPE" -type f -path '*/projects/*' -not -path '*/projects/*/*' -print0 2>/dev/null)

while IFS= read -r -d '' f; do
  b="$(basename "$f")"
  [[ "$b" == ".gitkeep" || "$b" == "README.md" || "$b" == ".DS_Store" ]] && continue
  report "$f" "File nằm trơ trong materials/" \
         "Chuyển vào materials/syllabus|slides|books|references/"
done < <(find "$SCOPE" -type f -path '*/materials/*' -not -path '*/materials/*/*' -print0 2>/dev/null)

# ── 2. Tên file trong lectures/_raw/ ────────────────────────────────────────
while IFS= read -r -d '' f; do
  b="$(basename "$f")"
  [[ "$b" == ".gitkeep" || "$b" == ".DS_Store" ]] && continue
  [[ "$b" =~ ^L[0-9]{2}-[0-9]{4}-[0-9]{2}-[0-9]{2}-(transcript|notes)\.[a-z]+$ ]] && continue
  report "$f" "Tên transcript không đúng quy ước" \
         "L<nn>-<YYYY-MM-DD>-transcript.<đuôi> — ngày lấy TỪ TRONG FILE, không đoán từ tên cũ"
done < <(find "$SCOPE" -type f -path '*/lectures/_raw/*' -print0 2>/dev/null)

# ── 3. Tên file note trong lectures/ ────────────────────────────────────────
while IFS= read -r -d '' f; do
  b="$(basename "$f")"
  [[ "$b" =~ ^L[0-9]{2}-[a-z0-9]+(-[a-z0-9]+)*\.md$ ]] && continue
  report "$f" "Tên note buổi học không đúng quy ước" \
         "L<nn>-<topic-tiếng-anh>.md — kebab-case, không dấu"
done < <(find "$SCOPE" -maxdepth 3 -type f -path '*/lectures/*' -not -path '*/_raw/*' -name '*.md' -print0 2>/dev/null)

# ── 4. Slide có tên vô nghĩa ────────────────────────────────────────────────
# KHÔNG đòi đổi slide đặt tên theo "Bài N" hay "L<nn>" — tên đó MANG THÔNG TIN
# (số chương của giảng viên). Chỉ báo những tên không nói lên điều gì.
while IFS= read -r -d '' f; do
  b="$(basename "$f")"
  [[ "$b" == ".gitkeep" ]] && continue
  # có cấu trúc rõ ràng → bỏ qua
  [[ "$b" =~ ^L[0-9]{2}- ]] && continue
  [[ "$b" =~ [Bb][aàAÀ]i[\ ._-] ]] && continue
  [[ "$b" =~ ^[Cc]h[uươƯƠ]*ng[\ ._-] ]] && continue
  # tên vô nghĩa điển hình
  if [[ "$b" =~ ^([Pp]resentation|[Ss]lide|[Uu]ntitled|[Dd]ocument|[Tt]ai\ lieu|[Nn]ew)[0-9\ _-]*\.[a-zA-Z]+$ ]] \
     || [[ "$b" =~ ^[0-9]+\.[a-zA-Z]+$ ]]; then
    report "$f" "Tên slide không nói lên nội dung" \
           "Đặt tên mô tả: L<nn>-<chu-de>.pdf hoặc giữ cách đánh số của giảng viên (Bài N - …)"
  fi
done < <(find "$SCOPE" -type f -path '*/materials/slides/*' -print0 2>/dev/null)

# ── 5. Thư mục bài tập thiếu khung ──────────────────────────────────────────
while IFS= read -r -d '' d; do
  miss=()
  [[ -f "$d/README.md" ]] || miss+=("README.md")
  for sub in brief resources images; do [[ -d "$d/$sub" ]] || miss+=("$sub/"); done
  [[ ${#miss[@]} -eq 0 ]] && continue
  report "$d" "Thư mục bài tập thiếu: ${miss[*]}" "Tạo đủ README.md, brief/, resources/, images/"
done < <(find "$SCOPE" -type d -regex '.*/assignments/a[^/]*' -print0 2>/dev/null)

# ── 6. Tên đường dẫn có dấu tiếng Việt hoặc khoảng trắng ────────────────────
# NGOẠI LỆ: file nộp nằm trực tiếp trong aN/ hoặc prjN/ — giữ nguyên mẫu giảng viên yêu cầu
while IFS= read -r -d '' f; do
  b="$(basename "$f")"
  [[ "$b" == ".DS_Store" ]] && continue
  # Bỏ qua mọi file dưới assignments/ và projects/ (trừ README.md): chúng là bài nộp
  # hoặc sẽ thành bài nộp, mà bài nộp giữ nguyên mẫu tên giảng viên yêu cầu.
  # Vị trí sai của chúng đã được mục 1 báo rồi, không cần báo tên thêm lần nữa.
  if [[ "$f" == */assignments/* || "$f" == */projects/* ]]; then
    [[ "$b" != "README.md" ]] && continue
  fi
  # bỏ qua materials/ — giữ tên gốc của giảng viên là có chủ ý
  [[ "$f" == */materials/* ]] && continue
  if [[ "$b" =~ [^\ -~] || "$b" =~ \  ]]; then
    report "$f" "Tên file có dấu tiếng Việt hoặc khoảng trắng" \
           "Đổi sang tiếng Anh kebab-case. (File nộp và materials/ được miễn)"
  fi
done < <(find "$SCOPE" -type f -print0 2>/dev/null)

# ── kết luận ────────────────────────────────────────────────────────────────
echo
if [[ $ISSUES -eq 0 ]]; then
  ok "Không có vấn đề nào${COURSE:+ trong $COURSE}"
  exit 0
fi
printf '%s%s vấn đề%s%s\n' "$B" "$ISSUES" "${COURSE:+ trong $COURSE}" "$N"
printf '\nSửa bằng: %s/tidy-files%s  — AI sẽ đọc nội dung từng file để biết nó đi đâu.\n' "$B" "$N"
printf 'Xem nhanh nội dung một file: %sscripts/peek.py <file>%s\n' "$B" "$N"
exit 1
