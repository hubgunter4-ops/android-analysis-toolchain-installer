# ANDROID ANALYSIS — Toolchain de reversing e instrumentación

![ANDROID ANALYSIS banner](assets/banner.png)

![ANDROID ANALYSIS cover](assets/cover.png)

ANDROID ANALYSIS es un **instalador Bash modular** para preparar una estación de análisis Android: ADB/Fastboot, Apktool, JADX, dex2jar, Androguard, Quark Engine, APKiD, MobSF, Frida, objection, Wireshark, tcpdump y mitmproxy. Conserva las seis fases del instalador original y mantiene capacidades ofensivas de reversing, instrumentación y análisis de tráfico para laboratorios autorizados.

> **Uso autorizado únicamente.** El instalador provisiona capacidades; no autoriza por sí mismo el análisis de una APK, la conexión a un dispositivo ni la captura de tráfico. Usa solo aplicaciones, emuladores, dispositivos y redes incluidos en una autorización escrita.

## Arquitectura

```text
src/no4nn.sh                    # entrypoint: resuelve raíz y carga el núcleo
src/android_toolchain/core.sh   # validación, banners, plan y seis fases
archive/original/no4nn.sh.original
```

El entrypoint no depende del directorio de trabajo. El core concentra las funciones de instalación y puede auditarse con `bash -n` antes de ejecutar. La idempotencia se aplica a clones Git controlados y a directorios JADX existentes; las herramientas de terceros no ejecutan `setup.sh` o `run.sh` automáticamente.

## Requisitos e instalación

Para la instalación real se requiere Ubuntu compatible, acceso de red, `sudo` para paquetes del sistema y espacio suficiente en `TOOLS_DIR`. Las fases de análisis dinámico requieren además un emulador o dispositivo Android de laboratorio con Depuración USB habilitada dentro del alcance autorizado. Sin dispositivo se pueden instalar las herramientas, pero no comprobar adjunción, instrumentación o tráfico.

```bash
git clone https://github.com/hubgunter4-ops/android-analysis-toolchain-installer.git
cd android-analysis-toolchain-installer
chmod +x src/no4nn.sh src/android_toolchain/core.sh
bash -n src/no4nn.sh src/android_toolchain/core.sh
```

Antes de provisionar, genera un plan legible:

```bash
./src/no4nn.sh --dry-run --static-only \
  --tools-dir "$HOME/security-tools" --banner-style 0
```

Para automatización, el plan se puede consumir como JSON y no ejecuta ninguna fase:

```bash
./src/no4nn.sh --plan-json --static-only \
  --tools-dir "$HOME/security-tools"
```

Instalación completa en una estación dedicada:

```bash
sudo -E ./src/no4nn.sh \
  --tools-dir "$HOME/security-tools" --banner-style 1
```

Solo reversing y análisis estático:

```bash
sudo -E ./src/no4nn.sh --static-only \
  --tools-dir "$HOME/security-tools"
```

Solo ADB, instrumentación y tráfico:

```bash
sudo -E ./src/no4nn.sh --dynamic-only \
  --tools-dir "$HOME/security-tools"
```

En una imagen que ya dispone de paquetes base, `--skip-apt` evita `apt-get`; no evita descargas, creación del venv o clones que correspondan a las fases seleccionadas.

## Opciones y controles

| Opción | Comportamiento |
|---|---|
| `--tools-dir PATH` | Directorio absoluto o relativo seguro para venv, JADX, dex2jar y MobSF. |
| `--dry-run` | Muestra comandos planificados sin ejecutar APT, pip, clones, descargas, ADB ni cambios de grupo. |
| `--plan-json` | Emite un plan JSON parseable y termina sin cambiar el host. |
| `--static-only` | Ejecuta base, ADB, APK tools y análisis estático; excluye instrumentación y tráfico. |
| `--dynamic-only` | Ejecuta base, ADB, instrumentación y tráfico; excluye APK tools y MobSF. |
| `--skip-apt` | Omite paquetes del sistema, útil en imágenes preconfiguradas. |
| `--banner-style 0\|1\|2` | Fija una de tres variantes visuales; sin valor se aleatoriza. |

`--static-only` y `--dynamic-only` son excluyentes. Las rutas aceptan una allowlist conservadora de caracteres y rechazan controles, separadores de comandos y traversal evidente. `JADX_SHA256`, si se define, debe ser un SHA-256 hexadecimal de 64 caracteres.

## Seis fases conservadas

