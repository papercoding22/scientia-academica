---
name: illustrate-mechanism
description: Tạo ảnh minh họa cơ chế hoạt động bằng các thành phần, trạng thái và tương tác theo từng bước, rồi chèn vào ghi chú Markdown liên quan. Dùng khi người dùng muốn nhìn cách một cơ chế vận hành, dữ liệu di chuyển hoặc trạng thái thay đổi, kể cả từ phiên học hiện tại. Đầu ra là hình mô tả hệ thống đang hoạt động, không phải infographic tổng hợp kiến thức; ảnh có sẵn dùng add-note-image.
---

# Minh họa cơ chế hoạt động

Giúp người học nhìn hình là lần theo được **ai làm gì, tác động vào đâu và tạo ra
thay đổi nào**. Kế thừa cách đối chiếu nguồn, kiểm tra ảnh và cập nhật note của
`illustrate-concept`; thiết kế hình xoay quanh hoạt động của chính hệ thống.

---

## Mục lục

- [1. Xác định cơ chế và đích lưu](#1-xác-định-cơ-chế-và-đích-lưu)
- [2. Lập diễn biến trước khi vẽ](#2-lập-diễn-biến-trước-khi-vẽ)
- [3. Dựng cảnh thể hiện hoạt động](#3-dựng-cảnh-thể-hiện-hoạt-động)
- [4. Tạo ảnh và kiểm tra cơ chế](#4-tạo-ảnh-và-kiểm-tra-cơ-chế)
- [5. Chèn vào note và bàn giao](#5-chèn-vào-note-và-bàn-giao)

---

## 1. Xác định cơ chế và đích lưu

```text
$illustrate-mechanism Dynamic loading vào L08 IT007 đang học
$illustrate-mechanism Cơ chế stub ở lần gọi đầu và lần gọi sau, thêm vào note hiện tại
$illustrate-mechanism Minh họa CPU tra TLB rồi truy cập RAM, chỉ tạo ảnh xem trước
```

- Đọc `AGENTS.md`, kiểm tra Git; lấy cơ chế và note từ yêu cầu hoặc phiên học hiện
  tại. Chỉ hỏi khi chưa xác định được cơ chế hoặc có nhiều note đích hợp lý.
- Mặc định tạo ảnh và chèn vào note đã xác định. Nếu người dùng chỉ muốn ảnh hoặc
  bản xem trước, thực hiện đúng phạm vi đó. Không tự tạo lecture hay sửa FAQ,
  flashcard, `IMPORTANT_NOTES.md`. Yêu cầu tạo ảnh vào note cho phép ghi phần này
  ngay trong phiên `study-tutor`, không cần chờ cuối phiên để hỏi duyệt lại.
- Đọc mục liên quan, đoạn lân cận và ảnh đã có. Ưu tiên nguồn được note dẫn;
  kiểm tra slide/giáo trình khi mô tả còn thiếu hoặc có dấu hiệu sai. Giữ nhãn
  nguồn thực để dẫn dưới ảnh; ví dụ tự đặt, giả thiết và phần ngoài slide phải rõ.
- Chỉ bao quát một cơ chế hoặc một phép so sánh cơ chế có cùng tình huống đầu vào.
  Infographic tóm tắt định nghĩa/ưu nhược điểm dùng `illustrate-concept`; ảnh đã
  có chỉ cần chèn dùng `add-note-image`. Không tự mở rộng thành slide deck.

## 2. Lập diễn biến trước khi vẽ

Xác định ngắn gọn các ý sau từ nguồn, không cần tạo thêm file kế hoạch:

- **Thành phần:** đối tượng nào tham gia, nằm ở đâu; cái gì dùng chung, cái gì riêng.
- **Ban đầu:** dữ liệu, tài nguyên, địa chỉ hoặc trạng thái đang như thế nào.
- **Kích hoạt:** sự kiện nào khiến bước tiếp theo xảy ra.
- **Diễn biến:** thành phần nào thực hiện hành động gì; dữ liệu/quyền sở hữu/trạng
  thái thay đổi thế nào; điều kiện nào dẫn đến nhánh khác.
- **Kết quả:** cái gì đã đổi và cái gì vẫn giữ nguyên; lần tiếp theo có khác không.

Dùng tình huống nhỏ, cụ thể và tự kiểm tra từng bước. Không bịa bước trung gian
để hình trông liền mạch. Chỗ chưa đủ nguồn thì thu hẹp hình hoặc ghi rõ giới hạn;
không trình bày giả định như hành vi luôn đúng của hệ thống thực.

## 3. Dựng cảnh thể hiện hoạt động

- Vẽ các thành phần thật của mô hình và quan hệ của chúng: CPU, RAM, ổ đĩa,
  process, vùng nhớ, hàng đợi, bảng địa chỉ… Với cơ chế vật lý, dùng bộ phận và
  hình cắt lớp khi cần thấy bên trong. Tránh thay cơ chế bằng icon trang trí.
- Chọn một cảnh có mũi tên đánh số, hoặc chuỗi khung trước/trong/sau khi hoạt
  động. Giữ vị trí, màu, tên và hình dạng của cùng một đối tượng xuyên các khung
  để người đọc thấy **sự thay đổi**. Đối chiếu hai cơ chế bằng cùng một ví dụ.
- Mỗi mũi tên phải có nghĩa: gọi hàm, chuyển dữ liệu, tra bảng, ánh xạ, cấp phát…
  Không dùng cùng một kiểu mũi tên cho cả di chuyển dữ liệu và quan hệ tham chiếu
  mà không phân biệt. Không vẽ mã/dữ liệu di chuyển nếu thực tế chỉ đổi con trỏ.
- Nhãn tiếng Việt có dấu, thuật ngữ kỹ thuật giữ tiếng Anh; nhãn ngắn đặt sát
  đối tượng/hành động. Dùng số bước, vị trí và ký hiệu cùng màu; chữ đọc được ở
  kích thước chèn Markdown. Số liệu, đơn vị, hướng đi và ranh giới phải chính xác.
- **Không dựng poster infographic:** không chia trang thành thẻ “định nghĩa”,
  “ưu điểm”, “lưu ý”, không nhét đoạn văn vào hộp, không trang trí bằng icon rồi
  để toàn bộ lời giải trong chữ. Các khung phải cho thấy cùng hệ thống đang đổi
  trạng thái. Flowchart chỉ có tên bước không đủ nếu cơ chế cần thấy bên trong.
- Giữ trực giác và analogy đời thường trong lời dẫn/caption khi hữu ích; hình
  chính thể hiện cơ chế kỹ thuật. Phần định nghĩa, giải thích dài và bảng chốt
  để trong note, không ép toàn bộ thứ tự giảng bài lên mặt ảnh.

Ví dụ bám phiên học: **dynamic loading** có thể vẽ thủ tục còn trên đĩa → có lời
gọi → nạp vào RAM → thực thi, và thể hiện phần nào đã có sẵn trong RAM. Không vẽ
thủ tục tự bị gỡ khỏi RAM ngay khi trả về nếu nguồn không nói vậy. Với **dynamic
linking**, tách việc tìm/lưu địa chỉ hàm khỏi việc nạp thư viện; nếu minh họa lần
gọi đầu mới tìm địa chỉ thì ghi rõ **lazy binding**. Đừng biến một biến thể thành
định nghĩa của toàn bộ dynamic linking.

## 4. Tạo ảnh và kiểm tra cơ chế

Chọn công cụ theo hình cần tạo và yêu cầu người dùng:

- Hình minh họa có vật thể, không gian hoặc hình cắt lớp: dùng skill `imagegen`
  nếu có, đọc hướng dẫn trước khi gọi công cụ. Prompt yêu cầu hình giải thích
  hoạt động với ít chữ, không phải infographic. Tôn trọng phong cách được chọn.
- Sơ đồ kỹ thuật cần chính xác từng nhãn, trạng thái, địa chỉ: có thể dựng SVG
  rồi render PNG bằng công cụ sẵn có; giữ SVG nguồn. Không mặc định mọi yêu cầu
  thành sơ đồ hộp và mũi tên nếu người dùng muốn hình minh họa có vật thể.
- Không bàn giao chỉ Mermaid/HTML thay cho ảnh được yêu cầu. Không hardcode
  tên công cụ, model hoặc đường dẫn cài đặt. Công cụ thiếu thì nói rõ giới hạn;
  không tự cài phần mềm hay chuyển sang API trả phí. Với `imagegen`, dùng phương
  án dự phòng theo hướng dẫn của chính skill đó.

Prompt hoặc bản đặc tả để dựng SVG cần nêu: **điều người đọc phải nhìn ra → các
thành phần và trạng thái ban đầu → sự kiện/bước chuyển → kết quả → bố cục và nhãn
chính xác → giả thiết và điều không được ngụ ý**. Không thêm kiến thức chưa kiểm
chứng trong quá trình tạo ảnh.

Mở ảnh kết quả thực tế; SVG cũng phải xem bản render. Đối chiếu chữ, số liệu,
mũi tên, thứ tự, phần dùng chung/riêng và ranh giới với diễn biến đã lập. Thử
che các lời giải dài: người đọc còn lần theo được cơ chế từ đối tượng và mũi
tên không? Nếu chưa, sửa bố cục thay vì thêm chữ. Chỉnh lỗi rồi xem lại; không
chèn ảnh biết là sai hoặc dùng caption để chữa một mũi tên/trạng thái sai.

## 5. Chèn vào note và bàn giao

- Đọc [add-note-image](../add-note-image/SKILL.md) để chọn vị trí, tránh trùng và
  kiểm tra link. Chèn sát đoạn giải thích cơ chế, giữ nguyên lý thuyết và cấu
  trúc note. Tái sử dụng ảnh đã phù hợp; không ghi đè ảnh cũ nếu chưa yêu cầu thay.
- Lưu đầu ra vào nơi chứa ảnh của note, mặc định
  `images/<mechanism>-mechanism.png` cạnh note; nếu dựng vector, lưu thêm SVG.
  Không ghi vào `materials/`, `lectures/_raw/` hoặc `brief/`.
- Alt text nêu diễn biến chính. Caption ghi ảnh do AI tạo, nguồn kiến thức đã
  đối chiếu, ví dụ tự đặt và giả thiết quan trọng; không gán ảnh mới thành slide
  của giảng viên.
- Nếu cần phần **Đọc hình**, đặt nhãn `**Đọc hình:**` trên dòng riêng, chừa một
  dòng trống rồi trình bày bằng **bullet list**. Mỗi bullet nêu một bước hoặc
  một ý, có thể mở đầu bằng nhãn đậm như **Hướng đọc**, **Gọi và nạp**, **Mũi tên**.
- Kiểm tra file mở được, link tương đối đúng, không trỏ tới file tạm. Chạy
  `scripts/toc.py check` cho Markdown sửa và `git diff --check`; thêm/đổi heading
  thì sinh mục lục bằng `scripts/toc.py gen`. Phân biệt việc xem ảnh với xem
  render Markdown; chỉ báo các bước đã thực hiện.
- Review diff, stage đúng ảnh, SVG nếu có và note của yêu cầu; commit theo repo,
  ví dụ `<MÃ MÔN>: minh họa cơ chế <chủ đề> trong <note>`. Không tự push.
- Bàn giao ảnh cùng link note và tên mục, nói rõ hình cho thấy bước chuyển nào.
  Nếu chỉ xem trước, không chèn hay commit vào note. Nếu dùng `imagegen`, bàn
  giao thêm nội dung mà skill đó yêu cầu; báo rõ phần chưa hoàn thành nếu có.
