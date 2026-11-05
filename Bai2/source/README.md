# Bài 2 — Đọc và phân tích nhóm tấn công trên MITRE ATT&CK Navigator

Phần chính của bài làm **trên trình duyệt của máy thật**:
<https://mitre-attack.github.io/attack-navigator/> (không cần cài đặt).

Thư mục này chứa script **tùy chọn** để tra cứu ATT&CK ngoại tuyến và đối chiếu số liệu
khi đọc bản đồ nhiệt. Chạy trên máy ảo Ubuntu 22.04, WSL2 hoặc máy bất kỳ có Python 3.

## Thứ tự thực hiện
0. `bash 00_cai_ssh.sh`          — (tùy chọn) bật SSH để làm việc từ terminal máy host.
1. `bash 01_setup_moitruong.sh`  — cài python3/curl nếu thiếu, tải dữ liệu ATT&CK Enterprise 20.0
   (~55 MB, cần Internet một lần) vào `~/.cache/nhapmon-attt/`.
2. `python3 02_tra_cuu_attack.py ...` — tra cứu:

| Lệnh | Dùng ở bước |
|------|-------------|
| `python3 02_tra_cuu_attack.py nhom G0016 --bien-phap` | Xem lại phân tích mẫu APT29 |
| `python3 02_tra_cuu_attack.py nhom G0016 --ca-chien-dich` | Gộp kỹ thuật của chiến dịch (màu đỏ/hồng trên Navigator) |
| `python3 02_tra_cuu_attack.py nhom G0050 --chi-tiet -o ketqua_bai2_nhom.txt` | Bước 3: số kỹ thuật theo chiến thuật |
| `python3 02_tra_cuu_attack.py kythuat T1566.001 --nhom G0050` | Bước 4: mô tả + Mitigations, nhóm có dùng không |
| `python3 02_tra_cuu_attack.py nhom G0050 --bien-phap` | Bước 6: biện pháp phủ nhiều kỹ thuật nhất |

3. Điền `phieu_ketqua.md`, nộp kèm ảnh layer xuất từ Navigator.

Đổi phiên bản dữ liệu: `ATTACK_VERSION=20.0 bash 01_setup_moitruong.sh --tai-lai`.

> Chỉ đọc và phân tích tri thức công khai cho mục đích phòng thủ. Không thử các kỹ thuật
> đọc được lên bất kỳ hệ thống, tài khoản hay email thật nào.

Dữ liệu: MITRE ATT&CK® (<https://attack.mitre.org/>), © The MITRE Corporation, dùng theo
điều khoản sử dụng của ATT&CK.
