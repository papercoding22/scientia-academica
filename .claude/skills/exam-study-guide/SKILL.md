---
name: exam-study-guide
description: Tạo hoặc cập nhật ghi chú ôn một chương từ các câu hỏi thuộc chương đó trong đề thi mẫu, gồm kiến thức chắt lọc, dẫn chiếu tài liệu và hướng dẫn suy luận từng câu. Dùng khi người dùng muốn tổng hợp kiến thức chương N từ đề mẫu, chắt lọc kiến thức theo câu hỏi, hoặc hướng dẫn từng câu của một chương; map và thống kê toàn đề dùng exam-map.
---

# Ôn từng chương từ đề thi mẫu

Biến các câu hỏi của **chương được yêu cầu** thành tài liệu học có thể đọc độc lập:
hiểu kiến thức nền trước, rồi biết cách vận dụng vào từng câu. Dùng cho mọi môn có
đề mẫu và tài liệu đối chiếu, không giới hạn ở IT007 hay câu trắc nghiệm.

Đầu ra mặc định: `<môn>/exam-prep/chapter<N>-exam-study-guide.md`.
Nếu người dùng chỉ định tên hoặc vị trí khác, dùng lựa chọn đó. Nhiều chương được
yêu cầu thì mặc định mỗi chương một file; chỉ gộp khi người dùng muốn gộp.

---

## Mục lục

