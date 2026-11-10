#!/usr/bin/env bash
# Bai 3 - Phan B/C: kiem tra ket noi TLS va chung thu cua MOT may chu, luu ket qua ra tep.
# Chi thuc hien vai ket noi TLS thong thuong nhu trinh duyet. KHONG dung de quet hang loat.
#
#   bash 03_kiem_tra_tls.sh example.com
#   bash 03_kiem_tra_tls.sh 127.0.0.1 4433 --sni lab3.attt.test                         # may chu lab
#   bash 03_kiem_tra_tls.sh 127.0.0.1 4433 --sni lab3.attt.test --cafile ~/bai3-lab/pki/root.crt
# Tuy chon: --sni TEN (mac dinh = may chu), --cafile TEP (tin them Root CA nay), -o TEP
set -o pipefail
[ -n "$1" ] || { sed -n 2,9p "$0"; exit 1; }
HOST="$1"; shift
PORT=443
if [ -n "$1" ] && [ "${1#-}" = "$1" ]; then PORT="$1"; shift; fi
SNI="$HOST"; CAFILE=""; OUT=""
while [ -n "$1" ]; do
  case "$1" in
    --sni) SNI="$2"; shift 2 ;;
    --cafile) CAFILE="$2"; shift 2 ;;
    -o) OUT="$2"; shift 2 ;;
    *) echo "[!] Tuy chon la: $1"; exit 1 ;;
  esac
done
case "$HOST" in *[!A-Za-z0-9.:-]*|"") echo "[!] Ten may chu khong hop le (chi 1 may chu)"; exit 1 ;; esac
OUT="${OUT:-ketqua_bai3_${SNI}.txt}"
TMP=$(mktemp -d); trap 'rm -rf "$TMP"' EXIT
CA=(); [ -n "$CAFILE" ] && CA=(-CAfile "$CAFILE")
sc() { timeout 15 openssl s_client -connect "$HOST:$PORT" -servername "$SNI" -verify_hostname "$SNI" "${CA[@]}" "$@" </dev/null 2>&1; }

{
echo "### Bai 3 - Kiem tra TLS: $HOST:$PORT (SNI $SNI) - $(date '+%Y-%m-%d %H:%M')"
echo "### $(openssl version)${CAFILE:+ ; tin them Root CA: $CAFILE}"
echo
echo "== Buoc 1-2: ket noi TLS 1.3, chuoi chung thu may chu gui =="
echo "\$ openssl s_client -connect $HOST:$PORT -servername $SNI -verify_hostname $SNI ${CAFILE:+-CAfile $CAFILE }-tls1_3 -showcerts"
sc -tls1_3 -showcerts >"$TMP/s13.txt"
if ! grep -q "^New, TLSv1.3" "$TMP/s13.txt"; then
  echo "[i] May chu khong chap nhan TLS 1.3 -> thu lai khong ep phien ban"
  sc -showcerts >"$TMP/s13.txt"
fi
if ! grep -q "BEGIN CERTIFICATE" "$TMP/s13.txt"; then
  echo "[!] Khong thiet lap duoc TLS. Thong bao loi:"; sed -n 1,15p "$TMP/s13.txt"; exit 1
fi
grep -E "^ *[0-9]+ s:|^ +i:" "$TMP/s13.txt"
N=$(grep -cE "^ *[0-9]+ s:" "$TMP/s13.txt")
if [ "$N" -gt 1 ]; then
  echo "  -> May chu gui $N chung thu (0 = may chu; 1..$((N-1)) = trung gian/cross-sign)."
else
  echo "  -> May chu CHI gui chung thu cua chinh no, KHONG kem chung thu trung gian."
fi
echo "  Duong xac minh OpenSSL dung (neu thanh cong, depth cao nhat = Root CA trong kho tin cay):"
grep -E "^depth=" "$TMP/s13.txt" | uniq | sed 's/^/    /'
grep -E "^New, |Server Temp Key|Negotiated TLS1.3 group" "$TMP/s13.txt"
grep -E "Verify return code" "$TMP/s13.txt" | tail -1 | sed 's/^ *//'
echo

echo "== Buoc 3: chi tiet chung thu may chu (chung thu 0) =="
sc </dev/null | openssl x509 -outform PEM >"$TMP/server.pem" 2>/dev/null
if [ -s "$TMP/server.pem" ]; then
  openssl x509 -in "$TMP/server.pem" -noout -subject -issuer -dates -serial
  openssl x509 -in "$TMP/server.pem" -noout -ext subjectAltName,keyUsage,extendedKeyUsage 2>/dev/null
  openssl x509 -in "$TMP/server.pem" -noout -text | grep -E "Public Key Algorithm|Public-Key:|NIST CURVE|Signature Algorithm" | sort -u | sed 's/^ */    /'
  HET=$(openssl x509 -in "$TMP/server.pem" -noout -enddate | cut -d= -f2)
  BD=$(openssl x509 -in "$TMP/server.pem" -noout -startdate | cut -d= -f2)
  echo "  -> Thoi han: $(( ($(date -d "$HET" +%s) - $(date -d "$BD" +%s)) / 86400 )) ngay; con lai $(( ($(date -d "$HET" +%s) - $(date +%s)) / 86400 )) ngay."
else
  echo "[!] Khong lay duoc chung thu (xem Buoc 1)"
fi
echo

echo "== Buoc 4: thu TLS 1.2 =="
sc -tls1_2 >"$TMP/s12.txt"
if grep -q "^New, TLSv1.2" "$TMP/s12.txt"; then
  grep -E "^New, |Server Temp Key" "$TMP/s12.txt"
else
  echo "  May chu KHONG chap nhan TLS 1.2 (hoac loi):"; grep -iE "alert|error" "$TMP/s12.txt" | head -2
fi
echo
echo "== Tom tat (dien vao phieu) =="
echo "  Phien ban / cipher : $(grep -E '^New, ' "$TMP/s13.txt" | head -1)"
echo "  Verify return code : $(grep -E 'Verify return code' "$TMP/s13.txt" | tail -1 | sed 's/^ *Verify return code: //')"
echo "  TLS 1.2            : $(grep -E '^New, ' "$TMP/s12.txt" | head -1 || echo 'khong chap nhan')"
} | tee "$OUT" || { echo "[!] Chua hoan tat - xem loi o tren"; exit 1; }
echo "[+] Da luu $OUT"
