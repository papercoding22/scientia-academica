# IE103 — Bài tập 3 · Hướng dẫn Bài tập 1

| | |
|---|---|
| Bài tập | [`README.md`](README.md) |
| Phần còn lại | [Hướng dẫn Bài tập 2](guide-exercise-2.md) |
| Buổi học | ❓ chưa xác minh |
| **Hạn nộp** | **❓ chưa biết** |
| Ước lượng | 5–7 giờ, chưa tính thời gian cài hoặc xử lý lỗi SQL Server |

> ⚠️ **File này chỉ dạy CÁCH LÀM, không chứa lời giải.** Bạn tự tra thông số theo phiên bản SQL Server đang dùng, tự viết câu lệnh và tự kết luận các câu phân tích.

---

## Mục lục

- [Đề yêu cầu gì](#đề-yêu-cầu-gì)
- [Chuẩn bị](#chuẩn-bị)
- [Gói 1 — Tổ chức dữ liệu](#gói-1--tổ-chức-dữ-liệu)
- [Gói 2 — Backup, restore và log](#gói-2--backup-restore-và-log)
- [Gói 3 — View và trạng thái mã hóa](#gói-3--view-và-trạng-thái-mã-hóa)
- [Checklist trước khi chuyển sang Bài tập 2](#checklist-trước-khi-chuyển-sang-bài-tập-2)
- [Phần bạn phải tự quyết](#phần-bạn-phải-tự-quyết)

---

## Đề yêu cầu gì

Bài tập 1 gồm ba gói: tìm hiểu tổ chức dữ liệu SQL Server; thực hành backup, delete, restore và đọc log; rồi phân tích View cùng trạng thái mã hóa. Đầu ra cuối cùng vẫn là một báo cáo PDF và phần SQL do bạn tự viết.

| Gói việc | Đầu ra phải có | Dạng |
|---|---|---|
| Tổ chức dữ liệu | Câu trả lời cho 6 ý về SQL Server | Giải thích có nguồn |
| Backup, restore, log | Ảnh theo từng bước, tiêu đề ảnh, SQL tương ứng và giải thích log | Ảnh + code + diễn giải |
| View, mã hóa | Kết luận và lập luận cho hai tình huống | Phân tích |

Nguồn yêu cầu là [đề gốc](brief/). Chưa có transcript nên guide không tự đặt thêm tiêu chí chấm hoặc hạn nộp.

## Chuẩn bị

**Công cụ:** SQL Server, SQL Server Management Studio (SSMS), công cụ chụp màn hình, trình soạn PDF và thư mục cục bộ để lưu file backup `.bak`.

1. Tạo một CSDL thực hành riêng; không dùng CSDL có dữ liệu quan trọng.
2. Ghi phiên bản SQL Server/SSMS vào phần ghi chú của báo cáo. Các giới hạn dung lượng và catalog cũ có thể phụ thuộc phiên bản.
3. Tạo trước một thư mục cho file backup và một thư mục cho ảnh chụp. Đừng chụp xong mới tìm ảnh.
4. Mở [slide chương 5](../../materials/slides/05%20-%20Quan%20tri%20CSDL%20va%20an%20toan%20thong%20tin.pdf): View ở slide 41–52, backup/restore ở 53–68.
5. Dành riêng các mục đúng thứ tự đề trong báo cáo; với mỗi ảnh, thêm một caption nói ảnh đang chứng minh bước nào.

## Gói 1 — Tổ chức dữ liệu

**Đề hỏi:** trả lời sáu ý về data type, giới hạn row/table, catalog trong `master`, file dữ liệu khi tạo CSDL và số kết nối đồng thời.

**Đầu ra:** sáu tiểu mục ngắn, mỗi tiểu mục có kết luận theo **phiên bản SQL Server bạn dùng**, nguồn tham khảo và diễn giải bằng lời của mình.

**Công cụ:** tài liệu SQL Server phù hợp với phiên bản đang dùng, slide chương 5 và SSMS để quan sát CSDL thử nghiệm.

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

**Công cụ:** SSMS, cửa sổ truy vấn T-SQL, thư mục cục bộ để lưu `.bak` và công cụ chụp màn hình.

**Các bước:**

1. Trước khi thao tác, tạo `AAA` có một dữ liệu nhận diện do bạn tự chọn. Đây là mốc để chứng minh restore đã phục hồi đúng CSDL, thay vì chỉ chứng minh lệnh chạy không lỗi.
2. Làm trọn vẹn chuỗi bằng giao diện: backup, xác nhận file `.bak`, xóa, restore, kiểm tra lại dấu hiệu nhận diện. Chụp **đúng màn hình quyết định** ở từng bước, không cần ảnh các màn hình không mang bằng chứng.
3. Lặp lại cùng chuỗi trong một lượt thực hành độc lập bằng script SQL tự viết. Lưu script vào file `.sql`, đồng thời dán đoạn code tương ứng vào PDF theo yêu cầu đề.
4. Sau mỗi restore, chạy một kiểm tra đọc dữ liệu/sự tồn tại của CSDL và ghi kết quả thật vào báo cáo.
5. Mở SQL Server Log theo đường dẫn đề bài nêu. Chụp đường dẫn mở log và một bản ghi đủ cột; dùng tài liệu SQL Server để lập bảng “tên trường → ý nghĩa → ví dụ quan sát được”.

**Thế nào là đủ:** báo cáo khiến người chấm nhìn theo là tái hiện được sáu thao tác (ba thao tác × hai cách) và thấy được kết quả restore.

**Bẫy thường gặp:** chỉ có ảnh backup/restore mà thiếu ảnh xóa; dùng cùng một ảnh cho hai cách; không kiểm tra dữ liệu sau restore.

## Gói 3 — View và trạng thái mã hóa

**Đề hỏi:** đánh giá một `INSERT` qua View `EmployeeNames`; nhận diện trạng thái dữ liệu trong hình mã hóa và giải thích.

**Đầu ra:** hai đoạn lập luận, mỗi đoạn có chuỗi căn cứ rõ ràng thay vì chỉ “có/không” hoặc gọi tên trạng thái.

**Công cụ:** đề PDF, slide chương 5, SSMS và một CSDL thử nghiệm nếu bạn muốn kiểm chứng hành vi của View.

**Các bước:**

1. Với View, lập bảng đối chiếu: cột của base table, ràng buộc trên từng cột, cột được View chiếu ra và dữ liệu mà câu `INSERT` cung cấp. Từ bảng này suy luận khả năng thực thi; nếu dùng SSMS để kiểm chứng, đặt trong CSDL thử nghiệm và ghi nhận thông báo thực tế.
2. Đọc slide 42–47 để phân biệt View với bảng vật lý và điều kiện cập nhật được; không chép ví dụ trong slide thành đáp án.
3. Với hình mã hóa, quan sát vị trí dữ liệu rõ, vị trí dữ liệu đã mã hóa và nơi ứng dụng đang xử lý/chuyển dữ liệu. So sánh từng dấu hiệu đó với ba định nghĩa trong đề, rồi tự chọn một trạng thái và giải thích tại sao hai trạng thái còn lại không phù hợp.

**Thế nào là đủ:** kết luận bám trực tiếp vào cấu trúc/hình minh họa; không dựa vào trực giác hoặc một câu trả lời không có lý do.

## Checklist trước khi chuyển sang Bài tập 2

- [ ] Đủ sáu ý của phần tổ chức dữ liệu, có nguồn và diễn giải theo ý hiểu.
- [ ] Backup, delete, restore đều có bằng chứng cho giao diện **và** SQL.
- [ ] Ảnh thao tác có tiêu đề từng bước, rõ nét và không chứa thông tin nhạy cảm.
- [ ] Phần log có ảnh đường dẫn mở log và giải thích các trường thông tin.
- [ ] Hai câu phân tích View và trạng thái mã hóa có lập luận từ đề.

## Phần bạn phải tự quyết

- Data type, giới hạn, ý nghĩa System tables và số kết nối phải tra theo phiên bản SQL Server bạn dùng.
- CSDL thực hành, dữ liệu nhận diện, ảnh chụp và toàn bộ câu lệnh SQL là bằng chứng do bạn tự tạo.
- Kết luận cho View và trạng thái mã hóa phải do bạn lập luận từ đề, không lấy từ guide.
- Nguồn tham khảo cuối báo cáo và cách diễn đạt câu lý thuyết là phần bạn tự viết.

Viết xong bản nháp thì nhờ AI review — lúc đó AI được phép chỉ ra chỗ sai và lý do sai.
