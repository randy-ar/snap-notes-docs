# Windsurf Rules — Snap Notes Flutter Development Guidelines

> **Dokumentasi ini adalah pedoman mutlak untuk AI agent dalam mengembangkan fitur Snap Notes. Setiap implementasi HARUS mengikuti aturan yang tercantum di sini.**

---

## 1. Architecture Overview

### 1.1 Clean Architecture Layers (Strict)

**Urutan dependency: Presentation → Domain ← Data**

```
lib/
├── core/                    # Utils, constants, errors (shared)
├── features/
│   └── [feature_name]/
│       ├── presentation/     # UI + State Management (Cubit/Bloc)
│       │   ├── cubit/       # Default: Cubit (80% features)
│       │   ├── bloc/        # Complex: Bloc (20% features)
│       │   ├── pages/
│       │   └── widgets/
│       ├── domain/          # Business logic (pure Dart)
│       │   ├── entities/
│       │   ├── repositories/  # Interfaces only
│       │   └── usecases/
│       └── data/            # Implementation details
│           ├── datasources/
│           ├── models/
│           └── repositories/
```

**⚠️ NEVER VIOLATE:**
- Domain layer TIDAK boleh import dari Presentation atau Data
- Data layer boleh import Domain (implements repository interface)
- Presentation layer boleh import Domain (uses use cases)

---

## 1.2 Backend API Reference

### API Spec Location
- **Swagger Spec:** `/swagger-spec.yaml` (symlink ke backend project)
- **Backend Source:** `/backend_snap_notes_backend_link_1746593912403/`

### Base Configuration
```dart
// Base URL & Auth
const String apiBaseUrl = 'https://backend-snap-notes.vercel.app/api'; // Production
// const String apiBaseUrl = 'http://localhost:3000/api'; // Development

// Headers
Headers: {
  'Authorization': 'Bearer <supabase_jwt_token>',
  'Content-Type': 'application/json',
}
```

### Available Endpoints

| Method | Endpoint | Description | Request | Response |
|--------|----------|-------------|---------|----------|
| `POST` | `/struk/scan` | Scan struk dengan OCR + AI | `multipart/form-data`: `gambar` (File), `raw_ocr_text` (String) | `StrukResponseDto` |
| `GET` | `/struk?bulan={m}&tahun={y}` | Daftar struk pengguna | Query: `bulan`, `tahun` | `List<StrukResponseDto>` |
| `GET` | `/struk/{id}` | Detail struk | Path: `id` | `StrukResponseDto` |
| `PATCH` | `/struk/{id}` | Update struk | JSON: `UpdateStrukDto` | `StrukResponseDto` |
| `DELETE` | `/struk/{id}` | Hapus struk | Path: `id` | `void` |
| `POST` | `/struk/{id}/konfirmasi` | Konfirmasi struk | Path: `id` | `StrukResponseDto` |

### Response Model (StrukResponseDto)
```json
{
  "id": "uuid",
  "nama_toko": "Indomaret Jl. Merdeka",
  "tanggal": "2026-05-07",
  "total": 85000,
  "kategori_toko": "Makanan & Minuman",
  "url_gambar": "https://...",
  "status_scan": "PENDING_REVIEW | CONFIRMED",
  "created_at": "2026-05-07T10:00:00Z",
  "updated_at": "2026-05-07T10:00:00Z",
  "items": [
    {
      "nama": "Indomie Goreng",
      "jumlah": 3,
      "harga_satuan": 3500,
      "subtotal": 10500,
      "kategori": "Makanan"
    }
  ]
}
```

### Error Responses
| Status | Description | Handling |
|--------|-------------|----------|
| `400` | Data tidak valid | Show validation errors |
| `401` | Unauthorized | Redirect to login |
| `403` | Forbidden (bukan milik pengguna) | Show access denied |
| `404` | Struk tidak ditemukan | Show not found message |
| `503` | Service AI tidak tersedia | Retry or manual input |

---

## 2. State Management — Hybrid Strategy (MANDATORY)

### 2.1 Decision Tree (WAJIB IKUTI)

```
Fitur Baru?
├── Multi-step workflow? (contoh: Scan → OCR → Upload → Review)
│   └── YA → Gunakan BLOC di features/[name]/presentation/bloc/
│
├── Banyak branching state? (3+ state transitions kompleks)
│   └── YA → Gunakan BLOC
│
└── TIDAK → Gunakan CUBIT di features/[name]/presentation/cubit/
```

### 2.2 Current Feature Mapping

