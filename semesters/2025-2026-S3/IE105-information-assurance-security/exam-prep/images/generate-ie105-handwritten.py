#!/usr/bin/env python3
"""Tạo bốn mặt A4 ghi chú IE105 với kiểu chữ mô phỏng viết tay."""

from html import escape
from pathlib import Path
import textwrap


ROOT = Path(__file__).resolve().parent
W, H = 2480, 3508
COL_X = (145, 1290)
COL_W = 1040
BODY_SIZE, LINE_H, WRAP = 42, 56, 47
TOP, BOTTOM = 390, 320

PAGES = [
    {
        "title": "MẬT MÃ · CÁC GIẢI THUẬT",
        "columns": [
            [
                ("NGUYÊN TẮC & PHÂN LOẠI", [
                    "Thuật toán công khai; độ an toàn nằm ở khóa, không ở việc giấu thuật toán. [B2A s22]",
                    "Cổ điển: thay thế ký tự / hoán vị vị trí. Hiện đại: thiết kế hiện đại hơn.",
                    "Đối xứng: K_E = K_D (vd AES). Bất đối xứng: K_E ≠ K_D (vd RSA).",
                    "Block: khối cố định (DES, 3DES, AES). Stream: từng bit (RC4). [B2A s10, s20, s42]",
                ]),
                ("MẬT MÃ CỔ ĐIỂN", [
                    "Thay thế đơn giản: khóa là hoán vị 26 ký tự (26! khóa); yếu vì phân tích tần suất. [B2A s23, s39–40]",
                    "Hoán vị bậc d: chia bản rõ thành khối d ký tự rồi đổi vị trí. [B2A s25]",
                    "Caesar / Vigenère: C = (P + K) mod 26. Vigenère lặp khóa d ký tự; Caesar là d = 1. [B2A s27]",
                    "Affine: E(x) = ax + b mod 26; giải mã x = a⁻¹(y − b) mod 26. a = 1 → dịch chuyển. [B2A s30]",
                    "Playfair: mã từng cặp; ma trận 5×5 từ khóa; I và J chung một ô. [B2A s31–32]",
                    "Hill: khóa ma trận vuông H; C = HP mod 26; P = H⁻¹C mod 26. [B2A s35]",
                ]),
            ],
            [
                ("MẬT MÃ HIỆN ĐẠI", [
                    "DES: đối xứng, block; khóa 56 bit, khối 64 bit, 16 vòng / 16 khóa con. Khóa ngắn, dễ vét cạn; 3DES an toàn hơn. [B2A s43, s46–48]",
                    "AES: đối xứng; khối 128 bit; khóa 128/192/256 bit. Mỗi vòng: SubBytes → ShiftRows → MixColumns → AddRoundKey. [B2A s19, s49–57]",
                    "RSA: bất đối xứng. Public mã hóa → private giải mã; private ký → public xác minh. Chậm hơn DES nhiều. [B2A s58–64]",
                    "Kết hợp: thuật toán đối xứng mã dữ liệu; RSA mã khóa đối xứng. [B2A s64]",
                ]),
                ("PLAYFAIR · CÁCH LÀM", [
                    "1) Viết khóa, bỏ chữ trùng; điền A–Z còn lại vào ma trận 5×5, gộp I/J.",
                    "2) Chia bản rõ thành cặp; nếu tổng ký tự lẻ thì thêm x cuối. [B2A s31–32]",
                    "3) Cùng hàng → chữ bên phải; cuối hàng vòng về đầu.",
                    "4) Cùng cột → chữ bên dưới; cuối cột vòng về đầu.",
                    "5) Hình chữ nhật → mỗi chữ lấy chữ cùng hàng, ở cột của chữ kia.",
                    "Ví dụ slide: khóa PLAYFAIR; THANH PHO HO CHI MINH → TH AN HP HO HO CH IM IN HX → QM PQ EA GQ GQ BK DE EU KW. [B2A s34]",
                ]),
                ("NHỚ NHANH", [
                    "DES: 56 / 64 / 16. AES: block 128, key 128–256. RSA: public / private.",
                    "Đối xứng nhanh, dùng chung bí mật. Bất đối xứng hỗ trợ trao đổi khóa và chữ ký số.",
                ]),
            ],
        ],
    },
    {
        "title": "CHỨNG THỰC · HASH · CHỮ KÝ SỐ",
        "columns": [
            [
                ("4 CÁCH MÃ HÓA THÔNG ĐIỆP", [
                    "E(K, M), khóa chung → bảo mật ✓, chứng thực ✓, chữ ký số ✗. Bên nhận cũng giữ K nên có thể giả mạo.",
                    "E(PU_b, M) → bảo mật ✓, chứng thực ✗, chữ ký số ✗.",
                    "E(PR_a, M) → bảo mật ✗, chứng thực ✓, chữ ký số ✓.",
                    "E(PU_b, E(PR_a, M)) → bảo mật ✓, chứng thực ✓, chữ ký số ✓.",
                    "Muốn vừa bảo mật vừa chứng thực: ký bằng private key người gửi, rồi mã hóa bằng public key người nhận. [B2B s17–21]",
                ]),
                ("CHỮ KÝ SỐ · KÝ VÀ KIỂM", [
                    "Ký: băm M → mã digest bằng private key người gửi → gửi M kèm chữ ký.",
                    "Kiểm: dùng public key người gửi giải chữ ký; tự băm M nhận; so sánh hai digest.",
                    "Trùng nhau → nội dung không đổi, chữ ký khớp người gửi. Chữ ký số không che nội dung. [B2B s50–52]",
                ]),
                ("HASH VÀ MAC", [
                    "Hash không dùng khóa. MAC = C(K, M): hai bên dùng chung khóa bí mật.",
                    "Cryptographic hash function cần tính một chiều + kháng đụng độ.",
                    "Đổi một ký tự → hash thay đổi mạnh. [B2B s22, s35, s37, s45–49]",
                    "MD5 128 bit · SHA-1 160 bit · SHA-2 224/256/384/512 bit · SHA-3 = Keccak.",
                    "MD5 và SHA-1 không còn kháng đụng độ. [B2B s46–49]",
                ]),
            ],
            [
                ("6 CÔNG DỤNG HASH", [
                    "Ký hiệu: M thông điệp; H hash; S bí mật chung; PR_a private key A; ‖ là nối.",
                    "a) E(K, [M ‖ H(M)]) → bảo mật + chứng thực.",
                    "b) M ‖ E(K, H(M)) → chứng thực, không bảo mật.",
                    "c) M ‖ E(PR_a, H(M)) → chứng thực + chữ ký số.",
                    "d) E(K, [M ‖ E(PR_a, H(M))]) → cả 3 mục tiêu.",
                    "e) M ‖ H(M ‖ S) → chứng thực; không bảo mật, không chữ ký số.",
                    "f) E(K, [M ‖ H(M ‖ S)]) → bảo mật + chứng thực. [B2B s40–44]",
                ]),
                ("MẸO NHẬN DIỆN", [
                    "E(K, …) bao ngoài → có bảo mật.",
                    "E(PR_a, …) → có chữ ký số.",
                    "S nằm trong H(… ‖ S) → chứng thực nhờ bí mật chung.",
                    "Hash đơn thuần không chứng minh ai gửi: ai cũng tính được H(M).",
                ]),
                ("3 MỤC TIÊU", [
                    "Bảo mật: chỉ người có khóa phù hợp đọc nội dung.",
                    "Chứng thực: kiểm tra nguồn gửi / toàn vẹn theo cơ chế có khóa.",
                    "Chữ ký số: xác minh người ký bằng public key; người ký khó chối bỏ.",
                ]),
            ],
        ],
    },
    {
        "title": "THĂM DÒ · QUÉT · MÃ ĐỘC",
        "columns": [
            [
                ("THĂM DÒ (FOOTPRINTING)", [
                    "Nguồn: WHOIS · DNS · network/traceroute · website · email · Google hacking. [B3A s7]",
                    "Giảm lộ tin: split DNS, hạn chế zone transfer; tắt directory listing; Whois privacy; đào tạo chống social engineering. [B3A s52–53]",
                ]),
                ("QUÉT MẠNG · PHƯƠNG PHÁP", [
                    "Port scan · vulnerability scan · network scan. [B3B s4]",
                    "Thứ tự: live systems → open ports → banner grabbing → vulnerability → vẽ sơ đồ → proxy. [B3B s5]",
                    "TCP connect: bắt tay 3 bước xong rồi gửi RST.",
                    "Stealth / half-open: gửi SYN, không bắt tay xong; SYN/ACK = mở, RST = đóng.",
                    "XMAS: FIN+URG+PSH. FIN: cờ FIN. NULL: không cờ. Im lặng = có thể mở; RST = đóng.",
                    "ACK: im lặng = bị lọc / có firewall; RST = không lọc.",
                    "UDP: ICMP port unreachable = đóng; im lặng = có thể mở. [B3B s16–24]",
                ]),
                ("LƯU Ý SCAN", [
                    "XMAS / FIN / NULL dựa RFC 793; không hiệu quả với Windows hiện tại. [B3B s18–20]",
                    "Nhìn cờ TCP + phản hồi để nhận diện method / trạng thái port.",
                ]),
            ],
            [
                ("MẬT KHẨU & SYSTEM HACKING", [
                    "Mật khẩu mạnh: dài, nhiều loại ký tự; tránh từ điển, tên, ngày sinh. [B4 s8, s28]",
                    "Phòng vệ: 8–12 ký tự hỗn hợp; không tái dùng; đổi định kỳ; theo dõi log; không lưu ở chỗ không bảo vệ. [B4 s28]",
                    "Keylogger ghi phím. Spyware theo dõi hoạt động bí mật. [B4 s14, s39, s45]",
                    "Dumpster diving: tìm tin trong rác. NTFS alternate data stream có thể giấu dữ liệu.",
                    "5 giai đoạn: gaining access → escalating privileges → executing applications → hiding files → covering tracks. [B4 s4]",
                ]),
                ("MÃ ĐỘC", [
                    "Vòng đời: Delivery/Infection → Execution → Persistence → Lateral Movement → C2 → Actions on Objectives. [B5 s13]",
                    "Static analysis: không chạy mẫu; xem cấu trúc file, strings, import/API, hash.",
                    "Dynamic analysis: chạy mẫu trong sandbox cô lập; quan sát process, file, registry, network. [B5 s59–105]",
                    "IoC: dấu hiệu mức system · network · file · behavior. [B5 s49–58]",
                    "Phát hiện: signature (khó bắt biến thể) · behavior · ML · sandbox. [B5 s110–111]",
                    "Phòng chống: lớp người dùng · hệ thống · mạng. [B5 s106–109]",
                ]),
            ],
        ],
    },
    {
        "title": "WI-FI · PHẠM VI ÔN TẬP",
        "columns": [
            [
                ("WEP · WPA · WPA2", [
                    "WEP: RC4; IV 24 bit dễ lặp; khóa 40/104 bit tĩnh; CRC-32; yếu, bỏ dùng.",
                    "WPA: RC4 + TKIP; IV 48 bit; khóa 128 bit thay theo gói; Michael MIC; không còn khuyến nghị.",
                    "WPA2: AES-CCMP; IV 48 bit; khóa 128 bit; toàn vẹn CCMP. [B6 s16, s25–34]",
                    "WPA2 Personal = PSK; Enterprise = 802.1X / RADIUS / EAP.",
                    "WPA3: SAE + AES-GCMP; mạnh nhất trong các chuẩn được nêu. [B6 s16]",
                ]),
                ("CHỨNG THỰC & SSID", [
                    "Open system · shared key (WEP) · PSK · Enterprise 802.1X/RADIUS/EAP · MAC filtering · captive portal · WPS. [B6 s14–24]",
                    "Public → open/captive portal; gia đình → WPA2/3 Personal; doanh nghiệp → WPA2/3 Enterprise. [B6 s24]",
                    "SSID: tên mạng, tối đa 32 ký tự, phân biệt hoa thường; SSID mặc định có rủi ro. [B6 s11–13]",
                ]),
                ("802.11 · ĐÃ XÁC NHẬN", [
                    "802.11a: 54 Mbps / 5 GHz. 802.11b: 11 Mbps / 2.4 GHz. 802.11ax: 9.6 Gbps. [B6 s9–10]",
                    "Chuẩn/tốc độ/năm đầy đủ: đối chiếu slide B6 s9–10 trước khi chép thêm.",
                ]),
            ],
            [
                ("NGUY CƠ MẠNG KHÔNG DÂY", [
                    "Rogue AP · evil twin · honeyspot · MAC spoofing · ad hoc · misconfigured AP.",
                    "Client mis-association · unauthorized association · DoS/deauthentication · jamming. [B6 s35–48, s84–86]",
                    "Phòng vệ: WPA2 Enterprise; đổi SSID/password mặc định; VPN/IPsec; phát hiện/chặn rogue AP; Wireless IPS. [B6 s104–110]",
                ]),
                ("PHẠM VI CUỐI KỲ", [
                    "Bài 1 · 2A · 2B · 3A · 3B · 4 · 5 · 6; 4 lab; ý chính Quản lý rủi ro và Xu thế an ninh thông tin. [EXAM_PREP.pdf, trang 1]",
                    "Lab: nhớ mục đích, lệnh/công cụ, cách dùng; handout chưa có đủ trong repo.",
                    "Bài 1: ôn kỹ thuật tấn công, attacker, thứ tự hành động hacker, mô hình bảo mật. Slide Bài 1 bị lỗi nên chi tiết chưa đối chiếu được.",
                ]),
                ("MẸO TRẮC NGHIỆM", [
                    "Đọc từ khóa: thuật toán / khóa / kích thước / mục tiêu bảo mật / dấu hiệu gói tin.",
                    "Nhận diện hình: khóa dùng ở đâu, cờ TCP nào gửi, phản hồi nào xuất hiện.",
                    "Đề cương ghi: 40 câu · 75 phút · tham khảo 2 tờ A4 viết tay. [EXAM_PREP.pdf, trang 1]",
                ]),
            ],
        ],
    },
]


