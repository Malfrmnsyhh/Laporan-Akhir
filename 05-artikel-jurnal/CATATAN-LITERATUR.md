# Catatan Literatur, Uji Istilah, dan Matriks Celah Riset (*Research Gap*)

Dokumen ini merekam hasil pencarian rujukan primer, verifikasi DOI melalui OpenAlex/Crossref (`naskah-id/scripts/openalex.py`), uji keterpakaian istilah bidang informatika, serta pemetaan *state of the art* untuk artikel JIFoSI.

---

## 1. Hasil Uji Keterpakaian Istilah (`openalex.py istilah`, bidang informatika, 2019–2026)

| Konsep | Bentuk Indonesia (Judul / Pangsa) | Bentuk Asing (Judul / Pangsa) | Putusan Konsistensi Naskah |
| :--- | :--- | :--- | :--- |
| Kode matriks 2D | kode QR (19 / 2%) | ***QR code*** (779 / **98%**) | Gunakan ***QR code*** (dicetak miring; selaras dengan judul dan dominasi 98%). |
| Fasilitas ruang server | **pusat data** (23 / 27%) | *data center* (63 / 73%) | Gunakan **pusat data** agar konsisten dengan judul artikel (perkenalkan *"pusat data (*data center*)"* pada kemunculan pertama; pangsa 27% masih aktif dipakai). |
| Penyimpanan relasional | **basis data** (224 / 29%) | *database* (559 / 71%) | Gunakan **basis data** secara konsisten di seluruh teks Indonesia (perkenalkan *"basis data (*database*)"* pada kemunculan pertama; menghindari klaster cetak miring berlebihan). |
| Rekam jejak akses | jejak audit (0 / 27% J+A) | ***audit trail*** (8 / **73% J+A**) | Gunakan **jejak audit** (*audit trail* pada kemunculan pertama) atau ***audit trail*** secara konsisten — pada naskah ini dipilih **jejak audit** untuk narasi umum dan ***audit trail*** saat merujuk standar ISO/IEC 27001. |

**Aturan Singkatan Naskah (`references/singkatan.md`):**
Setiap singkatan dijelaskan pada kemunculan pertama di Abstrak (bila muncul di abstrak) dan sekali lagi pada isi naskah:
- *Quick Response* (QR) / *QR code*
- *Application Programming Interface* (API) / *Representational State Transfer* (REST)
- *Customer Relationship Management* (CRM)
- *Role-Based Access Control* (RBAC)
- *Non-Disclosure Agreement* (NDA)
- Keselamatan dan Kesehatan Kerja (K3)
- *Time-of-Check to Time-of-Use* (TOCTOU)
- *Time-to-Live* (TTL)
- *Cryptographically Secure Pseudorandom Number Generator* (CSPRNG)
- *User Acceptance Testing* (UAT)
- *Personally Identifiable Information* (PII)
- Waktu Indonesia Barat (WIB) dan *Coordinated Universal Time* (UTC)

---

## 2. Komposisi Daftar Pustaka Terverifikasi (`references.bib`)

- **Total rujukan:** **16 entri** (100% terbitan **2021–2026**).
- **Artikel jurnal *peer-reviewed* ber-DOI (2021–2026):** **13 dari 16 entri (81,25%)**, melampaui ambang minimal 80%.
- **Standar internasional & RFC resmi:** **3 entri** (`ISO/IEC 27001:2022`, `OWASP API Security Top 10:2023`, `IETF RFC 9110:2022`).
- **Seluruh abstrak telah dibaca langsung** melalui `openalex.py doi` sebelum disitasi.

---

## 3. Matriks *State of the Art* dan Celah Riset (*Research Gap*)

