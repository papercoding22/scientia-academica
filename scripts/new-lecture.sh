#!/usr/bin/env bash
#
# new-lecture.sh — Tạo file buổi học mới trong lectures/ của một môn.
#
# Làm phần CƠ HỌC: tìm số buổi tiếp theo, tạo file _raw đúng quy ước tên,
# chuyển .vtt của Teams sang markdown đọc được, render khung note.
#
# Phần ĐỌC HIỂU NỘI DUNG (viết note, trích gợi ý thi, sinh flashcard)
# do skill `new-lecture` lo — xem .claude/skills/new-lecture/SKILL.md
#
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TPL="$REPO/templates"
source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"

usage() {
  cat <<'USAGE'
new-lecture.sh — Tạo file buổi học mới

CÁCH DÙNG
  scripts/new-lecture.sh --course IT007 [--from ~/Downloads/transcript.vtt]
                         [--number 3] [--date 2026-10-06] [--topic cpu-scheduling]
                         [--semester 2025-2026-S3] [--dry-run]

THAM SỐ
  --course    BẮT BUỘC  Mã môn, vd IT007, IE105
  --from      File transcript tải từ Teams (.vtt .txt .md). .vtt sẽ được
              chuyển sang markdown có timestamp và gộp theo người nói
  --number    Số buổi. Mặc định: buổi lớn nhất đang có + 1
  --date      Ngày học YYYY-MM-DD. Mặc định: hôm nay
  --topic     Slug chủ đề tiếng Anh, vd cpu-scheduling.
              CÓ  → tạo luôn khung note lectures/L<nn>-<topic>.md
              KHÔNG → chỉ tạo file _raw, note để AI đặt tên sau khi đọc nội dung
  --semester  Mã học kỳ. Mặc định: học kỳ mới nhất
  --dry-run   Chỉ in ra sẽ làm gì
  -h, --help  Trợ giúp

VÍ DỤ
  # Trước buổi học: tạo sẵn chỗ để dán transcript
  scripts/new-lecture.sh --course IT007

  # Sau buổi học: nạp thẳng file .vtt tải từ Teams
  scripts/new-lecture.sh --course IT007 --from ~/Downloads/meeting.vtt --date 2026-10-06
USAGE
}

COURSE=""; FROM=""; NUM=""; DATE=""; TOPIC=""; SEMESTER=""; DRY=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --course)   COURSE="${2:-}";   shift 2 ;;
    --from)     FROM="${2:-}";     shift 2 ;;
    --number)   NUM="${2:-}";      shift 2 ;;
    --date)     DATE="${2:-}";     shift 2 ;;
    --topic)    TOPIC="${2:-}";    shift 2 ;;
    --semester) SEMESTER="${2:-}"; shift 2 ;;
    --dry-run)  DRY=1;             shift   ;;
    -h|--help)  usage; exit 0 ;;
    *)          die "Tham số không hiểu: $1  (chạy --help)" ;;
  esac
done

[[ -n "$COURSE" ]] || { usage >&2; die "Thiếu --course"; }
COURSE="$(printf '%s' "$COURSE" | tr '[:lower:]' '[:upper:]')"

# ── tìm thư mục môn ──────────────────────────────────────────────────────────
SEMESTER="$(resolve_semester "$REPO" "$SEMESTER")"

MATCHES=$(find "$REPO/semesters/$SEMESTER" -maxdepth 1 -type d -name "${COURSE}-*" | sort)
COUNT=$(printf '%s' "$MATCHES" | grep -c . || true)
[[ "$COUNT" -eq 0 ]] && die "Không có môn '$COURSE' trong $SEMESTER.
  Các môn đang có: $(ls -1 "$REPO/semesters/$SEMESTER" | grep -v '\.md$' | tr '\n' ' ')
  Môn chưa tạo? Dùng skill /new-course"
[[ "$COUNT" -gt 1 ]] && die "Mơ hồ: '$COURSE' khớp nhiều môn:
$MATCHES"

CDIR="$MATCHES"
CREL="${CDIR#$REPO/}"
LECT="$CDIR/lectures"
RAW="$LECT/_raw"
[[ -d "$RAW" ]] || die "Thiếu $CREL/lectures/_raw/ — cấu trúc môn không đúng"

# Đọc tên môn + giảng viên từ README của môn
NAME_VI="$(sed -n '1s/^# [A-Z0-9]* — //p' "$CDIR/README.md" 2>/dev/null || true)"
LECTURER="$(sed -n 's/^| Giảng viên | \*\*\(.*\)\*\* |$/\1/p' "$CDIR/README.md" 2>/dev/null | head -1 || true)"
[[ -n "$NAME_VI"  ]] || NAME_VI="$COURSE"
[[ -n "$LECTURER" ]] || LECTURER="❓"

