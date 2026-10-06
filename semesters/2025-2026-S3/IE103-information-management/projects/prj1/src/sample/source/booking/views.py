import copy
from django.shortcuts import render
from django.db import connection

# ------------------------------------------------------------------ helpers
STATUS_LABEL = {
    # TAIXE
    'San sang':       'Sẵn sàng',
    'Dang ban':       'Đang bận',
    'Khong hoat dong':'Không HĐ',
    'Bi dinh chi':    'Bị đình chỉ',
    # CUOCXE
    'Cho nhan':  'Chờ nhận',
    'Da nhan':   'Đã nhận',
    'Dang chay': 'Đang chạy',
    'Hoan thanh':'Hoàn thành',
    'Da huy':    'Đã hủy',
}

STATUS_BADGE = {
    'San sang':       'success',
    'Dang ban':       'warning',
    'Khong hoat dong':'secondary',
    'Bi dinh chi':    'danger',
    'Cho nhan':  'info',
    'Da nhan':   'primary',
    'Dang chay': 'warning',
    'Hoan thanh':'success',
    'Da huy':    'danger',
}

LOAI_XE_LABEL = {'Xe may': 'Xe máy', 'O to': 'Ô tô'}


def _fetchall_as_dicts(cursor):
    cols = [c[0] for c in cursor.description]
    return [dict(zip(cols, row)) for row in cursor.fetchall()]


def _fmt_vnd(value):
    if value is None:
        return '—'
    return f"{int(value):,}".replace(',', '.') + ' đ'


def _enrich_trip(row):
    row['trang_thai_label'] = STATUS_LABEL.get(row['Trang_Thai'], row['Trang_Thai'])
    row['trang_thai_badge'] = STATUS_BADGE.get(row['Trang_Thai'], 'secondary')
    row['tong_tien_fmt'] = _fmt_vnd(row.get('Tong_Tien'))
    row['gia_fmt'] = _fmt_vnd(row.get('Gia_Uoc_Tinh'))
    return row


def _enrich_driver(row):
    row['trang_thai_label'] = STATUS_LABEL.get(row['Trang_Thai'], row['Trang_Thai'])
    row['trang_thai_badge'] = STATUS_BADGE.get(row['Trang_Thai'], 'secondary')
    dut = float(row['Diem_Uy_Tin']) if row.get('Diem_Uy_Tin') is not None else 0
    if dut >= 4.5:
        row['dut_badge'] = 'success'
    elif dut >= 3.5:
        row['dut_badge'] = 'warning'
    else:
        row['dut_badge'] = 'danger'
    row['loai_xe_label'] = LOAI_XE_LABEL.get(row.get('Loai_PT') or '', row.get('Loai_PT') or '—')
    return row


# --------------------------------------------------------------- dashboard
def dashboard(request):
    context = {}
    try:
        with connection.cursor() as cursor:
            # DB info
            cursor.execute("SELECT @@VERSION, DB_NAME()")
            row = cursor.fetchone()
            context['db_info'] = {
                'version': row[0].split('\n')[0] if row[0] else 'N/A',
                'name': row[1],
                'host': 'ql-datxecongnghe.database.windows.net',
            }

            # KPI 1: Tài xế sẵn sàng
            cursor.execute("SELECT COUNT(*) FROM TAIXE WHERE Trang_Thai = 'San sang'")
            context['kpi_drivers_ready'] = cursor.fetchone()[0]

            # KPI 2 & 3: Tổng cuốc / Hoàn thành
            cursor.execute("""
                SELECT
                    COUNT(*) AS tong,
                    SUM(CASE WHEN Trang_Thai = 'Hoan thanh' THEN 1 ELSE 0 END) AS hoan_thanh,
                    SUM(CASE WHEN Trang_Thai = 'Da huy'     THEN 1 ELSE 0 END) AS da_huy
                FROM CUOCXE
            """)
            row = cursor.fetchone()
            context['kpi_total_trips']     = row[0]
            context['kpi_completed_trips'] = row[1]
            context['kpi_cancelled_trips'] = row[2]

            # KPI 4: Tổng doanh thu (cuốc hoàn thành)
            cursor.execute("""
                SELECT ISNULL(SUM(Tong_Tien), 0)
                FROM CUOCXE
                WHERE Trang_Thai = 'Hoan thanh'
            """)
            context['kpi_revenue'] = _fmt_vnd(cursor.fetchone()[0])

            # Bảng 10 cuốc xe gần nhất
            cursor.execute("""
                SELECT TOP 10
                    cx.Ma_Cuoc_Xe,
                    kh.Ten_Khach_Hang,
                    ISNULL(tx.Ten_Tai_Xe, N'—') AS Ten_Tai_Xe,
                    bg.Loai_Xe,
                    cx.Khoang_Cach,
                    cx.Tong_Tien,
                    cx.Trang_Thai,
                    CONVERT(VARCHAR(16), cx.Thoi_Gian_Tao, 120) AS Thoi_Gian
                FROM CUOCXE cx
                JOIN  KHACHHANG kh ON cx.Ma_Khach_Hang = kh.Ma_Khach_Hang
                LEFT JOIN TAIXE   tx ON cx.Ma_Tai_Xe    = tx.Ma_Tai_Xe
                LEFT JOIN BANGGIA bg ON cx.Ma_Bang_Gia   = bg.Ma_Bang_Gia
                ORDER BY cx.Thoi_Gian_Tao DESC
            """)
            recent = _fetchall_as_dicts(cursor)
            context['recent_trips'] = [_enrich_trip(r) for r in recent]

    except Exception as e:
        context['db_error'] = str(e)

    return render(request, 'booking/dashboard.html', context)


# --------------------------------------------------------------- drivers
DRIVER_STATUSES = [
    ('', 'Tất cả'),
    ('San sang',        'Sẵn sàng'),
    ('Dang ban',        'Đang bận'),
    ('Khong hoat dong', 'Không HĐ'),
    ('Bi dinh chi',     'Bị đình chỉ'),
]


def drivers(request):
    status_filter = request.GET.get('status', '')
    context = {
        'status_filter': status_filter,
        'driver_statuses': DRIVER_STATUSES,
    }
    try:
        with connection.cursor() as cursor:
            sql = """
                SELECT
                    tx.Ma_Tai_Xe,
                    tx.Ten_Tai_Xe,
                    tx.SDT,
                    tx.Trang_Thai,
                    tx.Diem_Uy_Tin,
                    pt.Loai_Phuong_Tien AS Loai_PT,
                    pt.Nhan_Hieu,
                    pt.Bien_So_Xe
                FROM TAIXE tx
                OUTER APPLY (
                    SELECT TOP 1 Loai_Phuong_Tien, Nhan_Hieu, Bien_So_Xe
                    FROM PHUONGTIEN
                    WHERE Ma_Tai_Xe = tx.Ma_Tai_Xe AND Trang_Thai = 'Hoat dong'
                    ORDER BY Thoi_Gian_Tao DESC
                ) pt
            """
            if status_filter:
                sql += " WHERE tx.Trang_Thai = %s"
                sql += " ORDER BY tx.Trang_Thai, tx.Ten_Tai_Xe"
                cursor.execute(sql, [status_filter])
            else:
                sql += " ORDER BY tx.Trang_Thai, tx.Ten_Tai_Xe"
                cursor.execute(sql)

            drivers_list = _fetchall_as_dicts(cursor)
            context['drivers'] = [_enrich_driver(r) for r in drivers_list]
            context['total'] = len(drivers_list)

    except Exception as e:
        context['db_error'] = str(e)

    return render(request, 'booking/drivers.html', context)


# --------------------------------------------------------------- trips
TRIP_STATUSES = [
    ('', 'Tất cả'),
    ('Cho nhan',  'Chờ nhận'),
    ('Da nhan',   'Đã nhận'),
    ('Dang chay', 'Đang chạy'),
    ('Hoan thanh','Hoàn thành'),
    ('Da huy',    'Đã hủy'),
]


def trips(request):
    status_filter = request.GET.get('status', '')
    context = {
        'status_filter': status_filter,
        'trip_statuses': TRIP_STATUSES,
    }
    try:
        with connection.cursor() as cursor:
            sql = """
                SELECT
                    cx.Ma_Cuoc_Xe,
                    kh.Ten_Khach_Hang,
                    ISNULL(tx.Ten_Tai_Xe, N'—') AS Ten_Tai_Xe,
                    bg.Loai_Xe,
                    bg.Khung_Gio,
                    cx.Khoang_Cach,
                    cx.Gia_Uoc_Tinh,
                    cx.Tong_Tien,
                    cx.Trang_Thai,
                    CONVERT(VARCHAR(16), cx.Thoi_Gian_Tao, 120) AS Thoi_Gian
                FROM CUOCXE cx
                JOIN  KHACHHANG kh ON cx.Ma_Khach_Hang = kh.Ma_Khach_Hang
                LEFT JOIN TAIXE   tx ON cx.Ma_Tai_Xe    = tx.Ma_Tai_Xe
                LEFT JOIN BANGGIA bg ON cx.Ma_Bang_Gia   = bg.Ma_Bang_Gia
            """
            if status_filter:
                sql += " WHERE cx.Trang_Thai = %s"
                sql += " ORDER BY cx.Thoi_Gian_Tao DESC"
                cursor.execute(sql, [status_filter])
            else:
                sql += " ORDER BY cx.Thoi_Gian_Tao DESC"
                cursor.execute(sql)

            trips_list = _fetchall_as_dicts(cursor)
            context['trips'] = [_enrich_trip(r) for r in trips_list]
            context['total'] = len(trips_list)

    except Exception as e:
        context['db_error'] = str(e)

    return render(request, 'booking/trips.html', context)


# --------------------------------------------------------------- Phase 3 helpers

def _fmt_rows(rows, money_cols=()):
    """Format money columns as VND strings; replace None with em-dash."""
    out = []
    for raw in rows:
        row = {}
        for k, v in raw.items():
            if k in money_cols:
                row[k] = _fmt_vnd(v)
            elif v is None:
                row[k] = '—'
            else:
                row[k] = v
        out.append(row)
    return out


def _load_options(cursor, sql):
    cursor.execute(sql)
    return [(r[0], r[1]) for r in cursor.fetchall()]


# --------------------------------------------------------------- SP metadata

