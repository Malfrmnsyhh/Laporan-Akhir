# REKOGNISI KEGIATAN PLK DENGAN KONVERSI MATA KULIAH

## Rekognisi Mata Kuliah Analisis Kebutuhan (IF261206)

*(Panduan Penulisan Sub-Bab IV.1)*:
Bagian ini memetakan artefak rekayasa perangkat lunak hasil magang ke dalam Capaian Pembelajaran Mata Kuliah (CPMK) Analisis Kebutuhan:
1. **Spesifikasi Kebutuhan Perangkat Lunak (SKPL / SRS)**:
   - Identifikasi Kebutuhan Fungsional (FR): Mulai dari FR-DC-01 (Manajemen Fasilitas Gedung), FR-DC-02 (Alokasi Rak Spasial), FR-DC-03 (Manajemen Port & Kabel Jaringan), hingga FR-DC-05 (Registrasi & Pemindaian Visitor Pass).
   - Identifikasi Kebutuhan Non-Fungsional (NFR): Ketersediaan (*High Availability*), keamanan multi-tenant, integritas transaksi basis data, serta kecepatan respon API (< 200 ms).
2. **Pemodelan Aliran Data (Data Flow Diagram - DFD)**:
   - DFD Level 0 (Diagram Konteks): Memetakan interaksi entitas luar (Teknisi NOC, Pengunjung Eksternal, Satpam, Staf Sales CRM, Sensor IoT) dengan sistem MSDC ERP.
   - DFD Level 1: Rincian 5 proses utama modul Data Center Operations.
   - DFD Level 2: Dekomposisi proses alokasi unit slot rak dan validasi tiket izin masuk.
3. **Pemodelan Perilaku Pengguna**:
   - *Usecase Diagram* dan skenario kasus penggunaan (*Usecase Scenario*).
   - *User Flow Diagram* alur peminjaman kapasitas rak dan persetujuan bertingkat (*workflow approval*).

## Rekognisi Mata Kuliah Pemrograman Framework (IF261208)

*(Panduan Penulisan Sub-Bab IV.2)*:
Bagian ini membuktikan kompetensi rekayasa perangkat lunak berbasis kerangka kerja modern (*framework*):
1. **Rekayasa Framework Sisi Klien (React 18 + Vite + TypeScript)**:
   - Pola modular antarmuka: pemisahan direktori *modules/data-center-ops/* dan *shared/components/*.
   - *State Management* dan sinkronisasi server: pemanfaatan TanStack Query (React Query) untuk manajemen *caching*, *optimistic update*, dan pencegahan *duplicate network requests*.
   - *Component-Driven Architecture*: rancang bangun komponen kustom interaktif seperti *RackVisualPicker.tsx* (grid vertikal 42U) dan *QrScannerModal.tsx*.
   - *Type Safety*: pendefinisian antarmuka tipe TypeScript yang ketat pada lapisan DTO (*Data Transfer Object*).
2. **Rekayasa Framework Sisi Server (Laravel 11 Modular)**:
   - Arsitektur berbasis paket modul (*Modules/DataCenterOps/* dan *Modules/CorePlatform/*).
   - Pemisahan lapisan tanggung jawab (*Separation of Concerns*): Lapisan *Controller* tipis, *Domain Service Layer* berbobot, *Form Request Validator*, dan *Eloquent Model*.
   - Penegakan *multi-tenancy* transparan via *Global Scope Eloquent Trait* *ScopesOrganization*.
   - Penanganan eksepsi global (*Global Exception Handler*) untuk penomoran otomatis dokumen *NumberSequenceNotConfiguredException*.

## Rekognisi Mata Kuliah Pemrograman API (IF261217)

*(Panduan Penulisan Sub-Bab IV.3)*:
Bagian ini memvalidasi penguasaan arsitektur antarmuka pemrograman aplikasi (API):
1. **Perancangan Arsitektur RESTful API**:
   - Standar kontrak *endpoint* (URI, metode HTTP, format respon standar JSON *{success, message, data, errors}*, serta kode status HTTP yang tepat: 200, 201, 401, 403, 409, 422).
   - Penyusunan tabel spesifikasi *endpoint* representatif modul Data Center Operations.
2. **Lapisan Keamanan & Middleware Pipeline**:
   - Autentikasi OAuth2 berbasis *Bearer Token* (Laravel Passport) yang ditegakkan melalui *guard* terdedikasi *api*.
   - *Middleware* otorisasi berbasis peran: *ApiPermissionMiddleware* yang memeriksa izin granuler pengguna sebelum *controller* dieksekusi.
   - *Middleware* integrasi mesin (*M2M*): *ApiKeyMiddleware* untuk sensor telemetri rak yang memvalidasi kunci kriptografi dan menyaring IP pengirim via pencocokan subnet CIDR (*CIDR IP Whitelist Guard*).
3. **Pemodelan Data Fisik & Relasi ERD**:
   - Penyajian diagram relasi entitas (*Physical ERD*) mencakup tabel *dc_site*, *dc_site_room*, *dc_rack*, *dc_rack_allocation*, *dc_device*, *dc_network_port*, *dc_cross_connect*, dan *dc_visitor_pass*.
   - Penegakan integritas data: *foreign key constraints*, *composite unique indexes*, serta *scoped uniqueness* (contoh: nomor port unik per perangkat, kode ruangan unik per gedung).

## Rekognisi Mata Kuliah Praktik Kerja Lapangan (IF221129) dan Magang Industri (IF221381)

*(Panduan Penulisan Sub-Bab IV.4)*:
Bagian ini mendokumentasikan pemenuhan seluruh persyaratan administratif dan capaian kompetensi magang industri:
1. **Bukti Pelaksanaan Praktik Industri**: Keterlibatan langsung dalam siklus pengembangan perangkat lunak industri di PT Jawa Pos Media Televisi.
2. **Pengembangan Softskill & Budaya Kerja**: Pengalaman kerja tim lintas disiplin, kedisiplinan jadwal rilis, koordinasi komunikasi teknis, serta adaptasi terhadap kebutuhan klien korporat.
3. **Kesiapan Luaran Seminar Hasil**: Penyusunan bahan presentasi, laporan teknis komprehensif, dan demonstrasi sistem live untuk diujikan pada mata kuliah Seminar Hasil Merdeka Belajar I (IF221379).
