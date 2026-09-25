# Mutex và semaphore qua ví dụ React + TypeScript

| | |
|---|---|
| Môn | IT007 — Hệ điều hành |
| Liên quan | [L05 — Process synchronization](../lectures/L05-process-synchronization.md), mục 6, 7 và 10 |
| Đối tượng | Frontend Engineer đã biết React, TypeScript và `async/await` |
| Nguồn nội dung | Tổng hợp phiên trao đổi ngày 2026-09-25; lý thuyết đối chiếu L05, API đối chiếu tài liệu thư viện và React |
| Phạm vi | Ví dụ frontend **ngoài slide**; upload và nơi lưu lịch sử đều được **giả lập**, không gửi file lên server |

---

## Mục lục

- [1. Trực giác](#1-trực-giác)
- [2. Analogy — quầy nhận hàng và sổ chung](#2-analogy--quầy-nhận-hàng-và-sổ-chung)
- [3. Ví dụ nhỏ nhất — hai upload làm mất lịch sử thế nào](#3-ví-dụ-nhỏ-nhất--hai-upload-làm-mất-lịch-sử-thế-nào)
- [4. Định nghĩa và mối quan hệ](#4-định-nghĩa-và-mối-quan-hệ)
- [5. Code React + TypeScript](#5-code-react--typescript)
  - [5.1. Cách chạy](#51-cách-chạy)
  - [5.2. Service giữ semaphore và mutex dùng chung](#52-service-giữ-semaphore-và-mutex-dùng-chung)
  - [5.3. Component và I/O giả lập](#53-component-và-io-giả-lập)
- [6. Những giới hạn và lỗi cần phân biệt](#6-những-giới-hạn-và-lỗi-cần-phân-biệt)
- [7. Kiểm chứng ví dụ](#7-kiểm-chứng-ví-dụ)
- [8. Tự kiểm tra](#8-tự-kiểm-tra)
- [9. Nguồn](#9-nguồn)
- [10. Bảng chốt kiến thức](#10-bảng-chốt-kiến-thức)

---

## 1. Trực giác

**Semaphore kiểm soát có bao nhiêu tác vụ được đi tiếp; mutex bảo đảm một tác vụ hoàn thành đoạn thao tác chung trước khi tác vụ khác vào.**

Trong màn hình upload, ta muốn **tối đa 2 file đang upload**, đồng thời không làm mất dữ liệu khi các upload cùng cập nhật **một danh sách lịch sử**. Hai yêu cầu này cần hai cơ chế khác nhau.

## 2. Analogy — quầy nhận hàng và sổ chung

Quầy có **2 nhân viên nhận hàng**, nhưng chỉ có **một cuốn sổ ghi nhận**:

| Ngoài đời | Trong ứng dụng |
|---|---|
| Hai suất tiếp nhận hàng | `Semaphore(2)` — tối đa 2 upload đang chạy |
| Người thứ ba chờ có suất trống | Upload thứ ba chờ Promise do semaphore trả về |
| Chìa khóa cho quyền sửa sổ | Một mutex dùng chung cho lịch sử |
| Đọc sổ → thêm một dòng → cất sổ | `get()` → tạo danh sách mới → `set()` |

*Chỗ analogy vỡ:* JavaScript trên main thread không có hai callback đồng thời thực thi lệnh JavaScript. Các tác vụ vẫn có thể **xen kẽ qua `await`**: trong lúc A chờ I/O, B được chạy và đọc cùng dữ liệu cũ. Semaphore/mutex của thư viện phối hợp bằng Promise; tác vụ chờ không quay vòng chiếm main thread và không đồng nghĩa OS đã block cả thread trình duyệt.

## 3. Ví dụ nhỏ nhất — hai upload làm mất lịch sử thế nào

Giả sử file A và B đều upload thành công. Mỗi tác vụ ghi lịch sử theo cách sau:

```ts
const current = await historyStore.get();
await historyStore.set([...current, id]);
```

`historyStore` ở đây có API đọc/ghi **bất đồng bộ**; hai lần gọi riêng lẻ chưa tạo thành một transaction (giao dịch) đọc–sửa–ghi. Ví dụ có thể là một lớp bọc lưu trữ client. Phần code bên dưới dùng store trong bộ nhớ để mô phỏng hành vi này, không phải IndexedDB thật.

Một lịch xen kẽ gây **lost update (mất cập nhật)**:

| Bước | Tác vụ A | Tác vụ B | Lịch sử đã lưu |
|---|---|---|---|
| 1 | Đọc `[]` | | `[]` |
| 2 | | Đọc `[]` | `[]` |
| 3 | Lưu `[A]` | | `[A]` |
| 4 | | Lưu `[B]` từ bản đã đọc | **`[B]` — mất A** |

Có mutex, **toàn bộ** đoạn đọc–sửa–ghi của A hoàn tất trước khi B bắt đầu đọc: `[] → [A] → [A, B]`.

Semaphore vẫn cần riêng: dù lịch sử đã an toàn, người dùng chọn 100 file thì ta vẫn không muốn khởi chạy cả 100 upload cùng lúc.

```text
Nhiều file được chọn
        │
        ▼
Semaphore(2): nhận một suất upload
        │
        ▼
Upload giả lập → trả suất upload (kể cả khi upload thất bại)
        │ thành công
        ▼
Mutex: lấy quyền cập nhật lịch sử
        │
        ▼
Đọc lịch sử → thêm ID → ghi lịch sử → trả mutex
        │
        ▼
Cập nhật React state bằng functional updater
```

## 4. Định nghĩa và mối quan hệ

**Mutex** viết tắt từ **MUTual EXclusion**: bảo vệ quyền truy cập độc quyền vào critical section (đoạn code cần bảo vệ). Mutex theo mô hình OS có ownership: thread giữ khóa phải trả khóa. L05 mục 6 trình bày thao tác `acquire()`/`release()` và yêu cầu tính atomic (nguyên tử). [C5-2 s7–s13]

**Semaphore** là biến đếm được thao tác qua `wait()` và `signal()`. Counting semaphore có thể quản lý nhiều suất; khởi tạo N suất để cho phép tối đa N tác vụ đi qua, với điều kiện mỗi tác vụ lấy/trả đúng số suất. [C5-2 s15–s16, s26]

| Thuộc tính | Mutex | Semaphore |
|---|---|---|
| Trong ví dụ | Bảo vệ chuỗi đọc–sửa–ghi lịch sử | Giới hạn upload đang chạy |
| Mức đồng thời | Tối đa 1 tác vụ trong CS của cùng khóa | Tối đa 2 upload với cấu hình này |
| Điểm giao nhau | Đều có thể làm tác vụ phải chờ | Semaphore khởi tạo 1 có thể dùng để bảo vệ CS nếu sử dụng đúng |
| Điểm cần phân biệt | Ownership của mutex OS | Có thể `signal()` từ tác vụ khác, phù hợp báo hiệu sự kiện |

**Ánh xạ sang thư viện `async-mutex` — ngoài slide:** `runExclusive(callback)` chờ lấy quyền, chạy callback rồi tự trả quyền khi callback hoàn thành hoặc thất bại. Callback trả Promise thì khóa/suất được giữ đến khi Promise đó settle. `Mutex` trong thư viện phối hợp **async task**, không phải mutex kernel và không kiểm tra danh tính thread như mutex OS. Không suy mọi chi tiết ownership của OS sang API JavaScript. [Nguồn thư viện](https://github.com/DirtyHairy/async-mutex#readme)

Trong bounded-buffer của slide, semaphore `empty`/`full` kiểm soát chỗ trống/phần tử, còn `mutex = 1` bảo vệ buffer. Ví dụ upload dùng **cùng cách tách trách nhiệm**, nhưng không phải bản cài đặt đầy đủ bounded-buffer với hai semaphore `empty`/`full`. [C5-3 s5–s10]

## 5. Code React + TypeScript

### 5.1. Cách chạy

Trong một ứng dụng React + TypeScript có sẵn, cài thư viện:

```bash
npm install async-mutex@0.5.0
```

Tạo `src/upload-service.ts` và thay nội dung `src/App.tsx` bằng hai khối dưới, rồi chạy ứng dụng bằng lệnh dev của dự án. Với dự án Vite thông thường là `npm run dev`.

Chọn ít nhất 3 file để có tác vụ phải chờ semaphore. Demo **chỉ dùng tên file**, giả lập upload bằng timer và lưu lịch sử trong bộ nhớ; refresh hoặc tạo instance demo mới sẽ mất lịch sử. Thứ tự danh sách là thứ tự ghi lịch sử, không cam kết trùng thứ tự chọn file.

### 5.2. Service giữ semaphore và mutex dùng chung

`upload-service.ts`:

```ts
import { Mutex, Semaphore } from "async-mutex";

export type HistoryStore = {
  get: () => Promise<string[]>;
  set: (items: string[]) => Promise<void>;
};

export function createUploader(
  uploadFile: (file: File) => Promise<string>,
  historyStore: HistoryStore,
) {
  const slots = new Semaphore(2);
  const historyMutex = new Mutex();

  return async function upload(file: File): Promise<string> {
    // Giữ một suất trong suốt thời gian upload; hoàn tất thì trả suất.
    const id = await slots.runExclusive(() => uploadFile(file));

    // Cả đọc và ghi phải nằm trong cùng một critical section.
    await historyMutex.runExclusive(async () => {
      const current = await historyStore.get();
      await historyStore.set([...current, id]);
    });

    return id;
  };
}
```

**Chỗ quyết định:** `createUploader()` được gọi một lần cho một nhóm tác vụ cần phối hợp. Mọi lần gọi hàm `upload` trả về đều dùng **cùng hai đối tượng khóa**. Nếu tạo service mới cho mỗi file thì mỗi file có khóa riêng, không phối hợp được với các file khác.

`slots` chỉ bao quanh upload; upload thành công thì suất được trả **trước khi chờ mutex lịch sử**. Do đó có thể có 2 upload đang chạy đồng thời với 1 tác vụ đang ghi lịch sử. Giữ mutex bao quanh cả upload sẽ vô tình ép phần upload chạy tuần tự.

### 5.3. Component và I/O giả lập

`App.tsx`:

```tsx
import { useState } from "react";
import { createUploader, type HistoryStore } from "./upload-service";

const sleep = (ms: number) =>
  new Promise<void>((resolve) => setTimeout(resolve, ms));

function createDemo() {
  let saved: string[] = [];
  let sequence = 0;
  const historyStore: HistoryStore = {
    async get() {
      await sleep(20);
      return [...saved];
    },
    async set(items) {
      await sleep(20);
      saved = [...items];
    },
  };
  const upload = createUploader(async (file) => {
    await sleep(300); // Giả lập I/O; không gửi nội dung file.
    return `${++sequence}: ${file.name}`;
  }, historyStore);
  return { upload, historyStore };
}

export default function App() {
  const [demo] = useState(createDemo);
  const [busy, setBusy] = useState(false);
  const [completed, setCompleted] = useState(0);
  const [history, setHistory] = useState<string[]>([]);
  const [errors, setErrors] = useState<string[]>([]);

  async function start(files: File[]) {
    setBusy(true);
    setCompleted(0);
    setErrors([]);
    try {
      const results = await Promise.allSettled(files.map(async (file) => {
        const id = await demo.upload(file);
        setCompleted((previous) => previous + 1);
        return id;
      }));
      setErrors(results.flatMap((result) =>
        result.status === "rejected" ? [String(result.reason)] : []
      ));
      setHistory(await demo.historyStore.get());
    } catch (error) {
      setErrors((previous) => [...previous, String(error)]);
    } finally {
      setBusy(false);
    }
  }

  return (
    <main>
      <h1>Upload giả lập</h1>
      <label>
        Chọn các file để chạy ví dụ
        <input type="file" multiple disabled={busy} onChange={(event) => {
          const files = Array.from(event.currentTarget.files ?? []);
          event.currentTarget.value = "";
          if (files.length) void start(files);
        }} />
      </label>
      <p>Hoàn tất cả upload và lưu lịch sử trong đợt này: {completed}</p>
      {busy && <p>Đang xử lý…</p>}
      {errors.map((error, index) => <p role="alert" key={index}>{error}</p>)}
      <ul>{history.map((id) => <li key={id}>{id}</li>)}</ul>
    </main>
  );
}
```

`useState(createDemo)` giữ một service ổn định qua các lần render của **cùng component instance**. React Strict Mode có thể gọi initializer hai lần trong development; hàm này chỉ tạo đối tượng trong bộ nhớ, không upload hay đăng ký tác vụ nền lúc khởi tạo. Nếu nhiều component phải phối hợp, đưa service lên provider chung rồi truyền xuống, không tạo mỗi component một service độc lập. [React: initializer](https://react.dev/reference/react/useState#avoiding-recreating-the-initial-state)

`setCompleted(previous => previous + 1)` là **functional updater**: React áp dụng từng cập nhật lên state đang được xử lý trong hàng đợi. Không cần bọc mutex chỉ để tăng state kiểu này. Mutex trong ví dụ bảo vệ `historyStore.get()` và `historyStore.set()`, không bảo vệ việc render. [React: cập nhật dựa trên state trước](https://react.dev/reference/react/useState#updating-state-based-on-the-previous-state)

## 6. Những giới hạn và lỗi cần phân biệt

| Tình huống | Hệ quả / cách hiểu đúng |
|---|---|
| Tạo mutex mới trong mỗi lần `upload()` | Mỗi tác vụ có khóa riêng; lost update vẫn có thể xảy ra |
| Chỉ khóa `set()`, để `get()` ngoài mutex | Hai tác vụ vẫn có thể đọc cùng snapshot cũ; phải bảo vệ cả chuỗi |
| Quên `await` hoặc `return` Promise trong callback `runExclusive` | Callback kết thúc sớm, khóa/suất được trả khi công việc chưa xong |
| Callback reject/throw | `runExclusive` tự trả khóa/suất và truyền lỗi ra ngoài; UI vẫn phải xử lý lỗi |
| Callback chờ một Promise không bao giờ settle | Quyền tiếp tục bị giữ; cần cơ chế hủy/timeout của chính tác vụ khi áp dụng thực tế |
| Đặt semaphore thành 5 | Tối đa 5 upload; vẫn chỉ 1 tác vụ cập nhật lịch sử |
| Hai tab hoặc hai người dùng | Mutex JavaScript ở đây không phối hợp được giữa các môi trường đó; cần cơ chế ở phạm vi dữ liệu thực sự được chia sẻ |
| Upload thành công nhưng lưu lịch sử thất bại | Khóa không rollback upload; cần chiến lược retry/idempotency khi xây tính năng thật |
| Gọi trực tiếp `historyStore.set()` từ nơi khác | Bỏ qua mutex nên mất bảo đảm; mọi cập nhật liên quan phải đi qua cùng cơ chế |

**Không phải mọi async code đều cần mutex.** Chỉ cần khi có bất biến chung phải giữ qua nhiều bước có thể xen kẽ. Nếu lớp lưu trữ đã cung cấp transaction hoặc một thao tác append atomic thì nên dùng bảo đảm sẵn có của lớp đó. Functional updater của React chỉ xử lý hàng đợi state tương ứng; nó không biến một chuỗi API/IndexedDB thành transaction.

**So với mutex OS:** ở đây tác vụ đợi một Promise, event loop vẫn xử lý việc khác. Không dùng vòng `while` đồng bộ để chờ khóa trên main thread vì có thể chặn chính tác vụ cần chạy để trả khóa. Không suy cơ chế này thành memory barrier hoặc đồng bộ shared memory giữa Web Workers.

## 7. Kiểm chứng ví dụ

Hai khối TypeScript/TSX trên được trích nguyên văn để kiểm tra trong môi trường tạm, không cài dependency vào repo học tập.

Môi trường kiểm tra ngày 2026-09-25: Node.js **22.19.0**, `async-mutex` **0.5.0**, React/React DOM **19.3.0**, TypeScript **7.0.2**. Đây là các phiên bản đã chạy thử, không phải yêu cầu tối thiểu của ví dụ.

| Kiểm tra | Kết quả thực tế |
|---|---|
| TypeScript `--strict --noEmit`, JSX `react-jsx` | Cả service và component đều hợp lệ |
| Đối chứng: hai tác vụ đọc cùng snapshot rồi ghi, không mutex | Còn **1/2 ID** — tái hiện lost update |
| Chạy 6 upload qua service nguyên văn trong ghi chú | Tối đa **2 upload**, tối đa **1 chuỗi cập nhật lịch sử**, lưu đủ **6/6 ID** |
| Một upload thất bại và một lần ghi lịch sử thất bại | Hai tác vụ lỗi được báo; các tác vụ C, D và E vẫn tiếp tục thành công |
| React `renderToStaticMarkup` | Render ban đầu thành công, có tiêu đề và input chọn file |

**Giới hạn kiểm chứng:** chưa kiểm tra thao tác chọn file/cập nhật giao diện trong trình duyệt; không có upload mạng, IndexedDB thật hoặc kiểm tra phối hợp giữa nhiều tab. Các kiểm tra đồng thời ở trên chạy trên service TypeScript được trích từ chính khối code, không phải một bản viết lại.

## 8. Tự kiểm tra

**1.** Giữ semaphore bằng 2 nhưng xóa mutex: upload có vượt quá 2 không, và điều gì vẫn có thể sai?

<details><summary>Đáp án</summary>

Upload vẫn bị giới hạn ở 2 vì mọi upload đều qua cùng semaphore. Chuỗi đọc–sửa–ghi lịch sử có thể xen kẽ và làm mất một ID.

</details>

**2.** Vì sao không đặt `historyMutex.runExclusive()` bao quanh cả upload và ghi lịch sử?

<details><summary>Đáp án</summary>

Cách đó có thể an toàn cho lịch sử nhưng làm cả pipeline chỉ chạy một tác vụ mỗi lúc; semaphore 2 không còn giúp có 2 upload đồng thời. Chỉ giữ mutex quanh phần cần độc quyền.

</details>

**3.** Có `setCompleted(previous => previous + 1)` thì có thể bỏ mutex của store không?

<details><summary>Đáp án</summary>

Không. State React và store bất đồng bộ là hai nơi khác nhau. Functional updater bảo đảm cộng dựa trên state trước trong hàng đợi React; không tuần tự hóa `get()`/`set()` của store.

</details>

## 9. Nguồn

- [L05 — Process synchronization](../lectures/L05-process-synchronization.md): mục 6 mutex, mục 7 semaphore, mục 10 kết hợp trong bounded-buffer.
- **C5-2**, [Copy of #Week09-Chapter5-2 2024.pdf](../materials/slides/Copy%20of%20%23Week09-Chapter5-2%202024.pdf): s7–s13 mutex; s15–s16, s26 semaphore.
- **C5-3**, [Copy of #Week10-Chapter5-3 2024.pdf](../materials/slides/Copy%20of%20%23Week10-Chapter5-3%202024.pdf): s5–s13 bounded-buffer và lỗi bỏ quên critical section.
- [async-mutex — tài liệu API](https://github.com/DirtyHairy/async-mutex#readme): `Mutex`, `Semaphore`, thời điểm trả quyền và xử lý lỗi của `runExclusive`. Đã đối chiếu ngày 2026-09-25.
- [React — useState](https://react.dev/reference/react/useState): functional updater, initializer và Strict Mode. Đã đối chiếu ngày 2026-09-25.
- Ví dụ upload, analogy và trace là **tự dựng ngoài slide** từ phiên trao đổi với người dùng; không phải bài tập nộp hoặc lời giảng viên.

## 10. Bảng chốt kiến thức

| Câu hỏi cần giải quyết | Công cụ trong ví dụ |
|---|---|
| Có tối đa bao nhiêu upload đang chạy? | Semaphore |
| Ai được thực hiện trọn chuỗi cập nhật lịch sử? | Mutex dùng chung |
| Tăng state React dựa trên giá trị trước thế nào? | Functional updater |
| Ai trả quyền khi callback thất bại? | `runExclusive` của thư viện |
| Phối hợp giữa nhiều tab/người dùng thế nào? | Cơ chế ở phạm vi chia sẻ tương ứng; mutex cục bộ này chưa giải quyết |
