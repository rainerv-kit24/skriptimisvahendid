import platform
import socket
import getpass
import psutil
import json
import argparse
from datetime import datetime, timezone
from pathlib import Path


def kogu_os() -> dict:
    return {
        "süsteem": platform.system(),
        "versioon": platform.version(),
        "release": platform.release(),
        "arhitektuur": platform.architecture()[0],
        "masina_tüüp": platform.machine(),
    }


def kogu_host() -> dict:
    return {
        "host": socket.gethostname(),
        "kasutaja": getpass.getuser(),
        "python": platform.python_version(),
    }


def kogu_cpu() -> dict:
    mudel = platform.processor()

    if not mudel and platform.system() == "Linux":
        try:
            with open("/proc/cpuinfo") as f:
                for rida in f:
                    if "model name" in rida:
                        mudel = rida.split(":")[1].strip()
                        break
        except Exception:
            mudel = "Teadmata"

    return {
        "mudel": mudel or "Teadmata",
        "südamikud_füüsilised": psutil.cpu_count(logical=False),
        "südamikud_loogilised": psutil.cpu_count(logical=True),
        "kasutus_protsent": psutil.cpu_percent(interval=1),
    }


def kogu_mälu() -> dict:
    m = psutil.virtual_memory()

    return {
        "kokku_gb": round(m.total / (1024**3), 2),
        "kasutuses_gb": round(m.used / (1024**3), 2),
        "vaba_gb": round(m.available / (1024**3), 2),
        "kasutus_protsent": m.percent,
    }


def kogu_kettad() -> list:
    kettad = []

    for osa in psutil.disk_partitions(all=False):
        try:
            kasutus = psutil.disk_usage(osa.mountpoint)
        except Exception:
            continue

        kettad.append({
            "haakepunkt": osa.mountpoint,
            "seade": osa.device,
            "failisüsteem": osa.fstype,
            "kokku_gb": round(kasutus.total / (1024**3), 2),
            "vaba_gb": round(kasutus.free / (1024**3), 2),
            "kasutatud_gb": round(kasutus.used / (1024**3), 2),
            "kasutus_protsent": kasutus.percent,
        })

    return kettad


def kogu_võrk() -> list:
    kaardid = []
    aadressid = psutil.net_if_addrs()
    olek = psutil.net_if_stats()

    for nimi, adrlist in aadressid.items():
        ipv4 = next(
            (a.address for a in adrlist
             if a.family == socket.AF_INET and not a.address.startswith("127.")),
            None
        )

        kaardid.append({
            "nimi": nimi,
            "ipv4": ipv4,
            "ühendatud": olek[nimi].isup if nimi in olek else False,
        })

    return kaardid


def prindi_kokkuvote(data: dict):
    print("\n=== Süsteemi inventuur ===")
    print(f"Host:     {data['host']}")
    print(f"Kasutaja: {data['kasutaja']}")
    print(f"OS:       {data['os']['süsteem']} {data['os']['release']} ({data['os']['versioon']})")
    print(f"Python:   {data['python']}\n")

    print(f"CPU:      {data['cpu']['mudel']}")
    print(f"Südamikke: {data['cpu']['südamikud_füüsilised']} ({data['cpu']['südamikud_loogilised']} loogilist)")
    print(f"CPU kasutus: {data['cpu']['kasutus_protsent']}%\n")

    print(f"RAM:      {data['mälu']['kokku_gb']} GB ({data['mälu']['kasutus_protsent']}%)\n")

    print("Kettad:")
    for k in data["kettad"]:
        print(f"  {k['haakepunkt']}  Total: {k['kokku_gb']} GB  Free: {k['vaba_gb']} GB")

    print("\nVõrk:")
    for v in data["võrk"]:
        staatus = v["ipv4"] if v["ipv4"] else "(ühendamata)"
        print(f"  {v['nimi']:<15} {staatus}")


def main():
    parser = argparse.ArgumentParser(description="Süsteemi inventuur")
    parser.add_argument("--väljund", help="JSON failinimi")
    parser.add_argument("--stdout", action="store_true", help="Prindi JSON konsooli")
    args = parser.parse_args()

    inventuur = {
        "ajamäär": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        **kogu_host(),
        "os": kogu_os(),
        "cpu": kogu_cpu(),
        "mälu": kogu_mälu(),
        "kettad": kogu_kettad(),
        "võrk": kogu_võrk(),
    }

    if args.stdout:
        print(json.dumps(inventuur, indent=2, ensure_ascii=False))
        return

    prindi_kokkuvote(inventuur)

    hostname = inventuur["host"]
    kuupäev = datetime.now().strftime("%Y-%m-%d")

    failinimi = args.väljund or f"inventuur_{hostname}_{kuupäev}.json"

    Path(failinimi).write_text(
        json.dumps(inventuur, indent=2, ensure_ascii=False),
        encoding="utf-8"
    )

    print(f"\nSalvestatud: {failinimi}")


if __name__ == "__main__":
    main()