def wrap(text: str) -> list[str]:
    return textwrap.wrap(text, width=WRAP, break_long_words=False, break_on_hyphens=False) or [""]


def render(page: dict, number: int) -> str:
    out = [
        f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" viewBox="0 0 {W} {H}">',
        '<rect width="100%" height="100%" fill="#fffefa"/>',
        '<rect x="42" y="42" width="2396" height="3424" rx="24" fill="none" stroke="#c7d9e8" stroke-width="4"/>',
    ]
    for y in range(342, 3340, 62):
        out.append(f'<path d="M90 {y} H2390" stroke="#e6edf3" stroke-width="2"/>')
    out.extend([
        '<path d="M119 340 V3340" stroke="#e5bcbc" stroke-width="3"/>',
        '<text x="145" y="132" font-family="Marker Felt, Noteworthy, cursive" font-size="44" fill="#315d83">IE105 · GHI CHÚ ÔN THI</text>',
        f'<text x="145" y="224" font-family="Marker Felt, Noteworthy, cursive" font-size="62" fill="#193f63">{escape(page["title"])}</text>',
        f'<text x="145" y="294" font-family="Noteworthy, Bradley Hand, cursive" font-size="38" fill="#52697e">Mặt {number}/4 · Mẫu 4 mặt để in hai mặt trên 2 tờ A4</text>',
        '<path d="M145 320 H2335" stroke="#829fb9" stroke-width="4"/>',
        '<path d="M1240 340 V3340" stroke="#d3dfe8" stroke-width="3"/>',
    ])
    ends = []
    for col_index, sections in enumerate(page["columns"]):
        x, y = COL_X[col_index], TOP
        for heading, paragraphs in sections:
            out.append(f'<text x="{x}" y="{y}" font-family="Marker Felt, Noteworthy, cursive" font-size="46" fill="#a04642">{escape(heading)}</text>')
            y += 66
            for paragraph in paragraphs:
                for line_no, line in enumerate(wrap(paragraph)):
                    prefix = "• " if line_no == 0 else "  "
                    out.append(f'<text x="{x + 4}" y="{y}" font-family="Noteworthy, Bradley Hand, cursive" font-size="{BODY_SIZE}" fill="#263f5a">{escape(prefix + line)}</text>')
                    y += LINE_H
                y += 11
            y += 22
        ends.append(y)
    if max(ends) > H - BOTTOM:
        raise ValueError(f"Page {number} overflows at y={max(ends)}")
    out.extend([
        '<path d="M145 3370 H2335" stroke="#b7c7d5" stroke-width="3"/>',
        '<text x="145" y="3432" font-family="Noteworthy, Bradley Hand, cursive" font-size="29" fill="#63798e">Nguồn viết tắt: B2A/B2B/B3A/B3B/B4/B5/B6 = slide theo bài; xem exam-map.md.</text>',
        f'<text x="2332" y="3432" text-anchor="end" font-family="Noteworthy, Bradley Hand, cursive" font-size="30" fill="#63798e">{number}/4</text>',
        '</svg>',
    ])
    return "\n".join(out)


def main() -> None:
    for number, page in enumerate(PAGES, start=1):
        target = ROOT / f"ie105-handwritten-page-{number}.svg"
        if target.exists():
            raise FileExistsError(f"Refusing to overwrite {target}")
        target.write_text(render(page, number), encoding="utf-8")
        print(target.name)


if __name__ == "__main__":
    main()
