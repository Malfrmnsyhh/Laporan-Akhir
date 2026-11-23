# Spesifikasi Templat JIFoSI 2026 & Audit Fakta Teknis Klaster 5 (Single Source of Truth)

Dokumen ini menjadi acuan tunggal (*single source of truth*) bagi penyusunan naskah artikel ilmiah di workspace `05-artikel-jurnal/` berdasarkan inspeksi langsung terhadap `template/JIFOSI_Template_2026.docx`, codebase produksi `MSDC` (*backend*) dan `MSDCFrontend` (*frontend*), serta eksekusi langsung *automated feature test suite*.

---

## A. Spesifikasi Teknis Templat `JIFOSI_Template_2026.docx`

| Aspek Format | Spesifikasi Aktual pada Templat JIFoSI 2026 |
| :--- | :--- |
| **Nama Jurnal & ISSN** | Jurnal Informatika dan Sistem Informasi (JIFoSI), ISSN (Online): 2722-130X (Header halaman 1: Volume 7 Nomor 2 Agustus 2026) |
| **Ukuran Kertas** | A4 (21,00 cm × 29,70 cm) |
| **Margin Halaman** | Atas 2,00 cm, Bawah 2,00 cm, Kiri 2,00 cm, Kanan 2,00 cm |
| **Jumlah Kolom** | **1 kolom** (*single-column*) pada seluruh naskah |
| **Header & Footer** | `different_first_page_header_footer = True`. Halaman 1 memuat *banner* identitas JIFoSI + logo di *header* dan lisensi CC-BY + gambar di *footer*. Halaman berikutnya memuat *running header* (`Nama Penulis Pertama Dkk, JUDUL NASKAH` / `Jurnal Informatika dan Sistem Informasi (JIFoSI) \| <hal>`) dan nomor halaman. |
| **Font Utama & Ukuran** | **Times New Roman 11 pt** (`docDefaults w:sz=22`), rata kiri-kanan (*justify*), spasi **1** (*single*) sesuai instruksi isi templat |
| **Judul (Indonesia)** | Times New Roman **14 pt, Bold, UPPERCASE**, rata kiri-kanan (*justify*). Catatan templat: **maksimal 12 kata** *(lihat Catatan Editorial di bawah)* |
| **Identitas Penulis** | Times New Roman **12 pt, Bold**, spasi 1, *first-line indent* 0,50 cm, penanda korespondensi `*¹`, diikuti `²`, `³` |
| **Afiliasi Penulis** | Times New Roman **12 pt, Reguler**, spasi 1, *left indent* 0,50 cm, superskrip angka, format: `Program Studi, Fakultas, Universitas Pembangunan Nasional “Veteran” Jawa Timur, Indonesia` |
| **Blok Metadata Redaksi** | Times New Roman 11 pt: `DOI: (diisi oleh editor)`, `*Corresponding Author: email`, `Submit: [Bulan Tahun] \| Accepted: [Bulan Tahun] \| Published: [Bulan Tahun]` |
| **ABSTRAK (ID)** | Judul `ABSTRAK` (11 pt Bold Uppercase); isi **80–250 kata**, Times New Roman 11 pt reguler, spasi 1, **1 paragraf tanpa indentasi**, **tanpa sitasi/rujukan**; diikuti `Kata Kunci:` (**3–6 kata/frasa**, merupakan *subset* dari judul) |
| **TITLE & ABSTRACT (EN)** | `TITLE` (14 pt Bold **Italic** Uppercase, catatan maks. 12 kata); `ABSTRACT` (11 pt Bold **Italic** Uppercase); isi **80–250 words**, Times New Roman 11 pt **Italic**, spasi 1, 1 paragraf tanpa indentasi, tanpa sitasi; `Keywords:` (3–6 kata/frasa, **Italic**, *subset* dari judul) |
| **Struktur & Gaya Heading Bagian Utama** | Times New Roman 11 pt, **Bold, UPPERCASE**, rata kiri-kanan, **tanpa nomor bab**: `PENDAHULUAN` → `METODOLOGI` → `HASIL DAN PEMBAHASAN` → `KESIMPULAN DAN SARAN` → `DAFTAR RUJUKAN` |
| **Gaya Sub-bab** | Times New Roman 11 pt, **Bold**, *Title Case* dengan penomoran angka Arab: `1. Sub-bab ...`, `2. Sub-bab ...` |
| **Gambar & Keterangan** | Penomoran urut (`Gambar 1.`, `Gambar 2.`), diletakkan **di bawah gambar**, rata tengah (*center*), Times New Roman 11 pt **Bold** |
| **Tabel & Keterangan** | Penomoran urut (`Tabel 1.`, `Tabel 2.`), diletakkan **di atas tabel**, rata tengah (*center*), Times New Roman 11 pt **Bold**. Kolom teks rata kiri, kolom angka rata tengah. |
| **Gaya Sitasi & Daftar Rujukan** | **IEEE** — sitasi dalam teks memakai kurung siku `[1]`, `[2]` sesuai **urutan pertama kali disitasi** (bukan alfabetis). Daftar rujukan: spasi 1, *hanging indent* 1,13 cm (`left=1,13 cm`, `first_line=-1,13 cm`), tab setelah `[n]`, judul artikel dalam tanda petik, nama jurnal/prosiding/buku *italic*, **wajib mencantumkan `doi: https://doi.org/10.xxxx/xxxxx`** di akhir entri bila tersedia DOI (atau URL jika tanpa DOI). Format templat menggunakan konvensi IEEE (`and`, `vol.`, `no.`, `pp.`). |
| **Target Panjang Naskah** | Tidak dibatasi eksplisit dalam teks templat DOCX; target artikel jurnal JIFoSI adalah **6–10 halaman** (A4, 1 kolom). |

