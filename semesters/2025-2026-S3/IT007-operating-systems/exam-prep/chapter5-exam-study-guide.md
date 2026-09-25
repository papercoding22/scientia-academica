# IT007 — Chương 5: Kiến thức từ đề thi mẫu và hướng dẫn từng câu

| | |
|---|---|
| Đề nguồn | [Final-Exam-Sample.pdf](Final-Exam-Sample.pdf), mã đề 01, 6 trang |
| Phạm vi | Câu **1, 2, 4, 5, 7, 9, 11, 17, 23a** — Chương 5: Process synchronization |
| Điểm trong đề này | 8 câu trắc nghiệm × 0,3 + 1 ý tự luận × 0,5 = **2,9/10 điểm** |
| Cập nhật | 2026-09-25 |
| Cách dùng | Ôn mục 2 → tự làm đề → đối chiếu đáp án và giải thích ở mục 3 → làm lại mục cuối |
| Liên quan | [Map toàn đề](exam-map.md) · [Lecture L05](../lectures/L05-process-synchronization.md) · [Ví dụ React + TypeScript](../notes/mutex-semaphore-react-typescript.md) |

> **Phạm vi nguồn:** đây là kiến thức chắt lọc từ **một đề mẫu**, đối chiếu ba bộ slide Chương 5. Trường/khoa trên đề để trống, chưa xác nhận người ra đề; PDF không kèm đáp án chính thức. Đáp án và hướng dẫn bên dưới là suy luận từ đề và slide, không phải cam kết phạm vi thi thật. Các ví dụ đời thường và TypeScript là minh họa tự dựng ngoài slide.
>
> **Cách dẫn nguồn:** `[Đề tr2, C9]` = trang 2, câu 9 của đề; `[C5-2 s16]` = slide/trang PDF thứ 16 của bộ C5-2. Tra file ở mục Nguồn.

---

## Mục lục

