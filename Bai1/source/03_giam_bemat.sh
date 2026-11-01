#!/usr/bin/env bash
# Bai 1 - Buoc 8: giam be mat tan cong va quet lai de so sanh
# Cach dung: ./03_giam_bemat.sh [IP_muc_tieu]   (mac dinh 127.0.0.1)
TARGET="${1:-127.0.0.1}"
sudo systemctl stop vsftpd && sudo systemctl disable vsftpd
echo "== Quet lai sau khi tat vsftpd (so cong mo giam di) =="
nmap -sV "$TARGET"
