# 💊 SK8 Sell Drugs

> 🧠 **Autor:** sk8  
> 🧩 **Platforma:** FiveM (ESX Framework)  
> 🎨 **UI/UX:** SK8 Development Design System  
> 💾 **Databáze:** oxmysql  
> ⚙️ **Kompatibilita:** ESX Legacy

---

## 📋 Popis

**SK8 Sell Drugs** je pokročilý systém pro prodej drog ve FiveM s realistickou mechanikou, Street Credit systémem, a integrovaným police reporting systémem. Script obsahuje vlastní NUI v SK8 Design stylu s moderními animacemi a efekty.

---

## ✨ Klíčové funkce

### 💰 **Drug Dealing System**
- Prodej tří typů drog: **Tráva**, **Kokain**, **Pervitin**
- Dynamické ceny a množství
- Realistické NPC spawning s pokročilou AI navigací
- Animace a progress bary během transakce

### 🎯 **Street Credit System**
- 7 levelů s multiplier bonusy (1.0x - 2.0x)
- Vlastní NUI progress bar s SK8 designem
- XP systém s databázovým ukládáním
- Level up animace s vizuálními efekty

### 🚔 **Police Reporting System**
- 15% šance na nahlášení dealu policii
- Automatické notifikace pouze pro police joby
- Map blip s radius označením (150m)
- Custom SK8 NUI alert pro policisty

### 🎨 **SK8 Design NUI**
- Purple/Black gradient theme
- Shimmer a pulse animace
- Slide-in efekty
- Responzivní design

---

## 🛠️ Instalace

### 1. **Soubory**
```bash
# Zkopírovat do resources složky
resources/[sk8]/sk8_selldrugs/
```

### 2. **Databáze**
```sql
-- Spustit install.sql
CREATE TABLE `sk8_street_credit` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `identifier` varchar(50) NOT NULL,
  `points` int(11) DEFAULT 0,
  `level` int(11) DEFAULT 1,
  PRIMARY KEY (`id`),
  UNIQUE KEY `identifier` (`identifier`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

### 3. **Server.cfg**
```cfg
ensure sk8_selldrugs
```

### 4. **Závislosti**
- ESX Legacy
- ox_inventory
- ox_target
- ox_lib

---

## ⚙️ Konfigurace

### 🎮 **Základní nastavení**
```lua
Config.DrugItems = {
    ['cannabis'] = {
        name = 'cannabis',
        label = 'Tráva',
        sellPrice = {min = 50, max = 150},
        dealTime = {min = 30, max = 60},
        clientModels = {'a_m_m_beach_01', 'a_m_m_bevhills_01'},
        sellText = 'Prodej trávu'
    }
}
```

### 🚔 **Police Reporting**
```lua
Config.DealFailure = {
    enabled = true,
    chance = 15,                    -- 15% šance na nahlášení
    policeJobs = {'police', 'sheriff', 'state'},
    reportBlipSettings = {
        sprite = 161,
        color = 1,
        duration = 300000,          -- 5 minut
        radius = 150.0
    }
}
```

### 🎯 **Street Credit**
```lua
Config.StreetCredit = {
    enabled = true,
    pointsPerDeal = {
        ['cannabis'] = 3,
        ['cocaine'] = 5,
        ['meth'] = 8
    },
    levels = {
        {level = 1, required = 0, multiplier = 1.0, name = 'Nováček'},
        {level = 7, required = 1000, multiplier = 2.0, name = 'Legenda'}
    }
}
```

---

## 🎮 Použití

### 👤 **Pro hráče**
```
/selldrug - Zahájit prodej drog
```

### 👮 **Pro policisty**
- Automatické NUI notifikace při nahlášeném dealu
- Map blip s označením oblasti
- Informace o typu drogy a koordinátech

---

## 📱 UI/UX Features

### 🎨 **Street Credit Bar**
- **Pozice:** Top-center
- **Design:** Red gradient s shimmer efekty
- **Animace:** Slide-in/out, level up pulse
- **Informace:** Level, XP progress, multiplier

### 🚨 **Police Alert**
- **Pozice:** Right-center  
- **Design:** Purple/Black SK8 gradient
- **Animace:** Slide-in z pravé strany
- **Informace:** Typ drogy, koordináty, čas

---

## 🔧 Technické specifikace

### 📊 **Performance**
- **Resmon:** < 0.05ms při idle
- **Optimalizované:** NPC spawning algoritmy
- **Asynchronní:** Všechny databázové operace

### 🎯 **Bezpečnost**
- **SQL Injection:** Parametrizované dotazy
- **Validation:** Server-side kontroly
- **Anti-exploit:** Cooldown systémy

---

## 📋 Changelog

### **v1.0** - Initial Release
- ✅ Základní drug dealing systém
- ✅ Street Credit progression
- ✅ SK8 Design NUI
- ✅ Police reporting system
- ✅ Map blip integration

---

## 🆘 Podpora

### 🐛 **Bug Report**
Pro nahlášení chyb nebo návrhů kontaktuj:
- **Discord:** skinnycigan
- **GitHub:** Issues tab

### ❓ **FAQ**

**Q: Proč se NPC nespawnuje?**  
A: Zkontroluj ox_target a ox_lib dependency.

**Q: Jak změnit šanci na police report?**  
A: V config.lua změň `Config.DealFailure.chance`

**Q: Street Credit se neukládá?**  
A: Zkontroluj databázové připojení a spuštěný install.sql

---

## 📄 Licence

**Vlastní licence SK8 DEVELOPMENT**

- ❌ **Žádná redistribuce** bez povolení
- ❌ **Žádné úpravy (POUZE config.lua a nui povoleno)** bez uvedení autora  
- ❌ **Žádný resale** mimo oficiální kanály
- ✅ **Použití** na vlastním serveru povoleno

---

## 🎯 Credits

**Vytvořeno s ❤️ týmem SK8 DEVELOPMENT**

> 🔥 **Kvalitní scripty pro FiveM servery**  
> 🛒 **Tebex:** [sk8-development.tebex.io](https://sk8-development.tebex.io/)

---

<div align="center">

**⭐ Pokud se ti script líbí, zanech hvězdičku na GitHubu! ⭐**

</div>