- [1. Đề đang kiểm tra những gì?](#1-đề-đang-kiểm-tra-những-gì)
- [2. Kiến thức chắt lọc](#2-kiến-thức-chắt-lọc)
  - [2.1. Race condition và critical section — câu 17, 9](#21-race-condition-và-critical-section--câu-17-9)
  - [2.2. Ba yêu cầu của lời giải — câu 2](#22-ba-yêu-cầu-của-lời-giải--câu-2)
  - [2.3. Semaphore — câu 1, 4](#23-semaphore--câu-1-4)
  - [2.4. Mutex: chờ thế nào và dùng chung ra sao — câu 5, 11](#24-mutex-chờ-thế-nào-và-dùng-chung-ra-sao--câu-5-11)
  - [2.5. Peterson thuộc nhóm nào — câu 7](#25-peterson-thuộc-nhóm-nào--câu-7)
  - [2.6. Bounded-buffer: ba yêu cầu độc lập — câu 9](#26-bounded-buffer-ba-yêu-cầu-độc-lập--câu-9)
  - [2.7. Liveness — câu 23a](#27-liveness--câu-23a)
- [3. Hướng dẫn từng câu trong đề](#3-hướng-dẫn-từng-câu-trong-đề)
  - [Câu 1 — Thao tác xin sử dụng tài nguyên](#câu-1--thao-tác-xin-sử-dụng-tài-nguyên)
  - [Câu 2 — Nhận diện bounded waiting](#câu-2--nhận-diện-bounded-waiting)
  - [Câu 4 — Tìm phát biểu SAI về semaphore](#câu-4--tìm-phát-biểu-sai-về-semaphore)
  - [Câu 5 — Mutex không busy waiting](#câu-5--mutex-không-busy-waiting)
  - [Câu 7 — Phân loại Peterson](#câu-7--phân-loại-peterson)
  - [Câu 9 — Producer–Consumer chỉ có empty và full](#câu-9--producerconsumer-chỉ-có-empty-và-full)
  - [Câu 11 — Tại sao mutex được khai báo toàn cục?](#câu-11--tại-sao-mutex-được-khai-báo-toàn-cục)
  - [Câu 17 — Phân biệt bốn thuật ngữ gần nhau](#câu-17--phân-biệt-bốn-thuật-ngữ-gần-nhau)
  - [Câu 23a — Điền thuật ngữ tiếng Anh](#câu-23a--điền-thuật-ngữ-tiếng-anh)
- [4. Ví dụ TypeScript để nối với công việc frontend](#4-ví-dụ-typescript-để-nối-với-công-việc-frontend)
- [5. Tự kiểm tra](#5-tự-kiểm-tra)
- [6. Nguồn](#6-nguồn)
- [7. Bạn cần tự làm lại phần nào](#7-bạn-cần-tự-làm-lại-phần-nào)

---

## 1. Đề đang kiểm tra những gì?

| Câu | Trang đề | Kiến thức cần nắm | Việc cần làm | Điểm |
|---|---:|---|---|---:|
| 1 | 1 | Ý nghĩa `wait(S)` và `signal(S)` | Nhận diện thao tác xin sử dụng tài nguyên | 0,3 |
| 2 | 1 | Mutual exclusion, progress, bounded waiting | Phân loại bốn phát biểu | 0,3 |
| 4 | 1 | Semaphore: thao tác và phân loại | Tìm phát biểu **SAI** | 0,3 |
| 5 | 2 | Mutex không busy waiting | Ghép đúng trạng thái khóa với ngủ/đánh thức | 0,3 |
| 7 | 2 | Phân loại giải pháp Peterson | Xác định nhóm giải pháp theo slide | 0,3 |
| 9 | 2 | Bounded-buffer: điều kiện và critical section | Phát hiện thiếu sót trong code Producer–Consumer | 0,3 |
| 11 | 3 | Phạm vi dùng chung của mutex | Giải thích mục đích khai báo toàn cục trong ví dụ | 0,3 |
| 17 | 4 | Race condition và các thuật ngữ liên quan | Phân biệt hiện tượng, đoạn code, thuộc tính và hậu quả | 0,3 |
| 23a | 5 | Liveness | Tự viết thuật ngữ tiếng Anh, tối đa 2 từ | 0,5 |
| **Tổng** | | **9 câu/ý** | | **2,9** |

Luồng kiến thức nên học:

```text
Truy cập dữ liệu chung có thể xen kẽ
                ↓
Race condition → xác định critical section
                ↓
Lời giải phải có mutual exclusion + progress + bounded waiting
                ↓
Peterson / mutex / semaphore
                ↓
Kết hợp điều kiện tài nguyên và bảo vệ dữ liệu trong bounded-buffer
                ↓
Kiểm tra liveness: có ai bị chờ mãi không?
```

**Điểm nối với frontend:** giới hạn số request bằng semaphore và bảo vệ một chuỗi đọc–sửa–ghi bằng mutex giải quyết hai yêu cầu riêng. Đây là cùng cách phân tích trách nhiệm mà câu 9 đòi hỏi; ví dụ upload không phải bản cài đặt bounded-buffer của đề.

## 2. Kiến thức chắt lọc

### 2.1. Race condition và critical section — câu 17, 9

**Trực giác:** hai người cùng sửa một con số có thể vô tình ghi đè kết quả của nhau.

**Analogy:** hai nhân viên cùng đọc số hàng trong sổ, mỗi người tính trên bản mình đã đọc rồi ghi lại. Người ghi sau không biết người kia vừa thay đổi sổ.

**Ví dụ nhỏ:** ban đầu `count = 5`; Producer thêm một phần tử, Consumer lấy một phần tử. Sau cả hai thao tác, số phần tử đúng phải trở về 5. Nếu cả hai cùng đọc 5, Producer ghi 6 rồi Consumer ghi 4, kết quả lại là 4. Đây là mô hình đọc–tính–ghi bị xen kẽ, không phải lời khẳng định mọi phép `++` trong mọi ngôn ngữ đều bị xen kẽ như vậy.

**Định nghĩa:** race condition (kết quả phụ thuộc thứ tự thực thi) xảy ra khi kết quả thao tác trên dữ liệu chung phụ thuộc vào cách các tác vụ chạy xen kẽ, làm mất bảo đảm đúng đắn. Slide nêu đồng thời cả yếu tố **dữ liệu chia sẻ** và **kết quả phụ thuộc thứ tự**. Critical section (vùng code cần bảo vệ) là đoạn thao tác lên dữ liệu chung cần được phối hợp. [C5-1 s15–s18]

**Code:** xem ví dụ TypeScript ở mục 4 để chủ động tạo điểm xen kẽ bằng `await`; không cần có hai lệnh JavaScript chạy song song trên main thread.

| Thuật ngữ | Nó là gì? | Nhận diện trong ví dụ |
|---|---|---|
| Race condition | Hiện tượng phụ thuộc vào cách xen kẽ | Hai tác vụ dùng cùng giá trị cũ rồi ghi đè |
| Critical section | Đoạn code cần bảo vệ | Cả chuỗi đọc → tính → ghi `count` |
| Mutual exclusion | Thuộc tính loại trừ truy cập đồng thời vào CS tương ứng | Mỗi lúc chỉ một tác vụ thực hiện chuỗi đó |
| Data inconsistency | Dữ liệu không nhất quán, có thể là hậu quả | `count = 4` trong khi số đúng phải là 5 |

**Giới hạn cần nhớ:** cùng đọc một dữ liệu bất biến không tự tạo ra race condition; các cập nhật đã được đồng bộ đúng cũng không tự trở thành lỗi chỉ vì có nhiều tác vụ.

### 2.2. Ba yêu cầu của lời giải — câu 2

**Trực giác:** một quy tắc chia lượt tốt vừa ngăn chen ngang, vừa cho công việc tiếp tục, vừa tránh để một người đợi mãi.

**Analogy:** phòng có một ghế: mỗi lần một người dùng; phòng trống thì người muốn dùng được xét vào; người đang chờ không bị người khác vượt mặt vô hạn.

**Ví dụ nhỏ:** P0, P1 và P2 cùng dùng phòng. P0 đang trong phòng thì P1/P2 chờ. P0 đi làm việc khác ngoài phòng thì không được giữ lượt làm P1/P2 kẹt. Khi P1 đã xin vào, không thể để P0/P2 thay nhau vào mãi mà P1 không có lượt.

**Định nghĩa theo slide và cách nhận diện:** [C5-1 s21–s25]

| Yêu cầu | Điều phải bảo đảm | Từ khóa trong đề |
|---|---|---|
| Mutual exclusion | Không có hai tiến trình cùng thực hiện CS tương ứng | “P đang thực thi… không có Q nào khác…” |
| Progress (tiến triển) | Một tiến trình tạm dừng ngoài CS không được cản các tiến trình khác vào CS | “bên ngoài… không được ngăn cản…” |
| Bounded waiting (chờ có giới hạn) | Tiến trình xin vào không phải chờ vô hạn; tránh starvation | “mỗi tiến trình… chờ… có hạn định…” |

**Làm rõ ngoài câu chữ slide:** bounded waiting thường được phát biểu chặt bằng một giới hạn hữu hạn về **số lần tiến trình khác được vào CS** sau khi một tiến trình đã yêu cầu và trước khi nó được vào. Đừng tự đổi thành cam kết chính xác bao nhiêu mili giây nếu chưa có giả thiết về scheduler và thời gian thực thi.

“Phải từ bỏ CPU khi chưa vào được” nói về **cách chờ**, không phải tên một trong ba yêu cầu. Có thể chờ bằng spin hoặc block; vẫn phải đánh giá đủ ba yêu cầu trên.

### 2.3. Semaphore — câu 1, 4

**Trực giác:** có bao nhiêu suất thì cho bấy nhiêu việc đi tiếp; hết suất thì đợi.

**Analogy:** bãi xe phát hai thẻ. Xe vào lấy một thẻ; xe ra trả một thẻ. Không còn thẻ thì xe mới phải chờ.

**Ví dụ nhỏ:** semaphore khởi tạo `S = 2`. A lấy suất → còn 1; B lấy suất → còn 0; C yêu cầu → chờ. Một suất được trả thì C mới có thể nhận suất để tiếp tục. Đây là cách đếm **suất khả dụng**, không mô tả mọi chi tiết biến nội bộ của mọi cách cài semaphore.

**Định nghĩa:** semaphore là công cụ đồng bộ dựa trên biến nguyên, truy cập qua hai thao tác atomic (nguyên tử) `wait`/`signal`, còn gọi `P`/`V`. [C5-2 s15–s16]

| Thao tác/loại | Ý nghĩa | Điểm dễ nhầm |
|---|---|---|
| `wait(S)` | Xin sử dụng một suất; phải chờ nếu chưa có; khi lấy được thì tiêu thụ một suất | Tên “wait” không có nghĩa lần gọi nào cũng phải ngủ |
| `signal(S)` | Trả hoặc bổ sung một suất/tín hiệu | Trong mô hình tài nguyên của câu 1 là trả tài nguyên |
| Counting semaphore | Quản lý nhiều suất, ví dụ 2 upload đồng thời | Nhiều tác vụ được vào nên chưa bảo đảm độc quyền |
| Binary semaphore | Mô hình chỉ có 0/1, có thể dùng cho mutual exclusion | Có tác dụng tương tự mutex không có nghĩa mọi ngữ nghĩa đều giống mutex |

Phân loại theo [C5-2 s26]. Với mô hình không âm trên slide s16, `wait` đợi khi `S <= 0`, rồi giảm `S`; `signal` tăng `S`. **Không có cách hiểu nào trong mô hình này mà `wait` là thao tác tăng thêm suất.**

**Chú thích API:** đề viết `sem_wait()` trong câu 4, còn slide viết `wait(S)`. Khi làm câu này, đối chiếu **ý nghĩa xin suất**; không chép pseudocode của slide thành cài đặt POSIX thực tế. Các primitive phải bảo đảm atomic, không thể thay bằng một phép kiểm tra rồi trừ trên biến thường.

**Code liên hệ:** trong [ví dụ React + TypeScript](../notes/mutex-semaphore-react-typescript.md), `new Semaphore(2)` tạo hai suất; `slots.runExclusive(() => uploadFile(file))` lấy suất trước khi chạy callback và tự trả khi Promise của callback settle. Đây là API thư viện, không phải tên hàm trong đề.

### 2.4. Mutex: chờ thế nào và dùng chung ra sao — câu 5, 11

**Trực giác:** mọi người phải dùng chung một chìa khóa mới kiểm soát được ai đang sửa tài liệu.

**Analogy:** A giữ chìa khóa phòng hồ sơ thì B chờ. B có thể liên tục thử mở cửa, hoặc ngồi chờ được gọi; hai cách này có chi phí khác nhau. Nếu A và B mỗi người giữ một khóa riêng cho cùng cuốn sổ thì quy tắc không còn phối hợp được họ.

**Ví dụ nhỏ:** A lấy mutex M để sửa lịch sử. B cũng xin M, nên phải chờ A trả. Nếu B xin mutex N độc lập thì B vẫn vào được, dù A đang giữ M.

**Định nghĩa:** mutex bảo vệ quyền truy cập độc quyền vào CS, với thao tác lấy/trả khóa. Spinlock chờ bằng vòng lặp kiểm tra; mutex không busy waiting (chờ bận) cho tác vụ chờ bị block và được đánh thức sau. [C5-2 s7–s10]

```text
Khóa đang bị giữ → tác vụ xin khóa bị block → vào hàng đợi chờ
Người giữ trả khóa → wakeup một tác vụ chờ → ready → chờ scheduler cấp CPU
```

**Được đánh thức không có nghĩa lập tức chạy** hoặc tự động được vào CS bất chấp cơ chế lấy khóa. Slide s10 nói rõ `wakeup` đưa tiến trình về hàng đợi sẵn sàng.

Slide s13 nói mutex **thường** được khai báo toàn cục. Điều kiện cốt lõi là mọi thread cần phối hợp đều truy cập **cùng một đối tượng mutex**, và đối tượng còn tồn tại trong thời gian dùng. Khai báo global là một cách; dùng một object chung rồi truyền tham chiếu cũng được. Chia sẻ cho các thread trong một process khác với tự động chia sẻ cho các process con. [C5-2 s13; phần diễn giải phạm vi là bổ sung kỹ thuật]

**Code:** `const mutex = new Mutex()` nằm ngoài hàm `change()` trong mục 4, nên hai lần gọi dùng cùng khóa. Với React, xem cách giữ service bằng `useState(createDemo)` trong ghi chú liên kết; mutex của thư viện async không block cả thread trình duyệt như mô hình mutex OS.

| Câu hỏi | Điểm quyết định |
|---|---|
| Tránh tốn CPU do liên tục kiểm tra khóa? | Block khi chưa lấy được khóa, wakeup khi có thể thử tiếp |
| Vì sao nhiều thread cần thấy mutex? | Để cùng tuân theo một khóa cho dữ liệu chung |
| Có mutex nhưng mỗi tác vụ tạo một instance? | Không có mutual exclusion giữa các instance độc lập |

### 2.5. Peterson thuộc nhóm nào — câu 7

**Trực giác:** hai người có thể tự thỏa thuận lượt đi bằng một bộ quy tắc chung.

**Analogy:** trước cửa hẹp, mỗi người báo mình muốn qua; khi cả hai cùng muốn thì áp dụng quy tắc nhường lượt.

**Ví dụ nhỏ:** hai tiến trình P0/P1 dùng thông tin về ý định vào CS và lượt ưu tiên để phối hợp. Câu 7 chỉ yêu cầu nhận diện nhóm giải pháp, không yêu cầu chạy tay toàn bộ thuật toán.

**Phân loại hình thức theo slide:** Peterson, Bakery, Dekker nằm ở nhóm **giải pháp phần mềm**; `test_and_set` và `compare_and_swap` là các ví dụ dựa trên hỗ trợ lệnh atomic của phần cứng. [C5-1 s27]

| Nhóm | Dấu hiệu khi nhận diện |
|---|---|
| Giải pháp phần mềm | Dùng thuật toán phối hợp như Peterson |
| Giải pháp phần cứng | Dựa trên primitive đặc biệt như Test & Set, Compare & Swap |
| Sleep & Wake up | Mô tả cơ chế ngủ/đánh thức khi chờ |

**Giới hạn:** “phần mềm” là nhãn phân loại trong mô hình bài học; không suy thành thuật toán bỏ qua mọi giả thiết về thao tác đọc/ghi và thứ tự bộ nhớ. Phần triển khai Peterson trên kiến trúc hiện đại được giải thích riêng trong [L05](../lectures/L05-process-synchronization.md).

### 2.6. Bounded-buffer: ba yêu cầu độc lập — câu 9

**Trực giác:** biết còn chỗ hay còn hàng chưa đủ; người thêm và người lấy còn phải cập nhật sổ cho đúng.

**Analogy:** kệ có 10 ô. Thẻ “ô trống” kiểm soát việc đặt hàng; thẻ “hàng có sẵn” kiểm soát việc lấy hàng; chìa khóa sổ kho bảo vệ việc ghi số lượng.

**Ví dụ nhỏ:** sau một số lần sản xuất, buffer có 5/10 phần tử. Producer có thể lấy một suất `empty`, Consumer có thể lấy một suất `full`; cả hai đều đủ điều kiện đi tiếp. Nếu không bảo vệ `count`, cả hai có thể đọc 5 rồi lần lượt ghi 6 và 4. Chỉ kiểm soát đầy/rỗng chưa ngăn được lịch xen kẽ này.

**Mô hình theo slide:** bounded-buffer là buffer hữu hạn, được Producer thêm và Consumer lấy. Khi buffer ban đầu rỗng, lời giải mẫu dùng ba semaphore sau. Trong đó biến mang tên `mutex` là **semaphore khởi tạo 1**, dùng cho mutual exclusion. [C5-3 s5–s10]

| Yêu cầu | Công cụ | Khởi tạo khi buffer rỗng |
|---|---|---:|
| Không thêm khi đầy | `empty` — số suất có thể thêm | `n` |
| Không lấy khi rỗng | `full` — số suất có thể lấy | `0` |
| Không làm hỏng buffer và `count` | `mutex` — bảo vệ CS chung | `1` |

Luồng chuẩn để đối chiếu trách nhiệm, theo [C5-3 s10]:

```text
Producer: wait(empty) → wait(mutex) → thêm + count++ → signal(mutex) → signal(full)
Consumer: wait(full)  → wait(mutex) → lấy  + count-- → signal(mutex) → signal(empty)
```

**Vì sao thứ tự này tồn tại?** Chờ tài nguyên trước khi lấy khóa bảo vệ dữ liệu. Ví dụ buffer đầy mà Producer giữ mutex rồi mới chờ `empty`, Consumer có thể không lấy được mutex để lấy hàng và trả suất trống. Đây là suy luận từ luồng đồng bộ; không tự đảo thứ tự khi sửa bài.

`count++`/`count--` được xét như chuỗi đọc–tính–ghi trong mô hình của bài học. Không khẳng định một chương trình C/C++ có data race thực tế chỉ có vài kết quả số đơn giản như mô hình đó.

**Code liên hệ:** mục 4 minh họa lỗi mất cập nhật và cùng dùng một mutex. Đây là phần bảo vệ dữ liệu; chưa phải chương trình bounded-buffer đầy đủ.

### 2.7. Liveness — câu 23a

**Trực giác:** chương trình phải làm được việc, chứ không chỉ tránh làm sai.

**Analogy:** quy định “không ai được vào phòng bao giờ” tránh hai người cùng vào, nhưng mọi công việc đều bị bỏ dở.

**Ví dụ nhỏ:** P0 giữ khóa X và chờ Y; P1 giữ Y và chờ X. Không ai chạy qua đoạn chờ để trả khóa. Hoặc P2 chờ mãi trong khi người khác liên tục được chọn trước.

**Định nghĩa:** liveness (khả năng tiếp tục tiến triển) là tập các đặc điểm hệ thống phải thỏa mãn để bảo đảm tiến trình thực sự chạy; chờ vô hạn khi xin công cụ đồng bộ là dấu hiệu thất bại. [C5-2 s51–s52]

| Khái niệm | Cần phân biệt |
|---|---|
| Mutual exclusion | Không cùng vào CS; thuộc về bảo đảm an toàn |
| Liveness | Công việc có thể tiếp tục tiến triển theo các bảo đảm của hệ thống |
| Deadlock | Các tiến trình chờ nhau và không thể tự thoát khỏi vòng chờ đó |
| Starvation | Một tiến trình bị chờ vô hạn dù các tiến trình khác vẫn tiến triển |

Deadlock và starvation được minh họa ở [C5-2 s53]. Đừng hiểu liveness là “mọi tiến trình luôn luôn ở trạng thái running”; chờ hữu hạn một sự kiện bình thường không tự chứng minh có lỗi liveness.

## 3. Đáp án và hướng dẫn từng câu trong đề

Các phương án dưới đây được **rút gọn** để tập trung vào logic, giữ nguyên nhãn A/B/C/D. Mở PDF theo trang ghi ở mỗi câu để đọc nguyên văn. Mỗi câu có **đáp án suy luận kèm giải thích** ngay bên dưới đề/phương án; cuối file giữ bảng để tự ghi lựa chọn khi luyện lại.

### Câu 1 — Thao tác xin sử dụng tài nguyên

**Đề hỏi:** với semaphore S, thao tác nào có ý nghĩa sử dụng tài nguyên? `[Đề tr1, C1]`

| A | B | C | D |
|---|---|---|---|
| `signal(S)` | `wait(S)` | `return(S)` | `allocate(S)` |

**Đáp án (suy luận): B — `wait(S)`.**

**Giải thích:** `wait(S)` xin một suất tài nguyên; khi lấy được suất thì số suất khả dụng giảm 1. `signal(S)` trả/bổ sung suất; `return` và `allocate` không phải cặp primitive của semaphore trong slide. [C5-2 s15–s16]

**Cách làm:**

1. Gạch chân “sử dụng tài nguyên”: tiến trình đang **xin một suất**, chưa phải trả suất.
2. Nhớ đúng cặp primitive của semaphore trong slide; không chọn chỉ vì tên tiếng Anh nghe giống “cấp phát”.
3. Tự mô phỏng `S = 1`: sau khi một tiến trình lấy được suất, còn bao nhiêu suất cho tiến trình tiếp theo? Ghép thao tác phù hợp với hướng thay đổi đó.

**Bẫy:** `wait` có thể trả về ngay nếu có suất; không cần chứng minh tác vụ thực sự ngủ mới gọi đó là `wait`.

**Ôn lại:** mục 2.3; [C5-2 s15–s16].

### Câu 2 — Nhận diện bounded waiting

**Bốn phát biểu trong đề:** `[Đề tr1, C2]`

1. P trong CS thì không có Q khác đồng thời trong CS tương ứng.
2. Tiến trình chưa vào CS phải từ bỏ CPU.
3. Tiến trình tạm dừng ngoài CS không cản tiến trình khác vào.
4. Mỗi tiến trình chỉ chờ để vào CS trong một khoảng có hạn định.

Phương án: **A = (1), B = (2), C = (3), D = (4)**.

**Đáp án (suy luận): D — Phát biểu (4), bounded waiting.**

**Giải thích:** (4) giới hạn việc chờ của từng tiến trình. (1) là mutual exclusion; (3) là progress; (2) mô tả cách chờ bằng nhường CPU, không phải định nghĩa bounded waiting. [C5-1 s21, s25]

**Cách làm:**

1. Viết ba câu hỏi cạnh giấy: “có cùng vào không?”, “CS trống có bị cản không?”, “có ai chờ mãi không?”.
2. Ghép từng phát biểu với câu hỏi tương ứng; phát biểu về nhường CPU thuộc cách cài đặt việc chờ.
3. Chọn phát biểu nói về **giới hạn chờ của từng tiến trình**, rồi chuyển số phát biểu sang nhãn phương án.

**Bẫy:** progress không tự bảo đảm mọi người đều được phục vụ; hệ thống có thể cho người khác tiến lên mà một người vẫn bị bỏ lại. Đề cũng không hỏi thời gian chờ cụ thể bằng mili giây.

**Ôn lại:** mục 2.2; [C5-1 s21–s25].

### Câu 4 — Tìm phát biểu SAI về semaphore

**Các phương án:** `[Đề tr1, C4]`

| Phương án | Phát biểu rút gọn |
|---|---|
| A | Semaphore có thể đồng bộ process hoặc thread |
| B | Binary semaphore nhận 0/1, thường dùng như mutex |
| C | `sem_wait()` luôn tăng giá trị semaphore lên 1 |
| D | Counting semaphore giới hạn số process truy cập đồng thời tài nguyên |

**Đáp án (suy luận): C — “`sem_wait()` luôn tăng giá trị semaphore lên 1” là phát biểu SAI.**

**Giải thích:** Thao tác xin suất tiêu thụ một suất khi thành công; thao tác trả/bổ sung suất mới làm tăng giá trị. A, B và D phù hợp ý nghĩa đồng bộ và phân loại semaphore trong mô hình đề. [C5-2 s15–s16, s26]

**Cách làm:**

1. Khoanh chữ **SAI** trước khi đọc đáp án.
2. Kiểm tra A theo đối tượng có thể được đồng bộ; B theo binary semaphore; D bằng ví dụ hai suất upload.
3. Với C, dùng lại phép thử `S = 1` của câu 1: thao tác xin sử dụng đang tiêu thụ hay bổ sung một suất?
4. Tự lập bảng đúng/sai bốn dòng, rồi chọn phát biểu trái định nghĩa.

**Bẫy:** đừng đánh sai B chỉ vì biết mutex OS có ownership. Đề viết “thường được dùng như mutex”, tức có thể dùng cho mutual exclusion; không khẳng định hai công cụ giống mọi chi tiết.

**Ôn lại:** mục 2.3; [C5-2 s15–s16, s26].

### Câu 5 — Mutex không busy waiting

**Đề hỏi:** làm gì với tiến trình để tránh busy waiting? `[Đề tr2, C5]`

| Phương án | Quan hệ khóa và hành động |
|---|---|
| A | Ngủ khi khóa mở; đánh thức khi khóa bị giữ |
| B | Thực thi khi khóa mở; khởi tạo khi khóa bị giữ |
| C | Khởi tạo khi khóa mở; thực thi khi khóa bị giữ |
| D | Ngủ khi khóa bị giữ; đánh thức khi khóa mở |

**Đáp án (suy luận): D — Ngủ khi khóa bị giữ; đánh thức khi khóa mở.**

**Giải thích:** Tiến trình chưa lấy được khóa được block để không lặp kiểm tra và tiêu tốn CPU. Khi khóa được trả, wakeup đưa tiến trình chờ về hàng đợi ready; scheduler quyết định khi nào nó chạy. A đảo ngược điều kiện; B/C nói về khởi tạo nên không giải quyết việc chờ khóa. [C5-2 s10]

**Cách làm:**

1. Xác định tiến trình đang xét là **người xin khóa nhưng chưa lấy được**, không phải người đang giữ khóa.
2. Nếu chưa thể vào CS, tiếp tục kiểm tra khóa có tiêu tốn CPU không? Muốn tránh cách đó thì tiến trình phải chuyển sang trạng thái nào?
3. Khi khóa được trả, hành động nào giúp tiến trình chờ trở lại hàng đợi ready?
4. Ghép đủ hai vế trước khi chọn; các phương án có thể đúng một từ nhưng đảo ngược điều kiện.

**Bẫy:** khởi tạo tiến trình không phải giải pháp cho mỗi lần tranh khóa. Wakeup đưa về ready, không bảo đảm được CPU tức thì.

**Ôn lại:** mục 2.4; [C5-2 s8–s10].

### Câu 7 — Phân loại Peterson

**Đề hỏi:** giải pháp đồng bộ Peterson thuộc nhóm nào? `[Đề tr2, C7]`

| A | B | C | D |
|---|---|---|---|
| Phần mềm | Hỗn hợp | Phần cứng | Sleep & Wake up |

**Đáp án (suy luận): A — Giải pháp phần mềm.**

**Giải thích:** Slide xếp Peterson cùng Bakery và Dekker vào nhóm giải pháp phần mềm; Test & Set và Compare & Swap thuộc nhóm dựa trên phần cứng. Đây là phân loại thuật toán trong giáo trình, với các giả thiết về thao tác bộ nhớ của mô hình. [C5-1 s27]

**Cách làm:**

1. Tra tiêu chí phân loại của câu: cơ chế của thuật toán theo bảng 5.3.2, không phải ngôn ngữ dùng để viết chương trình.
2. Nhớ bộ ba Peterson–Bakery–Dekker thuộc cùng một nhóm trong slide.
3. Đối chiếu với nhóm có Test & Set/Compare & Swap; không đánh đồng thuật toán nhường lượt với cơ chế block/wakeup.

**Bẫy:** kiến thức bổ sung về memory ordering trên CPU hiện đại không làm thay đổi nhãn mà câu phân loại này đang hỏi.

**Ôn lại:** mục 2.5; [C5-1 s27].

### Câu 9 — Producer–Consumer chỉ có empty và full

**Dữ kiện:** `empty = kích thước buffer`, `full = 0`; code trong hình đề được chép lại dưới đây. `[Đề tr2, C9]`

```c
// Producer                  // Consumer
wait(empty);                 wait(full);
// add to buffer[]           // remove from buffer[]
count++;                     count--;
signal(full);                signal(empty);
```

| Phương án | Nhận xét rút gọn |
|---|---|
| A | Producer vẫn có thể thêm khi buffer đã đầy |
| B | Busy waiting vẫn có thể xuất hiện |
| C | Lời giải đáp ứng đầy đủ yêu cầu |
| D | Bỏ qua CS nên không bảo đảm mutual exclusion |

**Đáp án (suy luận): D — Bỏ qua critical section nên không bảo đảm mutual exclusion.**

**Giải thích:** `empty` và `full` kiểm soát chỗ trống/phần tử có sẵn, nhưng không ngăn hai phía đồng thời cập nhật `count`. Với `empty = full = 5`, cả hai đều có thể qua `wait`; lịch bên dưới cho kết quả 4 thay vì 5. Đây đúng lỗi “Bỏ qua vùng tranh chấp” ở slide. B phụ thuộc cách hiện thực semaphore, còn thiếu bảo vệ CS là lỗi thấy trực tiếp trong code, nên D là lựa chọn phù hợp nhất. [C5-3 s8–s9, s13]

**Cách làm:**

1. Liệt kê ba yêu cầu riêng: tránh thêm lúc đầy, tránh lấy lúc rỗng, bảo vệ dữ liệu chung.
2. Gạch dưới `wait(empty)` và `wait(full)`, ghi bên cạnh mỗi dòng nó đang kiểm soát điều kiện nào.
3. Khoanh hai thao tác trên `count`. Tìm xem có cùng một khóa nào bao quanh cả vùng cập nhật buffer/`count` của hai phía không.
4. Thử một trạng thái **sau khi đã sản xuất một số phần tử**, không chỉ nhìn buffer rỗng ban đầu: buffer có 5/10 phần tử, `empty = 5`, `full = 5`. Cả hai lời gọi `wait` đều có thể đi tiếp.
5. Tách cập nhật thành đọc–tính–ghi và chạy lịch sau:

| Bước | Producer | Consumer | `count` trong bộ nhớ |
|---|---|---|---:|
| 0 | | | 5 |
| 1 | Đọc 5 vào biến tạm P | | 5 |
| 2 | | Đọc 5 vào biến tạm C | 5 |
| 3 | Tính P = 6, ghi 6 | | 6 |
| 4 | | Tính C = 4, ghi 4 | 4 |

Sau một lần thêm và một lần lấy, giá trị đúng phải là 5. Dùng phản ví dụ này để xét lời khẳng định “đáp ứng đầy đủ”, rồi chọn phương án mô tả **lỗi có bằng chứng trực tiếp từ code**.

**Bẫy của B:** đề không cho cách hiện thực `wait`. Nếu semaphore dùng spin thì có thể busy waiting; nếu dùng block/wakeup thì không chờ theo cách đó. Vì đề yêu cầu **một đáp án đúng nhất**, cần ưu tiên thiếu sót nhìn thấy được ở CS, không tự thêm giả thiết về cài đặt semaphore. [C5-2 s15–s16; C5-3 s11–s13]

**Tự hoàn thiện sau khi chọn:** dựa vào luồng ở mục 2.6, đánh dấu vị trí cần lấy/trả cùng một khóa trên cả hai phía và giải thích vì sao phải chờ `empty`/`full` trước khi giữ khóa đó.

**Ôn lại:** mục 2.6; [C5-3 s8–s10, s13].

### Câu 11 — Tại sao mutex được khai báo toàn cục?

**Đề hỏi:** khi đồng bộ các thread trong một process, vì sao khai báo mutex toàn cục? `[Đề tr3, C11]`

| Phương án | Mục đích được nêu |
|---|---|
| A | Chia sẻ mutex với OS để tối ưu CPU |
| B | Để mọi process con dùng chung mutex |
| C | Chỉ biến global mới bảo đảm dữ liệu nhất quán |
| D | Để mọi thread trong process truy cập và dùng chung mutex |

**Đáp án (suy luận): D — Để mọi thread trong process truy cập và dùng chung mutex.**

**Giải thích:** Các thread phải tranh cùng một đối tượng khóa để loại trừ nhau. Khai báo global là cách chia sẻ trong ví dụ của slide; vị trí khai báo tự nó không bảo đảm dữ liệu nhất quán và không làm mutex tự được chia sẻ giữa mọi process con. [C5-2 s13]

**Cách làm:**

1. Khoanh đúng đối tượng trong đề: **thread trong cùng một process**.
2. Vẽ hai sơ đồ nhỏ: A/B xin cùng M; A xin M1 còn B xin M2. Chỉ ra sơ đồ nào thực sự ngăn cả hai cùng vào CS.
3. Từ đó xác định mục đích của phạm vi global trong ví dụ: khả năng truy cập cùng đối tượng, hay vị trí khai báo tự nó làm dữ liệu nhất quán?
4. Kiểm tra phương án có đổi “thread” thành “process con” hoặc đưa thêm mục đích tối ưu CPU không được đề nêu hay không.

**Bẫy:** từ “phải” trong câu hỏi không nên được ghi nhớ thành luật mọi chương trình đều phải dùng global mutex. Slide nói **thường** khai báo toàn cục; ứng dụng thực tế có thể chia sẻ mutex qua object/tham chiếu chung.

**Liên hệ frontend:** `createUploader()` tạo `historyMutex` một lần trong closure; mọi lần gọi hàm upload trả về cùng dùng đối tượng đó. Đây là ví dụ dùng chung khóa mà không cần biến global.

**Ôn lại:** mục 2.4; [C5-2 s13] và [ghi chú React + TypeScript](../notes/mutex-semaphore-react-typescript.md).

### Câu 17 — Phân biệt bốn thuật ngữ gần nhau

**Đề hỏi:** “Hiện tượng xảy ra khi các tiến trình cùng truy cập đồng thời vào dữ liệu được chia sẻ được gọi là gì?” `[Đề tr4, C17]`

| A | B | C | D |
|---|---|---|---|
| Critical section | Mutual exclusion | Race condition | Data inconsistency |

**Đáp án (suy luận): C — Race condition.**

**Giải thích:** Theo định nghĩa đầy đủ của slide, các tiến trình truy cập dữ liệu chia sẻ và kết quả phụ thuộc thứ tự thực thi. Critical section là đoạn code cần bảo vệ, mutual exclusion là thuộc tính bảo vệ, data inconsistency là hậu quả có thể xảy ra. Vì câu hỏi rút gọn, cần giữ điều kiện phụ thuộc thứ tự khi giải thích. [C5-1 s15]

**Cách làm:**

1. Gạch chân **hiện tượng**, **đồng thời**, **dữ liệu chia sẻ**.
2. Gán từng thuật ngữ vào một loại: đoạn code; thuộc tính bảo vệ; hiện tượng phụ thuộc xen kẽ; hậu quả dữ liệu sai.
3. Đối chiếu với định nghĩa đầy đủ ở slide s15, gồm cả câu “kết quả cuối cùng phụ thuộc vào thứ tự thực thi”. Dùng đúng ngữ cảnh đó để chọn.

**Bẫy:** câu hỏi rút ngắn định nghĩa. Khi tự giải thích lại, phải bổ sung yếu tố phụ thuộc thứ tự/xen kẽ; chỉ nói “nhiều người cùng truy cập” là quá rộng. Dữ liệu không nhất quán là hậu quả có thể xảy ra, không phải tên mọi tình huống truy cập dữ liệu chung.

**Ôn lại:** bảng ở mục 2.1; [C5-1 s15–s18].

### Câu 23a — Điền thuật ngữ tiếng Anh

**Đề hỏi:** thuật ngữ chỉ “một tập các đặc điểm mà hệ thống phải thỏa mãn để bảo đảm tiến trình thực sự chạy”. Trả lời bằng tiếng Anh, **tối đa 2 từ**. `[Đề tr5, C23a]`

**Đáp án (suy luận): `Liveness`.**

**Giải thích:** Đây là thuật ngữ khớp mô tả “tập các đặc điểm ... bảo đảm tiến trình thực sự chạy” trong slide. Deadlock và starvation là các tình trạng làm liveness thất bại, không phải tên thuộc tính cần điền. Ghi một từ tiếng Anh: `Liveness`. [C5-2 s51–s52]

**Cách làm:**

1. Xác định câu hỏi nói về bảo đảm hệ thống **tiếp tục tiến triển**, không nói về số tiến trình cùng ở CS.
2. Đối chiếu với tên khái niệm bao quát ở Appendix A của C5-2; phân biệt khái niệm đó với từng tình trạng lỗi như deadlock hoặc starvation.
3. Tự viết thuật ngữ từ trí nhớ, rồi mới mở slide kiểm tra chính tả.
4. Chỉ điền thuật ngữ vào ô **23a** của bảng trả lời trang 6; các ý 23b–d thuộc chương khác.

**Bẫy:** nhớ nghĩa tiếng Việt nhưng không viết được từ tiếng Anh; điền cả một câu giải thích vượt yêu cầu tối đa 2 từ; điền tên một lỗi thay cho thuộc tính cần bảo đảm.

**Ôn lại:** mục 2.7; [C5-2 s51–s52].

## 4. Ví dụ TypeScript để nối với công việc frontend

Ví dụ tự dựng này tách thao tác cập nhật thành hai phần qua `await` để thấy race condition giữa **async task**. Nó không phải cài đặt mutex kernel, không dùng React state và không mô phỏng đầy đủ bounded-buffer.

Trong một dự án TypeScript thử nghiệm, cài `async-mutex@0.5.0` và `tsx`; lưu đoạn sau thành `race-demo.ts`, chạy `npx tsx race-demo.ts`:

```ts
import { Mutex } from "async-mutex";

async function demo(useMutex: boolean): Promise<number> {
  let count = 5;
  const mutex = new Mutex(); // Cùng một khóa cho cả hai lời gọi change.

  async function change(delta: number): Promise<void> {
    const update = async () => {
      const snapshot = count;
      await Promise.resolve(); // Cho tác vụ khác có cơ hội đọc cùng giá trị.
      count = snapshot + delta;
    };

    if (useMutex) await mutex.runExclusive(update);
    else await update();
  }

  await Promise.all([change(1), change(-1)]);
  return count;
}

async function main() {
  console.log("Không mutex:", await demo(false));
  console.log("Có mutex dùng chung:", await demo(true));
}

void main().catch(console.error);
```

Kết quả của lịch microtask trong ví dụ này:

```text
Không mutex: 4
Có mutex dùng chung: 5
```

Đã trích nguyên văn đoạn code để kiểm tra TypeScript strict và chạy bằng `tsx`; kết quả thực tế khớp hai dòng trên. Đây là kiểm chứng ví dụ async task, không phải kiểm chứng một cài đặt đồng bộ ở mức hệ điều hành.

| Chi tiết trong code | Kiến thức được minh họa |
|---|---|
| Đọc `snapshot` trước điểm `await` | Hai tác vụ có thể dựa trên cùng dữ liệu cũ |
| `new Mutex()` nằm ngoài `change` | Hai tác vụ dùng chung một khóa — ý chính của câu 11 |
| Cả đọc và ghi trong `runExclusive` | Bảo vệ đúng phạm vi CS — ý chính của câu 9 |
| Chờ Promise | Event loop vẫn chạy tác vụ khác; không đánh đồng với block OS thread của câu 5 |

Nếu chỉ cần tăng React state, functional updater như `setCount(previous => previous + 1)` xử lý cập nhật trên state trước trong hàng đợi React. Nó không tự bảo vệ một store bất đồng bộ bên ngoài React. Xem [ví dụ upload kết hợp semaphore và mutex](../notes/mutex-semaphore-react-typescript.md) để nối hai trường hợp.

## 5. Tự kiểm tra

**1.** Một chương trình luôn cấm mọi tác vụ vào CS có thỏa mutual exclusion không? Vì sao vẫn là lời giải không dùng được?

<details><summary>Đáp án và giải thích</summary>

Nó tránh hai tác vụ cùng vào nên thỏa riêng mutual exclusion, nhưng không cho công việc tiến triển. Khi có yêu cầu hợp lệ mà không ai được vào, lời giải không bảo đảm progress/liveness.

</details>

**2.** Semaphore khởi tạo 2, hai tác vụ đã lấy hết suất. Tác vụ thứ ba gọi xin suất thì sao? Ai có thể giúp nó đi tiếp?

<details><summary>Đáp án và giải thích</summary>

Tác vụ thứ ba chờ. Một suất được trả/bổ sung bởi thao tác signal phù hợp cho phép tác vụ chờ có thể lấy suất. Cách chờ là spin hay block phụ thuộc hiện thực semaphore.

</details>

**3.** Bị đánh thức sau khi chờ mutex có đồng nghĩa chạy ngay trên CPU không?

<details><summary>Đáp án và giải thích</summary>

Không. Theo mô hình slide, wakeup đưa tác vụ về hàng đợi ready; scheduler quyết định khi nào nó chạy. Cơ chế khóa quyết định khi nào nó được vào CS.

</details>

**4.** Hai hàm cùng sửa một store, mỗi hàm tự tạo một mutex. Vì sao vẫn sai?

<details><summary>Đáp án và giải thích</summary>

Hai khóa độc lập không loại trừ nhau. Phải dùng chung cùng đối tượng mutex và bảo vệ đủ chuỗi thao tác liên quan; chỉ khóa bước ghi vẫn có thể giữ lại snapshot cũ.

</details>

**5.** Trong bounded-buffer, vì sao không dùng riêng `empty` và `full` để bảo vệ `count`?

<details><summary>Đáp án và giải thích</summary>

Hai semaphore quản lý hai loại suất. Khi buffer vừa có hàng vừa còn chỗ trống, Producer và Consumer đều có thể đi tiếp. Cần thêm bảo vệ CS chung để chuỗi cập nhật buffer/`count` không bị xen kẽ sai.

</details>

## 6. Nguồn

| Mã | Tài liệu | Các vị trí đã đối chiếu |
|---|---|---|
| Đề | [Final-Exam-Sample.pdf](Final-Exam-Sample.pdf) | Trang 1–5 chứa câu hỏi; trang 6 chứa bảng trả lời |
| C5-1 | [Copy of #Week07-Chapter5-1 2024.pdf](../materials/slides/Copy%20of%20%23Week07-Chapter5-1%202024.pdf) | s15–s18: race condition và CS; s21–s25: ba yêu cầu; s27: phân loại Peterson |
| C5-2 | [Copy of #Week09-Chapter5-2 2024.pdf](../materials/slides/Copy%20of%20%23Week09-Chapter5-2%202024.pdf) | s7–s10, s13: mutex; s15–s16, s26: semaphore; s51–s53: liveness |
| C5-3 | [Copy of #Week10-Chapter5-3 2024.pdf](../materials/slides/Copy%20of%20%23Week10-Chapter5-3%202024.pdf) | s5–s10: bounded-buffer; s11–s13: lỗi, đặc biệt bỏ qua CS |
| L05 | [Lecture L05 — Process synchronization](../lectures/L05-process-synchronization.md) | Giải thích đầy đủ, code và bài tập mở rộng |
| FE | [Mutex và semaphore qua React + TypeScript](../notes/mutex-semaphore-react-typescript.md) | API `async-mutex`, functional updater và giới hạn so với đồng bộ OS |

**Phần tự dựng:** analogy, các bảng hướng dẫn, lịch xen kẽ số cụ thể, code TypeScript và câu hỏi tự kiểm tra. Các nhận xét về global mutex, câu chữ rút gọn của race condition và bẫy busy waiting là phân tích kỹ thuật khi đối chiếu đề, không phải đáp án do giảng viên ban hành.

## 7. Bạn cần tự làm lại phần nào

1. Đóng ghi chú và làm lại đúng 9 câu/ý trong PDF; với mỗi câu trắc nghiệm, ghi thêm một câu giải thích vì sao chọn.
2. Với câu 2, phân loại đủ bốn phát biểu trước khi nhìn nhãn A/B/C/D.
3. Với câu 9, tự vẽ lịch đọc–tính–ghi khác vẫn gây sai `count`, rồi bổ sung các thao tác bảo vệ CS trên cả Producer và Consumer.
4. Với câu 11, giải thích bằng ví dụ closure TypeScript vì sao “cùng một mutex” quan trọng hơn “biến global”.
5. Với câu 23a, tự viết thuật ngữ tiếng Anh rồi kiểm tra chính tả ở slide.

| Câu | Lựa chọn/thuật ngữ của tôi | Tôi giải thích được vì sao? |
|---|---|---|
| 1 | | ☐ |
| 2 | | ☐ |
| 4 | | ☐ |
| 5 | | ☐ |
| 7 | | ☐ |
| 9 | | ☐ |
| 11 | | ☐ |
| 17 | | ☐ |
| 23a | | ☐ |
