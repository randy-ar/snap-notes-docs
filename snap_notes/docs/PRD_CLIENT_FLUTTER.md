# Product Requirements Document (PRD)
# Snap Notes — Aplikasi Flutter Client Side

**Versi:** 1.0.0  
**Tanggal:** Mei 2026  
**Status:** Draft  
**Platform:** Android & iOS (Flutter)

---

## 1. Ringkasan Eksekutif

Snap Notes Client adalah aplikasi mobile Flutter yang berfungsi sebagai interface pengguna untuk pencatatan pengeluaran dari struk belanja. Aplikasi memanfaatkan Google ML Kit untuk OCR on-device, mengirimkan hasil ke backend NestJS untuk diproses dengan Gemini AI, dan menampilkan dashboard laporan keuangan yang interaktif.

### Peran Client dalam Sistem
- **OCR On-Device**: Google ML Kit memproses gambar struk di sisi client untuk mengurangi beban server
- **UI/UX**: Interface yang intuitif untuk scan, review, dan manajemen transaksi
- **State Management**: Mengelola state aplikasi dengan BLoC pattern
- **Local Storage**: Menyimpan token JWT dan preferensi user secara aman

---

## 2. Tech Stack

| Komponen | Teknologi | Keterangan |
|----------|-----------|------------|
| **Framework** | Flutter (Dart SDK ^3.11.4) | Cross-platform mobile development |
| **State Management** | flutter_bloc ^9.1.1 | BLoC/Cubit pattern untuk reactive state |
| **HTTP Client** | dio ^5.9.2 | REST API communication dengan backend |
| **Dependency Injection** | get_it ^9.2.1 | Service locator pattern |
| **OCR Engine** | google_mlkit_text_recognition ^0.15.1 | On-device text recognition |
| **UI Components** | shadcn_flutter ^0.0.52 | Modern UI component library |
| **Image Picker** | image_picker ^1.2.1 | Akses kamera dan galeri |
| **Camera** | camera ^0.12.0+1 | Direct camera control untuk scan |
| **Image Crop** | image_cropper ^12.2.1 | Crop dan rotate gambar struk |
| **Secure Storage** | flutter_secure_storage | Penyimpanan JWT token |
| **Functional Programming** | dartz ^0.10.1 | Either type untuk error handling |
| **Env Config** | flutter_dotenv ^6.0.1 | Environment variables |
| **JSON Serialization** | json_annotation + json_serializable | Type-safe JSON parsing |
| **Equatable** | equatable ^2.0.8 | Value equality untuk state |

---

## 3. Arsitektur Clean Code

### 3.1 Layer Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                           │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐   │
│  │    Pages    │  │   Widgets   │  │  Cubits/Blocs (State)   │   │
│  │  (Flutter   │  │  (Reusable  │  │   - AuthCubit           │   │
│  │   Widgets)  │  │   UI comps) │  │   - ScanCubit           │   │
│  └──────┬──────┘  └─────────────┘  │   - StrukReviewCubit    │   │
│         │                           │   - DashboardCubit      │   │
│         │ emit state                │   - dll                 │   │
│         ▼                           └─────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                      DOMAIN LAYER                           │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐    │  │
│  │  │   Entities   │  │  Use Cases   │  │   Repository    │    │  │
│  │  │  (Business   │  │  (Business   │  │   Interfaces    │    │  │
│  │  │   Objects)   │  │   Logic)     │  │   (Contracts)   │    │  │
│  │  └──────────────┘  └──────────────┘  └─────────────────┘    │  │
│  └─────────────────────────────────────────────────────────────┘  │
│                           │                                      │
│         ▼                 ▼                 ▼                    │
│  ┌─────────────────────────────────────────────────────────────┐  │
│  │                       DATA LAYER                            │  │
│  │  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐    │  │
│  │  │    Models    │  │  DataSources │  │   Repository    │    │  │
│  │  │  (JSON       │  │  (API/Local/ │  │   Implement.    │    │  │
│  │  │   Parsing)   │  │   OCR/DB)    │  │                 │    │  │
│  │  └──────────────┘  └──────────────┘  └─────────────────┘    │  │
│  └─────────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

