# IT007 — Cheatsheet Chương 5: Đồng bộ tiến trình

> Chắt lọc từ [guide Chương 5](chapter5-exam-study-guide.md) để xem nhanh trước giờ thi. Giải thích đầy đủ nằm trong guide.
> Đáp án là **suy luận**, vì đề mẫu không có đáp án chính thức. `[C5-2 s16]` = slide C5-2, trang PDF 16.

---

## Semaphore: wait và signal (Semaphore operations) — câu 1, 4

**Định nghĩa theo slide** [C5-2 s16]

```text
wait(S)   { while (S <= 0) ; S--; }   ← "dùng khi muốn sử dụng tài nguyên" → GIẢM
signal(S) { S++; }                    ← "dùng khi trả lại tài nguyên"     → TĂNG
```

| Loại [C5-2 s26] | Giá trị | Ghi nhớ |
|---|---|---|
| Counting semaphore | số nguyên không giới hạn | giới hạn số tiến trình dùng đồng thời một tài nguyên |
| Binary semaphore | 0 hoặc 1 | "có tác dụng giống với khóa mutex" |

**Câu 1** — thao tác *sử dụng tài nguyên*? `[Đề tr1, C1]` → **B — `wait(S)`**.
**Câu 4** — tìm phát biểu **SAI** `[Đề tr1, C4]` → **C — "`sem_wait()` luôn tăng giá trị lên 1"**.

**Kiểm tra (30 giây):** `S = 1`, một tiến trình lấy suất → còn `0`. Thao tác "xin" làm số giảm thì phải là `wait`.

**Bẫy**

| Làm sai | Ra phương án | Nhận ra vì |
|---|---|---|
| C1: nhầm chiều "xin" và "trả" | **A — `signal(S)`** | `signal` dùng khi **trả lại** tài nguyên |
| C1: chọn theo nghĩa tiếng Anh "cấp phát" | **D — `allocate(S)`** | Slide chỉ có cặp `wait`/`signal` (P/V) |
| C1: chọn theo nghĩa "trả về" | **C — `return(S)`** | Không phải primitive của semaphore |
| C4: biết mutex OS có ownership nên cho là B sai | **B** | Đề nói "thường dùng như mutex", khớp slide s26 |
| C4: cho là A sai vì nghĩ semaphore chỉ dùng cho process | **A** | Slide dùng cho cả tiến trình lẫn tiểu trình |
| C4: cho là D sai vì nhầm sang binary | **D** | Counting semaphore chính là để giới hạn số truy cập |

---

## Ba yêu cầu của lời giải (Mutual exclusion / Progress / Bounded waiting) — câu 2

**Định nghĩa theo slide** [C5-1 s21–s25]

| Yêu cầu | Câu chữ slide (rút gọn) | Hỏi nhanh |
|---|---|---|
| (1) Mutual exclusion | P đang trong CS thì không Q nào khác trong CS | Có ai **cùng vào** không? |
| (2) Progress | Tiến trình tạm dừng **bên ngoài** CS không được cản người khác vào | CS trống có bị **cản** không? |
| (3) Bounded waiting | Mỗi tiến trình chỉ chờ trong khoảng **có hạn định**; không starvation | Có ai **chờ mãi** không? |

**Từ khóa nhận diện:** "không có Q nào khác" → ME · "bên ngoài… không được ngăn cản" → progress · "chờ… có hạn định" → bounded waiting.

**Đề mẫu:** phát biểu (1)…(4) ứng với A…D; hỏi bounded waiting `[Đề tr1, C2]` → **D — phát biểu (4)**.

**Bẫy**

| Làm sai | Ra phương án | Nhận ra vì |
|---|---|---|
| Thấy "chờ" là nghĩ tới nhường CPU | **B — (2) phải từ bỏ CPU** | Đó là **cách chờ**, không phải yêu cầu nào; Peterson spin mà vẫn đạt đủ 3 |
| Nhầm "không ai chen vào" với "không ai chờ mãi" | **A — (1)** | (1) là mutual exclusion |
| Cho rằng progress là đủ để mọi người được phục vụ | **C — (3)** | Progress chỉ cấm cản khi CS trống; một người vẫn có thể bị bỏ lại |

---

## Mutex không busy waiting (Block / Wakeup) — câu 5

**Định nghĩa theo slide** [C5-2 s10]: tạm đặt tiến trình vào trạng thái **ngủ khi khóa bị khóa**, **đánh thức khi khóa được mở**.

```text
khóa đang bị giữ → block  : vào hàng đợi, ngủ (không tốn CPU)
khóa được trả    → wakeup : ra khỏi hàng đợi → hàng đợi sẵn sàng (ready), chưa chạy ngay
```