| Fase | Componentes | Efecto real |
|---:|---|---|
| 1 | build-essential, Git, curl, wget, unzip, Python, venv y JDK | Instala dependencias base mediante `sudo_run`. |
| 2 | ADB y Fastboot | Instala paquetes y, fuera de dry-run, ejecuta solo `adb devices`; no hace `adb connect`. |
| 3 | Apktool, JADX y dex2jar | Descarga JADX por HTTPS desde la release esperada y clona dex2jar con profundidad 1. |
| 4 | Androguard, Quark Engine, APKiD y MobSF | Crea o actualiza `$TOOLS_DIR/venv` y clona MobSF; no inicia MobSF automáticamente. |
| 5 | Frida-tools y objection | Prepara instrumentación para una app autorizada; no adjunta procesos por sí sola. |
| 6 | Wireshark, tcpdump y mitmproxy | Instala captura y proxy; el usuario debe seleccionar interfaz, APK, dispositivo y CA conforme al alcance. |

## Cadena de suministro e idempotencia

JADX se obtiene desde la API de releases de su proyecto oficial y solo se acepta una URL `https://github.com/...` con el sufijo esperado. Para una verificación criptográfica, proporciona el hash desde un canal independiente:

```bash
export JADX_SHA256='<sha256-verificado-del-zip>'
sudo -E ./src/no4nn.sh --static-only
```

Sin `JADX_SHA256`, se conserva TLS y la comprobación del origen esperado, pero el script informa que no hubo validación criptográfica del archivo. Los clones no sobrescriben destinos no vacíos que no contengan `.git`; los venv se reutilizan en ejecuciones posteriores. Revisa lockfiles, hashes y licencias de dependencias antes de promover la estación.

## Operación Android autorizada

Después de instalar, el operador debe registrar APK y SHA-256, versión de Android, modelo/emulador, estado de root o debug, versión de Frida/objection, interfaz de captura, CA instalada y ventana de autorización. ADB, Frida y mitmproxy pueden acceder a datos sensibles; almacena resultados con permisos restringidos y elimina artefactos fuera del periodo de retención.

El instalador no verifica la validez funcional de una APK ni puede afirmar que una app es vulnerable solo porque una herramienta se haya instalado. La evidencia dinámica debe incluir el comando utilizado, el identificador del dispositivo, el proceso objetivo, el momento y los artefactos generados.

## TTPs y perspectiva ofensiva

| TTP | Capacidad ofensiva autorizada | Control a validar |
|---|---|---|
| Static Discovery | Permisos, componentes, strings, firmas y recursos de APK | SAST móvil, SBOM y pipeline de firma. |
| Dynamic Analysis | Frida/objection para observar llamadas y comportamiento en runtime | Anti-tampering, detección de instrumentación y telemetría. |
| Network Sniffing | tcpdump/Wireshark/mitmproxy en red de laboratorio | TLS pinning, política de proxy y detección de CA no confiable. |
| Tool Transfer | Descarga de releases y clones para provisionar la estación | Allowlist, checksum, revisión de dependencias y provenance. |

## Pruebas locales y límites de validación

```bash
bash tests/test_installer.sh
bash -n src/no4nn.sh src/android_toolchain/core.sh
./src/no4nn.sh --plan-json --dynamic-only --tools-dir /tmp/android-toolchain-plan
```

La suite verifica sintaxis, ayuda, banners, dry-run de fases estáticas/dinámicas, JSON parseable, exclusión de modos, checksum inválido y rechazo de rutas peligrosas. No ejecuta `apt`, `pip`, clones, descargas, `adb`, Frida, objection, Wireshark, tcpdump ni mitmproxy. Por tanto, en este entorno no se validaron hardware Android, ADB, instrumentación ni captura real.

## Evidencia visual

`assets/` contiene banner y cover del repositorio. `evidence/` conserva las variantes visuales generadas para planes dry-run; la aleatorización afecta únicamente presentación. Regenera las capturas mediante:

```bash
python3 tools/render_evidence.py
```

Las capturas no deben presentarse como prueba de que se instaló un toolchain en un host externo ni de que se conectó un dispositivo.

## Estructura

```text
.
├── archive/original/no4nn.sh.original
├── assets/{banner.png,cover.png,visual-review.md}
├── docs/{authorization.md,supply-chain.md,operator-checklist.md}
├── evidence/
├── src/
│   ├── no4nn.sh
│   └── android_toolchain/core.sh
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
