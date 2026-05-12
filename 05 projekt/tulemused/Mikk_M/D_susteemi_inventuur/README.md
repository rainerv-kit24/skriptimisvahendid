# Süsteemi inventuur

## Ülesanne
Skript kogub arvuti süsteemiinfo (OS, CPU, RAM, kettad, võrk) ja salvestab selle JSON formaati.

---

## Testkeskkond

- OS: Windows 10 Pro (10.0.19045)
  
---

## Käivitus

```bash
python inventuur.py
```

---

## Millised väljad õnnestusid kõigil platvormidel?

Testisin ainult Windowsi platvormil, seal töötasid järgmised väljad:

- Host nimi (socket.gethostname)
- Kasutaja nimi (getpass.getuser)
- Python versioon (platform.python_version)
- OS nimi, versioon ja release (platform.system, version, release)
- CPU loogiliste ja füüsiliste südamike arv (psutil.cpu_count)
- CPU kasutus protsent (psutil.cpu_percent)
- RAM kogus ja kasutus (psutil.virtual_memory)
- Kettad (mount point, kogumaht, vaba ruum)
- Võrguliidesed ja IP aadressid (psutil.net_if_addrs)

---

## Millised kohad olid platvormi­spetsiifilised ja kuidas said üle?

Windowsiga probleeme ei tekkinud, teistel platvormidel ei testinud.