# Phiếu ghi kết quả thực hành — Bài 1

- Họ tên: ____________________  Lớp: ________
- Mục tiêu quét (IP): ____________________
- Được cấp phép bởi: ____________________

> Bảng dưới là **ví dụ minh họa cách điền** (số liệu giả định, không phải kết quả thật).
> Sinh viên thay bằng kết quả quét của chính mình.

| Cổng | Trạng thái | Dịch vụ / phiên bản | Cần thiết? | CIA bị đe dọa nếu bị khai thác | Biện pháp đề xuất |
|------|-----------|----------------------|-----------|-------------------------------|-------------------|
| 21   | open   | vsftpd 3.0.3   | Không | C (truyền rõ mật khẩu), I | Ưu tiên tắt FTP; nếu cần dùng SFTP (qua SSH) |
| 22   | open   | OpenSSH 8.9    | Có    | C, I nếu mật khẩu yếu | Khóa SSH, tắt đăng nhập root |
| 80   | open   | Apache 2.4.52  | Có    | A (DoS), I (deface) | Chuyển HTTPS, cập nhật bản vá |
| 443  | closed | https          | —     | —                 | Mở khi bật HTTPS cho web |
| 3306 | closed | mysql          | —     | —                 | Giữ đóng / chỉ bind 127.0.0.1 |

**Nhận xét (3–5 câu):** dịch vụ nào đáng lo nhất và vì sao; số cổng mở trước/sau khi
giảm bề mặt tấn công; bài học về nguyên tắc đặc quyền tối thiểu.

_____________________________________________________________________________

_____________________________________________________________________________
