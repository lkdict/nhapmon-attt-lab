# Phiếu ghi kết quả thực hành — Bài 2 (ATT&CK Navigator)

- Họ tên: ____________________  Lớp: ________
- Nhóm APT phân tích: APT32 (G0050)
- Phiên bản ATT&CK / Navigator: ____________________
- Hệ thống giả định dùng để chấm ưu tiên: Trường Đại học X (cổng SV web, email đám mây,
  SSO, VPN cán bộ, máy trạm Windows phòng Đào tạo)

> Các dòng có chữ *(ví dụ minh họa)* lấy từ **phân tích mẫu APT29** trong tài liệu, chỉ để
> minh họa cách điền. Người học xóa đi và điền kết quả phân tích APT32 của chính mình.

## Phần A — Đọc bản đồ nhiệt

Legend có ____ màu, vì: ____________________________________________

| Chiến thuật | Số kỹ thuật | Giai đoạn Kill Chain | Ý nghĩa với bên phòng thủ |
|-------------|-------------|----------------------|---------------------------|
| *(ví dụ minh họa — APT29)* Persistence | 15 | 5. Cài đặt (có thể lặp ở 6–7) | Hồ sơ ghi nhận nhiều cách duy trì truy cập → cần giám sát cơ chế thường trú, tài khoản mới |
|  |  |  |  |
|  |  |  |  |
|  |  |  |  |

Hai nhóm APT29 và APT32 khác nhau ở chiến thuật nào? ______________________________

## Phần B — Bảng 3 kỹ thuật (3 chiến thuật khác nhau)

| Mã | Tên kỹ thuật và giải thích ngắn | Chiến thuật | Ưu tiên (1–3) và lý do | Biện pháp phòng thủ (loại, mã M) |
|----|-------------------------------|-------------|------------------------|----------------------------------|
| *(ví dụ minh họa — APT29)* T1078.004 | Valid Accounts: Cloud Accounts — dùng tài khoản đám mây hợp lệ bị đánh cắp để đăng nhập và ở lại | Persistence | 3 — với SSO, một tài khoản bị chiếm có thể ảnh hưởng nhiều dịch vụ liên kết mà tài khoản được cấp quyền, hậu quả lớn, đăng nhập "hợp lệ" nên khó phát hiện | MFA chống phishing cho tài khoản quản trị (M1032, ngăn chặn); cảnh báo đăng nhập lạ (phát hiện) |

Thang ưu tiên: 3 = chạm tài sản quan trọng, hậu quả lớn và khả năng xảy ra cao; 2 = mức vừa
(ví dụ cần một bước tấn công khác thành công trước); 1 = ít liên quan, hậu quả nhỏ hoặc đã có
kiểm soát tốt. Chi phí biện pháp đánh giá riêng, không dùng để hạ mức ưu tiên.

Quy ước màu trên ảnh layer (bản sao): xám = ____________ ; xanh lá → đỏ = ____________
|  |  |  |  |  |
|  |  |  |  |  |
|  |  |  |  |  |

## Phần C — Đính kèm và kết luận

- [ ] Ảnh SVG/PNG layer APT32 từ Navigator, thấy rõ 3 ô đã chấm theo thang 1–3
- [ ] (tùy chọn) `ketqua_bai2_nhom.txt`

**Kết luận (2–3 câu):** nếu là quản trị hệ thống của Trường Đại học X, bạn đầu tư biện pháp
nào trước và vì sao?

_____________________________________________________________________________

_____________________________________________________________________________
