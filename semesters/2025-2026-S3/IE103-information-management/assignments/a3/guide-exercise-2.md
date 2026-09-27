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

1. Chuẩn bị file Excel nhỏ, có hàng tiêu đề nhất quán và dữ liệu đủ để nhận biết sau import. Tự kiểm tra kiểu dữ liệu trước khi mở wizard (file mẫu: `resources/sample-students.xlsx`, có bản `.csv` đi kèm nếu dùng Import Flat File Wizard).
2. Chụp các điểm quyết định trong luồng import. Có hai cách mở wizard, chọn một hoặc làm cả hai để so sánh:

   **Cách A — SSMS Import and Export Wizard** (nguồn Excel trực tiếp): click phải CSDL → `Tasks` → `Import Data...`

   | Điểm quyết định | Chụp lúc nào | Tên file ảnh |
   |---|---|---|
   | Chọn nguồn | Đã chọn `Microsoft Excel`, trỏ đúng file, tick "First row has column names" — trước khi Next | `images/g1-excelwizard-step1-source.png` |
   | Chọn đích | Đã chọn đúng server + CSDL thực hành — trước khi Next | `images/g1-excelwizard-step2-destination.png` |
   | Mapping sheet/table | Màn hình chọn sheet nguồn → bảng đích | `images/g1-excelwizard-step3-mapping.png` |
   | Mapping cột (Edit Mappings) | Dialog kiểm tra kiểu dữ liệu từng cột | `images/g1-excelwizard-step3b-edit-mappings.png` |
   | Thực thi | Màn hình kết quả "X rows transferred" | `images/g1-excelwizard-step4-run-result.png` |
   | Kiểm tra table đích | Kết quả `SELECT * FROM` bảng vừa tạo | `images/g1-excelwizard-step5-verify-table.png` |

   **Cách B — Import Flat File Wizard** (nguồn `.csv`, chỉ đọc file text): click phải CSDL → `Tasks` → `Import Flat File...`

   | Điểm quyết định | Chụp lúc nào | Tên file ảnh |
   |---|---|---|
   | Chọn nguồn | Specify Input File — đã trỏ `sample-students.csv` | `images/g1-flatfile-step1-input-file.png` |
   | Xem trước dữ liệu | Preview Data — header + vài dòng đầu | `images/g1-flatfile-step2-preview-data.png` |
   | Modify Columns | Mapping kiểu dữ liệu từng cột (đối chiếu lại bước 1 — cột ngày và cột số dễ bị suy sai kiểu) | `images/g1-flatfile-step3-modify-columns.png` |
   | Summary | Tóm tắt trước khi chạy | `images/g1-flatfile-step4a-summary.png` |
   | Results | Kết quả chạy (✓/✗ từng hành động) | `images/g1-flatfile-step4b-results.png` |
   | Kiểm tra table đích | Kết quả `SELECT * FROM` bảng vừa tạo | `images/g1-flatfile-step5-verify-table.png` |

3. Chọn một table có dữ liệu rõ ràng cho export — dùng luôn bảng vừa import ở bước 2 (`dbo.SampleStudents` hoặc `dbo.SampleStudentsFlat`) để đề nhất quán và dễ đối chiếu ngược lại. Mở **SSMS Import and Export Wizard** (click phải CSDL → `Tasks` → `Export Data...`), lần này chiều đi ngược lại: SQL Server → Excel.

   | Điểm quyết định | Chụp lúc nào | Tên file ảnh |
   |---|---|---|
   | Chọn nguồn | Choose a Data Source — đã chọn `SQL Server Native Client`, đúng server và CSDL — trước khi Next | `images/g1-export-step1-source.png` |
   | Chọn đích | Choose a Destination — đã chọn `Microsoft Excel`, đặt đường dẫn file mới (vd `resources/exported-students.xlsx`), đúng version Excel — trước khi Next | `images/g1-export-step2-destination.png` |
   | Mapping table/sheet | Specify Table Copy or Query — chọn "Copy data from one or more tables", tick đúng bảng nguồn, cột "Destination" là tên sheet sẽ tạo | `images/g1-export-step3-mapping.png` |
   | Mapping cột (Column Mappings) | Dialog kiểm tra ánh xạ cột nguồn → cột Excel (bấm `Edit Mappings...` để mở) | `images/g1-export-step3b-column-mappings.png` |
   | Thực thi | Màn hình kết quả "X rows transferred" sau khi Finish | `images/g1-export-step4-run-result.png` |
   | Mở file Excel để kiểm tra | Mở `exported-students.xlsx` vừa tạo, thấy đủ hàng tiêu đề và dữ liệu | `images/g1-export-step5-verify-excel.png` |

   Lưu ý: giữ nguyên tên bảng nguồn trong caption ảnh, để người chấm đối chiếu ngược lại đúng bảng đã import ở bước 2 — tránh export nhầm một bảng khác không liên quan.

   > ⚠️ **Trên SQL Server Express**: `Tasks → Export Data...` (và `Import Data...`) có thể báo
   > *"This feature is not currently available in this version of SQL Server"* — Express không
   > kèm đủ tính năng SSIS để menu này gọi trực tiếp. Vòng qua bằng cách chạy thẳng file thực thi
   > của wizard (file này vẫn cài kèm SSMS, độc lập với edition SQL Server):
   > ```
   > C:\Program Files (x86)\Microsoft SQL Server\170\DTS\Binn\DTSWizard.exe
   > ```
   > Mở file này (double-click hoặc gõ `DTSWizard` vào Run/Start Menu) — wizard hiện ra y hệt
   > các màn hình đã mô tả ở trên, làm tiếp bình thường từ bước chọn nguồn.