# ── số buổi ──────────────────────────────────────────────────────────────────
if [[ -z "$NUM" ]]; then
  LAST=$(find "$LECT" -maxdepth 2 -name 'L[0-9][0-9]*' -exec basename {} \; 2>/dev/null \
         | sed -n 's/^L\([0-9][0-9]*\).*/\1/p' | sort -n | tail -1 || true)
  NUM=$(( ${LAST:-0} + 1 ))
  [[ -n "$LAST" ]] && warn "Buổi lớn nhất đang có là L$LAST → dùng buổi ${B}$NUM${N}" \
                   || warn "Chưa có buổi nào → bắt đầu từ buổi ${B}$NUM${N}"
fi
[[ "$NUM" =~ ^[0-9]+$ ]] || die "--number phải là số, nhận được '$NUM'"
NN=$(printf '%02d' "$NUM")

# ── ngày ─────────────────────────────────────────────────────────────────────
[[ -n "$DATE" ]] || DATE="$(date +%F)"
[[ "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]] \
  || die "--date phải dạng YYYY-MM-DD, nhận được '$DATE'"

# ── slug chủ đề ──────────────────────────────────────────────────────────────
[[ -n "$TOPIC" ]] && require_slug "$TOPIC" --topic

# ── nguồn ────────────────────────────────────────────────────────────────────
SRC_KIND="transcript"
if [[ -n "$FROM" ]]; then
  [[ -f "$FROM" ]] || die "Không thấy file: $FROM"
  case "${FROM##*.}" in
    vtt|VTT)        SRC_KIND="transcript" ;;
    txt|TXT|md|MD)  SRC_KIND="transcript" ;;
    docx|DOCX|doc|DOC|pdf|PDF)
      die "Không đọc được ${FROM##*.} bằng script.
  Cách khác: mở file, copy nội dung, rồi dán tay vào file _raw sau khi script tạo xong.
  Hoặc tải lại transcript từ Teams ở dạng .vtt — đó là dạng tốt nhất vì có timestamp." ;;
    *) warn "Đuôi file '${FROM##*.}' lạ — sẽ copy nguyên văn" ;;
  esac
else
  SRC_KIND="chưa có"
fi

RAW_FILE="L${NN}-${DATE}-transcript.md"
RAW_PATH="$RAW/$RAW_FILE"
[[ -e "$RAW_PATH" ]] && die "File đã tồn tại: $CREL/lectures/_raw/$RAW_FILE
  Script không ghi đè. Muốn tạo lại thì xoá thủ công, hoặc dùng --number khác."

if [[ -n "$TOPIC" ]]; then
  NOTE_FILE="L${NN}-${TOPIC}.md"
  NOTE_PATH="$LECT/$NOTE_FILE"
  [[ -e "$NOTE_PATH" ]] && die "File đã tồn tại: $CREL/lectures/$NOTE_FILE"
fi
EXISTING=$(find "$LECT" -maxdepth 1 -name "L${NN}-*.md" | head -1 || true)
[[ -n "$EXISTING" ]] && warn "Buổi $NN đã có note: $(basename "$EXISTING")"

# ── bộ chuyển VTT → markdown ─────────────────────────────────────────────────
# Teams sinh .vtt cắt câu rất vụn. Gộp các cue liên tiếp của cùng người nói
# để đọc được, giữ timestamp của câu đầu mỗi lượt nói.
read -r -d '' VTT_AWK <<'AWKEOF' || true
BEGIN { RS=""; FS="\n"; sp=""; buf=""; t="" }
function flush() {
  if (buf == "") return
  if (sp != "") printf "**[%s] %s:** %s\n\n", t, sp, buf
  else          printf "**[%s]** %s\n\n", t, buf
  buf = ""
}
{
  ts = ""; line = 0
  for (i = 1; i <= NF; i++) if ($i ~ / --> /) { ts = $i; line = i; break }
  if (ts == "") next
  split(ts, a, " --> "); start = a[1]
  sub(/\.[0-9]+$/, "", start); sub(/^00:/, "", start)
  txt = ""
  for (i = line + 1; i <= NF; i++) if ($i != "") txt = txt (txt == "" ? "" : " ") $i
  cur = ""
  if (match(txt, /<v[^>]*>/)) {
    cur = substr(txt, RSTART, RLENGTH)
    sub(/^<v[^ ]*[ ]*/, "", cur); sub(/>$/, "", cur)
  }
  gsub(/<[^>]*>/, "", txt)
  gsub(/^[ \t]+|[ \t]+$/, "", txt)
  if (txt == "") next
  if (cur != sp) { flush(); sp = cur; t = start }
  buf = buf (buf == "" ? "" : " ") txt
}
END { flush() }
AWKEOF

