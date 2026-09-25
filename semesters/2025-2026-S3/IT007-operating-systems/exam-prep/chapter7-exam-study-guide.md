# IT007 — Chương 7: Kiến thức từ đề thi mẫu và hướng dẫn từng câu

| | |
|---|---|
| Chương | **7 — Memory management (quản lý bộ nhớ)**, được tổng hợp trong **L08** |
| Đề nguồn | [Final-Exam-Sample.pdf](Final-Exam-Sample.pdf), mã đề 01, 6 trang |
| Phạm vi | Câu **3, 13, 14, 15, 16, 18, 20, 21a, 21b, 23c, 23d** |
| Điểm trong đề này | 7 câu trắc nghiệm × 0,3 + 4 ý tự luận × 0,5 = **4,1/10 điểm** |
| Cập nhật | 2026-09-25 |
| Cách dùng | Đọc mục 2 → tự làm đề → dùng mục 3 kiểm tra suy luận → luyện lại mục cuối |
| Liên quan | [Lecture L08](../lectures/L08-memory-management.md) · [Map toàn đề](exam-map.md) · [Guide Chương 5](chapter5-exam-study-guide.md) |

> **Phạm vi nguồn:** chắt lọc từ **một đề mẫu**, đối chiếu slide Chương 7. Trường/khoa trên đề để trống, chưa xác nhận người ra đề; trang 6 là bảng trả lời trống, **không có đáp án chính thức**. Guide hướng dẫn cách làm để bạn tự chọn/điền kết quả. Tỷ trọng này không cam kết phạm vi đề thi thật.
>
> `[Đề tr5, C21a]` = trang 5, câu 21a; `[C7 s44]` = **trang PDF thứ 44, tính từ 1** của slide C7. Các analogy, ví dụ nhỏ và TypeScript dưới đây là minh họa tự dựng, không phải lời giảng viên. L08 không có transcript hoặc ngày học; ngày trên là ngày cập nhật guide.

---

## Mục lục

