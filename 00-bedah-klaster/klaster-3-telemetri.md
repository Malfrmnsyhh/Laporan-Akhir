# BEDAH KLASTER 3: TELEMETRI & PENGAWASAN (MONITORING & SURVEILLANCE)

**Modul**: Data Center Operations (DataCenterOps)
**Sistem**: MSDC ERP — Internal Portal (PT Jawa Pos Media Televisi - JTV)
**Dokumen Referensi**: `PRD_DATACENTER_OPS_EXPANSION.md`, `01-feature-dual-thresholds-and-all-racks-monitoring.md`, `03-feature-cctv-racks.md`
**Penyusun**: Akmal (Tim 3 Data Center Operations)

---

## 1. IDENTITAS & LINGKUP SUB-MENU KLASTER 3

Klaster 3 memodelkan fungsi operasional **Network Operations Center (NOC) 24×7**, yang bertugas menjaga ketersediaan tinggi (*High Availability*) infrastruktur data center, memitigasi risiko kegagalan perangkat keras sebelum terjadi *downtime*, dan memberikan pengawasan visual lorong rak secara *real-time*.

Klaster ini menaungi 3 sub-menu utama:

1. **Dashboard Utama Data Center Ops** (`/dc`): Pusat komando ringkasan kapasitas fasilitas, utilisasi daya listrik (kW), matriks insiden aktif, dan daftar petugas piket (*Staff On-Duty*).
2. **Telemetri & Monitoring Rak** (`/dc/monitoring` & `/dc/monitoring/overview`): Pemantauan suhu dan kelembapan rak berbasis standar termal internasional ASHRAE TC 9.9, ingest sensor IoT otomatis, dan siklus hidup alarm.
3. **Pemantauan Visual CCTV** (`/dc/cctv`): Grid *live streaming* HLS lorong rak, verifikasi *probe* koneksi server CCTV, dan audit berkala kesehatan kamera.

---

## 2. FILOSOFI & SAINS BISNIS DATA CENTER

### 2.1. Konsep "Segitiga Pertahanan NOC"

Dalam data center tier enterprise, operator NOC tidak dapat terus-menerus berada di dalam ruang server yang bersuhu dingin ($18^\circ\text{C}$) dan bising (>75 dB). Klaster 3 membentuk **Segitiga Pertahanan**:

- **Radar Makro (Dashboard `/dc`)**: Mendeteksi masalah level makro (berapa rak yang terisi, berapa alarm yang sedang menyala, dan siapa teknisi yang sedang dinas).
- **Saraf Sensorik (Telemetri `/dc/monitoring`)**: Mendeteksi anomali fisika termodinamika (panas, dingin ekstrem, listrik statis).
- **Mata Visual (CCTV `/dc/cctv`)**: Melakukan verifikasi visual langsung ke lorong rak tanpa perlu membuka pintu fisik ruang server (*remote hands efficiency*).

### 2.2. Standar Termal ASHRAE TC 9.9 & Ambang Batas Ganda (Dual Thresholds)

Berbeda dengan anggapan awam bahwa data center *"harus sedingin mungkin"*, standar internasional **ASHRAE TC 9.9** menetapkan bahwa kondisi terlalu dingin atau terlalu kering sama berbahayanya dengan panas berlebih:

| Parameter Lingkungan                |                Rentang Nilai                |           Status Sistem           | Risiko Fisika & Kerusakan Perangkat Keras                                                                                                                              |
| ----------------------------------- | :-----------------------------------------: | :-------------------------------: | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Suhu Terlalu Dingin**       |          $< 18.0^\circ\text{C}$          | ⚠️ **Warning / Critical** | **Kondensasi Uap Air**: Udara dingin yang bertemu komponen aktif panas akan mengembun menjadi butiran air, memicu korsleting listrik (*short circuit*).        |
| **Suhu Rekomendasi (Ideal)**  | $18.0^\circ\text{C} - 27.0^\circ\text{C}$ |        🟢 **Normal**        | Titik efisiensi termal tertinggi prosesor dan rasio efisiensi energi pendingin (*PUE - Power Usage Effectiveness*).                                                  |
| **Suhu Warning (Allowable)**  | $27.1^\circ\text{C} - 30.0^\circ\text{C}$ |      ⚠️ **Warning**      | Beban pendingin (*CRAC/PAC*) meningkat; kipas pendingin server berputar maksimal (100% RPM).                                                                         |
| **Suhu Kritis (Overheating)** |          $> 30.0^\circ\text{C}$          |       🔴 **Critical**       | Terjadi *thermal throttling* (penurunan clock CPU) hingga *emergency shutdown* otomatis untuk mencegah silikon chip meleleh.                                       |
| **Kelembapan Kering Ekstrem** |      $< 40\%$ RH (Kritis: $<20\%$)      |       🔴 **Critical**       | **Listrik Statis (ESD - Electrostatic Discharge)**: Udara kering memicu lonjakan muatan statis dari gesekan udara/pakaian teknisi yang dapat membakar microchip. |
| **Kelembapan Basah Ekstrem**  |      $> 60\%$ RH (Kritis: $>70\%$)      |       🔴 **Critical**       | **Korosi & Jamur**: Uap air tinggi memicu karat pada pin konektor tembaga, kabel tembaga, dan konektor serat optik.                                              |