| Feature | Type | Location | Pattern |
|---------|------|----------|---------|
| **Auth** | Simple | `auth/presentation/cubit/` | Cubit |
| **Receipt/Scan** | **Complex** | `receipt/presentation/bloc/` | **Bloc** |
| **Dashboard** | Simple | `dashboard/presentation/cubit/` | Cubit |
| **Pengeluaran** | Simple | `pengeluaran/presentation/cubit/` | Cubit |
| **Pemasukan** | Simple | `pemasukan/presentation/cubit/` | Cubit |
| **Kategori** | Simple | `kategori/presentation/cubit/` | Cubit |
| **Notifikasi** | Simple | `notifikasi/presentation/cubit/` | Cubit |

### 2.3 Cubit Implementation Rules

```dart
// ✅ CORRECT
class DashboardCubit extends Cubit<DashboardState> {
  final GetRingkasan getRingkasan;
  
  DashboardCubit({required this.getRingkasan}) : super(DashboardInitial());
  
  Future<void> loadDashboard(int bulan, int tahun) async {
    emit(DashboardLoading());
    final result = await getRingkasan(Params(bulan: bulan, tahun: tahun));
    result.fold(
      (failure) => emit(DashboardError(failure.message)),
      (data) => emit(DashboardLoaded(data)),
    );
  }
}

// ❌ WRONG - Business logic in Cubit
typealias DashboardCubit extends Cubit<DashboardState> {
  Future<void> loadDashboard() async {
    emit(DashboardLoading());
    // NEVER: Direct API call here
    final response = await http.get(...);  // ❌
    emit(DashboardLoaded(response));  // ❌
  }
}
```

### 2.4 Bloc Implementation Rules (Event-Based)

```dart
// ✅ CORRECT - ReceiptBloc (Complex flow)
class ReceiptBloc extends Bloc<ReceiptEvent, ReceiptState> {
  final OcrLocalDataSource ocrDataSource;
  final ScanReceiptUseCase scanReceipt;
  
  ReceiptBloc({required this.ocrDataSource, required this.scanReceipt}) 
      : super(ReceiptCameraPreview()) {
    on<CaptureImageEvent>(_onCaptureImage);
    on<ProcessOCREvent>(_onProcessOCR);
    on<UploadToServerEvent>(_onUploadToServer);
  }
  
  Future<void> _onProcessOCR(ProcessOCREvent event, Emitter<ReceiptState> emit) async {
    emit(ReceiptProcessingOCR(image: event.image));
    final result = await ocrDataSource.processImage(event.image);
    result.fold(
      (failure) => emit(ReceiptOCRError(message: failure.message)),
      (rawText) => emit(ReceiptOCRSuccess(rawText: rawText, image: event.image)),
    );
  }
}
```

---

## 3. Domain Layer Rules (CRITICAL)

### 3.1 Entities (Pure Dart, No Dependencies)

```dart
// ✅ CORRECT
class Pengguna extends Equatable {
  final String id;
  final String email;
  final String namaLengkap;
  
  const Pengguna({required this.id, required this.email, required this.namaLengkap});
  
  @override
  List<Object?> get props => [id, email, namaLengkap];
}

// ❌ WRONG - No external dependencies in entities
class Pengguna extends HiveObject {  // ❌ Don't extend external classes
  @HiveField(0)  // ❌ No annotations from external packages
  final String id;
}
```

### 3.2 Use Cases (One Use Case = One Action)

```dart
// ✅ CORRECT - Single responsibility
class ScanReceiptUseCase implements UseCase<RecognizedText, ScanReceiptParams> {
  final ReceiptRepository repository;
  
  ScanReceiptUseCase(this.repository);
  
  @override
  Future<Either<Failure, RecognizedText>> call(ScanReceiptParams params) {
    return repository.scanReceipt(params.image);
  }
}

// ❌ WRONG - Multiple responsibilities
class ReceiptUseCase {  // ❌ Too generic
  Future<Either<Failure, dynamic>> call(String action, dynamic data) { ... }
}
```

### 3.3 Repository Interfaces (Domain)

```dart
// ✅ CORRECT - Abstract, no implementation
abstract class ReceiptRepository {
  Future<Either<Failure, RecognizedText>> scanReceipt(File image);
  Future<Either<Failure, Struk>> uploadToServer(String rawText, File image);
  Future<Either<Failure, List<Struk>>> getReceipts();
}
```

---

## 4. Data Layer Rules

### 4.1 Models (JSON Serialization)

