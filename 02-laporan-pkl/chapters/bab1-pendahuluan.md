# PENDAHULUAN

## Latar Belakang

Pendidikan tinggi bidang informatika menuntut keseimbangan antara penguasaan teori komputasi dan penerapannya dalam menyelesaikan persoalan nyata di dunia industri. Melalui program Merdeka Belajar Kampus Merdeka (MBKM) jalur Magang Mandiri atau Praktik Lapangan Kerja (PLK), mahasiswa memperoleh kesempatan untuk berpartisipasi langsung dalam proyek rekayasa perangkat lunak skala korporat (*enterprise*). Pengalaman ini menjembatani konsep teoretis yang dipelajari di bangku perkuliahan, seperti analisis kebutuhan perangkat lunak, perancangan arsitektur sistem, dan pengembangan antarmuka pemrograman aplikasi, dengan standar industri yang mengutamakan skalabilitas, modularitas, serta keandalan sistem [@pressman2019software].

PT Jawa Pos Media Televisi (JTV), sebagai salah satu stasiun televisi regional terkemuka di Indonesia yang berpusat di Surabaya, terus beradaptasi dengan dinamika industri penyiaran modern. Dalam mempertahankan keunggulan kompetitif, perusahaan melakukan transformasi digital melalui diversifikasi lini usaha ke penyediaan infrastruktur *Data Center* dan *Managed Services*. Fasilitas pusat data komersial ini melayani penempatan peladen (*colocation server*), penyediaan kapasitas ruang rak (*rack space*), jaminan keandalan catu daya listrik, kestabilan temperatur pendingin, serta interkoneksi jaringan berkecepatan tinggi bagi berbagai entitas bisnis eksternal [@tia942b]. Untuk mengonsolidasikan seluruh aktivitas bisnis dan operasional perusahaan secara efisien dan mandiri, PT Jawa Pos Media Televisi mengembangkan sistem *Enterprise Resource Planning* (ERP) internal terpadu yang dinamakan MSDC ERP.

Pengelolaan fasilitas pusat data komersial menuntut akurasi data spasial dan disiplin operasional yang sangat tinggi. Berdasarkan observasi awal selama pelaksanaan praktik industri di PT Jawa Pos Media Televisi, ditemukan bahwa pengelolaan operasional data center yang dilakukan tanpa modul *Data Center Infrastructure Management* (DCIM) terintegrasi memicu berbagai permasalahan struktural:

1. **Risiko Alokasi Ganda (*Double-Booking & Slot Allocation Conflict*)**: Ketiadaan mekanisme kendali konkurensi data yang ketat memungkinkan dua pesanan penjualan (*sales orders*) dari tim komersial secara bersamaan mengklaim unit slot lemari rak (*rack unit/U*) yang sama, sehingga berpotensi menimbulkan wanprestasi terhadap penyewa (*tenant*).
2. **Inkonsistensi Spasial Fasilitas**: Penamaan dan pemetaan hierarki fisik mulai dari gedung (*site*), ruangan fungsional (*room*), lemari rak (*rack 42U*), hingga slot penempatan peladen yang tidak terstandardisasi menyulitkan teknisi lapangan dalam mengidentifikasi aset fisik secara cepat.
3. **Kekacauan Jalur Pengkabelan (*Cable Spaghetti & Port Collision*)**: Dokumentasi interkoneksi kabel lintas rak (*cross-connect*) dan panel terminasi optik (*Optical Termination Box / OTB*) yang tidak terdokumentasi secara digital memperbesar risiko terputusnya transmisi data (*unplanned downtime*) akibat kekeliruan pencabutan kabel jaringan pada saat pemeliharaan.
4. **Inefisiensi Pengawasan Termal dan Daya Listrik**: Pemantauan suhu lingkungan lorong panas dan lorong dingin (*hot and cold aisle*) serta batas ambang daya listrik per rak yang masih bergantung pada pencatatan berkala manual berpotensi melanggar rekomendasi termal standar ASHRAE TC 9.9 [@ashrae2021tc99], yang dapat memperpendek usia operasional perangkat keras peladen.
5. **Celah Kepatuhan Akses Keamanan Fisik ISO/IEC 27001**: Prosedur pendaftaran dan pemeriksaan pengunjung data center yang masih mengandalkan buku registrasi kertas pada pos jaga satpam memiliki kelemahan signifikan, antara lain tiadanya validasi identitas otomatis, risiko pemalsuan izin masuk, serta hilangnya jejak audit (*audit trail*) digital yang dipersyaratkan oleh standar keamanan informasi internasional ISO/IEC 27001 [@iso27001_2022].
6. **Sekat Informasi Antardivisi (*Information Silo*)**: Terputusnya komunikasi data antara divisi penjualan (*CRM & Sales*) dengan teknisi *Network Operations Center* (NOC) menyebabkan ketidaksinkronan antara status penagihan (*billing*) dengan utilisasi fasilitas fisik yang sesungguhnya digunakan oleh pelanggan.

