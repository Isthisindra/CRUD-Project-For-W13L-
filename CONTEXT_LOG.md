# 📋 CONTEXT LOG — CRUD-Project-For-W13L-

> File ini adalah log konteks lengkap dari semua perubahan yang dilakukan pada project ini.
> Tujuan: dikirim ke AI manager / AI assistant baru agar langsung memahami state project.
>
> **Dibuat pada:** 2026-05-18 19:26 WIB  
> **Dibuat oleh:** Antigravity (AI coding assistant)  
> **Sesi:** Initial project scaffold

---

## 🧭 Ringkasan Proyek

| Atribut       | Detail                                      |
|---------------|---------------------------------------------|
| Nama Project  | CRUD-Project-For-W13L-                      |
| Platform      | Flutter (Mobile)                            |
| Tujuan        | Aplikasi CRUD sederhana untuk tugas W13L    |
| State Mgmt    | Provider (`ChangeNotifier`)                 |
| Backend / DB  | Supabase (PostgreSQL)                       |
| UI Style      | Cupertino (iOS-style widgets)               |
| Bahasa        | Dart (null-safety)                          |

---

## 📁 Struktur File Final

```
CRUD-Project-For-W13L-/
├── pubspec.yaml                        ✅ Dibuat
├── ai.md                               ✅ Dibuat (konteks untuk AI)
├── CONTEXT_LOG.md                      ✅ File ini
├── README.md                           (sudah ada, tidak diubah)
└── lib/
    ├── main.dart                       ✅ Dibuat
    ├── utils/
    │   └── constants.dart              ✅ Dibuat
    ├── models/
    │   └── item_model.dart             ✅ Dibuat
    ├── services/
    │   └── item_service.dart           ✅ Dibuat
    ├── providers/
    │   └── item_provider.dart          ✅ Dibuat
    ├── screens/
    │   ├── home_screen.dart            ✅ Dibuat
    │   ├── add_screen.dart             ✅ Dibuat
    │   ├── edit_screen.dart            ✅ Dibuat
    │   └── detail_screen.dart          ✅ Dibuat
    └── widgets/
        └── item_card.dart              ✅ Dibuat
```

---

## 🔄 Log Perubahan Per File

---

### `pubspec.yaml` — DIBUAT BARU

**Tujuan:** Mendefinisikan dependensi project Flutter.

**Dependencies yang ditambahkan:**
- `provider: ^6.1.2` — state management
- `supabase_flutter: ^2.3.4` — backend & database
- `cupertino_icons: ^1.0.6` — icon pack iOS

**Catatan:** `uses-material-design: false` karena seluruh UI menggunakan Cupertino.

---

### `lib/utils/constants.dart` — DIBUAT BARU

**Tujuan:** Menyimpan semua konstanta global agar tidak ada string hardcode di kode.

**Isi:**
- `supabaseUrl` — URL project Supabase (**WAJIB DIISI**)
- `supabaseAnonKey` — Anonymous key Supabase (**WAJIB DIISI**)
- `itemsTable` — Nama tabel (`'items'`)

> ⚠️ **ACTION REQUIRED:** Isi `supabaseUrl` dan `supabaseAnonKey` dengan kredensial dari Supabase Dashboard → Settings → API.

---

### `lib/models/item_model.dart` — DIBUAT BARU

**Tujuan:** Representasi data entity `Item` yang digunakan di seluruh aplikasi.

**Fields:**
| Field        | Tipe       | Sumber DB         |
|--------------|------------|-------------------|
| `id`         | `String`   | UUID (auto-gen)   |
| `name`       | `String`   | Input user        |
| `description`| `String`   | Input user        |
| `createdAt`  | `DateTime` | Timestamp DB      |

**Methods:**
- `Item.fromMap(Map)` — parse dari response Supabase
- `toMap()` — konversi ke Map untuk insert/update (tanpa `id` & `created_at`)
- `copyWith(...)` — buat salinan dengan field yang diubah

---

### `lib/services/item_service.dart` — DIBUAT BARU

**Tujuan:** Layer tunggal yang bertanggung jawab atas semua komunikasi dengan Supabase. UI tidak boleh menyentuh Supabase secara langsung.

**Methods:**
| Method                        | Aksi Supabase                                     |
|-------------------------------|---------------------------------------------------|
| `fetchAll()`                  | `.select().order('created_at', ascending: false)` |
| `create(Item item)`           | `.insert(item.toMap())`                           |
| `update(String id, Item item)`| `.update(item.toMap()).eq('id', id)`              |
| `delete(String id)`           | `.delete().eq('id', id)`                          |

**Pola:** Semua method `async`, lempar exception jika gagal (ditangani oleh Provider).

---

### `lib/providers/item_provider.dart` — DIBUAT BARU

**Tujuan:** Mengelola state aplikasi dan menjadi jembatan antara `ItemService` dan UI.

**State:**
- `List<Item> _items` — daftar item yang ditampilkan
- `bool _isLoading` — status loading
- `String? _errorMessage` — pesan error terakhir

**Methods:** `loadItems()`, `addItem()`, `updateItem()`, `deleteItem()`  
**Pattern:** Setiap method set `_isLoading = true` → jalankan service → `_isLoading = false` → `notifyListeners()`.

---

