# PANDUAN PENGGUNAAN DAN WORKFLOW TRANSAKSI

Bab ini menyajikan panduan operasional langkah demi langkah bagi operator, teknisi NOC, dan petugas keamanan untuk menjalankan seluruh alur kerja utama pada lima klaster modul *Data Center Operations*.

## Manajemen Hirarki Fasilitas Fisik dan Alokasi Rak 42U

Pengelolaan infrastruktur fisik disusun secara hierarkis mulai dari gedung (*Site*), ruangan (*Room*), hingga lemari rak 42U (*Rack*).

### Mengelola Gedung (*Site*) dan Ruangan (*Room*)

1. Buka menu **MASTER** pada bilah navigasi kiri, lalu pilih **Site Manager** (rute */dc/sites*).
2. Klik tombol **+ Site Baru** untuk mendaftarkan gedung pusat data baru (kode *site*, nama fasilitas, alamat lengkap, koordinat peta *Google Maps*, dan kapasitas daya total dalam satuan kW), atau klik salah satu baris gedung untuk membuka halaman rincian (*SiteDetailPage*) seperti ditunjukkan pada Gambar 4.1.
3. Pada halaman detail gedung, tinjau kartu ringkasan jumlah ruangan, rak, perangkat, serta kontrak aktif, lalu klik tombol **+ Tambah Room** atau buka menu **Room** (rute */dc/rooms*) untuk menambahkan ruangan. Gunakan fitur *Smart Room Code Generator* agar penamaan kode ruangan seragam dan tidak duplikat pada gedung yang sama.

![Antarmuka Detail Fasilitas Gedung (*SiteDetailPage*) dengan Peta Lokasi dan Ringkasan Kapasitas](gambar/workflow/01-k1-site-room-detail.png){width=92%}

### Memantau Kapasitas Rak, *Delete Guard*, dan Alokasi Slot 42U

1. Pilih menu **MASTER** lalu klik **Rack** (rute */dc/racks*) untuk melihat seluruh inventaris lemari rak beserta sisa kapasitas slot U dan daya listrik (Watt).
2. Klik ikon detail pada baris rak untuk membuka *RackDetailPage*, lalu buka tab **DETAIL** sebagaimana tampak pada Gambar 4.2. Operator dapat memeriksa bilah utilisasi *Slot Space (42 U)*, beban *Daya Listrik (5000 W)* beserta zona keamanannya, serta daftar perangkat terpasang. Apabila rak masih memiliki perangkat atau alokasi pelanggan aktif, sistem menampilkan peringatan *Delete Guard* merah yang memblokir penghapusan rak secara otomatis demi menjaga integritas kontrak.

![Antarmuka Detail Kapasitas Rak (*RackDetailPage*) dengan Indikator Daya 5000 W dan Peringatan *Delete Guard*](gambar/workflow/02-k1-rack-detail.png){width=92%}

3. Untuk mengalokasikan rentang unit U secara visual, klik tombol **Lihat Slot** atau ikon kisi pada daftar rak guna membuka modal *RackVisualPicker* (*Visual 42U Elevation Grid*) seperti diperlihatkan pada Gambar 4.3. Slot berwarna hijau menandakan *Kosong*, merah muda menandakan *Terisi* lengkap dengan identitas pelanggan atau nomor *provisioning*, sedangkan biru menandakan rentang yang sedang dipilih.
4. Klik satu slot kosong sebagai titik awal (*start_u*), lalu klik slot kosong kedua sebagai titik akhir (*end_u*). Sistem memastikan seluruh slot di antara kedua titik tersebut berurutan (*kontigu*) dan kosong, kemudian mengunci transaksi di basis data dengan *pessimistic locking* (*lockForUpdate()*) saat tombol simpan ditekan untuk mencegah *double-booking*.
5. Untuk melepas atau memindahkan alokasi aktif pelanggan, ajukan permintaan melalui tombol **Ajukan Pelepasan** (*request-release*) agar diteruskan ke alur persetujuan manajer (*Four-Eyes Principle*) sebelum slot dikembalikan menjadi kosong.

![Implementasi Komponen *Visual 42U Elevation Grid* (*RackVisualPicker*) pada *Rack Manager*](gambar/workflow/03-k1-rack-visual-42u.png){width=92%}

## Manajemen Konektivitas Jaringan dan Pengkabelan

Klaster kedua mengatur pencatatan perangkat keras aktif, port antarmuka jaringan, jalur kabel *Cross-Connect*, panel optik *OTB*, dan alokasi blok alamat IP (*IPAM*).

### Pendaftaran Perangkat dan Master *Network Port*

