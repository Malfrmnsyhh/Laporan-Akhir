# ORGANISASI ATAU LINGKUNGAN ORGANISASI MITRA PLK

## Struktur Organisasi

*(Panduan Penulisan Sub-Bab II.1)*:
Bagian ini memaparkan profil dan struktur keorganisasian mitra PT Jawa Pos Media Televisi (JTV):
1. **Gambaran Korporat Mitra**: Profil perusahaan, lini bisnis, visi, misi, dan nilai operasional PT Jawa Pos Media Televisi.
2. **Bagan Struktur Organisasi**: Penyajian bagan hierarki manajemen mitra (Direksi, Departemen Penyiaran, Departemen Keuangan, Departemen Teknologi Informasi & Infrastruktur).
3. **Penandaan Visual Unit Magang (Wajib)**: Berdasarkan pedoman prodi, **unit kerja tempat mahasiswa melaksanakan proyek magang (Divisi TI / Software Engineering Tim MSDC ERP) wajib dibedakan secara visual dari divisi lainnya menggunakan arsiran (*shading*) atau garis putus-putus (*dashed line*)**.
4. **Posisi Mahasiswa dalam Tim**: Menjelaskan posisi mahasiswa sebagai *Fullstack Software Engineering Intern* yang bertugas di bawah bimbingan Mentor Industri (*Lead Software Engineer*).

## Lingkup Pekerjaan

*(Panduan Penulisan Sub-Bab II.2)*:
Bagian ini menjelaskan ruang lingkup kerja unit/divisi tempat magang:
1. **Fungsi Divisi TI Mitra**: Tanggung jawab divisi dalam memelihara stabilitas penyiaran, infrastruktur server, jaringan transmisi, serta pengembangan sistem internal korporat.
2. **Keterkaitan dengan Proyek MSDC**: Alasan divisi mengembangkan sistem ERP mandiri untuk menopang unit bisnis komersial data center, colocation server, dan layanan jaringan terkelola.

## Deskripsi Pekerjaan

*(Panduan Penulisan Sub-Bab II.3)*:
Bagian ini menguraikan tahapan pekerjaan terperinci yang dijalankan mahasiswa:
1. **Tahap Analisis Kebutuhan**: Mengumpulkan kebutuhan operasional teknisi data center, membedah alur alokasi rak fisik, dan merancang spesifikasi kebutuhan fungsional (SRS).
2. **Tahap Perancangan Perangkat Lunak**:
   - Merancang diagram alir data (DFD Level 0, 1, 2) dan diagram alur pengguna (*User Flow*).
   - Merancang skema relasi basis data MySQL (*Physical Data Model*).
   - Menentukan kontrak endpoint RESTful API dan arsitektur modular Laravel.
3. **Tahap Implementasi Kode**:
   - Sisi Backend: Mengembangkan controller, domain service, form request, dan model pada modul `DataCenterOps` serta mengintegrasikan *shared kernel* dari `CorePlatform`.
   - Sisi Frontend: Mengembangkan komponen visualisasi rak 42U (*interactive rack grid*), form modal, data table terpaginasi, dan state management via TanStack Query pada aplikasi React TypeScript.
4. **Tahap Pengujian & Integrasi**: Melakukan pengujian fungsional unit (*unit test*), pengujian integrasi antarmuka, serta penanganan kasus ekstrem (*edge cases* seperti *concurrency lock*).

## Jadwal Kerja

*(Panduan Penulisan Sub-Bab II.4)*:
Bagian ini merangkum linimasa pelaksanaan magang selama satu semester penuh (Agustus – Desember 2026):
1. **Bulan 1 (Agustus 2026)**: Orientasi lingkungan kerja, bedah arsitektur sistem eksisting, analisis kebutuhan bisnis data center, dan setup environment pengembangan.
2. **Bulan 2 (September 2026)**: Perancangan skema database, implementasi hirarki fisik (Klaster 1: Site, Room, Rack), serta perancangan komponen visual elevation 42U.
3. **Bulan 3 (Oktober 2026)**: Pengembangan subsistem konektivitas jaringan (Klaster 2: Device, Network Port, Cross-Connect, IPAM) dan integrasi telemetri pemantauan (Klaster 3).
4. **Bulan 4 (November 2026)**: Implementasi operasional dokumen kerja (Klaster 4) dan modul keamanan akses fisik berbasis QR code (Klaster 5: Visitor Pass & Scanner Pos Satpam).
5. **Bulan 5 (Desember 2026)**: Pengujian UAT bersama teknisi mitra, penyusunan dokumentasi teknis, evaluasi hasil kerja, dan penyusunan laporan akhir. Rincian tanggal dan kegiatan harian mengacu secara lengkap pada Lampiran A (Log Activity).
