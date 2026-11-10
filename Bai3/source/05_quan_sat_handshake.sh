#!/usr/bin/env bash
# Bai 3 - Phan D (mo rong): quan sat trinh tu bat tay TLS ma KHONG can quyen bat goi.
# Dung "openssl s_client -msg" de liet ke tung ban ghi TLS: tren duong truyen (cai Wireshark thay)
# ban ghi mang nhan gi, va ben trong (chi hai dau ket noi biet sau khi giai ma) la thong diep nao.
#
#   bash 05_quan_sat_handshake.sh example.com                 # TLS 1.3
#   bash 05_quan_sat_handshake.sh example.com --tls12         # so sanh TLS 1.2
#   bash 05_quan_sat_handshake.sh 127.0.0.1 4433 --sni lab3.attt.test [--tls12]
[ -n "$1" ] || { sed -n 2,9p "$0"; exit 1; }
HOST="$1"; shift
PORT=443
if [ -n "$1" ] && [ "${1#-}" = "$1" ]; then PORT="$1"; shift; fi
SNI="$HOST"; VER=(-tls1_3)
while [ -n "$1" ]; do
  case "$1" in
    --sni) SNI="$2"; shift 2 ;;
    --tls12) VER=(-tls1_2); shift ;;
    *) echo "[!] Tuy chon la: $1"; exit 1 ;;
  esac
done
case "$HOST" in *[!A-Za-z0-9.:-]*|"") echo "[!] Ten may chu khong hop le"; exit 1 ;; esac

echo "\$ openssl s_client -connect $HOST:$PORT -servername $SNI ${VER[*]} -msg </dev/null"
echo "Huong  | Tren duong truyen (Wireshark) | Ben trong ban ghi"
echo "-------+-------------------------------+---------------------------"
timeout 15 openssl s_client -connect "$HOST:$PORT" -servername "$SNI" "${VER[@]}" -msg </dev/null 2>/dev/null |
awk '
function ten(t) { return t=="16"?"Handshake":t=="14"?"ChangeCipherSpec":t=="15"?"Alert":t=="17"?"Application Data":"type " t }
function xuat() {
  if (!n) return
  h = (huong[n]==">>>") ? "C -> S" : "S -> C"
  mh = (loai[n]=="17" || (ccs[huong[n]] && loai[n]!="14"))
  tr = ten(loai[n]) (mh ? " (MA HOA)" : " (ro)")
  bt = msg[n]; if (bt=="") bt = (loai[n]=="14") ? "(chi de tuong thich nguoc)" : "-"
  k = split(bt, ds, "|")
  for (i = 1; i <= k; i++)
    printf "%-6s | %-29s | %s%s\n", (i==1 ? h : ""), (i==1 ? tr : ""), (mh ? "[an] " : ""), ds[i]
  if (loai[n]=="14") ccs[huong[n]] = 1
}
/^(>>>|<<<) .*RecordHeader/ { xuat(); n++; huong[n]=$1; chohex=1; next }
chohex && /^ +[0-9a-f][0-9a-f] / { loai[n]=$1; chohex=0; next }
/^(>>>|<<<) TLS/ && !/InnerContent|ChangeCipherSpec/ {
  m=$0; sub(/.*\], */, "", m); if (m ~ /^\[/ || m=="") { m=$0; sub(/.*, /, "", m) }
  if ($0 ~ /Alert/) m = "Alert: " m
  msg[n] = (msg[n]=="") ? m : msg[n] "|" m
}
END { xuat() }'
echo
echo "Ghi chu: C = may khach (openssl), S = may chu. Ban ghi (MA HOA) tren Wireshark chi hien"
echo "'Application Data' / 'Encrypted Handshake Message'; [an] = noi dung chi hai dau ket noi"
echo "doc duoc sau khi giai ma. Nhieu dong cung mot ban ghi = may chu gop nhieu thong diep."