4. Đối chiếu số cột, số dòng và ít nhất một giá trị nhận diện ở mỗi đầu. Nếu wizard tự suy luận sai kiểu dữ liệu, ghi lỗi thật và cách bạn tự sửa thay vì che đi.

**Thế nào là đủ:** người chấm thấy được dữ liệu đã đi vào SQL Server và đi ra Excel, không chỉ thấy wizard được mở.

## Gói 2 — Xác thực và role

**Đề hỏi:** tạo `u1`–`u6`, `r1`–`r3`, gán đúng thành viên và role theo đề.

**Đầu ra:** script hoặc ảnh thể hiện thứ tự tạo login/user/role, mapping thành viên, và kiểm tra membership.

**Công cụ:** SSMS, cửa sổ truy vấn T-SQL, Object Explorer hoặc truy vấn metadata để đối chiếu membership.

**Các bước:**

1. Vẽ ma trận trước khi viết SQL — làm theo thứ tự này, đừng mở cửa sổ query trước:

   a. **Ma trận thành viên `user × role`.** Hàng là `u1`–`u6`, cột là `r1`–`r3`. Ô nào user thuộc role đó thì đánh dấu. Chép đúng mapping ở đề gốc (mục B, gạch đầu dòng "Tạo nhóm") vào bảng — không tự suy diễn hay đổi thứ tự, vì đây là phần chấm đối chiếu trực tiếp.

      ![Ma trận thành viên user × role: u1 thuộc r1; u2, u3 thuộc r2; u4, u5, u6 thuộc r3](images/g2-user-role-matrix.png)

   b. **Bảng vai trò hệ thống của từng role.** Một bảng riêng, hai cột: `role` và `server role / database role mà nó là thành viên`. Đề gốc liệt kê rõ ba dòng cho `r1`, `r2`, `r3` (mục B, gạch đầu dòng "Thực hiện") — chép nguyên văn vào bảng này. Ghi chú thêm ở mỗi dòng: role đích đó thuộc **server level** (vd `SysAdmin`) hay **database level** (vd `db_owner`, `db_accessadmin`), vì hai loại này tạo bằng lệnh khác nhau (bước 3 sẽ dùng đến).

      | role | thành viên của | cấp |
      |---|---|---|
      | `r1` | `SysAdmin` | server level |
      | `r2` | `db_owner`, `db_accessadmin` | database level |
      | `r3` | `SysAdmin`, `db_owner`, `db_accessadmin` | server level + database level |

      ![Bảng vai trò hệ thống của r1, r2, r3: r1 → SysAdmin (server level), r2 → db_owner/db_accessadmin (database level), r3 → cả hai cấp](images/g2-role-table.png)

      Vì `r3` bắc cầu cả hai cấp, khi viết script ở bước 3 bạn sẽ cần **hai câu lệnh khác nhau** cho cùng một role: một lệnh gán vào server role (`ALTER SERVER ROLE ... ADD MEMBER`), một lệnh gán vào database role (`ALTER ROLE ... ADD MEMBER`) — đừng gộp chung thành một câu.

   c. **Cột "đối tượng cần tạo trước".** Thêm một cột nháp bên cạnh ma trận, liệt kê cho mỗi `u1`–`u6`: cần login cấp server hay chỉ cần user cấp CSDL, và CSDL nào. Đây là chỗ dễ quên nhất — xem bước 2.

      Suy trực tiếp từ cột "cấp" ở bảng b: role ở **server level** thì thành viên của nó phải là **login** (`SysAdmin` là fixed server role — chỉ nhận login/server principal làm thành viên, không nhận database user); role ở **database level** thì thành viên chỉ cần là **database user** trong đúng CSDL thực hành. Ghép với ma trận a, bạn có:

      | user | thuộc role | cần server login? | cần database user? |
      |---|---|---|---|
      | `u1` | `r1` (server level) | có | không bắt buộc (trừ khi đề/bạn muốn nó truy vấn CSDL luôn) |
      | `u2` | `r2` (database level) | không bắt buộc riêng — nhưng **mọi database user vẫn cần map tới một login/`WITHOUT LOGIN`** | có, trong CSDL thực hành |
      | `u3` | `r2` (database level) | như `u2` | có, trong CSDL thực hành |
      | `u4` | `r3` (server + database level) | có | có, trong CSDL thực hành |
      | `u5` | `r3` (server + database level) | có | có, trong CSDL thực hành |
      | `u6` | `r3` (server + database level) | có | có, trong CSDL thực hành |

      ![Đối tượng cần tạo trước cho mỗi user: u1 cần server login; u2, u3 cần database user (map login gián tiếp); u4, u5, u6 cần cả hai](images/g2-precreate-table.png)

      Điền tên CSDL thực hành cụ thể của bạn vào cột cuối thay vì để chung chung — đây là chỗ người chấm dễ bắt lỗi nhất nếu bạn tạo login/user ở sai CSDL. Cột "cần database user?" của `u1` bỏ trống là hợp lệ nếu đề không yêu cầu `u1` thao tác trong CSDL đề tài, nhưng vẫn nên ghi rõ lý do trong báo cáo thay vì im lặng bỏ qua.

   Mục đích của toàn bộ bước 1 là để bước 3 (viết script) chỉ còn việc "dịch từng dòng ma trận thành một câu lệnh", không phải vừa viết vừa nhớ mapping.