_SP_META = {
    'sp_DatXe': {
        'label': 'Đặt xe mới',
        'icon': 'bi-car-front-fill',
        'nghiep_vu': (
            'Khách hàng xác nhận đặt xe. Hệ thống kiểm tra số dư ví, '
            'trừ tiền tạm giữ từ ví khách hàng, tạo cuốc xe mới (trạng thái "Chờ nhận") '
            'và ghi nhận lịch sử giao dịch. SP trả về mã cuốc xe vừa tạo qua OUTPUT parameter.'
        ),
        'sql_display': (
            "DECLARE @out CHAR(10);\n"
            "EXEC dbo.sp_DatXe\n"
            "    @Ma_Khach_Hang  = 'KH001',\n"
            "    @Ma_Bang_Gia    = 'BG001',\n"
            "    @Khoang_Cach    = 5.5,\n"
            "    @Gia_Uoc_Tinh   = 55000,\n"
            "    @Ma_Cuoc_Xe_Out = @out OUTPUT;\n"
            "SELECT @out AS Ma_Cuoc_Xe_Moi;"
        ),
        'before_label': 'Số dư ví khách hàng (trước đặt xe)',
        'before_sql': """
            SELECT kh.Ma_Khach_Hang     AS [Mã KH],
                   kh.Ten_Khach_Hang    AS [Tên khách hàng],
                   kh.Trang_Thai        AS [Trạng thái],
                   ISNULL(v.So_Du, 0)   AS [Số dư ví]
            FROM KHACHHANG kh
            LEFT JOIN VIDIENTU v
                   ON kh.Ma_Khach_Hang = v.Ma_Chu_So_Huu
                  AND v.Loai_Chu_So_Huu = 'Khach hang'
            WHERE kh.Trang_Thai = 'Hoat dong'
            ORDER BY kh.Ma_Khach_Hang
        """,
        'before_money': ['Số dư ví'],
        'after_label': '5 cuốc xe mới nhất + số dư ví khách hàng (sau đặt xe)',
        'after_sql': """
            SELECT TOP 5
                cx.Ma_Cuoc_Xe                              AS [Mã cuốc],
                kh.Ten_Khach_Hang                          AS [Khách hàng],
                cx.Khoang_Cach                             AS [Km],
                cx.Gia_Uoc_Tinh                            AS [Giá ước tính],
                cx.Trang_Thai                              AS [Trạng thái],
                ISNULL(v.So_Du, 0)                         AS [Số dư ví KH],
                CONVERT(VARCHAR(16), cx.Thoi_Gian_Tao, 120) AS [Thời gian]
            FROM CUOCXE cx
            JOIN KHACHHANG kh ON cx.Ma_Khach_Hang = kh.Ma_Khach_Hang
            LEFT JOIN VIDIENTU v
                   ON kh.Ma_Khach_Hang = v.Ma_Chu_So_Huu
                  AND v.Loai_Chu_So_Huu = 'Khach hang'
            ORDER BY cx.Thoi_Gian_Tao DESC
        """,
        'after_money': ['Giá ước tính', 'Số dư ví KH'],
        'fields': [
            {'name': 'ma_kh', 'label': 'Khách hàng', 'type': 'select',
             'options_sql': (
                 "SELECT Ma_Khach_Hang, Ten_Khach_Hang + ' (' + Ma_Khach_Hang + ')' "
                 "FROM KHACHHANG WHERE Trang_Thai = 'Hoat dong' ORDER BY Ma_Khach_Hang"
             ), 'options': []},
            {'name': 'ma_bg', 'label': 'Bảng giá', 'type': 'select',
             'options_sql': (
                 "SELECT Ma_Bang_Gia, Ma_Bang_Gia + ' — ' + Loai_Xe + ' / ' + Khung_Gio "
                 "+ ' (base: ' + CAST(CAST(Gia_Co_Ban AS BIGINT) AS VARCHAR) + 'đ)' "
                 "FROM BANGGIA ORDER BY Ma_Bang_Gia"
             ), 'options': []},
            {'name': 'khoang_cach', 'label': 'Khoảng cách (km)', 'type': 'number',
             'step': '0.1', 'min': '0.1', 'placeholder': 'VD: 5.5'},
            {'name': 'gia_uoc_tinh', 'label': 'Giá ước tính (đ)', 'type': 'number',
             'min': '1000', 'step': '1000', 'placeholder': 'VD: 55000'},
        ],
    },
    'sp_NhanCuocXe': {
        'label': 'Nhận cuốc xe',
        'icon': 'bi-person-check-fill',
        'nghiep_vu': (
            'Tài xế chọn nhận một cuốc xe đang chờ. Hệ thống áp dụng UPDLOCK để chống '
            'race condition — đảm bảo chỉ đúng một tài xế nhận được cuốc. '
            'Cuốc xe chuyển "Đã nhận", tài xế chuyển "Đang bận".'
        ),
        'sql_display': (
            "EXEC dbo.sp_NhanCuocXe\n"
            "    @Ma_Cuoc_Xe = 'CX001',\n"
            "    @Ma_Tai_Xe  = 'TX001';"
        ),
        'before_label': 'Cuốc xe đang "Chờ nhận" + tài xế đang "Sẵn sàng"',
        'before_sql': """
            SELECT cx.Ma_Cuoc_Xe                              AS [Mã cuốc],
                   kh.Ten_Khach_Hang                          AS [Khách hàng],
                   cx.Khoang_Cach                             AS [Km],
                   cx.Gia_Uoc_Tinh                            AS [Giá ước tính],
                   cx.Trang_Thai                              AS [TT cuốc]
            FROM CUOCXE cx
            JOIN KHACHHANG kh ON cx.Ma_Khach_Hang = kh.Ma_Khach_Hang
            WHERE cx.Trang_Thai = 'Cho nhan'
            ORDER BY cx.Thoi_Gian_Tao
        """,
        'before_money': ['Giá ước tính'],
        'after_label': 'Trạng thái cuốc xe + tài xế sau khi nhận',
        'after_sql': """
            SELECT TOP 5
                cx.Ma_Cuoc_Xe                              AS [Mã cuốc],
                kh.Ten_Khach_Hang                          AS [Khách hàng],
                ISNULL(tx.Ten_Tai_Xe, N'—')                AS [Tài xế],
                cx.Trang_Thai                              AS [TT cuốc],
                ISNULL(tx.Trang_Thai, '—')                 AS [TT tài xế]
            FROM CUOCXE cx
            JOIN KHACHHANG kh ON cx.Ma_Khach_Hang = kh.Ma_Khach_Hang
            LEFT JOIN TAIXE tx ON cx.Ma_Tai_Xe = tx.Ma_Tai_Xe
            WHERE cx.Trang_Thai IN ('Da nhan', 'Dang chay', 'Hoan thanh')
            ORDER BY cx.Thoi_Gian_Tao DESC
        """,
        'after_money': [],
        'fields': [
            {'name': 'ma_cx', 'label': 'Cuốc xe (Chờ nhận)', 'type': 'select',
             'options_sql': (
                 "SELECT cx.Ma_Cuoc_Xe, "
                 "cx.Ma_Cuoc_Xe + ' — ' + kh.Ten_Khach_Hang + ' (' + CAST(cx.Khoang_Cach AS VARCHAR) + ' km)' "
                 "FROM CUOCXE cx JOIN KHACHHANG kh ON cx.Ma_Khach_Hang = kh.Ma_Khach_Hang "
                 "WHERE cx.Trang_Thai = 'Cho nhan' ORDER BY cx.Thoi_Gian_Tao"
             ), 'options': []},
            {'name': 'ma_tx', 'label': 'Tài xế (Sẵn sàng)', 'type': 'select',
             'options_sql': (
                 "SELECT Ma_Tai_Xe, Ten_Tai_Xe + ' (' + Ma_Tai_Xe + ')' "
                 "FROM TAIXE WHERE Trang_Thai = 'San sang' ORDER BY Ma_Tai_Xe"
             ), 'options': []},
        ],
    },
    'sp_HoanThanhChuyen': {
        'label': 'Hoàn thành chuyến',
        'icon': 'bi-check-circle-fill',
        'nghiep_vu': (
            'Tài xế xác nhận hoàn thành chuyến. Hệ thống cập nhật cuốc xe → "Hoàn thành", '
            'cộng doanh thu vào ví tài xế, ghi LICHSUGIAODICH, cập nhật tài xế → "Sẵn sàng". '
            'Trigger trg_ThongBaoTrangThai và trg_KiemTraSoDuTruocGiaoDich tự động kích hoạt.'
        ),
        'sql_display': "EXEC dbo.sp_HoanThanhChuyen @Ma_Cuoc_Xe = 'CX001';",
        'before_label': 'Cuốc xe đang chạy + số dư ví tài xế (trước hoàn thành)',
        'before_sql': """
            SELECT cx.Ma_Cuoc_Xe                            AS [Mã cuốc],
                   kh.Ten_Khach_Hang                        AS [Khách hàng],
                   ISNULL(tx.Ten_Tai_Xe, N'—')              AS [Tài xế],
                   cx.Khoang_Cach                           AS [Km],
                   cx.Gia_Uoc_Tinh                          AS [Giá ước tính],
                   cx.Trang_Thai                            AS [TT cuốc],
                   ISNULL(v.So_Du, 0)                       AS [Số dư ví TX]
            FROM CUOCXE cx
            JOIN KHACHHANG kh ON cx.Ma_Khach_Hang = kh.Ma_Khach_Hang
            LEFT JOIN TAIXE tx ON cx.Ma_Tai_Xe = tx.Ma_Tai_Xe
            LEFT JOIN VIDIENTU v
                   ON tx.Ma_Tai_Xe = v.Ma_Chu_So_Huu
                  AND v.Loai_Chu_So_Huu = 'Tai xe'
            WHERE cx.Trang_Thai IN ('Dang chay', 'Da nhan')
            ORDER BY cx.Thoi_Gian_Tao
        """,
        'before_money': ['Giá ước tính', 'Số dư ví TX'],
        'after_label': '5 cuốc hoàn thành gần nhất + số dư ví tài xế (sau hoàn thành)',
        'after_sql': """
            SELECT TOP 5
                cx.Ma_Cuoc_Xe                               AS [Mã cuốc],
                ISNULL(tx.Ten_Tai_Xe, N'—')                 AS [Tài xế],
                cx.Tong_Tien                                AS [Thực thu],
                cx.Trang_Thai                               AS [TT cuốc],
                ISNULL(tx.Trang_Thai, '—')                  AS [TT tài xế],
                ISNULL(v.So_Du, 0)                          AS [Số dư ví TX]
            FROM CUOCXE cx
            LEFT JOIN TAIXE tx ON cx.Ma_Tai_Xe = tx.Ma_Tai_Xe
            LEFT JOIN VIDIENTU v
                   ON tx.Ma_Tai_Xe = v.Ma_Chu_So_Huu
                  AND v.Loai_Chu_So_Huu = 'Tai xe'
            WHERE cx.Trang_Thai = 'Hoan thanh'
            ORDER BY cx.Thoi_Gian_Tao DESC
        """,
        'after_money': ['Thực thu', 'Số dư ví TX'],
        'fields': [
            {'name': 'ma_cx', 'label': 'Cuốc xe (Đang chạy / Đã nhận)', 'type': 'select',
             'options_sql': (
                 "SELECT cx.Ma_Cuoc_Xe, "
                 "cx.Ma_Cuoc_Xe + ' — ' + ISNULL(tx.Ten_Tai_Xe, '?') + ' (' + cx.Trang_Thai + ')' "
                 "FROM CUOCXE cx LEFT JOIN TAIXE tx ON cx.Ma_Tai_Xe = tx.Ma_Tai_Xe "
                 "WHERE cx.Trang_Thai IN ('Dang chay', 'Da nhan') ORDER BY cx.Thoi_Gian_Tao"
             ), 'options': []},
        ],
    },
    'sp_HuyChuyen': {
        'label': 'Hủy chuyến',
        'icon': 'bi-x-circle-fill',
        'nghiep_vu': (
            'Khách hàng hoặc tài xế yêu cầu hủy chuyến. Hệ thống dùng UPDLOCK để tránh '
            'xung đột đồng thời, hoàn tiền vào ví khách hàng, giải phóng tài xế (nếu đã nhận), '
            'cập nhật cuốc xe → "Đã hủy". Trigger trg_ThongBaoTrangThai tự động kích hoạt.'
        ),
        'sql_display': "EXEC dbo.sp_HuyChuyen @Ma_Cuoc_Xe = 'CX001';",
        'before_label': 'Cuốc xe có thể hủy + số dư ví khách hàng (trước hủy)',
        'before_sql': """
            SELECT cx.Ma_Cuoc_Xe                            AS [Mã cuốc],
                   kh.Ten_Khach_Hang                        AS [Khách hàng],
                   cx.Gia_Uoc_Tinh                          AS [Giá ước tính],
                   cx.Trang_Thai                            AS [TT cuốc],
                   ISNULL(v.So_Du, 0)                       AS [Số dư ví KH]
            FROM CUOCXE cx
            JOIN KHACHHANG kh ON cx.Ma_Khach_Hang = kh.Ma_Khach_Hang
            LEFT JOIN VIDIENTU v
                   ON kh.Ma_Khach_Hang = v.Ma_Chu_So_Huu
                  AND v.Loai_Chu_So_Huu = 'Khach hang'
            WHERE cx.Trang_Thai IN ('Cho nhan', 'Da nhan')
            ORDER BY cx.Thoi_Gian_Tao
        """,
        'before_money': ['Giá ước tính', 'Số dư ví KH'],
        'after_label': '5 cuốc đã hủy gần nhất + số dư ví khách hàng (sau hoàn tiền)',
        'after_sql': """
            SELECT TOP 5
                cx.Ma_Cuoc_Xe                               AS [Mã cuốc],
                kh.Ten_Khach_Hang                           AS [Khách hàng],
                cx.Gia_Uoc_Tinh                             AS [Giá ước tính],
                cx.Trang_Thai                               AS [TT cuốc],
                ISNULL(v.So_Du, 0)                          AS [Số dư ví KH],
                CONVERT(VARCHAR(16), cx.Thoi_Gian_Tao, 120) AS [Thời gian]
            FROM CUOCXE cx
            JOIN KHACHHANG kh ON cx.Ma_Khach_Hang = kh.Ma_Khach_Hang
            LEFT JOIN VIDIENTU v
                   ON kh.Ma_Khach_Hang = v.Ma_Chu_So_Huu
                  AND v.Loai_Chu_So_Huu = 'Khach hang'
            WHERE cx.Trang_Thai = 'Da huy'
            ORDER BY cx.Thoi_Gian_Tao DESC
        """,
        'after_money': ['Giá ước tính', 'Số dư ví KH'],
        'fields': [
            {'name': 'ma_cx', 'label': 'Cuốc xe (Chờ nhận / Đã nhận)', 'type': 'select',
             'options_sql': (
                 "SELECT cx.Ma_Cuoc_Xe, "
                 "cx.Ma_Cuoc_Xe + ' — ' + kh.Ten_Khach_Hang + ' (' + cx.Trang_Thai + ')' "
                 "FROM CUOCXE cx JOIN KHACHHANG kh ON cx.Ma_Khach_Hang = kh.Ma_Khach_Hang "
                 "WHERE cx.Trang_Thai IN ('Cho nhan', 'Da nhan') ORDER BY cx.Thoi_Gian_Tao"
             ), 'options': []},
        ],
    },
    'sp_NapTienVi': {
        'label': 'Nạp tiền ví',
        'icon': 'bi-wallet2',
        'nghiep_vu': (
            'Khách hàng hoặc tài xế nạp tiền vào ví điện tử. '
            'Hệ thống cộng số dư vào VIDIENTU và ghi nhận lịch sử giao dịch vào LICHSUGIAODICH.'
        ),
        'sql_display': (
            "EXEC dbo.sp_NapTienVi\n"
            "    @Ma_Chu_So_Huu   = 'KH001',\n"
            "    @Loai_Chu_So_Huu = 'Khach hang',\n"
            "    @So_Tien         = 500000;"
        ),
        'before_label': 'Số dư ví tất cả tài khoản (trước nạp tiền)',
        'before_sql': """
            SELECT v.Ma_Chu_So_Huu      AS [Mã CSH],
                   v.Loai_Chu_So_Huu   AS [Loại ví],
                   CASE v.Loai_Chu_So_Huu
                       WHEN 'Khach hang' THEN kh.Ten_Khach_Hang
                       WHEN 'Tai xe'     THEN tx.Ten_Tai_Xe
                   END                 AS [Tên],
                   v.So_Du             AS [Số dư]
            FROM VIDIENTU v
            LEFT JOIN KHACHHANG kh
                   ON v.Ma_Chu_So_Huu = kh.Ma_Khach_Hang
                  AND v.Loai_Chu_So_Huu = 'Khach hang'
            LEFT JOIN TAIXE tx
                   ON v.Ma_Chu_So_Huu = tx.Ma_Tai_Xe
                  AND v.Loai_Chu_So_Huu = 'Tai xe'
            ORDER BY v.Loai_Chu_So_Huu, v.Ma_Chu_So_Huu
        """,
        'before_money': ['Số dư'],
        'after_label': 'Số dư ví tất cả tài khoản (sau nạp tiền)',
        'after_sql': """
            SELECT v.Ma_Chu_So_Huu      AS [Mã CSH],
                   v.Loai_Chu_So_Huu   AS [Loại ví],
                   CASE v.Loai_Chu_So_Huu
                       WHEN 'Khach hang' THEN kh.Ten_Khach_Hang
                       WHEN 'Tai xe'     THEN tx.Ten_Tai_Xe
                   END                 AS [Tên],
                   v.So_Du             AS [Số dư]
            FROM VIDIENTU v
            LEFT JOIN KHACHHANG kh
                   ON v.Ma_Chu_So_Huu = kh.Ma_Khach_Hang
                  AND v.Loai_Chu_So_Huu = 'Khach hang'
            LEFT JOIN TAIXE tx
                   ON v.Ma_Chu_So_Huu = tx.Ma_Tai_Xe
                  AND v.Loai_Chu_So_Huu = 'Tai xe'
            ORDER BY v.Loai_Chu_So_Huu, v.Ma_Chu_So_Huu
        """,
        'after_money': ['Số dư'],
        'fields': [
            {'name': 'ma_chu', 'label': 'Mã chủ sở hữu', 'type': 'text',
             'placeholder': 'VD: KH001 hoặc TX001'},
            {'name': 'loai', 'label': 'Loại ví', 'type': 'select',
             'options': [('Khach hang', 'Khách hàng'), ('Tai xe', 'Tài xế')]},
            {'name': 'so_tien', 'label': 'Số tiền (đ)', 'type': 'number',
             'min': '1000', 'step': '1000', 'placeholder': 'VD: 500000'},
        ],
    },
}


