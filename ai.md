# 🤖 AI Context — CRUD-Project-For-W13L-

File ini berisi konteks, panduan, dan catatan untuk AI assistant agar dapat membantu pengembangan project ini secara lebih efektif.

---

## 📌 Deskripsi Project

**Nama:** CRUD-Project-For-W13L-  
**Platform:** Flutter (Mobile / Cross-platform)  
**Tujuan:** Aplikasi CRUD (Create, Read, Update, Delete) sebagai tugas/project untuk Week 13 Lab.

---

## 🧱 Stack Teknologi

| Layer       | Teknologi              |
|-------------|------------------------|
| Framework   | Flutter / Dart         |
| State Mgmt  | *(belum ditentukan)*   |
| Backend     | *(belum ditentukan)*   |
| Database    | *(belum ditentukan)*   |
| UI          | Flutter Material / Cupertino |

> Perbarui tabel ini seiring perkembangan project.

---

## 📁 Struktur Project (Target)

```
CRUD-Project-For-W13L-/
├── lib/
│   ├── main.dart              # Entry point aplikasi
│   ├── models/                # Data model (entity classes)
│   ├── screens/               # Halaman UI utama
│   │   ├── home_screen.dart
│   │   ├── add_screen.dart
│   │   ├── edit_screen.dart
│   │   └── detail_screen.dart
│   ├── widgets/               # Komponen UI reusable
│   ├── services/              # Logic bisnis & koneksi data
│   └── utils/                 # Helper dan konstanta
├── assets/                    # Gambar, font, dll.
├── test/                      # Unit & widget test
├── pubspec.yaml               # Dependensi project
├── README.md
└── ai.md                      # ← File ini
```

---

## 🎯 Fitur Utama

- [ ] **Create** — Tambah data baru melalui form input
- [ ] **Read** — Tampilkan daftar data (ListView / GridView)
- [ ] **Update** — Edit data yang sudah ada
- [ ] **Delete** — Hapus data dengan konfirmasi dialog
- [ ] **Validasi Form** — Validasi input sebelum disimpan
- [ ] **State Management** — Manajemen state antar halaman

---

## 🧠 Panduan untuk AI Assistant

### Konvensi Kode
- Gunakan **Dart null-safety** (`?`, `!`, `late`)
- Penamaan: `camelCase` untuk variabel & fungsi, `PascalCase` untuk class
- Gunakan `const` constructor bila memungkinkan untuk performa
- Pisahkan logika dari UI (gunakan service/controller layer)

### Pola yang Direkomendasikan
```dart
// Model
class Item {
  final String id;
  final String name;
  final String description;

  Item({required this.id, required this.name, required this.description});

  factory Item.fromMap(Map<String, dynamic> map) => Item(
    id: map['id'],
    name: map['name'],
    description: map['description'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
  };
}
```

### Hal yang Harus Dihindari
- ❌ Jangan hardcode string — gunakan konstanta
- ❌ Hindari `setState` berlebihan — pertimbangkan state management
- ❌ Jangan lupa `dispose()` pada controller
- ❌ Jangan abaikan error handling pada operasi async

---

## 📋 Catatan Pengembangan

| Tanggal    | Catatan                                      |
|------------|----------------------------------------------|
| 2026-05-18 | Project diinisialisasi, struktur dasar dibuat |

---

## 🔗 Referensi

- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/language)
- [Flutter Cookbook — CRUD with SQLite](https://docs.flutter.dev/cookbook/persistence/sqlite)
- [pub.dev](https://pub.dev/) — Cari package Flutter

---

> **Catatan:** Perbarui file `ai.md` ini setiap kali ada keputusan arsitektur baru, perubahan stack, atau fitur besar yang ditambahkan. File ini membantu AI memahami konteks project dengan cepat.
