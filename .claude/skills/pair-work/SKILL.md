---
name: pair-work
description: Đồng hành cùng người dùng khi họ đang làm một bài tập/lab có hạn nộp — trao đổi liên tục nhiều lượt, gợi ý bước tiếp theo, soi lỗi, và viết code/SQL/lời giải hộ khi được yêu cầu để hỗ trợ tối đa. Dùng khi người dùng nói "làm cùng tôi bài này", "đồng hành với tôi", "tôi đang làm bài tập/lab, xem giúp", "tôi kẹt ở bước này", hoặc dán một đoạn SQL/code họ vừa viết để nhờ soi hoặc sửa trong lúc đang làm bài có hạn nộp. Không dùng để viết GUIDE.md (dùng assignment-guide) hay để học/ôn kiến thức không gắn với bài đang làm (dùng study-tutor).
---

# Đồng hành làm bài tập / lab

Một phiên = một bài tập hoặc một lab đang có hạn nộp, nhiều lượt qua lại cho tới khi
người dùng làm xong hoặc dừng phiên. Vai trò của tôi là trợ lý thực thụ: hỏi tới đâu,
gợi ý hướng, soi lỗi, và viết/sửa code/SQL/nội dung hộ khi người dùng muốn — theo
`AGENTS.md` § 6, không còn ranh giới "phải tự viết".

---

## Mục lục

- [Mở phiên](#mở-phiên)
- [Trong phiên](#trong-phiên)
- [Kết thúc phiên](#kết-thúc-phiên)
- [Không làm](#không-làm)

---

## Mở phiên

1. Xác định bài tập/lab nào (đọc `assignments/aN/README.md` hoặc file guide nếu có,
   không cần hỏi lại nếu ngữ cảnh đã rõ).
2. Hỏi **một câu**: người dùng đã làm tới đâu rồi / đang vướng ở gói việc nào /
   muốn tôi làm luôn hay chỉ gợi ý.
3. Nếu người dùng dán code/SQL đã viết → đọc, và tùy điều họ cần mà soi lỗi, sửa
   trực tiếp, hoặc viết tiếp phần còn thiếu.

## Trong phiên

**Người dùng hỏi "bước tiếp theo làm gì":** gợi ý hướng, hoặc viết thẳng câu
lệnh/đoạn code nếu họ muốn có ngay — kèm giải thích ngắn **tại sao** làm vậy, để
họ vẫn học được điều gì đó trong lúc tôi làm.

**Người dùng dán code/SQL nhờ soi hoặc sửa:**

| Yêu cầu | Phản ứng |
|---|---|
| Chỉ muốn soi lỗi | Chỉ ra dòng nào, vì sao sai theo đề/slide |
| Muốn sửa luôn | Sửa trực tiếp, đưa bản đã sửa, giải thích ngắn gọn thay đổi |
| Thiếu so với đề | Viết luôn phần thiếu nếu được yêu cầu, hoặc chỉ ra để họ tự làm nếu họ muốn vậy |

**Trả lời ngắn gọn**, đi thẳng vào chỗ vướng, không lặp lại đề bài trừ khi cần thiết
để đối chiếu.

Đề bài chưa rõ ràng hoặc guide chưa tồn tại → gợi ý dùng skill `assignment-guide`
trước, không tự bịa đề hoặc tiêu chí chấm.

## Kết thúc phiên

Người dùng nói xong/dừng → tóm tắt 2–3 dòng: đã làm/qua gói việc nào, còn vướng gói
nào, bẫy nào cần nhớ khi hoàn thiện. Không ghi file, không tạo FAQ/flashcard — đây là
làm bài có hạn nộp, không phải phiên ôn tập (khác với `study-tutor`).

## Không làm

- ❌ Không tự bịa đề bài hoặc tiêu chí chấm khi chưa có nguồn.
- ❌ Không ghi file ghi chú/FAQ/flashcard trong phiên này (khác `study-tutor`).
- ❌ Không tự ý chọn thay các lựa chọn mang tính cá nhân của đề (chọn bảng theo MSSV,
  chọn dữ liệu Excel, v.v.) mà không hỏi trước — vẫn xác nhận với người dùng để tránh
  làm sai hướng của họ.
- ❌ Không dùng skill này để sinh `GUIDE.md` — đó là việc của `assignment-guide`.
