#!/usr/bin/env bash
#
# common.sh — Hàm dùng chung cho các script trong scripts/
# Source từ script khác:  source "$(dirname "${BASH_SOURCE[0]}")/lib/common.sh"
#

# ── màu ──────────────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  R=$'\033[31m'; G=$'\033[32m'; Y=$'\033[33m'; B=$'\033[1m'; N=$'\033[0m'
else
  R=''; G=''; Y=''; B=''; N=''
fi

die()  { printf '%s✗ %s%s\n' "$R" "$*" "$N" >&2; exit 1; }
ok()   { printf '%s✓%s %s\n' "$G" "$N" "$*"; }
warn() { printf '%s!%s %s\n' "$Y" "$N" "$*"; }

# ── thoát ký tự đặc biệt cho sed ─────────────────────────────────────────────
esc() { printf '%s' "$1" | sed -e 's/[\\&|]/\\&/g'; }

# ── cảnh báo slug tiếng Việt bỏ dấu ──────────────────────────────────────────
# Quy ước repo: tên đường dẫn phải tiếng Anh. Nhưng "he-dieu-hanh" vẫn đúng
# kebab-case nên regex không bắt được — chỉ cảnh báo, không chặn, vì có thể
# nhầm (vd "han" trong "hanoi", "tin" trong "tinder").
VN_WORDS="he|dieu|hanh|mang|may|tinh|co|so|du|lieu|quan|ly|nhap|mon|lap|trinh|an|ninh|thong|tin|ha|tang|ky|thuat|phan|mem|giai|thuat|cau|truc|xac|suat|ke|dai|toan|hoc|bao|dam|tri|tue|nhan|tao|kien|chuc|nang|vien|ung|dung|phat|trien|dinh|thoi|bo|nho|tien|trinh|luong"

check_vietnamese_slug() {  # check_vietnamese_slug <slug> <tên tham số>
  local slug="$1" flag="${2:---slug}"
  if printf '%s' "$slug" | tr '-' '\n' | grep -qxE "$VN_WORDS"; then
    warn "$flag '${B}$slug${N}' trông giống ${B}tiếng Việt bỏ dấu${N}."
    warn "  Quy ước của repo: tên đường dẫn phải là ${B}tiếng Anh${N}."
    warn "  vd: he-dieu-hanh → ${G}operating-systems${N}   dinh-thoi-cpu → ${G}cpu-scheduling${N}"
    warn "  Nếu cố ý thì bỏ qua cảnh báo này."
  fi
}

# ── kiểm tra định dạng kebab-case ────────────────────────────────────────────
require_slug() {  # require_slug <slug> <tên tham số>
  local slug="$1" flag="${2:---slug}"
  [[ "$slug" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || die "$flag '$slug' sai định dạng.
  Cần: tiếng Anh, chữ thường, không dấu, nối bằng dấu gạch (kebab-case).
  Đúng:  operating-systems, cpu-scheduling
  Sai:   he-dieu-hanh (tiếng Việt), CPU_Scheduling (hoa + gạch dưới)"
  check_vietnamese_slug "$slug" "$flag"
}

# ── học kỳ ───────────────────────────────────────────────────────────────────
resolve_semester() {  # resolve_semester <repo> <semester|rỗng> → in ra mã học kỳ
  local repo="$1" sem="${2:-}"
  if [[ -z "$sem" ]]; then
    sem="$(ls -1 "$repo/semesters" 2>/dev/null | sort -r | head -1 || true)"
    [[ -n "$sem" ]] || die "Không tìm thấy học kỳ nào trong semesters/. Dùng --semester để chỉ rõ."
  fi
  [[ -d "$repo/semesters/$sem" ]] \
    || die "Học kỳ '$sem' không tồn tại. Có: $(ls -1 "$repo/semesters" | tr '\n' ' ')"
  printf '%s' "$sem"
}

# ── 2025-2026-S3 → HK3 2025–2026 ─────────────────────────────────────────────
semester_vi() {
  if [[ "$1" =~ ^([0-9]{4}-[0-9]{4})-S([0-9])$ ]]; then
    printf 'HK%s %s' "${BASH_REMATCH[2]}" "${BASH_REMATCH[1]//-/–}"
  else
    printf '%s' "$1"
  fi
}
