# PENDAHULUAN

## Latar Belakang

*(Panduan Penulisan Sub-Bab I.1)*:
Bagian ini menguraikan konteks objektif yang melatarbelakangi pelaksanaan Praktik Lapangan Kerja (PLK) / Magang Mandiri di PT Jawa Pos Media Televisi (JTV). Uraian berfokus pada:
1. **Profil Singkat & Misi Mitra**: Peran PT Jawa Pos Media Televisi (JTV) sebagai media penyiaran yang bertransformasi dan mendiversifikasi layanannya ke penyediaan fasilitas infrastruktur *Data Center* dan *Managed Services*.
2. **Kebutuhan Sistem ERP MSDC**: Kompleksitas pengelolaan data center skala industri yang membutuhkan sistem informasi terintegrasi (*Enterprise Resource Planning* - ERP) untuk memitigasi risiko *human error*, inefisiensi pencatatan manual, serta fragmentasi operasional.
3. **Urgensi Modul Data Center Operations**: Pentingnya perancangan modul khusus yang menangani siklus hidup fasilitas fisik gedung, alokasi lemari rak server 42U, pemetaan interkoneksi kabel jaringan, pemantauan telemetri lingkungan, serta penegakan protokol keamanan fisik berstandar ISO/IEC 27001 [@iso27001_2022; @wardana2021optimising].
4. **Kaitan dengan Kurikulum Perguruan Tinggi**: Penyelarasan antara kebutuhan industri rekayasa perangkat lunak modern dengan capaian pembelajaran program studi (analisis kebutuhan sistem, rekayasa framework fullstack, dan integrasi API terproteksi).

## Lingkup

*(Panduan Penulisan Sub-Bab I.2)*:
Bagian ini mendefinisikan batasan sistem dan ruang lingkup proyek yang dikembangkan selama kegiatan PLK, meliputi:
1. **Obyek Sistem**: Pengembangan subsistem *Data Center Operations* (DC Ops) pada ekosistem web MSDC ERP.
2. **Batasan Fungsional**:
   - Hirarki fasilitas fisik: pemodelan gedung (*Site*), ruangan/zona utilitas (*Room*), dan lemari rak komersial (*Rack 42U Elevation Grid*).
   - Jaringan dan pengkabelan: inventarisasi perangkat fisik (*Device*), port jaringan (*Network Port*), interkoneksi kabel (*Cross-Connect*), dan manajemen pengalamatan IP (*IPAM*).
   - Telemetri dan lingkungan: pemantauan suhu/kelembaban rak sesuai standar ASHRAE TC 9.9 dan integrasi visual CCTV lorong rak.
   - Operasional harian: manajemen tiket insiden (*Remote Hands*), perintah kerja (*Work Order*), dan surat operasional resmi.
   - Keamanan akses fisik: pendaftaran pengunjung (*Visitor Pass*) dan verifikasi *dynamic QR code* di pos satpam (*Scanner Guard*).
3. **Batasan Pengguna**: Sistem ditujukan bagi staf teknisi data center (*NOC / Facilities Engineer*), operator keamanan pos jaga, manajer operasional, serta staf penjualan (*CRM*).

## Tujuan

*(Panduan Penulisan Sub-Bab I.3)*:
Bagian ini merumuskan target capaian hasil nyata dari pelaksanaan PLK:
1. **Bagi Mitra Industri (PT Jawa Pos Media Televisi)**:
   - Menghasilkan modul operasional data center yang siap pakai, andal, dan terisolasi per tenant (*multi-tenant*).
   - Mencegah insiden *double-booking* slot rak dan tabrakan port jaringan melalui mekanisme *pessimistic locking* dan validasi keunikan bertingkat.
   - Meningkatkan transparansi audit akses fisik dan alokasi daya/ruang secara *real-time*.
2. **Bagi Mahasiswa (Akademik)**:
   - Menguasai implementasi arsitektur perangkat lunak skala enterprise berbasis React TypeScript pada antarmuka pengguna dan Laravel Modular pada lapisan backend.
   - Memenuhi kompetensi rekognisi 4 mata kuliah konversi (Analisis Kebutuhan, Pemrograman Framework, Pemrograman API, dan Praktik Kerja Lapangan) dengan bukti luaran perangkat lunak teruji.