2. Phân biệt rõ login, database user và role. Slide 11–31 là phần nền: bạn phải biết đối tượng nào thuộc cấp server, đối tượng nào thuộc CSDL trước khi chạy lệnh.

   ![Chuỗi phụ thuộc Login → Database User → Role → Quyền, chia theo cấp server và cấp database](images/g2-login-user-role-flow.png)

   a. **Ba khái niệm khác nhau ở đâu.**

      | Đối tượng | Cấp | Trả lời câu hỏi | Được tạo bởi |
      |---|---|---|---|
      | **Login** | Server | "Ai được phép kết nối vào SQL Server instance này?" | DBA/quản trị server |
      | **Database user** | Database | "Ai được phép thao tác trong CSDL này?" | Chủ CSDL, ánh xạ từ một login (hoặc `WITHOUT LOGIN`) |
      | **Role** (server role / database role) | Cả hai, tùy loại | "Nhóm quyền nào được gán sẵn, để gán hàng loạt thay vì gán từng quyền lẻ?" | DBA/chủ CSDL |

      Một login **không tự động** có quyền trong CSDL — phải map thành database user trước. Một database user **không tự động** có quyền gì — phải được thêm vào role hoặc `GRANT` trực tiếp. Đây là chuỗi phụ thuộc `login → user → role → quyền`, thiếu một mắt là user không dùng được như đề yêu cầu.

   b. **Vì sao bảng b/c ở bước 1 lại tách "cấp".** Server role (`SysAdmin`) chỉ chứa được login/server principal; database role (`db_owner`, `db_accessadmin`) chỉ chứa được database user. Không có lệnh nào gán thẳng một login vào một database role, hay một database user vào một server role — đây là lý do bước 3 phải viết hai câu lệnh khác nhau cho `r3`, đúng như đã nêu ở mục b.

   c. **Tự kiểm tra trước khi qua bước 3.** Với mỗi dòng trong bảng c, tự hỏi: "đối tượng cấp server của user này đã có chưa, đối tượng cấp database đã có chưa, và role nó cần gia nhập ở cấp nào?" Nếu câu trả lời cho một trong ba câu hỏi còn mơ hồ, quay lại đọc slide 11–31 phần tương ứng (login/user hay server role/database role) trước khi viết lệnh — viết trước rồi sửa lỗi cú pháp sau sẽ mất thời gian hơn nhiều so với xác nhận khái niệm trước.
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

