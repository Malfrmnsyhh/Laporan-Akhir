# PANDUAN MEMAHAMI INFORMASI ANALITIK UTAMA

Halaman dasbor utama dan dasbor pemantauan telemetri dirancang sebagai pusat informasi cepat (*single pane of glass*) bagi operator *Network Operations Center* (NOC) dan manajer operasional. Seluruh metrik diperbarui secara berkala melalui *TanStack Query* maupun tombol **Refresh Data** agar kondisi fasilitas dapat dibaca tanpa menelusuri tabel satu per satu.

## Membaca Kartu Ringkasan Operasional (Stats Cards)

Pada halaman utama **Data Center Overview** (*DashboardPage* pada rute */dc*), informasi kondisi harian fasilitas disajikan dalam tiga komponen analitik utama sebagaimana tampak pada Gambar 3.1.

![Antarmuka Dasbor Utama (*Data Center Overview*) Menampilkan Spanduk Status, Enam Kartu Ringkasan Operasional, dan Petugas Bertugas Hari Ini](gambar/dashboard/01-dashboard-utama.png){width=92%}

Penjelasan tiap elemen informasi pada halaman dasbor utama diuraikan sebagai berikut:

1. **Spanduk Status Sistem (*SystemStatusBanner*):** Berada di bagian atas tepat di bawah tajuk halaman. Warna hijau bertuliskan *ALL SYSTEMS OPERATIONAL* dilengkapi stempel waktu pembaruan terakhir (*LAST UPDATED*) menandakan seluruh fasilitas berjalan normal. Apabila terjadi anomali kritis pada suhu ruang peladen atau perangkat utama, spanduk berubah warna menjadi kuning atau merah untuk menarik perhatian operator secara instan.
2. **Enam Kartu Ringkasan Operasional (*Stats Cards*):** Menampilkan enam indikator inti secara sejajar:
   - **SITE:** Menampilkan jumlah gedung pusat data terdaftar beserta rincian status aktif dan pemeliharaan (*Maint.*).
   - **RACK:** Menampilkan total lemari rak terpasang beserta rincian kapasitas slot unit U (total slot, jumlah slot terpakai, dan jumlah slot kosong) yang menjadi dasar evaluasi kepadatan ruang.
   - **IP ADDRESS:** Merangkum total alamat IP yang dikelola lintas seluruh blok subnet *CIDR*, jumlah IP berstatus *Allocated*, serta sisa alamat IP *Available*.
   - **DEVICE:** Menampilkan total perangkat keras aktif yang terpasang pada rak beserta jumlah perangkat cadangan (*Spare*).
   - **TICKET:** Menampilkan jumlah tiket bantuan teknis (*Ticket & Remote Hands*) yang masih terbuka (*Open*), melewati tenggat SLA (*Overdue*), terselesaikan (*Resolved*), dan ditutup (*Closed*).
   - **ALARM:** Menampilkan jumlah peringatan aktif terbuka (*Open*) yang dipisahkan menurut tingkat keparahan *Critical* dan *Warning*.

   Untuk mengevaluasi rasio kepadatan ruang rak 42U serta beban daya listrik (Watt) pada rincian tiap rak, operator menggunakan rumus persentase utilisasi berikut:

$$\text{Utilisasi Ruang Rak (\%)} = \frac{\text{Jumlah Slot Terpakai (U)}}{\text{Kapasitas Total Rak (U)}} \times 100\%$$

$$\text{Utilisasi Daya Listrik (\%)} = \frac{\text{Beban Daya Terkini (Watt)}}{\text{Kapasitas Daya Maksimal (Watt)}} \times 100\%$$

   Sebagai acuan keselamatan operasional, beban daya di bawah 70% ditandai hijau (*Normal / Zona Aman*), rentang 70% hingga 85% ditandai jingga (*Peringatan*), dan di atas 85% ditandai merah (*Kritis*) untuk mencegah risiko pemutusan sirkuit listrik (*breaker trip*).
