# IE105 — Cheatsheet Chương 2A: Các giải thuật mã hoá

> Chắt lọc từ [guide Chương 2A](chapter2a-exam-study-guide.md) để xem nhanh trước giờ thi. Giải thích đầy đủ nằm trong guide.
> Đáp án là **suy luận**, vì đề mẫu không có đáp án chính thức. `[B2A s31]` = slide Bài 2A, trang PDF 31.

---

## Mã Playfair (Playfair Cipher) — câu 05, 06

**Quy tắc** [B2A s31–32]

```text
Ma trận 5×5 = chữ của khoá (bỏ chữ trùng) → A–Z còn lại   ← I = J, đủ đúng 25 ô
Bản rõ      = bỏ khoảng trắng → tách cặp; lẻ thì thêm X
Cùng dòng   → mỗi chữ lấy chữ BÊN PHẢI                   ← cột cuối vòng về cột đầu
Cùng cột    → mỗi chữ lấy chữ BÊN DƯỚI                   ← hàng cuối vòng lên hàng đầu
Chữ nhật    → mỗi chữ GIỮ HÀNG mình, sang CỘT chữ kia     ← thứ tự giữ nguyên
```

**4 bước làm bài**

1. Dựng ma trận, **đếm đủ 25 ô**, đánh số hàng/cột từ 1.
2. Tách bản rõ thành cặp; chỉ mã những cặp đề cần (câu 06 chỉ cần cặp đầu).
3. Áp một trong ba luật cho cặp đó.
4. Đọc đúng vị trí đề hỏi: "ký tự thứ k" đếm trên chuỗi mã **bỏ dấu cách**.

**Đề mẫu:** m = `THANH PHO HO CHI MINH`, k = `BAOMAT`. [Đề tr2, C05–06]
Câu 05: hàng 3 cột 3 là? a. L · b. K · c. I · d. khác. Câu 06: ký tự thứ hai của c? a. B · b. T · c. N · d. khác.

```text
     c1 c2 c3 c4 c5
r1   B  A  O  M  T      ← BAOMAT, chữ A thứ hai bị bỏ
r2   C  D  E  F  G
r3   H  I  K  L  N
r4   P  Q  R  S  U
r5   V  W  X  Y  Z
```

| Bước | Tính | Kết quả |
|---|---|---|
| C05 — tra ô | hàng 3 = `H I K L N`, cột 3 | **b. K** |
| C06 — tách cặp | `THANHPHOHOCHIMINH` 17 chữ + X | `TH AN HP HO HO CH IM IN HX` |
| C06 — mã cặp đầu | T(1,5), H(3,1): chữ nhật → T giữ hàng 1 sang cột 1, H giữ hàng 3 sang cột 5 | `TH → BN` |
| C06 — đọc vị trí | c = `BN TI PV KB KB HP LA KH KV` → ký tự 1 = B, ký tự 2 = N | **c. N** |

**Kiểm tra (30 giây)**

- Ma trận: không chữ nào lặp, không có J, đúng 25 ô.
- Giải mã ngược `BN`: vẫn là chữ nhật → B về cột 5 = **T**, N về cột 1 = **H** ✓.
- Luyện thêm bằng slide s34: khoá `PLAYFAIR` → `QM PQ EA GQ GQ BK DE EU KW`.

**Bẫy**

| Làm sai | Ra phương án | Nhận ra vì |
|---|---|---|
| C05: giữ chữ A trùng của khoá (`B A O M A / T C D E F / G H I K L`) | **c. I** | Slide: chữ trong ma trận không được trùng; đếm thấy 26 ô là sai |
| C05: đọc lệch sang cột 4 của hàng 3 | **a. L** | Lỗi tra ô, không phải lỗi quy tắc; chỉ tay vào từng cột khi đếm |
| C05: đánh số từ 0 (hàng 4, cột 4 tính từ 1) | **d. khác** (ra S) | Đề đếm hàng/cột từ 1 |
| C06: lấy ký tự **thứ nhất** của c | **a. B** | "Thứ hai" là chữ thứ 2 của `BN`, không phải chữ đầu |
| C06: chữ nhật làm ngược (giữ cột, đổi hàng) → `TH → NB` | **a. B** | Mỗi chữ phải **giữ hàng** của mình; giải mã ngược sẽ không ra `TH` |
| C06: hiểu "thứ hai" là **cặp** thứ hai (`TI`), lấy chữ đầu | **b. T** | Đếm theo ký tự, không đếm theo cặp |
| Gặp cặp cùng dòng/cột mà quên vòng mép (vd `IN → KH`) | — | N ở cột cuối phải vòng về H ở cột đầu |