def _exec_sp(cursor, tab, post):
    if tab == 'sp_DatXe':
        cursor.execute("""
            DECLARE @out CHAR(10);
            EXEC dbo.sp_DatXe
                @Ma_Khach_Hang  = %s,
                @Ma_Bang_Gia    = %s,
                @Khoang_Cach    = %s,
                @Gia_Uoc_Tinh   = %s,
                @Ma_Cuoc_Xe_Out = @out OUTPUT;
            SELECT @out;
        """, [post.get('ma_kh', '').strip(),
              post.get('ma_bg', '').strip(),
              float(post.get('khoang_cach', 0) or 0),
              float(post.get('gia_uoc_tinh', 0) or 0)])
        row = cursor.fetchone()
        ma_moi = row[0] if row else '?'
        return f'Đặt xe thành công! Mã cuốc xe mới: <strong>{ma_moi}</strong>'

    elif tab == 'sp_NhanCuocXe':
        ma_cx = post.get('ma_cx', '').strip()
        ma_tx = post.get('ma_tx', '').strip()
        cursor.execute("EXEC dbo.sp_NhanCuocXe @Ma_Cuoc_Xe=%s, @Ma_Tai_Xe=%s", [ma_cx, ma_tx])
        return f'Tài xế <strong>{ma_tx}</strong> đã nhận cuốc xe <strong>{ma_cx}</strong>.'

    elif tab == 'sp_HoanThanhChuyen':
        ma_cx = post.get('ma_cx', '').strip()
        cursor.execute("EXEC dbo.sp_HoanThanhChuyen @Ma_Cuoc_Xe=%s", [ma_cx])
        return f'Cuốc xe <strong>{ma_cx}</strong> đã hoàn thành. Doanh thu đã cộng vào ví tài xế.'

    elif tab == 'sp_HuyChuyen':
        ma_cx = post.get('ma_cx', '').strip()
        cursor.execute("EXEC dbo.sp_HuyChuyen @Ma_Cuoc_Xe=%s", [ma_cx])
        return f'Cuốc xe <strong>{ma_cx}</strong> đã hủy. Tiền đã hoàn vào ví khách hàng.'

    elif tab == 'sp_NapTienVi':
        ma_chu = post.get('ma_chu', '').strip()
        loai   = post.get('loai', '').strip()
        so_tien = float(post.get('so_tien', 0) or 0)
        cursor.execute(
            "EXEC dbo.sp_NapTienVi @Ma_Chu_So_Huu=%s, @Loai_Chu_So_Huu=%s, @So_Tien=%s",
            [ma_chu, loai, so_tien])
        return f'Nạp <strong>{_fmt_vnd(so_tien)}</strong> vào ví <strong>{ma_chu}</strong> thành công.'

    return 'Thực thi thành công.'


# --------------------------------------------------------------- demo: procedures

def demo_procedures(request):
    tab = request.GET.get('tab', 'sp_DatXe')
    if tab not in _SP_META:
        tab = 'sp_DatXe'

    sp = copy.deepcopy(_SP_META[tab])
    context = {'sp_meta': _SP_META, 'tab': tab, 'sp': sp}

    try:
        with connection.cursor() as cursor:
            # Load select options from DB
            for f in sp['fields']:
                if f['type'] == 'select' and 'options_sql' in f:
                    f['options'] = _load_options(cursor, f['options_sql'])

            if request.method == 'POST':
                # Capture BEFORE (before execution)
                cursor.execute(sp['before_sql'])
                context['before_rows'] = _fmt_rows(
                    _fetchall_as_dicts(cursor), sp['before_money'])
                context['before_cols'] = (
                    list(context['before_rows'][0].keys()) if context['before_rows'] else [])

                # Execute SP
                try:
                    context['exec_result'] = _exec_sp(cursor, tab, request.POST)
                    context['exec_ok'] = True
                except Exception as e:
                    context['exec_error'] = str(e)

                # Capture AFTER (after execution)
                cursor.execute(sp['after_sql'])
                context['after_rows'] = _fmt_rows(
                    _fetchall_as_dicts(cursor), sp['after_money'])
                context['after_cols'] = (
                    list(context['after_rows'][0].keys()) if context['after_rows'] else [])

            else:
                # GET: only BEFORE data
                cursor.execute(sp['before_sql'])
                context['before_rows'] = _fmt_rows(
                    _fetchall_as_dicts(cursor), sp['before_money'])
                context['before_cols'] = (
                    list(context['before_rows'][0].keys()) if context['before_rows'] else [])

    except Exception as e:
        context['db_error'] = str(e)

    return render(request, 'booking/demo_procedures.html', context)


# --------------------------------------------------------------- Trigger metadata