Guna mengatasi rangkaian persoalan tersebut, diperlukan perancangan dan implementasi modul **`DataCenterOps`** yang terintegrasi penuh ke dalam sistem ERP MSDC. Rekayasa modul ini dibangun dengan menerapkan *Modular Architecture* pada kerangka kerja Laravel 11 di sisi peladen (*backend*) dan *RESTful API* pada pustaka React 18 berbasis TypeScript di sisi antarmuka pengguna (*frontend*) [@fielding2000architectural]. Pendekatan modular memisahkan domain logika operasional data center dari modul bisnis lainnya, namun tetap terikat kuat dengan modul kernel `CorePlatform` untuk penegakan isolasi multi-organisasi (*multi-tenancy*), otorisasi peran pengguna (*Role-Based Access Control* / RBAC), penomoran seri otomatis terpusat (*number sequence*), dan mesin alur kerja persetujuan bertingkat (*workflow approval engine*). Implementasi ini menjamin bahwa seluruh data master fasilitas, transaksi alokasi sumber daya, hingga pelaporan telemetri dan log audit dapat dikelola secara terpusat, konsisten, dan aman.

## Lingkup

Ruang lingkup proyek rekayasa perangkat lunak yang diselesaikan dalam kegiatan Praktik Lapangan Kerja ini dibatasi pada perancangan dan pembangunan modul **`DataCenterOps`** pada sistem MSDC ERP PT Jawa Pos Media Televisi. Modul ini mencakup lima klaster kapabilitas fungsional utama:

1. **Klaster 1: Hirarki Fasilitas Fisik dan Visualisasi Elevasi Rak 42U**:
   - Pemodelan hierarki spasial bertingkat mencakup manajemen gedung data center (*Site*), ruangan dan zona fungsional (*Room*), serta lemari rak standar EIA-310 (*Rack 42U*).
   - Rancang bangun komponen visual antarmuka *Visual 42U Elevation Grid* interaktif yang memetakan status keterisian setiap slot unit rak (kosong, direservasi, atau terisi) secara *real-time*.
   - Kalkulasi otomatis terhadap pemanfaatan ruang unit rak (*space utilization*) dan akumulasi konsumsi daya listrik terhadap kapasitas batas aman rak (*power capacity in Watt*).
2. **Klaster 2: Konektivitas Jaringan dan Pengkabelan (*Connectivity Layer*)**:
   - Manajemen inventaris perangkat keras peladen dan perangkat jaringan (*Device Inventory*).
   - Pendataan dan validasi keunikan port jaringan (*Network Port Management*).
   - Pemetaan rute pengkabelan interkoneksi antarak dan antarpelanggan (*Cross-Connect*).
   - Inventarisasi panel terminasi serat optik (*Optical Termination Box / OTB*) dan tata kelola blok pengalamatan protokol internet (*IP Address Management / IPAM*).
3. **Klaster 3: Telemetri Lingkungan dan Pengawasan (*Monitoring & Surveillance*)**:
   - Dashboard terpusat *Network Operations Center* (NOC) untuk visualisasi status operasional fasilitas data center.
   - Pemantauan telemetri termal lingkungan (suhu dan kelembaban udara) berbasis batas rekomendasi ASHRAE TC 9.9.
   - Integrasi pemantauan visual lorong rak melalui pemutaran umpan kamera sirkuit tertutup (*CCTV surveillance*).
4. **Klaster 4: Operasional Harian dan Administrasi (*Operations & Workflow*)**:
   - Pengelolaan tiket gangguan dan permohonan bantuan teknis lapangan (*Ticket & Remote Hands*).
   - Penerbitan dan pelacakan surat perintah kerja teknisi (*Work Order*).
   - Pencatatan rekaman penggunaan fasilitas untuk dasar kalkulasi biaya sewa (*Usage Records & Billing*).
   - Pembuatan dan verifikasi keabsahan tata naskah surat operasional data center berbasis kode QR publik.
5. **Klaster 5: Keamanan Akses Fisik dan Kepatuhan Regulasi ISO/IEC 27001**:
   - Pendaftaran dan penerbitan surat izin masuk pengunjung fasilitas data center (*Visitor Pass Management*).
   - Pembangkitan kode QR dinamis sekali pakai (*Dynamic One-Time QR Code*) yang terenkripsi dan terikat pada masa berlaku kunjungan.
   - Pengembangan antarmuka pemindai pos jaga satpam (*Scanner Guard*) berbasis kamera penjelajah web untuk verifikasi keabsahan izin kunjungan secara seketika (*instant check-in/check-out*).

Batasan integrasi lintas modul meliputi pemanfaatan layanan bersama (*shared kernel services*) dari modul **`CorePlatform`**, yang mencakup sistem identitas pengguna, penegakan isolasi organisasi multi-penyewa melalui penyuntikan *header* `X-Organization-Id` dan *Eloquent Global Scope*, verifikasi hak akses berbasis *Spatie Permission*, penomoran dokumen transaksi secara atomik melalui `NumberSequence::next()`, serta orkestrasi persetujuan rilis kapasitas rak melalui `WorkflowEngineService`. Selain itu, modul ini berintegrasi dengan modul **`CrmSales`** sebagai jangkar verifikasi kontrak komersial dan pesanan penjualan pelanggan sebelum alokasi fisik dilakukan.