| Penelitian (Tahun) | Fokus & Konteks | Token QR Dinamis Sekali Pakai | *Pessimistic Locking* Anti-*Replay* (HTTP 409) | *Response Whitelisting* API Publik | Validasi Kontrak Aktif & Pos Gedung (*Multi-Site*) | *Audit Trail* & Kontrol Fisik ISO/IEC 27001 |
| :--- | :--- | :---: | :---: | :---: | :---: | :---: |
| Mubarok & Chotijah (2021) [5] | Buku tamu web QR pada industri pupuk | Tidak (QR statis) | Tidak | Tidak | Tidak | Tidak |
| Jain dkk. (2023) [6] | Kontrol akses pintu pintar berbasis QR (UID) & Arduino | Tidak (UID statis) | Tidak | Tidak | Tidak | Parsial (log UID dasar) |
| Saputra dkk. (2026) [7] | Sistem *check-in* tamu web perkantoran (RBAC, *overstay*, OCR) | Tidak | Tidak | Tidak | Tidak (tanpa kontrak/pos *multi-site*) | Parsial (*audit log* & kehadiran darurat) |
| Jasri dkk. (2026) [8] | Manajemen pengunjung *enterprise* Laravel + QR + RESTful API | Parsial (QR autentikasi) | Tidak | Tidak dibahas eksplisit | Parsial (persetujuan karyawan, tanpa kontrak kolokasi & pos gedung) | Parsial (uji OWASP ZAP, tanpa matriks ISO 27001) |
| Slameto dkk. (2026) [9] | Evaluasi keamanan sistem QR *anti-replay* berbasis RSA-PSS + *nonce-timestamp* | Ya (*nonce-timestamp*) | Tidak (evaluasi kriptografi, bukan transaksi *lockForUpdate* pos jaga) | Tidak | Tidak | Tidak (fokus identitas digital umum) |
| **Sistem yang Diusulkan (2026)** | **Manajemen izin akses fisik pusat data kolokasi (*DataCenterOps*)** | **Ya (`VPQR_` CSPRNG 160-bit + SHA-256 + TTL)** | **Ya (`DB::transaction` + `lockForUpdate()`, HTTP 409)** | **Ya (`toRegistrationSummary()` + sensor PII + `no-store` + *local QR*)** | **Ya (kontrak CRM aktif + rak teralokasi + `isWrongScanSite()`)** | **Ya (K3/NDA IP, *vetting*, 8 kode `dc_visitor_access_log`, *overstay* 10 menit, *live headcount*)** |

### Rumusan Celah Riset (*Research Gap*)
Berdasarkan sintesis literatur:
1. Studi kepatuhan ISO/IEC 27001:2022 pada pusat data internal [2] dan sektor teregulasi [3] menekankan pentingnya kontrol fisik dan tata kelola pihak ketiga, namun berfokus pada evaluasi audit prosedural dan belum menyajikan implementasi arsitektur perangkat lunak perizinan akses fisik yang dapat diaudit secara otomatis.
2. Tinjauan sistematis Alsawi dan Ibrahim [4] serta studi empiris buku tamu berbasis *QR code* di Indonesia [5], [6], [7], [8] menunjukkan bahwa sebagian besar sistem pengunjung masih mengandalkan *QR code* statis atau pencocokan pengenal tunggal tanpa mekanisme pembatalan atomik sekali pakai.
3. Penelitian *anti-replay* QR oleh Slameto dkk. [9] menelaah 26 studi QR Indonesia dan menemukan belum adanya evaluasi *anti-replay* multi-skenario yang utuh; sementara Wang dkk. [10] dan Miyachi dkk. [11] membuktikan bahwa transaksi web tanpa isolasi dan penguncian yang tepat sangat rentan terhadap kondisi balapan (*race condition* / TOCTOU). Di sisi lain, risiko *Broken Object Property Level Authorization* (*excessive data exposure*) pada API publik [12], [13] masih sering terabaikan dalam sistem pendaftaran tamu tanpa autentikasi.
4. **Kebaruan Penelitian Ini:** Menggabungkan penerbitan token *dynamic one-time QR code* berentropi 160-bit (`VPINV_` dan `VPQR_`) tersimpan dalam *hash* SHA-256, 6 lapis validasi *anti-replay* di dalam transaksi *pessimistic row locking* (`lockForUpdate()`), *response whitelisting* serta *local QR rendering* (*fail-closed*) pada *endpoint* publik, validasi silang kontrak kolokasi CRM aktif dan lokasi pos gedung, serta pencatatan permanen `dc_visitor_access_log` di luar *rollback* transaksi demi pemenuhan kendali akses fisik ISO/IEC 27001:2022.