### `lib/main.dart` — DIBUAT BARU

**Tujuan:** Entry point aplikasi.

**Alur:**
1. `WidgetsFlutterBinding.ensureInitialized()`
2. `Supabase.initialize(url, anonKey)`
3. `runApp(ChangeNotifierProvider(create: ItemProvider, child: CupertinoApp))`

**Root widget:** `CupertinoApp` dengan tema `primaryColor: CupertinoColors.systemBlue`.

---

### `lib/screens/home_screen.dart` — DIBUAT BARU

**Tujuan:** Halaman utama, menampilkan daftar semua item.

**Fitur:**
- Load data otomatis saat pertama buka (`initState`)
- Tiga state UI: loading (`CupertinoActivityIndicator`), kosong, dan berisi list
- State error dengan tombol "Coba Lagi"
- Navigasi ke `AddScreen` via tombol `+` di navigation bar
- Navigasi ke `DetailScreen` saat item di-tap
- Dialog konfirmasi hapus (`CupertinoAlertDialog`) saat tombol trash di-tap

---

### `lib/screens/add_screen.dart` — DIBUAT BARU

**Tujuan:** Form untuk menambah item baru.

**Fitur:**
- `CupertinoTextField` untuk `name` (wajib) dan `description` (opsional)
- Validasi: nama tidak boleh kosong → tampil `CupertinoAlertDialog` error
- Loading state saat menyimpan (tombol berubah jadi `CupertinoActivityIndicator`)
- Pop otomatis kembali ke `HomeScreen` setelah simpan berhasil

---

### `lib/screens/edit_screen.dart` — DIBUAT BARU

**Tujuan:** Form untuk mengedit item yang sudah ada.

**Fitur:**
- Pre-fill field dengan data item yang diterima via constructor
- Validasi sama dengan `AddScreen`
- Setelah update berhasil: `Navigator.pop()` dua kali (tutup EditScreen + DetailScreen) untuk kembali ke HomeScreen
- Menggunakan `item.copyWith()` untuk update field

---

### `lib/screens/detail_screen.dart` — DIBUAT BARU

**Tujuan:** Menampilkan detail lengkap satu item.

**Konten:**
- Ikon + nama item di header
- Section: Deskripsi, Dibuat Pada (formatted `dd/MM/yyyy HH:mm`), ID (UUID)
- Tombol "Edit Item" → navigasi ke `EditScreen`
- Tombol "Hapus Item" (merah) → `CupertinoAlertDialog` konfirmasi → delete + kembali ke Home

---

### `lib/widgets/item_card.dart` — DIBUAT BARU

**Tujuan:** Komponen card reusable untuk menampilkan satu item dalam list di `HomeScreen`.

**Props:**
- `item` — data yang ditampilkan
- `onTap` — callback saat card di-tap (navigasi ke detail)
- `onDelete` — callback saat tombol trash di-tap

**UI:** Container dengan shadow, ikon dokumen, nama (bold), deskripsi (2 baris, truncated), tombol trash merah.

---

### `ai.md` — DIBUAT BARU (diupdate oleh user)

**Tujuan:** File konteks untuk AI assistant agar memahami project dengan cepat.

**Isi:** Stack teknologi, struktur folder, setup Supabase, SQL schema, pola kode (model/service/provider/UI), hal yang harus dihindari, referensi dokumentasi.

---

## ⚠️ Action Items yang Belum Diselesaikan

| No | Item                                         | File                          | Status  |
|----|----------------------------------------------|-------------------------------|---------|
| 1  | Isi `supabaseUrl` dengan URL project nyata   | `lib/utils/constants.dart`    | ❌ TODO |
| 2  | Isi `supabaseAnonKey` dengan key nyata       | `lib/utils/constants.dart`    | ❌ TODO |
| 3  | Jalankan `flutter pub get`                   | Terminal                      | ❌ TODO |
| 4  | Buat tabel `items` di Supabase SQL Editor    | Supabase Dashboard            | ❌ TODO |
| 5  | Jalankan dan test aplikasi (`flutter run`)   | Terminal                      | ❌ TODO |

---

## 🗄️ SQL untuk Supabase

Jalankan di **Supabase Dashboard → SQL Editor**:

```sql
CREATE TABLE items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Opsional: aktifkan RLS jika menggunakan autentikasi
-- ALTER TABLE items ENABLE ROW LEVEL SECURITY;
```

---

## 🏗️ Arsitektur Layer

```
UI (Screens & Widgets)
        │ context.watch / context.read
        ▼
Provider (ItemProvider)
        │ memanggil service
        ▼
Service (ItemService)
        │ Supabase SDK
        ▼
Supabase / PostgreSQL
```

**Aturan penting:**
- Screen **tidak boleh** memanggil Supabase langsung
- Service **tidak boleh** memiliki state atau memanggil `notifyListeners`
- Provider **tidak boleh** membangun widget

---

## 📌 Dependensi Versi

```yaml
provider: ^6.1.2
supabase_flutter: ^2.3.4
cupertino_icons: ^1.0.6
```

---

> **Untuk AI manager:** Semua file sudah lengkap dan siap dijalankan setelah mengisi Supabase credentials dan membuat tabel di database. Tidak ada file Material widget yang digunakan — seluruh UI menggunakan Cupertino.