| | Spinlock | Mutex không busy waiting |
|---|---|---|
| Chờ bằng | vòng lặp kiểm tra khóa | ngủ trong hàng đợi |
| Tốn CPU khi chờ | có | không |

**Đề mẫu** `[Đề tr2, C5]` → **D — ngủ khi khóa bị giữ; đánh thức khi khóa mở**.

**Bẫy**

| Làm sai | Ra phương án | Nhận ra vì |
|---|---|---|
| Ghép đúng từ nhưng đảo điều kiện | **A — ngủ khi khóa mở, dậy khi khóa bị giữ** | Khóa mở thì đi vào luôn, ngủ làm gì |
| Nhầm "tránh chờ" với "tạo lại tiến trình" | **B / C — khởi tạo…** | Khởi tạo tiến trình không giải quyết việc tranh khóa |
| Hiểu wakeup = chạy ngay | (không ứng với A–D) | Wakeup chỉ đưa về ready; scheduler quyết định khi nào chạy |

---

## Phân loại giải pháp (Software / Hardware solutions) — câu 7

**Phân loại theo slide** [C5-1 s27]

| Nhóm | Thành viên | Dấu hiệu |
|---|---|---|
| **Giải pháp phần mềm** | **Peterson · Bakery · Dekker** | Chỉ dùng kỹ thuật lập trình, không cần phần cứng đặc biệt |
| Giải pháp dựa trên phần cứng | Test & Set · Compare & Swap | Cần lệnh đơn nguyên (atomic) của CPU |

**Mẹo nhớ:** ba cái tên người (Peterson, Dekker, Bakery của Lamport) → phần mềm; tên lệnh máy → phần cứng.

**Đề mẫu** `[Đề tr2, C7]` → **A — Giải pháp phần mềm**.

**Bẫy**

| Làm sai | Ra phương án | Nhận ra vì |
|---|---|---|
| Nghĩ Peterson cần memory barrier nên là phần cứng | **C — Phần cứng** | Memory barrier là kiến thức bổ sung; nhãn phân loại của slide vẫn là phần mềm |
| Không nhớ nên chọn phương án "an toàn" | **B — Hỗn hợp** | Slide không có nhóm "hỗn hợp" |
| Nhầm với cơ chế chờ của mutex/semaphore | **D — Sleep & Wake up** | Peterson chờ bằng vòng `while` (busy waiting), không ngủ |

---

## Producer–Consumer thiếu mutex (Bounded-buffer) — câu 9

**Ba yêu cầu, ba semaphore** [C5-3 s8–s10]

```text
empty = n   ← không thêm khi ĐẦY
full  = 0   ← không lấy khi RỖNG
mutex = 1   ← bảo vệ buffer + count (critical section)
Producer: wait(empty) → wait(mutex) → thêm, count++ → signal(mutex) → signal(full)
Consumer: wait(full)  → wait(mutex) → lấy,  count-- → signal(mutex) → signal(empty)
```

**4 bước làm bài**
1. Gắn mỗi `wait` trong code với điều kiện nó kiểm soát (đầy / rỗng / CS).
2. Tìm xem có **cùng một khóa** bao quanh `count++` và `count--` không.
3. Chọn trạng thái giữa chừng để cả hai cùng qua được `wait` (`empty > 0` và `full > 0`).
4. Tách `count±±` thành đọc → tính → ghi rồi xen kẽ hai phía.

**Đề mẫu** `[Đề tr2, C9]`: code chỉ có `empty`/`full`. Buffer 10 ô đang có 5 phần tử, nên `empty = 5`, `full = 5`.

| Bước | Producer | Consumer | `count` |
|---|---|---|---:|
| 0 | | | 5 |
| 1 | đọc 5 | | 5 |
| 2 | | đọc 5 | 5 |
| 3 | tính 6, ghi | | 6 |
| 4 | | tính 4, ghi | **4** (đúng phải là 5) |

→ **D — bỏ qua critical section nên không bảo đảm mutual exclusion** ("bỏ qua vùng tranh chấp" [C5-3 s13]).

**Kiểm tra (30 giây):** đếm số `wait` mỗi phía: thiếu `wait(mutex)`/`signal(mutex)` → thiếu ME. Đổi lịch ghi (Consumer ghi trước) thì ra 6: vẫn sai.

**Bẫy**

