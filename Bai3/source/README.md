# Bài 3 — Quan sát chứng thư số và bắt tay TLS bằng OpenSSL

Chạy trên máy ảo Ubuntu 22.04 (hoặc WSL2 Ubuntu) có OpenSSL 3.x. Đề bài (PDF) do người
hướng dẫn phát qua kênh của lớp.

## Thứ tự thực hiện

| Script | Dùng ở | Việc làm |
|--------|--------|----------|
| `bash 00_cai_ssh.sh` | Chuẩn bị (tùy chọn) | Bật SSH để làm việc từ terminal máy host |
| `bash 01_setup_moitruong.sh` | Chuẩn bị | Cài `openssl`, `ca-certificates`, `python3` nếu thiếu; kiểm tra giờ hệ thống, DNS; tạo PKI lab giả định trong `~/bai3-lab/pki` |
| `bash 01_setup_moitruong.sh --wireshark` | Phần D (tùy chọn) | Cài thêm `tshark`, `tcpdump` |
| `bash 02_matma_coban.sh [1-5]` | Phần A | Khởi động: hàm băm, Base64, mã hóa không có toàn vẹn, MAC, salt, entropy |
| `bash 03_kiem_tra_tls.sh example.com` | Phần B | Phiên bản TLS, cipher suite, chuỗi chứng thư, các trường X.509; lưu `ketqua_bai3_<ten>.txt` |
| `bash 04_maychu_lab.sh start` | Phần C | Chạy máy chủ TLS thử nghiệm tại `127.0.0.1:4433` (tên `lab3.attt.test`) |
| `bash 03_kiem_tra_tls.sh 127.0.0.1 4433 --sni lab3.attt.test [--cafile ~/bai3-lab/pki/root.crt]` | Phần C | Kiểm tra máy chủ lab, có/không tin Root CA lab |
| `bash 04_maychu_lab.sh start --thieu-trung-gian` | Phần C | Cấu hình SAI: không gửi chứng thư trung gian |
| `bash 05_quan_sat_handshake.sh example.com [--tls12]` | Phần D | Liệt kê bản ghi TLS: phần rõ / phần đã mã hóa (không cần quyền bắt gói) |
| `bash 04_maychu_lab.sh stop` | Dọn dẹp | Dừng máy chủ lab |

Cổng 4433 bị chiếm? Dùng cổng khác: `BAI3_PORT=4434 bash 04_maychu_lab.sh start` và đổi
`4433` thành `4434` trong các lệnh.

Điền `phieu_ketqua.md` và nộp kèm tệp `ketqua_bai3_*.txt` (không đưa lên kho này).

> **Phạm vi:** `openssl s_client` chỉ mở một kết nối TLS bình thường như trình duyệt. Chỉ
> kết nối tới `example.com`, máy chủ lab trên chính máy ảo, hoặc máy chủ người hướng dẫn chỉ
> định; không quét hàng loạt, không lặp liên tục, không thử cổng/dịch vụ không công khai.
> Root CA trong `~/bai3-lab/pki` là **giả định**, chỉ dùng trong lab: không cài vào trình
> duyệt hay kho tin cậy của hệ điều hành.
