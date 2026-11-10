#!/usr/bin/env bash
# Bai 3 - May chu TLS thu nghiem CHAY TREN CHINH MAY AO (127.0.0.1:4433).
# Dung lam may chu du phong khi khong co Internet va de quan sat chuoi tin cay.
#
#   bash 04_maychu_lab.sh tao-pki              # tao Root CA -> Intermediate CA -> chung thu may chu
#   bash 04_maychu_lab.sh start                # chay may chu, gui kem chung thu trung gian
#   bash 04_maychu_lab.sh start --thieu-trung-gian   # cau hinh SAI: khong gui chung thu trung gian
#   bash 04_maychu_lab.sh status | stop
#
# Toan bo CA, khoa va chung thu la GIA DINH, chi dung trong lab; khong cai Root CA nay vao
# trinh duyet hay kho tin cay cua he dieu hanh.
set -e
LAB="${BAI3_LAB:-$HOME/bai3-lab}"
PKI="$LAB/pki"
PORT="${BAI3_PORT:-4433}"
TEN_MAY_CHU="lab3.attt.test"
PIDFILE="$LAB/s_server.pid"
LOG="$LAB/s_server.log"

tao_pki() {
  if [ -s "$PKI/server.crt" ] && [ "$1" != "--tao-lai" ]; then
    echo "[i] Da co PKI lab: $PKI (them --tao-lai de tao lai)"
    return 0
  fi
  mkdir -p "$PKI"
  cd "$PKI"
  rm -f ./*.crt ./*.key ./*.csr ./*.srl
  cat > openssl-lab.cnf <<EOF
[req]
distinguished_name = dn
prompt = no
[dn]
CN = placeholder
[v3_root]
basicConstraints = critical,CA:TRUE
keyUsage = critical,keyCertSign,cRLSign
subjectKeyIdentifier = hash
[v3_inter]
basicConstraints = critical,CA:TRUE,pathlen:0
keyUsage = critical,keyCertSign,cRLSign
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always
[v3_server]
basicConstraints = critical,CA:FALSE
keyUsage = critical,digitalSignature
extendedKeyUsage = serverAuth
subjectKeyIdentifier = hash
authorityKeyIdentifier = keyid:always
subjectAltName = DNS:${TEN_MAY_CHU},DNS:localhost,IP:127.0.0.1
EOF
  umask 077
  for k in root inter server; do
    openssl genpkey -algorithm EC -pkeyopt ec_paramgen_curve:P-256 -out "$k.key"
  done
  umask 022
  # 1) Root CA tu ky (10 nam)
  openssl req -x509 -new -config openssl-lab.cnf -extensions v3_root -key root.key -sha256 \
    -days 3650 -subj "/C=VN/O=ICTU Lab (gia dinh)/CN=ICTU Lab Root CA" -out root.crt
  # 2) Intermediate CA do Root CA ky (5 nam)
  openssl req -new -config openssl-lab.cnf -key inter.key \
    -subj "/C=VN/O=ICTU Lab (gia dinh)/CN=ICTU Lab Issuing CA 1" -out inter.csr
  openssl x509 -req -in inter.csr -CA root.crt -CAkey root.key -CAcreateserial -sha256 \
    -days 1825 -extfile openssl-lab.cnf -extensions v3_inter -out inter.crt 2>/dev/null
  # 3) May chu tao CSR (PKCS#10), Intermediate CA ky ra chung thu X.509 (90 ngay)
  openssl req -new -config openssl-lab.cnf -key server.key \
    -subj "/C=VN/O=Truong Dai hoc X (gia dinh)/CN=${TEN_MAY_CHU}" -out server.csr
  openssl x509 -req -in server.csr -CA inter.crt -CAkey inter.key -CAcreateserial -sha256 \
    -days 90 -extfile openssl-lab.cnf -extensions v3_server -out server.crt 2>/dev/null
  echo "[+] Da tao PKI lab trong $PKI:"
  echo "    root.crt  (ICTU Lab Root CA)  -> inter.crt (ICTU Lab Issuing CA 1) -> server.crt (${TEN_MAY_CHU})"
  openssl verify -CAfile root.crt -untrusted inter.crt server.crt
}

dang_chay() {
  [ -s "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null
}

start() {
  [ -s "$PKI/server.crt" ] || tao_pki
  if dang_chay; then
    echo "[i] May chu dang chay (PID $(cat "$PIDFILE")). Muon doi cau hinh: stop roi start lai."
    return 0
  fi
  CHAIN=(-cert_chain "$PKI/inter.crt")
  MOTA="gui kem chung thu trung gian (cau hinh DUNG)"
  if [ "$1" = "--thieu-trung-gian" ]; then
    CHAIN=()
    MOTA="KHONG gui chung thu trung gian (cau hinh SAI - de quan sat loi)"
  fi
  if ss -lnt 2>/dev/null | grep -q ":$PORT "; then
    echo "[!] Cong $PORT dang bi chuong trinh khac dung. Doi cong: BAI3_PORT=4434 bash $0 start"
    echo "    (nho dung cong moi trong cac lenh s_client)"; exit 1
  fi
  nohup openssl s_server -accept "127.0.0.1:$PORT" -cert "$PKI/server.crt" -key "$PKI/server.key" \
    "${CHAIN[@]}" -www >"$LOG" 2>&1 </dev/null &
  echo $! >"$PIDFILE"
  sleep 1
  if dang_chay; then
    echo "[+] May chu TLS lab: 127.0.0.1:$PORT, ten ${TEN_MAY_CHU}, $MOTA"
    echo "[i] Thu: openssl s_client -connect 127.0.0.1:$PORT -servername ${TEN_MAY_CHU} -showcerts </dev/null"
  else
    echo "[!] Khong khoi dong duoc. Xem $LOG"; cat "$LOG"; exit 1
  fi
}

stop() {
  if dang_chay; then kill "$(cat "$PIDFILE")"; echo "[+] Da dung may chu lab."; else echo "[i] May chu khong chay."; fi
  rm -f "$PIDFILE"
}

case "${1:-}" in
  tao-pki) tao_pki "$2" ;;
  start)   start "$2" ;;
  stop)    stop ;;
  status)  if dang_chay; then echo "[+] Dang chay (PID $(cat "$PIDFILE"))"; ss -lnt 2>/dev/null | grep ":$PORT " || true; else echo "[i] Khong chay"; fi ;;
  *) echo "Cach dung: bash $0 {tao-pki [--tao-lai] | start [--thieu-trung-gian] | status | stop}"; exit 1 ;;
esac
