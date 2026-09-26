---
name: task-summary
description: Tổng hợp việc cần làm, hạn nộp, lịch thi và mốc nhóm của các môn trong repo thành bảng ngắn có nguồn, trạng thái và thứ tự ưu tiên. Dùng khi người dùng hỏi "tôi còn việc gì", "tóm tắt task và deadline", "tuần này cần làm gì", "bài nào quá hạn" hoặc muốn xem việc của một môn/học kỳ. Không tự đồng bộ Notion hay xếp lịch ôn thi.
---

# Tóm tắt việc cần làm và deadline

Giúp người dùng biết **cần làm gì, hạn khi nào, việc nào nên xử lý trước**.
Mặc định trả báo cáo trong chat dựa trên repo; không tạo thêm một bảng deadline
lưu riêng dễ lệch với nguồn. Không thực hiện các task trong lúc tổng hợp.

---

## Mục lục

- [1. Xác định phạm vi và thời điểm](#1-xác-định-phạm-vi-và-thời-điểm)
- [2. Đọc nguồn và gom việc](#2-đọc-nguồn-và-gom-việc)
- [3. Đối chiếu deadline và trạng thái](#3-đối-chiếu-deadline-và-trạng-thái)
- [4. Trình bày báo cáo ngắn](#4-trình-bày-báo-cáo-ngắn)
- [5. Giữ đúng phạm vi và kiểm tra cuối](#5-giữ-đúng-phạm-vi-và-kiểm-tra-cuối)

---

## 1. Xác định phạm vi và thời điểm

```text
$task-summary
$task-summary tuần này
$task-summary IE101, gồm các mốc nhóm
$task-summary các bài quá hạn trong học kỳ 2025-2026-S3
```

- Đọc `AGENTS.md`. Ưu tiên môn, học kỳ, khoảng ngày và nguồn người dùng chỉ định.
  Không có bộ lọc thì lấy các việc chưa xong của **học kỳ đang học**, gồm bài tập,
  lab, đồ án, mốc nhóm và lịch thi. Xác định kỳ đang học từ README/AGENTS hiện tại;
  không mặc định thư mục học kỳ có tên lớn nhất là kỳ đang học.
- Lấy ngày giờ hiện tại theo `Asia/Ho_Chi_Minh`, hoặc ngày chốt báo cáo người dùng
  yêu cầu. Ghi rõ thời điểm và phạm vi đã xem. Không hardcode ngày trong skill.
- "Tuần này" là thứ Hai–Chủ nhật của tuần hiện tại; "7 ngày tới" dùng khoảng
  từ hôm nay đến ngày hiện tại + 7 ngày, ghi rõ hai đầu mốc để tránh hiểu khác.
  Với bộ lọc thời gian, vẫn nhắc việc quá hạn/chưa biết hạn liên quan trong nhóm
  riêng, trừ khi người dùng yêu cầu chỉ đúng khoảng ngày đó.
- Thiếu một dữ kiện không cản trở việc tổng hợp thì đánh dấu `❓` và tiếp tục.
  Chỉ hỏi khi không xác định được phạm vi cần đọc.

## 2. Đọc nguồn và gom việc

| Nguồn | Lấy thông tin gì |
|---|---|
| `admin/tasks-<kỳ>.md` | Theo từng môn: hạn giảng viên, ngày/giờ thi, bài đang chờ và đã nộp |
| `semesters/<kỳ>/README.md`, README môn | Danh sách môn, bảng bài tập/đồ án để phát hiện việc bị bỏ sót |
| `assignments/<bài>/README.md` | Tên bài, trạng thái, sản phẩm cần nộp, phần việc còn lại |
| `projects/<đồ án>/README.md` | Trạng thái, mốc giảng viên và mốc nhóm/tự đặt, phân công |
| Tài liệu được nguồn trên dẫn | Chỉ mở phần cần xác minh hạn, yêu cầu hoặc trạng thái mâu thuẫn |

- Dùng `rg --files` tìm README trong phạm vi, `rg -n` tìm hạn/trạng thái/mốc rồi
  đọc ngữ cảnh liên quan. Không quét mọi checkbox trong lecture thành task.
- Mỗi bài/mốc là một việc. Gộp bản ghi trùng giữa admin và README theo học kỳ,
  môn, bài/đồ án và mốc; giữ các mốc khác nhau của cùng đồ án thành các dòng riêng.
  Không cộng dòng tổng đồ án và các mốc con thành số đồ án khác nhau.
- Tách **hạn giảng viên**, **lịch thi**, **mốc nhóm/tự đặt**. Hạn nộp cuối chưa biết
  vẫn là `❓`, kể cả đã có ngày ghép báo cáo hoặc ngày ôn xong.
- Bỏ các bước checklist mẫu như "đọc đề", "điền bìa", `❓`; chỉ nêu bước tiếp theo
  cụ thể khi có căn cứ. Thư mục khung thiếu tên/đề/hạn đưa vào **Cần xác minh**,
  không khẳng định đó là bài chắc chắn đã giao. Có file làm bài không chứng minh đã nộp.
- Quy tắc "nộp cuối buổi học" chỉ thành deadline cụ thể khi xác định được buổi
  học/ngày giao tương ứng. Không tự sinh bài hoặc hạn tuần tới từ một quy tắc lặp.

## 3. Đối chiếu deadline và trạng thái

- **Ngày tháng:** `admin/tasks-<kỳ>.md` là nguồn chính cho hạn giảng viên và lịch thi;
  mốc nhóm lấy từ README đồ án, không đẩy vào admin. Giữ cả hạn chính và hạn dự
  phòng có nguồn, không âm thầm thay hạn chính bằng hạn dự phòng.
- Nếu tìm thấy hạn giảng viên mới đã xác minh, bổ sung vào mục môn trong `admin/tasks-<kỳ>.md`
  theo `AGENTS.md` § 10, giữ nguồn và chạy kiểm tra/commit đúng file. Nếu yêu cầu
  hiện tại là **chỉ đọc**, chỉ báo hạn mới cần bổ sung. Nguồn mâu thuẫn thì nêu cả
  hai cùng căn cứ, không tự chọn ngày muộn hơn hoặc sửa một ngày thành chắc chắn.
- **Trạng thái:** ưu tiên cập nhật rõ của người dùng trong phiên; còn lại dùng
  trạng thái đã ghi ở nguồn và nói "theo repo". `✅ đã nộp`/hoàn tất không thuộc
  danh sách cần làm; "đã làm xong file" chưa đồng nghĩa "đã nộp". Mâu thuẫn giữa
  các nguồn thì ghi `❓ cần xác minh`, không suy từ ngày sửa file hoặc số checkbox.
- Tính lại **Còn lại** theo ngày chốt báo cáo; không chép cột đếm ngày có sẵn.
  Biết giờ thì so đến giờ; chỉ biết ngày thì dùng "hôm nay" trong ngày đó,
  không tự gán giờ nộp. Ngày cũ và trạng thái chưa xong: "quá hạn theo repo".
  Ngày thi đã qua chỉ là "lịch thi đã qua, chưa có kết quả/trạng thái" nếu thiếu
  bằng chứng, không kết luận người dùng bỏ thi.
- Mặc định không cần Notion/Calendar. Khi người dùng yêu cầu đối chiếu Notion,
  chỉ đọc các task liên quan bằng connector đang có; không có quyền/công cụ thì
  vẫn đưa phần repo và ghi rõ chưa đối chiếu. `admin/notion-map.json` chỉ là ánh
  xạ, không phải trạng thái live; không đưa ID/URL riêng vào file tracked.

## 4. Trình bày báo cáo ngắn

Mở bằng **ngày chốt, học kỳ/môn và nguồn đã kiểm tra**. Nêu việc đến hạn trong
7 ngày tới trước khi phân tích dài. Gom bảng thành các nhóm có dữ liệu:

1. **Quá hạn theo repo** — việc chưa xong, cần xử lý hoặc xác nhận đã nộp.
2. **Sắp đến hạn** — hôm nay và 7 ngày tới, hoặc khoảng ngày người dùng chọn.
3. **Sau đó** — việc còn lại có ngày, theo thứ tự deadline tăng dần.
4. **Chưa rõ hạn / cần xác minh** — vẫn là việc cần theo dõi, không giấu khỏi báo cáo.

| Môn | Việc cần làm | Deadline / loại mốc | Còn lại | Trạng thái | Nguồn |
|---|---|---|---|---|---|

- Dùng ngày tuyệt đối `YYYY-MM-DD`, kèm giờ khi biết. Giữ dấu `❓` đúng chỗ thiếu
  (ví dụ ngày thi biết nhưng loại giữa kỳ/cuối kỳ chưa xác nhận). Mỗi dòng có link
  tới nguồn cụ thể; có thể gắn link ở tên việc để bảng gọn.
- Lịch thi là một mốc riêng; không tự biến nó thành hàng loạt task ôn chưa được
  lên kế hoạch. Với việc nhóm, nêu phần người dùng phụ trách nếu đã có phân công;
  chưa rõ thì không quy tất cả việc nhóm thành việc cá nhân.
- Kết bằng **1–3 việc nên làm trước**, có lý do dựa trên hạn, phụ thuộc hoặc thông
  tin còn thiếu. Ghi rõ đây là đề xuất ưu tiên, không tự đổi Priority trên Notion
  hay đặt deadline mới. Không có việc trong khoảng đã đọc thì nói rõ phạm vi đó,
  không suy thành "không còn việc gì" khi vẫn thiếu dữ liệu.
- Mặc định bỏ việc đã xong; chỉ thêm nhóm lịch sử khi người dùng yêu cầu.

## 5. Giữ đúng phạm vi và kiểm tra cuối

- Trước khi trả lời, kiểm tra: có sót mốc nhóm không; việc đã nộp có lọt vào bảng
  không; bản ghi có trùng không; ngày đếm còn lại có khớp không; mọi dòng có nguồn
  và mức chắc chắn đúng không. Không khẳng định đã kiểm tra nguồn chưa mở được.
- Chỉ muốn xem tình hình thì trả báo cáo ngay, không yêu cầu duyệt báo cáo.
  Muốn **đồng bộ/tạo/sửa task Notion** → [notion-tasks](../notion-tasks/SKILL.md);
  muốn **xếp lịch ôn** → [exam-plan](../exam-plan/SKILL.md), theo phạm vi yêu cầu.
- Khi người dùng yêu cầu lưu báo cáo, ghi một snapshot có ngày chốt, nguồn và
  link tới deadline gốc; dùng đích họ chỉ định, hoặc `notes/task-summary-YYYY-MM-DD.md`
  trong môn nếu chỉ một môn, `admin/task-summary-YYYY-MM-DD.md` nếu nhiều môn.
  Không tạo file mới mỗi lần chỉ hỏi trong chat. File dài có TOC theo repo;
  kiểm tra link, `scripts/toc.py check`, `git diff --check` và commit đúng thay đổi.
