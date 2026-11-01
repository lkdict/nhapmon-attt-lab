#!/usr/bin/env bash
# Bai 1 - Quet nhan dien be mat tan cong
# CHI quet muc tieu duoc cap phep: 127.0.0.1, may ao noi bo, hoac IP giang vien cap.
# Cach dung: ./02_quet_nmap.sh [IP_muc_tieu]   (mac dinh 127.0.0.1)
TARGET="${1:-127.0.0.1}"
echo "== Buoc 1: kiem tra Nmap =="
nmap --version
echo "== Buoc 3: quet cong co ban ($TARGET) =="
nmap "$TARGET"
echo "== Buoc 4: nhan dien dich vu / phien ban =="
nmap -sV "$TARGET"
echo "== Buoc 5 (tuy chon): do he dieu hanh =="
sudo nmap -O "$TARGET"
echo "== Buoc 6: quet cong cu the + xuat file ketqua_bai1.txt =="
nmap -p 21,22,80,443,3306 -sV "$TARGET" -oN ketqua_bai1.txt
echo "[+] Da luu ketqua_bai1.txt"
