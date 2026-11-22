# PENUTUP

## Kesimpulan

Pelaksanaan Praktik Lapangan Kerja (PLK) selama 20 minggu di Unit IT PT Jawa Pos Media Televisi (JTV) Surabaya memberikan bukti nyata penerapan disiplin rekayasa perangkat lunak pada ekosistem *enterprise*. Berangkat dari kebutuhan operasional pengelolaan pusat data komersial di bawah naungan MSDC ERP, keseluruhan proses pengembangan dan hasil capaian dirangkum ke dalam tiga kelompok kesimpulan berikut.

### Kesimpulan Umum

1. **Pelaksanaan PLK yang Sistematis dan Memenuhi Standar MBKM**

   Rangkaian kegiatan magang dari 10 Agustus hingga 23 Desember 2026 berjalan runtut melalui lima fase kerja. Pekerjaan dimulai dari orientasi organisasi dan elisitasi kebutuhan ruang peladen, dilanjutkan penyusunan desain antarmuka di Figma, rekayasa kode *fullstack*, pengujian otomatis serta UAT, hingga penuntasan dokumentasi teknis. Dengan skema hibrida (WFH empat hari dan WFO setiap hari Kamis di kantor JTV Surabaya), penulis menjaga intensitas kerja 50 hingga 60 jam per pekan. Akumulasi lebih dari 1.000 jam kerja efektif tersebut melampaui batas minimal 900 jam untuk penyetaraan 20 SKS pada paket konversi kurikulum *MG220*.

2. **Kontribusi Nyata terhadap Digitalisasi Pusat Data JTV**

   Kehadiran modul *Data Center Operations* (*DataCenterOps*) pada sistem MSDC ERP menggantikan pencatatan fasilitas yang sebelumnya tersebar pada lembar kerja terpisah dan buku tamu kertas. Seluruh proses inti pusat data kini tersimpan di dalam satu basis data relasional yang terhubung langsung dengan layanan *CorePlatform*, *CRM & Sales*, *Finance*, serta *HR*. Untuk menjamin kesinambungan operasional setelah masa magang berakhir, hasil rekayasa dilengkapi dengan publikasi repositori kode terkurasi (*MSDCBackend-module-dc-ops* dan *MSDCFrontend-module-dc-ops*), catatan *logbook* harian, serta Buku Panduan (*Manual Book*) sebagai kelengkapan pendaftaran Hak Kekayaan Intelektual (HKI) Program Komputer.

3. **Pengembangan Kompetensi Teknis dan Nonteknis (*Soft Skills*)**

   Keterlibatan penuh sebagai *Fullstack Developer* mempertajam penguasaan penulis terhadap arsitektur *Laravel 11 Modular*, *React 18 TypeScript*, perancangan *RESTful API*, dan pengelolaan basis data *MySQL 8*. Bersamaan dengan peningkatan keterampilan teknis tersebut, dinamika kerja di Divisi Teknologi Informasi membentuk kematangan nonteknis yang konkret. Penulis terlatih mengoordinasikan integrasi antartim, menyampaikan paparan kemajuan teknis secara lugas di hadapan mentor industri, serta mengelola prioritas tenggat waktu secara mandiri.

### Kesimpulan Spesifik Proyek

1. **Peningkatan Arsitektur Antarmuka dan Navigasi Global ERP**

   Kerangka antarmuka awal pada *base project* MSDC ERP sebelumnya belum memiliki pedoman gaya visual dan struktur menu yang seragam antarmodul. Melalui perumusan *Design System* beridentitas warna korporat JTV di Figma serta perombakan kerangka navigasi *2-Tier Sidebar*, seluruh enam modul ERP kini berbagi pola navigasi dan komponen UI yang konsisten. Pada ranah operasional fisik, penulis membangun komponen interaktif *RackVisualPicker* 42U yang memetakan kondisi slot kosong, terpakai, dan terpesan secara visual sehingga operator tidak lagi menebak sisa ruang rak dari tabel angka mentah.

