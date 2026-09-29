# IE103 — Đồ án 1

| | |
|---|---|
| Tên đề tài | **Xây dựng hệ thống Quản lý Khách sạn — CSDL, Backend và Frontend** [U2] |
| Môn | `IE103` Quản lý thông tin |
| Giao ở buổi | ❓ |
| **Hạn nộp** | **❓ chưa có ngày/giờ chính thức** · có thể cuối tháng 10/2026 [U1] |
| Tỷ trọng điểm | **50%** — slide giới thiệu, trang 11 [S1] |
| Làm nhóm / cá nhân | **Nhóm** [U1] |
| Đề gốc | [Hướng dẫn đồ án.pdf](<brief/Hướng dẫn đồ án.pdf>) [S2] |
| **File nộp** | `❓ chưa xác nhận` |
| Trạng thái | ⬜ chưa bắt đầu |

> Task **T027** trong [`admin/tasks-2025-2026-S3.md`](../../../../../admin/tasks-2025-2026-S3.md), khoá `IE103/prj1`; hạn nộp còn `❓`.
>
> Số **1** là quy ước tổ chức trong repo cho đồ án môn học nêu ở [S1]; chưa có nguồn cho số thứ tự do giảng viên đặt.

---

## Mục lục

- [Đề bài](#đề-bài)
- [Tiêu chí chấm](#tiêu-chí-chấm)
- [Quy định báo cáo](#quy-định-báo-cáo)
- [Checklist](#checklist)
- [Thành viên và phân công](#thành-viên-và-phân-công)
- [Mốc thời gian](#mốc-thời-gian)
- [Kiến trúc / cách làm](#kiến-trúc--cách-làm)
- [Nhật ký](#nhật-ký)
- [Sau khi có điểm](#sau-khi-có-điểm)
- [Thư mục](#thư-mục)
- [Nguồn](#nguồn)

---

## Đề bài

**Yêu cầu chung của giảng viên:** phân tích, thiết kế CSDL cho một bài toán quản lý do sinh viên tự chọn [S2, trang 1].

**Nhóm đã chọn:** hệ thống **Quản lý Khách sạn**, gồm **CSDL, Backend và Frontend** [U1, U2]. Đề gốc có gợi ý quản lý đặt phòng khách sạn với thông tin khách, phòng trống, nhiều loại phòng và thanh toán [S2, trang 3]; đây là gợi ý, chưa phải danh sách chức năng nhóm đã chốt.

| Phần | Yêu cầu phải đáp ứng | Nguồn |
|---|---|---|
| Mô tả bài toán | Phát biểu bài toán, mục tiêu, đối tượng sử dụng; mô tả từng bước quy trình thực tế, vẽ sơ đồ nếu có | [S2], trang 1 |
| Phân tích và thiết kế | Liệt kê/mô tả chức năng; thực thể, thuộc tính, mối quan hệ và ràng buộc; mô hình mức quan niệm (ERD với mô hình quan hệ); chuyển sang mức logic, giải thích các bảng (tân từ) | [S2], trang 1 |
| Cài đặt CSDL | Tạo bảng, primary key (khoá chính), foreign key (khoá ngoại), các ràng buộc nếu có; **10–20 dòng dữ liệu cho mỗi quan hệ**, bao quát nhiều trường hợp | [S2], trang 1 |
| Xử lý thông tin | **5 Stored Procedure, 5 Trigger, 3 Function, 2 Cursor** | [S2], trang 1 |
| An toàn thông tin | Xác thực, phân quyền, **Import, Export, Backup, Restore** | [S2], trang 1 |
| Trình bày thông tin | **5 Report** | [S2], trang 1 |
| Hệ quản trị CSDL | Sử dụng **SQL Server hoặc MySQL**; nhóm chưa chốt lựa chọn | [S2], trang 2 |
| Chức năng và demo | Mô tả các chức năng từ phần phân tích; đề có lưu ý demo trên Web, Desktop, Mobile… | [S2], trang 2 |
| Báo cáo và trình bày | Có file báo cáo, phần trình bày và link video demo trong báo cáo | [S1], trang 11; [S2], trang 3 |

> ❓ **CẦN XÁC MINH:** trang 2 vừa ghi “Các chức năng của hệ thống (Từ phần phân tích) (**chỉ mô tả**)”, vừa ghi “**Demo cho các chức năng**”. Giữ cả hai yêu cầu; cần xác nhận mức demo phải hoàn thiện. Nhóm đã chọn làm Backend và Frontend [U2], nhưng chưa chốt màn hình/chức năng hoặc nền tảng cụ thể.

Chưa có quy định rõ về nộp mã nguồn, slide riêng, định dạng/tên file và kênh nộp. `lectures/_raw/` và `materials/syllabus/` chưa có tài liệu tại ngày 2026-09-29; buổi giao chưa xác định.

---

## Tiêu chí chấm

| Nội dung | Thông tin | Nguồn |
|---|---|---|
| Tỷ trọng trong điểm môn | **50%** | [S1], trang 11 |
| Thành phần đánh giá | File báo cáo và trình bày | [S1], trang 11 |
| Nội dung cần có | Các yêu cầu ở mục **Đề bài** và **Quy định báo cáo** | [S2], trang 1–3; đề không chia điểm từng phần |
| Sao chép / độ trùng lặp | Không sao chép nội dung trên mạng; kiểm tra bằng Turnitin; **trùng lặp trên 25% → điểm 0** | [S2], trang 3 |
| Điểm từng phần, tiêu chí demo, mức trừ điểm khác | ❓ chưa công bố trong nguồn hiện có | Cần giảng viên xác nhận |

---

## Quy định báo cáo

- Theo **mẫu cung cấp sẵn**, có **trang bìa và mục lục**, tiêu đề cụ thể và phù hợp [S2, trang 3]. ❓ Chưa có file mẫu riêng của giảng viên trong `brief/`. Repo có [ASSIGNMENT_TEMPLATE.docx](../../../../../templates/ASSIGNMENT_TEMPLATE.docx); cần đối chiếu với mẫu được yêu cầu trước khi dùng.
- Ngắn gọn, súc tích, **tối đa 20 trang, không tính mục lục và tài liệu tham khảo** [S2, trang 3]. Đề không nói loại trừ trang bìa khỏi giới hạn.
- Chỉ nên dùng hình về **cấu trúc bảng, kết quả thực nghiệm, demo**; không nên thêm logo công nghệ hay lịch sử hình thành [S2, trang 3].
- Cuối phần trình bày đưa **link video clip demo trực tiếp vào file báo cáo**; có thể lưu video trên Google Drive hoặc YouTube [S2, trang 3].
- **Không sao chép nội dung trên mạng**; quy định Turnitin ở mục **Tiêu chí chấm** [S2, trang 3].

Mẫu tên file, định dạng `.docx`/`.pdf`/`.zip`, nơi nộp và việc nộp kèm source code: **❓ chưa xác nhận**. Chưa tạo file nộp.

---

## Checklist

- [x] Lưu đề gốc vào `brief/` và trích yêu cầu [S2].
- [x] Xác nhận làm nhóm [U1].
- [x] Xác nhận đề tài Quản lý Khách sạn, phạm vi CSDL + Backend + Frontend [U2].
- [ ] Bổ sung tên thành viên và phân công.
- [ ] Xác nhận hạn nộp, lịch trình bày, mẫu tên/định dạng file và nơi nộp.
- [ ] Chốt chức năng, quy trình khách sạn và mức demo cần hoàn thiện [S2, trang 1–2; U2].
- [ ] Chọn SQL Server hoặc MySQL, công nghệ Backend/Frontend và ghi lý do ở **Kiến trúc / cách làm** [S2, trang 2; U2].
- [ ] Viết mô tả bài toán, mục tiêu, đối tượng sử dụng, các bước quy trình [S2, trang 1].
- [ ] Liệt kê chức năng, thực thể/thuộc tính, quan hệ, ràng buộc; vẽ ERD, chuyển mức logic và ghi tân từ [S2, trang 1].
- [ ] Tạo CSDL, bảng, khoá và ràng buộc; nạp 10–20 dòng dữ liệu cho mỗi quan hệ [S2, trang 1].
- [ ] Hoàn thành 5 Stored Procedure, 5 Trigger, 3 Function và 2 Cursor [S2, trang 1].
- [ ] Thực hiện xác thực, phân quyền, Import, Export, Backup và Restore [S2, trang 1].
- [ ] Hoàn thành 5 Report [S2, trang 1].
- [ ] Xây dựng, tích hợp Backend và Frontend theo phạm vi nhóm đã chốt [U2].
- [ ] Chuẩn bị demo, quay video và chèn link vào báo cáo [S2, trang 2–3].
- [ ] Hoàn thành báo cáo đúng mẫu, giới hạn trang và quy định nội dung; rà soát sao chép/trích dẫn [S2, trang 3].
- [ ] Chuẩn bị và thực hiện phần trình bày [S1, trang 11].
- [ ] Nộp bài, ghi ngày nộp và cập nhật trạng thái task.

Checklist kết hợp yêu cầu giảng viên [S1, S2], phạm vi nhóm chọn [U2] và các bước tổ chức công việc. Các mục chưa tick là việc cần theo dõi, không suy ra tiến độ thực tế từ việc tạo khung repo.

---

## Thành viên và phân công

| Tên | Phụ trách |
|---|---|
| Nguyễn Quốc Trung | ❓ chưa xác nhận vai trò/phần việc |

**Làm nhóm** [U1]; ❓ chưa có danh sách đồng đội và phân công.

> Repo public — chỉ ghi tên đồng đội, **không ghi MSSV, email, số điện thoại** của người khác.

---

## Mốc thời gian

| Mốc | Ngày | Do ai đặt | Trạng thái | Nguồn / ghi chú |
|---|---|---|---|---|
| **Nộp đồ án** | **❓ ngày/giờ chính thức** | giảng viên — chờ xác nhận | ⬜ | Khoá `IE103/prj1`; người dùng dự kiến có thể cuối tháng 10/2026 [U1], chưa phải hạn đã chốt |
| Trình bày đồ án | ❓ chưa biết | giảng viên — chờ công bố lịch | ⬜ | [S1], trang 11; chưa có mốc ngày để ghi task riêng |

Chưa có mốc nội bộ do nhóm/tự đặt. Không suy ngày nộp hay ngày trình bày từ lịch thi của môn khác.

“Có thể cuối tháng 10” [U1] là thông tin dự kiến, chưa đủ để quy thành một ngày tuyệt đối; chưa dùng làm Deadline trên Notion hoặc tạo sự kiện Calendar.

**Do ai đặt:** `giảng viên` → phải có trong `admin/tasks-2025-2026-S3.md` · `nhóm` / `tự đặt` → chỉ ở đây và Notion.

---

## Kiến trúc / cách làm

**Đã chốt:** Quản lý Khách sạn với CSDL, Backend và Frontend [U2].

| Quyết định | Trạng thái |
|---|---|
| Danh sách chức năng, vai trò người dùng, quy trình nghiệp vụ | ❓ nhóm chưa cung cấp |
| Hệ quản trị CSDL | ❓ chọn SQL Server hoặc MySQL theo [S2], trang 2 |
| Ngôn ngữ/framework Backend và Frontend | ❓ chưa chốt |
| Mô hình dữ liệu, ERD, cấu trúc bảng | ❓ chưa thiết kế |
| Phạm vi demo và cách triển khai | ❓ chưa chốt |

Ghi phương án, sơ đồ và lý do lựa chọn ở đây trước khi review. Chưa có mã nguồn hoặc thiết kế chi tiết trong khung này.

---

## Nhật ký

| Ngày | Việc đã làm | Vướng |
|---|---|---|
| 2026-09-29 | Tạo khung đồ án; đối chiếu trang 11 của [S1]; nối bảng theo dõi môn và task học kỳ; người dùng xác nhận làm nhóm, hạn có thể cuối tháng 10 [U1] | Thiếu đề bài, hạn chính thức, lịch trình bày, mẫu file và danh sách nhóm |
| 2026-09-29 | Nhận [S2], chuyển nguyên bản từ `docs/` sang `brief/`, đọc đủ 3 trang; bổ sung yêu cầu/checklist; xác nhận đề tài Quản lý Khách sạn [U2] | Còn hạn chính thức, lịch trình bày, mức demo, mẫu file, công nghệ và danh sách nhóm |

---

## Sau khi có điểm

Điểm: ❓ — sai ở đâu, vì sao, lần sau làm khác gì.

---

## Thư mục

| | |
|---|---|
| [`brief/`](brief/) | Đề bài gốc của giảng viên — chỉ đọc |
| [`docs/`](docs/) | Báo cáo, slide thuyết trình |
| [`src/`](src/) | Mã nguồn và cấu hình của project ứng dụng |
| [`snippets/`](snippets/) | Code, SQL và script rời rạc để thử nghiệm hoặc chạy độc lập; chưa cần cấu trúc project |
| [`images/`](images/) | Screenshot, sơ đồ, demo — tên tiếng Anh mô tả nội dung |

---

## Nguồn

- **[S1]** [00 - Gioi thieu.pdf](<../../materials/slides/00 - Gioi thieu.pdf#page=11>), trang 11 — tỷ trọng đồ án 50%, file báo cáo và trình bày. Đã đối chiếu trực tiếp trang PDF ngày 2026-09-29; ngày giảng/buổi giao chưa biết.
- **[S2]** [Hướng dẫn đồ án.pdf](<brief/Hướng dẫn đồ án.pdf>), trang 1–3 — đề bài, hệ quản trị được phép, gợi ý đề tài, demo, quy định báo cáo và Turnitin. Đã đối chiếu trực tiếp cả 3 trang ngày 2026-09-29; không ghi hạn nộp, lịch trình bày hoặc thang điểm chi tiết.
- **[U1]** Người dùng cung cấp trong phiên ngày 2026-09-29: “Làm nhóm, hạn nộp cuối có thể cuối tháng 10”. Hình thức nhóm đã xác nhận; thời hạn chỉ là dự kiến.
- **[U2]** Người dùng cung cấp trong phiên ngày 2026-09-29: “Đề tài về xây dựng hệ thống CSDL, Backend và Frontend Quản Lý Khách Sạn”.
- [Ghi chú quan trọng của IE103](../../IMPORTANT_NOTES.md) — tổng hợp thông tin tính điểm và quy định môn học có nguồn.