### 3.2 Dependency Rule
- **Inner layers** tidak boleh bergantung pada **outer layers**
- Dependencies mengarah ke dalam (Domain ← Data)
- Use Cases orchestrate flow data ke/dari entities

---

### 3.3 State Management Strategy — Hybrid Cubit & Bloc

Aplikasi Snap Notes menggunakan **pendekatan hybrid** untuk state management: **Cubit sebagai default (80%)** dan **Bloc untuk flow kompleks (20%)**.

#### Guidelines Pemilihan Cubit vs Bloc

| Gunakan **CUBIT** jika | Gunakan **BLOC** jika |
|------------------------|----------------------|
| Hanya 1-2 action (load, refresh) | Multi-step workflow kompleks |
| Tidak ada business flow rumit | Banyak user interaction trigger state change |
| Hanya fetch dan display data | Perlu tracking history event |
| State transitions linear | State branches atau conditional flow |

#### Decision Tree

```
Apakah fitur memiliki:
├── Multi-step workflow? (contoh: Scan → OCR → Upload → Review)
│   └── YA → Gunakan BLOC
│
├── Banyak branching state? (3+ state transitions kompleks)
│   └── YA → Gunakan BLOC
│
└── TIDAK → Gunakan CUBIT (default)
```

#### Mapping Feature ke State Management

| Feature | State Management | Alasan |
|---------|-----------------|--------|
| **Auth** | Cubit | Flow sederhana: login/logout/refresh |
| **Scan Struk** | **Bloc** | Flow kompleks: Camera → OCR → Upload → Review → Konfirmasi |
| **Dashboard** | Cubit | Fetch & display data, refresh |
| **Pengeluaran List** | Cubit | List dengan pagination |
| **Pengeluaran Form** | Cubit | Form validation & submit |
| **Pemasukan** | Cubit | CRUD sederhana mirip pengeluaran |
| **Kategori** | Cubit | CRUD sederhana |
| **Notifikasi** | Cubit | Setting boolean dan time picker |

#### Struktur Folder Hybrid

```
lib/features/
├── auth/presentation/cubit/           ← Cubit (flow sederhana)
│   ├── auth_cubit.dart
│   └── auth_state.dart
│
├── receipt/presentation/bloc/       ← Bloc (flow kompleks)
│   ├── receipt_bloc.dart
│   ├── receipt_event.dart
│   └── receipt_state.dart
│
├── dashboard/presentation/cubit/    ← Cubit
├── pengeluaran/presentation/cubit/  ← Cubit
└── notifikasi/presentation/cubit/   ← Cubit
```

#### Perbandingan Implementasi

**Cubit (Simple)**:
```dart
class DashboardCubit extends Cubit<DashboardState> {
  DashboardCubit() : super(DashboardInitial());
  
  void loadDashboard() async {
    emit(DashboardLoading());
    final result = await getDashboardData();
    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (data) => emit(DashboardLoaded(data)),
    );
  }
  
  void refresh() => loadDashboard();
}
```

**Bloc (Complex Workflow)**:
```dart
class ReceiptBloc extends Bloc<ReceiptEvent, ReceiptState> {
  ReceiptBloc() : super(ReceiptCameraPreview()) {
    on<StartCameraEvent>(_onStartCamera);
    on<CaptureImageEvent>(_onCaptureImage);
    on<ProcessOCREvent>(_onProcessOCR);
    on<UploadToServerEvent>(_onUploadToServer);
    on<ReviewCompleteEvent>(_onReviewComplete);
    on<CancelScanEvent>(_onCancelScan);
  }
  // Handler untuk tiap event dengan flow yang jelas
}
```

#### Keuntungan Hybrid Approach

1. **Developer Velocity**: 80% fitur pakai Cubit = development lebih cepat
2. **Code Maintainability**: Less boilerplate, less bug
3. **Team Scaling**: Junior dev kuasai Cubit dulu (1 minggu), Senior dev handle Bloc
4. **Testing Efficiency**: Cubit 50% less test code
5. **Flexibility**: Refactor ke Bloc hanya jika flow jadi kompleks