Pengembangan sistem mengadopsi tumpukan teknologi modern:

- **Sisi Klien (*Frontend*)**: React 18 *Single Page Application* (SPA), Vite, TypeScript, Tailwind CSS, TanStack Query v5 untuk manajemen sinkronisasi data server, Axios, Lucide React, dan pustaka pemindai kamera HTML5-QRCode.
- **Sisi Peladen (*Backend*)**: PHP 8.2+, kerangka kerja Laravel 11 Modular (`nwidart/laravel-modules`), Laravel Passport untuk otentikasi berbasis *OAuth2 Bearer Token*, dan sistem manajemen basis data relasional MySQL 8.

Sesuai dengan ketentuan panduan resmi program studi, rincian kronologis tahapan aktivitas kerja mahasiswa selama masa magang tidak dibahas pada sub-bab ini, melainkan diuraikan secara tersendiri pada Sub-bab II.3 (Deskripsi Pekerjaan).

## Tujuan

Tujuan pelaksanaan Praktik Lapangan Kerja di PT Jawa Pos Media Televisi dirumuskan secara terukur untuk menjawab kebutuhan industri mitra serta memenuhi capaian pembelajaran empat mata kuliah konversi kurikulum program studi:

1. **Capaian Mata Kuliah Analisis Kebutuhan (IF261206)**:
   - Menganalisis, mengidentifikasi, dan mendokumentasikan spesifikasi kebutuhan perangkat lunak (SKPL) fungsional dan non-fungsional untuk modul operasional pusat data.
   - Merancang model aliran data menggunakan *Data Flow Diagram* (DFD) mulai dari tingkat konteks (Level 0), Level 1, hingga Level 2, serta menyusun skenario kasus penggunaan (*usecase diagram & scenario*) dan diagram alur pengguna (*user flow*) pada subsistem alokasi rak dan perizinan akses fisik.
2. **Capaian Mata Kuliah Pemrograman Framework (IF261208)**:
   - Mengimplementasikan arsitektur perangkat lunak berbasis kerangka kerja modern pada sisi klien menggunakan React 18, TypeScript, dan TanStack Query yang mengedepankan keamanan tipe data (*type safety*), modularitas komponen visual, serta efisiensi manajemen status (*state management*).
   - Membangun arsitektur modular pada sisi peladen menggunakan Laravel 11 Modular yang memisahkan tanggung jawab kode (*separation of concerns*) ke dalam lapisan pengendali (*controller*), layanan domain (*service layer*), dan model data Eloquent, serta menerapkan *trait* semesta `ScopesOrganization` untuk penegakan isolasi *multi-tenancy* secara otomatis.
3. **Capaian Mata Kuliah Pemrograman API (IF261217)**:
   - Merancang spesifikasi kontrak antarmuka *RESTful API* yang konsisten meliputi pemilihan metode HTTP, struktur muatan data (*payload*) JSON, dan kode status HTTP representatif pada seluruh subsistem *DataCenterOps*.
   - Menerapkan lapisan pertahanan keamanan API berlapis, mencakup otentikasi *OAuth2 Bearer Token* via Laravel Passport dengan *guard* `api`, otorisasi izin pengguna melalui `ApiPermissionMiddleware`, serta pengamanan komunikasi mesin (*M2M*) telemetri menggunakan `ApiKeyMiddleware` yang dilengkapi validasi daftar putih alamat IP berbasis notasi CIDR (*Classless Inter-Domain Routing*).
   - Merancang dan mengimplementasikan skema basis data fisik relasional MySQL dengan relasi referensial berintegritas tinggi serta menerapkan kendali konkurensi pesimistik (*pessimistic locking*) untuk mengeliminasi potensi tabrakan data alokasi rak.
4. **Capaian Mata Kuliah Praktik Kerja Lapangan (IF221129)**:
   - Menerapkan metodologi pengembangan perangkat lunak kolaboratif berbasis *Agile/Scrum* dalam lingkungan tim rekayasa industri profesional di PT Jawa Pos Media Televisi.
   - Mengembangkan kemampuan komunikasi interpersonal, kedisiplinan kerja industri, koordinasi teknis, serta adaptabilitas terhadap standar operasional prosedur perusahaan penyiaran dan penyedia pusat data.
   - Menghasilkan modul perangkat lunak fungsional yang tervalidasi melalui pengujian penerimaan pengguna (*User Acceptance Testing* / UAT) di lingkungan *staging* serta menyusun laporan pertanggungjawaban teknis yang siap diseminarkan pada mata kuliah Seminar Hasil Merdeka Belajar I (IF221379).
5. **Capaian Manfaat bagi Mitra Industri**:
   - Menghadirkan modul operasional pusat data terpadu yang memitigasi risiko alokasi ganda lemari rak, memangkas waktu pelacakan jalur kabel dan port jaringan, mengotomatisasi pengawasan standar termal ASHRAE TC 9.9, serta memperkuat kepatuhan audit keamanan akses fisik berstandar ISO/IEC 27001 pada sistem ERP MSDC PT Jawa Pos Media Televisi.
