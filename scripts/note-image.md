# Bộ công cụ dùng chung cho hình minh họa

`note-image.py` hỗ trợ `illustrate-concept`, `illustrate-mechanism`, `concept-mindmap`
và phần Markdown của `add-note-image`. Chạy từ root repo bằng **Python 3.9+**.
Dựng SVG/Markdown chỉ cần stdlib; render cần một công cụ đã cài trên máy.

---

## Mục lục

- [1. Chạy nhanh](#1-chạy-nhanh)
- [2. Dựng hình từ JSON hoặc SVG tự vẽ](#2-dựng-hình-từ-json-hoặc-svg-tự-vẽ)
- [3. Render PNG và kiểm tra ảnh](#3-render-png-và-kiểm-tra-ảnh)
- [4. Sinh Markdown có Đọc hình dạng bullet list](#4-sinh-markdown-có-đọc-hình-dạng-bullet-list)
- [5. Giới hạn ghi file và kiểm thử](#5-giới-hạn-ghi-file-và-kiểm-thử)

---

## 1. Chạy nhanh

```bash
python3 scripts/note-image.py doctor
python3 scripts/note-image.py init mechanism --output /tmp/loading-spec.json
# Sửa JSON: nội dung đã kiểm chứng, thành phần, tọa độ, nhãn và mũi tên.
python3 scripts/note-image.py build /tmp/loading-spec.json --output /tmp/loading-mechanism.svg
python3 scripts/note-image.py render /tmp/loading-mechanism.svg --output /tmp/loading-mechanism.png
```

Thay `mechanism` bằng `concept` hoặc `mindmap` để lấy mẫu tương ứng.
Các mẫu chỉ là **khung bố cục**, chưa phải hình của concept đang học.
Mở PNG thật, sửa nội dung/bố cục rồi render lại khi cần. Khi chủ động thay bản thử
đã tạo, thêm `--force`; mặc định script từ chối ghi đè.

Với ảnh cần lưu vào note, dùng đường dẫn `images/` cạnh note cho SVG và PNG thay
cho `/tmp/`. Giữ tên riêng theo skill: `*-explained`, `*-mechanism`, `*-mindmap`.
Mind map xem trước vẫn ở thư mục tạm, chỉ lưu/chèn khi người dùng yêu cầu.

## 2. Dựng hình từ JSON hoặc SVG tự vẽ

Mẫu nằm trong [`templates/images/`](../templates/images/). Có thể sửa JSON và
build lại; SVG đầu ra vẫn chỉnh sửa trực tiếp được. Nếu chỉnh SVG trực tiếp thì
không build lại từ JSON cũ, vì build không đọc các thay đổi ấy.

| Kiểu | Dữ liệu | Bố cục |
|---|---|---|
| `concept` | `title`, `subtitle`, `width`, `height`, `elements` | Đặt tọa độ để làm rõ quan hệ/phép so sánh |
| `mechanism` | Cùng cấu trúc scene như `concept` | Mẫu trước/sau, cùng thành phần và mũi tên có ý nghĩa |
| `mindmap` | `title`, `subtitle`, `center`, `branches` | Tự chia nhánh hai bên, tăng chiều cao theo nội dung |

Với **scene**, `elements` được vẽ theo thứ tự trong JSON, phần tử sau nằm trên:

| `type` | Trường cần có | Tùy chọn |
|---|---|---|
| `rect`, `ellipse` | `x`, `y`, `width`, `height` | `text`, `fill`, `color`, `font_size`, `bold`; `radius` cho rect |
| `text` | `x`, `y`, `text` | `font_size`, `color`, `bold`, `anchor`: `start` / `middle` / `end` |
| `arrow`, `line` | `points`: ít nhất hai cặp `[x, y]` | `color`, `stroke_width`, `dashed` |

Tọa độ tính bằng px từ góc trên trái; với ellipse là khung bao quanh ellipse.
`text.y` là baseline dòng đầu. Nhãn hỗ trợ `\n`; text trong rect/ellipse căn giữa.
Script escape XML và giữ dấu tiếng Việt. Scene không tự đo font hay tránh chồng
chữ; chủ động xuống dòng và mở PNG để kiểm tra.

Với **mindmap**, mỗi nhánh có `text` và `children` là danh sách chuỗi:

```json
{"text": "Thành phần", "children": ["Page table", "TLB"]}
```

Layout hỗ trợ 1–8 nhánh chính và một tầng nhánh phụ, canvas rộng 1600 px.
Nhãn được wrap theo số ký tự ước lượng, không cắt giữa một từ dài. Rút gọn nhãn
hoặc vẽ SVG riêng nếu cây lớn/phức tạp; không ép nội dung vào mẫu.

Với hình dạng, bảng, hatch pattern hoặc bố cục đặc biệt, **vẽ SVG riêng rồi gọi
`render` trực tiếp**. Không cần chuyển SVG có sẵn sang JSON. Script không thay
ImageGen cho phong cách bitmap/vật thể được yêu cầu, không kiểm chứng chuyên môn.

## 3. Render PNG và kiểm tra ảnh

```bash
python3 scripts/note-image.py render drawing.svg --output drawing.png --width 1600
python3 scripts/note-image.py render drawing.svg --output drawing.png --backend qlmanage --force
```

- `auto` chọn công cụ đã có theo thứ tự `rsvg-convert` → `inkscape` → `qlmanage`.
  `doctor` in đường dẫn; script không cài dependency, gọi mạng hay API trả phí.
- Mặc định dùng chiều rộng SVG; `--width` đổi chiều rộng PNG và giữ tỉ lệ.
  Mỗi chiều PNG cần trong khoảng 1–8192 px. SVG dùng width/height dạng số, `px`
  hoặc chỉ `viewBox`; chuyển đơn vị `cm`/`in`/`%` trước khi render.
- Quick Look (`qlmanage`, macOS) có thể cần quyền ngoài sandbox. Nếu báo
  `sandbox initialization failed`, agent xin quyền cho **lệnh render đó** theo
  môi trường. Script không đổi renderer sau lỗi hay tự thử đường vòng.
- Quick Look có thể ép thumbnail SVG thành vuông. Script lồng viewport nguồn
  trong SVG vuông tạm, render rồi crop góc trên trái, hỗ trợ ngang/dọc/vuông.
  PNG được unfilter trước khi crop. Không sửa SVG gốc, không dùng `sips` center-crop.
- Crop Quick Look hỗ trợ PNG 8-bit không interlace; định dạng khác thì báo lỗi,
  chưa ghi đầu ra. Chỉ thành công khi kích thước PNG khớp. File tạm tự dọn;
  render thất bại giữ file đích cũ nguyên vẹn.
- **Mở PNG thật** để kiểm tra chữ, công thức, nhánh/mũi tên và mép ảnh. Kích thước
  đúng không chứng minh nội dung đúng. Ưu tiên SVG tự chứa và font đã có trên máy.

## 4. Sinh Markdown có Đọc hình dạng bullet list

Sau khi ảnh đã lưu trong repo và được kiểm tra, sinh block bằng lệnh sau (thay
đường dẫn minh họa bằng file thật):

```bash
python3 scripts/note-image.py markdown path/to/images/loading-mechanism.png \
  --note path/to/note.md \
  --alt 'Thủ tục được nạp khi có lời gọi' \
  --svg path/to/images/loading-mechanism.svg \
  --caption '*Hình do AI dựng; nguồn và giả thiết đã đối chiếu trong phiên học.*' \
  --read '**Ban đầu:** Thủ tục chưa được nạp vào RAM.' \
  --read '**Khi gọi:** Thủ tục được nạp để thực thi.'
```

Lệnh **in ra stdout**, không sửa note. Skill chọn đúng đoạn, tránh ảnh trùng rồi
chèn block. Link tương đối từ note được URL-encode khoảng trắng, tiếng Việt,
`#`, `%`, dấu ngoặc; ảnh/SVG và note phải tồn tại trong repo. Caption do người gọi
cung cấp, có thể chứa link nguồn; script không tự gán nguồn hay xuất xứ AI.
Mỗi `--read` tạo một bullet và giữ Markdown in đậm.

`add-note-image` có thể dùng riêng `markdown` với PNG/JPEG/WebP/SVG đã có, không
cần dựng/render lại. Ảnh trong `materials/`, `_raw/`, `brief/` vẫn được tham chiếu
chỉ đọc. Không redirect stdout vào chính note vì sẽ ghi đè toàn bộ file.

## 5. Giới hạn ghi file và kiểm thử

`init`, `build`, `render` từ chối ghi vào `materials/`, `brief/`, `_raw/`, kể cả qua
symlink. Script kiểm tra đuôi đầu ra, từ chối file đã có trừ khi có `--force`.
Chỉ dùng `--force` khi việc thay thế đúng yêu cầu; không dùng để vượt xung đột tên
với ảnh cũ. CLI không chèn note, commit hay push.

```bash
python3 -m unittest discover -s scripts/tests -p 'test_note_image.py' -v
python3 scripts/toc.py check scripts/note-image.md
git diff --check
```

Kiểm thử gồm crop chính xác pixel với cả năm PNG filter, ảnh ngang/dọc/vuông,
escape XML/tiếng Việt, build mẫu, link Markdown và bảo vệ file gốc. Khi sửa renderer,
render thêm SVG thực tế vào thư mục tạm và mở ảnh; unit test không thay bước đó.

Skill gọi chung CLI trong `scripts/`, không copy script vào từng skill. Giữ nguyên
việc đối chiếu nguồn, kiểm tra ảnh và phạm vi ghi note của mỗi skill.