_TRG_META = {
    'trg_CapNhatDiemUyTin': {
        'label': 'Cập nhật điểm uy tín',
        'icon': 'bi-star-fill',
        'nghiep_vu': (
            'Sau khi khách hàng gửi đánh giá 1 sao, trigger tự động kiểm tra: '
            'nếu tài xế tích lũy từ 3 đánh giá 1 sao trong ngày → trạng thái chuyển sang "Bị đình chỉ". '
            'Đây là cơ chế bảo vệ chất lượng dịch vụ tự động ở tầng database.'
        ),
        'sql_display': (
            "-- AFTER INSERT on DANHGIA\n"
            "IF EXISTS (\n"
            "    SELECT C.Ma_Tai_Xe FROM DANHGIA D\n"
            "    JOIN CUOCXE C ON D.Ma_Cuoc_Xe = C.Ma_Cuoc_Xe\n"
            "    WHERE C.Ma_Tai_Xe IN (\n"
            "        SELECT CX.Ma_Tai_Xe FROM inserted i\n"
            "        JOIN CUOCXE CX ON i.Ma_Cuoc_Xe = CX.Ma_Cuoc_Xe\n"
            "        WHERE i.Diem_Danh_Gia = 1\n"
            "    )\n"
            "    AND D.Diem_Danh_Gia = 1\n"
            "    AND CAST(D.Thoi_Gian_Danh_Gia AS DATE) = CAST(GETDATE() AS DATE)\n"
            "    GROUP BY C.Ma_Tai_Xe HAVING COUNT(D.Ma_Danh_Gia) >= 3\n"
            ")\n"
            "    UPDATE TAIXE SET Trang_Thai = 'Bi dinh chi' WHERE Ma_Tai_Xe IN (...);"
        ),
        'dml_label': 'INSERT đánh giá 1 sao → trigger tự kiểm tra',
        'dml_sql': (
            "INSERT INTO DANHGIA\n"
            "  (Ma_Danh_Gia, Ma_Cuoc_Xe, Diem_Danh_Gia, Noi_Dung, Thoi_Gian_Danh_Gia)\n"
            "VALUES\n"
            "  ('DG' + RIGHT(CAST(NEWID() AS VARCHAR(36)), 8),\n"
            "   'CX001', 1, N'Demo: 1 sao', GETDATE());"
        ),
        'before_label': 'Trạng thái tài xế + số đánh giá 1 sao hôm nay',
        'before_sql': """
            SELECT tx.Ma_Tai_Xe                                          AS [Mã TX],
                   tx.Ten_Tai_Xe                                         AS [Tên tài xế],
                   tx.Trang_Thai                                         AS [Trạng thái],
                   COUNT(dg.Ma_Danh_Gia)                                 AS [Đánh giá 1 sao hôm nay]
            FROM TAIXE tx
            LEFT JOIN CUOCXE cx  ON cx.Ma_Tai_Xe = tx.Ma_Tai_Xe
            LEFT JOIN DANHGIA dg ON dg.Ma_Cuoc_Xe = cx.Ma_Cuoc_Xe
                AND dg.Diem_Danh_Gia = 1
                AND CAST(dg.Thoi_Gian_Danh_Gia AS DATE) = CAST(GETDATE() AS DATE)
            GROUP BY tx.Ma_Tai_Xe, tx.Ten_Tai_Xe, tx.Trang_Thai
            ORDER BY tx.Ma_Tai_Xe
        """,
        'before_money': [],
        'after_label': 'Trạng thái tài xế + số đánh giá 1 sao hôm nay (sau trigger)',
        'after_sql': """
            SELECT tx.Ma_Tai_Xe                                          AS [Mã TX],
                   tx.Ten_Tai_Xe                                         AS [Tên tài xế],
                   tx.Trang_Thai                                         AS [Trạng thái],
                   COUNT(dg.Ma_Danh_Gia)                                 AS [Đánh giá 1 sao hôm nay]
            FROM TAIXE tx
            LEFT JOIN CUOCXE cx  ON cx.Ma_Tai_Xe = tx.Ma_Tai_Xe
            LEFT JOIN DANHGIA dg ON dg.Ma_Cuoc_Xe = cx.Ma_Cuoc_Xe
                AND dg.Diem_Danh_Gia = 1
                AND CAST(dg.Thoi_Gian_Danh_Gia AS DATE) = CAST(GETDATE() AS DATE)
            GROUP BY tx.Ma_Tai_Xe, tx.Ten_Tai_Xe, tx.Trang_Thai
            ORDER BY tx.Ma_Tai_Xe
        """,
        'after_money': [],
        'fields': [
            {'name': 'ma_cx', 'label': 'Cuốc xe hoàn thành (chưa có đánh giá)', 'type': 'select',
             'options_sql': (
                 "SELECT cx.Ma_Cuoc_Xe, "
                 "cx.Ma_Cuoc_Xe + ' — ' + ISNULL(tx.Ten_Tai_Xe,'?') + ' / ' + kh.Ten_Khach_Hang "
                 "FROM CUOCXE cx "
                 "JOIN KHACHHANG kh ON cx.Ma_Khach_Hang = kh.Ma_Khach_Hang "
                 "LEFT JOIN TAIXE tx ON cx.Ma_Tai_Xe = tx.Ma_Tai_Xe "
                 "WHERE cx.Trang_Thai = 'Hoan thanh' "
                 "AND NOT EXISTS (SELECT 1 FROM DANHGIA dg WHERE dg.Ma_Cuoc_Xe = cx.Ma_Cuoc_Xe) "
                 "ORDER BY cx.Thoi_Gian_Tao DESC"
             ), 'options': []},
        ],
        'exec_fn': 'trg_DanhGia',
    },
    'trg_KiemTraSoDuTruocGiaoDich': {
        'label': 'Kiểm tra số dư',
        'icon': 'bi-exclamation-triangle-fill',
        'nghiep_vu': (
            'Khi cuốc xe chuyển trạng thái → "Hoàn thành", trigger tự kiểm tra ví khách hàng. '
            'Nếu số dư < 10.000đ → INSERT THONGBAO cảnh báo cho khách. '
            'Đây là lớp cảnh báo tự động, không chặn giao dịch.'
        ),
        'sql_display': (
            "-- AFTER UPDATE on CUOCXE\n"
            "-- (Kích hoạt bởi sp_HoanThanhChuyen)\n"
            "INSERT INTO THONGBAO (...)\n"
            "SELECT ... FROM inserted i\n"
            "JOIN VIDIENTU V ON i.Ma_Khach_Hang = V.Ma_Chu_So_Huu\n"
            "WHERE i.Trang_Thai = 'Hoan thanh'\n"
            "  AND d.Trang_Thai <> 'Hoan thanh'\n"
            "  AND V.So_Du < 10000;"
        ),
        'dml_label': 'EXEC sp_HoanThanhChuyen → trigger tự kích hoạt',
        'dml_sql': "EXEC dbo.sp_HoanThanhChuyen @Ma_Cuoc_Xe = 'CX001';",
        'before_label': 'Cuốc xe đang chạy + số dư ví KH + số THONGBAO (trước)',
        'before_sql': """
            SELECT cx.Ma_Cuoc_Xe                              AS [Mã cuốc],
                   kh.Ten_Khach_Hang                          AS [Khách hàng],
                   ISNULL(v.So_Du, 0)                         AS [Số dư ví KH],
                   cx.Trang_Thai                              AS [TT cuốc],
                   (SELECT COUNT(*) FROM THONGBAO tb
                    WHERE tb.Ma_Nguoi_Nhan = kh.Ma_Khach_Hang) AS [Tổng THONGBAO]
            FROM CUOCXE cx
            JOIN KHACHHANG kh ON cx.Ma_Khach_Hang = kh.Ma_Khach_Hang
            LEFT JOIN VIDIENTU v
                   ON kh.Ma_Khach_Hang = v.Ma_Chu_So_Huu
                  AND v.Loai_Chu_So_Huu = 'Khach hang'
            WHERE cx.Trang_Thai IN ('Dang chay', 'Da nhan')
            ORDER BY v.So_Du
        """,
        'before_money': ['Số dư ví KH'],
        'after_label': 'Số dư ví KH + THONGBAO mới nhất (trigger đã chạy)',
        'after_sql': """
            SELECT TOP 5
                tb.Tieu_De                                    AS [Tiêu đề],
                tb.Ma_Nguoi_Nhan                              AS [Gửi đến],
                tb.Trang_Thai_Doc                             AS [Đã đọc],
                CONVERT(VARCHAR(16), tb.Thoi_Gian_Gui, 120)  AS [Thời gian]
            FROM THONGBAO tb
            ORDER BY tb.Thoi_Gian_Gui DESC
        """,
        'after_money': [],
        'fields': [
            {'name': 'ma_cx', 'label': 'Cuốc xe (Đang chạy / Đã nhận)', 'type': 'select',
             'options_sql': (
                 "SELECT cx.Ma_Cuoc_Xe, "
                 "cx.Ma_Cuoc_Xe + ' — ' + kh.Ten_Khach_Hang + ' (ví: ' + "
                 "ISNULL(CAST(CAST(v.So_Du AS BIGINT) AS VARCHAR),'?') + 'đ)' "
                 "FROM CUOCXE cx "
                 "JOIN KHACHHANG kh ON cx.Ma_Khach_Hang = kh.Ma_Khach_Hang "
                 "LEFT JOIN VIDIENTU v ON kh.Ma_Khach_Hang = v.Ma_Chu_So_Huu AND v.Loai_Chu_So_Huu = 'Khach hang' "
                 "WHERE cx.Trang_Thai IN ('Dang chay','Da nhan') ORDER BY v.So_Du"
             ), 'options': []},
        ],
        'exec_fn': 'trg_HoanThanh',
    },
    'trg_CapNhatLuotVoucher': {
        'label': 'Cập nhật lượt voucher',
        'icon': 'bi-ticket-perforated-fill',
        'nghiep_vu': (
            'Khi cuốc xe có sử dụng voucher chuyển sang "Hoàn thành", trigger tự động '
            'tăng So_Luot_Da_Dung của voucher đó. Giúp hệ thống theo dõi lượt dùng mà không cần '
            'lập trình thêm ở tầng ứng dụng.'
        ),
        'sql_display': (
            "-- AFTER UPDATE on CUOCXE\n"
            "-- (Kích hoạt bởi sp_HoanThanhChuyen)\n"
            "UPDATE V SET V.So_Luot_Da_Dung = ISNULL(V.So_Luot_Da_Dung, 0) + 1\n"
            "FROM VOUCHER V\n"
            "JOIN inserted i ON V.Ma_Voucher = i.Ma_Voucher\n"
            "JOIN deleted  d ON i.Ma_Cuoc_Xe = d.Ma_Cuoc_Xe\n"
            "WHERE i.Trang_Thai = 'Hoan thanh'\n"
            "  AND d.Trang_Thai <> 'Hoan thanh'\n"
            "  AND i.Ma_Voucher IS NOT NULL;"
        ),
        'dml_label': 'Tự động: tạo trip + gắn voucher + hoàn thành → trigger cập nhật lượt',
        'dml_sql': (
            "-- Hệ thống tự tạo cuốc xe demo có voucher rồi hoàn thành:\n"
            "EXEC dbo.sp_DatXe ... → UPDATE CUOCXE SET Ma_Voucher=? → sp_NhanCuocXe → sp_HoanThanhChuyen\n"
            "-- Trigger tự chạy khi CUOCXE.Trang_Thai → 'Hoan thanh' AND Ma_Voucher IS NOT NULL"
        ),
        'before_label': 'Trạng thái voucher trước khi hoàn thành cuốc xe',
        'before_sql': """
            SELECT v.Ma_Voucher                               AS [Mã voucher],
                   v.Ma_Code                                  AS [Code],
                   v.Loai_Giam_Gia                            AS [Loại giảm],
                   v.Gia_Tri_Giam                             AS [Giá trị giảm],
                   ISNULL(v.So_Luot_Da_Dung, 0)              AS [Lượt đã dùng],
                   v.So_Luot_Toi_Da                           AS [Tối đa],
                   v.Trang_Thai                               AS [Trạng thái]
            FROM VOUCHER v
            ORDER BY v.Ma_Voucher
        """,
        'before_money': ['Giá trị giảm'],
        'after_label': 'Lượt sử dụng voucher sau khi trigger cập nhật',
        'after_sql': """
            SELECT v.Ma_Voucher                               AS [Mã voucher],
                   v.Ma_Code                                  AS [Code],
                   v.Loai_Giam_Gia                            AS [Loại giảm],
                   v.Gia_Tri_Giam                             AS [Giá trị giảm],
                   ISNULL(v.So_Luot_Da_Dung, 0)              AS [Lượt đã dùng],
                   v.So_Luot_Toi_Da                           AS [Tối đa],
                   v.Trang_Thai                               AS [Trạng thái]
            FROM VOUCHER v
            ORDER BY v.Ma_Voucher
        """,
        'after_money': ['Giá trị giảm'],
        'fields': [
            {'name': 'ma_voucher', 'label': 'Voucher sẽ dùng', 'type': 'select',
             'options_sql': (
                 "SELECT Ma_Voucher, Ma_Voucher + ' (' + Ma_Code + ') — '"
                 " + Loai_Giam_Gia "
                 "+ ' (dùng: ' + CAST(ISNULL(So_Luot_Da_Dung,0) AS VARCHAR) + '/' + CAST(So_Luot_Toi_Da AS VARCHAR) + ')' "
                 "FROM VOUCHER WHERE Trang_Thai = 'Dang hoat dong' "
                 "AND ISNULL(So_Luot_Da_Dung,0) < So_Luot_Toi_Da ORDER BY Ma_Voucher"
             ), 'options': []},
        ],
        'exec_fn': 'trg_HoanThanhVoucher',
    },
    'trg_NganXoaCuocXe': {
        'label': 'Ngăn xóa cuốc xe',
        'icon': 'bi-shield-fill-x',
        'nghiep_vu': (
            'Trigger INSTEAD OF DELETE bảo vệ dữ liệu: không cho phép xóa cuốc xe đang '
            '"Đã nhận" hoặc "Đang chạy" — vì đang có giao dịch tài chính và hành trình diễn ra. '
            'Nếu cuốc xe ở trạng thái khác ("Chờ nhận", "Hoàn thành", "Đã hủy") → cho phép xóa.'
        ),
        'sql_display': (
            "-- INSTEAD OF DELETE on CUOCXE\n"
            "IF EXISTS (\n"
            "    SELECT 1 FROM deleted\n"
            "    WHERE Trang_Thai IN ('Da nhan', 'Dang chay')\n"
            ")\n"
            "BEGIN\n"
            "    RAISERROR('Khong the xoa cuoc xe dang trong trang thai...', 16, 1);\n"
            "    ROLLBACK TRANSACTION;\n"
            "    RETURN;\n"
            "END\n"
            "DELETE FROM CUOCXE WHERE Ma_Cuoc_Xe IN (SELECT Ma_Cuoc_Xe FROM deleted);"
        ),
        'dml_label': 'DELETE cuốc xe → trigger quyết định cho phép hay chặn',
        'dml_sql': "DELETE FROM CUOCXE WHERE Ma_Cuoc_Xe = 'CX_DA_NHAN';",
        'before_label': 'Cuốc xe đang "Đã nhận" / "Đang chạy" (sẽ bị chặn xóa)',
        'before_sql': """
            SELECT cx.Ma_Cuoc_Xe                              AS [Mã cuốc],
                   kh.Ten_Khach_Hang                          AS [Khách hàng],
                   ISNULL(tx.Ten_Tai_Xe, N'—')                AS [Tài xế],
                   cx.Trang_Thai                              AS [Trạng thái]
            FROM CUOCXE cx
            JOIN KHACHHANG kh ON cx.Ma_Khach_Hang = kh.Ma_Khach_Hang
            LEFT JOIN TAIXE tx ON cx.Ma_Tai_Xe = tx.Ma_Tai_Xe
            WHERE cx.Trang_Thai IN ('Da nhan', 'Dang chay')
            ORDER BY cx.Thoi_Gian_Tao
        """,
        'before_money': [],
        'after_label': 'Cuốc xe vẫn tồn tại sau khi trigger chặn xóa',
        'after_sql': """
            SELECT cx.Ma_Cuoc_Xe                              AS [Mã cuốc],
                   kh.Ten_Khach_Hang                          AS [Khách hàng],
                   ISNULL(tx.Ten_Tai_Xe, N'—')                AS [Tài xế],
                   cx.Trang_Thai                              AS [Trạng thái]
            FROM CUOCXE cx
            JOIN KHACHHANG kh ON cx.Ma_Khach_Hang = kh.Ma_Khach_Hang
            LEFT JOIN TAIXE tx ON cx.Ma_Tai_Xe = tx.Ma_Tai_Xe
            WHERE cx.Trang_Thai IN ('Da nhan', 'Dang chay')
            ORDER BY cx.Thoi_Gian_Tao
        """,
        'after_money': [],
        'fields': [
            {'name': 'ma_cx', 'label': 'Cuốc xe cần xóa (Đã nhận / Đang chạy)', 'type': 'select',
             'options_sql': (
                 "SELECT cx.Ma_Cuoc_Xe, "
                 "cx.Ma_Cuoc_Xe + ' — ' + kh.Ten_Khach_Hang + ' (' + cx.Trang_Thai + ')' "
                 "FROM CUOCXE cx JOIN KHACHHANG kh ON cx.Ma_Khach_Hang = kh.Ma_Khach_Hang "
                 "WHERE cx.Trang_Thai IN ('Da nhan','Dang chay') ORDER BY cx.Thoi_Gian_Tao"
             ), 'options': []},
        ],
        'exec_fn': 'trg_XoaCuoc',
    },
    'trg_ThongBaoTrangThai': {
        'label': 'Thông báo trạng thái',
        'icon': 'bi-bell-fill',
        'nghiep_vu': (
            'Mỗi khi cuốc xe thay đổi trạng thái, trigger tự động INSERT một THONGBAO '
            'cho khách hàng. Đảm bảo mọi thay đổi đều có notification — không cần lập trình '
            'ở tầng ứng dụng.'
        ),
        'sql_display': (
            "-- AFTER UPDATE on CUOCXE\n"
            "IF UPDATE(Trang_Thai)\n"
            "BEGIN\n"
            "    INSERT INTO THONGBAO (...)\n"
            "    SELECT 'TB' + RIGHT(CAST(NEWID() AS VARCHAR(36)), 8),\n"
            "           'Khach hang', i.Ma_Khach_Hang,\n"
            "           N'Cập nhật chuyến đi',\n"
            "           N'Chuyến đi ' + i.Ma_Cuoc_Xe + ' → ' + i.Trang_Thai,\n"
            "           'Chua doc', GETDATE()\n"
            "    FROM inserted i JOIN deleted d ON i.Ma_Cuoc_Xe = d.Ma_Cuoc_Xe\n"
            "    WHERE i.Trang_Thai <> d.Trang_Thai;\n"
            "END"
        ),
        'dml_label': 'Tự động: tạo trip mới → sp_NhanCuocXe → trigger INSERT THONGBAO',
        'dml_sql': (
            "-- Hệ thống tự tạo cuốc xe demo rồi cho tài xế nhận:\n"
            "EXEC dbo.sp_DatXe ... → EXEC dbo.sp_NhanCuocXe ...\n"
            "-- Trigger kích hoạt khi Trang_Thai thay đổi (Cho nhan → Da nhan)"
        ),
        'before_label': '5 THONGBAO gần nhất (trước khi đổi trạng thái)',
        'before_sql': """
            SELECT TOP 5
                tb.Ma_Thong_Bao                               AS [Mã TB],
                tb.Ma_Nguoi_Nhan                              AS [Gửi đến],
                tb.Tieu_De                                    AS [Tiêu đề],
                tb.Trang_Thai_Doc                             AS [Đọc],
                CONVERT(VARCHAR(16), tb.Thoi_Gian_Gui, 120)  AS [Thời gian]
            FROM THONGBAO tb
            ORDER BY tb.Thoi_Gian_Gui DESC
        """,
        'before_money': [],
        'after_label': '5 THONGBAO gần nhất (trigger vừa INSERT thêm)',
        'after_sql': """
            SELECT TOP 5
                tb.Ma_Thong_Bao                               AS [Mã TB],
                tb.Ma_Nguoi_Nhan                              AS [Gửi đến],
                tb.Tieu_De                                    AS [Tiêu đề],
                tb.Trang_Thai_Doc                             AS [Đọc],
                CONVERT(VARCHAR(16), tb.Thoi_Gian_Gui, 120)  AS [Thời gian]
            FROM THONGBAO tb
            ORDER BY tb.Thoi_Gian_Gui DESC
        """,
        'after_money': [],
        'fields': [
            {'name': 'ma_tx', 'label': 'Tài xế nhận cuốc (Sẵn sàng)', 'type': 'select',
             'options_sql': (
                 "SELECT Ma_Tai_Xe, Ten_Tai_Xe + ' (' + Ma_Tai_Xe + ')' "
                 "FROM TAIXE WHERE Trang_Thai = 'San sang' ORDER BY Ma_Tai_Xe"
             ), 'options': []},
        ],
        'exec_fn': 'trg_NhanCuoc',
    },
}