> **Rule of Thumb**: "Start with Cubit, graduate to Bloc when needed."
> Jika ragu, gunakan Cubit. Refactor ke Bloc saat flow menjadi kompleks.

---

## 4. Fitur Utama Client

### 4.1 Autentikasi (Auth Feature)

**Deskripsi:** Manajemen login, register, logout, dan token JWT.

**State Management**: **Cubit** (flow sederhana, 1-2 action per fitur)

**Alur:**
1. User input email/password di `LoginPage`
2. `AuthCubit` memanggil `MasukUseCase`
3. `AuthRepository` memanggil `AuthRemoteDataSource`
4. Response token disimpan di `flutter_secure_storage`
5. Dio interceptor otomatis menambahkan Bearer token

**Halaman:**
- `LoginPage` - Form login dengan validasi
- `RegisterPage` - Form registrasi user baru

**Cubits:**
- `AuthCubit` - Handle login/logout/refresh dan global auth state
- `AuthState` - States: `AuthInitial`, `AuthLoading`, `AuthAuthenticated`, `AuthError`

---

### 4.2 Scan Struk dengan OCR (Scan Struk Feature)

**Deskripsi:** Fitur utama aplikasi - memindai struk menggunakan kamera dan OCR.

**State Management**: **Bloc** (flow kompleks multi-step: Camera → OCR → Upload → Review → Konfirmasi)

**Alur Detail:**
1. User tap "Scan Struk" → `ScanStrukPage`
2. Pilih sumber: Kamera langsung atau Galeri
3. Jika kamera: `CameraView` dengan preview real-time
4. User capture foto struk → `CaptureImageEvent`
5. `ImageCropper` untuk crop/rotate jika diperlukan
6. `OcrLocalDataSource` memproses gambar dengan Google ML Kit → `ProcessOCREvent`
7. Hasil raw text ditampilkan preview
8. User konfirmasi → `UploadToServerEvent` kirim ke server:
   - `rawText` (hasil OCR)
   - `gambar` (file multipart/form-data)
9. Server proses dengan Gemini AI → kembalikan JSON terstruktur
10. `StrukReviewPage` menampilkan hasil parsing untuk review/edit
11. User bisa edit item, kategori, atau detail struk
12. Konfirmasi final → `ReviewCompleteEvent` → struk tersimpan

**Halaman:**
- `ScanStrukPage` - Pilih sumber (kamera/galeri)
- `CameraPreviewPage` - Preview kamera dengan capture button
- `CropImagePage` - Crop dan rotate gambar
- `OcrPreviewPage` - Preview raw text dari OCR
- `StrukReviewPage` - Review dan edit hasil AI parsing

**Blocs:**
- `ReceiptBloc` - Manage complete scan workflow dengan events:
  - `StartCameraEvent`, `CaptureImageEvent`, `ProcessOCREvent`
  - `UploadToServerEvent`, `ReviewCompleteEvent`, `CancelScanEvent`
- `ReceiptState`: `ReceiptCameraPreview`, `ReceiptProcessingOCR`, `ReceiptOCRSuccess`, `ReceiptUploading`, `ReceiptServerSuccess`, `ReceiptError`

**Events:**
```dart
abstract class ReceiptEvent extends Equatable { ... }
class StartCameraEvent extends ReceiptEvent { ... }
class CaptureImageEvent extends ReceiptEvent { final File image; ... }
class ProcessOCREvent extends ReceiptEvent { final File image; ... }
class UploadToServerEvent extends ReceiptEvent { final String rawText; final File image; ... }
class ReviewCompleteEvent extends ReceiptEvent { final String strukId; ... }
class CancelScanEvent extends ReceiptEvent { ... }
```

**Integrasi:**
```
Google ML Kit (on-device)
    ↓
Raw Text + Gambar
    ↓
POST /struk/scan (NestJS)
    ↓
Gemini AI Parsing
    ↓
JSON Terstruktur
    ↓
Review & Konfirmasi UI
```

---

