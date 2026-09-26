---
name: illustrate-concept
description: Tạo hình minh họa trực quan để giải thích một khái niệm rồi chèn vào đúng mục của ghi chú Markdown. Dùng khi người dùng muốn tạo hình, infographic hoặc sơ đồ giải thích và lưu vào note, kể cả khi suy ra khái niệm và note từ phiên học hiện tại. Ảnh có sẵn chỉ cần chèn thì dùng add-note-image; không dùng cho việc chỉ giảng bằng lời hoặc tạo cả slide deck.
---

# Tạo hình giải thích khái niệm và cập nhật ghi chú

Biến một khái niệm thành hình giúp người học **thấy được cơ chế và hiểu vì sao**,
rồi lưu ảnh và chèn vào đúng đoạn của note. Mặc định hoàn thành cả hai việc khi
người dùng gọi skill; nếu họ chỉ muốn xem trước thì chỉ tạo bản xem trước.

---

## Mục lục

- [1. Xác định khái niệm, ghi chú và nguồn](#1-xác-định-khái-niệm-ghi-chú-và-nguồn)
- [2. Thiết kế hình để giải thích](#2-thiết-kế-hình-để-giải-thích)
- [3. Tạo ảnh và kiểm tra trực quan](#3-tạo-ảnh-và-kiểm-tra-trực-quan)
- [4. Lưu ảnh và chèn vào ghi chú](#4-lưu-ảnh-và-chèn-vào-ghi-chú)
- [5. Kiểm tra và bàn giao](#5-kiểm-tra-và-bàn-giao)

---

## 1. Xác định khái niệm, ghi chú và nguồn

```text
$illustrate-concept Address binding vào semesters/2025-2026-S3/IT007-operating-systems/lectures/L08-memory-management.md
$illustrate-concept Tạo hình giải thích paging và thêm vào note đang học
$illustrate-concept Minh họa bounded waiting giống phong cách ảnh trong L05
```

- Đọc `AGENTS.md`, kiểm tra Git và dùng đúng khái niệm/note người dùng chỉ định.
  Nếu thiếu, suy từ chủ đề vừa trao đổi và note đang học; chỉ hỏi một câu ngắn khi
  có nhiều đích hợp lý hoặc chưa xác định được khái niệm. Không tự tạo lecture mới.
- Đọc mục liên quan cùng các đoạn lân cận, hình và caption hiện có. Ưu tiên nguồn
  được note dẫn; xem slide/giáo trình khi cần kiểm chứng. Ghi lại nhãn nguồn thật
  để dùng trong caption, không suy số slide từ tên ảnh.
- Chọn một ý chính mà hình cần làm rõ. Ví dụ tự đặt, analogy và kiến thức bổ sung
  phải phân biệt với nội dung slide; ghi giả thiết ảnh hưởng kết quả. Nếu chưa
  xác minh được một mệnh đề thì không đưa nó thành khẳng định trong ảnh.
- Yêu cầu tạo hình **và cập nhật note** đã cho phép ghi phần này, kể cả giữa phiên
  `study-tutor`; không chờ kết thúc phiên hoặc hỏi duyệt lại khi đích đã rõ. Không
  mở rộng sang FAQ, flashcard hoặc `IMPORTANT_NOTES.md`.

## 2. Thiết kế hình để giải thích

Tham khảo phong cách trong `L05-process-synchronization.md` của IT007 khi người
dùng muốn “giống L05”: đọc các link ảnh trong note và mở ảnh thực tế. Ảnh race
condition, bounded waiting có tiêu đề rõ, khối nội dung phân màu, ví dụ nhỏ,
mũi tên chỉ trình tự và phần đối chiếu. Học cách trình bày; đối chiếu cả caption
đính chính trong note, không sao chép các khẳng định rút gọn của ảnh tham chiếu.

Soạn nội dung hình trước khi gọi công cụ:

- **Trực giác → analogy → ví dụ nhỏ → quy tắc chính thức.** Giữ thứ tự giải thích
  của repo, rút thành nhãn ngắn; code chỉ thêm khi thật sự giúp hiểu và đã kiểm
  chứng. Giải thích dài hoặc giới hạn của analogy có thể để ở caption.
- Dùng ví dụ có số hoặc đối tượng cụ thể: hai thread, vài page/frame, một yêu cầu
  cấp phát. Tự tính lại mọi kết quả; nếu có luồng chạy, kiểm tra từng trạng thái.
- Chọn hình thức theo nội dung: timeline cho thứ tự, các khối và mũi tên cho ánh
  xạ, hai cột cho so sánh, hình trước/sau cho thay đổi. Không ép mọi khái niệm
  thành “sai/đúng” hoặc “vấn đề/giải pháp”. Kết hình bằng một câu chốt/bảng nhỏ.
- Nhãn tiếng Việt có dấu; giữ thuật ngữ kỹ thuật tiếng Anh và chú thích lần đầu.
  Nhất quán màu/nhãn cho cùng đối tượng. Mũi tên có hướng rõ, kèm ý nghĩa nếu dễ
  nhầm; thời gian, lượt chờ, địa chỉ và kích thước phải có đơn vị đúng.
- Ưu tiên chữ đủ lớn khi đọc trong Markdown, nền sáng, khoảng trống và tương
  phản rõ. Không dùng màu làm dấu hiệu duy nhất. Bớt chữ hoặc tách hình nếu quá
  dày; không nhồi nguyên note thành poster.

Ví dụ về độ chính xác: hình address binding có thể dùng `logical = 1000`, nền
`4000` rồi `7000`, suy ra physical `5000` rồi `8000`. Phải ghi đây là **mô hình
relocation cộng địa chỉ nền**, không trình bày như công thức chung của paging.
Với bounded waiting, giới hạn **số lượt được vào trước** không phải số giây; FIFO
là một ví dụ cơ chế, không phải định nghĩa hay bảo đảm của mọi thuật toán.

## 3. Tạo ảnh và kiểm tra trực quan

**Infographic có minh họa như L05:** nếu môi trường có skill `imagegen`, đọc skill
đó và dùng công cụ tạo ảnh tích hợp theo hướng dẫn của nó. Không hardcode đường
dẫn cài đặt, model hay tên tham số chưa được công cụ xác nhận. Nếu dùng môi trường
khác, kiểm tra công cụ tạo ảnh tương đương thực sự có sẵn trước khi thực hiện.

**Sơ đồ cần chính xác từng nhãn/toạ độ hoặc người dùng yêu cầu vector:** có thể
dựng SVG rồi render PNG bằng công cụ sẵn có; giữ SVG để chỉnh sửa về sau. Đây là
lựa chọn theo loại hình, không phải thay thế âm thầm khi công cụ tạo ảnh thiếu.
Nếu người dùng yêu cầu infographic dạng ảnh, không bàn giao chỉ Mermaid hoặc
HTML thay cho ảnh. Không tự cài công cụ hay chuyển sang API trả phí ngoài yêu cầu.
Khi công cụ cần thiết không có, báo giới hạn và phương án thực tế; không tạo link
ảnh giả. Với `imagegen`, CLI/API dự phòng chỉ dùng khi người dùng chọn theo skill.

Prompt cần chứa những phần có ích sau, điền bằng nội dung đã kiểm chứng:

```text
Mục đích: giải thích [khái niệm] cho người học, chèn trong ghi chú Markdown.
Ý chính cần nhìn ra: [...].
Nội dung và nhãn chính xác: [...].
Ví dụ: đối tượng, số liệu, các bước, kết quả [...].
Bố cục và hướng đọc: [...]; analogy và giới hạn [...].
Phong cách tham chiếu: [ảnh đã mở, chỉ dùng để tham khảo trình bày].
Ràng buộc: tiếng Việt rõ dấu, thuật ngữ nhất quán, không thêm mệnh đề mới;
giữ nguyên số liệu/đơn vị/giả thiết [...], không được ngụ ý [...].
```

Mở **ảnh kết quả thực tế** để kiểm tra chữ, số, dấu tiếng Việt, công thức, chiều
mũi tên, thứ tự bước và khả năng đọc; với SVG cũng phải xem bản render. Đối chiếu
với nội dung đã chuẩn bị, không chỉ kiểm tra file tồn tại. Chỉnh hoặc tạo lại
phần sai rồi xem lại; nếu vẫn chưa có ảnh đạt yêu cầu thì báo cụ thể phần chưa
xong, không chèn ảnh sai vào note. Caption giải thích giả thiết, không dùng để
hợp thức hóa lỗi đã biết trong ảnh mới.

## 4. Lưu ảnh và chèn vào ghi chú

Đọc [add-note-image](../add-note-image/SKILL.md), áp dụng cách chọn vị trí, chống
trùng, ghi Markdown và kiểm tra link của skill đó. Với ảnh mới tạo, áp dụng thêm:

- Lưu ảnh hoàn chỉnh trong repo trước khi chèn. Dùng nơi lưu ảnh **đầu ra** đã có
  của note; mặc định `images/<concept>-explained.png` cạnh note, tên tiếng Anh.
  Ảnh bài tập/đồ án dùng `images/` của bài đó. Không lưu ảnh mới vào `lectures/_raw/`,
  `materials/` hay `brief/`, dù hình cũ của L05 đang được tham chiếu từ `_raw/`.
- Không ghi đè ảnh cũ nếu chưa được yêu cầu thay thế. Nếu đã có ảnh tương đương,
  kiểm tra trước khi tạo/chèn trùng; khi cần biến thể, đặt tên phân biệt. Với
  bản vector, lưu cả SVG nguồn và PNG, liên kết PNG trong note.
- Chèn ngay sau ví dụ/đoạn giải thích tương ứng, thường trong phần “Giải thích dễ
  hiểu”. Giữ nguyên lý thuyết và cấu trúc note; không đẩy hình xuống sau phần tự
  kiểm tra. Alt text phải nói được ý chính ngay cả khi ảnh không hiển thị.
- Ghi đúng nguồn gốc: ảnh mới do AI tạo không phải ảnh người dùng cung cấp hay
  slide giảng viên. Caption có nguồn kiến thức, ví dụ tự đặt và giả thiết cần
  thiết; không gán nguồn chưa kiểm chứng.
- Phần **Đọc hình** luôn trình bày bằng bullet list, mỗi bullet một ý; mở đầu
  bằng nhãn in đậm chỉ vùng, bước hoặc lưu ý tương ứng. Đặt `**Đọc hình:**` trên
  dòng riêng, cách danh sách một dòng trống; không gộp các ý thành đoạn văn.

```markdown
![Mô tả ngắn cơ chế hoặc kết quả mà hình thể hiện](images/concept-explained.png)

*Hình minh họa do AI tạo dựa trên [nguồn kiến thức đã đối chiếu]; ví dụ tự đặt.*

**Đọc hình:**

- **Vùng/bước thứ nhất:** Giải thích điều cần quan sát và ý nghĩa.
- **Vùng/bước tiếp theo:** Giải thích quan hệ hoặc kết quả.
- **Lưu ý:** Nêu giả thiết hoặc giới hạn cần thiết để đọc đúng hình, nếu có.
```

## 5. Kiểm tra và bàn giao

- Xác nhận file mở được, link tương đối resolve đúng từ note, không trỏ ra thư
  mục tạm hay máy cá nhân; xem lại vị trí chèn và các ảnh đã có để tránh trùng.
- Chạy `scripts/toc.py check` cho Markdown đã sửa và `git diff --check`. Nếu
  thêm/đổi heading, sinh lại mục lục bằng `scripts/toc.py gen`. Chỉ nói đã xem
  render Markdown khi thực sự đã xem; xem ảnh riêng không thay thế việc đó.
- Review diff, stage đúng ảnh (cả SVG nếu có) và note thuộc yêu cầu, commit theo
  repo: `<MÃ MÔN>: minh họa <khái niệm> trong <note>`. Không push tự động.
- Bàn giao ảnh cùng link note và tên mục đã chèn; nói ngắn hình giải thích điều
  gì. Nếu dùng `imagegen`, kèm prompt cuối và chế độ tạo theo yêu cầu của skill
  đó. Nếu mới tạo bản xem trước hoặc còn bước chưa xong, báo đúng trạng thái.
