#!/usr/bin/env bash
# Bai 3 - Chuan bi moi truong: OpenSSL 3.x, kho CA, python3; tao PKI lab gia dinh.
# Can Internet MOT LAN de cai goi (card NAT / Default Switch).
#   bash 01_setup_moitruong.sh               # cai goi con thieu + tao PKI lab
#   bash 01_setup_moitruong.sh --wireshark   # them tshark + tcpdump cho phan mo rong
set -e
cd "$(dirname "$0")"

GOI="openssl ca-certificates python3"
[ "$1" = "--wireshark" ] && GOI="$GOI tshark tcpdump"
THIEU=""
for g in $GOI; do dpkg -s "$g" >/dev/null 2>&1 || THIEU="$THIEU $g"; done
if [ -n "$THIEU" ]; then
  echo "[+] Cai goi con thieu:$THIEU"
  sudo apt update
  # tshark hoi "cho phep nguoi thuong bat goi?" -> tra loi mac dinh (khong) de khong bi treo
  sudo DEBIAN_FRONTEND=noninteractive apt install -y $THIEU
fi

echo "== Kiem tra =="
openssl version
python3 --version
echo "Gio he thong: $(date -u '+%Y-%m-%d %H:%M:%S UTC')   (sai gio -> kiem tra chung thu bao loi han dung)"
NAM=$(date +%Y)
[ "$NAM" -lt 2025 ] && echo "[!] Gio he thong co ve sai. Chay: sudo timedatectl set-ntp true"
if getent hosts example.com >/dev/null; then
  echo "[+] DNS/Internet: phan giai duoc example.com"
else
  echo "[!] Khong phan giai duoc example.com -> Phan B dung may chu du phong (Phan C, 127.0.0.1:4433)"
fi
command -v tshark >/dev/null && echo "[+] Co tshark (phan mo rong)" || echo "[i] Chua co tshark (chi can cho phan mo rong: bash $0 --wireshark)"

echo "== Tao PKI lab gia dinh =="
bash ./04_maychu_lab.sh tao-pki
echo "[i] Buoc tiep: bash 02_matma_coban.sh"