def _exec_trg(cursor, tab, post):
    if tab == 'trg_CapNhatDiemUyTin':
        ma_cx = post.get('ma_cx', '').strip()
        cursor.execute("""
            INSERT INTO DANHGIA (Ma_Danh_Gia, Ma_Cuoc_Xe, Diem_Danh_Gia, Binh_Luan, Thoi_Gian_Danh_Gia)
            VALUES ('DG' + RIGHT(CAST(NEWID() AS VARCHAR(36)), 8),
                    %s, 1, N'Demo: đánh giá 1 sao', GETDATE())
        """, [ma_cx])
        return (f'INSERT 1 đánh giá 1 sao cho cuốc xe <strong>{ma_cx}</strong>. '
                f'Trigger đã kiểm tra — nếu tài xế đủ 3 lần hôm nay → trạng thái = "Bị đình chỉ".')

    elif tab == 'trg_KiemTraSoDuTruocGiaoDich':
        ma_cx = post.get('ma_cx', '').strip()
        cursor.execute("EXEC dbo.sp_HoanThanhChuyen @Ma_Cuoc_Xe=%s", [ma_cx])
        return (f'Hoàn thành cuốc xe <strong>{ma_cx}</strong>. '
                f'Trigger đã kiểm tra số dư ví KH — nếu < 10.000đ → INSERT THONGBAO cảnh báo.')

    elif tab == 'trg_CapNhatLuotVoucher':
        ma_voucher = post.get('ma_voucher', '').strip()
        # Tìm khách hàng có đủ số dư
        cursor.execute("""
            SELECT TOP 1 kh.Ma_Khach_Hang
            FROM KHACHHANG kh
            JOIN VIDIENTU v ON kh.Ma_Khach_Hang = v.Ma_Chu_So_Huu
                           AND v.Loai_Chu_So_Huu = 'Khach hang'
            WHERE kh.Trang_Thai = 'Hoat dong' AND v.So_Du >= 50000
            ORDER BY kh.Ma_Khach_Hang
        """)
        kh_row = cursor.fetchone()
        if not kh_row:
            raise Exception('Không có khách hàng có đủ số dư (≥ 50.000đ) để tạo chuyến demo.')
        ma_kh = kh_row[0].strip()
        # Tạo cuốc xe mới
        cursor.execute("""
            DECLARE @out CHAR(10);
            EXEC dbo.sp_DatXe
                @Ma_Khach_Hang  = %s,
                @Ma_Bang_Gia    = 'BG001',
                @Khoang_Cach    = 3.0,
                @Gia_Uoc_Tinh   = 30000,
                @Ma_Cuoc_Xe_Out = @out OUTPUT;
            SELECT @out;
        """, [ma_kh])
        out_row = cursor.fetchone()
        if not out_row or not out_row[0]:
            raise Exception('sp_DatXe không trả về mã cuốc xe.')
        ma_cx = out_row[0].strip()
        # Gắn voucher vào cuốc xe
        cursor.execute("UPDATE CUOCXE SET Ma_Voucher = %s WHERE Ma_Cuoc_Xe = %s", [ma_voucher, ma_cx])
        # Tìm tài xế sẵn sàng
        cursor.execute("SELECT TOP 1 Ma_Tai_Xe FROM TAIXE WHERE Trang_Thai = 'San sang' ORDER BY Ma_Tai_Xe")
        tx_row = cursor.fetchone()
        if not tx_row:
            raise Exception('Không có tài xế sẵn sàng để nhận cuốc demo.')
        ma_tx = tx_row[0].strip()
        # Tài xế nhận cuốc → hoàn thành (trigger kích hoạt tại bước này)
        cursor.execute("EXEC dbo.sp_NhanCuocXe @Ma_Cuoc_Xe=%s, @Ma_Tai_Xe=%s", [ma_cx, ma_tx])
        cursor.execute("EXEC dbo.sp_HoanThanhChuyen @Ma_Cuoc_Xe=%s", [ma_cx])
        return (f'Tạo + hoàn thành cuốc xe <strong>{ma_cx}</strong> với voucher <strong>{ma_voucher}</strong>. '
                f'Trigger <code>trg_CapNhatLuotVoucher</code> đã tự động tăng So_Luot_Da_Dung.')

    elif tab == 'trg_NganXoaCuocXe':
        ma_cx = post.get('ma_cx', '').strip()
        cursor.execute("DELETE FROM CUOCXE WHERE Ma_Cuoc_Xe=%s", [ma_cx])
        return (f'DELETE cuốc xe <strong>{ma_cx}</strong> — '
                f'trạng thái cho phép xóa nên đã thực hiện thành công.')

    elif tab == 'trg_ThongBaoTrangThai':
        ma_tx = post.get('ma_tx', '').strip()
        # Auto-create a new trip so we always have a 'Cho nhan' trip to trigger on
        cursor.execute("""
            SELECT TOP 1 kh.Ma_Khach_Hang
            FROM KHACHHANG kh
            JOIN VIDIENTU v ON kh.Ma_Khach_Hang = v.Ma_Chu_So_Huu AND v.Loai_Chu_So_Huu = 'Khach hang'
            WHERE kh.Trang_Thai = 'Hoat dong' AND v.So_Du >= 50000
            ORDER BY kh.Ma_Khach_Hang
        """)
        kh_row = cursor.fetchone()
        if not kh_row:
            raise Exception('Không có khách hàng có đủ số dư để tạo chuyến demo.')
        ma_kh = kh_row[0].strip()
        cursor.execute("""
            DECLARE @out CHAR(10);
            EXEC dbo.sp_DatXe
                @Ma_Khach_Hang  = %s,
                @Ma_Bang_Gia    = 'BG001',
                @Khoang_Cach    = 2.0,
                @Gia_Uoc_Tinh   = 20000,
                @Ma_Cuoc_Xe_Out = @out OUTPUT;
            SELECT @out;
        """, [ma_kh])
        out_row = cursor.fetchone()
        if not out_row or not out_row[0]:
            raise Exception('sp_DatXe không trả về mã cuốc xe.')
        ma_cx = out_row[0].strip()
        # Accept trip → trigger fires (Cho nhan → Da nhan = status change → INSERT THONGBAO)
        cursor.execute("EXEC dbo.sp_NhanCuocXe @Ma_Cuoc_Xe=%s, @Ma_Tai_Xe=%s", [ma_cx, ma_tx])
        return (f'Tạo cuốc xe <strong>{ma_cx}</strong> + tài xế <strong>{ma_tx}</strong> nhận. '
                f'Trigger <code>trg_ThongBaoTrangThai</code> đã INSERT THONGBAO tự động cho khách hàng.')

    return 'Thực thi thành công.'