```dart
// ✅ CORRECT
import 'package:json_annotation/json_annotation.dart';

part 'pengguna_model.g.dart';

@JsonSerializable()
class PenggunaModel {
  final String id;
  final String email;
  final String namaLengkap;
  
  PenggunaModel({required this.id, required this.email, required this.namaLengkap});
  
  factory PenggunaModel.fromJson(Map<String, dynamic> json) => 
      _$PenggunaModelFromJson(json);
  
  Map<String, dynamic> toJson() => _$PenggunaModelToJson(this);
  
  // Conversion to/from Entity
  Pengguna toEntity() => Pengguna(id: id, email: email, namaLengkap: namaLengkap);
  
  factory PenggunaModel.fromEntity(Pengguna entity) => 
      PenggunaModel(id: entity.id, email: entity.email, namaLengkap: entity.namaLengkap);
}
```

### 4.2 Data Sources

```dart
// Remote Data Source - API calls
class ReceiptRemoteDataSource {
  final Dio dio;
  
  ReceiptRemoteDataSource({required this.dio});
  
  Future<ReceiptModel> scanReceipt(String rawText, File image) async {
    final formData = FormData.fromMap({
      'rawText': rawText,
      'image': await MultipartFile.fromFile(image.path),
    });
    
    final response = await dio.post('/struk/scan', data: formData);
    return ReceiptModel.fromJson(response.data);
  }
}

// Local Data Source - On-device processing
class OcrLocalDataSource {
  final TextRecognizer recognizer;
  
  OcrLocalDataSource({required this.recognizer});
  
  Future<Either<Failure, String>> processImage(File image) async {
    try {
      final inputImage = InputImage.fromFile(image);
      final result = await recognizer.processImage(inputImage);
      return Right(result.text);
    } catch (e) {
      return Left(OCRFailure(message: e.toString()));
    }
  }
}
```

### 4.3 Repository Implementation

```dart
class ReceiptRepositoryImpl implements ReceiptRepository {
  final ReceiptRemoteDataSource remoteDataSource;
  final OcrLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  ReceiptRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, RecognizedText>> scanReceipt(File image) async {
    try {
      final result = await localDataSource.processImage(image);
      return result;
    } on OCRProcessingException catch (e) {
      return Left(OCRFailure(message: e.message));
    }
  }
  
  @override
  Future<Either<Failure, Struk>> uploadToServer(String rawText, File image) async {
    if (!await networkInfo.isConnected) {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
    
    try {
      final model = await remoteDataSource.scanReceipt(rawText, image);
      return Right(model.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
```

---

## 5. Error Handling (MANDATORY)

### 5.1 Failure Classes (dartz Either)

```dart
// ✅ ALWAYS use Either<Failure, SuccessType>
abstract class Failure extends Equatable {
  final String message;
  const Failure({required this.message});
  
  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  final int? statusCode;
  const ServerFailure({required super.message, this.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class OCRFailure extends Failure {
  const OCRFailure({required super.message});
}

class ValidationFailure extends Failure {
  final Map<String, String>? errors;
  const ValidationFailure({required super.message, this.errors});
}
```

### 5.2 Exception Classes (Data Layer)

```dart
class ServerException implements Exception {
  final String message;
  final int? statusCode;
  ServerException({required this.message, this.statusCode});
}

class OCRProcessingException implements Exception {
  final String message;
  OCRProcessingException({required this.message});
}
```

### 5.3 UI Error Handling

```dart
// In Cubit/Bloc
result.fold(
  (failure) {
    if (failure is ServerFailure) {
      emit(ErrorState('Server error: ${failure.message}'));
    } else if (failure is NetworkFailure) {
      emit(ErrorState('No internet connection'));
    } else if (failure is OCRFailure) {
      emit(ErrorState('OCR failed, try manual input'));
    } else {
      emit(ErrorState('An error occurred'));
    }
  },
  (data) => emit(LoadedState(data)),
);
```

---

## 6. Dependency Injection (GetIt)

### 6.1 Registration Rules

```dart
// injection_container.dart

// External dependencies
sl.registerLazySingleton(() => Dio());
sl.registerLazySingleton(() => FlutterSecureStorage());
sl.registerLazySingleton(() => TextRecognizer());

// Data Sources
sl.registerLazySingleton<AuthRemoteDataSource>(
  () => AuthRemoteDataSourceImpl(dio: sl()),
);
sl.registerLazySingleton<OcrLocalDataSource>(
  () => OcrLocalDataSourceImpl(recognizer: sl()),
);

// Repositories
sl.registerLazySingleton<AuthRepository>(
  () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
);

// Use Cases
sl.registerLazySingleton(() => Masuk(sl()));
sl.registerLazySingleton(() => ScanReceipt(sl()));

// Cubits (Factory - new instance each time)
sl.registerFactory(() => AuthCubit(masukUseCase: sl(), keluarUseCase: sl()));
sl.registerFactory(() => DashboardCubit(getRingkasan: sl()));

// Blocs (Factory)
sl.registerFactory(() => ReceiptBloc(
  ocrDataSource: sl(),
  scanReceipt: sl(),
));
```