### 4.3 Manajemen Pengeluaran (Pengeluaran Feature)

**Deskripsi:** CRUD pengeluaran manual dan yang berasal dari struk.

**State Management**: **Cubit** (CRUD sederhana, fetch list dan form submission)

**Alur:**
1. `PengeluaranListPage` - Daftar semua pengeluaran dengan filter
2. `PengeluaranDetailPage` - Detail satu pengeluaran
3. `TambahPengeluaranPage` - Form tambah pengeluaran manual
4. Edit/Hapus pengeluaran dengan konfirmasi

**Halaman:**
- `PengeluaranListPage` - List dengan search dan filter
- `PengeluaranDetailPage` - Detail lengkap
- `TambahPengeluaranPage` - Form input manual
- `EditPengeluaranPage` - Form edit

**Cubits:**
- `PengeluaranListCubit` - Manage list state dengan pagination
- `PengeluaranFormCubit` - Manage form state (add/edit)

---

### 4.4 Manajemen Pemasukan (Pemasukan Feature)

**Deskripsi:** CRUD pemasukan manual.

**State Management**: **Cubit** (CRUD sederhana mirip pengeluaran)

**Alur:** Sama dengan pengeluaran, tetapi untuk transaksi masuk.

**Halaman:**
- `PemasukanListPage`
- `PemasukanDetailPage`
- `TambahPemasukanPage`

**Cubits:**
- `PemasukanListCubit`
- `PemasukanFormCubit`

---

### 4.5 Manajemen Kategori (Kategori Feature)

**Deskripsi:** Mengelola kategori preset dan custom.

**State Management**: **Cubit** (List dan form CRUD sederhana)

**Alur:**
1. `KategoriListPage` - Tampilkan kategori preset + custom
2. `TambahKategoriPage` - Buat kategori custom baru
3. Edit/Hapus kategori custom (preset tidak bisa dihapus)

**Halaman:**
- `KategoriListPage` - Grid/list kategori dengan icon
- `TambahKategoriPage` - Form tambah kategori custom

**Cubits:**
- `KategoriCubit` - Manage list dan CRUD operations

---

### 4.6 Dashboard Laporan (Dashboard Feature)

**Deskripsi:** Visualisasi data keuangan dengan chart dan calendar.

**State Management**: **Cubit** (Fetch dan display data, refresh, filter periode)

**Komponen UI:**
- **Calendar View** - `TableCalendar` dengan marker transaksi
- **Ringkasan Card** - Total pengeluaran, pemasukan, saldo bulan ini
- **Line Chart** - `fl_chart` untuk tren 6 bulan terakhir
- **Pie Chart** - Breakdown pengeluaran per kategori
- **Riwayat List** - Transaksi terbaru

**Halaman:**
- `DashboardPage` - Main dashboard dengan semua komponen
- `KalenderDetailPage` - Detail transaksi per tanggal yang dipilih

**Cubits:**
- `DashboardCubit` - Fetch dan manage semua data dashboard
- `KalenderCubit` - Manage calendar view state

**API Integration:**
```
GET /dashboard/ringkasan?bulan=&tahun=
GET /dashboard/kalender?bulan=&tahun=
GET /dashboard/tren?bulan_mulai=&bulan_selesai=
GET /dashboard/kategori?bulan=&tahun=
```

---

### 4.7 Notifikasi Pengingat (Notifikasi Feature)

**Deskripsi:** Pengaturan jadwal notifikasi lokal.

**State Management**: **Cubit** (Setting boolean dan time picker)

**Alur:**
1. `NotifikasiSettingPage` - UI pengaturan
2. User pilih hari aktif (checkbox Senin-Minggu)
3. User pilih jam notifikasi (time picker)
4. Simpan ke server via `NotifikasiRepository`
5. `flutter_local_notifications` schedule notifikasi lokal

**Halaman:**
- `NotifikasiSettingPage` - Form pengaturan notifikasi

**Cubits:**
- `NotifikasiCubit` - Manage preferensi notifikasi

---

## 5. Struktur Data & Models

### 5.1 Entities (Domain Layer)