2. **Pembangunan Utuh Lima Klaster Operasional Pusat Data**

   Seluruh lima klaster fungsional yang dirancang dalam spesifikasi kebutuhan telah direalisasikan secara penuh. Klaster 1 menata hierarki *Site*, *Room*, dan *Rack* 42U bersama persetujuan pelepasan kapasitas bertingkat lewat *WorkflowEngineService*. Klaster 2 mengintegrasikan inventaris *Device*, master *Network Port* bervalidasi *MAC/IP*, jalur kabel *Cross-Connect*, panel serat optik *OTB* berkapasitas 48 *core*, serta manajemen blok alamat *IPAM*. Klaster 3 menghadirkan dasbor kendali NOC dengan jadwal piket *StaffOnDuty* zona WIB, pemantauan telemetri termal batas ganda (*dual-bounds*) sesuai standar *ASHRAE TC 9.9*, dan pemutaran aliran CCTV berformat *HLS* via *hls.js*. Klaster 4 merangkai penanganan *Ticket* SLA, *Work Order* berpola *lazy initialization*, agregasi penagihan *Usage Billing* ke divisi *Finance*, serta tata naskah *Surat DC* berkode QR publik. Klaster 5 menuntaskan sistem izin masuk tamu *Visitor Pass* dan stasiun *Scanner Guard* yang memenuhi kontrol masuk fisik standar *ISO/IEC 27001:2022*.

3. **Penguatan Keandalan Konkurensi, Isolasi Data, dan Keamanan API**

   Berbagai celah risiko pada rancangan awal berhasil ditutup melalui rekayasa pengamanan berlapis. Potensi *race condition* pada alokasi slot rak 42U maupun pembangkitan nomor tiket dicegah dengan membungkus transaksi memakai *DB::transaction* dan *lockForUpdate()*. Risiko putusnya relasi kontrak pelanggan dihindari lewat *delete guards* (*HTTP 409 Conflict*) pada entitas fasilitas dan blok subnet *IPAM* aktif. Di sisi keamanan akses, sistem menegakkan isolasi *multi-tenancy* via *trait* *HasOrganizationScope* (pola *ScopesOrganization* berbasis *header* *X-Organization-Id*), autentikasi *OAuth2* *Laravel Passport* dengan hak akses granuler *Spatie Permission*, proteksi *Anti-SSRF* serta enkripsi AES-256 pada *CctvStreamProbeService*, dan kebijakan token *SHA-256* sekali pakai (*ReplayAttemptException*) untuk menangkal pemindaian ulang kode QR tamu.

4. **Peningkatan Performa Kueri dan Tervalidasinya Kualitas Sistem**

   Hambatan latensi akibat pemanggilan kueri berulang (*N+1 query*) pada halaman katalog perangkat, port jaringan, dan pemetaan *IPAM* telah diatasi dengan kombinasi *eager loading* Eloquent, *caching* *TanStack Query v5*, serta paginasi hibrida sisi peladen. Stabilitas seluruh fitur tersebut dibuktikan lewat kelulusan 9 *suite* pengujian otomatis Laravel (*automated feature tests*) yang mencakup 123 skenario uji tanpa galat. Hasil akhir modul juga telah lulus evaluasi *User Acceptance Testing* (UAT) pada *staging server* JTV tanggal 19 November 2026 di hadapan Pembimbing Lapangan, Bapak M. Triman Prasodjo, S.T.

### Kesimpulan Capaian Pembelajaran (*Learning Outcomes*)

1. **Kolaborasi Efektif dalam Ekosistem Multi-Tim**

   Bekerja pada satu repositori besar bersama beberapa tim pengembang modul mengajarkan disiplin batas ruang kerja yang sangat ketat. Penulis belajar memecah pekerjaan ke dalam cabang fitur (*feature branches*) dan *Pull Request* granular agar perubahan pada *DataCenterOps* tidak merusak layanan tim lain. Koordinasi lintas tim ini juga melatih kecermatan membaca kontrak data milik modul *CorePlatform*, *CRM & Sales*, *Finance*, maupun *HR* sebelum menulis baris kode integrasi.

