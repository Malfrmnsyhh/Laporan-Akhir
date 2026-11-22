# PENDAHULUAN

## Latar Belakang

Sistem perangkat lunak skala korporat (*enterprise*) dituntut mampu berkembang tanpa mengorbankan keandalan data transaksi, sementara domain bisnis yang berbeda tetap terpisah satu sama lain. Melalui program Merdeka Belajar Kampus Merdeka (MBKM) jalur Praktik Lapangan Kerja (PLK), mahasiswa menguji apakah konsep yang dipelajari di perkuliahan, yaitu analisis kebutuhan, pemodelan basis data relasional, dan perancangan antarmuka pemrograman aplikasi, dapat memenuhi tuntutan tersebut di lingkungan industri [@pressman2020software].

PT Jawa Pos Media Televisi (JTV), stasiun televisi regional yang berpusat di Surabaya, mengoperasikan fasilitas *Data Center* dan *Managed Services* komersial di samping lini penyiaran utamanya. Fasilitas pusat data ini melayani penempatan peladen (*colocation server*), penyewaan ruang lemari rak (*rack space*), pasokan daya listrik yang kontinu, temperatur ruangan yang stabil, serta interkoneksi jaringan berkecepatan tinggi bagi klien korporat eksternal [@tia942c_2024]. Untuk mengelola operasional dan transaksi komersial fasilitas itu, PT Jawa Pos Media Televisi mengembangkan sistem *Enterprise Resource Planning* (ERP) internal bernama MSDC ERP.

Fasilitas pusat data skala industri hanya dapat dikelola dengan data spasial yang presisi dan disiplin operasional yang ketat. Observasi awal selama praktik kerja di PT Jawa Pos Media Televisi menunjukkan bahwa operasional *data center* yang berjalan tanpa modul *Data Center Infrastructure Management* (DCIM) terintegrasi menimbulkan enam masalah struktural berikut:

1. **Risiko Alokasi Ganda (*Double-Booking & Slot Allocation Conflict*)**: Tanpa mekanisme kendali konkurensi data, dua pesanan penjualan (*sales orders*) dari tim komersial dapat mengklaim unit slot lemari rak (*rack unit/U*) yang sama secara bersamaan, sehingga berpotensi menimbulkan wanprestasi terhadap penyewa (*tenant*).
2. **Inkonsistensi Spasial Fasilitas**: Penamaan dan pemetaan hierarki fisik mulai dari gedung (*site*), ruangan fungsional (*room*), lemari rak (*rack 42U*), hingga slot penempatan peladen yang tidak terstandardisasi menyulitkan teknisi lapangan dalam mengidentifikasi aset fisik secara cepat.
3. **Kekacauan Jalur Pengkabelan (*Cable Spaghetti & Port Collision*)**: Interkoneksi kabel lintas rak (*cross-connect*) dan panel terminasi optik (*Optical Termination Box / OTB*) yang tidak didokumentasikan secara digital memperbesar risiko terputusnya transmisi data (*unplanned downtime*), karena teknisi dapat keliru mencabut kabel jaringan saat pemeliharaan.
4. **Inefisiensi Pengawasan Termal dan Daya Listrik**: Pemantauan suhu lingkungan lorong panas dan lorong dingin (*hot and cold aisle*) serta batas ambang daya listrik per rak yang masih bergantung pada pencatatan berkala manual berpotensi melanggar rekomendasi termal standar ASHRAE TC 9.9 [@ashrae2021tc99], yang dapat memperpendek usia operasional perangkat keras peladen.
5. **Celah Kepatuhan Akses Keamanan Fisik ISO/IEC 27001**: Prosedur pendaftaran dan pemeriksaan pengunjung *data center* yang masih mengandalkan buku registrasi kertas pada pos jaga satpam memiliki kelemahan: identitas pengunjung tidak divalidasi secara otomatis, izin masuk dapat dipalsukan, dan jejak audit (*audit trail*) digital yang dipersyaratkan standar keamanan informasi internasional ISO/IEC 27001 [@iso27001_2022; @widharto2026iso27001] tidak tersedia.
6. **Sekat Informasi Antardivisi (*Information Silo*)**: Data divisi penjualan (*CRM & Sales*) tidak terhubung dengan data teknisi *Network Operations Center* (NOC), sehingga status penagihan (*billing*) dapat berbeda dari utilisasi fasilitas fisik yang sesungguhnya dipakai pelanggan.

