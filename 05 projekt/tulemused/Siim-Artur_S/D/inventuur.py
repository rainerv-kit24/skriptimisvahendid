#!/usr/bin/env python3

#Süsteemi inventuur — töötab Windowsis, macOS-is ja Linuxis.

#Kasutus:
#    python inventuur.py
#    python inventuur.py --väljund minu_inventuur.json
#    python inventuur.py --stdout | jq .


import argparse
import getpass
import json
import platform
import socket
import sys
from datetime import datetime, timezone
from pathlib import Path

try:
    import psutil
except ImportError:
    print("Viga: 'psutil' pole paigaldatud. Käivita: pip install psutil")
    sys.exit(1)


# ---------------------------------------------------------------------------
# Andmete kogumine
# ---------------------------------------------------------------------------

def kogu_os() -> dict:
    süsteem  = platform.system()
    versioon = platform.version()
    release  = platform.release()
    arhitektuur = platform.architecture()[0]

    # macOS annab release'iks "Darwin"
    if süsteem == "Darwin":
        release = platform.mac_ver()[0] or release

    return {
        "süsteem":     süsteem,
        "versioon":    versioon,
        "release":     release,
        "arhitektuur": arhitektuur,
    }


def kogu_cpu() -> dict:
    mudel = ""

    try:
        if platform.system() == "Windows":
            import winreg
            key  = winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE,
                                  r"HARDWARE\DESCRIPTION\System\CentralProcessor\0")
            mudel = winreg.QueryValueEx(key, "ProcessorNameString")[0].strip()
        elif platform.system() == "Darwin":
            import subprocess
            mudel = subprocess.check_output(
                ["sysctl", "-n", "machdep.cpu.brand_string"],
                text=True
            ).strip()
        else:
            # Linux
            with open("/proc/cpuinfo") as f:
                for rida in f:
                    if rida.startswith("model name"):
                        mudel = rida.split(":", 1)[1].strip()
                        break
    except Exception:
        mudel = platform.processor() or "Teadmata"

    return {
        "mudel":                mudel,
        "südamikud_füüsilised": psutil.cpu_count(logical=False) or 0,
        "südamikud_loogilised": psutil.cpu_count(logical=True)  or 0,
        "kasutus_protsent":     psutil.cpu_percent(interval=0.5),
    }


def kogu_mälu() -> dict:
    m = psutil.virtual_memory()
    return {
        "kokku_gb":        round(m.total    / 1e9, 1),
        "kasutuses_gb":    round(m.used     / 1e9, 1),
        "vaba_gb":         round(m.available/ 1e9, 1),
        "kasutus_protsent": m.percent,
    }


def kogu_kettad() -> list:
    kettad = []
    for partitsioon in psutil.disk_partitions(all=False):
        try:
            kasutus = psutil.disk_usage(partitsioon.mountpoint)
            kettad.append({
                "mount":      partitsioon.mountpoint,
                "fs":         partitsioon.fstype,
                "kokku_gb":   round(kasutus.total / 1e9, 1),
                "kasutuses_gb": round(kasutus.used  / 1e9, 1),
                "vaba_gb":    round(kasutus.free  / 1e9, 1),
                "vaba_protsent": round(100 - kasutus.percent, 1),
            })
        except PermissionError:
            continue
    return kettad


def kogu_võrk() -> list:
    kaardid = []
    aadressid = psutil.net_if_addrs()
    staatused = psutil.net_if_stats()

    for nimi, aadresside_list in aadressid.items():
        # Leia IPv4 aadress
        ipv4 = next(
            (a.address for a in aadresside_list
             if a.family.name in ("AF_INET", "2")),
            None
        )

        if ipv4 is None:
            import socket as _sock
            ipv4 = next(
                (a.address for a in aadresside_list
                 if a.family == _sock.AF_INET),
                None
            )

        ühendatud = staatused[nimi].isup if nimi in staatused else False

        kaardid.append({
            "nimi":      nimi,
            "ipv4":      ipv4,
            "ühendatud": ühendatud,
        })

    # Sorteeri: ühendatud ees, siis nime järgi
    kaardid.sort(key=lambda x: (not x["ühendatud"], x["nimi"]))
    return kaardid


def kogu_inventuur() -> dict:
    hostname = socket.gethostname()
    kasutaja = getpass.getuser()

    return {
        "ajamäär":  datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "host":     hostname,
        "kasutaja": kasutaja,
        "os":       kogu_os(),
        "python":   platform.python_version(),
        "cpu":      kogu_cpu(),
        "mälu":     kogu_mälu(),
        "kettad":   kogu_kettad(),
        "võrk":     kogu_võrk(),
    }


# ---------------------------------------------------------------------------
# Konsooli väljund
# ---------------------------------------------------------------------------

def prindi_kokkuvõte(andmed: dict, salvestatud: str | None = None):
    os_info = andmed["os"]
    cpu     = andmed["cpu"]
    mälu    = andmed["mälu"]

    os_kuva = f"{os_info['süsteem']} {os_info['release']} ({os_info['versioon']})"

    print("\n=== Süsteemi inventuur ===")
    print(f"Host:        {andmed['host']}")
    print(f"Kasutaja:    {andmed['kasutaja']}")
    print(f"OS:          {os_kuva}")
    print(f"Python:      {andmed['python']}")
    print(f"CPU:         {cpu['mudel']}")
    print(f"Südamikke:   {cpu['südamikud_füüsilised']} ({cpu['südamikud_loogilised']} loogilist)")
    print(f"RAM:         {mälu['kokku_gb']} GB (kasutuses {mälu['kasutus_protsent']}%)")

    print("Kettad:")
    for ketas in andmed["kettad"]:
        print(f"  {ketas['mount']:<6} Total: {ketas['kokku_gb']} GB  "
              f"Free: {ketas['vaba_gb']} GB  ({ketas['vaba_protsent']}% vaba)")

    print("Võrgukaardid:")
    for kaart in andmed["võrk"]:
        if kaart["ühendatud"] and kaart["ipv4"]:
            ip_kuva = kaart["ipv4"]
        else:
            ip_kuva = "(ühendamata)"
        print(f"  {kaart['nimi']:<18} {ip_kuva}")

    if salvestatud:
        print(f"Salvestatud: {salvestatud}")
    print()


# ---------------------------------------------------------------------------
# Peafunktsioon
# ---------------------------------------------------------------------------

def parse_args():
    p = argparse.ArgumentParser(description="Süsteemi inventuur")
    p.add_argument("--väljund", metavar="FAIL",
                   help="Väljundfaili nimi (vaikimisi automaatne)")
    p.add_argument("--stdout", action="store_true",
                   help="Prindi JSON konsooli (torustiku jaoks)")
    return p.parse_args()


def main():
    args = parse_args()

    andmed = kogu_inventuur()

    # Väljundfaili nimi
    kuupäev  = datetime.now().strftime("%Y-%m-%d")
    vaiknimi = f"inventuur_{andmed['host']}_{kuupäev}.json"
    failinimi = args.väljund or vaiknimi

    json_sisu = json.dumps(andmed, ensure_ascii=False, indent=2)

    if args.stdout:
        print(json_sisu)
        return

    # Salvesta faili
    väljund_tee = Path(failinimi)
    väljund_tee.write_text(json_sisu, encoding="utf-8")

    # Konsooli kokkuvõte
    prindi_kokkuvõte(andmed, salvestatud=failinimi)


if __name__ == "__main__":
    main()