> **Catatan Editorial Penting (Batas Kata Judul):** Templat `JIFOSI_Template_2026.docx` menuliskan anjuran *(MAKSIMAL 12 KATA)*. Judul final yang ditetapkan pengguna (*"Rancang Bangun Sistem Manajemen Izin Akses Fisik Pusat Data Berbasis Dynamic One-Time QR Code dengan Proteksi Anti-Replay Mengacu ISO/IEC 27001"*) berjumlah **21 kata** (ID). Naskah akan tetap menggunakan judul final yang ditetapkan pengguna secara utuh, disertai opsi judul ringkas ≤ 12 kata pada catatan penyerahan bila editor JIFoSI menegakkan batas 12 kata secara ketat.

---

## B. Audit Fakta Teknis Klaster 5 (Inspeksi Codebase Aktual)

### 1. Stack Teknologi Terverifikasi (`composer.json` & `package.json`)
- **Backend:** PHP `8.4.0` (requirement `^8.2`), Laravel Framework `^12.0`, `nwidart/laravel-modules` `^12.0`, Laravel Passport `^13.0` (`auth:api` OAuth2), Spatie Laravel Permission `^6.0` (RBAC granular: `visitor-pass.view` & `visitor-pass.manage`), `endroid/qr-code` `^5.0` (melalui `Modules\CorePlatform\Services\QrCodeService`), PHPUnit `11.5.56`.
- **Frontend:** React `18.3.1`, TypeScript `5.6.3`, Vite `5.4.21`, TanStack React Query `^5.59.0`, Axios `^1.7.7`, Tailwind CSS `3.4.19`, `jsqr` `^1.4.0` (plus *native* HTML5 `BarcodeDetector` API dan *local QR encoder* berbasis spesifikasi ISO/IEC 18004 port Project Nayuki di `utils/qrEncoder.ts`).