1. Buka menu **MASTER** lalu pilih **Device Inventory** (rute */dc/devices*) untuk mendaftarkan peladen, *switch*, atau *router* ke dalam posisi unit U pada rak yang sudah dialokasikan. Sistem menolak pendaftaran apabila tinggi perangkat (*u_height*) melampaui rentang slot atau bertabrakan dengan perangkat lain.
2. Pilih menu **Network Port** (rute */dc/network-ports*) untuk mengelola seluruh antarmuka fisik perangkat. Klik tombol **+ Tambah Port** untuk membuka formulir modal *DevicePortFormModal* seperti pada Gambar 4.4.
3. Pilih perangkat tujuan, isi nama port (misalnya *eth0* atau *sfp-sfpplus1*), pilih tipe media fisik (*Ethernet RJ-45 Copper* atau serat optik), tentukan kecepatan tautan (*1 Gbps*, *10 Gbps*, *25 Gbps*, atau *40 Gbps*), serta masukkan *MAC Address* dan *IP Address* bila tersedia. Sistem memvalidasi format *MAC/IP* serta menolak duplikasi nama port pada perangkat yang sama. Apabila port yang terhubung dihapus, sistem otomatis melepas referensi port lawan (*interconnect release*).

![Antarmuka Master Port Jaringan (*NetworkPortListPage*) dan Modal Pendaftaran Port dengan Validasi *MAC/IP Address*](gambar/workflow/04-k2-network-port-modal.png){width=92%}

### Pencatatan *Cross-Connect*, *OTB Inventory*, dan *IPAM*

1. Untuk mencatat kabel penghubung fisik antar-rak maupun menuju *Meet-Me Room*, buka menu **TRANSAKSI** lalu pilih **Cross Connect** (rute */dc/cross-connects*) sebagaimana ditunjukkan pada Gambar 4.5.
2. Klik **+ Kabel Baru**, pilih jenis kabel (*Cat5e*, *Cat6*, *Single-Mode Fiber*, atau *Multi-Mode Fiber*), tentukan titik sumber dan titik tujuan (port rak atau port *OTB*), lalu tautkan ke kontrak pelanggan. Nomor tag kabel dibangkitkan otomatis oleh sistem. Gunakan tombol aksi pada tabel untuk mengunci, melepas, menandai rusak (*mark-damaged*), atau mencatat perbaikan kabel.

![Antarmuka Inventaris Jalur Kabel Interkoneksi (*CrossConnectListPage*) Lintas Rak dan Panel *OTB*](gambar/workflow/05-k2-cross-connect-ipam.png){width=92%}

3. Untuk mengelola panel serat optik, buka menu **OTB Inventory** (rute */dc/otbs*) dan daftarkan kapasitas panel (misalnya 24 atau 48 *core*). Sistem otomatis membentuk seluruh baris port anak berstatus *available* yang tersinkron dengan transaksi *Cross-Connect*.
4. Untuk manajemen alamat IP, buka menu **IPAM** (rute */dc/ipam*), tambahkan blok subnet *CIDR* (contoh *103.10.20.0/29*), lalu klik **Generate Addresses** untuk membangkitkan daftar alamat IP individual. Operator dapat mengalokasikan IP ke perangkat atau pelanggan, serta melepasnya kembali bila kontrak berakhir. Penghapusan subnet yang masih memiliki alamat berstatus *allocated* atau *reserved* akan otomatis ditolak oleh *Allocation Guard* (*HTTP 409 Conflict*).

## Pengawasan Telemetri Lingkungan dan Live Stream CCTV

Pengawasan kondisi ruang server memadukan pembacaan sensor termal (sebagaimana telah dijelaskan pada Gambar 3.2 di Bab III) dengan verifikasi visual kamera CCTV lorong rak.

1. Untuk mengawasi grafik riwayat suhu, kelembaban, serta daya per rak, buka menu **REPORT** lalu pilih **Telemetri Rak** (rute */dc/monitoring*) atau **Dashboard Monitoring** (rute */dc/monitoring-racks*). Atur batas atas dan batas bawah peringatan maupun kritis pada menu pengaturan ambang batas agar alarm otomatis terbentuk tanpa duplikasi (*alarm deduplication*).
2. Untuk mengawasi kamera lorong rak secara visual, buka menu **REPORT** lalu pilih **Pemantauan CCTV** (rute */dc/cctv*). Halaman *CctvListPage* menampilkan seluruh kamera terdaftar lengkap dengan status *ONLINE*, protokol *HLS*, resolusi video, dan codec *H.264 (AVC)* sebagaimana terlihat pada Gambar 4.6.
3. Guna mendaftarkan kamera baru, klik **Tambah Kamera**, pilih lokasi gedung, ruangan, dan rak target, lalu masukkan tautan aliran *RTMP/HLS* dari peladen media *MediaMTX*. Klik tombol uji konektivitas agar layanan *CctvStreamProbeService* memverifikasi keabsahan host (*Anti-SSRF*) dan parameter aliran via *ffprobe* sebelum disimpan dalam bentuk terenkripsi AES-256.

