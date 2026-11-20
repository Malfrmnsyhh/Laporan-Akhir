# PENUTUP

## Kesimpulan

*(Panduan Penulisan Sub-Bab V.1)*:
Bagian ini menyimpulkan seluruh proses dan hasil yang diperoleh selama pelaksanaan program PLK di PT Jawa Pos Media Televisi (JTV):
1. **Kesimpulan Proses Pelaksanaan PLK**:
   - Program magang mandiri di PT Jawa Pos Media Televisi telah terlaksana dengan baik sesuai linimasa dan metodologi pengembangan perangkat lunak yang disepakati.
   - Kolaborasi tim pengembang dan bimbingan mentor industri memberikan pemahaman mendalam mengenai standar rekayasa perangkat lunak enterprise dan dinamika kerja di industri media dan data center.
2. **Kesimpulan Substansi Teknis**:
   - Modul *Data Center Operations* berhasil dirancang dan diimplementasikan secara terintegrasi mencakup 5 klaster fungsional (Fasilitas Fisik, Jaringan & Pengkabelan, Telemetri Lingkungan, Operasional Dokumen, dan Keamanan Akses Fisik).
   - Penggunaan arsitektur React 18 SPA dan Laravel 11 Modular terbukti mampu memberikan performa tinggi, modularitas kode yang rapi, serta kemudahan pemeliharaan sistem jangka panjang.
   - Penerapan mekanisme *pessimistic locking* (*lockForUpdate*) dan transaksi atomik berhasil memecahkan persoalan *race condition* pada alokasi lemari rak dan penomoran dokumen otomatis.
   - Isolasi data *multi-tenancy* terbukti kokoh melalui penegakan *global scope* *ScopesOrganization* dan validasi *header* *X-Organization-Id*.

## Saran

*(Panduan Penulisan Sub-Bab V.2)*:
Bagian ini merumuskan rekomendasi perbaikan dan pengembangan sistem untuk masa mendatang:
1. **Saran bagi Proses Pelaksanaan PLK & Institusi Mitra**:
   - Mempertahankan dan memperluas program kemitraan magang industri berbasis proyek nyata antara Program Studi Informatika UPN "Veteran" Jawa Timur dan PT Jawa Pos Media Televisi.
   - Memberikan alokasi waktu tambahan pada tahap pengujian beban sistem (*load testing*) di lingkungan staging sebelum rilis produksi.
2. **Saran bagi Pengembangan Teknis Sistem ke Depan**:
   - Mengembangkan integrasi telemetri otomatis menggunakan protokol industri IoT seperti SNMP (*Simple Network Management Protocol*) atau Modbus TCP untuk membaca sensor daya PDU (*Power Distribution Unit*) dan sensor suhu rak secara langsung tanpa input gateway manual.
   - Mengintegrasikan pemindai kode QR pada modul *Visitor Pass* dengan gerbang fisik (*turnstile barrier gate*) dan kartu akses RFID agar proses verifikasi di pos satpam berjalan sepenuhnya otomatis.
   - Menambahkan fitur pelacakan rute pengkabelan serat optik interaktif berbasis visualisasi diagram topologi canvas (*interactive network topology graph*).