2. **Kemampuan Beradaptasi dengan Standar Rekayasa Industri**

   Lingkungan proyek nyata menuntut perangkat lunak mematuhi aturan bisnis dan standar baku yang diakui secara internasional. Penulis memperoleh pengalaman langsung menerjemahkan kaidah infrastruktur *ANSI/TIA-942-C*, batas keselamatan suhu serta kelembaban *ASHRAE TC 9.9*, dan prinsip jejak audit *ISO/IEC 27001:2022* menjadi aturan validasi kode, struktur tabel relasional, serta tampilan antarmuka operasional yang mudah dipahami teknisi.

3. **Pemecahan Masalah Teknis pada Skenario Nyata (*Real-World Problem Solving*)**

   Tantangan lapangan kerap memunculkan kasus tepi (*edge cases*) yang jarang ditemui pada latihan praktikum kampus. Penulis melatih ketajaman analisis saat menyelesaikan konflik transaksi paralel (*race condition*), menutup potensi celah *SSRF* pada pengujian tautan media, menyaring muatan respons rute publik (*response whitelisting*), hingga merancang simulasi pemutaran siaran langsung *RTMP/HLS* lokal dengan *OBS Studio*, *Larix Broadcaster*, dan peladen media *MediaMTX*.

4. **Pembentukan Etos Kerja dan Komunikasi Profesional**

   Ritme kerja hibrida menguji konsistensi kemandirian sekaligus akuntabilitas terhadap target mingguan. Sesi presentasi rutin setiap hari Kamis bersama Direktur Teknik dan staf Unit IT membiasakan penulis menerima kritik desain secara terbuka, menindaklanjuti masukan revisi secara cepat, dan mempertanggungjawabkan hasil kerja melalui dokumentasi laporan serta Buku Panduan HKI yang rapi.

## Saran

Berdasarkan evaluasi selama pelaksanaan praktik kerja dan catatan tindak lanjut menuju tahap penerapan penuh di lingkungan produksi, penulis merumuskan sejumlah saran konstruktif bagi mitra industri, peserta magang mendatang, serta pihak universitas.

### Saran untuk PT Jawa Pos Media Televisi (JTV)

1. **Integrasi Otomatis Perangkat Sensor Fisik (*SNMP/Modbus/IoT*)**

   Pada tahap penerapan produksi (*production rollout*), tim internal Unit IT disarankan segera menghubungkan sensor suhu, kelembaban, serta *Power Distribution Unit* (PDU) ruang peladen secara langsung menuju *endpoint* *iot/metric-readings* yang telah disediakan. Otomatisasi pengiriman pembacaan melalui protokol *SNMP*, *Modbus*, atau *gateway* IoT akan memaksimalkan deteksi dini batas ganda *ASHRAE TC 9.9* tanpa ketergantungan pada pencatatan perantara.

2. **Otomasi Perangkat Keras Keamanan Fisik dan Audit Peran Produksi**

   Stasiun pemindai *Scanner Guard* pada modul *Visitor Pass* berpotensi ditingkatkan dengan menghubungkan keluaran status verifikasi ke gerbang fisik (*turnstile barrier gate*) atau pembaca kartu akses RFID di pintu masuk ruang server. Sebelum sistem dibuka penuh untuk operasional harian, disarankan pula melakukan tinjauan ulang terhadap pemetaan izin *Spatie Permission* sesuai struktur jabatan aktual agar pemisahan wewenang antara manajer, teknisi NOC, dan petugas satpam tetap terjaga ketat.

3. **Pengembangan Visualisasi Topologi Jaringan dan Uji Beban (*Load Testing*)**

   Untuk mempercepat pelacakan gangguan kabel skala besar, modul konektivitas dapat diperluas dengan fitur visualisasi graf topologi interaktif yang menggambarkan hubungan port perangkat, kabel *Cross-Connect*, dan tray *OTB* dalam satu kanvas. Selain itu, tim teknis perlu menjadwalkan pengujian beban (*load testing*) pada peladen API serta mengevaluasi kapasitas jaringan dan penyimpanan peladen media *SRS/MediaMTX* saat menampung aliran kamera penuh di seluruh lorong gedung.