![Antarmuka Kisi Pengawasan Kamera CCTV (*CctvListPage*) dengan Pemutaran Siaran Langsung *HLS* Simultan](gambar/workflow/07-k3-cctv-monitoring-list.png){width=92%}

4. Klik tombol **Buka** atau tombol putar pada kartu kamera untuk membuka jendela modal *HlsPlayer* layar penuh seperti diperlihatkan pada Gambar 4.7. Operator dapat memantau siaran langsung berlatensi rendah menggunakan pustaka *hls.js*, memakai kontrol jeda, bisu, serta layar penuh, dan memastikan alamat sumber di bilah bawah tampil dalam format tersamar (*Masked Stream URL*) sehingga kredensial mentah tidak pernah terekspos ke peramban.

![Modal Pemutar Siaran Langsung *HLS* (*HlsPlayer*) dengan Verifikasi *Masked Stream URL* dan Metadata Video](gambar/workflow/08-k3-cctv-hls-modal-simulation.png){width=92%}

## Operasional Harian, Work Order, Usage Billing, dan Surat DC

Klaster keempat menyatukan koordinasi teknisi lapangan, pemenuhan pesanan kontrak, penagihan jasa teknis, dan tata naskah berita acara operasional.

### Penanganan *Ticket & Remote Hands* serta *Perintah Kerja (Work Order)*

1. Buka menu **TRANSAKSI** lalu pilih **Ticket & Remote Hands** (rute */dc/tickets*) untuk mencatat laporan gangguan atau permintaan bantuan teknis pelanggan. Sistem otomatis menghitung batas waktu respon dan penyelesaian berdasarkan kontrak SLA pelanggan.
2. Catat setiap tindakan teknisi lengkap dengan durasi pengerjaan (menit) melalui tombol **Catat Aktivitas**. Saat pekerjaan tuntas, isi catatan penyelesaian (*resolution_action*) lalu ubah status menjadi *closed*; tiket tertutup terkunci permanen untuk menjaga keutuhan riwayat audit.
3. Untuk menindaklanjuti pesanan instalasi baru dari divisi komersial, buka menu **Perintah Kerja** (rute */dc/work-orders*) seperti tampak pada Gambar 4.8.
4. Klik tombol **Proses** atau **Lanjutkan** pada baris *Sales Order* pelanggan untuk membuka halaman daftar periksa instalasi. Lakukan alokasi perangkat, alamat IP, maupun kabel *Cross-Connect* langsung dari modal bantu yang tersedia, lalu centang setiap item pekerjaan yang telah selesai. Sistem secara otomatis menghitung ulang persentase progres dan menyinkronkan tanggal pencapaian (*milestone*) ke modul kontrak CRM.

![Antarmuka Manajemen Perintah Kerja (*Work Orders*) dan Pelacakan Progres Daftar Periksa Instalasi](gambar/workflow/09-k4-work-order-ticket.png){width=92%}

### Penagihan *Usage Records* dan Tata Naskah *Surat DC*

1. Pada akhir periode bulanan, buka menu **REPORT** lalu pilih **Usage Record** (rute */dc/usage*) seperti disajikan pada Gambar 4.9.
2. Pilih bulan dan tahun periode tagihan, lalu klik tombol **Generate Usage Record** agar sistem mengagregasi penggunaan kapasitas rak, konsumsi daya, *bandwidth*, serta total jam kerja *Remote Hands* secara otomatis.
3. Pada baris pencatatan *Remote Hands* berstatus *Draft*, klik tombol **Tagih** untuk membuka modal tarif per jam (*BillRemoteHandsModal*) dan meneruskan draf faktur piutang (*Accounts Receivable Invoice*) ke modul *Finance & Accounting*. Baris yang telah berstatus *Sent to Finance* otomatis terkunci dari penagihan ulang.

![Antarmuka Pencatatan Pemakaian dan Penagihan Operasional (*Usage Records & Billing*) menuju Modul *Finance*](gambar/workflow/10-k4-usage-surat-dc.png){width=92%}

