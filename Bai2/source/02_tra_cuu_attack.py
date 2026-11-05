#!/usr/bin/env python3
"""Bai 2 - Tra cuu MITRE ATT&CK ngoai tuyen (doc tep STIX enterprise-attack.json).

Cach dung:
  python3 02_tra_cuu_attack.py nhom G0050            # ky thuat cua nhom, gom theo chien thuat
  python3 02_tra_cuu_attack.py nhom G0050 --chi-tiet --bien-phap   # + danh sach ky thuat, xep hang Mitigation
  python3 02_tra_cuu_attack.py nhom G0016 --ca-chien-dich          # gop ca ky thuat cua chien dich (Cxxxx)
  python3 02_tra_cuu_attack.py kythuat T1566         # mo ta ngan + bien phap giam thieu (Mitigations)
  python3 02_tra_cuu_attack.py kythuat T1566 --nhom G0050   # them: nhom co dung ky thuat nay khong
  python3 02_tra_cuu_attack.py nhom G0050 -o ketqua_bai2_nhom.txt   # dong thoi ghi ra tep

Du lieu mac dinh: ~/.cache/nhapmon-attt/enterprise-attack.json (do 01_setup_moitruong.sh tai ve).
Chi dung thu vien chuan cua Python 3 (Ubuntu 22.04 co san python3).
"""
import argparse
import json
import os
import re
import sys

MAC_DINH = os.path.expanduser("~/.cache/nhapmon-attt/enterprise-attack.json")


def ma_ngoai(obj):
    """Ma ATT&CK (Txxxx, Gxxxx, Mxxxx, TAxxxx) cua mot doi tuong STIX."""
    for ref in obj.get("external_references", []):
        if ref.get("source_name") == "mitre-attack":
            return ref.get("external_id")
    return None


def con_hieu_luc(obj):
    return not obj.get("revoked") and not obj.get("x_mitre_deprecated")


def cau_dau(text):
    """Cau dau tien cua mo ta, bo trich dan (Citation: ...) va lien ket markdown."""
    text = re.sub(r"\(Citation:[^)]*\)", "", text or "")
    text = re.sub(r"\[([^\]]+)\]\([^)]*\)", r"\1", text)
    text = re.sub(r"<[^>]+>", "", text)          # bo the HTML nhu <code>

    text = " ".join(text.split())
    m = re.search(r"^(.+?[.!?])(\s|$)", text)
    return m.group(1) if m else text


class AttackDB:
    def __init__(self, duong_dan):
        if not os.path.isfile(duong_dan):
            sys.exit("[!] Khong thay du lieu: %s\n    Chay truoc: bash 01_setup_moitruong.sh" % duong_dan)
        with open(duong_dan, encoding="utf-8") as f:
            objs = json.load(f)["objects"]
        self.theo_id = {o["id"]: o for o in objs}
        self.theo_ma = {}
        for o in objs:
            ma = ma_ngoai(o)
            if ma and con_hieu_luc(o) and o["type"] in ("attack-pattern", "intrusion-set", "course-of-action"):
                self.theo_ma[ma.upper()] = o
        self.phien_ban = next((o.get("x_mitre_version") for o in objs if o["type"] == "x-mitre-collection"), "?")
        matran = next(o for o in objs if o["type"] == "x-mitre-matrix")
        # Thu tu chien thuat dung nhu tren ma tran Navigator
        self.chien_thuat = []
        for ref in matran["tactic_refs"]:
            t = self.theo_id[ref]
            self.chien_thuat.append((t["x_mitre_shortname"], t["name"], ma_ngoai(t)))
        self.quan_he = [o for o in objs if o["type"] == "relationship" and con_hieu_luc(o)]

    def tim(self, ma, loai):
        o = self.theo_ma.get(ma.upper())
        if not o or o["type"] != loai:
            sys.exit("[!] Khong tim thay %s trong ATT&CK %s (hoac da bi thu hoi)." % (ma, self.phien_ban))
        return o

    def chien_dich_cua_nhom(self, nhom):
        """Cac chien dich (campaign, ma Cxxxx) duoc quy cho nhom (attributed-to)."""
        kq = []
        for r in self.quan_he:
            if r["relationship_type"] == "attributed-to" and r["target_ref"] == nhom["id"]:
                c = self.theo_id.get(r["source_ref"])
                if c and c["type"] == "campaign" and con_hieu_luc(c):
                    kq.append(c)
        return sorted(kq, key=ma_ngoai)

    def ky_thuat_cua_nhom(self, nhom):
        """Ky thuat ma doi tuong (nhom hoac chien dich) 'uses' truc tiep."""
        kq = []
        for r in self.quan_he:
            if r["relationship_type"] == "uses" and r["source_ref"] == nhom["id"]:
                t = self.theo_id.get(r["target_ref"])
                if t and t["type"] == "attack-pattern" and con_hieu_luc(t):
                    kq.append(t)
        return kq

    def bien_phap(self, kt):
        kq = []
        for r in self.quan_he:
            if r["relationship_type"] == "mitigates" and r["target_ref"] == kt["id"]:
                m = self.theo_id.get(r["source_ref"])
                if m and con_hieu_luc(m):
                    kq.append(m)
        return sorted(kq, key=ma_ngoai)

    def ten_chien_thuat(self, kt):
        ma = {p["phase_name"] for p in kt.get("kill_chain_phases", [])
              if p.get("kill_chain_name") == "mitre-attack"}
        return [ten for (sn, ten, _) in self.chien_thuat if sn in ma]