Untuk mengatasi persoalan tersebut, dirancang dan diimplementasikan modul *DataCenterOps* yang terintegrasi penuh ke dalam sistem ERP MSDC. Modul ini dibangun dengan *Modular Architecture* pada kerangka kerja Laravel 11 di sisi peladen (*backend*) dan *RESTful API* pada pustaka React 18 berbasis TypeScript di sisi antarmuka pengguna (*frontend*) [@fielding2022rfc9110; @putra2025laravelreact]. Pendekatan modular memisahkan domain logika operasional *data center* dari modul bisnis lainnya [@richards2020fundamentals]. Walaupun terpisah, modul ini tetap memakai modul kernel *CorePlatform* untuk menegakkan isolasi multi-organisasi (*multi-tenancy*), mengatur otorisasi peran pengguna (*Role-Based Access Control* / RBAC), menomori dokumen secara otomatis dan terpusat (*number sequence*), serta menjalankan alur persetujuan bertingkat (*workflow approval engine*). Dengan cara ini, data master fasilitas, transaksi alokasi sumber daya, pelaporan telemetri, dan log audit dapat dikelola secara terpusat dan konsisten.

## Lingkup

Proyek yang dikerjakan selama Praktik Lapangan Kerja ini dibatasi pada perancangan dan pembangunan modul *DataCenterOps* pada sistem MSDC ERP milik PT Jawa Pos Media Televisi. Modul ini mencakup lima klaster fungsional:

1. **Klaster 1: Hirarki Fasilitas Fisik dan Visualisasi Elevasi Rak 42U**:
   - Pemodelan hierarki spasial bertingkat mencakup manajemen gedung *data center* (*Site*), ruangan dan zona fungsional (*Room*), serta lemari rak standar EIA-310 (*Rack 42U*).
   - Rancang bangun komponen visual antarmuka *Visual 42U Elevation Grid* interaktif yang memetakan status keterisian setiap slot unit rak (kosong, direservasi, atau terisi) secara *real-time*.
   - Kalkulasi otomatis terhadap pemanfaatan ruang unit rak (*space utilization*) dan akumulasi konsumsi daya listrik terhadap kapasitas batas aman rak (*power capacity in Watt*).
2. **Klaster 2: Konektivitas Jaringan dan Pengkabelan (*Connectivity Layer*)**:
   - Manajemen inventaris perangkat keras peladen dan perangkat jaringan (*Device Inventory*).
   - Pendataan dan validasi keunikan port jaringan (*Network Port Management*).
   - Pemetaan rute pengkabelan interkoneksi antarak dan antarpelanggan (*Cross-Connect*).
   - Inventarisasi panel terminasi serat optik (*Optical Termination Box / OTB*) dan tata kelola blok pengalamatan protokol internet (*IP Address Management / IPAM*).
3. **Klaster 3: Telemetri Lingkungan dan Pengawasan (*Monitoring & Surveillance*)**:
   - *Dashboard* terpusat *Network Operations Center* (NOC) untuk visualisasi status operasional fasilitas *data center*.
   - Pemantauan telemetri termal lingkungan (suhu dan kelembaban udara) berbasis batas rekomendasi ASHRAE TC 9.9.
   - Integrasi pemantauan visual lorong rak melalui pemutaran umpan kamera sirkuit tertutup (*CCTV surveillance*).
4. **Klaster 4: Operasional Harian dan Administrasi (*Operations & Workflow*)**:
   - Pengelolaan tiket gangguan dan permohonan bantuan teknis lapangan (*Ticket & Remote Hands*).
   - Penerbitan dan pelacakan surat perintah kerja teknisi (*Work Order*).
   - Pencatatan rekaman penggunaan fasilitas untuk dasar kalkulasi biaya sewa (*Usage Records & Billing*).
   - Pembuatan dan verifikasi keabsahan tata naskah surat operasional *data center* berbasis kode QR publik.
5. **Klaster 5: Keamanan Akses Fisik dan Kepatuhan Regulasi ISO/IEC 27001**:
   - Pendaftaran dan penerbitan surat izin masuk pengunjung fasilitas *data center* (*Visitor Pass Management*).
   - Pembangkitan kode QR dinamis sekali pakai (*Dynamic One-Time QR Code*) yang terenkripsi dan terikat pada masa berlaku kunjungan.
   - Pengembangan antarmuka pemindai pos jaga satpam (*Scanner Guard*) berbasis kamera penjelajah web untuk verifikasi keabsahan izin kunjungan secara seketika (*instant check-in/check-out*).

