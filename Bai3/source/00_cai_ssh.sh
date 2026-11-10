#!/usr/bin/env bash
# Bai 3 - Cai & bat SSH tren may ao de lam viec tu terminal may host
set -e
sudo apt update
sudo apt install -y openssh-server git
sudo systemctl enable --now ssh
sudo ufw allow 22/tcp 2>/dev/null || true
echo "[+] SSH: $(systemctl is-active ssh). IP may ao:"
hostname -I
echo "[i] Tu may host:  ssh <user>@<IP o tren>"
