# Bài 1 — Nhận diện bề mặt tấn công bằng Nmap

Chạy trên máy ảo Ubuntu 22.04 trong môi trường lab được cấp phép.

## Thứ tự thực hiện
0. `bash 00_cai_ssh.sh`          — (tùy chọn) bật SSH để làm việc từ terminal máy host.
1. `bash 01_setup_moitruong.sh`  — cài Nmap + dựng dịch vụ mẫu, lấy IP máy ảo.
2. `bash 02_quet_nmap.sh [IP]`    — quét cổng, nhận diện dịch vụ, xuất `ketqua_bai1.txt`.
3. Điền `phieu_ketqua.md` (liên hệ CIA + biện pháp cho từng cổng mở).
4. `bash 03_giam_bemat.sh [IP]`   — tắt dịch vụ thừa, quét lại, so sánh trước/sau.

> Chỉ quét 127.0.0.1, máy ảo nội bộ, hoặc mục tiêu được giảng viên cấp phép.
