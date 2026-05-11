from pathlib import Path
from collections import Counter, defaultdict
from datetime import datetime
import argparse
import csv


# --- LOGI LUGEMINE ---
def loe_logi(fail: Path):
    read = []
    if not fail.exists():
        print("Viga: logifaili ei leitud")
        return []

    with fail.open("r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue

            try:
                parts = line.split("\t")
                if len(parts) < 4:
                    raise ValueError("vale formaat")

                aeg = datetime.strptime(parts[0], "%Y-%m-%d %H:%M:%S")
                staatus = parts[1].strip("[]")
                tase = parts[2]
                host = parts[3]

                read.append((aeg, staatus, tase, host))
            except Exception as e:
                print(f"Vigane rida: {line} -> {e}")
                continue

    return read


# --- ANALÜÜS ---
def analüüsi(read):
    if not read:
        return None

    kokku = len(read)
    staatus_counter = Counter([r[1] for r in read])
    tase_counter = Counter([r[2] for r in read])
    host_counter = Counter([r[3] for r in read])

    per_day = defaultdict(lambda: {"OK": 0, "FAIL": 0, "Info": 0, "Warning": 0, "Critical": 0})

    critical_days = Counter()

    for aeg, staatus, tase, host in read:
        day = aeg.date().isoformat()

        per_day[day][tase] += 1
        if staatus == "OK":
            per_day[day]["OK"] += 1
        else:
            per_day[day]["FAIL"] += 1

        if tase == "Critical":
            critical_days[day] += 1

    return {
        "kokku": kokku,
        "staatus": staatus_counter,
        "tase": tase_counter,
        "hostid": host_counter,
        "per_day": per_day,
        "critical_days": critical_days,
        "paevad": sorted(per_day.keys())
    }


# --- KONSOOLI VÄLJUND ---
def kuva_tulemused(stats):
    if not stats:
        print("Logi on tühi")
        return

    print("\n--- KOKKUVÕTE ---")
    print(f"Teateid kokku: {stats['kokku']}")
    print(f"  OK: {stats['staatus'].get('OK', 0)}")
    print(f"  FAIL: {stats['staatus'].get('FAIL', 0)}")

    print("\nRaskusaste:")
    for tase, arv in stats["tase"].items():
        print(f"  {tase}: {arv}")

    print("\nTop allikad:")
    for i, (host, arv) in enumerate(stats["hostid"].most_common(3), 1):
        print(f"  {i}. {host} — {arv} teadet")

    print("\nCritical teated:")
    for day in stats["paevad"]:
        count = stats["critical_days"].get(day, 0)
        bar = "█" * count if count > 0 else "-"
        print(f"  {day}: {bar} ({count})")


# --- CSV SALVESTUS ---
def salvesta_csv(stats, nimi):
    with open(nimi, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["Päev", "OK", "FAIL", "Info", "Warning", "Critical"])

        for day in stats["paevad"]:
            d = stats["per_day"][day]
            writer.writerow([
                day,
                d["OK"],
                d["FAIL"],
                d["Info"],
                d["Warning"],
                d["Critical"]
            ])


# --- MAIN ---
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("logifail", nargs="?", default="ps-alerts.log")
    parser.add_argument("--csv", default="analyys_paevad.csv")

    args = parser.parse_args()

    fail = Path(args.logifail)
    read = loe_logi(fail)
    stats = analüüsi(read)

    kuva_tulemused(stats)

    if stats:
        salvesta_csv(stats, args.csv)
        print(f"\nCSV salvestatud: {args.csv}")


if __name__ == "__main__":
    main()