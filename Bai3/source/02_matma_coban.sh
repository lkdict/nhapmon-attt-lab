#!/usr/bin/env bash
# Bai 3 - Phan A (khoi dong): ham bam, Base64, ma hoa khong co toan ven, MAC, salt, entropy.
# Chay hoan toan cuc bo, khong can mang. Moi buoc in ra lenh tuong ung de nguoi hoc go lai.
#   bash 02_matma_coban.sh            # chay ca 5 buoc
#   bash 02_matma_coban.sh 3          # chi chay buoc 3
# Khoa/mat khau trong script la GIA DINH de minh hoa; khong dung lai o noi khac.
set -e
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
CHON="${1:-all}"
chay() { [ "$CHON" = all ] || [ "$CHON" = "$1" ]; }
lenh() { echo "  \$ $*"; }

if chay 1; then
echo "== A1. Ham bam SHA-256 va hieu ung thac =="
lenh "printf '%s' 'AnToanThongTin' | sha256sum"
H1=$(printf '%s' 'AnToanThongTin' | sha256sum | cut -d' ' -f1); echo "    $H1"
lenh "printf '%s' 'AnToanThongTim' | sha256sum      # chi doi 1 ky tu cuoi"
H2=$(printf '%s' 'AnToanThongTim' | sha256sum | cut -d' ' -f1); echo "    $H2"
python3 - "$H1" "$H2" <<'PY'
import sys
a, b = (int(x, 16) for x in sys.argv[1:3])
d = bin(a ^ b).count("1")
print("  -> Hai gia tri bam khac nhau %d/256 bit (%.0f%%); ly tuong la ~50%%." % (d, d / 2.56))
PY
echo
fi

if chay 2; then
echo "== A2. Base64 la ma bieu dien, KHONG phai ma hoa =="
lenh "printf '%s' 'MatKhau@123' | base64"
B=$(printf '%s' 'MatKhau@123' | base64); echo "    $B"
lenh "echo '$B' | base64 -d"
echo "    $(echo "$B" | base64 -d)"
echo "  -> Khong can khoa, ai cung giai duoc."
echo
fi

if chay 3; then
echo "== A3. Ma hoa (AES-256-CTR) bao ve bi mat nhung KHONG bao ve toan ven =="
printf '%s' 'Chuyen 100000 dong cho SV001' > "$TMP/lenh.txt"
echo "  Ban ro: $(cat "$TMP/lenh.txt")"
lenh "openssl enc -aes-256-ctr -pbkdf2 -pass pass:KhoaDemo-Bai3 -in lenh.txt -out lenh.bin"
openssl enc -aes-256-ctr -pbkdf2 -pass pass:KhoaDemo-Bai3 -in "$TMP/lenh.txt" -out "$TMP/lenh.bin"
echo "  Ban ma (hex, 16 byte dau la 'Salted__' + salt):"
od -An -tx1 -v "$TMP/lenh.bin" | sed 's/^/   /'
lenh "openssl dgst -sha256 -hmac KhoaMAC-Bai3 lenh.bin        # MAC tinh TRUOC khi gui"
MAC1=$(openssl dgst -sha256 -hmac KhoaMAC-Bai3 "$TMP/lenh.bin" | awk '{print $NF}'); echo "    $MAC1"
# Ke tan cong KHONG biet khoa, chi lat 1 bit cua byte thu 7 ban ro (offset 16+7 trong tep)
python3 - "$TMP/lenh.bin" <<'PY'
import sys
p = sys.argv[1]
d = bytearray(open(p, "rb").read())
d[16 + 7] ^= 0x08          # '1' (0x31) XOR 0x08 = '9' (0x39)
open(p, "wb").write(d)
PY
echo "  [Ke tan cong sua 1 byte ban ma tren duong truyen, khong can biet khoa]"
lenh "openssl enc -d -aes-256-ctr -pbkdf2 -pass pass:KhoaDemo-Bai3 -in lenh.bin"
echo "    Giai ma: $(openssl enc -d -aes-256-ctr -pbkdf2 -pass pass:KhoaDemo-Bai3 -in "$TMP/lenh.bin")   <- khong bao loi!"
lenh "openssl dgst -sha256 -hmac KhoaMAC-Bai3 lenh.bin        # ben nhan tinh lai MAC"
MAC2=$(openssl dgst -sha256 -hmac KhoaMAC-Bai3 "$TMP/lenh.bin" | awk '{print $NF}'); echo "    $MAC2"
[ "$MAC1" != "$MAC2" ] && echo "  -> MAC KHONG KHOP: phat hien ban ma bi sua. AEAD (AES-GCM, ChaCha20-Poly1305) gop san hai viec nay."
echo
fi

