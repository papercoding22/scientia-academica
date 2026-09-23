# L3 — Quản lý tiến trình (Process Management)

| | |
|---|---|
| Môn | `IT007` Hệ điều hành |
| Buổi | 3 |
| Ngày | TBD *(người dùng sẽ cập nhật sau)* |
| Giảng viên | Nguyễn Thanh Thiện |
| Transcript | ❌ Không có. Phần bài giảng dựa trên slide/kiến thức giáo trình như lưu ý bên dưới; bài tập bổ sung có nguồn riêng. |
| Slide | [`../materials/slides/Copy of #Week03-Chapter3-1 2024.pdf`](../materials/slides/) và [`Copy of #Week04-Chapter3-2 2024.pdf`](../materials/slides/) |

> ❓ **CẦN XÁC MINH:** Ngày buổi học chưa có, chưa có transcript nên không bắt được
> gợi ý thi hay ví dụ minh hoạ ngoài slide của giảng viên. Phần "Khái niệm tiến trình,
> trạng thái, PCB, định thời" (Chapter3-1) tổng hợp lại theo kiến thức giáo trình chuẩn
> khớp với mục lục slide — nếu số liệu ví dụ cụ thể trên slide khác với đây, cần đối chiếu lại.

---

## Mục lục

- [Tóm tắt một đoạn](#tóm-tắt-một-đoạn)
- [Nội dung chính](#nội-dung-chính)
  - [1. Khái niệm tiến trình (Process)](#1-khái-niệm-tiến-trình-process)
  - [2. Trạng thái tiến trình (Process State)](#2-trạng-thái-tiến-trình-process-state)
  - [3. Process Control Block (PCB)](#3-process-control-block-pcb)
  - [4. Chuyển đổi ngữ cảnh (Context Switch)](#4-chuyển-đổi-ngữ-cảnh-context-switch)
  - [5. Định thời tiến trình — các hàng đợi và bộ định thời](#5-định-thời-tiến-trình--các-hàng-đợi-và-bộ-định-thời)
  - [6. Tạo và kết thúc tiến trình](#6-tạo-và-kết-thúc-tiến-trình)
  - [7. Cộng tác giữa các tiến trình & IPC](#7-cộng-tác-giữa-các-tiến-trình--ipc)
  - [8. Tiểu trình (Thread)](#8-tiểu-trình-thread)
- [Bài tập bổ sung — chuỗi trạng thái tiến trình](#bài-tập-bổ-sung--chuỗi-trạng-thái-tiến-trình)
  - [Chuỗi trạng thái khi mỗi lần in đều phải chờ I/O](#chuỗi-trạng-thái-khi-mỗi-lần-in-đều-phải-chờ-io)
  - [Phân biệt giả định bài tập với thực thi thật](#phân-biệt-giả-định-bài-tập-với-thực-thi-thật)
- [Bảng tổng hợp](#bảng-tổng-hợp)
- [Sơ đồ](#sơ-đồ)
- [Chỗ chưa rõ](#chỗ-chưa-rõ)
- [Tự kiểm tra](#tự-kiểm-tra)
- [Liên kết](#liên-kết)
- [Bạn cần tự làm lại phần nào](#bạn-cần-tự-làm-lại-phần-nào)

---

## Tóm tắt một đoạn

Một tiến trình (process) là một chương trình đang chạy — có không gian nhớ riêng, trạng thái riêng, được hệ điều hành quản lý qua một cấu trúc gọi là PCB (Process Control Block). Tiến trình di chuyển qua các trạng thái (new → ready → running → waiting → terminated) dưới sự điều phối của các bộ định thời. Một tiến trình có thể tạo tiến trình con bằng `fork()`, rồi nạp chương trình khác đè lên bằng họ hàm `exec()` — đây chính là cơ chế đứng sau việc gõ lệnh trong shell Unix/Linux. Các tiến trình cộng tác với nhau qua hai mô hình IPC: chia sẻ vùng nhớ chung (shared memory) hoặc gửi thông điệp qua nhân hệ điều hành (message passing). Tiểu trình (thread) là đơn vị thực thi nhỏ hơn tiến trình, nhiều tiểu trình trong cùng một tiến trình chia sẻ code/data nhưng có stack và thanh ghi riêng — đây là cơ chế đứng sau khái niệm "đa luồng" mà lập trình viên dùng hàng ngày.

---

## Nội dung chính

### 1. Khái niệm tiến trình (Process)

**Trực giác:** một chương trình nằm trên đĩa chỉ là dữ liệu tĩnh; khi bạn chạy nó (double-click, gõ lệnh), hệ điều hành tạo ra một "bản sống" của chương trình đó — có vùng nhớ, có trạng thái đang chạy tới đâu — bản sống đó là tiến trình.

**Analogy:** giống một công thức nấu ăn (chương trình) so với việc thực sự đang nấu theo công thức đó (tiến trình) — cùng một công thức có thể có nhiều người nấu cùng lúc ở nhiều bếp khác nhau (nhiều tiến trình từ cùng một chương trình).

**Ví dụ nhỏ nhất:** mở 2 cửa sổ trình duyệt Chrome cùng lúc — cùng một file thực thi `chrome.exe`, nhưng là hai tiến trình độc lập, mỗi tiến trình có PID (process ID) riêng.

**Định nghĩa hình thức:**
> Tiến trình (process) là một chương trình đang được thực thi, bao gồm program counter, các thanh ghi, và ngăn xếp hiện tại.

**Không gian nhớ của một tiến trình gồm:** text section (code), data section (biến toàn cục), heap (cấp phát động khi chạy), stack (biến cục bộ, tham số hàm, địa chỉ trả về).

---

### 2. Trạng thái tiến trình (Process State)

**Trực giác:** tiến trình không phải lúc nào cũng "đang chạy" — CPU chỉ có giới hạn, còn tiến trình thì có thể phải chờ I/O, chờ tới lượt.

**Analogy:** giống hàng người ở quầy thu ngân — có người đang được phục vụ (running), có người đang xếp hàng chờ tới lượt (ready), có người tạm bước ra ngoài chờ điện thoại rồi mới quay lại xếp hàng tiếp (waiting).

**5 trạng thái cơ bản:**
- **New:** tiến trình vừa được tạo.
- **Ready:** tiến trình sẵn sàng chạy, chỉ chờ được cấp CPU.
- **Running:** đang được CPU thực thi.
- **Waiting (blocked):** đang chờ một sự kiện xảy ra (I/O hoàn tất, tín hiệu, v.v.).
- **Terminated:** đã chạy xong.

**Định nghĩa hình thức:**
> Tại mỗi thời điểm, một tiến trình ở đúng một trong các trạng thái: new, ready, running, waiting, hoặc terminated. Việc chuyển trạng thái do hệ điều hành điều phối dựa trên sự kiện (được cấp CPU, hết thời gian, chờ I/O, I/O hoàn tất, kết thúc).

---

### 3. Process Control Block (PCB)

**Trực giác:** để hệ điều hành có thể tạm dừng một tiến trình rồi sau đó chạy tiếp đúng chỗ cũ, nó cần một "phiếu ghi chú" lưu lại toàn bộ trạng thái của tiến trình đó tại thời điểm bị dừng.

**Analogy:** giống việc đánh dấu trang khi đang đọc sách dở — gấp trang, ghi chú lại đang đọc tới đâu, để lúc sau đọc tiếp cầm đúng cuốn sách cũ lên là tiếp tục được ngay, không cần đọc lại từ đầu.

**PCB lưu:**
- Trạng thái tiến trình (process state)
- Program counter — vị trí lệnh tiếp theo sẽ chạy
- Giá trị các thanh ghi CPU
- Thông tin định thời CPU (độ ưu tiên, con trỏ tới hàng đợi định thời...)
- Thông tin quản lý bộ nhớ (giới hạn vùng nhớ, bảng trang...)
- Thông tin I/O (danh sách thiết bị I/O đang cấp cho tiến trình, danh sách file đang mở)

**Định nghĩa hình thức:**
> PCB (Process Control Block) là cấu trúc dữ liệu hệ điều hành dùng để lưu trữ mọi thông tin cần thiết của một tiến trình, phục vụ cho việc chuyển đổi ngữ cảnh (context switch) giữa các tiến trình.

---

### 4. Chuyển đổi ngữ cảnh (Context Switch)

**Trực giác:** khi CPU chuyển từ chạy tiến trình A sang chạy tiến trình B, nó phải lưu lại toàn bộ "ngữ cảnh" của A (vào PCB của A) rồi nạp ngữ cảnh của B (từ PCB của B) — quá trình lưu/nạp đó gọi là context switch, và bản thân nó tốn thời gian, không làm việc có ích gì cho A lẫn B.

**Analogy:** giống việc bạn đang làm dở một bài tập rồi bị gọi chuyển sang làm việc khác — phải ghi chú lại đang làm tới đâu (lưu ngữ cảnh cũ), rồi đọc lại ghi chú của việc mới trước khi bắt tay vào (nạp ngữ cảnh mới). Thời gian đọc/ghi chú đó là "chi phí chuyển đổi", không tính là thời gian làm việc thật.

**Định nghĩa hình thức:**
> Context switch là việc hệ điều hành lưu trạng thái của tiến trình đang chạy vào PCB của nó, rồi nạp trạng thái đã lưu của tiến trình kế tiếp từ PCB tương ứng để tiếp tục thực thi.

---

### 5. Định thời tiến trình — các hàng đợi và bộ định thời

**Trực giác:** hệ thống có nhiều tiến trình hơn số CPU, nên cần cơ chế xếp hàng và chọn tiến trình nào chạy tiếp theo.

**Analogy:** giống sân bay có nhiều hành khách (tiến trình) nhưng ít cổng lên máy bay (CPU) — cần hàng đợi chờ check-in, hàng đợi chờ ra cổng, và nhân viên quyết định ai được ưu tiên lên trước.

**Các hàng đợi:**
- **Job queue:** tập hợp mọi tiến trình trong hệ thống.
- **Ready queue:** tập hợp tiến trình đang nằm trong RAM, sẵn sàng chạy.
- **Device queue:** tập hợp tiến trình đang chờ một thiết bị I/O cụ thể.

**Các bộ định thời (Scheduler):**
- **Long-term scheduler (job scheduler):** quyết định tiến trình nào được đưa vào bộ nhớ để trở thành ứng viên chạy (kiểm soát mức độ đa chương — degree of multiprogramming). Chạy không thường xuyên.
- **Short-term scheduler (CPU scheduler):** chọn tiến trình nào trong ready queue được cấp CPU kế tiếp. Chạy rất thường xuyên (mili-giây).
- **Medium-term scheduler:** tạm swap tiến trình ra khỏi RAM để giảm tải, sau đó swap lại vào khi cần — cân bằng mức độ đa chương.

---

### 6. Tạo và kết thúc tiến trình

**Trực giác:** một tiến trình có thể sinh ra tiến trình khác — tiến trình con nhận một phần hoặc toàn bộ tài nguyên từ tiến trình cha, và quan hệ cha-con này tạo thành cây tiến trình (ví dụ: trong Linux, mọi tiến trình đều là con cháu của `init`, pid = 1).

**Analogy:** giống việc mở một terminal rồi từ đó gõ lệnh chạy chương trình khác — terminal (shell) là tiến trình cha, chương trình bạn chạy là tiến trình con.

**Ví dụ nhỏ nhất — hàm `fork()`:**
```c
#include <stdio.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
    int pid;
    pid = fork();  // tạo tiến trình con

    if (pid > 0) {
        // đây là tiến trình cha — pid = PID của con
        printf("This is parent process");
        wait(NULL);
        exit(0);
    } else if (pid == 0) {
        // đây là tiến trình con — pid = 0
        printf("This is child process");
        execlp("/bin/ls", "ls", NULL);  // nạp đè chương trình ls
        exit(0);
    } else {
        // pid < 0 — fork thất bại
        printf("Fork error\n");
        exit(-1);
    }
}
```

**`fork()` làm gì:** tiến trình con là bản sao gần như y hệt tiến trình cha (sao chép source code, giá trị biến), bắt đầu chạy tiếp ngay tại dòng sau lệnh `fork()`. Giá trị trả về của `fork()` cho biết mình đang ở nhánh nào:
- `> 0` → đang ở tiến trình cha, giá trị là PID của con vừa tạo
- `= 0` → đang ở tiến trình con
- `< 0` → fork thất bại

**Họ hàm `exec()` làm gì:** nạp một chương trình mới đè lên không gian địa chỉ hiện tại — tiến trình sau khi gọi `exec()` sẽ chạy hẳn chương trình mới, không quay lại code cũ nữa (trừ khi `exec()` thất bại).

**Trình tự thường gặp trong Unix/Linux:** `fork()` tạo tiến trình con → tiến trình con gọi `exec()` để nạp chương trình mới → tiến trình cha gọi `wait()` để đợi con kết thúc.

**Kết thúc tiến trình:**
- Tiến trình tự kết thúc: chạy xong lệnh cuối, gọi `exit()`.
- Bị kết thúc bởi tiến trình khác có đủ quyền (ví dụ cha gọi `abort` với PID của con).
- Hệ điều hành thu hồi toàn bộ tài nguyên tiến trình đã dùng (vùng nhớ, I/O buffer...).

---

### 7. Cộng tác giữa các tiến trình & IPC

**Trực giác:** nhiều tiến trình độc lập đôi khi cần phối hợp với nhau — chia sẻ dữ liệu, chia nhỏ một công việc lớn ra chạy song song, hoặc cùng xây dựng một phần mềm phức tạp theo từng module riêng.

**Analogy:** giống nhiều nhân viên trong công ty cần trao đổi thông tin với nhau — có thể dùng chung một tấm bảng thông báo ở giữa phòng (shared memory) hoặc gửi email cho nhau (message passing).

**Hai mô hình IPC (Inter-Process Communication):**

| | Shared memory | Message passing |
|---|---|---|
| Cơ chế | Vùng nhớ dùng chung giữa các tiến trình | Gửi/nhận thông điệp qua nhân hệ điều hành |
| Ai điều khiển đồng bộ | Do chính các tiến trình tự lo (cần cơ chế đồng bộ riêng) | Do hệ điều hành quản lý (message queue) |
| Tốc độ | Nhanh hơn sau khi thiết lập | Có chi phí gọi hệ thống mỗi lần gửi/nhận |

**Message passing chi tiết:**
- **Đặt tên (naming):**
  - Giao tiếp trực tiếp: `send(P, msg)` gửi tới đích danh tiến trình P, `receive(Q, msg)` nhận từ đích danh tiến trình Q.
  - Giao tiếp gián tiếp: qua mailbox/port — `send(A, msg)`, `receive(A, msg)`.
- **Đồng bộ hoá:** có 4 kiểu — blocking send, nonblocking send, blocking receive, nonblocking receive.
- **Buffering (vùng đệm chứa message dạng queue):**
  - Zero capacity (no buffering) — người gửi phải chờ người nhận sẵn sàng.
  - Bounded capacity — hàng đợi có giới hạn độ dài.
  - Unbounded capacity — hàng đợi không giới hạn.

---

### 8. Tiểu trình (Thread)

**Trực giác:** một tiến trình có thể có nhiều "luồng thực thi" chạy song song bên trong nó, tất cả cùng dùng chung code/data/file nhưng mỗi luồng có ngăn xếp và thanh ghi riêng — đây chính là khái niệm "thread" mà lập trình viên dùng hàng ngày khi viết ứng dụng đa luồng.

**Analogy:** một tiến trình giống một nhà máy (dùng chung mặt bằng, nguyên liệu, kho — tức code/data/file), còn mỗi thread giống một công nhân trong nhà máy đó — mỗi người có công cụ và vị trí làm việc riêng (thanh ghi, stack) nhưng làm việc trên cùng một mặt bằng chung.

**Ví dụ nhỏ nhất:** trình duyệt vừa tải file (một thread lo network I/O) vừa vẽ giao diện (một thread khác lo render) — hai việc chạy gần như đồng thời trong cùng một tiến trình trình duyệt, không cần mở tiến trình mới.

**Định nghĩa hình thức:**
> Tiểu trình (thread) là đơn vị cơ bản sử dụng CPU, gồm Thread ID, program counter, tập thanh ghi, và stack riêng — trong khi chia sẻ chung code, data và tài nguyên (file) với các thread khác cùng thuộc một tiến trình.

**Lợi ích của tiến trình đa luồng:**
- **Đáp ứng nhanh:** chương trình vẫn tiếp tục chạy phần khác dù một phần bị block hoặc đang xử lý tác vụ dài.
- **Chia sẻ tài nguyên:** dễ dàng và tiết kiệm bộ nhớ hơn so với việc tạo nhiều tiến trình riêng.
- **Kinh tế:** tạo/chuyển đổi ngữ cảnh giữa các thread nhanh hơn nhiều so với giữa các tiến trình (ví dụ slide: trên Solaris 2, tạo tiến trình chậm hơn ~30 lần, chuyển ngữ cảnh chậm hơn ~5 lần so với thread).
- **Khả năng mở rộng:** có thể thực thi song song thật sự trên nhiều lõi CPU.

**Phân loại thread:**
- **Thread người dùng (user thread):** chạy trong không gian người dùng, không cần hạt nhân hỗ trợ trực tiếp.
- **Thread hạt nhân (kernel thread):** được hệ điều hành quản lý trực tiếp, thực thi thao tác hệ thống qua system call.

**3 mô hình ánh xạ thread người dùng ↔ thread hạt nhân:**

| Mô hình | Cách ánh xạ | Ưu / nhược |
|---|---|---|
| Many-to-One | Nhiều user thread → 1 kernel thread | Một thread block thì cả tiến trình block; không chạy song song được trên đa lõi; hiếm dùng |
| One-to-One | Mỗi user thread → 1 kernel thread riêng | Đồng thời tốt hơn (thread khác vẫn chạy khi 1 thread block); nhược điểm: số lượng thread có thể bị giới hạn; Windows và Linux dùng mô hình này |
| Many-to-Many | Nhiều user thread → nhiều kernel thread (không cố định 1-1) | Giải quyết hạn chế của 2 mô hình trên nhưng khó cài đặt, ít phổ biến |

---

## Bài tập bổ sung — chuỗi trạng thái tiến trình

> **Nguồn:** ảnh code người dùng cung cấp ngày **2026-09-23**; phần giải thích
> dưới đây là phân tích bổ sung, chưa có đáp án xác nhận của giảng viên.

Chương trình chỉ có **1 process**, gọi `printf()` theo thứ tự **`Bye` → `Hello`
→ `Hi` → `Bye`**, rồi gọi `exit(0)`.

### Chuỗi trạng thái khi mỗi lần in đều phải chờ I/O

**Giả định để vẽ:** mỗi `printf()` đều thực hiện I/O và làm process block
(chờ); bỏ qua việc bị thu hồi CPU giữa chừng và các lần chờ khác.

```text
New → Ready → Running
    → Waiting → Ready → Running   (chờ in Bye xong, được cấp CPU lại)
    → Waiting → Ready → Running   (chờ in Hello xong, được cấp CPU lại)
    → Waiting → Ready → Running   (chờ in Hi xong, được cấp CPU lại)
    → Waiting → Ready → Running   (chờ in Bye xong, được cấp CPU lại)
    → Terminated                 (exit(0))
```

| Chuyển trạng thái | Nguyên nhân trong bài |
|---|---|
| `New → Ready` | OS tạo process và đưa vào ready queue |
| `Ready → Running` | Scheduler cấp CPU cho process |
| `Running → Waiting` | Process yêu cầu in và phải chờ I/O theo giả định |
| `Waiting → Ready` | I/O hoàn tất; process sẵn sàng chạy nhưng chưa chắc được cấp CPU |
| `Running → Terminated` | Hoàn tất chương trình qua `exit(0)` |

Các lệnh `i++`, kiểm tra `while` và `if` được thực thi khi process ở **Running**.
Chúng không tự gây chuyển trạng thái. Sau mỗi lần chờ I/O, process tiếp tục công
việc đang dở khi được cấp CPU lại; không chạy lại từ đầu `main()`.

### Phân biệt giả định bài tập với thực thi thật

**Không thể suy ra chắc chắn 4 lần Waiting chỉ từ 4 lời gọi `printf()`.**
`printf()` có thể chỉ ghi vào buffer (vùng đệm), chưa phải chờ I/O. Khi đó
process vẫn ở Running; việc flush dữ liệu khi `exit(0)` cũng có thể phát sinh chờ.
Nếu toàn bộ lần chạy không block và không bị thu hồi CPU, chuỗi là:

```text
New → Ready → Running → Terminated
```

Nếu bị thu hồi CPU khi vẫn có thể chạy tiếp, process đi theo
`Running → Ready → Running`. Chỉ khi phải chờ sự kiện như I/O mới đi theo
`Running → Waiting → Ready → Running`.

**Chốt cách phân biệt:** Ready = chờ CPU; Waiting = chờ sự kiện/I/O.
I/O xong phải về Ready, không chuyển thẳng sang Running.

---

## Bảng tổng hợp

| Khái niệm | Vai trò cốt lõi |
|---|---|
| PCB | "Phiếu ghi chú" lưu toàn bộ trạng thái một tiến trình |
| Context switch | Lưu/nạp PCB khi CPU đổi từ tiến trình này sang tiến trình khác |
| Long-term scheduler | Quyết định tiến trình nào được nạp vào RAM (kiểm soát mức đa chương) |
| Short-term scheduler | Chọn tiến trình nào trong ready queue được cấp CPU kế tiếp |
| `fork()` | Nhân bản tiến trình hiện tại thành tiến trình con |
| `exec()` | Nạp đè chương trình mới lên tiến trình hiện tại |
| Shared memory | IPC qua vùng nhớ chung, tiến trình tự lo đồng bộ |
| Message passing | IPC qua gửi/nhận thông điệp, hệ điều hành quản lý hàng đợi |
| Thread | Đơn vị thực thi nhỏ hơn tiến trình, chia sẻ code/data, có stack/thanh ghi riêng |

---

## Sơ đồ

```
Trạng thái tiến trình:

         admitted          interrupt
   new ─────────▶ ready ◀──────────── running
                    │  ▲                 │  │
        scheduler   │  │                 │  │
           dispatch │  └── I/O or event  │  │ exit
                     ▼      completion   │  ▼
                  running ───────────────┘  terminated
                    │
                    │ I/O or event wait
                    ▼
                  waiting
```

```
Tạo tiến trình với fork() + exec() (mẫu chuẩn Unix/Linux):

        P0 (cha)
         │
       fork()
         │
   ┌─────┴──────┐
   │             │
 pid>0         pid=0
 (P0 tiếp)     (P1, con)
   │             │
 wait()       exec("/bin/ls")
   │             │
   ▼             ▼
 (đợi P1)    chạy chương trình ls
   │             │
   └──── P1 kết thúc, P0 resume
```

```
Ba mô hình ánh xạ thread:

Many-to-One:      user:  \|/\|/\|/\|/
                   kernel:      \|/

One-to-One:        user:  \|/  \|/  \|/  \|/
                   kernel: \|/  \|/  \|/  \|/

Many-to-Many:       user:  \|/\|/\|/\|/
                   kernel:   \|/  \|/  \|/
```

---

## Chỗ chưa rõ

> ❓ **CẦN XÁC MINH:** Ngày chính xác của buổi học — người dùng nói sẽ cập nhật sau.

> ❓ **CẦN XÁC MINH:** Toàn bộ phần "Khái niệm, trạng thái, PCB, định thời" (mục 1–5) không có nguồn slide cụ thể được xác nhận trong phiên làm việc này — viết theo kiến thức giáo trình chuẩn khớp với mục lục môn học. Nếu số liệu, ví dụ, hoặc thuật ngữ trên slide `Week03-Chapter3-1` khác với những gì ghi ở đây, cần đối chiếu và sửa lại.

> ❓ **CẦN XÁC MINH:** Slide có bài tập vẽ cây tiến trình từ đoạn code `fork()` lồng nhau nhiều lớp (trang 47 slide Chapter3-2) — không rõ đây là bài tập tại lớp hay bài tập về nhà, chưa có đáp án xác nhận.

---

## Tự kiểm tra

**1.** PCB (Process Control Block) lưu trữ những thông tin gì, và tại sao hệ điều hành cần nó khi thực hiện context switch?

<details><summary>Đáp án</summary>

PCB lưu: trạng thái tiến trình, program counter, giá trị thanh ghi CPU, thông tin định thời, thông tin quản lý bộ nhớ, thông tin I/O. Hệ điều hành cần PCB để lưu lại toàn bộ "điểm dừng" của một tiến trình trước khi chuyển CPU sang tiến trình khác, và nạp lại đúng điểm dừng đó khi tiến trình được chạy tiếp.

</details>

**2.** Sau khi gọi `fork()`, làm sao một tiến trình biết mình đang là tiến trình cha hay tiến trình con?

<details><summary>Đáp án</summary>

Dựa vào giá trị trả về của `fork()`: lớn hơn 0 nghĩa là đang ở tiến trình cha (giá trị chính là PID của con), bằng 0 nghĩa là đang ở tiến trình con, nhỏ hơn 0 nghĩa là fork thất bại.

</details>

**3.** Sự khác nhau cốt lõi giữa `fork()` và họ hàm `exec()` là gì?

<details><summary>Đáp án</summary>

`fork()` tạo ra một tiến trình con là bản sao của tiến trình cha (nhân bản không gian địa chỉ, tiếp tục chạy từ sau lệnh fork). `exec()` không tạo tiến trình mới — nó nạp đè một chương trình khác lên không gian địa chỉ của tiến trình hiện tại, tiến trình sẽ chạy hẳn chương trình mới thay vì code cũ.

</details>

**4.** Vì sao mô hình ánh xạ thread Many-to-One ít được dùng trong thực tế?

<details><summary>Đáp án</summary>

Vì tất cả user thread ánh xạ vào đúng một kernel thread — khi một thread bị block (chờ I/O chẳng hạn) thì toàn bộ các thread khác trong tiến trình cũng bị block theo, và các thread không thể chạy song song thật sự trên hệ thống nhiều lõi vì chỉ có một kernel thread truy xuất nhân tại một thời điểm.

</details>

**5.** Hai mô hình IPC (shared memory và message passing) khác nhau ở điểm nào về việc ai chịu trách nhiệm đồng bộ hoá?

<details><summary>Đáp án</summary>

Với shared memory, quá trình giao tiếp và đồng bộ hoá do chính các tiến trình tự quản lý, hệ điều hành chỉ cấp vùng nhớ dùng chung. Với message passing, việc gửi/nhận và hàng đợi message được hệ điều hành (nhân) quản lý trực tiếp thông qua các lời gọi hệ thống `send`/`receive`.

</details>

**6.** Điền các trạng thái còn thiếu tương ứng với các thao tác sau:

| Tên thao tác | Chuyển trạng thái |
|---|---|
| admit | New → Ready |
| dispatch | Ready → ? |
| interrupt | Running → ? |
| I/O or event wait | ? → ? |
| I/O or event completion | ? → ? |
| exit | Running → Terminated |

<details><summary>Đáp án</summary>

| Tên thao tác | Chuyển trạng thái |
|---|---|
| admit | New → Ready |
| dispatch | Ready → Running |
| interrupt | Running → Ready |
| I/O or event wait | Running → Waiting |
| I/O or event completion | Waiting → Ready |
| exit | Running → Terminated |

**Ai gây ra và vì sao:**

| Thao tác | Ai gây ra | Vì sao |
|---|---|---|
| admit | OS | Tiến trình vừa tạo xong, đủ điều kiện chạy nhưng chưa có CPU |
| dispatch | Scheduler | Chọn 1 tiến trình trong Ready, cấp CPU |
| interrupt | OS (timer) | Hết time slice hoặc có tiến trình ưu tiên hơn — **bị ép** rời CPU dù chưa xong việc |
| I/O or event wait | Chính tiến trình | Tự gọi I/O — **tự nguyện** nhường CPU vì biết chưa làm được gì tiếp |
| I/O or event completion | Thiết bị/OS | I/O xong, đủ điều kiện chạy lại nhưng phải xếp hàng, không được chạy ngay |
| exit | Chính tiến trình | Chạy xong, gọi `exit()` |

**Điểm hay bị hỏi thi:** `interrupt` và `I/O or event wait` đều rời khỏi Running,
nhưng `interrupt` là bị ép (chưa xong việc) → về **Ready**; `I/O or event wait`
là tự nguyện (đang chờ thứ khác) → về **Waiting**. Và không có mũi tên nào đi
thẳng `Waiting → Running` — luôn phải qua `Ready`, vì scheduler mới quyết định
ai được chạy tiếp theo, không phải hết chờ là chạy ngay.

**Liên hệ đời sống — phòng khám bệnh, 1 bác sĩ = 1 CPU:**

| Thao tác | Tình huống |
|---|---|
| admit | Đăng ký ở quầy lễ tân → ngồi phòng chờ |
| dispatch | Y tá gọi tên → vào phòng khám |
| interrupt | Đang khám dở thì có ca cấp cứu ưu tiên hơn → bác sĩ bảo ra ngoài chờ tiếp (chưa khám xong, vẫn sẵn sàng, chỉ bị giành chỗ) |
| I/O or event wait | Bác sĩ bảo "đi chụp X-quang rồi quay lại" → tự rời phòng khám vì chưa làm gì thêm được lúc này |
| I/O or event completion | Chụp xong quay lại **phòng chờ**, không được vào khám ngay |
| exit | Khám xong, ra về |

Chỗ hay nhầm: người bị `interrupt` và người vừa chụp X-quang xong đều quay về
phòng chờ — không ai được ưu tiên vào khám ngay, đều phải chờ gọi tên lại.

</details>

---

## Liên kết

- Khái niệm dùng chung: [`knowledge-base/`](../../../../knowledge-base/)
- Ghi chú quan trọng của môn: [`../IMPORTANT_NOTES.md`](../IMPORTANT_NOTES.md)

---

## Bạn cần tự làm lại phần nào

1. Tự vẽ lại chuỗi trạng thái với giả định cả 4 lần in đều phải chờ I/O;
   ghi nguyên nhân trên từng mũi tên.
2. Giải thích vì sao I/O xong phải về Ready, còn hết lượt CPU thì không vào Waiting.
