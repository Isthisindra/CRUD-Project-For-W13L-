# 🤖 AI Context — CRUD-Project-For-W13L-

File ini berisi konteks, panduan, dan catatan untuk AI assistant agar dapat membantu pengembangan project ini secara lebih efektif.

---

## 📌 Deskripsi Project

**Nama:** CRUD-Project-For-W13L-  
**Platform:** Flutter (Mobile / Cross-platform)  
**Tujuan:** Aplikasi CRUD (Create, Read, Update, Delete) sebagai tugas/project untuk Week 13 Lab.

---

## 🧱 Stack Teknologi

| Layer      | Teknologi             |
| ---------- | --------------------- |
| Framework  | Flutter / Dart        |
| State Mgmt | Provider              |
| Backend    | Supabase              |
| Database   | Supabase (PostgreSQL) |
| UI         | Cupertino (iOS-style) |

---

## 📦 Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.2
  supabase_flutter: ^2.3.4
  cupertino_icons: ^1.0.6

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

---

## ⚙️ Setup Supabase

1. Buat project di [supabase.com](https://supabase.com)
2. Salin `SUPABASE_URL` dan `SUPABASE_ANON_KEY` dari **Project Settings → API**
3. Inisialisasi di `main.dart`:

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://your-project.supabase.co',
    anonKey: 'your-anon-key',
  );
  runApp(const MyApp());
}

// Shortcut global client
final supabase = Supabase.instance.client;
```

> ⚠️ Jangan commit API key ke Git. Gunakan `.env` atau `--dart-define`.

---

## 📁 Struktur Project (Target)

```
CRUD-Project-For-W13L-/
├── lib/
│   ├── main.dart                  # Entry point & Supabase init
│   ├── models/
│   │   └── item_model.dart        # Data model
│   ├── screens/
│   │   ├── home_screen.dart       # List semua data
│   │   ├── add_screen.dart        # Form tambah data
│   │   ├── edit_screen.dart       # Form edit data
│   │   └── detail_screen.dart     # Detail satu item
│   ├── widgets/
│   │   └── item_card.dart         # Komponen card reusable
│   ├── services/
│   │   └── item_service.dart      # Logic CRUD ke Supabase
│   ├── providers/
│   │   └── item_provider.dart     # Provider state management
│   └── utils/
│       └── constants.dart         # Konstanta (table name, dll.)
├── assets/
├── test/
├── pubspec.yaml
├── README.md
└── ai.md                          # ← File ini
```

---

## 🎯 Fitur Utama

- [ ] **Create** — Tambah data baru melalui form input Cupertino
- [ ] **Read** — Tampilkan daftar data (ListView dengan CupertinoListTile)
- [ ] **Update** — Edit data yang sudah ada
- [ ] **Delete** — Hapus data dengan CupertinoAlertDialog konfirmasi
- [ ] **Validasi Form** — Validasi input sebelum disimpan
- [ ] **State Management** — Provider untuk sinkronisasi state antar halaman
- [ ] **Realtime** — Opsional: Supabase realtime subscription

---

## 🧠 Panduan untuk AI Assistant

### Konvensi Kode

- Gunakan **Dart null-safety** (`?`, `!`, `late`)
- Penamaan: `camelCase` untuk variabel & fungsi, `PascalCase` untuk class
- Gunakan `const` constructor bila memungkinkan untuk performa
- Pisahkan logika dari UI (service layer untuk Supabase, provider untuk state)
- Gunakan **Cupertino widgets**, bukan Material — `CupertinoApp`, `CupertinoPageScaffold`, `CupertinoButton`, `CupertinoTextField`, dll.

### Pola Model

```dart
class Item {
  final String id;
  final String name;
  final String description;
  final DateTime createdAt;

  Item({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
  });

  factory Item.fromMap(Map<String, dynamic> map) => Item(
    id: map['id'],
    name: map['name'],
    description: map['description'],
    createdAt: DateTime.parse(map['created_at']),
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
  };
}
```

### Pola Service (Supabase)

```dart
class ItemService {
  final _client = Supabase.instance.client;
  static const _table = 'items';

  Future<List<Item>> fetchAll() async {
    final data = await _client.from(_table).select().order('created_at');
    return (data as List).map((e) => Item.fromMap(e)).toList();
  }

  Future<void> create(Item item) async {
    await _client.from(_table).insert(item.toMap());
  }

  Future<void> update(String id, Item item) async {
    await _client.from(_table).update(item.toMap()).eq('id', id);
  }

  Future<void> delete(String id) async {
    await _client.from(_table).delete().eq('id', id);
  }
}
```

### Pola Provider

```dart
class ItemProvider extends ChangeNotifier {
  final ItemService _service = ItemService();
  List<Item> _items = [];
  bool _isLoading = false;

  List<Item> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();
    _items = await _service.fetchAll();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(Item item) async {
    await _service.create(item);
    await loadItems();
  }

  Future<void> updateItem(String id, Item item) async {
    await _service.update(id, item);
    await loadItems();
  }

  Future<void> deleteItem(String id) async {
    await _service.delete(id);
    await loadItems();
  }
}
```

### Pola UI (Cupertino)

```dart
// Wrap app dengan ChangeNotifierProvider
void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ItemProvider(),
      child: const MyApp(),
    ),
  );
}

// Konsumsi provider di screen
class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ItemProvider>();
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Items')),
      child: provider.isLoading
          ? const Center(child: CupertinoActivityIndicator())
          : ListView.builder(
              itemCount: provider.items.length,
              itemBuilder: (_, i) => Text(provider.items[i].name),
            ),
    );
  }
}
```

### Hal yang Harus Dihindari

- ❌ Jangan hardcode string — gunakan konstanta di `utils/constants.dart`
- ❌ Jangan gunakan Material widgets — pakai Cupertino equivalents
- ❌ Jangan commit Supabase API key — gunakan environment variable
- ❌ Jangan lupa `dispose()` pada controller
- ❌ Jangan abaikan error handling pada operasi async Supabase
- ❌ Hindari `setState` — gunakan Provider untuk semua state antar halaman

---

## 🗄️ Supabase Table (SQL)

```sql
CREATE TABLE items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security (RLS) jika perlu auth
ALTER TABLE items ENABLE ROW LEVEL SECURITY;
```

---

## 📋 Catatan Pengembangan

| Tanggal    | Catatan                                              |
| ---------- | ---------------------------------------------------- |
| 2026-05-18 | Project diinisialisasi, struktur dasar dibuat        |
| 2026-05-18 | Stack ditentukan: Provider + Supabase + Cupertino UI |

---

## 🔗 Referensi

- [Flutter Docs](https://docs.flutter.dev/)
- [Dart Language Tour](https://dart.dev/language)
- [Supabase Flutter Docs](https://supabase.com/docs/reference/dart/introduction)
- [Provider Package](https://pub.dev/packages/provider)
- [Cupertino Widgets](https://docs.flutter.dev/ui/widgets/cupertino)
- [pub.dev](https://pub.dev/)

---

> **Catatan:** Perbarui file `ai.md` ini setiap kali ada keputusan arsitektur baru, perubahan stack, atau fitur besar yang ditambahkan. File ini membantu AI memahami konteks project dengan cepat.
