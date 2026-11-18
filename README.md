<div align="center">

```
 ███╗   ██╗███████╗ ██████╗      ██╗    ██╗ █████╗ ████████╗ ██████╗██╗  ██╗
 ████╗  ██║██╔════╝██╔════╝      ██║    ██║██╔══██╗╚══██╔══╝██╔════╝██║  ██║
 ██╔██╗ ██║█████╗  ██║           ██║ █╗ ██║███████║   ██║   ██║     ███████║
 ██║╚██╗██║██╔══╝  ██║           ██║███╗██║██╔══██║   ██║   ██║     ██╔══██║
 ██║ ╚████║██║     ╚██████╗      ╚███╔███╔╝██║  ██║   ██║   ╚██████╗██║  ██║
 ╚═╝  ╚═══╝╚═╝      ╚═════╝       ╚══╝╚══╝ ╚═╝  ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝
```

### `> JACK INTO THE TAG. READ IT. REWRITE IT._`

![HarmonyOS NEXT](https://img.shields.io/badge/HarmonyOS-NEXT-ff003c?style=for-the-badge&labelColor=0d0221)
![ArkTS](https://img.shields.io/badge/ArkTS-Stage_Model-00f0ff?style=for-the-badge&labelColor=0d0221)
![Wearable](https://img.shields.io/badge/Target-Smartwatch-f9f002?style=for-the-badge&labelColor=0d0221)
![NFC](https://img.shields.io/badge/NFC-Read_%2F_Write-ff2a6d?style=for-the-badge&labelColor=0d0221)
![Architecture](https://img.shields.io/badge/Clean-Architecture-05ffa1?style=for-the-badge&labelColor=0d0221)

</div>

---

## `// ABOUT`

A **HarmonyOS NEXT** smartwatch app that reads and writes **NFC tags and cards** from your wrist. It is built with **Clean Architecture** (domain / data / presentation), so the NFC hardware stays behind an interface and the logic is easy to test.

> ⚠️ Not compiled or run on a device yet. Build it in DevEco Studio first.

## `// FEATURES`

| MODULE | STATUS | DETAILS |
|---|---|---|
| 📡 **READ** | `ONLINE` | UID, technologies, tech details and NDEF records |
| ✍️ **WRITE** | `ONLINE` | Text, URL, phone, email, SMS, location, MIME, app, external |
| 🧬 **TECH SUPPORT** | `ONLINE` | NFC-A/B/F/V, ISO-DEP, NDEF, MIFARE Classic, MIFARE Ultralight |
| 🧱 **FORMAT** | `ONLINE` | Blank NDEF-formattable tags are formatted on write |
| 🔒 **SAFETY** | `ONLINE` | Read-only tags are detected and not overwritten |

## `// ARCHITECTURE`

```
 ┌──────────────┐     ┌──────────────┐     ┌──────────────────────┐
 │ pages / UI   │ ──► │   domain     │ ◄── │        data          │
 │ view models  │     │ use cases    │     │ repository impl      │
 │              │     │ repo (iface) │     │ NFC data sources     │
 └──────────────┘     └──────────────┘     └──────────────────────┘
          └───────────── di/AppContainer wires it all ─────────────┘
```

```
watch/src/main/ets
├── domain/          models · NfcRepository · use cases
├── data/            NfcRepositoryImpl · discovery · reader · writer · codec
├── presentation/    view models · UI helpers
├── pages/           Index (menu) · ReadPage · WritePage
└── di/              AppContainer
```

## `// RUN`

1. Open the project in **DevEco Studio** (HarmonyOS SDK 6.0.1 / API 21).
2. Set up a **signing config** (`File → Project Structure → Signing Configs`).
3. Pick a **wearable** device or emulator with NFC.
4. Run the `watch` module.
5. Pick **Read tag** or **Write tag**, then hold a tag against the watch.

## `// CONTACT`

<div align="center">

[![GitHub](https://img.shields.io/badge/GitHub-oliver__botello-0d0221?style=for-the-badge&logo=github&logoColor=00f0ff&labelColor=1a1a2e&color=ff003c)](https://github.com/Oliver404)
[![X](https://img.shields.io/badge/X-@oliver__botello-0d0221?style=for-the-badge&logo=x&logoColor=ff2a6d&labelColor=1a1a2e&color=00f0ff)](https://x.com/oliver_botello)
[![Instagram](https://img.shields.io/badge/Instagram-@oliver__botello-0d0221?style=for-the-badge&logo=instagram&logoColor=f9f002&labelColor=1a1a2e&color=ff2a6d)](https://instagram.com/oliver_botello)
[![YouTube](https://img.shields.io/badge/YouTube-@oliver__botello-0d0221?style=for-the-badge&logo=youtube&logoColor=ff003c&labelColor=1a1a2e&color=f9f002)](https://youtube.com/@oliver_botello)
[![TikTok](https://img.shields.io/badge/TikTok-@oliver__botello-0d0221?style=for-the-badge&logo=tiktok&logoColor=05ffa1&labelColor=1a1a2e&color=ff003c)](https://tiktok.com/@oliver_botello)

</div>

---

<div align="center">

`> CONNECTION TERMINATED // Oliver 404`

</div>
