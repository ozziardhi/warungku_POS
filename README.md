# Warungku POS 🛒📱

Aplikasi Point of Sale (POS) berbasis mobile menggunakan Flutter untuk membantu pencatatan transaksi kasir, manajemen produk toko, laporan penjualan, hingga integrasi cetak struk Bluetooth dan pengaturan QRIS.

---

## 🔄 Alur Kerja Aplikasi (App Flow)

1. **Inisialisasi & Penyimpanan (`main.dart`)**
   * Saat aplikasi pertama kali dibuka, sistem menginisialisasi Flutter bindings dan membuka database lokal **Hive** agar data produk dan transaksi siap diakses secara *offline*.
   * Mengatur halaman awal aplikasi.

2. **Modul Kasir & Transaksi (`features/home_pos/`)**
   * Kasir memilih produk dari daftar yang tersedia di halaman utama (`home_pos_page.dart`).
   * Setiap pilihan produk dikelola oleh **Cubit** (`pos_cubit.dart` & `pos_state.dart`) untuk menghitung keranjang belanja, subtotal, dan total pembayaran secara *real-time*.
   * Setelah pembayaran selesai, data transaksi disimpan ke dalam database lokal Hive dan struk dapat dicetak.

3. **Manajemen Produk (`features/manage_product/`)**
   * Pemilik atau kasir dapat menambah, mengedit, atau menghapus data barang dagangan melalui halaman daftar produk (`product_list_page.dart`).

4. **Laporan Penjualan (`features/reports/`)**
   * Mengambil riwayat transaksi dari penyimpanan lokal untuk disajikan dalam bentuk rekapitulasi laporan penjualan (`sales_report_page.dart`).

5. **Pengaturan Periferal & Toko (`features/settings/`)**
   * Pengguna dapat mengatur koneksi printer thermal Bluetooth (`printer_settings.dart`), QRIS pembayaran (`qris_settings.dart`), serta format struk transaksi (`receipt_settings.dart`).

---

## 📂 Penjelasan Masing-Masing File

### 📁 `lib/`
* **`main.dart`**: Titik masuk utama aplikasi (*entry point*), tempat inisialisasi Hive, adapter, dan menjalankan root widget Flutter.

#### 📁 `core/`
* **`core/constants/app_colors.dart`**: Menyimpan konstanta warna global yang digunakan untuk konsistensi tema UI aplikasi.
* **`core/services/printer_service.dart`**: Layanan logika untuk menghubungkan dan mengirim perintah cetak teks/data ke printer Bluetooth thermal.
* **`core/widgets/app_drawer.dart`**: Komponen navigasi samping (menu drawer) yang dapat diakses dari berbagai halaman untuk berpindah menu.

#### 📁 `data/models/`
* **`product_model.dart`**: Skema/model data untuk produk (nama, harga, stok, dll).
* **`product_model.g.dart`**: File *generated* (TypeAdapter Hive) untuk serialisasi objek produk ke database Hive.
* **`transaction_model.dart`**: Skema/model data untuk transaksi penjualan (daftar item, total harga, tanggal, dll).
* **`transaction_model.g.dart`**: File *generated* untuk serialisasi objek transaksi ke database Hive.

#### 📁 `features/`
* **`features/home_pos/`**
  * **`cubit/pos_cubit.dart`**: Logika bisnis utama untuk kasir (menambah/menghapus item keranjang, menghitung total, dan memproses transaksi).
  * **`cubit/pos_state.dart`**: Menampung state/status dari keranjang belanja dan proses kasir saat ini.
  * **`presentation/home_pos_page.dart`**: Tampilan antarmuka utama halaman kasir/penjualan.
* **`features/manage_product/`**
  * **`presentation/product_list_page.dart`**: Tampilan antarmuka untuk melihat, menambah, dan mengelola daftar produk toko.
* **`features/reports/`**
  * **`presentation/sales_report_page.dart`**: Tampilan antarmuka untuk memuat dan melihat rekap laporan penjualan.
* **`features/settings/`**
  * **`settings_page.dart`**: Halaman utama pusat pengaturan aplikasi.
  * **`printer_settings_page.dart`**: Halaman konfigurasi perangkat printer Bluetooth.
  * **`qris_settings_page.dart`**: Halaman pengaturan QRIS pembayaran digital.
  * **`receipt_settings_page.dart`**: Halaman pengaturan format dan teks pada struk belanja.

---

## 🛠️ Tech Stack
* **Framework:** Flutter (Dart)[cite: 7]
* **State Management:** Flutter Bloc / Cubit (`flutter_bloc`, `equatable`)[cite: 7]
* **Local Database:** Hive (`hive`, `hive_flutter`)[cite: 7]
* **Printer & Utilities:** Print Bluetooth Thermal, Intl, Image Picker[cite: 7]