### 6.2 Order of Registration

1. External dependencies (Dio, SecureStorage, etc.)
2. Core utilities (NetworkInfo, etc.)
3. Data sources (Remote, Local)
4. Repositories
5. Use cases
6. Cubits/Blocs

---

## 7. Feature Development Workflow

### 7.1 When Adding New Feature

**Step-by-step (MUST FOLLOW):**

1. **Decide State Management:**
   - Simple? → Cubit in `presentation/cubit/`
   - Complex workflow? → Bloc in `presentation/bloc/`

2. **Create Domain Layer First:**
   ```
   domain/entities/ - Define entity classes
   domain/repositories/ - Define repository interfaces
   domain/usecases/ - Define use cases
   ```

3. **Create Data Layer:**
   ```
   data/datasources/ - Remote and local data sources
   data/models/ - JSON models with from/to entity
   data/repositories/ - Repository implementations
   ```

4. **Create Presentation Layer:**
   ```
   presentation/cubit/ OR presentation/bloc/ - State management
   presentation/pages/ - Screen widgets
   presentation/widgets/ - Reusable feature widgets
   ```

5. **Register in DI:**
   - Add to `injection_container.dart`

6. **Testing:**
   - Unit test use cases
   - Unit test cubits/blocs
   - Widget test pages

### 7.2 File Naming Convention

| Component | Naming | Example |
|-----------|--------|---------|
| Entity | `[name].dart` | `pengguna.dart` |
| Model | `[name]_model.dart` | `pengguna_model.dart` |
| Use Case | `[action]_[resource].dart` | `scan_receipt.dart` |
| Repository Interface | `[resource]_repository.dart` | `receipt_repository.dart` |
| Repository Impl | `[resource]_repository_impl.dart` | `receipt_repository_impl.dart` |
| Data Source | `[resource]_[type]_datasource.dart` | `receipt_remote_datasource.dart` |
| Cubit | `[resource]_cubit.dart` | `dashboard_cubit.dart` |
| Cubit State | `[resource]_state.dart` | `dashboard_state.dart` |
| Bloc | `[resource]_bloc.dart` | `receipt_bloc.dart` |
| Bloc Event | `[resource]_event.dart` | `receipt_event.dart` |
| Bloc State | `[resource]_state.dart` | `receipt_state.dart` |
| Page | `[resource]_[action]_page.dart` | `receipt_scan_page.dart` |

---

## 8. UI/UX Guidelines

### 8.1 Using shadcn_flutter

```dart
// ✅ CORRECT - Use shadcn_flutter components
import 'package:shadcn_flutter/shadcn_flutter.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      child: Column(
        children: [
          // Use shadcn components
          PrimaryButton(
            onPressed: () {},
            child: Text('Login'),
          ),
          OutlineButton(
            onPressed: () {},
            child: Text('Register'),
          ),
          // ⚠️ ATURAN CARD:
          // JANGAN membungkus child dari Card dengan widget Padding.
          // Komponen Card dari shadcn_flutter sudah memiliki padding bawaan.
          // Menambahkan Padding di dalamnya akan membuat whitespace menjadi double/terlalu lebar.
          Card(
            child: Text('Content without extra Padding widget'),
          ),
        ],
      ),
    );
  }
}
```

### 8.2 State Handling in UI

```dart
class DashboardPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        // ✅ Handle ALL states
        if (state is DashboardInitial) {
          return const SizedBox.shrink();
        } else if (state is DashboardLoading) {
          return const LoadingIndicator();
        } else if (state is DashboardLoaded) {
          return DashboardContent(data: state.data);
        } else if (state is DashboardError) {
          return ErrorWidget(
            message: state.message,
            onRetry: () => context.read<DashboardCubit>().loadDashboard(),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
```

---

## 9. Testing Requirements

### 9.1 Unit Test Use Cases

```dart
void main() {
  late ScanReceiptUseCase useCase;
  late MockReceiptRepository mockRepository;
  
  setUp(() {
    mockRepository = MockReceiptRepository();
    useCase = ScanReceiptUseCase(mockRepository);
  });
  
  test('should return RecognizedText when scan is successful', () async {
    // Arrange
    final file = File('test.png');
    const expectedText = RecognizedText(text: 'Indomaret');
    when(mockRepository.scanReceipt(any)).thenAnswer((_) async => const Right(expectedText));
    
    // Act
    final result = await useCase(ScanReceiptParams(image: file));
    
    // Assert
    expect(result, const Right(expectedText));
    verify(mockRepository.scanReceipt(file));
  });
}
```