if chay 4; then
echo "== A4. Salt khi luu mat khau =="
lenh "openssl passwd -6 'MatKhau@123'      # chay 2 lan"
echo "    $(openssl passwd -6 'MatKhau@123')"
echo "    $(openssl passwd -6 'MatKhau@123')"
echo "  -> Cung mat khau, salt ngau nhien khac nhau => gia tri luu khac nhau."
lenh "openssl passwd -6 -salt ictu2026 'MatKhau@123'      # co dinh salt, chay 2 lan"
echo "    $(openssl passwd -6 -salt ictu2026 'MatKhau@123')"
echo "    $(openssl passwd -6 -salt ictu2026 'MatKhau@123')"
echo "  -> Cung salt => trung nhau. Dinh dang \$6\$salt\$bam (SHA-512-crypt); Ubuntu 22.04 mac dinh dung yescrypt (\$y\$)."
echo
fi

if chay 5; then
echo "== A5. Entropy =="
lenh "openssl rand -base64 15      # mat khau ngau nhien 20 ky tu"
MK=$(openssl rand -base64 15); echo "    $MK"
head -c 500 /dev/zero | tr '\0' 'a' > "$TMP/lap.txt"
python3 - <<'PY' > "$TMP/van.txt"
s = ("Nhap mon an toan thong tin giup nguoi hoc hieu cac khai niem co ban ve bao mat, "
     "ma hoa, xac thuc va quan ly rui ro trong he thong thong tin cua to chuc. ")
print((s * 5)[:500], end="")
PY
openssl rand 500 > "$TMP/ngaunhien.bin"
python3 - "$TMP" <<'PY'
import math, sys
from collections import Counter
t = sys.argv[1]
def E(L, R): return L * math.log2(R)
print("  Gioi han tren E = L*log2(R) (chi dung cho chuoi sinh NGAU NHIEN):")
for mota, R, L in [("8 chu so", 10, 8), ("8 ky tu, 95 ky hieu", 95, 8),
                   ("12 ky tu, 95 ky hieu", 95, 12), ("16 chu thuong", 26, 16),
                   ("4 tu diceware", 7776, 4), ("openssl rand -base64 15 (20 ky tu)", 64, 20)]:
    print("    %-36s R=%-5d L=%-3d E = %5.1f bit" % (mota, R, L, E(L, R)))
def H(b):
    n = len(b); return max(0.0, -sum(c / n * math.log2(c / n) for c in Counter(b).values()))
print("  Entropy theo byte cua 3 mau 500 byte (toi da 8 bit/byte):")
for ten, mota in [("lap.txt", "500 chu 'a'"), ("van.txt", "van ban tu nhien"), ("ngaunhien.bin", "openssl rand 500")]:
    print("    %-22s %.2f bit/byte" % (mota, H(open(t + "/" + ten, "rb").read())))
print("  (Mau 500 byte ngau nhien chua dat 8 bit/byte vi qua ngan so voi 256 gia tri byte.)")
print("  -> Entropy du lieu cao la DAU HIEU du lieu da ma hoa/nen, khong phai ket luan;")
print("     va KHONG dung entropy theo tan suat ky tu de do do manh mat khau.")
PY
fi
