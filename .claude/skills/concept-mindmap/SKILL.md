---
name: concept-mindmap
description: Vẽ mind map cho một concept, gồm khái niệm cơ bản ngắn gọn và những ý chính quan trọng để học và ôn lại. Dùng khi người dùng nói "vẽ mind map cho X", "sơ đồ tư duy về X" hoặc muốn chắt lọc một khái niệm thành các nhánh dễ nhớ. Không dùng để lập bản đồ toàn bộ slide của môn hay minh họa cơ chế chạy từng bước.
---

# Mind map cho một concept

Giúp người học nhìn một hình là nhớ được **concept là gì và cần nắm những ý nào**.
Chắt lọc nội dung trước, rồi mới vẽ cây nhánh; không biến cả bài giảng thành một ảnh đầy chữ.

---

## Mục lục

- [1. Nhận concept và đối chiếu nguồn](#1-nhận-concept-và-đối-chiếu-nguồn)
- [2. Chắt lọc thành cây ý chính](#2-chắt-lọc-thành-cây-ý-chính)
- [3. Vẽ mind map và xem ảnh thật](#3-vẽ-mind-map-và-xem-ảnh-thật)
- [4. Lưu và chèn khi được yêu cầu](#4-lưu-và-chèn-khi-được-yêu-cầu)
- [5. Kiểm tra và bàn giao](#5-kiểm-tra-và-bàn-giao)

---

## 1. Nhận concept và đối chiếu nguồn

```text
$concept-mindmap Address binding
$concept-mindmap Vẽ mind map cho paging
$concept-mindmap Address binding vào semesters/2025-2026-S3/IT007-operating-systems/lectures/L08-memory-management.md
```

- Đọc `AGENTS.md`, kiểm tra Git nếu làm trong repo. Xác định **một concept** từ
  yêu cầu hoặc phiên học; chỉ hỏi khi chưa phân biệt được nghĩa/chủ đề cần vẽ.
- Mặc định tạo và bàn giao hình mind map. Khi người dùng yêu cầu chèn vào note
  hoặc gọi kèm `vào <note>`, thực hiện cả việc chèn; có thể suy note từ phiên học
  nếu yêu cầu là "thêm vào note đang học". Không tự tạo lecture hay sửa note chỉ
  vì note được dùng làm nguồn.
- Đọc đúng mục trong note, ưu tiên slide/giáo trình được dẫn. Kiểm chứng các ý
  định đưa lên hình; giữ tên tài liệu và trang thật để ghi nguồn dưới hình.
  Không cần đọc toàn bộ môn cho một concept.
- Khi thiếu nguồn học liệu, có thể dùng kiến thức nền và ghi rõ là phần tổng hợp;
  không gán cho giảng viên. Mệnh đề còn mâu thuẫn/chưa rõ phải được kiểm chứng,
  thu hẹp hoặc đánh dấu `❓ Cần xác minh`, không biến thành ý chốt chắc chắn.

## 2. Chắt lọc thành cây ý chính

- **Trung tâm:** tên concept, giữ thuật ngữ kỹ thuật tiếng Anh.
- **Nhánh khái niệm:** một câu ngắn, dễ hiểu trả lời "là gì?"; tránh định nghĩa dài.
- **Các nhánh còn lại:** chọn theo bản chất concept, chẳng hạn mục đích, loại chính,
  thành phần, quy tắc cốt lõi hoặc điểm dễ nhầm. Không ép concept nào cũng có đủ
  các nhóm này.
- Ưu tiên khoảng **3–6 nhánh chính**, mỗi nhánh chỉ vài ý phụ, thường sâu 1–2 tầng.
  Đây là mức gợi ý để hình gọn; concept đơn giản cần ít nhánh hơn. Chỉ giữ ý giúp
  người học hiểu, phân biệt hoặc vận dụng; gộp các ý trùng nhau, bỏ chi tiết phụ.
- Mỗi node là **một từ khóa hoặc mệnh đề ngắn**, nội dung tiếng Việt có dấu.
  Giữ điều kiện quan trọng khi rút gọn, không biến "có thể" thành "luôn luôn".
- Chỉ thêm ví dụ nhỏ/công thức khi nó giúp nhớ một ý chính; ghi giả thiết cần thiết.
  Analogy, diễn giải dài, code và bài tập không chiếm các nhánh của bản tóm tắt.
- "Quan trọng" nghĩa là cốt lõi của concept; không suy ra "chắc chắn thi" nếu
  không có nguồn từ giảng viên.

Ví dụ chọn nhánh cho **Address binding** *(khung tham khảo, đối chiếu nguồn của
phiên học trước khi dùng; không phải mẫu nội dung áp đặt cho mọi concept)*:

```text
Address binding
├─ Là gì? → Ánh xạ giữa các không gian địa chỉ
├─ Compile time → Biết trước chỗ nạp; đổi chỗ thì biên dịch lại
├─ Load time → Gán địa chỉ khi nạp; đổi chỗ thì nạp lại
└─ Execution time → Ánh xạ lúc chạy; cần phần cứng hỗ trợ
```

Ba thời điểm là **các lựa chọn**, không phải ba bước bắt buộc nối tiếp nhau.
Đây là cây nội dung để dựng hình, chưa phải sản phẩm bàn giao.

## 3. Vẽ mind map và xem ảnh thật

- Đặt concept ở trung tâm, các nhánh chính tỏa ra hai bên hoặc quanh tâm; nối
  nhánh phụ vào đúng cha. Phân biệt cấp ý bằng vị trí, cỡ chữ và nét nối.
  Đường nối biểu thị quan hệ ý chính–ý phụ, không ngụ ý thứ tự thời gian.
- Mỗi nhánh chính có thể dùng một màu nhất quán; vẫn phải hiểu cây khi bỏ màu.
  Nền sáng, chữ đủ lớn, khoảng trống rõ. Nếu quá chật, rút gọn nội dung trước
  khi giảm cỡ chữ. Không đổi mind map thành chuỗi hộp flowchart hay poster liệt kê.
- Ưu tiên **SVG nguồn + PNG** để kiểm soát chính xác nhãn và bố cục. Dùng công cụ
  dựng/render sẵn có; không hardcode đường dẫn công cụ trên một máy cụ thể.
  Nếu người dùng chọn định dạng khác, dùng công cụ phù hợp và giữ đúng yêu cầu.
- Chỉ dùng `imagegen` khi cần phong cách minh họa do người dùng chọn; đọc skill đó
  trước và kiểm tra từng nhãn. Không tự cài phần mềm hay gọi API trả phí để tạo hình.
- Phải **mở ảnh render thực tế** để kiểm tra dấu tiếng Việt, chữ bị cắt/chồng,
  nhánh nối nhầm, ý trùng và khả năng đọc ở kích thước chèn Markdown. Sửa rồi xem lại.
  Nếu công cụ render không có, báo giới hạn và phương án khả thi; không gọi cây
  text hay mã Mermaid chưa render là hình mind map đã hoàn thành.

## 4. Lưu và chèn khi được yêu cầu

- Với bản xem trong chat, lưu vào thư mục tạm/đầu ra được phép ghi và bàn giao
  hình; không tự chèn vào note hay commit file xem trước.
- Với yêu cầu lưu vào note, đọc [add-note-image](../add-note-image/SKILL.md).
  Lưu `images/<concept>-mindmap.png` cạnh note hoặc nơi chứa ảnh đầu ra đã dùng;
  giữ SVG cạnh PNG. Không ghi vào `materials/`, `lectures/_raw/` hay `brief/`.
- Kiểm tra mind map đã có trước khi tạo/chèn trùng; không ghi đè ảnh cũ nếu chưa
  được yêu cầu thay. Chèn gần phần khái niệm hoặc tổng kết của đúng mục, giữ nguyên
  cấu trúc và lý thuyết của note. Dùng alt text nêu concept và các nhánh chính.
- Caption ngắn: ghi hình do AI dựng, nguồn kiến thức đã đối chiếu, phần tự tổng hợp
  nếu có và link SVG. Không nhét đường dẫn nguồn dài vào từng node của hình.
- Nếu cần **Đọc hình**, đặt `**Đọc hình:**` trên dòng riêng, chừa một dòng trống
  rồi dùng bullet list ngắn. Không diễn giải lại toàn bộ mind map thành bài giảng.

## 5. Kiểm tra và bàn giao

- Xác nhận hình chỉ xoay quanh một concept, có khái niệm ngắn gọn và đủ các ý
  cốt lõi; quan hệ cha–con đúng, không bỏ điều kiện làm sai ý nghĩa.
- Kiểm tra file mở được và link tương đối resolve từ note. Với Markdown đã sửa,
  chạy `scripts/toc.py check` và `git diff --check`; đổi heading thì cập nhật TOC
  bằng `scripts/toc.py gen`. Chỉ báo đã xem render Markdown nếu thực sự đã xem.
- Nếu cập nhật repo, review diff và chỉ stage ảnh/SVG/note thuộc yêu cầu; commit
  theo `AGENTS.md`, ví dụ `IT007: thêm mind map address binding vào L08`. Không tự push.
- Bàn giao hình, nguồn ngắn và link note nếu có; nói ngắn map gồm những nhánh gì.
  Báo đúng trạng thái nếu mới là bản xem trước hoặc chưa render được.