### 2. Komponen & Berkas Produksi Aktual
- **Backend (`MSDC/Modules/DataCenterOps/`):**
  - `app/Http/Controllers/Api/V1/VisitorPassController.php` — 10 *endpoint* internal (`auth:api`, `core.active`, RBAC `visitor-pass.view` [4 `GET`] & `visitor-pass.manage` [6 `POST`]).
  - `app/Http/Controllers/Api/V1/PublicVisitorPassController.php` — 3 *endpoint* publik tanpa autentikasi (`GET /v1/public/visitor-invitation/{token}`, `POST /v1/public/visitor-invitation/{token}/register`, `GET /v1/public/visitor-pass/{publicUrlToken}`).
  - `app/Services/VisitorPassService.php` — Logika inti: `getEligibleCustomers()`, `createInvitation()`, `getInvitationDetails()`, `submitSelfRegistration()`, `approveVisitorPass()`, `createVisitorPass()`, `scanAndVerify()`, `checkOut()`, `cancelVisitorPass()`, `getActiveInFacility()`, `checkOverstayAndExpiry()`, `assertVisitScheduleWithinPermit()`, `generatePassNumber()`.
  - `app/Exceptions/ReplayAttemptException.php` — *Custom exception* yang dipetakan menjadi respons **HTTP 409 Conflict** (`replay_detected: true`).
  - `app/Console/Commands/CheckVisitorPassStatusCommand.php` — Perintah Artisan `dc-ops:check-visitor-pass-status` terjadwal **setiap 10 menit** (`everyTenMinutes()->withoutOverlapping()` di `DataCenterOpsServiceProvider.php`) untuk transisi `scheduled`/`pending_registration`/`registered` → `expired` dan `active_in_facility` → `overstayed` (disertai alarm *in-app* tanpa *auto check-out*).
  - `app/Entities/VisitorPass.php` & `app/Entities/VisitorAccessLog.php` — Model Eloquent dengan *trait* `HasOrganizationScope` (isolasi *multi-tenant*) dan `RecordsDataChange` (*audit trail* perubahan data), serta `$hidden = ['token_hash', 'encrypted_token', 'invite_token_hash']`.
  - **Migrasi Basis Data:**
    - `2026_10_18_000002_create_dc_visitor_pass_tables.php` — Membuat `dc_visitor_pass` (9 status: `pending_registration`, `registered`, `scheduled`, `active_in_facility`, `overstayed`, `completed`, `cancelled`, `expired`, `denied`; 4 metode *check-in*: `webcam_guard`, `usb_scanner`, `manual_override`, `turnstile_gate`) dan `dc_visitor_access_log` (8 hasil audit: `granted`, `checkout_granted`, `denied_invalid_token`, `denied_expired`, `denied_already_used`, `denied_contract_inactive`, `denied_overstayed`, `denied_wrong_site`).
    - `2026_10_21_000001_add_invitation_fields_to_dc_visitor_pass.php`
    - `2026_10_25_000001_add_registered_status_and_approval_fields_to_dc_visitor_pass.php`
    - `2026_10_26_000001_add_visitor_pass_permissions.php` (memisahkan RBAC `visitor-pass.view` & `visitor-pass.manage`).
