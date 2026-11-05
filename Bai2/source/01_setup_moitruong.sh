#!/usr/bin/env bash
# Bai 2 - Chuan bi moi truong: python3 + tai du lieu MITRE ATT&CK (STIX) ve may ao.
# Can Internet MOT LAN (card NAT / Default Switch). Sau do tra cuu hoan toan ngoai tuyen.
# Co the dat ATTACK_VERSION=... de doi phien ban (mac dinh 20.0, khop vi du trong tai lieu).
set -e
ATTACK_VERSION="${ATTACK_VERSION:-20.0}"
DIR="$HOME/.cache/nhapmon-attt"
FILE="$DIR/enterprise-attack.json"
URL="https://raw.githubusercontent.com/mitre-attack/attack-stix-data/master/enterprise-attack/enterprise-attack-${ATTACK_VERSION}.json"

if ! command -v python3 >/dev/null || ! command -v curl >/dev/null; then
  sudo apt update
  sudo apt install -y python3 curl
fi
python3 --version

mkdir -p "$DIR"
if [ -s "$FILE" ] && [ "$1" != "--tai-lai" ]; then
  echo "[i] Da co du lieu: $FILE (them --tai-lai de tai lai)"
else
  echo "[+] Tai ATT&CK Enterprise ${ATTACK_VERSION} (~55 MB) ..."
  curl -fL --retry 3 -o "$FILE.tmp" "$URL"
  mv "$FILE.tmp" "$FILE"
fi

python3 - "$FILE" <<'PY'
import json, sys
d = json.load(open(sys.argv[1], encoding="utf-8"))
v = next(o.get("x_mitre_version") for o in d["objects"] if o["type"] == "x-mitre-collection")
ap = [o for o in d["objects"] if o["type"] == "attack-pattern"]
act = [o for o in ap if not o.get("revoked") and not o.get("x_mitre_deprecated")]
sub = sum(1 for o in act if o.get("x_mitre_is_subtechnique"))
print("[+] Du lieu hop le: ATT&CK Enterprise %s, %d ky thuat + %d sub-technique dang hieu luc"
      % (v, len(act) - sub, sub))
print("    (tep chua %d doi tuong attack-pattern, ke ca %d da thu hoi/ngung dung)" % (len(ap), len(ap) - len(act)))
PY
echo "[i] Buoc tiep: python3 02_tra_cuu_attack.py nhom G0050"
