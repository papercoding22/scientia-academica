# IE103 — Bài tập 3

| | |
|---|---|
| Tên bài | An ninh thông tin |
| Môn | `IE103` Quản lý thông tin |
| Buổi học | ❓ |
| **Hạn nộp** | **❓ chưa biết** |
| Tỷ trọng | Thuộc nhóm điểm quá trình |
| **File nộp** | `MSSV_HoTen_BTTH3.pdf` và `MSSV_HoTen_BTTH3.sql` |
| Trạng thái | ⬜ chưa làm |

> ✅ Đã ghi hạn nộp vào [`admin/deadlines.md`](../../../../../admin/deadlines.md)? — ❓
>
> 📄 Nếu đã có file `.docx`, nó được copy từ `templates/ASSIGNMENT_TEMPLATE.docx` — có trang
> bìa UIT và khung `Câu 1` · `Bảng` · `Kết luận`. Nếu cột **File nộp** còn `❓`, chưa được
> phép đoán mẫu tên: chờ chỉ dẫn của giảng viên hoặc một bài cùng loại đã nộp trước đó.

---

## Mục lục

- [Yêu cầu đề bài](#yêu-cầu-đề-bài)
- [Checklist](#checklist)
- [Hướng tiếp cận](#hướng-tiếp-cận)
- [Ghi chú trong quá trình làm](#ghi-chú-trong-quá-trình-làm)
- [Sau khi có điểm](#sau-khi-có-điểm)
- [Thư mục](#thư-mục)

---

## Yêu cầu đề bài

### Phần 1 — Tìm hiểu và thao tác trên SQL Server

1. **Tổ chức dữ liệu:** tìm hiểu và trình bày theo ý hiểu:
   - data type cho field và cách sử dụng;
   - dung lượng tối đa của một row và một table trong SQL Server;
   - ý nghĩa các System tables trong CSDL `master`: `Sysusers`, `Syssserver`, `Sysxlogin`;
   - số file tối thiểu khi tạo CSDL bằng `CREATE DATABASE AAA` và ý nghĩa từng file;
   - số user có thể connect đồng thời.
2. **Backup, delete, restore:** backup CSDL `AAA` ra `AAA.BAK`; sau đó xóa CSDL và restore lại từ file backup. Với **mỗi** thao tác backup, delete, restore phải thực hiện bằng:
   - giao diện SQL Server Management Studio, chụp các bước cần thiết, rõ nét;
   - câu lệnh SQL, đưa câu lệnh vào báo cáo.
3. **SQL Server Log:** mở `SQL Enterprise → Management → SQL Server Log`, trình bày các bước trên giao diện và giải thích ý nghĩa từng trường thông tin của bảng log.
4. **View:** phân tích liệu câu lệnh `INSERT` vào view `EmployeeNames` trong đề có thực hiện được không, và giải thích lý do dựa trên cấu trúc `Employees` và định nghĩa view.
5. **Trạng thái mã hóa:** xác định hình minh họa mô tả `data at rest`, `data in use`, hay `data in motion/transit`; giải thích bằng dấu hiệu trong hình.

### Phần 2 — Import/export, xác thực và phân quyền

1. **Import/export:** chọn một file dữ liệu sinh viên từ Excel để import vào SQL Server; chọn một table trong SQL Server để export ra Excel. Thực hiện bằng giao diện và chụp lại các bước.
2. **Xác thực người dùng:** tạo `u1` đến `u6`, tạo role `r1` đến `r3`, rồi gán thành viên: `u1 → r1`; `u2`, `u3 → r2`; `u4`, `u5`, `u6 → r3`. Thiết lập role theo đề: `r1` là thành viên `SysAdmin`; `r2` là thành viên `db_owner`, `db_accessadmin`; `r3` là thành viên `SysAdmin`, `db_owner`, `db_accessadmin`.
3. **Phân quyền người dùng:** trên CSDL Quản lý đề tài với ba table `T1`, `T2`, `T3` (chọn theo chữ số cuối MSSV trong bảng của đề gốc), tạo `U1`, `U2`, `U3` và thực hiện đúng các phát biểu `GRANT`, `DENY`, `REVOKE`:
   - cấp các quyền `SELECT`/`DELETE`, `UPDATE`/`DELETE`, `INSERT` theo từng user và table mà đề chỉ định;
   - từ chối quyền `INSERT` của `U1` trên hai table đề chỉ định và quyền `DELETE` của `U2` trên table đề chỉ định;
   - thu hồi quyền của `U1` trên `T1` và của `U3` trên `T2`.

### Quy cách nộp

- Nộp báo cáo PDF tên `MSSV_HoTen_BTTH3.pdf` và file SQL tên `MSSV_HoTen_BTTH3.sql`.
- Báo cáo chứa câu trả lời theo ý hiểu. Với thao tác thực hành, ảnh chụp phải theo từng bước, có tiêu đề từng bước; với yêu cầu code SQL, dán code vào báo cáo.
- Các câu lý thuyết không sao chép; cuối báo cáo có phần tài liệu tham khảo.
- Nộp qua `courses.uit.edu.vn`; **không nén file**.

> *Nguồn: đề gốc 4 trang, [`brief/`](brief/), chưa có thông tin buổi giao hoặc hạn nộp.*

---

## Checklist

- [ ] Đọc kỹ đề, xác định đúng yêu cầu
- [ ] Điền trang bìa file nộp (MÃ MÔN · MÔN HỌC · GVHD · Sinh viên · MSSV · Lớp)
- [ ] ❓
- [ ] Kiểm tra lại trước khi nộp
- [ ] Nộp đúng hạn

---

## Hướng tiếp cận

> ✍️ **Viết phần này TRƯỚC khi hỏi AI.**
> AI được cấu hình để không viết hộ lời giải khi bạn chưa có bản nháp
> (`AGENTS.md` § 6) — và đó là chủ ý, không phải hạn chế.

❓ *Chưa viết.*

---

## Ghi chú trong quá trình làm

| Ngày | Việc đã làm | Vướng ở đâu |
|---|---|---|
| | | |

Ảnh thực hành: [`images/`](images/) — đặt tên tiếng Anh mô tả (`step3-ping-result.png`)

---

## Sau khi có điểm

| | |
|---|---|
| Điểm | ❓ |
| Nhận xét của giảng viên | |
| Sai ở đâu, vì sao | |

---

## Thư mục

| | |
|---|---|
| [`brief/`](brief/) | Đề bài gốc từ giảng viên — **chỉ đọc** |
| [`resources/`](resources/) | Tài liệu tham khảo |
| [`images/`](images/) | Ảnh chụp quá trình làm bài |