4. **Keberlanjutan Program Magang Berbasis Proyek Nyata**

   Skema pembimbingan berbasis proyek nyata dengan sesi evaluasi mingguan bersama jajaran teknik terbukti efektif mempertemukan kebutuhan transformasi sistem internal perusahaan dengan energi kreatif mahasiswa. Pola kolaborasi ini layak terus dipertahankan untuk mendukung pengembangan modul lanjutan pada ekosistem MSDC ERP.

### Saran untuk Mahasiswa atau Peserta PLK Selanjutnya

1. **Persiapan Teknis dan Pemahaman Arsitektur Sebelum PLK**

   Mahasiswa yang akan menempuh program magang di bidang rekayasa perangkat lunak sebaiknya membekali diri sejak awal dengan alur kerja *version control* Git (*branching*, *Pull Request*, dan penyelesaian *merge conflict*), prinsip dasar *RESTful API*, serta kerangka kerja modern. Saat pertama kali bergabung dalam proyek eksisting, luangkan waktu memadai untuk membedah struktur *base project* dan konvensi kode tim sebelum mulai menulis fitur baru.

2. **Menjaga Budaya Kerja, Komunikasi Proaktif, dan Isolasi Kode**

   Hambatan teknis yang dibiarkan terlalu lama dapat menghambat jadwal *sprint* tim lain. Peserta magang perlu membangun komunikasi proaktif bersama mentor maupun rekan lintas modul setiap kali menemui *blocker* integrasi. Pada repositori kolaboratif, jaga kedisiplinan ruang kerja agar perubahan kode tetap terisolasi di dalam direktori modul yang menjadi tanggung jawab sendiri tanpa mengubah konfigurasi global secara sepihak, serta pertahankan manajemen waktu yang tertib selama menjalani skema hibrida.

3. **Disiplin Dokumentasi dan Pengelolaan Portofolio Pasca-PLK**

   Catat progres *logbook* harian, simpan tangkapan layar antarmuka, dan arsipkan bukti pengujian secara rutin sejak pekan pertama agar penyusunan laporan akhir berjalan ringan tanpa tumpukan pekerjaan di akhir semester. Apabila hasil karya akan dipublikasikan sebagai portofolio terbuka atau bahan pendaftaran HKI, pastikan seluruh berkas telah melewati pemeriksaan kebersihan keamanan (*zero leaked credentials*) terlebih dahulu.

### Saran untuk Universitas Pembangunan Nasional "Veteran" Jawa Timur

1. **Penguatan Kemitraan Industri dan Sinkronisasi Kurikulum**

   Program Studi Informatika diharapkan terus memperluas jejaring kemitraan magang berbasis proyek rekayasa nyata dengan perusahaan teknologi maupun industri penyiaran. Materi praktikum pada mata kuliah pemrograman dan rekayasa perangkat lunak juga dapat terus diperbarui agar sesuai dengan praktik industri modern, khususnya terkait arsitektur modular, pengujian fitur otomatis (*automated testing*), dan praktik keamanan API terkini.

2. **Pembekalan Pra-PLK dan Kelancaran Administrasi Konversi MBKM**

   Penyelenggaraan lokakarya singkat sebelum keberangkatan magang mengenai kolaborasi Git tim, etika *code review*, dan standar penyusunan dokumentasi teknis akan mempercepat adaptasi mahasiswa di pekan-pekan awal industri. Di sisi layanan akademik, penyederhanaan serta percepatan penerbitan dokumen legalitas kerja sama seperti *LoA* dan *MoA* sangat membantu mahasiswa memusatkan perhatian secara penuh pada penyelesaian target teknis di perusahaan mitra.

3. **Pendampingan Luaran Akademik dan Pendaftaran HKI**

   Pihak fakultas dan program studi disarankan terus mendorong serta memfasilitasi pendampingan lanjutan bagi mahasiswa peserta PLK dalam mengonversi produk rekayasa industri menjadi luaran akademik bernilai tambah, baik berupa publikasi artikel ilmiah terakreditasi maupun pendaftaran Hak Kekayaan Intelektual (HKI) Program Komputer bersama mitra industri.