Integrasi lintas modul dibatasi pada pemakaian layanan bersama (*shared kernel services*) dari modul *CorePlatform*. Layanan itu mencakup sistem identitas pengguna, isolasi organisasi multi-penyewa melalui penyuntikan *header* *X-Organization-Id* dan *Eloquent Global Scope*, verifikasi hak akses berbasis *Spatie Permission*, penomoran dokumen transaksi secara atomik melalui *NumberSequence::next()*, serta orkestrasi persetujuan rilis kapasitas rak melalui *WorkflowEngineService*. Selain itu, modul ini berintegrasi dengan modul *CrmSales* sebagai dasar verifikasi kontrak komersial dan pesanan penjualan pelanggan sebelum alokasi fisik dilakukan.

Sistem dikembangkan dengan tumpukan teknologi berikut:

- **Sisi Klien (*Frontend*)**: React 18 *Single Page Application* (SPA), Vite, TypeScript, Tailwind CSS, TanStack Query v5 untuk manajemen sinkronisasi data server, Axios, Lucide React, dan pustaka pemindai kamera HTML5-QRCode.
- **Sisi Peladen (*Backend*)**: PHP 8.2+, kerangka kerja Laravel 11 Modular (*nwidart/laravel-modules*), Laravel Passport untuk otentikasi berbasis *OAuth2 Bearer Token*, dan sistem manajemen basis data relasional MySQL 8.

Sesuai panduan resmi program studi, kronologi aktivitas kerja selama masa magang diuraikan pada Sub-bab II.3 (Deskripsi Pekerjaan).

## Tujuan

Praktik Lapangan Kerja di PT Jawa Pos Media Televisi bertujuan menjawab kebutuhan operasional mitra industri sekaligus memenuhi capaian pembelajaran program magang, dengan rincian sebagai berikut:

1. **Integrasi Teori Akademik dan Pemenuhan Paket Konversi MBKM**: Menerapkan konsep-konsep teoretis rekayasa perangkat lunak yang diperoleh selama perkuliahan ke dalam proyek industri nyata, sekaligus memenuhi seluruh indikator capaian pembelajaran pada paket konversi mata kuliah program Merdeka Belajar Magang Industri, yang meliputi *Analisis Kebutuhan*, *Pemrograman Framework*, *Pemrograman API*, *Praktik Kerja Lapangan*, serta *Seminar Hasil Merdeka Belajar I*.
2. **Peningkatan Kompetensi Teknis Rekayasa Perangkat Lunak *Enterprise***: Mengembangkan kapabilitas teknis mahasiswa dalam merancang dan mengimplementasikan arsitektur *fullstack* skala *enterprise*. Cakupannya meliputi *Modular Architecture* pada kerangka kerja Laravel 11, antarmuka pengguna interaktif dengan React 18 berbasis TypeScript, kontrak antarmuka *RESTful API* yang aman, serta kendali konkurensi data (*pessimistic locking*) pada basis data relasional MySQL.
3. **Penguatan Kolaborasi Tim Lintas Modul dan Komunikasi Profesional**: Membangun pengalaman bekerja dalam tim pengembang perangkat lunak industri melalui koordinasi antarmodul (Tim *Data Center Operations*, Tim *CorePlatform*, dan Tim *CRM & Sales*). Pengalaman itu mencakup tata kelola versi dengan Git yang terstruktur serta latihan komunikasi teknis, yaitu mempresentasikan kemajuan pekerjaan dan mendiskusikan kendala rekayasa pada sesi evaluasi berkala bersama mentor industri.
4. **Adaptasi Budaya Kerja dan Standar Operasional Industri**: Memahami dinamika dan etika profesional di lingkungan Divisi Teknologi Informasi perusahaan penyiaran dan penyedia fasilitas pusat data komersial, serta melatih kedisiplinan dan manajemen waktu dalam skema kerja *hybrid*. Standar industri dipakai sebagai acuan rancangan sistem, yaitu TIA-942 untuk infrastruktur telekomunikasi *data center*, ASHRAE TC 9.9 untuk rekomendasi termal, dan ISO/IEC 27001 untuk prinsip keamanan akses fisik.
5. **Kontribusi Nyata bagi Transformasi Digital Mitra Industri**: Menyediakan modul operasional pusat data terintegrasi yang mencegah tabrakan alokasi lemari rak (*double-booking*), memudahkan inventarisasi aset dan penelusuran jalur pengkabelan jaringan, memusatkan pemantauan kondisi lingkungan, serta memperkuat audit keamanan akses fisik pada sistem ERP MSDC PT Jawa Pos Media Televisi (JTV).