Semua entities immutable dengan `Equatable`.

**Pengguna Entity:**
```dart
class Pengguna extends Equatable {
  final String id;
  final String email;
  final String namaLengkap;
  final String? fotoProfilUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
}
```

**Struk Entity:**
```dart
class Struk extends Equatable {
  final String id;
  final String namaToko;
  final DateTime tanggalBelanja;
  final double total;
  final String? gambarUrl;
  final String? kategoriId;
  final List<ItemStruk> items;
  final DateTime createdAt;
}
```

**ItemStruk Entity:**
```dart
class ItemStruk extends Equatable {
  final String id;
  final String namaItem;
  final int jumlah;
  final double hargaSatuan;
  final double subtotal;
  final String? kategoriId;
}
```

**Pengeluaran Entity:**
```dart
class Pengeluaran extends Equatable {
  final String id;
  final String? strukId; // null jika input manual
  final String deskripsi;
  final double jumlah;
  final DateTime tanggal;
  final String? kategoriId;
  final String? catatan;
}
```

---

## 6. Spesifikasi Non-Fungsional

### 6.1 Performa

| Metric | Target |
|--------|--------|
| App Launch | < 2 detik |
| OCR Processing | < 3 detik (depend on device) |
| API Response | < 2 detik (non-AI) |
| Full Scan Flow | < 10 detik end-to-end |
| Frame Rate | 60 FPS (jika device support) |
| Memory Usage | < 150 MB idle |

### 6.2 Keamanan

| Aspek | Implementasi |
|-------|--------------|
| Token Storage | `flutter_secure_storage` (Keychain/Keystore) |
| Network | HTTPS only, certificate pinning (optional) |
| Input Validation | Server-side + client-side validation |
| OCR Data | Raw text tidak disimpan lokal, langsung kirim ke server |
| Image | Temporary file dihapus setelah upload |

### 6.3 UX/UI

| Aspek | Spesifikasi |
|-------|-------------|
| Theme | Material 3 dengan shadcn_flutter components |
| Responsive | Support phone (portrait primary) |
| Accessibility | Support screen reader, minimum touch target 48dp |
| Loading State | Skeleton loaders, progress indicators |
| Error Handling | Snackbar/toast dengan pesan user-friendly |
| Empty State | Illustrasi dan CTA yang jelas |

### 6.4 Offline Capability

| Fitur | Offline Support |
|-------|-----------------|
| View Dashboard | Cache data terakhir |
| View List | Cache dengan TTL |
| Add Transaction | Queue untuk sync saat online |
| Scan Struk | Butuh online (karena butuh Gemini AI) |

---

## 7. Alur Data Utama

### 7.1 Alur Scan Struk Lengkap

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   User      │────▶│ Camera/     │────▶│ Image       │
│   Action    │     │ Gallery     │     │ Cropper     │
└─────────────┘     └─────────────┘     └──────┬──────┘
                                               │
                                               ▼
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Review    │◀────│   Server    │◀────│  Google ML  │
│    & Edit   │     │  (Gemini)   │     │  Kit OCR    │
└──────┬──────┘     └─────────────┘     └─────────────┘
       │
       ▼
┌─────────────┐     ┌─────────────┐
│  Confirm    │────▶│   Save to   │
│   Save      │     │   Database  │
└─────────────┘     └─────────────┘
```

### 7.2 Alur Autentikasi

```
LoginPage
    │
    ▼
LoginCubit ──▶ MasukUseCase ──▶ AuthRepository
                                      │
                                      ▼
                              AuthRemoteDataSource
                                      │
                                      ▼
                              POST /auth/masuk
                                      │
                                      ▼
                              Save token ke
                              flutter_secure_storage
```

---

## 8. Error Handling Strategy

### 8.1 Failure Types (dartz Either)

```dart
abstract class Failure extends Equatable {
  final String message;
}

