---
name: illustrate-table
description: Vẽ một bảng dữ liệu (header + rows, có thể có dấu ✔ ở một số ô) thành ảnh SVG/PNG, ví dụ ma trận user × role, bảng mapping, bảng đối chiếu quyền. Dùng khi người dùng muốn "vẽ bảng", "xuất ảnh bảng này", hoặc cần một bảng dạng ảnh để paste vào báo cáo/note thay vì bảng Markdown. Không dùng cho sơ đồ có mũi tên/luồng (illustrate-mechanism) hay infographic khái niệm (illustrate-concept).
---

# Vẽ bảng thành ảnh SVG/PNG

Dựng một bảng đơn giản (tiêu đề cột, các hàng, có thể đánh dấu ✔ ở một số ô)
thành SVG bằng `scripts/table-svg.py`, rồi render PNG bằng `scripts/note-image.py`.
Dùng cho các bảng tĩnh — không có bước/trạng thái thay đổi (nếu cần thể hiện
diễn biến thì dùng `illustrate-mechanism` thay vì skill này).

---

## Mục lục

- [1. Xác định nội dung bảng và đích lưu](#1-xác-định-nội-dung-bảng-và-đích-lưu)
- [2. Soạn spec JSON](#2-soạn-spec-json)
- [3. Dựng SVG và render PNG](#3-dựng-svg-và-render-png)
- [4. Kiểm tra và bàn giao](#4-kiểm-tra-và-bàn-giao)

---

## 1. Xác định nội dung bảng và đích lưu

```text
$illustrate-table Vẽ bảng vai trò hệ thống r1/r2/r3 trong guide-exercise-2 IE103 a3
$illustrate-table Xuất ảnh ma trận user × role, chỉ xem trước
```

- Xác định: tiêu đề bảng, cột, hàng, ô nào cần đánh dấu (✔ hoặc giá trị ngắn),
  và nguồn dữ liệu (đề gốc, ma trận đã lập trong note/guide). Không tự bịa số
  liệu hay mapping — chép đúng nguồn đã có trong hội thoại hoặc tài liệu.
- Nếu người dùng chỉ nói "vẽ bảng" mà chưa rõ nội dung, lấy từ ngữ cảnh gần nhất
  (bảng vừa được mô tả bằng lời/Markdown trong hội thoại). Chỉ hỏi khi thật sự
  chưa xác định được cột/hàng.
- Xác định nơi lưu ảnh: `images/` cạnh note/bài tập liên quan, tên dạng
  `<mô-tả>-matrix.svg` / `.png` (tiếng Anh, không dấu). Nếu người dùng chỉ muốn
  xem trước, dùng thư mục scratchpad, không ghi vào repo.

## 2. Soạn spec JSON

Lấy khung mẫu rồi sửa nội dung:

```bash
python3 scripts/table-svg.py init --output spec.json
```

Spec gồm:

| Trường | Ý nghĩa |
|---|---|
| `title`, `subtitle` | Tiêu đề/phụ đề phía trên bảng, có thể để trống `""` |
| `columns` | Danh sách tên cột; **cột đầu tiên** là cột nhãn hàng (vd `"user"`) |
| `rows` | Danh sách các hàng; mỗi hàng là mảng chuỗi, số phần tử = số cột |
| `note` | Danh sách dòng chú thích nhỏ phía dưới bảng (nguồn dữ liệu, giả thiết) |
| `mark_color`, `header_color`, `text_color` | Tùy chọn, có màu mặc định hợp lý |

Quy ước: ô có chuỗi ngắn (≤ 2 ký tự, vd `✔`) ở cột không phải cột đầu sẽ tự
được vẽ đậm màu `mark_color` như một dấu đánh dấu; ô có nội dung dài hơn được
vẽ như văn bản thường. Ví dụ ma trận user × role:

```json
{
  "title": "Ma trận thành viên user × role",
  "subtitle": "IE103 · Bài tập 3 · Gói 2",
  "columns": ["user", "r1", "r2", "r3"],
  "rows": [
    ["u1", "✔", "", ""],
    ["u2", "", "✔", ""],
    ["u3", "", "✔", ""],
    ["u4", "", "", "✔"],
    ["u5", "", "", "✔"],
    ["u6", "", "", "✔"]
  ],
  "note": ["Nguồn: đề gốc mục B, gạch đầu dòng \"Tạo nhóm\"."]
}
```

Với bảng có ô là văn bản (không phải đánh dấu), ví dụ bảng vai trò hệ thống,
để nguyên chuỗi dài trong ô:

```json
{
  "columns": ["role", "thành viên của", "cấp"],
  "rows": [
    ["r1", "SysAdmin", "server level"],
    ["r2", "db_owner, db_accessadmin", "database level"],
    ["r3", "SysAdmin, db_owner, db_accessadmin", "server + database"]
  ]
}
```

Kiểm chứng lại số liệu/mapping trong spec so với nguồn trước khi build — script
không tự đối chiếu đúng/sai, chỉ vẽ đúng những gì được đưa vào.

## 3. Dựng SVG và render PNG

```bash
python3 scripts/table-svg.py build spec.json --output images/ten-bang.svg
python3 scripts/note-image.py render images/ten-bang.svg --output images/ten-bang.png --width <3x-chiều-rộng-SVG>
```

- `table-svg.py` tự tính layout (độ rộng cột, chiều cao bảng) theo số cột/hàng;
  không cần tự đặt tọa độ như khi vẽ SVG tay.
- **Luôn truyền `--width`** khi render, bằng khoảng 3 lần chiều rộng SVG gốc
  (in ra trong log dòng "Đã dựng SVG" hoặc xem `width` trong thẻ `<svg>`). Không
  truyền `--width` sẽ xuất PNG đúng 1:1 px theo SVG — với bảng chữ nhỏ (font-size
  ~15px) ảnh ra chỉ vài trăm px, vỡ nét khi phóng to trong báo cáo/PDF.
- `note-image.py render` cần một renderer đã cài (`rsvg-convert`, `inkscape`
  hoặc `qlmanage`); chạy `python3 scripts/note-image.py doctor` để kiểm tra.
  Không tự cài thêm công cụ nếu chưa được người dùng đồng ý — nếu thiếu, báo rõ
  và hỏi trước khi cài (xem `scripts/note-image.md`).
- Cả hai lệnh từ chối ghi vào `materials/`, `brief/`, `_raw/` và từ chối ghi đè
  file đã có trừ khi thêm `--force`.

## 4. Kiểm tra và bàn giao

- **Mở PNG thật** để kiểm tra: đúng số hàng/cột, đúng vị trí đánh dấu, chữ tiếng
  Việt không vỡ dấu, không bị cắt chữ ở mép bảng.
- Nếu người dùng muốn chèn vào note/báo cáo, dùng `add-note-image` hoặc
  `python3 scripts/note-image.py markdown ...` để sinh block Markdown đúng vị
  trí — skill này chỉ tạo ảnh, không tự chèn.
- Nếu ảnh mới và thuộc thay đổi được yêu cầu, có thể stage cả `.svg`/`.png`
  cùng file note liên quan; chỉ commit khi người dùng yêu cầu, không tự push.
- Báo ngắn gọn: đã tạo ảnh nào, đường dẫn SVG/PNG, và đã xem PNG thật hay chỉ
  dựng SVG (khi chưa có renderer để render PNG).
