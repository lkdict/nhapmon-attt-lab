#!/usr/bin/env bash
# Bai 1 - Dung moi truong lab + be mat tan cong mau (chay tren may ao Ubuntu)
set -e
sudo apt update
sudo apt install -y nmap openssh-server apache2 vsftpd
sudo systemctl start ssh apache2 vsftpd
echo "[+] Dich vu mau da bat (ssh/apache2/vsftpd)."
echo "[+] IP may ao trong mang lab:"
hostname -I