def ten_day_du(db, kt):
    """Ten ky thuat; voi sub-technique ghi them ten ky thuat cha."""
    ma = ma_ngoai(kt)
    if kt.get("x_mitre_is_subtechnique") and "." in ma:
        cha = db.theo_ma.get(ma.split(".")[0])
        if cha:
            return "%s: %s" % (cha["name"], kt["name"])
    return kt["name"]


def lenh_nhom(db, args, out):
    nhom = db.tim(args.ma, "intrusion-set")
    kts = db.ky_thuat_cua_nhom(nhom)
    out("Nhom %s (%s) - ATT&CK Enterprise %s" % (nhom["name"], ma_ngoai(nhom), db.phien_ban))
    out("Ten khac: %s" % ", ".join(a for a in nhom.get("aliases", []) if a != nhom["name"]))
    out("So ky thuat/sub-technique nhom da dung truc tiep: %d" % len(kts))
    cds = db.chien_dich_cua_nhom(nhom)
    if cds:
        ids_nhom = {k["id"] for k in kts}
        ids_cd = {}
        for c in cds:
            kc = db.ky_thuat_cua_nhom(c)
            out("Chien dich quy cho nhom: %s %s (%s -> %s), %d ky thuat" % (
                ma_ngoai(c), c["name"], c.get("first_seen", "?")[:7], c.get("last_seen", "?")[:7], len(kc)))
            for k in kc:
                ids_cd[k["id"]] = k
        chi_cd = [k for i, k in ids_cd.items() if i not in ids_nhom]
        out("  -> Navigator: xanh = chi nhom; hong = nhom + chien dich (%d); do = chi chien dich (%d)"
            % (len(ids_nhom & set(ids_cd)), len(chi_cd)))
        if args.ca_chien_dich:
            kts = kts + chi_cd
            out("  -> Bang duoi DA GOP ky thuat cua chien dich: %d ky thuat" % len(kts))
        else:
            out("  -> Bang duoi CHI tinh ky thuat cua nhom (them --ca-chien-dich de gop).")
    else:
        out("Chien dich quy cho nhom: (khong co) -> Navigator chi to mot mau.")
    out("")
    out("== So ky thuat theo chien thuat (doc ban do nhiet bang so lieu) ==")
    bang = []
    for sn, ten, ma_ct in db.chien_thuat:
        trong_ct = sorted((k for k in kts if sn in {p["phase_name"] for p in k.get("kill_chain_phases", [])}),
                          key=ma_ngoai)
        bang.append((ten, ma_ct, trong_ct))
        out("%-22s %-7s %3d  %s" % (ten, ma_ct, len(trong_ct), "#" * len(trong_ct)))
    out("")
    out("(Mot ky thuat co the thuoc nhieu chien thuat nen tong cac cot co the lon hon so ky thuat.)")
    if args.bien_phap:
        dem = {}
        khong_co = 0
        for k in kts:
            bps = db.bien_phap(k)
            if not bps:
                khong_co += 1
            for m in bps:
                dem.setdefault(ma_ngoai(m), [m["name"], 0])[1] += 1
        out("")
        out("== Bien phap (Mitigation) phu duoc nhieu ky thuat cua nhom nhat ==")
        for ma, (ten, n) in sorted(dem.items(), key=lambda x: (-x[1][1], x[0]))[:10]:
            out("  %-6s %-40s %3d / %d ky thuat" % (ma, ten, n, len(kts)))
        out("  (%d ky thuat khong co Mitigation trong ATT&CK -> can dua vao phat hien/giam sat.)" % khong_co)
    if args.chi_tiet:
        for ten, ma_ct, trong_ct in bang:
            if not trong_ct:
                continue
            out("")
            out("-- %s (%s) --" % (ten, ma_ct))
            for k in trong_ct:
                out("  %-10s %s" % (ma_ngoai(k), ten_day_du(db, k)))