class ServerFailure extends Failure {}
class NetworkFailure extends Failure {}
class CacheFailure extends Failure {}
class OCRFailure extends Failure {}
class ValidationFailure extends Failure {}
class UnauthorizedFailure extends Failure {}
```

### 8.2 Error UI Patterns

| Skenario | UI Response |
|----------|-------------|
| Network error | Snackbar dengan retry button |
| Server error | Dialog dengan detail error |
| Validation error | Inline field error |
| OCR failed | Alert dengan opsi manual input |
| Unauthorized | Auto logout ke login page |

---

## 9. Integrasi dengan Backend

### 9.1 API Client Configuration (Dio)

```dart
class DioClient {
  final Dio dio;
  
  // Base URL dari .env
  // Timeout: 30s (default), 60s (upload)
  // Interceptors:
  //   - AuthInterceptor (add Bearer token)
  //   - ErrorInterceptor (handle errors)
  //   - LoggingInterceptor (dev only)
}
```

### 9.2 Endpoint Mapping

| Feature | Endpoints |
|---------|-----------|
| Auth | `POST /auth/daftar`, `POST /auth/masuk`, `POST /auth/refresh`, `GET /auth/profil` |
| Scan Struk | `POST /struk/scan`, `GET /struk/:id`, `PATCH /struk/:id`, `DELETE /struk/:id` |
| Pengeluaran | `GET /pengeluaran`, `POST /pengeluaran`, `PATCH /pengeluaran/:id`, `DELETE /pengeluaran/:id` |
| Pemasukan | `GET /pemasukan`, `POST /pemasukan`, `PATCH /pemasukan/:id`, `DELETE /pemasukan/:id` |
| Kategori | `GET /kategori`, `POST /kategori`, `PATCH /kategori/:id`, `DELETE /kategori/:id` |
| Dashboard | `GET /dashboard/ringkasan`, `GET /dashboard/kalender`, `GET /dashboard/tren`, `GET /dashboard/kategori` |
| Notifikasi | `GET /notifikasi/preferensi`, `POST /notifikasi/preferensi`, `PATCH /notifikasi/preferensi` |

---

## 10. Testing Strategy

### 10.1 Unit Tests

| Layer | Coverage Target | Tools |
|-------|-----------------|-------|
| Domain (Use Cases) | > 90% | mocktail |
| Data (Repositories) | > 80% | mocktail |
| Cubits | > 85% | bloc_test |

### 10.2 Widget Tests

| Screen | Skenario Test |
|--------|---------------|
| LoginPage | Validasi form, tap login, loading state, error state |
| ScanStrukPage | Tap camera, capture flow, OCR loading |
| DashboardPage | Load data, pull-to-refresh, chart rendering |

### 10.3 Integration Tests

| Flow | Skenario |
|------|----------|
| End-to-end scan | Login → Scan → Review → Save → Verify di list |
| CRUD pengeluaran | Tambah → Edit → Hapus → Verify |

---

## 11. Development Milestone

| Phase | Deliverables | Estimasi |
|-------|--------------|----------|
| **Phase 1: Setup** | Project structure, DI, theme, API client | 1 minggu |
| **Phase 2: Auth** | Login, register, token management | 1 minggu |
| **Phase 3: Core** | OCR integration, camera, image crop | 1 minggu |
| **Phase 4: Scan** | Scan struk flow, review UI, konfirmasi | 1 minggu |
| **Phase 5: Transaksi** | Pengeluaran & pemasukan CRUD | 1 minggu |
| **Phase 6: Dashboard** | Calendar, charts, visualisasi | 1 minggu |
| **Phase 7: Polish** | Notifikasi, testing, bug fix, UI polish | 1 minggu |

---

## 12. Risiko & Mitigasi

| Risiko | Dampak | Mitigasi |
|--------|--------|----------|
| OCR tidak akurat pada struk buram | Medium | Fallback ke manual input, UI edit yang baik |
| Device tidak support Google ML Kit | Low | Cek availability, graceful degradation |
| Memory leak saat camera | Medium | Proper disposal, testing di low-end devices |
| Cold start lambat | Low | Lazy load, code splitting, reduce initial deps |
| Backend downtime | High | Retry logic, cache strategy, offline queue |

---

*Dokumen ini adalah landasan pengembangan Flutter client untuk Snap Notes.*