- [1. Đề đang kiểm tra những gì?](#1-đề-đang-kiểm-tra-những-gì)
- [2. Kiến thức chắt lọc](#2-kiến-thức-chắt-lọc)
  - [2.1. Các kiểu địa chỉ và address binding — câu 15, 16, 23c](#21-các-kiểu-địa-chỉ-và-address-binding--câu-15-16-23c)
  - [2.2. Dynamic loading và dynamic linking — câu 18](#22-dynamic-loading-và-dynamic-linking--câu-18)
  - [2.3. Fragmentation và compaction — câu 14, 23d](#23-fragmentation-và-compaction--câu-14-23d)
  - [2.4. Placement và first-fit — câu 13](#24-placement-và-first-fit--câu-13)
  - [2.5. Paging: đổi địa chỉ, đếm bit và kích thước bảng — câu 20, 21a, 21b](#25-paging-đổi-địa-chỉ-đếm-bit-và-kích-thước-bảng--câu-20-21a-21b)
  - [2.6. TLB và effective access time — câu 3](#26-tlb-và-effective-access-time--câu-3)
- [3. Hướng dẫn từng câu trong đề](#3-hướng-dẫn-từng-câu-trong-đề)
  - [Câu 3 — Tìm thời gian tra TLB](#câu-3--tìm-thời-gian-tra-tlb)
  - [Câu 13 — First-fit trên các partition cố định](#câu-13--first-fit-trên-các-partition-cố-định)
  - [Câu 14 — Nhận diện loại fragmentation](#câu-14--nhận-diện-loại-fragmentation)
  - [Câu 15 — Tên biến trong source code](#câu-15--tên-biến-trong-source-code)
  - [Câu 16 — Khuyết điểm của compile-time binding](#câu-16--khuyết-điểm-của-compile-time-binding)
  - [Câu 18 — Chỉ nạp routine khi được gọi](#câu-18--chỉ-nạp-routine-khi-được-gọi)
  - [Câu 20 — Dịch logical address sang physical address](#câu-20--dịch-logical-address-sang-physical-address)
  - [Câu 21a — Số bit của logical address](#câu-21a--số-bit-của-logical-address)
  - [Câu 21b — Kích thước page table](#câu-21b--kích-thước-page-table)
  - [Câu 23c — Vị trí nhớ diễn tả trong chương trình](#câu-23c--vị-trí-nhớ-diễn-tả-trong-chương-trình)
  - [Câu 23d — Gom vùng trống bị phân mảnh ngoại](#câu-23d--gom-vùng-trống-bị-phân-mảnh-ngoại)
- [4. Ví dụ TypeScript để tự kiểm chứng](#4-ví-dụ-typescript-để-tự-kiểm-chứng)
- [5. Tự kiểm tra](#5-tự-kiểm-tra)
- [6. Nguồn](#6-nguồn)
- [7. Bạn cần tự làm lại phần nào](#7-bạn-cần-tự-làm-lại-phần-nào)

---

## 1. Đề đang kiểm tra những gì?

| Câu | Trang đề | Kiến thức cần nắm | Việc cần làm | Điểm |
|---|---:|---|---|---:|
| 3 | 1 | TLB, effective access time (EAT) | Giải ngược tìm thời gian tra TLB | 0,3 |
| 13 | 3 | First-fit, fixed partitioning | Duyệt đúng thứ tự, bỏ qua vùng đã cấp phát | 0,3 |
| 14 | 3 | External và internal fragmentation | Nhận diện đủ tổng dung lượng nhưng thiếu vùng liên tục | 0,3 |
| 15 | 4 | Symbolic address | Xác định cách gọi tên địa chỉ trong source code | 0,3 |
| 16 | 4 | Compile-time binding | Suy ra việc phải làm khi đổi địa chỉ nạp | 0,3 |
| 18 | 4 | Dynamic loading và dynamic linking | Phân biệt nạp thủ tục với liên kết module | 0,3 |
| 20 | 5 | Paging | Tách page/offset, tra frame, ghép physical address | 0,3 |
| 21a | 5 | Cấu trúc logical address | Tính số bit của page number và offset | 0,5 |
| 21b | 5 | Page table | Tính số entry × số byte mỗi entry | 0,5 |
| 23c | 5 | Logical address | Điền tiếng Anh, tối đa 2 từ | 0,5 |
| 23d | 5 | Compaction | Điền tiếng Anh, tối đa 2 từ | 0,5 |
| **Tổng** | | **11 câu/ý** | | **4,1** |

**Căn cứ điểm:** phần 1 ghi 0,3 điểm/câu. Phần 2 ghi 0,5 điểm/câu và trang 6 tách thành 8 ô từ 21a đến 23d; hiểu mỗi ô là 0,5 điểm thì khớp tổng 4 điểm của phần 2. Chương 7 chỉ lấy bốn ô nêu trên. [Đề tr1, tr5–tr6]

**Ranh giới:** câu 6 có phương án B mô tả dynamic linking, nhưng câu hỏi chính thuộc Chương 8; chỉ dùng để nhắc phân biệt, không cộng thêm điểm. Các câu về page fault, FIFO/LRU thuộc Chương 8, không gộp vào đây chỉ vì cùng nói về bộ nhớ.

```text
Chương trình gọi một vị trí bằng cách nào? → Các kiểu địa chỉ, address binding
                             ↓
Nạp mã lúc nào? → Dynamic loading / dynamic linking
                             ↓
Chọn chỗ trống nào? → Placement → Phân mảnh → Compaction
                             ↓
Chia thành page/frame → Đổi địa chỉ → Số bit và kích thước page table
                             ↓
Tra page table tốn thời gian → TLB → Tính EAT
```

## 2. Kiến thức chắt lọc

### 2.1. Các kiểu địa chỉ và address binding — câu 15, 16, 23c

**Trực giác:** tên bạn dùng để gọi một món đồ chưa cho biết nó đang nằm ở ngăn nào.

**Analogy:** trong kho, bạn gọi “hộp dụng cụ”; người quản lý ghi “cách đầu kệ 12 ô”; khi xếp vào kho thật mới ra một số ô cụ thể. Đó là những cách biểu diễn khác nhau cho cùng thứ cần tìm.

**Ví dụ nhỏ:** tên biến `total` là ký hiệu trong source code. Giả sử nó nằm cách đầu module 12 byte; trong mô hình nạp liên tục tại địa chỉ nền 1000, vị trí thực là `1000 + 12 = 1012`. Chuyển nền thành 2000 thì vị trí thực đổi thành 2012. Đây là ví dụ relocation (tái định vị) đơn giản, không phải công thức dịch mọi địa chỉ trong paging.

**Định nghĩa theo slide:** [C7 s12, s18]

| Thuật ngữ | Ý nghĩa trong ngữ cảnh của đề |
|---|---|
| Symbolic address (địa chỉ ký hiệu) | Tên biểu diễn trong source code, như tên biến, nhãn |
| Logical address (địa chỉ luận lý), còn gọi virtual address | Vị trí nhớ được diễn tả trong chương trình; ở lúc chạy là địa chỉ phía chương trình/CPU trước khi dịch sang physical address |
| Relocatable address (địa chỉ khả tái định vị) | Biểu diễn tương đối so với một mốc, chẳng hạn cách đầu module 12 byte |
| Physical address (địa chỉ vật lý) | Vị trí thực trong bộ nhớ chính |
| Absolute address (địa chỉ tuyệt đối) | Slide dùng với nghĩa tương đương địa chỉ thực |

Hai câu **15 và 23c hỏi ở hai mức khác nhau**: câu 15 chỉ vào *tên biến trong source code*; câu 23c dùng nguyên mô tả khái quát của slide về *vị trí nhớ trong chương trình*. Không coi symbolic address và logical address là hai từ đồng nghĩa có thể thay tùy ý.

**Address binding (ánh xạ địa chỉ)** là chuyển địa chỉ từ một không gian sang không gian khác. Khi đã gắn sẵn địa chỉ thực, chuyển chương trình sang nơi khác sẽ khiến các địa chỉ đó không còn đúng. [C7 s18–s19, s22]

```text
Tên trong source → compiler tạo mã → linker/loader chuẩn bị → thực thi
                         ↑                     ↑                ↑
                    compile time          load time        execution time
                    Ba thời điểm có thể thực hiện binding
```

| Thời điểm binding | Cách làm trong mô hình slide | Khi vị trí nạp thay đổi |
|---|---|---|
| Compile time | Biết trước vị trí nạp, tạo địa chỉ tuyệt đối | Phải biên dịch lại |
| Load time | Giữ địa chỉ có thể relocation tới lúc loader biết địa chỉ nền | Phải reload theo nền mới |
| Execution time | Dịch khi chạy, có phần cứng hỗ trợ | Có thể cập nhật ánh xạ khi di chuyển; không cần biên dịch lại chỉ vì đổi vị trí vật lý |

**Chốt:** đọc đúng *dạng biểu diễn* ở câu 15/23c và đúng *thời điểm binding* ở câu 16. Không lấy hành vi của bundler TypeScript để suy ra binding của hệ điều hành.

### 2.2. Dynamic loading và dynamic linking — câu 18

**Trực giác:** phần ít dùng thì có thể chờ đến lúc cần mới mang vào.

**Analogy:** nhà hàng chỉ mang bộ dụng cụ làm bánh ra khi có khách gọi bánh. Một việc khác là xác định đầu bếp ngoài nào sẽ thực hiện món đó; “mang dụng cụ vào” và “nối tới người thực hiện” là hai trách nhiệm khác nhau.

**Ví dụ nhỏ:** chương trình có phần chính 80 KB và thủ tục báo lỗi 20 KB. Với mô hình chỉ nạp thủ tục khi gọi, lần chạy không gặp lỗi không phải nạp thêm 20 KB ấy. Ví dụ này chỉ xét dung lượng mã, bỏ qua metadata và overhead.

**Định nghĩa:** dynamic loading (nạp động) chỉ nạp một routine vào bộ nhớ chính khi routine đó được gọi. Dynamic linking (liên kết động) trì hoãn liên kết tới external module; slide mô tả stub (đoạn mã trung gian) tìm/nạp routine và chuyển tới địa chỉ của routine khi gọi lần đầu. Việc thực thi dynamic linking có thể kéo theo loading, nhưng tên hai cơ chế nhấn mạnh hai công việc khác nhau. [C7 s24–s25, s27]

**Liên hệ React:** `lazy(() => import('./Report'))` giúp hình dung việc trì hoãn tải một phần mã tới lúc cần render. Đây là analogy về thời điểm tải; chunk JavaScript và cơ chế của trình duyệt/bundler không phải mô hình DLL hay `.so` trong slide.

| Cụm mô tả | Tập trung vào việc gì? |
|---|---|
| “Thủ tục chỉ được nạp khi được gọi” | Thời điểm đưa mã vào bộ nhớ |
| “Liên kết tới external module sau khi tạo executable” | Thời điểm nối tham chiếu tới mã ngoài |

### 2.3. Fragmentation và compaction — câu 14, 23d

**Trực giác:** đủ chỗ cộng lại chưa chắc có một chỗ liền nhau đủ lớn.

**Analogy:** rạp còn 6 ghế trống nhưng chia thành hai cụm 3 ghế. Nhóm 4 người cần ngồi cạnh nhau vẫn không thể vào một cụm. Ngược lại, đặt riêng một phòng 6 chỗ cho 4 người thì 2 chỗ dư nằm bên trong phòng đã đặt.

**Ví dụ nhỏ:** có hai vùng trống 3 KB cách nhau bởi vùng đang dùng; yêu cầu một vùng liên tục 4 KB thất bại dù tổng trống là 6 KB. Nếu đã cấp một partition 6 KB cho process 4 KB, phần 2 KB còn thừa nằm trong partition được cấp.

**Định nghĩa:** external fragmentation (phân mảnh ngoại) là tổng vùng trống đủ nhưng không liên tục để đáp ứng cấp phát. Internal fragmentation (phân mảnh nội) là phần dư trong khối đã cấp do kích thước khối lớn hơn yêu cầu. Compaction (kết khối) gom vùng trống bị phân mảnh ngoại thành một vùng liên tục. [C7 s31]

```text
Trước: [P1][trống 3 KB][P2][trống 3 KB]
Sau:   [P1][P2][       trống 6 KB      ]
           Di chuyển vùng đang dùng để gom chỗ trống
```

**Điều kiện bổ sung:** sơ đồ giả sử có thể di chuyển và cập nhật địa chỉ của vùng đang dùng. Compaction có chi phí sao chép/relocation; không tự làm phần dư *bên trong* partition đã cấp biến thành vùng cấp phát tự do. Đây là giải thích cơ chế ngoài câu định nghĩa ngắn của s31.

| Vấn đề | Chỗ bị lãng phí nằm ở đâu? | Compaction có nhắm vào nó không? |
|---|---|---|
| External fragmentation | Các vùng trống rời nhau | Có, gom thành vùng liên tục nếu di chuyển được |
| Internal fragmentation | Bên trong khối đã cấp | Không giải quyết bằng cách dồn các khối |

### 2.4. Placement và first-fit — câu 13

**Trực giác:** có nhiều chỗ vừa thì vẫn cần một quy tắc chọn chỗ.

**Analogy:** tìm tủ đựng vali: có người kiểm tra từ tủ đầu tiên và dừng ngay khi gặp tủ vừa; người khác tiếp tục từ lần tìm trước; người khác tìm tủ vừa khít nhất.

**Ví dụ nhỏ:** ba partition trống theo thứ tự `100, 300, 200 KB`, process cần `180 KB`. First-fit chọn partition 300 KB vì đó là chỗ đầu tiên đủ; best-fit chọn 200 KB vì nhỏ nhất trong các chỗ đủ. Đây là ví dụ riêng, không phải số liệu câu 13.

**Định nghĩa:** fixed partitioning (phân vùng cố định) chia sẵn bộ nhớ thành các partition; một process được cấp trọn một partition đủ lớn. Chiến lược placement (chọn vị trí cấp phát) quyết định chọn vùng trống nào. Slide giới thiệu các chiến lược dưới dynamic partitioning; câu 13 áp dụng **quy tắc chọn first-fit trên danh sách partition cố định**. [C7 s34, s39]

| Thuật toán | Quy tắc trên các vùng còn trống và đủ lớn |
|---|---|
| First-fit | Tìm từ đầu bộ nhớ, chọn vùng phù hợp đầu tiên |
| Next-fit | Tiếp tục tìm từ vị trí cấp phát trước đó, quét vòng khi cần |
| Best-fit | Chọn vùng nhỏ nhất vẫn chứa được process |
| Worst-fit | Chọn vùng lớn nhất |

**Bất biến khi duyệt:** một ứng viên phải vừa **trống**, vừa có `size ≥ request`. Với first-fit, mọi vùng đứng trước vùng chọn đều phải bị loại bởi ít nhất một điều kiện ấy. Code TypeScript ở mục 4 mô phỏng đúng hai điều kiện này.

**Chốt:** con trỏ không làm first-fit biến thành next-fit. Với fixed partitioning, phần dư vẫn thuộc partition đã cấp, không tự tách thành hole (vùng trống) để cấp tiếp.

### 2.5. Paging: đổi địa chỉ, đếm bit và kích thước bảng — câu 20, 21a, 21b

**Trực giác:** chia đồ thành các hộp bằng nhau giúp đặt chúng ở nhiều chỗ mà vẫn tìm đúng món bên trong.

**Analogy:** sách chia thành trang; sổ tra cứu cho biết từng trang đang ở ngăn nào. Muốn tìm chữ, cần số trang và vị trí chữ trên trang. Chuyển trang sang ngăn khác không làm vị trí chữ trong trang thay đổi.

**Ví dụ nhỏ:** mỗi page 16 byte; page table là `0 → 3, 1 → 1`. Logical address 21 nằm ở page 1, offset (độ lệch trong trang) 5. Page 1 nằm ở frame 1 nên physical address là `1 × 16 + 5 = 21`. Hai con số bằng nhau chỉ do ánh xạ tình cờ; nếu page 1 ở frame 4 thì kết quả là 69.

**Định nghĩa:** paging (phân trang) chia không gian logical thành page và bộ nhớ physical thành frame cùng kích thước. Page table (bảng trang) ánh xạ page number sang frame number. Địa chỉ gồm hai phần; phần offset giữ nguyên khi dịch. [C7 s42, s44–s45]

```text
Logical address L
       │ chia cho kích thước page P
       ├── thương p ── pageTable[p] ── frame f ─┐
       └── dư d ────────────────────────────────┤
                                    Physical = f × P + d
```

Với địa chỉ tính theo **byte**, đánh số page/frame từ **0**:

```text
p = floor(L / P)       d = L mod P
f = pageTable[p]       physical = f × P + d
```

**Đếm bit:** nếu có `N = 2^k` page, mỗi page `P = 2^n` byte, thì page number cần `k` bit và offset cần `n` bit. Logical address cần `k + n = log₂(N × P)` bit. Với `F = 2^r` frame, physical address cần `r + n` bit. [C7 s44]

**Kích thước bảng:** trong mô hình bảng một cấp đầy đủ của bài, mỗi logical page có một entry. Vì vậy `tableBytes = N × entryBytes`. Số frame quyết định số giá trị frame number cần biểu diễn, **không thay thế N khi đếm entry**. Một entry còn có thể có metadata; khi đề đã cho byte/entry, dùng nguyên số đó. [C7 s44; công thức nhân byte suy ra từ số entry]

Ví dụ riêng: `N = 8`, `P = 16 byte`, `F = 4`, entry 2 byte → logical address 7 bit, physical address 6 bit, bảng trang 16 byte. Không gian địa chỉ có `2^7 = 128` byte, địa chỉ lớn nhất là **127**, không phải 128.

**Code:** mục 4 mô phỏng các công thức trên; dữ liệu ví dụ nhỏ khác đề.

| Cần tìm | Dữ kiện phải dùng | Tự kiểm tra |
|---|---|---|
| Physical address | Logical address, page size, page table | `physical mod P = L mod P` |
| Số bit logical | Số page, số byte/page | Đủ biểu diễn địa chỉ từ 0 đến `N × P − 1` |
| Số byte page table | Số logical page, số byte/entry | Đơn vị kết quả là byte, không phải bit |

### 2.6. TLB và effective access time — câu 3

**Trực giác:** nhớ sẵn chỗ cất đồ sẽ bớt được một lần đi tra sổ.

**Analogy:** thủ thư có giấy ghi nhanh vị trí các cuốn thường mượn. Nếu giấy có thông tin, đi thẳng đến kệ lấy sách. Nếu không, tra sổ lớn rồi mới đến kệ. Không thấy trên giấy chưa có nghĩa thư viện không có sách.

**Ví dụ nhỏ:** tra giấy mất 10 ns, mỗi lần vào RAM mất 100 ns, hit ratio 80%. Một hit mất 110 ns; một miss mất 210 ns. Trung bình `0,8 × 110 + 0,2 × 210 = 130 ns`.

**Định nghĩa:** TLB (Translation Lookaside Buffer, bộ đệm ánh xạ địa chỉ) giữ một số ánh xạ page → frame. EAT (Effective Access Time, thời gian truy xuất hiệu dụng) là trung bình có trọng số của các nhánh hit/miss. Trong mô hình slide, page table nằm trong RAM và một lần tra bảng cần một lần truy cập RAM. [C7 s49, s51, s53]

```text
Tra TLB (ε) ── hit  (α) ──────→ Đọc dữ liệu RAM (x)
       └────── miss (1 − α) ──→ Đọc page table (x) → Đọc dữ liệu RAM (x)
```

```text
EAT = α(ε + x) + (1 − α)(ε + 2x)
    = ε + (2 − α)x
⇒ ε = EAT − (2 − α)x
```

**Giả thiết:** TLB được tra tuần tự trước RAM; các lần RAM có cùng thời gian `x`; bỏ qua các cấp cache khác và page fault (lỗi trang). **TLB miss không đồng nghĩa page fault**: thiếu ánh xạ trong TLB vẫn có thể tra bảng và đọc dữ liệu đang nằm trong RAM. Không tự thêm thời gian đọc đĩa khi đề không cho mô hình đó.

Slide s53 gọi các nhánh là “thời gian cần thiết để có được chỉ số frame”, nhưng công thức `ε + x` / `ε + 2x` đã tính cả lần đọc dữ liệu cuối. Guide dùng công thức với nghĩa **thời gian hoàn thành truy cập bộ nhớ**, phù hợp sơ đồ s51 và đề câu 3.

**Code:** mục 4 tính độc lập hai nhánh rồi lấy trung bình.

| Trường hợp kiểm biên | EAT phải bằng |
|---|---|
| `α = 1`, luôn hit | `ε + x` |
| `α = 0`, luôn miss | `ε + 2x` |
| `0 ≤ α ≤ 1` | Nằm giữa hai giá trị trên |

## 3. Hướng dẫn từng câu trong đề

Các câu dưới giữ dữ kiện và nhãn phương án của mã đề 01. Phần diễn đạt được rút gọn khi không ảnh hưởng yêu cầu. Bạn tự ghi lựa chọn/kết quả ở mục 7 sau khi làm; không có bảng đáp án chọn sẵn.

### Câu 3 — Tìm thời gian tra TLB

**Đề:** page table nằm trong RAM, `α = 0,95`, `x = 160 ns`, `EAT = 190 ns`. Tìm `ε`. [Đề tr1, C3]

| A | B | C | D |
|---|---|---|---|
| 30 ns | 22 ns | 152 ns | 320 ns |

**Kiến thức:** mục 2.6; [C7 s53].

1. Xác định điều chưa biết là thời gian lookup, không phải hit ratio.
2. Viết hai nhánh `ε + 160` và `ε + 320`, gắn xác suất `0,95` và `0,05`.
3. Lập `190 = 0,95(ε + 160) + 0,05(ε + 320)`.
4. Thu gọn thành `ε = 190 − (2 − 0,95) × 160`, tự tính rồi đối chiếu phương án.

**Bẫy:** lấy `EAT − x` sẽ bỏ quên chi phí tra page table khi miss. Hit ratio là **0,95**, không phải 95; mọi thời gian đều tính bằng ns.

**Tự kiểm tra:** thay `ε` vừa tìm vào biểu thức hai nhánh phải thu lại 190 ns. Đồng thời `ε ≥ 0` và EAT nằm giữa thời gian hit/miss.

### Câu 13 — First-fit trên các partition cố định

**Đề:** process P cần **220 KB**; con trỏ PC nằm ở vùng 3; vùng 3 đã được cấp phát, các vùng khác trống. Dùng **first-fit** thì chọn vùng nào? [Đề tr3, C13]

| Thứ tự | Kích thước | Trạng thái ban đầu |
|---|---:|---|
| Vùng 1 | 150 KB | Trống |
| Vùng 2 | 250 KB | Trống |
| Vùng 3 | 380 KB | Đã cấp phát; PC tại đây |
| Vùng 4 | 420 KB | Trống |
| Vùng 5 | 320 KB | Trống |
| Vùng 6 | 240 KB | Trống |

| A | B | C | D |
|---|---|---|---|
| Vùng 2 — 250 KB | Vùng 1 — 150 KB | Vùng 4 — 420 KB | Vùng 6 — 240 KB |

**Kiến thức:** mục 2.4; [C7 s34, s39].

1. Gạch chân **first-fit**: bắt đầu duyệt ở vùng 1, không bắt đầu tại PC.
2. Lập bảng duyệt; với mỗi vùng, kiểm tra `trống AND kích thước ≥ 220 KB`.
3. Dừng ngay khi gặp vùng đầu tiên thỏa cả hai điều kiện; không tìm tiếp vùng vừa khít hơn.
4. Sau khi chọn, đánh dấu **cả partition** đã cấp cho P. Tính phần dư bằng `kích thước partition − 220 KB` nếu muốn tự kiểm tra internal fragmentation.

| Bước tự điền | Trống? | Đủ 220 KB? | Hành động |
|---|---|---|---|
| Xét vùng 1 | Có | Tự so sánh | Dừng hoặc sang vùng kế |
| Xét vùng tiếp theo nếu cần | Đọc trạng thái ban đầu | Tự so sánh | Gặp vùng phù hợp đầu tiên thì dừng |

**Bẫy:** PC gợi next-fit; “vừa khít nhất” gợi best-fit. Không coi phần dư của fixed partition là một hole mới. Chế độ `place` của script L08 trừ kích thước hole để mô phỏng cấp phát động, nên không dùng nguyên trạng cho trạng thái fixed partition sau câu này.

**Tự kiểm tra:** giải thích vì sao *mọi vùng trước vùng chọn* không hợp lệ. Nếu bạn bỏ qua một vùng trống đủ lớn ở trước, bạn chưa làm first-fit.

### Câu 14 — Nhận diện loại fragmentation

**Đề:** tổng không gian nhớ trống đủ thỏa yêu cầu cấp phát, nhưng không liên tục; tình trạng này gọi là gì? [Đề tr3, C14]

| A | B | C | D |
|---|---|---|---|
| External fragmentation | Fixed partitioning | Internal fragmentation | Dynamic partitioning |

**Kiến thức:** mục 2.3; [C7 s31].

1. Đề yêu cầu tên **tình trạng**, không phải tên cách chia bộ nhớ.
2. Xác định chỗ trống nằm giữa các vùng đang dùng hay bên trong vùng đã cấp.
3. Đối chiếu hai điều kiện “tổng đủ” và “không liên tục” với định nghĩa; tự chọn phương án.

**Bẫy:** “vẫn còn thừa bộ nhớ” chưa đủ kết luận internal fragmentation; phải biết phần thừa ở đâu.

**Tự kiểm tra:** vẽ hai hole 3 KB bị ngăn cách, yêu cầu 4 KB. Chỉ ra vì sao cộng được 6 KB mà vẫn cấp phát thất bại trong mô hình cấp phát liên tục.

### Câu 15 — Tên biến trong source code

**Đề:** các biến `a`, `b`, `c` trong chương trình sau được gọi bằng thuật ngữ nào? Code giữ nguyên theo đề. [Đề tr4, C15]

```c
#include <stdio.h>
int main()
{
    int a, b;
    int c = a + b;
    printf("Ket qua cua c la %d", c);
    return 1;
}
```

| A | B | C | D |
|---|---|---|---|
| Symbolic address | Physical address | Absolute address | Relocatable address |

**Kiến thức:** mục 2.1; [C7 s18], phân loại ở [C7 s12].

1. Xác định đề đang chỉ vào **tên trong source code**, chưa đưa địa chỉ RAM hoặc offset.
2. Đối chiếu ba dạng biểu diễn ở s18: tên ký hiệu → địa chỉ tương đối → vị trí thực.
3. Chọn thuật ngữ cho dạng đang được nhìn thấy; không suy diễn địa chỉ cụ thể của `a`, `b`, `c`.

**Bẫy:** đề dùng cách nói tắt “các biến được gọi là…”, thực chất hỏi cách biểu diễn địa chỉ bằng tên biến trong ngữ cảnh address binding. `a`, `b` chưa khởi tạo nên đoạn C không dùng làm ví dụ chạy tính tổng; không có kết quả số đáng tin cậy để suy ra.

**Tự kiểm tra:** nếu thay tên biến bằng “cách đầu module 12 byte”, khái niệm nào trong bảng mục 2.1 sẽ phù hợp hơn?

### Câu 16 — Khuyết điểm của compile-time binding

**Đề:** khuyết điểm của việc chuyển địa chỉ lệnh/dữ liệu thành địa chỉ thực **tại thời điểm biên dịch** là gì? [Đề tr4, C16]

| Nhãn | Phương án |
|---|---|
| A | Phải reload nếu thay đổi địa chỉ nền |
| B | Phải trì hoãn quá trình chuyển đổi địa chỉ đến thời điểm thực thi |
| C | Phải biên dịch lại nếu thay đổi địa chỉ nạp chương trình |
| D | Địa chỉ thực phải được tính toán vào thời điểm viết chương trình |

**Kiến thức:** mục 2.1; [C7 s19].

1. Giả sử compiler đã tạo địa chỉ tuyệt đối dựa trên nền 1000.
2. Thử chuyển chương trình sang nền 2000: địa chỉ đã ghi trong mã có tự đổi không?
3. Xác định phải làm lại công đoạn nào để tạo mã với các địa chỉ mới; đối chiếu lựa chọn.

**Bẫy:** reload và recompile thuộc hai hàng khác nhau trong bảng binding. Thời điểm **viết code** cũng khác thời điểm **biên dịch**.

**Tự kiểm tra:** diễn giải lại bằng cặp ví dụ `1000 + 12` và `2000 + 12`, sau đó nói vì sao lời giải sẽ khác nếu đề hỏi load-time binding.

### Câu 18 — Chỉ nạp routine khi được gọi

**Đề:** cơ chế “chỉ khi nào cần được gọi đến thì một thủ tục mới được nạp vào bộ nhớ chính” gọi là gì? [Đề tr4, C18]

| A | B | C | D |
|---|---|---|---|
| Static linking | Dynamic loading | Static fragmentation | Dynamic linking |

**Kiến thức:** mục 2.2; [C7 s27], đối chiếu [C7 s24].

1. Gạch chân động từ **nạp** và điều kiện **khi được gọi**.
2. Phân biệt yêu cầu về thời điểm nạp routine với yêu cầu liên kết tới external module.
3. Ghép mô tả chính xác với định nghĩa s27; không chọn chỉ vì thấy chữ “dynamic”.

**Bẫy:** mô tả dynamic linking trong slide cũng có bước nạp routine. Hãy nhận diện đặc trưng mà câu hỏi đang định nghĩa, không tìm một từ tình cờ xuất hiện trong cả hai cơ chế.

**Tự kiểm tra:** viết một câu riêng cho “trì hoãn nạp” và một câu cho “trì hoãn liên kết”. Dùng `React.lazy` để nhớ ý trì hoãn tải, nhưng giải thích đáp án bằng thuật ngữ hệ điều hành.

### Câu 20 — Dịch logical address sang physical address

**Đề:** kích thước frame là **2 KB**, logical address **7654**, page table như sau. Tìm physical address. [Đề tr5, C20]

| Page | Frame |
|---:|---:|
| 0 | 5 |
| 1 | 3 |
| 2 | 4 |
| 3 | 2 |

| A | B | C | D |
|---|---|---|---|
| 5606 | 9702 | 6144 | 1510 |

**Kiến thức:** mục 2.5; [C7 s44–s45]. **Quy ước bài tính:** địa chỉ theo byte, `2 KB = 2 × 1024 = 2048 byte` (cách dùng KB nhị phân trong bài tập bộ nhớ; tương ứng 2 KiB), page và frame cùng kích thước.

1. Tính `p = floor(7654 / 2048)` và `d = 7654 mod 2048`.
2. Tìm **hàng có Page = p**, lấy Frame ở cùng hàng làm `f`.
3. Tính `physical = f × 2048 + d`, rồi đối chiếu phương án.
4. Kiểm tra địa chỉ nằm trong frame đó: `f × 2048 ≤ physical < (f + 1) × 2048`.

**Bẫy:** không đổi page number thành frame number bằng cộng/trừ cố định; phải tra bảng. Không lấy riêng offset làm physical address; cũng không bỏ offset và chỉ lấy địa chỉ đầu frame.

**Tự kiểm tra:** `physical mod 2048` phải bằng `7654 mod 2048`; `0 ≤ d < 2048`. Giữ nguyên đơn vị byte trong cả phép chia và phép nhân.

### Câu 21a — Số bit của logical address

**Đề:** không gian địa chỉ ảo có **256 page**, mỗi page **4096 byte**, ánh xạ vào bộ nhớ physical **64 frame**. Logical address gồm bao nhiêu bit? [Đề tr5, C21a]

**Kiến thức:** mục 2.5; [C7 s44].

1. Viết `256 = 2^k` để tìm số bit page number.
2. Viết `4096 = 2^n` để tìm số bit offset.
3. Cộng `k + n`; ghi kết quả với đơn vị **bit**.
4. Kiểm tra độc lập bằng `2^(k+n) = 256 × 4096` địa chỉ byte.

**Bẫy:** 64 frame thuộc phía physical, không thay 256 page khi tính logical address. Chỉ tính `log₂(4096)` sẽ mới có offset, chưa có page number. Số địa chỉ lớn nhất bằng tổng số byte **trừ 1**.

**Tự kiểm tra:** nếu giữ nguyên số page và page size nhưng tăng số frame gấp đôi, kết quả câu 21a có cần đổi không? Giải thích trước khi điền ô trả lời.

### Câu 21b — Kích thước page table

**Đề:** dùng dữ kiện câu 21; mỗi entry trong page table cần **4 byte**. Bảng cần bao nhiêu byte? [Đề tr5, C21b]

**Kiến thức:** mục 2.5; [C7 s44]. Áp dụng mô hình bảng một cấp đầy đủ của bài, không tự thay bằng inverted page table (bảng trang nghịch đảo).

1. Hỏi bảng được đánh chỉ số bằng **page** hay **frame**.
2. Suy ra số entry từ số logical page.
3. Lập `tableBytes = 256 entry × 4 byte/entry`, tự tính và ghi **byte**.

**Bẫy:** `64 × 4` là nhầm số frame với số entry. Không tự thay 4 byte bằng số bit tối thiểu để mã hóa frame number: đề đã quy định kích thước **toàn entry**.

**Tự kiểm tra:** tăng số page gấp đôi, giữ 4 byte/entry thì bảng phải lớn gấp đôi. Tăng dung lượng RAM nhưng giữ số page và kích thước entry thì bảng trong mô hình này không tự tăng.

### Câu 23c — Vị trí nhớ diễn tả trong chương trình

**Đề:** “Một vị trí nhớ được diễn tả trong một chương trình được gọi là gì?” Trả lời **tiếng Anh, tối đa 2 từ**. [Đề tr5, C23c]

**Kiến thức:** mục 2.1; [C7 s12].

1. Đối chiếu nguyên mô tả này với bảng các kiểu địa chỉ ở s12.
2. Phân biệt vị trí trong cách nhìn của chương trình với vị trí thực trong RAM.
3. Viết thuật ngữ tiếng Anh đúng với tên chính trên slide; không thêm câu giải thích vào ô đáp án.

**Bẫy:** đừng bê lựa chọn từ câu 15 sang: câu 15 chỉ tên biến ở source code, còn câu này dùng định nghĩa khái quát s12. Slide ghi thêm một tên đồng nghĩa; để bám đề, ưu tiên tên chính của định nghĩa.

**Tự kiểm tra:** tự nói cặp thuật ngữ “phía chương trình → phía RAM” rồi kiểm số từ trước khi ghi.

### Câu 23d — Gom vùng trống bị phân mảnh ngoại

**Đề:** cơ chế gom các vùng nhớ bị phân mảnh ngoại thành một vùng nhớ liên tục gọi là gì? Trả lời **tiếng Anh, tối đa 2 từ**. [Đề tr5, C23d]

**Kiến thức:** mục 2.3; [C7 s31].

1. Xác định đề hỏi **cơ chế xử lý**, không hỏi tên hiện tượng.
2. Vẽ trạng thái trước/sau như sơ đồ mục 2.3: tổng dung lượng trống giữ nguyên, bố cục đổi.
3. Điền tên cơ chế trong slide bằng tiếng Anh, không viết lại “external fragmentation”.

**Bẫy:** giải phóng thêm bộ nhớ và gom bộ nhớ đang trống là hai việc khác nhau. Paging bỏ yêu cầu mọi page của process nằm liền nhau; đó cũng không phải tên thao tác đang được mô tả.

**Tự kiểm tra:** giải thích cơ chế này có tạo thêm byte RAM không và có chữa internal fragmentation không.

## 4. Ví dụ TypeScript để tự kiểm chứng

Đây là **mô hình tính toán**, không đọc địa chỉ RAM thật của trình duyệt. Các hàm thuần có thể dùng làm logic của một màn hình luyện tập React; không cần dựng UI để hiểu công thức. Dữ liệu minh họa khác số liệu đề, giả sử địa chỉ hợp lệ, page/frame đánh số từ 0, số page và page size là lũy thừa của 2.

Lưu đoạn dưới thành `memory-demo.ts`, chạy bằng `tsx memory-demo.ts` trong môi trường TypeScript đã có `tsx`:

```typescript
type Partition = { sizeKB: number; free: boolean };

function firstFit(partitions: readonly Partition[], requestKB: number) {
  // Trả về chỉ số từ 0; -1 nếu không có partition phù hợp.
  return partitions.findIndex(p => p.free && p.sizeKB >= requestKB);
}

function translate(logical: number, pageSize: number, table: readonly number[]) {
  const page = Math.floor(logical / pageSize);
  const offset = logical % pageSize;
  const frame = table[page];
  if (frame === undefined) throw new Error("Page không có trong bảng ví dụ");
  return { page, offset, frame, physical: frame * pageSize + offset };
}

function layout(pages: number, pageSize: number, entryBytes: number) {
  const pageBits = Math.log2(pages);
  const offsetBits = Math.log2(pageSize);
  return { logicalBits: pageBits + offsetBits, tableBytes: pages * entryBytes };
}

function eat(alpha: number, memoryNs: number, lookupNs: number) {
  const hitNs = lookupNs + memoryNs;
  const missNs = lookupNs + 2 * memoryNs;
  return alpha * hitNs + (1 - alpha) * missNs;
}

const partitions: Partition[] = [
  { sizeKB: 100, free: true },
  { sizeKB: 300, free: true },
  { sizeKB: 200, free: true },
];
const address = translate(21, 16, [3, 4]);
console.log({
  partitionIndex: firstFit(partitions, 180),
  address,
  layout: layout(8, 16, 2),
  eatNs: eat(0.8, 100, 10),
});
```

Kết quả minh họa: `partitionIndex = 1` (partition thứ hai); `page = 1`, `offset = 5`, `frame = 4`, `physical = 69`; `logicalBits = 7`, `tableBytes = 16`; `eatNs = 130`. Hàm first-fit chỉ **chọn**, chưa thay đổi trạng thái cấp phát.

**Tự biến đổi đầu vào:** đặt `free: false` cho partition 300 KB rồi dự đoán vùng tiếp theo; đổi frame của page 1 và quan sát offset giữ nguyên; thử hit ratio 0 và 1. Sau khi hiểu mô hình, dùng hàm để kiểm tra bài đã làm tay.

## 5. Tự kiểm tra

**1. Tên biến `total`, vị trí “cách đầu module 12 byte” và một vị trí RAM cụ thể khác nhau ở đâu?**

<details><summary>Đáp án</summary>

Lần lượt là symbolic address, relocatable address và physical address trong mô hình slide. Chúng khác cách biểu diễn và giai đoạn đã biết vị trí. Nếu compile-time binding đã ghi địa chỉ tuyệt đối mà đổi địa chỉ nạp, phải biên dịch lại. [C7 s12, s18–s19]

</details>

**2. Vì sao “chỉ nạp khi được gọi” chưa đủ để nói mọi trường hợp ấy đều là dynamic linking?**

<details><summary>Đáp án</summary>

Mô tả đó định nghĩa dynamic loading. Dynamic linking nhấn mạnh việc trì hoãn liên kết tới external module. Trong triển khai hai việc có thể phối hợp, nhưng nhiệm vụ và định nghĩa khác nhau. [C7 s24, s27]

</details>

**3. Các partition cố định trống có kích thước 100, 300, 200 KB; cần 180 KB. First-fit chọn gì, phần dư thuộc loại nào? Compaction có xử lý phần dư đó không?**

<details><summary>Đáp án</summary>

Chọn partition 300 KB, vì đó là vùng đầu tiên đủ lớn. Phần dư 120 KB trong partition đã cấp là internal fragmentation. Compaction nhắm tới các hole rời nhau gây external fragmentation, không biến phần dư trong partition thành vùng cấp phát mới. [C7 s31, s34, s39]

</details>

**4. Với page size 16 byte và page 1 ở frame 4, logical address 21 dịch thế nào? Nếu có 8 page, entry 2 byte thì bảng trang có bao nhiêu byte?**

<details><summary>Đáp án</summary>

`21 = 1 × 16 + 5` → page 1, offset 5 → physical `4 × 16 + 5 = 69`. Offset vẫn 5. Bảng một cấp đầy đủ có 8 entry, tổng `8 × 2 = 16 byte`; không lấy số frame để đếm entry. [C7 s44–s45]

</details>

**5. Vì sao TLB miss mất hai lần RAM trong mô hình bài? Nếu hit ratio tăng, EAT thay đổi thế nào?**

<details><summary>Đáp án</summary>

Một lần đọc page table để lấy frame, một lần đọc dữ liệu; cộng lookup TLB. Với `x > 0` và `ε` giữ nguyên, `EAT = ε + (2 − α)x` giảm khi `α` tăng. Miss trong TLB không tự suy ra page fault hoặc cần đọc đĩa. [C7 s49, s51, s53]

</details>

## 6. Nguồn

| Mã | Tài liệu | Phần đã đối chiếu cho guide |
|---|---|---|
| Đề | [Final-Exam-Sample.pdf](Final-Exam-Sample.pdf) | Đã đọc đủ 6 trang; dữ kiện và phương án câu 3, 13–16, 18, 20; câu 21a/b, 23c/d; cách chia điểm và bảng trả lời trống |
| C7 | [Copy of #Week12-Chapter7 2024.pdf](../materials/slides/Copy%20of%20%23Week12-Chapter7%202024.pdf) — 72 trang | s12: kiểu địa chỉ; s18–s19, s22: binding; s24–s25, s27: linking/loading; s31: fragmentation; s34, s39: partition/placement; s42, s44–s45: paging; s49, s51, s53: TLB/EAT |
| L08 | [L08-memory-management.md](../lectures/L08-memory-management.md) | Note tổng hợp Chương 7, giải thích và bài tập rộng hơn phạm vi đề mẫu |
| Map | [exam-map.md](exam-map.md) | Chỉ mục câu → chương và tỷ trọng toàn đề; số liệu guide được đối chiếu lại với PDF |
| Code có sẵn | [memory-calc.py](../code/L08/memory-calc.py) | Công cụ tham khảo cho paging/EAT; lưu ý chế độ `place` mô phỏng vùng trống có thể chia nhỏ, không phải cấp trọn fixed partition của C13 |

**Giới hạn nguồn:** chưa có đáp án chính thức để so với đáp án người ra đề; KB được hiểu theo quy ước nhị phân ở C20. Công thức EAT dùng đúng mô hình đơn giản của slide, không đại diện mọi kiến trúc CPU. Ví dụ và code trong guide là phần bổ sung để học, không phải tín hiệu “giảng viên bảo sẽ thi”.

## 7. Bạn cần tự làm lại phần nào

1. **Tự suy ra công thức:** vẽ hai nhánh TLB rồi lập EAT; vẽ `page → frame` rồi suy ra công thức dịch địa chỉ. Chưa dùng code ở bước này.
2. **Làm tay câu 3, 13, 20, 21a, 21b:** ghi cả đơn vị, bước trung gian và cách kiểm tra; sau đó mới dùng công cụ kiểm kết quả.
3. **Phân biệt bằng một câu:** symbolic/logical/physical; compile/load/execution time; loading/linking; external/internal fragmentation; first/next/best-fit.
4. **Tự điền 23c và 23d bằng tiếng Anh:** không nhìn bảng định nghĩa, tối đa 2 từ mỗi ô.
5. **Đổi dữ kiện để kiểm tra hiểu:** thay PC khi vẫn dùng first-fit; thay frame nhưng giữ logical address; thay hit ratio nhưng giữ thời gian RAM. Dự đoán phần nào đổi và phần nào giữ nguyên.

| Câu | Lựa chọn/kết quả tự làm | Lý do hoặc phép kiểm tra |
|---|---|---|
| 3 | | |
| 13 | | |
| 14 | | |
| 15 | | |
| 16 | | |
| 18 | | |
| 20 | | |
| 21a | | |
| 21b | | |
| 23c | | |
| 23d | | |
