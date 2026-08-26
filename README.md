# ANDROID ANALYSIS — Reversing, Instrumentation & Traffic Toolchain

![ANDROID ANALYSIS banner](assets/banner.png)

![ANDROID ANALYSIS cover](assets/cover.png)

![Estado](https://img.shields.io/badge/estado-mobile%20red%20team%20autorizado-6f42c1)
![Shell](https://img.shields.io/badge/shell-Bash-4eaa25)
![Plataforma](https://img.shields.io/badge/plataforma-Ubuntu-111827)

`no4nn.sh` conserva el instalador recibido para una estación Ubuntu dedicada a análisis Android: ADB/Fastboot, Apktool, JADX, dex2jar, Androguard, Quark Engine, APKiD, MobSF, Frida, objection, Wireshark, tcpdump y mitmproxy. El objetivo es preparar una estación para reversing, análisis estático y análisis dinámico de APKs dentro de un engagement autorizado.

> **El instalador no conecta ni modifica dispositivos Android automáticamente.** Las fases de instrumentación, proxy y captura pueden manejar datos sensibles; utiliza únicamente APKs, emuladores, dispositivos y redes incluidos en la autorización escrita.

## Mejoras incorporadas

La versión reforzada conserva las seis fases del original y añade `set -Eeuo pipefail`, funciones idempotentes, `--dry-run`, selección `--static-only`/`--dynamic-only`, `--skip-apt`, directorio configurable, venv Python, validación de rutas y arquitectura, descargas HTTPS con `curl --fail`, verificación SHA-256 opcional para JADX, clones controlados y detección explícita de dispositivos ADB sin conexión automática.

El banner integrado cuenta con tres variantes y se selecciona con `--banner-style 0|1|2`, `BANNER_STYLE=0|1|2` o aleatoriamente cuando no se fija un estilo. La aleatorización es visual y no modifica el plan de instalación.

| Mejora | Resultado |
|---|---|
| Idempotencia | No vuelve a clonar directorios que ya tienen `.git`. |
| Entorno Python | Usa `$TOOLS_DIR/venv` en lugar de `pip` global del usuario. |
| Cadena de suministro | Restringe URLs a HTTPS esperadas y soporta `JADX_SHA256`. |
| Fases | Permite preparar solo estático o dinámico sin mezclar ambos. |
| ADB | Ejecuta solo `adb devices` para inventario; no hace `adb connect`. |
| Privilegios | Centraliza apt/usermod mediante `sudo_run`. |
| Repetibilidad | Acepta `--tools-dir`, estilo de banner y dry-run. |

## Requisitos

Se necesita Ubuntu 22.04/24.04 o compatible, conexión de red para descargar dependencias, `sudo` para paquetes del sistema y un directorio de instalación con espacio suficiente. El análisis dinámico requiere un emulador o dispositivo de laboratorio con Depuración USB autorizada. No se requiere conectar un dispositivo para instalar la estación.

## Instalación

Clona el repositorio y revisa primero el plan:

```bash
git clone <URL_DEL_REPOSITORIO>
cd android-analysis-toolchain-installer
chmod +x src/no4nn.sh
bash -n src/no4nn.sh
./src/no4nn.sh --dry-run --static-only --tools-dir "$HOME/security-tools"
```

Instalación completa en una estación dedicada:

```bash
sudo -E ./src/no4nn.sh \
  --tools-dir "$HOME/security-tools" \
  --banner-style 1
```

Solo reversing y análisis estático:

```bash
sudo -E ./src/no4nn.sh --static-only --tools-dir "$HOME/security-tools"
```

Solo instrumentación, tráfico y ADB:

```bash
sudo -E ./src/no4nn.sh --dynamic-only --tools-dir "$HOME/security-tools"
```

En una imagen que ya tiene paquetes base, puedes omitir apt:

```bash
./src/no4nn.sh --skip-apt --static-only --tools-dir "$HOME/security-tools"
```

## Verificación de descargas

La descarga de JADX utiliza la release latest del repositorio oficial por HTTPS y exige una URL `https://github.com/...` antes de extraerla. Para elevar la garantía de integridad, proporciona el SHA-256 obtenido por un canal de confianza:

```bash
export JADX_SHA256='<sha256-verificado-del-zip-de-jadx>'
sudo -E ./src/no4nn.sh --static-only
```

Si no se define `JADX_SHA256`, el script conserva la validación TLS y del origen esperado, pero muestra un aviso de que no se realizó verificación criptográfica del archivo. Los clones usan profundidad 1 y no se ejecuta ningún `setup.sh` o `run.sh` de terceros de forma automática.

## Fases conservadas

| Fase | Componentes | Nota operativa |
|---:|---|---|
| 1 | build-essential, git, curl, wget, unzip, Python, JDK | Preparación del host. |
| 2 | ADB y Fastboot | Solo inventario local mediante `adb devices`. |
| 3 | Apktool, JADX, dex2jar | Reversing y desempaquetado de APK. |
| 4 | Androguard, Quark Engine, APKiD, MobSF | Análisis estático y scoring. |
| 5 | Frida-tools y objection | Instrumentación dinámica autorizada. |
| 6 | Wireshark, tcpdump, mitmproxy | Captura y análisis de tráfico del laboratorio. |

## TTPs y perspectiva purple team

| TTP | Uso ofensivo del toolchain | Control defensivo a validar |
|---|---|---|
| Static Discovery | Inspección de permisos, componentes, firmas y strings APK | Mobile app security review, SBOM y pipeline de firma. |
| Dynamic Analysis | Frida/objection para observar llamadas y comportamiento | Anti-tampering, detección de instrumentación y telemetría móvil. |
| Network Sniffing | tcpdump/Wireshark/mitmproxy sobre dispositivo de laboratorio | TLS pinning, proxy policy, EDR/NDR y detección de CA no confiable. |
| Tool Transfer | Descarga de releases y clones para provisionar estación | Allowlist de repositorios, checksum y revisión de dependencias. |

La instalación prepara capacidades; no implica que una APK sea maliciosa ni que una observación dinámica sea concluyente. Conserva el APK, el hash, la versión del toolchain y la autorización junto con cada expediente.

## Pruebas y evidencia visual

Las pruebas versionadas verifican sintaxis Bash, ayuda, modos dry-run, banners y exclusión de fases incompatibles. No ejecutan apt, clones, pip, ADB, Frida, proxy ni captura real.

```bash
bash tests/test_installer.sh
python3 tools/render_evidence.py
```

| Archivo | Contenido |
|---|---|
| `evidence/01-banner-variant-0.png` | Plan estático y banner variante 0. |
| `evidence/02-banner-variant-1.png` | Plan dinámico y banner variante 1. |
| `evidence/03-banner-variant-2.png` | Plan completo y banner variante 2. |

## Estructura

```text
.
├── assets/
│   ├── banner.png
│   ├── cover.png
│   └── visual-review.md
├── docs/
│   ├── authorization.md
│   ├── supply-chain.md
│   └── operator-checklist.md
├── evidence/
│   ├── 01-banner-variant-0.png
│   ├── 02-banner-variant-1.png
│   ├── 03-banner-variant-2.png
│   └── visual-review.md
├── src/
│   ├── no4nn.sh
│   └── no4nn.sh.original
├── tests/test_installer.sh
├── tools/render_evidence.py
└── README.md
```

## Referencias

[1]: https://developer.android.com/tools/adb "Android Debug Bridge documentation"
[2]: https://github.com/skylot/jadx "JADX project"
[3]: https://github.com/MobSF/Mobile-Security-Framework-MobSF "Mobile Security Framework"
[4]: https://frida.re/docs/home/ "Frida documentation"
[5]: https://attack.mitre.org/techniques/T1426/ "MITRE ATT&CK Mobile — System Information Discovery"
[6]: https://attack.mitre.org/techniques/T1417/ "MITRE ATT&CK Mobile — Input Capture"