### 9.2 Unit Test Cubits

```dart
void main() {
  late DashboardCubit cubit;
  late MockGetRingkasan mockGetRingkasan;
  
  setUp(() {
    mockGetRingkasan = MockGetRingkasan();
    cubit = DashboardCubit(getRingkasan: mockGetRingkasan);
  });
  
  blocTest<DashboardCubit, DashboardState>(
    'emits [Loading, Loaded] when loadDashboard succeeds',
    build: () {
      when(mockGetRingkasan(any)).thenAnswer((_) async => Right(testData));
      return cubit;
    },
    act: (cubit) => cubit.loadDashboard(5, 2026),
    expect: () => [
      DashboardLoading(),
      DashboardLoaded(testData),
    ],
  );
}
```

### 9.3 Testing Coverage Requirements

| Layer | Minimum Coverage |
|-------|------------------|
| Domain (Use Cases) | 90% |
| Data (Repositories) | 80% |
| Cubits/Blocs | 85% |

---

## 10. Code Review Checklist

Before submitting any code, verify:

- [ ] **Architecture:** Domain layer doesn't import Presentation/Data
- [ ] **State Management:** Cubit for simple, Bloc for complex workflows
- [ ] **Error Handling:** All use cases return `Either<Failure, Success>`
- [ ] **DI:** All dependencies registered in injection_container.dart
- [ ] **Naming:** Follow naming conventions
- [ ] **Models:** Have fromJson, toJson, toEntity, fromEntity methods
- [ ] **Entities:** Extend Equatable, immutable with final fields
- [ ] **Tests:** Unit tests for use cases and cubits/blocs
- [ ] **UI:** Handle all states (loading, error, success, empty)
- [ ] **Imports:** No unused imports
- [ ] **Null Safety:** Proper null checking and non-nullable types where possible

---

## 11. References

- **Swagger API Spec:** `/swagger-spec.yaml` — OpenAPI 3.0 spec (auto-sync dengan backend)
- **Backend Source:** `/backend_snap_notes_backend_link_1746593912403/` — NestJS backend (symlink)
- **PRD Backend:** `/docs/PRD_BACKEND.md`
- **PRD Client:** `/docs/PRD_CLIENT_FLUTTER.md`
- **Class Diagram Backend:** `/docs/CLASS_DIAGRAM_BACKEND.md`
- **Class Diagram Flutter:** `/docs/CLASS_DIAGRAM_FLUTTER.md`

---

## 12. Commit Message Conventions (WAJIB)

Gunakan **Conventional Commits** dengan format:

```
<type>: <description>

[optional body]

[optional footer]
```

### 12.1 Types

| Type | Kapan Digunakan | Contoh |
|------|-----------------|--------|
| `feat` | Fitur baru atau enhancement | `feat: tambah halaman scan struk` |
| `fix` | Bug fix | `fix: perbaiki error saat upload gambar` |
| `chore` | Maintenance, refactor, tooling | `chore: update dependency dio ke 5.0` |
| `deploy` | Deployment related | `deploy: setup vercel production` |

### 12.2 Rules

**WAJIB:**
- Gunakan **lowercase** untuk description
- Gunakan **imperative mood** ("tambah" bukan "tambahan" atau "menambah")
- Deskripsi maksimal **50 karakter** untuk subject line
- Jelaskan **apa** dan **mengapa**, bukan **bagaimana**

**❌ JANGAN:**
```
feat: menambahkan halaman baru
fix: fixed bug
chore: wip update
```

**✅ BENAR:**
```
feat: tambah halaman review hasil scan

feat: implementasi bloc untuk upload struk

fix: perbaiki null pointer saat gambar kosong

chore: upgrade flutter ke 3.19.0

chore: refactor receipt repository untuk testability

deploy: konfigurasi firebase crashlytics
```

### 12.3 Scope (Optional)

Tambahkan scope untuk konteks lebih jelas:

```
feat(receipt): tambah use case scan struk
fix(auth): perbaiki refresh token expired
chore(deps): update package supabase_flutter
```

### 12.4 Breaking Changes

Gunakan `!` untuk breaking changes:

```
feat!: ubah struktur response API struk

fix!: hapus field deprecated dari model
```

---

> **⚠️ WARNING:** Violation of these rules will result in inconsistent codebase and technical debt. When in doubt, refer to existing implementations in `receipt` feature (Bloc) or `auth` feature (Cubit).

---

*Last Updated: Mei 2026*