# --------------------------------------------------------------- demo: triggers

def demo_triggers(request):
    tab = request.GET.get('tab', 'trg_CapNhatDiemUyTin')
    if tab not in _TRG_META:
        tab = 'trg_CapNhatDiemUyTin'

    trg = copy.deepcopy(_TRG_META[tab])
    context = {'trg_meta': _TRG_META, 'tab': tab, 'trg': trg}

    try:
        with connection.cursor() as cursor:
            for f in trg['fields']:
                if f['type'] == 'select' and 'options_sql' in f:
                    f['options'] = _load_options(cursor, f['options_sql'])

            if request.method == 'POST':
                cursor.execute(trg['before_sql'])
                context['before_rows'] = _fmt_rows(
                    _fetchall_as_dicts(cursor), trg['before_money'])
                context['before_cols'] = (
                    list(context['before_rows'][0].keys()) if context['before_rows'] else [])

                try:
                    context['exec_result'] = _exec_trg(cursor, tab, request.POST)
                    context['exec_ok'] = True
                except Exception as e:
                    context['exec_error'] = str(e)

                cursor.execute(trg['after_sql'])
                context['after_rows'] = _fmt_rows(
                    _fetchall_as_dicts(cursor), trg['after_money'])
                context['after_cols'] = (
                    list(context['after_rows'][0].keys()) if context['after_rows'] else [])

            else:
                cursor.execute(trg['before_sql'])
                context['before_rows'] = _fmt_rows(
                    _fetchall_as_dicts(cursor), trg['before_money'])
                context['before_cols'] = (
                    list(context['before_rows'][0].keys()) if context['before_rows'] else [])

    except Exception as e:
        context['db_error'] = str(e)

    return render(request, 'booking/demo_triggers.html', context)


# ================================================================ PHASE 4

# --------------------------------------------------------------- Function metadata

_FN_META = {
    'fn_TinhCuocPhi': {
        'label': 'Tính cước phí',
        'fn_type': 'Scalar Function',
        'icon': 'bi-calculator',
        'nghiep_vu': (
            'Scalar function tính cước phí cuốc xe dựa trên bảng giá và khoảng cách. '
            'Nếu truyền voucher hợp lệ, hàm tự động áp dụng giảm giá (theo % hoặc số tiền cố định). '
            'Trả về một giá trị DECIMAL — cước phí thực tế sau khi áp dụng ưu đãi. '
            'Có thể gọi trực tiếp trong SELECT, WHERE, hoặc làm tham số cho SP khác.'
        ),
        'sql_display': (
            "-- Scalar function — dùng trực tiếp trong SELECT:\n"
            "SELECT dbo.fn_TinhCuocPhi(\n"
            "    @Ma_Bang_Gia = 'BG001',\n"
            "    @Khoang_Cach = 5.5,\n"
            "    @Ma_Voucher  = NULL    -- hoặc 'VC001'\n"
            ") AS [Cuoc phi];"
        ),
        'before_label': 'Bảng giá + voucher đang hoạt động (dữ liệu đầu vào)',
        'before_sql': """
            SELECT bg.Ma_Bang_Gia       AS [Mã BG],
                   bg.Loai_Xe          AS [Loại xe],
                   bg.Khung_Gio        AS [Khung giờ],
                   bg.Gia_Co_Ban       AS [Giá cơ bản],
                   bg.Don_Gia_Km       AS [Đơn giá/km],
                   bg.Don_Gia_Phut     AS [Đơn giá/phút]
            FROM BANGGIA bg
            ORDER BY bg.Ma_Bang_Gia
        """,
        'before_money': ['Giá cơ bản', 'Đơn giá/km', 'Đơn giá/phút'],
        'after_label': 'Kết quả fn_TinhCuocPhi — chi tiết tính toán cước phí',
        'after_money': [],
        'fields': [
            {'name': 'ma_bg', 'label': 'Bảng giá', 'type': 'select',
             'options_sql': (
                 "SELECT Ma_Bang_Gia, Ma_Bang_Gia + ' — ' + Loai_Xe + ' / ' + Khung_Gio "
                 "FROM BANGGIA ORDER BY Ma_Bang_Gia"
             ), 'options': []},
            {'name': 'khoang_cach', 'label': 'Khoảng cách (km)', 'type': 'number',
             'step': '0.1', 'min': '0.1', 'placeholder': 'VD: 5.5'},
            {'name': 'ma_voucher', 'label': 'Voucher (để trống = không dùng)', 'type': 'select',
             'options_sql': (
                 "SELECT Ma_Voucher, Ma_Voucher + ' (' + Ma_Code + ') — ' + Loai_Giam_Gia "
                 "+ ' ' + CAST(CAST(Gia_Tri_Giam AS BIGINT) AS VARCHAR) "
                 "FROM VOUCHER WHERE Trang_Thai = 'Dang hoat dong' "
                 "AND ISNULL(So_Luot_Da_Dung,0) < So_Luot_Toi_Da ORDER BY Ma_Voucher"
             ), 'options': [], 'allow_empty': True},
        ],
    },
    'fn_DoanhThuTheoThang': {
        'label': 'Doanh thu theo tháng',
        'fn_type': 'Table-Valued Function',
        'icon': 'bi-bar-chart-fill',
        'nghiep_vu': (
            'Table-Valued Function (TVF) trả về một bảng dữ liệu thay vì một giá trị đơn. '
            'Hàm tổng hợp doanh thu của tài xế theo từng tháng: số cuốc hoàn thành và tổng thu nhập. '
            'TVF có thể dùng trong mệnh đề FROM, JOIN với bảng khác, '
            'hoặc kết hợp CROSS APPLY để tính cho nhiều tài xế cùng lúc.'
        ),
        'sql_display': (
            "-- TVF — dùng như bảng trong FROM:\n"
            "SELECT *\n"
            "FROM dbo.fn_DoanhThuTheoThang(\n"
            "    @Ma_Tai_Xe = 'TX001',\n"
            "    @Thang     = 5,\n"
            "    @Nam       = 2026\n"
            ");\n\n"
            "-- Hoặc JOIN với TAIXE:\n"
            "SELECT tx.Ten_Tai_Xe, dt.*\n"
            "FROM TAIXE tx\n"
            "CROSS APPLY dbo.fn_DoanhThuTheoThang(tx.Ma_Tai_Xe, 5, 2026) dt;"
        ),
        'before_label': 'Cuốc xe hoàn thành gần đây (raw data trước khi TVF tổng hợp)',
        'before_sql': """
            SELECT TOP 10
                cx.Ma_Cuoc_Xe                               AS [Mã cuốc],
                tx.Ten_Tai_Xe                               AS [Tài xế],
                cx.Tong_Tien                                AS [Thực thu],
                CONVERT(VARCHAR(7), cx.Thoi_Gian_Tao, 120) AS [Tháng]
            FROM CUOCXE cx
            JOIN TAIXE tx ON cx.Ma_Tai_Xe = tx.Ma_Tai_Xe
            WHERE cx.Trang_Thai = 'Hoan thanh'
            ORDER BY cx.Thoi_Gian_Tao DESC
        """,
        'before_money': ['Thực thu'],
        'after_label': 'Kết quả TVF fn_DoanhThuTheoThang',
        'after_money': [],
        'fields': [
            {'name': 'ma_tx', 'label': 'Tài xế', 'type': 'select',
             'options_sql': (
                 "SELECT tx.Ma_Tai_Xe, tx.Ten_Tai_Xe + ' (' + tx.Ma_Tai_Xe + ')' "
                 "FROM TAIXE tx "
                 "WHERE EXISTS (SELECT 1 FROM CUOCXE cx "
                 "    WHERE cx.Ma_Tai_Xe = tx.Ma_Tai_Xe AND cx.Trang_Thai = 'Hoan thanh') "
                 "ORDER BY tx.Ma_Tai_Xe"
             ), 'options': []},
            {'name': 'thang', 'label': 'Tháng (1–12)', 'type': 'number',
             'min': '1', 'max': '12', 'step': '1', 'placeholder': 'VD: 5'},
            {'name': 'nam', 'label': 'Năm', 'type': 'number',
             'min': '2020', 'max': '2030', 'step': '1', 'placeholder': 'VD: 2026'},
        ],
    },
    'fn_KiemTraVoucher': {
        'label': 'Kiểm tra voucher',
        'fn_type': 'Scalar Function → BIT',
        'icon': 'bi-ticket-perforated-fill',
        'nghiep_vu': (
            'Scalar function kiểm tra tính hợp lệ của voucher cho một khách hàng cụ thể. '
            'Trả về BIT: 1 = hợp lệ, 0 = không hợp lệ. '
            'Các điều kiện kiểm tra: voucher đang hoạt động, chưa hết lượt sử dụng, '
            'trong hạn sử dụng, và khách hàng chưa từng dùng voucher này.'
        ),
        'sql_display': (
            "-- Scalar function trả về BIT (0/1):\n"
            "SELECT dbo.fn_KiemTraVoucher(\n"
            "    @Ma_Voucher    = 'VC001',\n"
            "    @Ma_Khach_Hang = 'KH001'\n"
            ") AS [Hop le];\n"
            "-- 1 = Hợp lệ, 0 = Không hợp lệ\n\n"
            "-- Dùng trong điều kiện WHERE:\n"
            "SELECT * FROM VOUCHER\n"
            "WHERE dbo.fn_KiemTraVoucher(Ma_Voucher, 'KH001') = 1;"
        ),
        'before_label': 'Danh sách voucher và trạng thái (dữ liệu đầu vào)',
        'before_sql': """
            SELECT v.Ma_Voucher                         AS [Mã voucher],
                   v.Ma_Code                            AS [Code],
                   v.Loai_Giam_Gia                      AS [Loại giảm],
                   v.Gia_Tri_Giam                       AS [Giá trị giảm],
                   ISNULL(v.So_Luot_Da_Dung, 0)        AS [Đã dùng],
                   v.So_Luot_Toi_Da                     AS [Tối đa],
                   v.Trang_Thai                         AS [Trạng thái]
            FROM VOUCHER v
            ORDER BY v.Ma_Voucher
        """,
        'before_money': ['Giá trị giảm'],
        'after_label': 'Kết quả fn_KiemTraVoucher',
        'after_money': [],
        'fields': [
            {'name': 'ma_voucher', 'label': 'Voucher', 'type': 'select',
             'options_sql': (
                 "SELECT Ma_Voucher, Ma_Voucher + ' (' + Ma_Code + ') — ' + Trang_Thai "
                 "FROM VOUCHER ORDER BY Ma_Voucher"
             ), 'options': []},
            {'name': 'ma_kh', 'label': 'Khách hàng', 'type': 'select',
             'options_sql': (
                 "SELECT Ma_Khach_Hang, Ten_Khach_Hang + ' (' + Ma_Khach_Hang + ')' "
                 "FROM KHACHHANG WHERE Trang_Thai = 'Hoat dong' ORDER BY Ma_Khach_Hang"
             ), 'options': []},
        ],
    },
}