- [Khi nào dùng và cách gọi](#khi-nào-dùng-và-cách-gọi)
- [1. Xác định phạm vi và nguồn](#1-xác-định-phạm-vi-và-nguồn)
- [2. Lọc đầy đủ câu hỏi thuộc chương](#2-lọc-đầy-đủ-câu-hỏi-thuộc-chương)
- [3. Chắt lọc kiến thức và hướng dẫn từng câu](#3-chắt-lọc-kiến-thức-và-hướng-dẫn-từng-câu)
- [4. Tổ chức file và cập nhật](#4-tổ-chức-file-và-cập-nhật)
- [5. Kiểm tra và bàn giao](#5-kiểm-tra-và-bàn-giao)

---

## Khi nào dùng và cách gọi

```text
$exam-study-guide semesters/2025-2026-S3/IT007-operating-systems chương 7
$exam-study-guide <đường-dẫn-đề> — chắt lọc kiến thức chương 5 và hướng dẫn từng câu
```

- Muốn biết toàn đề hỏi những chương nào, điểm và dạng câu ra sao → [exam-map](../exam-map/SKILL.md).
- Muốn học kiến thức của một chương **thông qua các câu trong đề** → skill này.
- Muốn hỏi đáp qua lại hoặc hướng dẫn một bài tập nộp → dùng `study-tutor` hoặc
  `assignment-guide` theo yêu cầu tương ứng.

Không cần tạo map toàn đề trước khi viết guide. Map có sẵn là chỉ mục giúp tìm nhanh,
không thay thế việc đọc đề và nguồn của từng câu.

## 1. Xác định phạm vi và nguồn

1. Lấy môn, học kỳ, chương và đề từ yêu cầu hoặc ngữ cảnh hiện có. Số chương theo
   tài liệu môn, **không suy ra từ số lecture**. Chỉ hỏi khi còn nhiều lựa chọn có
   ảnh hưởng đến đầu ra; không hỏi lại điều đã rõ.
2. Ưu tiên đề người dùng chỉ định. Nếu chưa chỉ định, tìm trong `exam-prep/` và
   `exam-map.md` của đúng môn. Nếu có nhiều đề mà chưa rõ cần dùng đề nào, nêu các
   lựa chọn cụ thể; không tự gộp tất cả.
3. Đọc file guide đã có nếu cập nhật, rồi tìm slide, giáo trình, lecture note hoặc
   knowledge map liên quan. Dùng slide/giáo trình để kiểm tra định nghĩa, note để
   bổ sung giải thích. Chỉ mở quy định thi trong `IMPORTANT_NOTES.md` khi cần diễn
   giải phạm vi hoặc yêu cầu thi.
4. Đề và tài liệu gốc là đầu vào chỉ đọc. Không di chuyển, đổi tên hoặc chỉnh sửa
   chúng; không tự tạo FAQ, flashcard, lịch ôn hay task bên ngoài.

Nếu thiếu đề, yêu cầu đường dẫn hoặc nội dung câu hỏi trước khi viết phần hướng dẫn.
Nếu đề có nhưng nguồn kiến thức thiếu, vẫn xử lý được phần đã có bằng chứng; đánh
dấu phần chưa đối chiếu và không bịa số slide, định nghĩa hoặc quy định thi.

## 2. Lọc đầy đủ câu hỏi thuộc chương

- Đọc toàn bộ đề, kể cả trang phụ lục và bảng trả lời. Với PDF, dùng skill PDF có
  sẵn trong phiên; kết hợp trích text và xem trang để kiểm tra hình, bảng, code,
  công thức và thứ tự phương án. Dữ liệu không đọc được phải ghi `❓ CẦN XÁC MINH`.
- Lập danh sách câu/ý với **mã đề hoặc tên file, số câu gốc, trang, nội dung hỏi,
  phương án, điểm nếu xác định được, mục chương và nguồn kiến thức**. Giữ số như
  `23a`, không đổi thành thứ tự mới trong chương; nhiều đề cần thêm mã nguồn để
  không lẫn hai câu cùng số.
- Xác định chương từ **kiến thức thực sự cần để giải**, đối chiếu slide/giáo trình.
  Tách từng ý a/b nếu thuộc chương khác nhau. Câu liên chương thì ghi rõ phần nào
  liên quan, chỉ giải thích thêm kiến thức ngoài chương đủ để xử lý câu đó.
- Phương án nhiễu có thể thuộc mục/chương khác: ghi lại khái niệm cần phân biệt,
  không biến guide thành bản tổng hợp cả môn.
- Điểm lấy theo đề hoặc hướng dẫn chấm có nguồn. Không tự chia đều điểm cho các ý;
  nếu dùng bảng trả lời để suy ra cách chia thì nói rõ căn cứ và kiểm tra tổng.
  Không cộng toàn bộ điểm câu liên chương vào từng chương gây đếm trùng; thiếu cách
  tách thì ghi riêng điểm câu và để điểm thuộc chương là `❓`.

Nếu chương không có câu nào trong đề đã đọc đủ, báo rõ và không tạo nội dung câu
hỏi giả. Không kết luận chương đó sẽ không thi. Nếu đề đọc chưa đủ, kết luận là
**chưa xác định được**, không phải “không có câu”.

## 3. Chắt lọc kiến thức và hướng dẫn từng câu

**Phần kiến thức:** gom các câu cùng khái niệm để giải thích một lần; sắp theo quan
hệ nền tảng → vận dụng, không bắt buộc theo thứ tự câu. Mỗi khối chỉ rõ dùng cho
câu nào và có nguồn cụ thể: tên/mã tài liệu + số trang/slide đã mở kiểm tra.

- Theo cách giải thích trong `AGENTS.md`: trực giác → analogy → ví dụ nhỏ → định
  nghĩa/công thức → code nếu phù hợp. Kết thúc khối bằng bảng hoặc ý chốt ngắn.
- Tập trung vào điều kiện áp dụng, sự khác biệt giữa khái niệm gần nhau và vì sao
  công thức/cơ chế tồn tại. Có luồng xử lý thì dùng sơ đồ ASCII hoặc Mermaid.
- Ví dụ tự dựng phải ghi rõ là minh họa, không gán cho giảng viên. Chọn bối cảnh
  phù hợp môn học và nền tảng người dùng; React/TypeScript là một lựa chọn khi hữu
  ích cho frontend, không bắt buộc cho mọi môn hoặc mọi khái niệm.
- Giữ khác biệt giữa mô hình học thuật và hành vi thư viện/hệ thống thực tế. Khi
  câu chữ đề rút gọn hoặc có nhiều cách hiểu, giải thích giới hạn thay vì biến nó
  thành quy tắc tuyệt đối.

**Phần từng câu:** giữ thứ tự và số câu gốc trong từng đề. Mỗi câu cần đủ thông tin
để người học biết mình phải làm gì:

| Thành phần | Nội dung |
|---|---|
| Đề hỏi và nguồn | Số trang, dữ kiện, phương án hoặc yêu cầu đầu ra; rút gọn phải ghi rõ, giữ nhãn và logic gốc |
| Kiến thức cần dùng | Trỏ về khối kiến thức tương ứng và trang/slide nguồn |
| Cách làm | Các bước nhận diện yêu cầu, áp dụng quy tắc, kiểm tra hoặc loại trừ; nêu lý do của bước khó |
| Bẫy và giả thiết | Chữ ĐÚNG/SAI/KHÔNG, đơn vị, thứ tự, điều kiện biên, thuật ngữ hay bị nhầm |
| Việc tự kiểm tra | Cách tự biết lập luận/kết quả có hợp lý và phần cần làm lại |

Điều chỉnh cách hướng dẫn theo dạng: câu tính toán nêu công thức, đơn vị và cách
thế số; mô phỏng giải thuật có bảng trạng thái; phân tích code chỉ ra dữ liệu chung,
điểm xen kẽ hoặc bất biến; điền thuật ngữ nhắc ngôn ngữ và số từ đúng như đề.

Mặc định hướng dẫn để người học tự chọn/điền kết quả, như file mẫu. Nếu người dùng
yêu cầu đáp án hoặc lời giải, cung cấp kèm lập luận trong `<details>` và phần cần
tự làm lại; không hỏi lại để xin phép. Phân biệt **đáp án chính thức có nguồn** với
**đáp án suy luận**. Khi câu hỏi mơ hồ hoặc thiếu dữ kiện, ghi các cách hiểu và giới
hạn kết luận thay vì ép một đáp án chắc chắn.

## 4. Tổ chức file và cập nhật

File mẫu để tham khảo mức độ hướng dẫn khi cần:
[IT007 Chương 5](../../../semesters/2025-2026-S3/IT007-operating-systems/exam-prep/chapter5-exam-study-guide.md).
Dùng cấu trúc phù hợp nội dung mới; không sao chép số câu, điểm, kiến thức hay kết
quả kiểm chứng của mẫu sang môn/chương khác.

Khung đầu ra gợi ý:

1. **Thông tin đầu file:** môn/chương, đề nguồn và mã đề, ngày cập nhật, phạm vi
   câu/ý, điểm có căn cứ, cách dùng, tình trạng nguồn/đáp án chính thức.
2. **Mục lục** và **bảng câu hỏi thuộc chương**: câu, trang đề, kiến thức, việc cần
   làm, điểm; ghi phần chưa xác minh ngay cạnh dữ kiện liên quan.
3. **Kiến thức chắt lọc:** các khối khái niệm có liên hệ câu hỏi và nguồn.
4. **Hướng dẫn từng câu:** theo bảng thành phần ở mục 3.
5. **Ví dụ vận dụng/code:** chỉ thêm khi giúp hiểu hoặc kiểm chứng; có thể gộp ngay
   trong khối kiến thức, không cần tạo một chương trình hay ứng dụng mới.
6. **Tự kiểm tra:** 5 câu recall, gợi ý/đáp án gập trong `<details>`.
7. **Nguồn** và **Bạn cần tự làm lại phần nào:** link nguồn cụ thể, danh sách việc
   luyện lại hoặc bảng tự ghi lựa chọn.

Khi đã có guide, cập nhật phần bị ảnh hưởng, giữ ghi chú/lựa chọn của người dùng và
nguồn đề cũ còn trong phạm vi. Không tạo bản `v2` chỉ để tránh đọc bản hiện có.
Thêm link ở dòng `exam-prep/` trong README môn và ở `exam-map.md` nếu map đã có;
không chạy lại toàn bộ blueprint chỉ để thêm link. Không ghi suy luận từ đề mẫu
vào `IMPORTANT_NOTES.md` như lời giảng viên.

## 5. Kiểm tra và bàn giao

- Đối chiếu danh sách đã lọc với bảng câu hỏi **và** các mục hướng dẫn: đủ mỗi
  câu/ý trong phạm vi, không sót/trùng hoặc đánh nhầm mã đề. Kiểm tra lại nhãn đáp
  án, hình/code và dữ kiện của câu có nhiều phương án gần giống nhau.
- Kiểm tổng điểm bằng công cụ khi có dữ kiện; điểm liên chương/điểm chưa rõ phải
  được ghi riêng. Không dùng tỷ trọng của một đề để cam kết đề thật.
- Kiểm nguồn dẫn: số trang/slide tồn tại và nội dung thực sự hỗ trợ nhận định;
  link tương đối trỏ được đến đúng file. Không xem kiểm tra đường dẫn tồn tại là
  thay thế cho đọc nội dung.
- Nếu thêm code được mô tả là chạy được, trích **nguyên văn** để chạy/typecheck
  hoặc dùng cách kiểm chứng phù hợp. Không cài dependency vào repo học tập chỉ để
  thử ví dụ; dùng môi trường tạm. Ghi rõ điều đã kiểm tra, không báo đã thử UI khi
  mới kiểm tra logic. Với bài tính/mô phỏng, kiểm tra kết quả bằng phương pháp độc
  lập hoặc công cụ phù hợp.
- Dùng `scripts/toc.py gen <file>` để sinh mục lục, rồi
  `scripts/toc.py check <các-file-markdown-đã-sửa>` và `git diff --check`. Không để
  placeholder trong đầu ra; xem lại cả file mới chưa được Git track.
- Theo quy ước repo, commit riêng các file của việc này với message như
  `<MÃ MÔN>: hướng dẫn ôn chương <N> từ đề mẫu`; không push nếu chưa được yêu cầu.
- Bàn giao link guide, số câu/ý, nội dung chính và điểm chưa xác minh nếu có.
  Không cần xin duyệt lại trước khi tạo file mà người dùng đã yêu cầu.
