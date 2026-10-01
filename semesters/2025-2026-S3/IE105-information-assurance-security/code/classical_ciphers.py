#!/usr/bin/env python3
"""Mã hoá cổ điển — IE105 L02 (Bài 2A, slide 23–35).

Chạy: python3 code/classical_ciphers.py
Mọi ví dụ trong lectures/L02-classical-ciphers.md được kiểm bằng file này.
Quy ước chữ cái: A=0 … Z=25 (Caesar/Vigenère/Affine). Slide Hill dùng A=01, không có ở đây.
"""
from math import factorial, gcd
from string import ascii_uppercase as AZ


# ---------- Mã thay thế đơn giản: khoá = hoán vị 26 chữ ----------
def substitution(m, key):
    return "".join(key[AZ.index(ch)] if ch in AZ else ch for ch in m)


# ---------- Mã hoán vị bậc d: h[i] = vị trí cũ đưa vào vị trí mới i ----------
def permutation(m, h):
    d = len(h)
    m = m + " " * (-len(m) % d)            # đệm cho đủ khối
    blocks = [m[i:i + d] for i in range(0, len(m), d)]
    return "".join("".join(b[p - 1] for p in h) for b in blocks)


# ---------- Mã dịch chuyển: Vigenère; Caesar = Vigenère khoá 1 ký tự ----------
def vigenere(m, key, decrypt=False):
    out, j = [], 0
    for ch in m:
        if ch not in AZ:                    # slide: ký tự trắng giữ nguyên, không cộng
            out.append(ch)
            continue
        k = AZ.index(key[j % len(key)]) * (-1 if decrypt else 1)
        out.append(AZ[(AZ.index(ch) + k) % 26])
        j += 1
    return "".join(out)


def caesar(m, k, decrypt=False):
    return vigenere(m, AZ[k], decrypt)


# ---------- Mã tuyến tính (Affine): e(x) = ax + b mod 26 ----------
def affine(m, a, b, decrypt=False):
    if gcd(a, 26) != 1:
        raise ValueError(f"a={a} không khả nghịch mod 26 → không giải mã được")
    a_inv = pow(a, -1, 26)
    f = (lambda y: a_inv * (y - b)) if decrypt else (lambda x: a * x + b)
    return "".join(AZ[f(AZ.index(ch)) % 26] if ch in AZ else ch for ch in m)


# ---------- Mã Playfair 5×5 (I = J) ----------
def playfair_matrix(key):
    seen = []
    for ch in (key.upper() + AZ).replace("J", "I"):
        if ch in AZ and ch not in seen:
            seen.append(ch)
    return [seen[r * 5:(r + 1) * 5] for r in range(5)]


def playfair(m, key, decrypt=False):
    M = playfair_matrix(key)
    pos = {M[r][c]: (r, c) for r in range(5) for c in range(5)}
    s = [ch for ch in m.upper().replace("J", "I") if ch in AZ]
    if len(s) % 2:
        s.append("X")                       # slide s32: dư 1 ký tự thì thêm x
    step = -1 if decrypt else 1
    out = []
    for a, b in zip(s[::2], s[1::2]):
        (ra, ca), (rb, cb) = pos[a], pos[b]
        if ra == rb:                        # cùng dòng → bên phải (giải mã: bên trái)
            out.append(M[ra][(ca + step) % 5] + M[rb][(cb + step) % 5])
        elif ca == cb:                      # cùng cột → bên dưới (giải mã: bên trên)
            out.append(M[(ra + step) % 5][ca] + M[(rb + step) % 5][cb])
        else:                               # hình chữ nhật → góc còn lại cùng dòng
            out.append(M[ra][cb] + M[rb][ca])
    return " ".join(out)


if __name__ == "__main__":
    print("26! =", f"{factorial(26):.2e}", "khoá thay thế")
    print("Substitution:", substitution("BAD", "UXEOSABCDFGHIJKLMNPQRTVWYZ"))

    print("Permutation slide s26:", repr(permutation("JOHN IS A GOOD ACTOR", (4, 1, 3, 2, 5))))
    print("Permutation tự đặt   :", permutation("SECRET", (2, 3, 1)))

    print("Caesar slide s28  :", caesar("CRYPTOGRAPHY", 5))
    print("Caesar giải mã    :", caesar("HWDUYTLWFUMD", 5, decrypt=True))
    print("Caesar tự đặt k=3 :", caesar("TRUONG DAI HOC", 3))
    print("Vigenère slide s29:", vigenere("VIGENERE", "CHIFFRE"))
    print("Vigenère tự đặt   :", vigenere("ATTACK", "LEMON"))

    print("Affine 5x+8       :", affine("AFFINE", 5, 8), "| a^-1 =", pow(5, -1, 26))
    print("Affine giải mã    :", affine("IHHWVC", 5, 8, decrypt=True))
    try:
        affine("A", 2, 3)
    except ValueError as e:
        print("Affine a=2        :", e)

    for key in ("PLAYFAIR", "COMPUTER", "BAOMAT"):
        print(f"\nMa trận Playfair khoá {key}:")
        for row in playfair_matrix(key):
            print("   ", " ".join(row))
    print("Playfair slide s34 :", playfair("THANH PHO HO CHI MINH", "PLAYFAIR"))
    print("Playfair của thầy  :", playfair("TRUONG DAI HOC CONG NGHE THONG TIN", "COMPUTER"))
    print("Giải mã ngược      :", playfair("EA CM XN HT DI MO OM XN XN FA AD ML DR GS", "COMPUTER", decrypt=True))
    print("Playfair tự đặt    :", playfair("HELLO", "COMPUTER"))