3. **Panel Petugas Bertugas Hari Ini (*StaffOnDuty*):** Menampilkan daftar teknisi NOC yang sedang menjalankan tugas piket pada tanggal berjalan berdasarkan sinkronisasi jadwal *shift* dengan zona waktu operasional *Asia/Jakarta* (WIB). Setiap kartu petugas dikelompokkan per gedung (*Site*) lengkap dengan lencana **BERTUGAS**, kode dan jam *shift* (misalnya *SH2 06:00 - 14:00*), kontak *email*, serta nomor telepon guna mempercepat eskalasi penanganan insiden.

## Membaca Grafik Telemetri ASHRAE TC 9.9 dan Status Kamera CCTV

Untuk pengawasan mikroklimat ruang peladen secara rinci, operator membuka menu **REPORT** lalu memilih **Dashboard Monitoring** (rute */dc/monitoring-racks*). Halaman ini memantau suhu dan kelembaban relatif seluruh rak secara serentak menggunakan evaluasi ambang batas ganda (*dual-bounds*) yang mengacu pada pedoman termal ASHRAE TC 9.9. Tampilan dasbor telemetri seluruh rak ditunjukkan pada Gambar 3.2.

![Dasbor Pemantauan Telemetri Termal Seluruh Rak dengan Evaluasi Ambang Batas Ganda Standar ASHRAE TC 9.9](gambar/workflow/01-dashboard-telemetri.png){width=92%}

Cara membaca indikator pada dasbor pemantauan telemetri dan status kamera CCTV diuraikan sebagai berikut:

1. **Indikator Rata-Rata Lingkungan Makro:** Dua kartu di kanan atas merangkum rata-rata suhu seluruh sensor aktif (target ideal $18^\circ\text{C}\text{--}27^\circ\text{C}$) serta rata-rata kelembaban relatif (target ideal $40\%\text{--}60\%$). Apabila terdapat minimal satu rak yang melewati ambang kritis, spanduk *PERINGATAN TERMAL TERDETEKSI* otomatis muncul di bagian atas beserta stempel waktu pembaruan terakhir (WIB).
2. **Evaluasi Ambang Batas Ganda (*Dual-Bounds*) per Kartu Rak:** Setiap kartu rak menampilkan kode rak, lokasi ruangan, nilai suhu terkini, kelembaban terkini, jumlah alarm aktif, dan lencana status kesehatan:
   - **Normal (Hijau):** Suhu dan kelembaban berada di dalam rentang ideal (misalnya rak *R01* pada suhu $24,0^\circ\text{C}$ dan kelembaban $50,0\%$).
   - **Warning (Jingga):** Nilai sensor mendekati atau melampaui batas peringatan atas maupun bawah (misalnya rak *R03* pada suhu $30,0^\circ\text{C}$ dan kelembaban $70,0\%$) yang menandakan perlunya pemeriksaan aliran udara pendingin (*Precision Air Conditioning*).
   - **Critical (Merah):** Nilai sensor melampaui batas kritis panas berlebih (*overheating*) maupun terlalu dingin (misalnya *RACK-00004* pada suhu $14,0^\circ\text{C}$ dan kelembaban $25,0\%$ yang berisiko memicu kondensasi uap air dan listrik statis *ESD*). Klik tombol **Lihat telemetri** pada kartu rak untuk membuka grafik riwayat tren waktu (*time-series*).
3. **Membaca Status Kamera Pengawas CCTV:** Pada menu **Pemantauan CCTV** (rute */dc/cctv*), sistem menampilkan ringkasan jumlah kamera berstatus *ONLINE* (aliran *HLS* aktif dan dapat diputar di peramban), *OFFLINE* (pemeriksaan berkala mendeteksi kamera gagal dijangkau berturut-turut dan mengirim notifikasi gangguan), serta *MAINTENANCE* (kamera sedang dalam perawatan terjadwal).
