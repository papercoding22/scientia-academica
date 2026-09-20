# IE103 — Bài tập 3 · Hướng dẫn Bài tập 2

| | |
|---|---|
| Bài tập | [`README.md`](README.md) |
| Phần trước | [Hướng dẫn Bài tập 1](guide-exercise-1.md) |
| Buổi học | ❓ chưa xác minh |
| **Hạn nộp** | **❓ chưa biết** |
| Ước lượng | 3–5 giờ, chưa tính thời gian cài hoặc xử lý lỗi SQL Server |

> ⚠️ **File này chỉ dạy CÁCH LÀM, không chứa lời giải.** Bạn tự chọn dữ liệu, tự lập ma trận quyền, tự viết câu lệnh và tự kiểm chứng kết quả.

---

## Mục lục

- [Đề yêu cầu gì](#đề-yêu-cầu-gì)
- [Chuẩn bị](#chuẩn-bị)
- [Gói 1 — Import và export](#gói-1--import-và-export)
- [Gói 2 — Xác thực và role](#gói-2--xác-thực-và-role)
- [Gói 3 — GRANT, DENY, REVOKE](#gói-3--grant-deny-revoke)
- [Checklist trước khi nộp](#checklist-trước-khi-nộp)
- [Phần bạn phải tự quyết](#phần-bạn-phải-tự-quyết)

---

## Đề yêu cầu gì

Bài tập 2 gồm ba gói: import/export dữ liệu qua giao diện, xác thực người dùng bằng user và role, rồi phân quyền trên CSDL Quản lý đề tài. Đầu ra cuối cùng vẫn là một báo cáo PDF và file `.sql` do bạn tự viết.

| Gói việc | Đầu ra phải có | Dạng |
|---|---|---|
| Import/export | Ảnh wizard và kết quả kiểm tra | Ảnh + diễn giải |
| User, role | Script tự viết và bằng chứng thực thi | `.sql` + ảnh/chứng minh |
| Phân quyền | Ma trận quyền, script và kiểm tra sau thay đổi | `.sql` + ảnh/chứng minh |

Nguồn yêu cầu là [đề gốc](brief/). Chưa có transcript nên guide không tự đặt thêm tiêu chí chấm hoặc hạn nộp.

## Chuẩn bị

**Công cụ:** SQL Server, SSMS, Excel, công cụ chụp màn hình, trình soạn PDF và file `.sql` để lưu lệnh của bạn.

1. Tạo một CSDL thực hành riêng; không dùng CSDL có dữ liệu quan trọng.
2. Mở [slide chương 5](../../materials/slides/05%20-%20Quan%20tri%20CSDL%20va%20an%20toan%20thong%20tin.pdf): phân quyền ở slide 10–40, import/export ở 69–81.
3. Tạo trước một bảng làm việc cho mapping user–role và một ma trận `user × table × thao tác`; chúng giúp tránh sót dòng khi viết SQL.
4. Trong báo cáo, dành riêng các mục đúng thứ tự đề; với mỗi ảnh, thêm một caption nói ảnh đang chứng minh bước nào.

## Gói 1 — Import và export

**Đề hỏi:** import một file dữ liệu sinh viên Excel vào SQL Server, rồi export một table SQL Server ra Excel, đều bằng giao diện.

**Đầu ra:** hai luồng ảnh theo bước và một kiểm tra kết quả ở đầu vào/đầu ra.

**Công cụ:** SSMS Import and Export Wizard, Excel và công cụ chụp màn hình.

**Các bước:**

1. Chuẩn bị file Excel nhỏ, có hàng tiêu đề nhất quán và dữ liệu đủ để nhận biết sau import. Tự kiểm tra kiểu dữ liệu trước khi mở wizard.
2. Chụp các điểm quyết định trong luồng import: chọn nguồn, chọn đích, mapping sheet/table, thực thi và kiểm tra table đích.
3. Chọn một table có dữ liệu rõ ràng cho export. Chụp các điểm quyết định tương ứng: nguồn, đích Excel, mapping, thực thi, mở file Excel để kiểm tra.
4. Đối chiếu số cột, số dòng và ít nhất một giá trị nhận diện ở mỗi đầu. Nếu wizard tự suy luận sai kiểu dữ liệu, ghi lỗi thật và cách bạn tự sửa thay vì che đi.

**Thế nào là đủ:** người chấm thấy được dữ liệu đã đi vào SQL Server và đi ra Excel, không chỉ thấy wizard được mở.

## Gói 2 — Xác thực và role

**Đề hỏi:** tạo `u1`–`u6`, `r1`–`r3`, gán đúng thành viên và role theo đề.

**Đầu ra:** script hoặc ảnh thể hiện thứ tự tạo login/user/role, mapping thành viên, và kiểm tra membership.

**Công cụ:** SSMS, cửa sổ truy vấn T-SQL, Object Explorer hoặc truy vấn metadata để đối chiếu membership.

**Các bước:**

1. Vẽ ma trận trước khi viết SQL: hàng là `u1`–`u6`, cột là `r1`–`r3`; chép mapping từ đề gốc vào ma trận. Kế bên là bảng quyền của từng role.
2. Phân biệt rõ login, database user và role. Slide 11–31 là phần nền: bạn phải biết đối tượng nào thuộc cấp server, đối tượng nào thuộc CSDL trước khi chạy lệnh.
3. Viết script theo thứ tự phụ thuộc: tạo đối tượng cấp server cần thiết, ánh xạ vào CSDL, tạo role, gán thành viên, rồi gán role hệ thống/database mà đề yêu cầu.
4. Sau mỗi nhóm lệnh, dùng giao diện hoặc truy vấn metadata để kiểm tra membership thực tế. Lưu bằng chứng đó vào báo cáo.

**Thế nào là đủ:** tất cả user và role trong đề xuất hiện đúng; không đảo mapping user–role hoặc lẫn server role với database role.

**Bẫy thường gặp:** tạo login nhưng quên database user; cấp quyền ở sai CSDL; hiểu role “sở hữu” là tự có toàn bộ quyền.

## Gói 3 — GRANT, DENY, REVOKE

**Đề hỏi:** tạo `U1`–`U3`, chọn `T1`–`T3` theo chữ số cuối MSSV, rồi cấp, từ chối và thu hồi quyền đúng theo danh sách đề bài.

**Đầu ra:** file SQL có các lệnh do bạn viết, cùng bảng đối chiếu để người chấm kiểm tra từng quyền trước và sau khi thay đổi.

**Công cụ:** trang 4 của đề PDF, SSMS, cửa sổ truy vấn T-SQL và một bảng ma trận quyền tự lập.

**Các bước:**

1. Lấy chữ số cuối MSSV, chọn đúng ba bảng trong bảng ở trang 4 đề gốc, rồi ghi ba tên đã chọn ở đầu script. Không thay bằng các tên bảng trong ví dụ slide.
2. Tạo ma trận “user × table × thao tác” với ba trạng thái: được cấp, bị từ chối, đã thu hồi. Chép từng dòng từ đề sang ma trận trước khi viết bất kỳ lệnh nào.
3. Từ ma trận, tự viết các phát biểu `GRANT`, rồi `DENY`, rồi `REVOKE` theo đúng đối tượng và thứ tự mà đề nêu. Xem slide 33–36 để kiểm tra cú pháp và ý nghĩa ba thao tác.
4. Thực thi trong CSDL thực hành, rồi kiểm tra ít nhất một thao tác được phép và một thao tác bị từ chối bằng user phù hợp. Khi thu hồi, kiểm tra lại trạng thái sau thu hồi thay vì chỉ tin rằng lệnh không báo lỗi.
5. Trong báo cáo, đưa ma trận rút gọn và các đoạn SQL của bạn; giải thích khác biệt giữa “bị từ chối” và “đã thu hồi” bằng lời của mình.

**Thế nào là đủ:** mỗi gạch đầu dòng trong đề có đúng một hoặc một nhóm lệnh tương ứng và có thể đối chiếu từ ma trận sang script.

**Bẫy thường gặp:** chọn sai bảng theo MSSV; bỏ sót một trong các thao tác `DENY`/`REVOKE`; coi `REVOKE` là `DENY`.

## Checklist trước khi nộp

- [ ] Import và export có ảnh kiểm tra kết quả cuối.
- [ ] Mapping user/role đã đối chiếu lại với đề gốc.
- [ ] Ba table `T1`–`T3` đã chọn đúng theo bảng ở trang 4 đề gốc.
- [ ] Mỗi quyền `GRANT`, `DENY`, `REVOKE` trong đề đều xuất hiện trong script/báo cáo của bạn.
- [ ] Ảnh thao tác có tiêu đề từng bước, rõ nét và không chứa thông tin nhạy cảm.
- [ ] PDF có phần tài liệu tham khảo; không sao chép nguyên văn câu lý thuyết.
- [ ] Tên file đúng `MSSV_HoTen_BTTH3.pdf` và `MSSV_HoTen_BTTH3.sql`.
- [ ] Nộp hai file riêng trên `courses.uit.edu.vn`, không nén file.
- [ ] Kiểm tra lại hạn nộp với giảng viên hoặc hệ thống courses trước khi nộp.

## Phần bạn phải tự quyết

- Dữ liệu Excel, CSDL thực hành, table export và ảnh chụp là bằng chứng do bạn tự tạo.
- Ba table `T1`–`T3`, toàn bộ câu lệnh SQL và kết quả thực thi phải bám theo MSSV/cài đặt của bạn.
- Nguồn tham khảo cuối báo cáo và cách diễn đạt câu lý thuyết là phần bạn tự viết.

Viết xong bản nháp thì nhờ AI review — lúc đó AI được phép chỉ ra chỗ sai và lý do sai.