| Làm sai | Ra phương án | Nhận ra vì |
|---|---|---|
| Không thấy `empty` chặn khi đầy | **A — vẫn thêm được khi đầy** | `empty = 0` thì `wait(empty)` chặn Producer; điều kiện đầy đã được kiểm soát |
| Tự giả định `wait` là spin | **B — có busy waiting** | Đề không cho cách cài `wait`; chọn lỗi thấy trực tiếp trong code |
| Chỉ thử buffer rỗng ban đầu (chỉ Producer chạy được) | **C — đầy đủ** | Thử trạng thái giữa chừng, cả hai đều qua `wait` → ra 4 |
| Khi sửa: `wait(mutex)` trước `wait(empty)` | (sửa sai, không ứng với A–D) | Buffer đầy: Producer giữ mutex rồi ngủ, Consumer không vào được → deadlock |

---

## Phạm vi khai báo mutex (Mutex scope) — câu 11

**Câu chữ slide** [C5-2 s13]: mutex lock **thường** được khai báo **toàn cục** và khởi tạo trong `main`.

**Cốt lõi:** mọi thread cần loại trừ nhau phải tranh **cùng một đối tượng mutex**. Mỗi thread một mutex riêng thì ai cũng lấy được khóa của mình, nên không có ME.

**Từ khóa nhận diện:** đề nói **thread trong cùng một process**. Phương án đúng phải nói về *thread* và *dùng chung*.

**Đề mẫu** `[Đề tr3, C11]` → **D — để mọi thread trong process truy cập và dùng chung mutex**.

**Bẫy**

| Làm sai | Ra phương án | Nhận ra vì |
|---|---|---|
| Gán thêm mục đích hiệu năng | **A — chia sẻ với OS để tối ưu CPU** | Global là chuyện phạm vi truy cập, không liên quan tối ưu CPU |
| Đổi "thread" thành "process con" | **B — process con dùng chung** | Biến global không tự chia sẻ giữa các process |
| Cho rằng vị trí khai báo tạo ra nhất quán | **C — chỉ global mới bảo đảm nhất quán** | Nhất quán đến từ lock/unlock đúng CS; dùng object chung truyền tham chiếu cũng được |

---

## Race condition và các thuật ngữ gần (Race condition) — câu 17

**Định nghĩa theo slide** [C5-1 s15]: *hiện tượng* xảy ra khi các tiến trình cùng truy cập đồng thời vào dữ liệu được chia sẻ; **kết quả cuối cùng phụ thuộc vào thứ tự thực thi**.

| Thuật ngữ | Loại | Trong ví dụ `count` |
|---|---|---|
| **Race condition** | **hiện tượng** | hai phía cùng đọc 5 rồi ghi đè nhau |
| Critical section | đoạn **code** | chuỗi đọc → tính → ghi `count` |
| Mutual exclusion | **thuộc tính** bảo vệ | mỗi lúc chỉ một phía chạy chuỗi đó |
| Data inconsistency | **hậu quả** | `count = 4` thay vì 5 |

**Từ khóa nhận diện:** "**hiện tượng** xảy ra khi… cùng truy cập đồng thời… dữ liệu chia sẻ" → race condition.

**Đề mẫu** `[Đề tr4, C17]` → **C — Race condition**.

**Bẫy**

| Làm sai | Ra phương án | Nhận ra vì |
|---|---|---|
| Gọi tên đoạn code thay cho hiện tượng | **A — Critical section** | CS là *chỗ* xảy ra, không phải *hiện tượng* |
| Gọi tên cách chữa | **B — Mutual exclusion** | ME là thuộc tính để *ngăn* race condition |
| Gọi tên hậu quả | **D — Data inconsistency** | Đó là kết quả *có thể* xảy ra sau race condition |

---

## Liveness — câu 23a

| Định nghĩa (đúng chữ slide [C5-2 s51]) | Điền |
|---|---|
| Một tập các đặc điểm mà hệ thống phải thỏa mãn để đảm bảo rằng các tiến trình **thực sự đang chạy** | **`Liveness`** |

Đề yêu cầu tiếng Anh, **tối đa 2 từ**, điền vào ô 23a trang 6. `[Đề tr5, C23a]`

**Thuật ngữ hay bị điền nhầm**

| Điền nhầm | Vì sao sai |
|---|---|
| `Deadlock` / `Starvation` | Đây là các **lỗi** làm mất liveness, không phải tên tập đặc điểm cần bảo đảm |
| `Progress` / `Bounded waiting` | Đây là yêu cầu của lời giải CS (câu 2), phạm vi hẹp hơn |
| `Mutual exclusion` | Thuộc **an toàn** (không cùng vào CS), không phải tiến triển |
| Viết cả câu giải thích, hoặc chỉ ghi nghĩa tiếng Việt | Vi phạm yêu cầu "tiếng Anh, tối đa 2 từ" |
