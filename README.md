# Warungku POS 🛒📱

Aplikasi Point of Sale (POS) berbasis mobile menggunakan Flutter untuk membantu pencatatan transaksi kasir, manajemen produk toko, laporan penjualan, hingga integrasi cetak struk Bluetooth dan pengaturan QRIS.

---

## 🔄 Alur Kerja & Arsitektur Aplikasi (App Flow)

Project ini menggunakan arsitektur modular berdasarkan *features* dengan manajemen state **Flutter Bloc/Cubit** dan penyimpanan lokal **Hive**.

### 1. Inisialisasi Aplikasi (`main.dart`)
* Memuat binding Flutter dan menginisialisasi **Hive** sebagai database lokal untuk menyimpan data produk, transaksi, dan pengaturan.
* Membuka *box* Hive yang dibutuhkan agar data bersifat persisten (bisa diakses secara offline).

### 2. Modul Utama & State Management (`features/`)
Aplikasi dibagi menjadi beberapa modul fitur utama yang dikelola menggunakan **Cubit**:

* **Home POS (`home_pos/`)**
  * **Alur Transaksi Kasir:** Pengguna memilih produk dari katalog, memasukkannya ke keranjang belanja, menghitung total harga, dan memproses pembayaran.
  * **State (`pos_cubit.dart` & `pos_state.dart`):** Mengatur logika keranjang, perhitungan diskon/subtotal, dan penyimpanan data transaksi ke Hive setelah pembayaran selesai.

* **Manajemen Produk (`manage_product/`)**
  * Berisi halaman daftar produk (`product_list_page.dart`) untuk menambah, mengubah, atau menghapus stok barang dagangan yang tersimpan di database lokal.

* **Laporan Penjualan (`reports/`)**
  * **Alur Rekap:** Mengambil data riwayat transaksi dari Hive untuk menampilkan rekapitulasi laporan penjualan (`sales_report_page.dart`) secara berkala kepada pemilik warung.

* **Pengaturan & Periferal (`settings/`)**
  * **Printer Bluetooth:** Mengatur koneksi perangkat printer thermal (`printer_service.dart`) untuk mencetak struk transaksi.
  * **Pengaturan Toko & QRIS:** Mengatur informasi struk, QRIS pembayaran digital, dan preferensi aplikasi lainnya.

---

## 🛠️ Tech Stack
* **Framework:** Flutter (Dart)
* **State Management:** Flutter Bloc / Cubit (`flutter_bloc`, `equatable`)
* **Local Database:** Hive (`hive`, `hive_flutter`, `hive_generator`)
* **Hardware & Integrasi:** Print Bluetooth Thermal (`print_bluetooth_thermal`), Image Picker, Shared Preferences
* **Format & Utilities:** Intl (untuk format mata uang/tanggal)