def lenh_kythuat(db, args, out):
    kt = db.tim(args.ma, "attack-pattern")
    out("%s - %s (ATT&CK Enterprise %s)" % (ma_ngoai(kt), ten_day_du(db, kt), db.phien_ban))
    out("Chien thuat : %s" % ", ".join(db.ten_chien_thuat(kt)))
    out("Mo ta ngan  : %s" % cau_dau(kt.get("description")))
    out("Trang web   : https://attack.mitre.org/techniques/%s/" % ma_ngoai(kt).replace(".", "/"))
    if args.nhom:
        nhom = db.tim(args.nhom, "intrusion-set")
        ids = {k["id"] for k in db.ky_thuat_cua_nhom(nhom)}
        if kt["id"] in ids:
            co = "CO"
        else:
            con = [ma_ngoai(k) for k in db.ky_thuat_cua_nhom(nhom)
                   if ma_ngoai(k).startswith(ma_ngoai(kt) + ".")]
            co = "KHONG truc tiep" + (" (nhung co sub-technique: %s)" % ", ".join(sorted(con)) if con else "")
        out("Nhom %s dung ky thuat nay? %s" % (nhom["name"], co))
    bps = db.bien_phap(kt)
    out("")
    out("== Bien phap giam thieu (Mitigations): %d ==" % len(bps))
    if not bps:
        out("  (ATT&CK khong liet ke Mitigation; xem muc Detection tren trang web.)")
    for m in bps:
        out("  %-6s %s" % (ma_ngoai(m), m["name"]))


def main():
    chung = argparse.ArgumentParser(add_help=False)
    chung.add_argument("--du-lieu", default=MAC_DINH, help="tep enterprise-attack.json")
    chung.add_argument("-o", "--ra-tep", help="ghi them ket qua ra tep van ban")
    p = argparse.ArgumentParser(description="Tra cuu MITRE ATT&CK ngoai tuyen (Bai 2).")
    sub = p.add_subparsers(dest="lenh", required=True)
    a = sub.add_parser("nhom", parents=[chung], help="ky thuat cua mot nhom APT, vd G0050")
    a.add_argument("ma")
    a.add_argument("--chi-tiet", action="store_true", help="liet ke tung ky thuat trong moi chien thuat")
    a.add_argument("--ca-chien-dich", action="store_true",
                   help="gop ca ky thuat cua cac chien dich (campaign) quy cho nhom")
    a.add_argument("--bien-phap", action="store_true",
                   help="xep hang Mitigation theo so ky thuat cua nhom ma no phu duoc")
    b = sub.add_parser("kythuat", parents=[chung], help="thong tin + Mitigations cua mot ky thuat, vd T1566")
    b.add_argument("ma")
    b.add_argument("--nhom", help="kiem tra nhom (vd G0050) co dung ky thuat nay khong")
    args = p.parse_args()

    dong = []

    def out(s):
        print(s)
        dong.append(s)

    db = AttackDB(args.du_lieu)
    (lenh_nhom if args.lenh == "nhom" else lenh_kythuat)(db, args, out)
    if args.ra_tep:
        with open(args.ra_tep, "w", encoding="utf-8") as f:
            f.write("\n".join(dong) + "\n")
        print("\n[+] Da ghi %s" % args.ra_tep)


if __name__ == "__main__":
    main()
