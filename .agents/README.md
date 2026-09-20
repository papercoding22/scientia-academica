# Cầu nối skill Claude ↔ Codex

`.agents/skills` là symlink tới `../.claude/skills`. Claude dùng thư mục đích,
còn Codex dùng đường dẫn `.agents/skills` để tự phát hiện cùng các skill đó.

## Quy tắc

- Chỉ tạo hoặc sửa skill ở `.claude/skills/<skill-name>/SKILL.md`.
- Không copy thủ công sang `.agents/skills`: skill mới sẽ hiện tự động qua symlink.
- Giữ symlink này trong Git; không thay nó bằng thư mục thật.

## Dùng với Codex

Mở một phiên Codex mới từ root của repo rồi gọi tên skill, ví dụ:

```text
Dùng skill slide-knowledge-map để lập knowledge map cho IE103.
```

## Kiểm tra

```bash
test -f .agents/skills/<skill-name>/SKILL.md
```

Lệnh phải thành công cho mọi skill có tại `.claude/skills/`.
