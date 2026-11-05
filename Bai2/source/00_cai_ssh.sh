#!/usr/bin/env bash
# Bai 2 - Cai & bat SSH tren may ao de lam viec tu terminal may host
set -e
sudo apt update
sudo apt install -y openssh-server
sudo systemctl enable --now ssh
sudo ufw allow 22/tcp 2>/dev/null || true
echo "[+] SSH da bat (active). IP may ao:"
hostname -I
echo "[i] Tu may host:  ssh <user>@<IP o tren>"