def _exec_fn(cursor, tab, post):
    """Execute a function and return (exec_html, after_rows, after_cols, after_label)."""
    if tab == 'fn_TinhCuocPhi':
        ma_bg = post.get('ma_bg', '').strip()
        khoang_cach = float(post.get('khoang_cach', 0) or 0)
        ma_voucher = post.get('ma_voucher', '').strip() or None

        cursor.execute("""
            SELECT
                bg.Ma_Bang_Gia                               AS [Mã BG],
                bg.Loai_Xe                                   AS [Loại xe],
                bg.Khung_Gio                                 AS [Khung giờ],
                %s                                           AS [Khoảng cách (km)],
                bg.Gia_Co_Ban + bg.Don_Gia_Km * %s          AS [Giá gốc],
                %s                                           AS [Voucher],
                dbo.fn_TinhCuocPhi(%s, %s, %s)              AS [Cước phí sau giảm]
            FROM BANGGIA bg WHERE Ma_Bang_Gia = %s
        """, [khoang_cach, khoang_cach, ma_voucher or '—',
              ma_bg, khoang_cach, ma_voucher, ma_bg])
        rows = _fetchall_as_dicts(cursor)
        if not rows:
            raise Exception(f'Không tìm thấy bảng giá: {ma_bg}')
        after_rows = _fmt_rows(rows, ['Giá gốc', 'Cước phí sau giảm'])
        after_cols = list(after_rows[0].keys())
        gia_sau = rows[0]['Cước phí sau giảm']
        gia_goc = rows[0]['Giá gốc']
        discount = ''
        if ma_voucher and gia_goc is not None and gia_sau is not None:
            diff = float(gia_goc) - float(gia_sau)
            if diff > 0:
                discount = f' (giảm {_fmt_vnd(diff)} so với giá gốc)'
        exec_html = (
            f'fn_TinhCuocPhi(<em>{ma_bg}</em>, <em>{khoang_cach} km</em>, '
            f'<em>{ma_voucher or "NULL"}</em>) = '
            f'<strong>{_fmt_vnd(gia_sau)}</strong>{discount}'
        )
        return exec_html, after_rows, after_cols, 'Kết quả tính cước phí fn_TinhCuocPhi'

    elif tab == 'fn_DoanhThuTheoThang':
        ma_tx = post.get('ma_tx', '').strip()
        thang = int(post.get('thang', 0) or 0)
        nam = int(post.get('nam', 0) or 0)

        cursor.execute(
            "SELECT * FROM dbo.fn_DoanhThuTheoThang(%s, %s, %s)",
            [ma_tx, thang, nam]
        )
        raw = _fetchall_as_dicts(cursor)
        money_cols = tuple(
            k for k in (raw[0].keys() if raw else [])
            if any(x in k for x in ('Doanh', 'Tien', 'Thu', 'tien', 'thu'))
        )
        after_rows = _fmt_rows(raw, money_cols)
        after_cols = list(after_rows[0].keys()) if after_rows else []
        exec_html = (
            f'fn_DoanhThuTheoThang(<em>{ma_tx}</em>, <em>{thang}</em>, <em>{nam}</em>) '
            f'→ <strong>{len(after_rows)}</strong> hàng kết quả.'
        )
        return exec_html, after_rows, after_cols, f'Kết quả TVF — tài xế {ma_tx} tháng {thang}/{nam}'

    elif tab == 'fn_KiemTraVoucher':
        ma_voucher = post.get('ma_voucher', '').strip()
        ma_kh = post.get('ma_kh', '').strip()

        cursor.execute("SELECT dbo.fn_KiemTraVoucher(%s, %s)", [ma_voucher, ma_kh])
        bit_result = cursor.fetchone()[0]
        hop_le = bool(bit_result)

        after_rows = [{
            'Voucher': ma_voucher,
            'Khách hàng': ma_kh,
            'Kết quả (BIT)': str(bit_result),
            'Ý nghĩa': 'HỢP LỆ — có thể sử dụng' if hop_le else 'KHÔNG HỢP LỆ',
        }]
        after_cols = list(after_rows[0].keys())
        exec_html = (
            f'fn_KiemTraVoucher(<em>{ma_voucher}</em>, <em>{ma_kh}</em>) = '
            f'<strong>{bit_result}</strong> — '
            + ('<strong class="text-success">Voucher hợp lệ</strong>' if hop_le
               else '<strong class="text-danger">Voucher không hợp lệ</strong>')
        )
        return exec_html, after_rows, after_cols, 'Kết quả kiểm tra fn_KiemTraVoucher'

    raise Exception('Function không xác định.')


def demo_functions(request):
    tab = request.GET.get('tab', 'fn_TinhCuocPhi')
    if tab not in _FN_META:
        tab = 'fn_TinhCuocPhi'

    fn = copy.deepcopy(_FN_META[tab])
    context = {'fn_meta': _FN_META, 'tab': tab, 'fn': fn}

    try:
        with connection.cursor() as cursor:
            for f in fn['fields']:
                if f['type'] == 'select' and 'options_sql' in f:
                    f['options'] = _load_options(cursor, f['options_sql'])

            cursor.execute(fn['before_sql'])
            context['before_rows'] = _fmt_rows(
                _fetchall_as_dicts(cursor), fn['before_money'])
            context['before_cols'] = (
                list(context['before_rows'][0].keys()) if context['before_rows'] else [])

            if request.method == 'POST':
                try:
                    exec_html, after_rows, after_cols, after_label = _exec_fn(
                        cursor, tab, request.POST)
                    context['exec_result'] = exec_html
                    context['exec_ok'] = True
                    context['after_rows'] = after_rows
                    context['after_cols'] = after_cols
                    context['after_label_dyn'] = after_label
                except Exception as e:
                    context['exec_error'] = str(e)

    except Exception as e:
        context['db_error'] = str(e)

    return render(request, 'booking/demo_functions.html', context)


# --------------------------------------------------------------- Cursor metadata

