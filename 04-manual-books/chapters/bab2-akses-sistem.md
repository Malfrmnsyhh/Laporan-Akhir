# AKSES SISTEM (AUTENTIKASI DAN KEAMANAN)

Setiap permintaan data dari antarmuka pengguna menuju layanan *RESTful API* pada modul *Data Center Operations* diamankan melalui mekanisme autentikasi *OAuth2 Bearer Token* yang dikelola oleh *Laravel Passport* (*guard api*). Ketika pengguna berhasil masuk ke sistem, peladen menerbitkan token akses terenkripsi yang disertakan secara otomatis pada *header* *Authorization* di setiap panggilan *Axios*.

Selain verifikasi identitas pengguna, sistem menerapkan isolasi data lintas entitas usaha (*multi-tenancy*) melalui pengiriman *header* *X-Organization-Id*. Dengan adanya *trait* *HasOrganizationScope* pada seluruh model basis data pusat data, setiap kueri pembacaan maupun mutasi data secara otomatis tersaring hanya untuk organisasi yang sedang aktif, sehingga data fasilitas, pelanggan, maupun kamera CCTV antar-organisasi tidak dapat saling mengakses. Khusus untuk jalur pengiriman data sensor suhu dan daya perangkat keras (*IoT ingest*), autentikasi menggunakan *header* *X-API-Key* dengan pemeriksaan daftar putih alamat IP (*CIDR whitelist*) di luar sesi masuk pengguna.

## Antarmuka dan Prosedur Masuk ke Sistem (Login)

Pengguna internal perusahaan (Manajer Operasional, Teknisi NOC, maupun Petugas Pos Jaga) wajib melalui prosedur autentikasi terlebih dahulu sebelum membuka dasbor operasional. Tampilan halaman masuk ERP MSDC ditunjukkan pada Gambar 2.1.

1. Buka peramban web modern (Google Chrome, Microsoft Edge, Mozilla Firefox, atau Brave) pada komputer kerja, lalu masukkan alamat URL aplikasi ERP MSDC pada bilah alamat.
2. Pada panel **Selamat Datang** di sisi kanan halaman masuk (*Login Page*), masukkan alamat surat elektronik (*email*) korporat yang telah terdaftar pada kolom **Email**.
3. Ketik kata sandi akun Anda pada kolom **Password** dengan memperhatikan huruf kapital dan simbol, lalu klik tombol **Masuk ke Portal**.
4. Apabila kredensial valid dan status akun aktif, sistem menyimpan *Bearer Token* secara aman pada penyimpanan sesi peramban, menetapkan konteks organisasi aktif, dan mengarahkan pengguna langsung menuju halaman utama *Data Center Overview* (rute */dc*) sebagaimana diperlihatkan pada Gambar 3.1 di Bab III. Jika kombinasi *email* dan kata sandi keliru, sistem menampilkan pesan penolakan tanpa membeberkan informasi detail akun.

![Antarmuka Halaman Masuk (*Login Page*) Portal Internal ERP MSDC](gambar/akses-sistem/01-login-page.png){width=92%}

## Prosedur Keluar dari Sistem (Logout)

Untuk mencegah penyalahgunaan sesi pada komputer bersama di ruang kendali NOC maupun pos jaga satpam, pengguna wajib keluar dari sistem secara resmi setiap kali selesai bertugas atau meninggalkan stasiun kerja. Letak menu keluar sistem ditunjukkan pada Gambar 2.2.

1. Klik panel profil pengguna di sudut kanan atas layar (menampilkan nama akun, peran pengguna, serta organisasi aktif *MSDC Surabaya*) hingga menu *dropdown* terbuka, atau gulir ke bagian bawah bilah navigasi kiri (*2-Tier Sidebar*).
2. Klik tombol **Keluar (Logout)** berwarna merah pada menu *dropdown* profil, atau klik pintasan **Keluar** pada bilah navigasi kiri.
3. Sistem secara otomatis memicu pencabutan token akses di peladen, membersihkan *cache* kueri lokal *TanStack Query* beserta data sesi di peramban (*session purge*), lalu mengembalikan tampilan ke halaman masuk (*Login Page*).

![Menu Profil Pengguna dan Prosedur Keluar Sistem (*Logout*) pada ERP MSDC](gambar/akses-sistem/02-logout-menu.png){width=92%}