# ── in kế hoạch ──────────────────────────────────────────────────────────────
printf '\n%sTạo buổi học%s\n' "$B" "$N"
printf '  Môn        %s  %s\n' "$COURSE" "$NAME_VI"
printf '  Giảng viên %s\n' "$LECTURER"
printf '  Buổi       L%s\n' "$NN"
printf '  Ngày       %s\n' "$DATE"
printf '  Nguồn      %s%s\n' "$SRC_KIND" "${FROM:+  ← $FROM}"
printf '  Chủ đề     %s\n\n' "${TOPIC:-❓ chưa biết, để AI đặt sau khi đọc nội dung}"

if [[ $DRY -eq 1 ]]; then
  printf '%s[dry-run] Sẽ tạo:%s\n' "$Y" "$N"
  printf '  %s/lectures/_raw/%s\n' "$CREL" "$RAW_FILE"
  [[ -n "$TOPIC" ]] && printf '  %s/lectures/%s\n' "$CREL" "$NOTE_FILE"
  printf '\n%s[dry-run] Chưa ghi gì cả.%s\n' "$Y" "$N"
  exit 0
fi

# ── render ───────────────────────────────────────────────────────────────────
render() {
  sed -e "s|{{CODE}}|$(esc "$COURSE")|g" \
      -e "s|{{NAME_VI}}|$(esc "$NAME_VI")|g" \
      -e "s|{{LECTURER}}|$(esc "$LECTURER")|g" \
      -e "s|{{NUM}}|$(esc "$NN")|g" \
      -e "s|{{DATE}}|$(esc "$DATE")|g" \
      -e "s|{{TOPIC_VI}}|$(esc "${TOPIC_VI:-<Tên chủ đề tiếng Việt>}")|g" \
      -e "s|{{SLUG}}|$(esc "${TOPIC:-}")|g" \
      -e "s|{{RAW_FILE}}|$(esc "$RAW_FILE")|g" \
      -e "s|{{SOURCE}}|$(esc "$SRC_KIND")|g" \
      "$TPL/$1.md" > "$2"
}

if [[ -n "$FROM" ]]; then
  # header từ template, bỏ phần hướng dẫn "chưa có nội dung"
  render lecture-raw "$RAW_PATH.tmp"
  sed '/<!-- DÁN TRANSCRIPT/,$d' "$RAW_PATH.tmp" > "$RAW_PATH"
  rm -f "$RAW_PATH.tmp"
  if [[ "${FROM##*.}" =~ ^(vtt|VTT)$ ]]; then
    # bỏ CR của Windows trước khi đưa vào awk
    if tr -d '\r' < "$FROM" | awk "$VTT_AWK" >> "$RAW_PATH" 2>/dev/null; then
      TURNS=$(grep -c '^\*\*\[' "$RAW_PATH" || true)
      ok "Đã chuyển .vtt → markdown: $TURNS lượt nói, đã gộp theo người nói"
    else
      warn "Chuyển .vtt thất bại, copy nguyên văn"
      cat "$FROM" >> "$RAW_PATH"
    fi
  else
    cat "$FROM" >> "$RAW_PATH"
    ok "Đã copy nội dung từ $(basename "$FROM")"
  fi
else
  render lecture-raw "$RAW_PATH"
fi

ok "Tạo $CREL/lectures/_raw/$RAW_FILE"

if [[ -n "$TOPIC" ]]; then
  render lecture-note "$NOTE_PATH"
  ok "Tạo $CREL/lectures/$NOTE_FILE  (khung rỗng)"
fi

# ── việc còn lại ─────────────────────────────────────────────────────────────
printf '\n%sCòn lại:%s\n\n' "$B" "$N"
if [[ -z "$FROM" ]]; then
  printf '  1. Dán transcript hoặc note vào %s/lectures/_raw/%s\n' "$CREL" "$RAW_FILE"
  printf '  2. Bảo AI:  %s/new-lecture %s %s%s\n' "$B" "$COURSE" "$NN" "$N"
else
  printf '  Bảo AI:  %s/new-lecture %s %s%s\n' "$B" "$COURSE" "$NN" "$N"
fi
cat <<NEXT

  AI sẽ đọc file _raw ${FROM:+vừa nạp }cùng slide trong materials/slides/, rồi:
    · viết note theo 5 bước (trực giác → analogy → ví dụ → định nghĩa → code)
    · thêm mục "Tự kiểm tra" 5 câu
    · trích gợi ý thi  → IMPORTANT_NOTES.md
    · trích deadline   → admin/deadlines.md
    · sinh flashcard   → exam-prep/flashcards.md + .csv
    · cập nhật bảng tiến độ trong README của môn và của học kỳ
NEXT
