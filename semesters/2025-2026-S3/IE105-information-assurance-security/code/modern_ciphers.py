#!/usr/bin/env python3
"""Mã hoá hiện đại — IE105 L03 (Bài 2A, slide 41–69).

Chạy: python3 code/modern_ciphers.py
Không cần thư viện ngoài. DES/AES thật quá dài để viết tay ở đây — file này chỉ minh hoạ
những ý slide yêu cầu nắm: thời gian vét cạn theo độ dài khoá, ShiftRows của AES,
và RSA đồ chơi (số nhỏ) để thấy public/private làm hai việc khác nhau.
"""

# ---------- Vét cạn: trung bình phải thử một nửa không gian khoá (slide s68) ----------
def brute_force_seconds(bits, tries_per_second):
    return 2 ** (bits - 1) / tries_per_second


def human(seconds):
    year = 365.25 * 24 * 3600
    for unit, size in (("năm", year), ("giờ", 3600), ("phút", 60)):
        if seconds >= size:
            return f"{seconds / size:.3g} {unit}"
    return f"{seconds * 1000:.3g} ms"


# ---------- AES ShiftRows: hàng r xoay trái r ô (slide s52, s55) ----------
def shift_rows(state):
    return [row[r:] + row[:r] for r, row in enumerate(state)]


# ---------- RSA đồ chơi ----------
def rsa_keypair(p, q, e):
    n, phi = p * q, (p - 1) * (q - 1)
    d = pow(e, -1, phi)                     # e·d ≡ 1 (mod φ(n))
    return (e, n), (d, n)                   # (public), (private)


def rsa_apply(m, key):
    k, n = key
    return pow(m, k, n)


if __name__ == "__main__":
    print("Vét cạn với 10^6 lần thử mỗi MICRO giây (= 10^12/s):")
    for bits in (32, 56, 128):
        print(f"  {bits:>3} bit: {human(brute_force_seconds(bits, 1e12))}")
    print("Vét cạn với 1 lần thử mỗi micro giây (= 10^6/s):")
    for bits in (32, 56):
        print(f"  {bits:>3} bit: {human(brute_force_seconds(bits, 1e6))}")

    state = [[f"a{r}{c}" for c in range(4)] for r in range(4)]
    print("\nShiftRows:")
    for before, after in zip(state, shift_rows(state)):
        print("  ", " ".join(before), " → ", " ".join(after))

    pub, priv = rsa_keypair(61, 53, 17)
    print("\nRSA đồ chơi: public =", pub, "private =", priv)
    m = 65
    c = rsa_apply(m, pub)
    print(f"  Bảo mật  : m={m} → mã bằng PUBLIC  → c={c} → giải bằng PRIVATE → {rsa_apply(c, priv)}")
    s = rsa_apply(m, priv)
    print(f"  Chứng thực: m={m} → mã bằng PRIVATE → s={s} → giải bằng PUBLIC  → {rsa_apply(s, pub)}")