Oleh karena itu, sistem mengadopsi **Ambang Batas Ganda (Dual Thresholds)**:

$$
\text{Lower Critical} < \text{Lower Warning} \le \text{Kondisi Aman} \le \text{Upper Warning} < \text{Upper Critical}
$$

---

## 3. ARSITEKTUR FULLSTACK & ALUR DATA (END-TO-END TRACE)

### 3.1. Alur 1: Ingest Sensor IoT & Evaluasi Alarm Otomatis

```Markdown
[Sensor IoT Hardware: ESP32 / DHT22]
  │ (HTTP POST JSON + Header: X-API-Key)
  ▼
[Laravel Route: api.php -> /v1/data-center-ops/iot/metric-readings]
  │ (Diproteksi ApiKeyMiddleware, Tanpa JWT Token User)
  ▼
[MonitoringController::iotRecordReading()]
  │ (Memaksa source = 'sensor')
  ▼
[MonitoringService::recordReading()]
  │
  ├─► [Eloquent: MetricReading::create() -> DB dc_metric_reading]
  │
  └─► [MonitoringService::evaluateThreshold()]
        │ (Evaluasi Hierarkis: Device-Specific -> Rack-Specific -> Site-Specific -> Global)
        │ (Memeriksa Dual Bounds: Lower & Upper Thresholds)
        ▼
      [Breach Terdeteksi?]
        ├─► TIDAK -> Selesai.
        └─► YA -> [Deduplication Guard: Cek apakah Alarm tipe sama berstatus 'open' sudah ada?]
                    ├─► Sudah Ada -> Abaikan (Mencegah Spam Alarm)
                    └─► Belum Ada -> [Alarm::create() -> DB dc_alarm (status: 'open')]
                                      │
                                      └─► [NotificationService::send() -> Email Alert ke Teknisi]
```

### 3.2. Alur 2: Arsitektur Pemantauan CCTV (Zero-Trust Stream Security)

```text
[Kamera Fisik / NVR CCTV]
  │ (Push Stream RTMP: rtmp://admin:token@ip:1935/live/ch1)
  ▼
[Server CCTV Kantor JTV (SRS / MediaMTX / Nginx-RTMP)]
  │ (Transcoding otomatis ke format HLS: http://stream.jtv.co.id/live/ch1.m3u8)
  ▼
[Form Frontend: /dc/cctv/new]
  │ (Admin memasukkan URL stream)
  ▼
[Backend Probe: POST /v1/data-center-ops/cctv-cameras/test]
  │ 1. SSRF Protection: Blokir IP 169.254.169.254 & Private Loopback
  │ 2. CctvStreamProbeService: ffprobe / HTTP HEAD untuk cek codec (H.264), resolusi, status live
  ▼
[Simpan Data: POST /v1/data-center-ops/cctv-cameras]
  │ 1. source_url DIENKRIPSI AES-256 via Crypt::encryptString() (Kredensial Aman)
  │ 2. playback_url disimpan untuk streaming browser
  ▼
[Frontend Dashboard / Grid: /dc/cctv]
  │ (Browser membaca response melalui CctvCameraResource -> source_url TIDAK PERNAH bocor)
  ▼
[Browser Client HlsPlayer (Hls.js)]
  │ (Memutar HLS .m3u8 langsung dari Server CCTV JTV tanpa membebani server Laravel)
  │ (Optimasi Memori Browser: MAX_ACTIVE_PLAYERS = 4)
```

### 3.3. Alur 3: Integrasi Jadwal Piket Petugas (HR Shift Schedule ke Dashboard)

- `DashboardController::onDutyToday()` memanggil `DashboardService::onDutyToday($siteId)`.
- Mengambil data dari tabel `hr_shift_schedule` (modul HR Service Support) di mana tanggal sama dengan hari ini (`schedule_date = today`) dan `site_id` cocok.
- Meng-eager load relasi karyawan: nama lengkap, nomor telepon, foto profil, dan jumlah tiket aktif yang sedang ditangani.

---

## 4. LOGIKA PROTEKSI, KEAMANAN, & INTEGRITAS DATA

1. **Anti-Spam Alarm (Alarm Deduplication)**:
   Mencegah banjir alarm email jika sensor mengirim data abnormal setiap menit. Satu insiden suhu panas hanya menghasilkan **1 tiket alarm berstatus `open`** hingga staf menekan `Acknowledge` atau `Resolve`.
