# Phiếu ghi kết quả thực hành — Bài 3 (Chứng thư số và TLS)

- Họ tên: ____________________  Lớp: ________  Ngày: ____________
- Máy chủ công khai kiểm tra: ____________________ (mặc định `example.com`)
- Phiên bản OpenSSL (`openssl version`): ____________________

> Các dòng có chữ *(ví dụ minh họa)* chỉ để minh họa cách điền; số liệu có thể khác khi bạn
> làm (chứng thư được thay định kỳ). Người học xóa đi và điền kết quả của chính mình.

## Phần A — Khởi động: các cơ chế mật mã (không chấm điểm riêng)

| Câu hỏi | Trả lời |
|---------|---------|
| A1. Đổi 1 ký tự, hai giá trị SHA-256 khác nhau bao nhiêu bit / 256? | *(ví dụ minh họa)* 129/256 (~50%) |
| A2. Base64 có phải mã hóa không? Vì sao? |  |
| A3. Sau khi sửa 1 byte bản mã AES-CTR, giải mã ra gì? Có báo lỗi không? Cơ chế nào phát hiện được? |  |
| A4. Vì sao hai lần `openssl passwd -6` cùng mật khẩu cho kết quả khác nhau? |  |
| A5. Entropy theo byte của 3 mẫu (lặp / văn bản / ngẫu nhiên); vì sao không dùng nó để đo độ mạnh mật khẩu? |  |

## Phần B, C — Kết quả kiểm tra TLS

| Nội dung ghi nhận | Máy chủ công khai | Máy chủ lab `lab3.attt.test` (có `-CAfile`) |
|-------------------|-------------------|---------------------------------------------|
| Phiên bản giao thức thỏa thuận | *(ví dụ minh họa)* TLSv1.3 |  |
| Cipher suite; nhóm trao đổi khóa (Server Temp Key) | *(ví dụ minh họa)* TLS_AES_256_GCM_SHA384; X25519 |  |
| Subject (CN, O) |  |  |
| Issuer |  |  |
| Subject Alternative Name |  |  |
| Thời hạn (Not Before – Not After), tổng số ngày |  |  |
| Serial; Public Key Algorithm; Signature Algorithm |  |  |
| Chuỗi máy chủ gửi (0: …; 1: …) và Root CA (depth cao nhất) |  |  |
| Verify return code |  |  |
| TLS 1.2: có chấp nhận? cipher suite? |  |  |

**Phần C — Mã lỗi xác minh trên máy chủ lab**

| Tình huống | Verify return code | Giải thích (máy khách thiếu gì / máy chủ sai gì) |
|------------|--------------------|---------------------------------------------------|
| C2. Không có `-CAfile` |  |  |
| C3. Có `-CAfile root.crt` |  |  |
| C4a. Sai tên, KHÔNG có `-verify_hostname` |  |  |
| C4b. Sai tên, có `-verify_hostname` |  |  |
| C5. Máy chủ không gửi chứng thư trung gian |  |  |

## Phần D — Bắt tay TLS (mở rộng)

| Câu hỏi | TLS 1.3 | TLS 1.2 |
|---------|---------|---------|
| Thông điệp nào đi ở dạng rõ? |  |  |
| Thông điệp `Certificate` ở dạng rõ hay đã mã hóa? |  |  |
| SNI quan sát được trong ClientHello? (nếu dùng Wireshark) |  |  |

## Giải thích ngắn (2–3 câu)

Vai trò của chứng thư và khóa phiên trong kết nối vừa quan sát:

_____________________________________________________________________________

_____________________________________________________________________________

## Đính kèm

- [ ] `ketqua_bai3_<may_chu_cong_khai>.txt` và `ketqua_bai3_lab3.attt.test.txt`
- [ ] Ảnh chụp lệnh và kết quả Bước 1 (Phần B)
- [ ] (mở rộng) Ảnh Wireshark có ClientHello / ServerHello, hoặc kết quả `05_quan_sat_handshake.sh`
