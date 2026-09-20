---
name: slide-knowledge-map
description: Đọc toàn bộ slide của một môn và tạo hoặc cập nhật knowledge map có dẫn chiếu slide trong chính materials/slides. Dùng khi người dùng muốn khám phá slide, lập bản đồ kiến thức, xem quan hệ giữa các chương, hoặc cập nhật knowledge map sau khi thêm slide.
---

# Knowledge map từ slide

Tạo một bản đồ cho **toàn bộ** slide của một môn, để thấy cấu trúc và quan hệ
giữa các ý thay vì một danh sách tóm tắt từng file. Kết quả được đặt cùng nguồn
ở `materials/slides/knowledge-map.md`; đây là ngoại lệ do người dùng yêu cầu,
không thay đổi bất kỳ slide gốc nào.

## Mục lục

- [Xác định phạm vi và đầu ra](#xác-định-phạm-vi-và-đầu-ra)
- [Đọc slide theo bằng chứng](#đọc-slide-theo-bằng-chứng)
- [Lập knowledge map](#lập-knowledge-map)
- [Kiểm tra và bàn giao](#kiểm-tra-và-bàn-giao)
- [Không làm](#không-làm)

---

## Xác định phạm vi và đầu ra

1. Xác định đúng thư mục môn từ mã môn hoặc đường dẫn người dùng đưa. Nếu chưa
   rõ môn nào, hỏi một câu ngắn thay vì quét slide của mọi môn trong repo.
2. Liệt kê tất cả file slide trong `materials/slides/`, gồm cả các phần A/B và
   slide có tên không theo `L<nn>`. Bỏ qua `.gitkeep` và `knowledge-map.md`.
3. Đọc `README.md` của môn để biết tên môn và đối chiếu tên chương. Không suy ra
   thứ tự buổi học chỉ từ tên file nếu slide không ghi rõ.
4. Đầu ra duy nhất là `materials/slides/knowledge-map.md`. Nếu file đã tồn tại,
   đọc nó trước và tái tạo từ toàn bộ nguồn hiện có; chỉ ghi đè file dẫn xuất này,
   không đụng tới slide gốc.

## Đọc slide theo bằng chứng

Trước khi đọc PDF, nạp skill `pdf:pdf` và theo quy trình của skill đó. Đọc **tất
cả trang** của mỗi slide, không chỉ tiêu đề, metadata hay trang đầu.

- Ưu tiên trích text để tìm outline, định nghĩa, công thức, ví dụ, bảng so sánh
  và tham chiếu chéo; khi text trống, vỡ nghĩa, hoặc sơ đồ mang ý chính, render
  trang liên quan và đọc bằng mắt.
- Với mỗi khái niệm hoặc quan hệ ghi lại nguồn tối thiểu là `tên file — slide
  <số>`. Khi không xác định được số slide, ghi rõ `slide chưa xác định`, không
  bịa số trang.
- Phân biệt rõ: định nghĩa · thành phần/cấu trúc · quy trình/cơ chế · quan hệ
  prerequisite · so sánh/đối lập · ứng dụng. Chỉ nối hai ý khi slide nói trực
  tiếp hoặc khi quan hệ logic hiển nhiên từ cấu trúc được dạy.
- Một slide scan hoặc sơ đồ không đọc được là khoảng trống dữ liệu: đưa vào mục
  cần xác minh, nêu đúng file và slide; không lấp bằng kiến thức ngoài slide.

## Lập knowledge map

Viết nội dung tiếng Việt có dấu, giữ nguyên technical term. Map phải giúp người
đọc trả lời ba câu: **môn này xây từ nền nào, mỗi chương bổ sung gì, và các ý
liên kết với nhau ra sao** — không biến thành bản chép lại slide.

`knowledge-map.md` dùng cấu trúc này:

````markdown
# Knowledge map — <tên môn>

> Phạm vi: <số> file slide · Cập nhật: YYYY-MM-DD
> Quy ước: mỗi nhãn `[S<n>]` dẫn tới file nguồn và số slide tương ứng.

## Mục lục
...

## Phạm vi nguồn
| Mã | File gốc | Chủ đề nhận diện | Trang/slide |
|---|---|---|---|

## Bức tranh lớn
Một đoạn ngắn: vấn đề trung tâm của môn, luồng học từ nền tảng đến ứng dụng.

```mermaid
flowchart LR
  A[Khái niệm nền] -->|prerequisite| B[Cơ chế]
  B -->|cho phép| C[Ứng dụng]
````

## Các cụm kiến thức
### <Cụm/chương>
- **Trả lời:** câu hỏi mà cụm này giải quyết.
- **Khái niệm lõi:** … `[S<n>]`
- **Quan hệ:** `A → B` — loại quan hệ và lý do, có nguồn.
- **Nối với cụm khác:** …

## Lộ trình học
1. … — cần biết gì trước và vì sao.

## Điểm dễ nhầm và ranh giới
| Cặp khái niệm | Khác ở đâu | Nguồn |
|---|---|---|

## Cần xác minh
- Chỉ các chỗ slide không đủ rõ hoặc không đọc được; nếu không có, ghi `Không có`.

## Nguồn
- [<tên file gốc>](<tên-file-được-URL-encode>) — slide 1–N
```

Thay Mermaid mẫu bằng graph thực tế của môn. Graph cần đủ nhỏ để đọc được; gom
khái niệm thành cụm thay vì tạo một node cho mỗi bullet. Nhãn cạnh phải chỉ loại
quan hệ như `prerequisite`, `gồm`, `biến đổi thành`, `so sánh với`, `dùng để`.
Khi map có từ 5 mục `##` hoặc vượt 100 dòng, tạo và kiểm tra mục lục bằng
`scripts/toc.py gen|check` theo `AGENTS.md` § 2b.

## Kiểm tra và bàn giao

- Đối chiếu bảng **Phạm vi nguồn** với danh sách file ban đầu: mỗi slide phải xuất
  hiện đúng một lần và không có file tưởng tượng.
- Kiểm tra mọi khái niệm trọng tâm và cạnh quan trọng có nguồn slide; gỡ quan hệ
  không chứng minh được thay vì làm graph đẹp nhưng sai.
- Đảm bảo Mermaid render được và link nguồn hoạt động. Chạy
  `scripts/toc.py check <knowledge-map.md>` nếu map có mục lục.
- Báo số slide đã đọc, số cụm kiến thức, các khoảng trống cần xác minh, cùng link
  tới map. Chỉ commit file map bằng message `<MÃ MÔN>: knowledge map từ slide`;
  không stage thay đổi không liên quan.

## Không làm

- Không sửa, đổi tên, di chuyển hoặc xoá file gốc trong `materials/slides/`.
- Không dùng slide để tự suy diễn gợi ý thi, deadline, quy định điểm, hay nội dung
  giảng viên đã nói ngoài slide.
- Không lập map từ một phần slide khi yêu cầu là toàn bộ slide; nếu thiếu hoặc đọc
  không được file nào, nêu chính xác file đó.
- Không tự tạo flashcard, lecture note, hay knowledge-base ngoài phạm vi map trừ
  khi người dùng yêu cầu thêm.