- **Frontend (`MSDCFrontend/src/modules/data-center-ops/`):**
  - Halaman: `PublicVisitorRegistrationPage.tsx` (registrasi mandiri tanpa akun dengan *backoff polling* 5 dtk → 15 dtk → 30 dtk dan *auto-redirect* 5 detik pasca-*approve*), `PublicVisitorPassPage.tsx` (E-Badge publik dengan *live refresh* 30 detik & *countdown* lokal), `VisitorPassListPage.tsx`, `VisitorPassInvitePage.tsx`, `VisitorPassCreatePage.tsx` (jalur darurat/*walk-in*), `VisitorPassDetailPage.tsx`, `VisitorPassScannerPage.tsx`.
  - Komponen & Utilitas: `VisitorPassApproveModal.tsx` (wajib 2 *checkbox* *Compliance Vetting* ISO 27001 sebelum tombol setujui aktif), `VisitorPassTicket.tsx` (visualisasi status terminal tanpa QR bila hangus), `VisitorScannerView.tsx` (*Scanner Guard*: kamera langsung `jsQR` interval 250 ms, unggah foto multi-lapis `BarcodeDetector` + *multi-scale* `jsQR` 1000/600/1400 px, *USB HID scanner*, *2-step masked token confirmation* kedaluwarsa 60 dtk, pemilih *site* pos jaga tersimpan di `localStorage`, *Web Audio API* feedback, serta *Live Headcount*), `utils/qrEncoder.ts` (*local ISO/IEC 18004 QR encoder* di browser tanpa request pihak ketiga), `utils/visitorPassQr.ts` (aturan tunggal *fail-closed* tampilan QR hanya untuk token `^VPQR_[A-Za-z0-9]+$`).

### 3. Parameter Kriptografi, Validasi, & Keamanan Aktual (Terverifikasi di Kode)
1. **Pembangkitan Token Kriptografis CSPRNG (`random_bytes`):**
   - Token undangan (*invitation*): `'VPINV_' . bin2hex(random_bytes(20))` (entropi **160 bit**, total **46 karakter**), disimpan sebagai *hash* satu arah **SHA-256** (`invite_token_hash`, `char(64)` unik).
   - Token akses fisik QR (*dynamic one-time QR*): `'VPQR_' . bin2hex(random_bytes(20))` (entropi **160 bit**, total **45 karakter**), disimpan sebagai *hash* **SHA-256** (`token_hash`, `char(64)` unik) dan enkripsi simetris Laravel `Crypt::encryptString()` (AES-256-CBC + HMAC-SHA256 pada `encrypted_token`) untuk penyajian E-Badge.
   - Token tautan publik E-Badge: `bin2hex(random_bytes(32))` (entropi **256 bit**, **64 karakter heksadesimal** unik pada `public_url_token`).
2. **Kebijakan Jadwal & Jendela Berlaku (TTL) Berbasis Zona Bisnis WIB (`Asia/Jakarta`) vs UTC:**
   - Durasi maksimum satu izin kunjungan: `MAX_VISIT_HOURS = 14` jam (1 *shift* operasional).
   - Jendela validitas QR (*TTL*): `valid_from = planned_check_in_at - 2 jam` hingga `valid_until = planned_check_out_at + 2 jam`.
   - Toleransi pengisian formulir publik: `earliestCheckIn = now - 15 menit` (toleransi selisih jam perangkat tamu).
   - Penyimpanan waktu di basis data menggunakan UTC (`ISO-8601 Z`), sedangkan perbandingan batas hari (`allowed_start_date`, `allowed_end_date`, `contract.start_date/end_date`, `validToday`) dikonversi ke zona bisnis `Asia/Jakarta` (WIB, UTC+7).
3. **6 Lapis Validasi *Anti-Replay* di Dalam Transaksi *Pessimistic Locking* (`scanAndVerify()`):**
   - Diawali `hash('sha256', trim($rawToken))` lalu `DB::transaction()` + `VisitorPass::where('token_hash', $attemptedHash)->lockForUpdate()->first()`.
   - Lapis 1: Keberadaan *hash* token di `dc_visitor_pass` (gagal → `DomainException` HTTP 422, log `denied_invalid_token`).
   - Lapis 2: Kesesuaian lokasi fasilitas pos jaga (`isWrongScanSite()` — bila `site_id` pos jaga ≠ `pass->site_id`, tolak HTTP 422 tanpa menghanguskan token, log `denied_wrong_site`).
   - Lapis 3: Keaktifan kontrak komersial CRM (`contract->status === 'active'`; gagal → HTTP 422, log `denied_contract_inactive`).
   - Lapis 4: Jendela waktu berlaku (`valid_from <= now <= valid_until`; gagal → HTTP 422, log `denied_expired`).
   - Lapis 5: Proteksi *Anti-Replay* sekali pakai (`qr_token_consumed_at !== null || in_array(status, ['active_in_facility', 'overstayed'])` → lempar `ReplayAttemptException` **HTTP 409 Conflict**, log `denied_already_used` dicatat **di luar rollback transaksi** agar jejak audit percobaan serangan tetap permanen).
   - Lapis 6: *Status Whitelist* (`$pass->status === 'scheduled'` saja yang diizinkan *check-in*; status lain seperti `registered` atau `cancelled` ditolak *fail-closed*).
   - Jika lolos keenam lapis: atomik memperbarui `status = 'active_in_facility'`, `qr_token_consumed_at = now()`, `actual_check_in_at = now()`, mencatat `dc_visitor_access_log` (`result = 'granted'`), dan mengembalikan daftar rak yang diizinkan (`allocated_racks`).
4. **Proteksi API Publik & Privasi Data (*OWASP API Security*):**
   - *Response Whitelisting* melalui `toRegistrationSummary()` — hanya 8 atribut aman (`pass_number`, `status`, `visitor_name`, `visitor_company`, `site_name`, `room_name`, `planned_check_in_at`, `planned_check_out_at`); memblokir 13+ atribut sensitif (`visitor_identity_number`, `safety_nda_ip`, `notes`, `contract`, `approved_by`, dll.).
   - *Read-only & Idempotent GET*: `showInvitation()` dan `show()` tidak pernah menulis mutasi status ke DB dan tidak pernah merotasi kredensial saat dekripsi gagal (*fail-closed*).
   - *Header* `Cache-Control: private, no-store` pada respons E-Badge + sensor nomor identitas (`visitor_identity_masked`, hanya 4 digit awal & 4 digit akhir).
   - *Zero Third-Party Credential Leakage*: QR dirender lokal di server (`QrCodeService` → `data:image/svg+xml;base64,...`) dan di browser (`qrEncoder.ts` → PNG canvas) sehingga token akses fisik tidak pernah dikirim ke layanan generator QR eksternal.
   - *Transactional Email Safety*: `approveVisitorPass()` menggunakan `lockForUpdate()` dan `DB::afterCommit()` sehingga koneksi SMTP tidak menahan kunci baris basis data dan surel tidak pernah terkirim bila transaksi di-*rollback*.
   - *Idempotent Check-Out & Safe Cancel*: `checkOut()` dan `cancelVisitorPass()` memakai `DB::transaction()` + `lockForUpdate()` untuk mencegah log *check-out* ganda saat *double-click* dan mencegah *race condition* pembatalan vs registrasi.

### 4. Hasil Eksekusi Pengujian Otomatis & Validasi Lapangan (Terverifikasi Langsung)
- **Lingkungan Eksekusi:** PHP `8.4.0`, PHPUnit `11.5.56`, basis data SQLite *in-memory* terisolasi dengan pembekuan waktu deterministik (`$this->travelTo()`).
- **Suite 1 (`Tests\Feature\VisitorPassInvitationAndSelfRegistrationTest`):** **36 skenario uji** (181 *assertions*) — seluruhnya **LULUS (100%)**.
- **Suite 2 (`Tests\Feature\IntegratedPublicVisitorBadgeTest`):** Mewarisi 36 skenario di atas dan menambah **3 skenario uji keamanan E-Badge & Local QR Renderer** (24 *assertions* tambahan) — total **39 skenario uji unik, 205 *assertions*, 100% LULUS (0 gagal, 0 *skipped*)** dalam **4,10 detik**.
  *(Catatan transparansi: bila kedua kelas dieksekusi bersamaan via filter PHPUnit, total eksekusi tercatat 75 runs / 386 assertions karena pewarisan kelas; untuk kejujuran ilmiah dalam artikel jurnal, angka yang dilaporkan adalah **39 skenario uji unik dengan 205 assertions**.)*
- **Validasi Lapangan (*User Acceptance Testing* / UAT):** Pengujian *end-to-end* pada lingkungan *staging* dilaksanakan pada **19 November 2026** di fasilitas PT Jawa Pos Media Televisi (JTV) Surabaya bersama perwakilan teknis pengelola pusat data (Bapak M. Triman Prasodjo, S.T.), dengan hasil seluruh alur fungsional dan kendali akses diterima tanpa galat kritis.