4. Untuk menerbitkan berita acara serah terima fasilitas maupun surat izin kerja operasional, buka menu **TRANSAKSI** lalu pilih **Surat DC** (rute */dc/surat*). Klik **Buat Surat Baru**, susun isi dokumen, ajukan persetujuan berjenjang (*WorkflowEngineService*), bubuhkan tanda tangan digital, lalu unduh atau pratinjau dokumen PDF yang telah dilengkapi kode QR verifikasi keaslian publik.

## Keamanan Akses Fisik Visitor Pass dan Scanner Pos Satpam

Klaster kelima menerapkan pengendalian masuk fisik ruang peladen berstandar ISO/IEC 27001 dari tahap pendaftaran hingga kepulangan pengunjung.

### Penerbitan Izin Kunjungan (*Visitor Pass*) dan Kartu *E-Badge* Digital

1. Buka menu **REPORT** lalu pilih **Visitor Pass Log** (rute */dc/visitor-passes*). Operator dapat memilih dua mode penerbitan:
   - **Kirim Undangan Mandiri (*Self-Registration*):** Klik **Undang Tamu**, pilih pelanggan penjamin berkontrak aktif, gedung tujuan, serta rentang tanggal izin, lalu kirim tautan publik bertoken *VPINV* kepada calon pengunjung. Pengunjung mengisi biodata, daftar barang bawaan, jadwal kedatangan, dan menyetujui deklarasi K3 serta NDA tanpa perlu akun masuk ERP.
   - **Penerbitan Langsung (*Walk-in*):** Klik **Buat Izin Langsung** apabila teknisi darurat hadir langsung di lokasi atas persetujuan penjamin.
2. Untuk pendaftaran mandiri yang masuk berstatus *registered*, operator membuka halaman rincian tiket, memeriksa daftar periksa kepatuhan (*Compliance Vetting Checklist*), lalu menekan tombol **Setujui**. Sistem otomatis membangkitkan token kriptografi *VPQR* ter-hash *SHA-256* dan mengirimkan tautan kartu *e-badge* digital kepada pengunjung.
3. Kartu *e-badge* digital *Visitor Pass* ditunjukkan pada Gambar 4.10. Kartu menampilkan nomor izin, status tiket, identitas pengunjung, pelanggan penjamin, ruang rak tujuan, tautan publik, serta tiga butir *SOP Keselamatan Fasilitas Data Center*. Setelah pengunjung menyelesaikan kunjungan dan *check-out*, tiket berubah status menjadi *Tiket Kedaluwarsa* (*Kunjungan Selesai*) sehingga kode QR tidak dapat digunakan ulang.

![Antarmuka Kartu *E-Badge* Digital Izin Kunjungan (*Visitor Pass*) dan Daftar SOP Keselamatan Fasilitas](gambar/workflow/11-k5-visitor-pass-ticket.png){width=92%}

### Verifikasi Akses di Stasiun *Scanner Pos Jaga* (*Scanner Guard*)

1. Petugas keamanan di pos resepsionis membuka menu **TRANSAKSI** lalu memilih **Scanner Pos Jaga** (rute */dc/visitor-scanner*) seperti terlihat pada Gambar 4.11.
2. Pilih gedung dan titik pos jaga aktif pada bilah dropdown di bagian atas stasiun pemindaian.
3. Lakukan verifikasi tiket pengunjung melalui salah satu dari tiga metode yang didukung:
   - Klik **Nyalakan kamera** untuk memindai kode QR pada layar ponsel pengunjung secara langsung menggunakan *HTML5 BarcodeDetector* atau *jsQR*.
   - Klik **Unggah foto QR** apabila gambar tiket dikirimkan secara digital.
   - Arahkan kursor ke kolom **Token QR atau scanner USB** lalu tembak kode QR memakai perangkat pemindai tembak fisik (*USB barcode scanner*).
4. Ikuti empat langkah *SOP Verifikasi Pos Jaga* di panel kanan: cocokkan nama pada layar dengan KTP fisik pengunjung, serahkan kalung kartu visitor fisik setelah verifikasi berhasil (*Access Granted*), pastikan tamu hanya mengakses rak yang tercantum pada izin, dan lakukan *check-out* pada panel **Sedang di fasilitas** (*live headcount*) ketika pengunjung meninggalkan gedung. Apabila kode QR yang sudah terpakai dipindai ulang (*replay attack*), sistem menolak akses dengan nada peringatan dan mencatat insiden secara permanen pada *dc_visitor_access_log*.

![Antarmuka Stasiun Pemindai Pos Jaga (*Scanner Guard*) Berbasis Kamera Peramban, Masukan *Scanner* USB, dan SOP Verifikasi](gambar/workflow/12-k5-scanner-guard-pos.png){width=92%}