_CURSOR_META = {
    'sp_Cursor_Top50TaiXeDoanhThuNgay': {
        'label': 'TOP 50 tài xế doanh thu ngày',
        'icon': 'bi-trophy-fill',
        'nghiep_vu': (
            'Stored Procedure dùng CURSOR để duyệt TOP 50 tài xế có doanh thu cao nhất hôm nay. '
            'Với mỗi tài xế, SP INSERT một THONGBAO cá nhân hóa kèm thứ hạng và số tiền. '
            'Cursor cho phép xử lý logic riêng cho từng hàng — điều mà câu lệnh tập hợp không làm được. '
            'Phù hợp cho batch processing nội bộ, gửi thông báo, tính thưởng.'
        ),
        'sql_display': (
            "EXEC dbo.sp_Cursor_Top50TaiXeDoanhThuNgay;\n\n"
            "-- Bên trong SP (cursor logic):\n"
            "DECLARE cur_top50 CURSOR FOR\n"
            "    SELECT TOP 50 Ma_Tai_Xe, SUM(Tong_Tien) AS DoanhThu\n"
            "    FROM CUOCXE\n"
            "    WHERE Trang_Thai = 'Hoan thanh'\n"
            "      AND CAST(Thoi_Gian_Tao AS DATE) = CAST(GETDATE() AS DATE)\n"
            "    GROUP BY Ma_Tai_Xe ORDER BY DoanhThu DESC;\n\n"
            "OPEN cur_top50;\n"
            "FETCH NEXT FROM cur_top50 INTO @ma_tx, @doanh_thu;\n"
            "WHILE @@FETCH_STATUS = 0\n"
            "BEGIN\n"
            "    INSERT INTO THONGBAO (Ma_Thong_Bao, Loai_Nguoi_Nhan,\n"
            "        Ma_Nguoi_Nhan, Tieu_De, Noi_Dung, Trang_Thai_Doc, Thoi_Gian_Gui)\n"
            "    VALUES ('TB' + ..., 'Tai xe', @ma_tx,\n"
            "        N'Xếp hạng doanh thu hôm nay',\n"
            "        N'Bạn đạt ' + CAST(@doanh_thu AS VARCHAR) + N'đ hôm nay',\n"
            "        'Chua doc', GETDATE());\n"
            "    FETCH NEXT FROM cur_top50 INTO @ma_tx, @doanh_thu;\n"
            "END\n"
            "CLOSE cur_top50; DEALLOCATE cur_top50;"
        ),
        'before_label': 'TOP 10 tài xế doanh thu hôm nay (trước khi cursor gửi thông báo)',
        'before_sql': """
            SELECT TOP 10
                tx.Ma_Tai_Xe                              AS [Mã TX],
                tx.Ten_Tai_Xe                             AS [Tên tài xế],
                ISNULL(SUM(cx.Tong_Tien), 0)             AS [Doanh thu hôm nay],
                COUNT(cx.Ma_Cuoc_Xe)                     AS [Số cuốc]
            FROM TAIXE tx
            LEFT JOIN CUOCXE cx
                   ON cx.Ma_Tai_Xe = tx.Ma_Tai_Xe
                  AND cx.Trang_Thai = 'Hoan thanh'
                  AND CAST(cx.Thoi_Gian_Tao AS DATE) = CAST(GETDATE() AS DATE)
            GROUP BY tx.Ma_Tai_Xe, tx.Ten_Tai_Xe
            ORDER BY [Doanh thu hôm nay] DESC
        """,
        'before_money': ['Doanh thu hôm nay'],
        'after_label': '5 THONGBAO mới nhất (cursor đã gửi cho từng tài xế)',
        'after_sql': """
            SELECT TOP 5
                tb.Ma_Thong_Bao                               AS [Mã TB],
                tb.Ma_Nguoi_Nhan                              AS [Gửi đến],
                tb.Tieu_De                                    AS [Tiêu đề],
                SUBSTRING(tb.Noi_Dung, 1, 60)                AS [Nội dung],
                CONVERT(VARCHAR(16), tb.Thoi_Gian_Gui, 120)  AS [Thời gian]
            FROM THONGBAO tb
            ORDER BY tb.Thoi_Gian_Gui DESC
        """,
        'after_money': [],
        'fields': [],
    },
    'sp_Cursor_ThuongTop3KhachHang': {
        'label': 'Thưởng TOP 3 khách hàng',
        'icon': 'bi-award-fill',
        'nghiep_vu': (
            'SP dùng CURSOR duyệt TOP 3 khách hàng có nhiều cuốc xe hoàn thành nhất. '
            'Với mỗi KH: cộng 50.000đ vào ví điện tử, ghi LICHSUGIAODICH, INSERT THONGBAO chúc mừng. '
            'Cursor cho phép tính toán cá nhân hóa cho từng người (khác nhau về số cuốc, tên) '
            'trước khi ghi — không thể làm bằng một câu UPDATE tập hợp đơn thuần.'
        ),
        'sql_display': (
            "EXEC dbo.sp_Cursor_ThuongTop3KhachHang;\n\n"
            "-- Bên trong SP (cursor logic):\n"
            "DECLARE cur_top3 CURSOR FOR\n"
            "    SELECT TOP 3 Ma_Khach_Hang, COUNT(*) AS SoCuoc\n"
            "    FROM CUOCXE WHERE Trang_Thai = 'Hoan thanh'\n"
            "    GROUP BY Ma_Khach_Hang ORDER BY SoCuoc DESC;\n\n"
            "OPEN cur_top3;\n"
            "FETCH NEXT FROM cur_top3 INTO @ma_kh, @so_cuoc;\n"
            "WHILE @@FETCH_STATUS = 0\n"
            "BEGIN\n"
            "    -- Cộng 50.000đ vào ví\n"
            "    UPDATE VIDIENTU SET So_Du = So_Du + 50000\n"
            "    WHERE Ma_Chu_So_Huu = @ma_kh\n"
            "      AND Loai_Chu_So_Huu = 'Khach hang';\n\n"
            "    -- Ghi lịch sử giao dịch\n"
            "    INSERT INTO LICHSUGIAODICH (...);\n\n"
            "    -- Gửi thông báo cá nhân hóa\n"
            "    INSERT INTO THONGBAO (...)\n"
            "    VALUES (..., N'Top ' + CAST(@rank AS VARCHAR)\n"
            "        + N' — nhận thưởng 50.000đ', ...);\n\n"
            "    FETCH NEXT FROM cur_top3 INTO @ma_kh, @so_cuoc;\n"
            "END\n"
            "CLOSE cur_top3; DEALLOCATE cur_top3;"
        ),
        'before_label': 'TOP 3 khách hàng + số dư ví (TRƯỚC khi nhận thưởng)',
        'before_sql': """
            SELECT TOP 3
                kh.Ma_Khach_Hang                         AS [Mã KH],
                kh.Ten_Khach_Hang                        AS [Tên khách hàng],
                COUNT(cx.Ma_Cuoc_Xe)                     AS [Số cuốc HT],
                ISNULL(v.So_Du, 0)                       AS [Số dư ví]
            FROM KHACHHANG kh
            JOIN CUOCXE cx ON cx.Ma_Khach_Hang = kh.Ma_Khach_Hang
                           AND cx.Trang_Thai = 'Hoan thanh'
            LEFT JOIN VIDIENTU v
                   ON kh.Ma_Khach_Hang = v.Ma_Chu_So_Huu
                  AND v.Loai_Chu_So_Huu = 'Khach hang'
            GROUP BY kh.Ma_Khach_Hang, kh.Ten_Khach_Hang, v.So_Du
            ORDER BY COUNT(cx.Ma_Cuoc_Xe) DESC
        """,
        'before_money': ['Số dư ví'],
        'after_label': 'TOP 3 KH sau khi nhận thưởng 50.000đ (số dư ví tăng)',
        'after_sql': """
            SELECT TOP 3
                kh.Ma_Khach_Hang                         AS [Mã KH],
                kh.Ten_Khach_Hang                        AS [Tên khách hàng],
                COUNT(cx.Ma_Cuoc_Xe)                     AS [Số cuốc HT],
                ISNULL(v.So_Du, 0)                       AS [Số dư ví]
            FROM KHACHHANG kh
            JOIN CUOCXE cx ON cx.Ma_Khach_Hang = kh.Ma_Khach_Hang
                           AND cx.Trang_Thai = 'Hoan thanh'
            LEFT JOIN VIDIENTU v
                   ON kh.Ma_Khach_Hang = v.Ma_Chu_So_Huu
                  AND v.Loai_Chu_So_Huu = 'Khach hang'
            GROUP BY kh.Ma_Khach_Hang, kh.Ten_Khach_Hang, v.So_Du
            ORDER BY COUNT(cx.Ma_Cuoc_Xe) DESC
        """,
        'after_money': ['Số dư ví'],
        'fields': [],
    },
}


def _exec_cursor(cursor, tab):
    if tab == 'sp_Cursor_Top50TaiXeDoanhThuNgay':
        cursor.execute("EXEC dbo.sp_Cursor_Top50TaiXeDoanhThuNgay")
        return ('Cursor đã duyệt <strong>TOP 50 tài xế</strong> doanh thu hôm nay '
                'và INSERT THONGBAO cá nhân hóa cho từng người.')
    elif tab == 'sp_Cursor_ThuongTop3KhachHang':
        cursor.execute("EXEC dbo.sp_Cursor_ThuongTop3KhachHang")
        return ('Cursor đã thưởng <strong>+50.000đ</strong> vào ví TOP 3 khách hàng, '
                'ghi LICHSUGIAODICH và INSERT THONGBAO chúc mừng.')
    return 'Thực thi thành công.'


def demo_cursors(request):
    tab = request.GET.get('tab', 'sp_Cursor_Top50TaiXeDoanhThuNgay')
    if tab not in _CURSOR_META:
        tab = 'sp_Cursor_Top50TaiXeDoanhThuNgay'

    cur = copy.deepcopy(_CURSOR_META[tab])
    context = {'cursor_meta': _CURSOR_META, 'tab': tab, 'cur': cur}

    try:
        with connection.cursor() as cursor:
            if request.method == 'POST':
                cursor.execute(cur['before_sql'])
                context['before_rows'] = _fmt_rows(
                    _fetchall_as_dicts(cursor), cur['before_money'])
                context['before_cols'] = (
                    list(context['before_rows'][0].keys()) if context['before_rows'] else [])

                try:
                    context['exec_result'] = _exec_cursor(cursor, tab)
                    context['exec_ok'] = True
                except Exception as e:
                    context['exec_error'] = str(e)

                cursor.execute(cur['after_sql'])
                context['after_rows'] = _fmt_rows(
                    _fetchall_as_dicts(cursor), cur['after_money'])
                context['after_cols'] = (
                    list(context['after_rows'][0].keys()) if context['after_rows'] else [])

            else:
                cursor.execute(cur['before_sql'])
                context['before_rows'] = _fmt_rows(
                    _fetchall_as_dicts(cursor), cur['before_money'])
                context['before_cols'] = (
                    list(context['before_rows'][0].keys()) if context['before_rows'] else [])

    except Exception as e:
        context['db_error'] = str(e)

    return render(request, 'booking/demo_cursors.html', context)


# --------------------------------------------------------------- Security demo

_SECURITY_VIEWS = [
    {'key': 'vw_KhachHang_BaoCao', 'label': 'KH Báo cáo', 'icon': 'bi-people-fill',
     'desc': 'Thông tin khách hàng cho mục đích báo cáo — số điện thoại được che bằng DDM.',
     'sql': "SELECT TOP 10 * FROM dbo.vw_KhachHang_BaoCao"},
    {'key': 'vw_TaiXe_BaoCao', 'label': 'Tài xế Báo cáo', 'icon': 'bi-person-badge-fill',
     'desc': 'Thông tin tài xế kèm phương tiện, điểm uy tín — dùng cho báo cáo quản lý.',
     'sql': "SELECT TOP 10 * FROM dbo.vw_TaiXe_BaoCao"},
    {'key': 'vw_CuocXe_Dashboard', 'label': 'Cuốc xe Dashboard', 'icon': 'bi-map-fill',
     'desc': 'Cuốc xe kèm thông tin KH, TX, bảng giá — dùng cho màn hình dashboard.',
     'sql': "SELECT TOP 10 * FROM dbo.vw_CuocXe_Dashboard ORDER BY 1 DESC"},
    {'key': 'vw_DoanhThu_Dashboard', 'label': 'Doanh thu Dashboard', 'icon': 'bi-cash-stack',
     'desc': 'Tổng hợp doanh thu theo ngày/tháng — dùng cho biểu đồ dashboard.',
     'sql': "SELECT TOP 10 * FROM dbo.vw_DoanhThu_Dashboard"},
    {'key': 'vw_HieuSuatTaiXe_Dashboard', 'label': 'Hiệu suất Tài xế', 'icon': 'bi-bar-chart-line-fill',
     'desc': 'Hiệu suất tài xế: số cuốc, doanh thu, đánh giá trung bình.',
     'sql': "SELECT TOP 10 * FROM dbo.vw_HieuSuatTaiXe_Dashboard"},
    {'key': 'vw_OrderPool_Dashboard', 'label': 'Order Pool', 'icon': 'bi-collection-fill',
     'desc': 'Cuốc xe đang chờ nhận — dùng cho màn hình điều phối tài xế.',
     'sql': "SELECT TOP 10 * FROM dbo.vw_OrderPool_Dashboard"},
    {'key': 'ddm', 'label': 'DDM', 'icon': 'bi-shield-lock-fill',
     'desc': 'Dynamic Data Masking — danh sách cột đang được che khuất.',
     'sql': (
         "SELECT t.name AS [Bảng], c.name AS [Cột], "
         "m.masking_function AS [Hàm mask] "
         "FROM sys.masked_columns m "
         "JOIN sys.columns c ON m.object_id = c.object_id AND m.column_id = c.column_id "
         "JOIN sys.tables t ON c.object_id = t.object_id "
         "ORDER BY t.name, c.name"
     )},
    {'key': 'users_roles', 'label': 'Users / Roles', 'icon': 'bi-person-lock',
     'desc': 'Database users và role members trong SQL Server.',
     'sql': (
         "SELECT dp.name AS [Tên], dp.type_desc AS [Loại], "
         "CONVERT(VARCHAR(16), dp.create_date, 120) AS [Ngày tạo] "
         "FROM sys.database_principals dp "
         "WHERE dp.type IN ('S','U','G','E','R') "
         "AND dp.name NOT LIKE '##%' AND dp.name != 'guest' "
         "ORDER BY dp.type_desc, dp.name"
     )},
]


def demo_security(request):
    tab = request.GET.get('tab', 'vw_KhachHang_BaoCao')
    valid_keys = [v['key'] for v in _SECURITY_VIEWS]
    if tab not in valid_keys:
        tab = valid_keys[0]

    current = next(v for v in _SECURITY_VIEWS if v['key'] == tab)
    context = {
        'security_views': _SECURITY_VIEWS,
        'tab': tab,
        'current': current,
    }

    try:
        with connection.cursor() as cursor:
            cursor.execute(current['sql'])
            rows = _fetchall_as_dicts(cursor)
            money_cols = tuple(
                k for k in (rows[0].keys() if rows else [])
                if any(x in k for x in ('Doanh', 'Tien', 'Thu', 'Du', 'Phi'))
            )
            context['view_rows'] = _fmt_rows(rows, money_cols)
            context['view_cols'] = list(rows[0].keys()) if rows else []
    except Exception as e:
        context['view_error'] = str(e)

    return render(request, 'booking/demo_security.html', context)