2. **Zero-Trust URL Encryption**:
   Stream key CCTV berisi token rahasia kamera. Disimpan dengan enkripsi simetris AES-256 di database (`dc_cctv_camera.source_url`). Model menerapkan getter terenkripsi dan `CctvCameraResource` membuang atribut tersebut dari payload JSON frontend.
3. **Proteksi SSRF (*Server-Side Request Forgery*)**:
   Fitur probe kamera memeriksa apakah hostname berada dalam *allowlist*. Memblokir alamat metadata cloud AWS/GCP/Azure (`169.254.169.254`) agar penyerang tidak dapat mengeksploitasi server backend.
4. **Pembatasan Player Bersamaan (`MAX_ACTIVE_PLAYERS = 4`)**:
   Decoding video HLS 1080p membebani GPU/CPU. Frontend membatasi pemutaran serentak maksimal 4 kamera, sementara kamera ke-5 dst berada dalam mode thumbnail *standby* untuk mencegah browser teknisi mengalami *crash*.

---

## 5. DIAGRAM ARSITEKTUR & ALIRAN DATA

Berikut adalah visualisasi alur integrasi Klaster 3 (Telemetri & Pengawasan):

![Arsitektur Klaster 3 Telemetri & Pengawasan](../../diagrams/rendered/arsitektur-klaster-3-telemetri.png)

*Sumber diagram mentah*: `diagrams/source/arsitektur-klaster-3-telemetri.mmd`

---

## 6. BANK PERTANYAAN & JAWABAN SIDANG PENGUJI (DEFENSE CHEAT-SHEET)

### Pertanyaan 1: Mengapa sistem pemantauan suhu rak Anda memiliki ambang batas bawah (*lower threshold*), bukankah ruang server lebih bagus jika semakin dingin?

> **Jawaban Ilmiah**:
> *"Tidak, Pak/Bu. Mengacu pada standar internasional ASHRAE TC 9.9, suhu data center yang terlalu dingin (< 18°C) sangat berbahaya karena memicu kondensasi uap air. Ketika udara dingin bertemu permukaan motherboard server yang hangat, uap air akan mengembun menjadi tetesan air dan menyebabkan korsleting listrik. Selain itu, kelembapan yang terlalu rendah (< 40% RH) memicu Electrostatic Discharge (ESD) atau listrik statis yang membakar microchip silikon. Oleh karena itu, sistem kami menerapkan Ambang Batas Ganda (Dual Thresholds) dengan batas bawah dan batas atas yang seimbang."*

### Pertanyaan 2: Bagaimana mekanisme autentikasi sensor perangkat keras IoT saat mengirim data metrik ke backend Anda?

> **Jawaban Ilmiah**:
> *"Sensor IoT di lapangan (seperti mikrokontroler ESP32 atau probe SNMP) tidak menggunakan token JWT pengguna karena bukan entitas manusia yang melakukan login. Kami menyediakan rute khusus `POST /v1/data-center-ops/iot/metric-readings` yang diproteksi menggunakan middleware `X-API-Key`. Kunci API divalidasi dari tabel CorePlatform dan diikat ke organisasi terkait, sehingga komunikasi data machine-to-machine berjalan aman, ringan, dan terisolasi."*

### Pertanyaan 3: Mengapa aliran video CCTV tidak dialirkan (*streaming*) langsung melewati server backend Laravel?

> **Jawaban Ilmiah**:
> *"Kami memisahkan secara tegas antara Control Plane dan Data Plane. Mengalirkan video melalui Laravel akan menghabiskan bandwidth jaringan, membebani CPU PHP-FPM, dan menyebabkan latensi tinggi. Backend Laravel hanya bertindak sebagai Control Plane (mengelola perizinan, verifikasi probe kesehatan kamera, dan enkripsi kredensial stream). Sedangkan Data Plane dialirkan langsung dari server CCTV kantor ke peramban web operator menggunakan protokol modern HTTP Live Streaming (HLS `.m3u8`) yang dirender efisien oleh pustaka Hls.js."*

### Pertanyaan 4: Bagaimana sistem mencegah banjir alarm (*alarm storm/spam*) jika sensor IoT terus-menerus melaporkan suhu kritis setiap 1 menit?

> **Jawaban Ilmiah**:
> *"Kami menerapkan algoritma Deduplikasi Alarm pada `MonitoringService::evaluateThreshold`. Sebelum alarm baru dibuat, sistem memeriksa apakah sudah terdapat alarm dengan metrik dan entitas (site/rack/device) yang sama yang masih berstatus 'open'. Jika alarm aktif sudah ada, sistem tidak akan membuat alarm duplikat maupun mengirim spam email, melainkan membiarkan tiket alarm tersebut tetap terbuka sampai operator NOC melakukan `Acknowledge` dan `Resolve` setelah insiden ditangani."*
