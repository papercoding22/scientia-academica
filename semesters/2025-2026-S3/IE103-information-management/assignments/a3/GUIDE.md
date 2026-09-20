# IE103 — Bài tập thực hành 3 · Hướng dẫn cách làm

| | |
|---|---|
| Bài tập | [`README.md`](README.md) |
| Buổi học | ❓ chưa xác minh |
| **Hạn nộp** | **❓ chưa biết** |
| Ước lượng | 8–12 giờ, chưa tính thời gian cài hoặc xử lý lỗi SQL Server |

> ⚠️ **File này chỉ dạy CÁCH LÀM, không chứa lời giải.** Bạn tự chọn dữ liệu, tự tra thông số theo phiên bản SQL Server đang dùng, tự viết câu lệnh và tự kết luận các câu phân tích.

---

## Mục lục

- [Đề yêu cầu gì](#đề-yêu-cầu-gì)
- [Chuẩn bị](#chuẩn-bị)
- [Gói 1 — Tổ chức dữ liệu](#gói-1--tổ-chức-dữ-liệu)
- [Gói 2 — Backup, restore và log](#gói-2--backup-restore-và-log)
- [Gói 3 — View và trạng thái mã hóa](#gói-3--view-và-trạng-thái-mã-hóa)
- [Gói 4 — Import và export](#gói-4--import-và-export)
- [Gói 5 — Xác thực và role](#gói-5--xác-thực-và-role)
- [Gói 6 — GRANT, DENY, REVOKE](#gói-6--grant-deny-revoke)
- [Checklist trước khi nộp](#checklist-trước-khi-nộp)
- [Phần bạn phải tự quyết](#phần-bạn-phải-tự-quyết)

---

## Đề yêu cầu gì

Đây là một bài thực hành gồm hai đầu ra bắt buộc: báo cáo PDF có giải thích, ảnh chụp và code SQL; cùng file `.sql` chứa các câu lệnh bạn tự viết.

| Gói việc | Đầu ra phải có | Dạng |
|---|---|---|
| Tổ chức dữ liệu | Câu trả lời cho 6 ý về SQL Server | Giải thích có nguồn |
| Backup, restore, log | Ảnh theo từng bước, tiêu đề ảnh, SQL tương ứng và giải thích log | Ảnh + code + diễn giải |
| View, mã hóa | Kết luận và lập luận cho hai tình huống | Phân tích |
| Import/export | Ảnh wizard và kết quả kiểm tra | Ảnh + diễn giải |
| User, role, quyền | Script tự viết và bằng chứng thực thi | `.sql` + ảnh/chứng minh |

Nguồn yêu cầu duy nhất là [đề gốc](brief/). Chưa có transcript nên guide không tự đặt thêm tiêu chí chấm hoặc hạn nộp.

## Chuẩn bị

**Công cụ:** SQL Server và SQL Server Management Studio (SSMS), Excel, công cụ chụp màn hình, trình soạn PDF.

1. Tạo một CSDL thực hành riêng; không dùng CSDL có dữ liệu quan trọng.
2. Ghi phiên bản SQL Server/SSMS vào phần ghi chú của báo cáo. Các giới hạn dung lượng và catalog cũ có thể phụ thuộc phiên bản.
3. Tạo trước hai thư mục cục bộ: một cho file backup `.bak`, một cho ảnh chụp. Đừng chụp xong mới tìm ảnh.
4. Mở [slide chương 5](../../materials/slides/05%20-%20Quan%20tri%20CSDL%20va%20an%20toan%20thong%20tin.pdf): phần phân quyền ở slide 10–40, View ở 41–52, backup/restore ở 53–68, import/export ở 69–81.
5. Trong báo cáo, dành riêng các mục đúng thứ tự đề; với mỗi ảnh, thêm một caption nói ảnh đang chứng minh bước nào.

## Gói 1 — Tổ chức dữ liệu

**Đề hỏi:** trả lời sáu ý về data type, giới hạn row/table, catalog trong `master`, file dữ liệu khi tạo CSDL và số kết nối đồng thời.

**Đầu ra:** sáu tiểu mục ngắn, mỗi tiểu mục có kết luận theo **phiên bản SQL Server bạn dùng**, nguồn tham khảo và diễn giải bằng lời của mình.

**Các bước:**

1. Lập bảng làm việc gồm: câu hỏi, thông số/tên đối tượng cần tra, phiên bản áp dụng, nguồn Microsoft hoặc tài liệu học phần, diễn giải của bạn.
2. Phân biệt `data type` theo nhóm (số, chuỗi, ngày giờ, nhị phân) trước khi mô tả tình huống dùng; không chỉ liệt kê tên kiểu dữ liệu.
3. Với mọi con số giới hạn, kiểm tra phạm vi áp dụng: kích thước row, kích thước database/table và edition/version có thể không phải cùng một khái niệm.
4. Giữ nguyên cách viết tên System tables trong đề khi nêu câu hỏi, nhưng đối chiếu với catalog views/tài liệu chính thức của đúng phiên bản trước khi kết luận; ghi rõ nếu một tên là legacy hoặc có khác biệt chính tả.
5. Với `CREATE DATABASE`, quan sát file được tạo thực tế rồi mới giải thích vai trò. Với số kết nối đồng thời, nêu điều kiện/version thay vì ghi một con số rời rạc.

**Thế nào là đủ:** sáu ý đều có câu trả lời, nguồn và phạm vi phiên bản; không có đoạn sao chép nguyên văn.

**Bẫy thường gặp:** trộn giới hạn của một row với giới hạn của toàn database; coi tài liệu của phiên bản khác là kết luận chung.

## Gói 2 — Backup, restore và log

**Đề hỏi:** backup `AAA` thành `AAA.BAK`, xóa CSDL, restore lại bằng cả giao diện lẫn SQL; sau đó xem SQL Server Log và giải thích các trường thông tin.

**Đầu ra:** một chuỗi bằng chứng cho **mỗi** thao tác backup → delete → restore, làm bằng hai cách; phần log có ảnh các bước và bảng giải thích trường.

**Các bước:**

1. Trước khi thao tác, tạo `AAA` có một dữ liệu nhận diện do bạn tự chọn. Đây là mốc để chứng minh restore đã phục hồi đúng CSDL, thay vì chỉ chứng minh lệnh chạy không lỗi.
2. Làm trọn vẹn chuỗi bằng giao diện: backup, xác nhận file `.bak`, xóa, restore, kiểm tra lại dấu hiệu nhận diện. Chụp **đúng màn hình quyết định** ở từng bước, không cần ảnh các màn hình không mang bằng chứng.
3. Lặp lại cùng chuỗi trong một lượt thực hành độc lập bằng script SQL tự viết. Lưu script vào file `.sql`, đồng thời dán đoạn code tương ứng vào PDF theo yêu cầu đề.
4. Sau mỗi restore, chạy một kiểm tra đọc dữ liệu/sự tồn tại của CSDL và ghi kết quả thật vào báo cáo.
5. Mở SQL Server Log theo đường dẫn đề bài nêu. Chụp đường dẫn mở log và một bản ghi đủ cột; dùng tài liệu SQL Server để lập bảng “tên trường → ý nghĩa → ví dụ quan sát được”.

**Thế nào là đủ:** báo cáo khiến người chấm nhìn theo là tái hiện được sáu thao tác (ba thao tác × hai cách) và thấy được kết quả restore.

**Bẫy thường gặp:** chỉ có ảnh backup/restore mà thiếu ảnh xóa; dùng cùng một ảnh cho hai cách; không kiểm tra dữ liệu sau restore.

## Gói 3 — View và trạng thái mã hóa

**Đề hỏi:** đánh giá một `INSERT` qua view `EmployeeNames`; nhận diện trạng thái dữ liệu trong hình mã hóa và giải thích.

**Đầu ra:** hai đoạn lập luận, mỗi đoạn có chuỗi căn cứ rõ ràng thay vì chỉ “có/không” hoặc gọi tên trạng thái.

**Các bước:**

1. Với View, lập bảng đối chiếu: cột của base table, ràng buộc trên từng cột, cột được view chiếu ra và dữ liệu mà câu `INSERT` cung cấp. Từ bảng này suy luận khả năng thực thi; nếu dùng SSMS để kiểm chứng, đặt trong CSDL thử nghiệm và ghi nhận thông báo thực tế.
2. Đọc slide 42–47 để phân biệt view với bảng vật lý và điều kiện cập nhật được; không chép ví dụ trong slide thành đáp án.
3. Với hình mã hóa, quan sát vị trí dữ liệu rõ, vị trí dữ liệu đã mã hóa và nơi ứng dụng đang xử lý/chuyển dữ liệu. So sánh từng dấu hiệu đó với ba định nghĩa trong đề, rồi tự chọn một trạng thái và giải thích tại sao hai trạng thái còn lại không phù hợp.

**Thế nào là đủ:** kết luận bám trực tiếp vào cấu trúc/hình minh họa; không dựa vào trực giác hoặc một câu trả lời không có lý do.

## Gói 4 — Import và export

**Đề hỏi:** import một file dữ liệu sinh viên Excel vào SQL Server, rồi export một table SQL Server ra Excel, đều bằng giao diện.

**Đầu ra:** hai luồng ảnh theo bước và một kiểm tra kết quả ở đầu vào/đầu ra.

**Các bước:**

1. Chuẩn bị file Excel nhỏ, có hàng tiêu đề nhất quán và dữ liệu đủ để nhận biết sau import. Tự kiểm tra kiểu dữ liệu trước khi mở wizard.
2. Chụp các điểm quyết định trong luồng import: chọn nguồn, chọn đích, mapping sheet/table, thực thi và kiểm tra table đích.
3. Chọn một table có dữ liệu rõ ràng cho export. Chụp các điểm quyết định tương ứng: nguồn, đích Excel, mapping, thực thi, mở file Excel để kiểm tra.
4. Đối chiếu số cột, số dòng và ít nhất một giá trị nhận diện ở mỗi đầu. Nếu wizard tự suy luận sai kiểu dữ liệu, ghi lỗi thật và cách bạn tự sửa thay vì che đi.

**Thế nào là đủ:** người chấm thấy được dữ liệu đã đi vào SQL Server và đi ra Excel, không chỉ thấy wizard được mở.

## Gói 5 — Xác thực và role

**Đề hỏi:** tạo `u1`–`u6`, `r1`–`r3`, gán đúng thành viên và role theo đề.

**Đầu ra:** script hoặc ảnh thể hiện thứ tự tạo login/user/role, mapping thành viên, và kiểm tra membership.

**Các bước:**

1. Vẽ ma trận trước khi viết SQL: hàng là `u1`–`u6`, cột là `r1`–`r3`; đánh dấu đúng một role cho mỗi user theo đề gốc. Kế bên là bảng quyền của từng role.
2. Phân biệt rõ login, database user và role. Slide 11–31 là phần nền: bạn phải biết đối tượng nào thuộc cấp server, đối tượng nào thuộc CSDL trước khi chạy lệnh.
3. Viết script theo thứ tự phụ thuộc: tạo đối tượng cấp server cần thiết, ánh xạ vào CSDL, tạo role, gán thành viên, rồi gán role hệ thống/database mà đề yêu cầu.
4. Sau mỗi nhóm lệnh, dùng giao diện hoặc truy vấn metadata để kiểm tra membership thực tế. Lưu bằng chứng đó vào báo cáo.

**Thế nào là đủ:** tất cả sáu user và ba role xuất hiện đúng; không đảo mapping user–role hoặc lẫn server role với database role.

**Bẫy thường gặp:** tạo login nhưng quên database user; cấp quyền ở sai CSDL; hiểu role “sở hữu” là tự có toàn bộ quyền.

## Gói 6 — GRANT, DENY, REVOKE

**Đề hỏi:** tạo `U1`–`U3`, chọn `T1`–`T3` theo chữ số cuối MSSV, rồi cấp, từ chối và thu hồi quyền đúng theo danh sách đề bài.

**Đầu ra:** file SQL có các lệnh do bạn viết, cùng bảng đối chiếu để người chấm kiểm tra từng quyền trước và sau khi thay đổi.

**Các bước:**

1. Lấy chữ số cuối MSSV, chọn đúng ba bảng trong bảng ở trang 4 đề gốc, rồi ghi ba tên đã chọn ở đầu script. Không thay bằng các tên bảng trong ví dụ slide.
2. Tạo ma trận “user × table × thao tác” với ba trạng thái: được cấp, bị từ chối, đã thu hồi. Chép từng dòng từ đề sang ma trận trước khi viết bất kỳ lệnh nào.
3. Từ ma trận, tự viết các phát biểu `GRANT`, rồi `DENY`, rồi `REVOKE` theo đúng đối tượng và thứ tự mà đề nêu. Xem slide 33–36 để kiểm tra cú pháp và ý nghĩa ba thao tác.
4. Thực thi trong CSDL thực hành, rồi kiểm tra ít nhất một thao tác được phép và một thao tác bị từ chối bằng user phù hợp. Khi thu hồi, kiểm tra lại trạng thái sau thu hồi thay vì chỉ tin rằng lệnh không báo lỗi.
5. Trong báo cáo, đưa ma trận rút gọn và các đoạn SQL của bạn; giải thích khác biệt giữa “bị từ chối” và “đã thu hồi” bằng lời của mình.

**Thế nào là đủ:** mỗi gạch đầu dòng trong đề có đúng một hoặc một nhóm lệnh tương ứng và có thể đối chiếu từ ma trận sang script.

**Bẫy thường gặp:** chọn sai bảng theo MSSV; bỏ sót một trong các thao tác `DENY`/`REVOKE`; coi `REVOKE` là `DENY`.

## Checklist trước khi nộp

- [ ] Đủ tất cả ý của phần tổ chức dữ liệu, có nguồn và diễn giải theo ý hiểu.
- [ ] Backup, delete, restore đều có bằng chứng cho giao diện **và** SQL.
- [ ] Ảnh thao tác có tiêu đề từng bước, rõ nét và không chứa thông tin nhạy cảm.
- [ ] Import và export có ảnh kiểm tra kết quả cuối.
- [ ] Mapping `u1`–`u6`/`r1`–`r3` và `T1`–`T3` đã đối chiếu lại với đề gốc.
- [ ] Mỗi quyền `GRANT`, `DENY`, `REVOKE` trong đề đều xuất hiện trong script/báo cáo của bạn.
- [ ] PDF có phần tài liệu tham khảo; không sao chép nguyên văn câu lý thuyết.
- [ ] Tên file đúng `MSSV_HoTen_BTTH3.pdf` và `MSSV_HoTen_BTTH3.sql`.
- [ ] Nộp hai file riêng trên `courses.uit.edu.vn`, không nén file.
- [ ] Kiểm tra lại hạn nộp với giảng viên hoặc hệ thống courses trước khi nộp.

## Phần bạn phải tự quyết

- Data type, giới hạn, ý nghĩa System tables và số kết nối phải tra theo phiên bản SQL Server bạn dùng.
- Dữ liệu Excel, CSDL thực hành, table export và ảnh chụp là bằng chứng do bạn tự tạo.
- Kết luận cho View và trạng thái mã hóa phải do bạn lập luận từ đề, không lấy từ guide.
- Ba table `T1`–`T3`, toàn bộ câu lệnh SQL và kết quả thực thi phải bám theo MSSV/cài đặt của bạn.
- Nguồn tham khảo cuối báo cáo và cách diễn đạt câu lý thuyết là phần bạn tự viết.

Viết xong bản nháp thì nhờ AI review — lúc đó AI được phép chỉ ra chỗ sai và lý do sai.
