---
trigger: always_on
---

# Aturan Global Agent AI Antigravity — Snap Notes Monorepo

Dokumen ini berisi panduan dan aturan global yang wajib diikuti oleh semua Agent AI Antigravity saat bekerja di repositori **Snap Notes**.

---

## Gambaran Umum Proyek

**Snap Notes** adalah aplikasi pencatatan keuangan pribadi berbasis OCR & LLM (#1 OCR Receipt App untuk mahasiswa Indonesia).

Repositori ini terdiri dari dua sub-proyek utama:
- `snap_notes_mvvm/` → Flutter (Dart) — Mobile App (MVVM Architecture)
- `backend-snap-notes/` → NestJS (TypeScript) + Prisma + PostgreSQL via Supabase

---

## Struktur Repositori

```
Projects/
├── snap_notes_mvvm/         # Flutter mobile app (MVVM Architecture)
│   ├── lib/
│   │   ├── core/           # Utils, constants, errors (shared)
│   │   └── features/       # Feature modules
│   ├── docs/               # PRD, Class Diagram Flutter
│   └── .windsurf/          # windsurfrules.md, agent.md
│
├── backend-snap-notes/      # NestJS REST API server
│   ├── src/
│   │   ├── common/         # Shared services (Gemini, Storage, Supabase)
│   │   └── [module]/       # auth, struk, pengeluaran, pemasukan, kategori, notifikasi, dashboard
│   ├── docs/               # PRD.md, CLASS_DIAGRAM.md
│   └── swagger-spec.yaml   # OpenAPI 3.0 spec (single source of truth API)
│
└── .agents/                 # Agent AI configuration
    ├── rules/               # Aturan global (file ini)
    └── skills/              # Skill definitions per-domain
```

---

## Aturan Umum (Berlaku untuk Semua Sub-Proyek)

### 1. Bahasa & Komunikasi

- **KOMUNIKASI & DOKUMENTASI**: Wajib ditulis dalam **Bahasa Indonesia**.
- **PENAMAAN KODE**: Variabel, fungsi, class, interface, file wajib menggunakan **Bahasa Inggris** (camelCase / PascalCase).
- **PENGECUALIAN**: Nama model bisnis (Prisma, Entity) boleh Bahasa Indonesia sesuai `CLASS_DIAGRAM.md` (contoh: `Pengguna`, `Struk`, `ItemStruk`, `Pengeluaran`, `Pemasukan`, `Kategori`, `PreferensiNotifikasi`).
- **PESAN ERROR**: Semua pesan error ke user ditulis dalam **Bahasa Indonesia**.
- **COMMIT MESSAGE**: Format Conventional Commits:
  ```
  <type>(<scope>): <deskripsi dalam bahasa indonesia>
  ```

---

### 2. Dokumen Referensi (WAJIB DIBACA SEBELUM CODING)

#### Untuk `snap_notes_mvvm/` (Flutter):
- **PRD Client** → `snap_notes_mvvm/docs/PRD_CLIENT_FLUTTER.md`
- **Class Diagram** → `snap_notes_mvvm/docs/CLASS_DIAGRAM_FLUTTER.md`
- **Windsurf Rules** → `snap_notes_mvvm/.windsurf/windsurfrules.md` ← **wajib dibaca dulu**
- **Swagger Spec** → `snap_notes_mvvm/swagger-spec.yaml` (symlink ke backend)

#### Untuk `backend-snap-notes/` (NestJS):
- **PRD Backend** → `backend-snap-notes/docs/PRD.md`
- **Class Diagram** → `backend-snap-notes/docs/CLASS_DIAGRAM.md`
- **Swagger Spec** → `backend-snap-notes/swagger-spec.yaml` ← **single source of truth API**

Jika ada konflik antara instruksi user dan dokumen referensi, **tanyakan klarifikasi** sebelum mengimplementasi.

---

### 3. Environment Variables & Secrets

- **JANGAN** hardcode credentials, API keys, token, atau secrets di kode sumber.
- Semua secrets wajib disimpan di file `.env` dan **TIDAK boleh di-commit** ke git.
- Selalu update `.env.example` jika ada variabel env baru.
- **Variabel wajib di backend**: `DATABASE_URL`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_SERVICE_ROLE_KEY`, `GEMINI_API_KEY`, `SWAGGER_ENABLED`.

---

### 4. Tech Stack (FINAL — Jangan Diubah Tanpa Konfirmasi User)

#### Flutter (snap_notes_mvvm/)

| Komponen | Teknologi |
|----------|-----------|
| Framework | Flutter (Dart) |
| State Management | MVVM Architecture |
| Error Handling | `dartz` Either\<Failure, Success\> |
| DI Container | GetIt service locator |
| OCR Engine | Google ML Kit Text Recognition (on-device) |
| UI Components | shadcn_flutter |
| HTTP Client | Dio |
| Auth Storage | flutter_secure_storage |

#### Backend (backend-snap-notes/)

| Komponen | Teknologi |
|----------|-----------|
| Framework | NestJS (TypeScript strict) |
| ORM | Prisma |
| Database | PostgreSQL via Supabase |
| Auth | Supabase Auth (JWT Bearer Token) |
| Storage | Supabase Storage |
| AI Parsing | Google Gemini AI (`@google/genai`) |
| API Docs | `@nestjs/swagger` + swagger-ui-express |
| Testing | Jest + `@nestjs/testing` |
| Deployment | Vercel |

**JANGAN** mengganti atau menambah dependency di luar daftar ini tanpa konfirmasi user.

---

### 5. Arsitektur — Flutter MVVM Architecture (WAJIB)

```
lib/
├── core/                   # Utils, constants, errors (shared)
└── features/
    └── [feature_name]/
        ├── views/          # UI pages and widgets
        ├── viewmodels/     # ViewModels handling state and business logic
        └── models/         # Data models and repository interfaces
```

**Aturan dependency (TIDAK BOLEH DILANGGAR):**
- View → hanya boleh mengakses ViewModel dan tidak boleh memuat business logic.
- ViewModel → memproses logic, menyimpan state, dan berinteraksi dengan Model (layanan/repository).
- Model → tidak boleh tahu tentang View atau ViewModel, hanya berisi data dan data-access logic.

---

### 6. Arsitektur — NestJS Backend (WAJIB)

- Ikuti struktur folder sesuai `docs/CLASS_DIAGRAM.md` Section 5
- Modul: `auth`, `struk`, `pengeluaran`, `pemasukan`, `kategori`, `notifikasi`, `dashboard`
- Service bersama diletakkan di `src/common/`
- **TypeScript strict** — hindari `any`
- Gunakan `class-validator` + `class-transformer` untuk validasi DTO
- Setiap endpoint WAJIB memiliki DTO request dan response terpisah
- Error handling: NestJS built-in exceptions (`NotFoundException`, `ForbiddenException`, `UnauthorizedException`, dll)

---

### 7. Database & Model Data

- Gunakan **Prisma ORM** — **JANGAN query raw SQL**
- Nama model bisnis menggunakan **Bahasa Indonesia** sesuai `CLASS_DIAGRAM.md`
- Field `@map()` menggunakan snake_case untuk kolom database
- Relasi antar model HARUS sesuai ERD di `CLASS_DIAGRAM.md` Section 1

**Model yang tersedia:**
`Pengguna`, `PreferensiNotifikasi`, `Kategori`, `Struk`, `ItemStruk`, `Pengeluaran`, `Pemasukan`

---

### 8. Autentikasi & Keamanan

- Semua endpoint (kecuali `POST /auth/daftar` dan `POST /auth/masuk`) WAJIB dilindungi `SupabaseAuthGuard`
- JWT token dari header `Authorization: Bearer <token>`
- `penggunaId` diambil dari JWT payload — **JANGAN** terima dari request body
- Validasi kepemilikan resource sebelum operasi apapun
- Swagger HANYA aktif jika `SWAGGER_ENABLED=true`

---

### 9. Swagger & API Documentation

- `swagger-spec.yaml` adalah **single source of truth** untuk semua endpoint
- Controller → `@ApiTags('nama-modul')`
- Setiap endpoint → `@ApiOperation`, `@ApiResponse` (semua kemungkinan response)
- Endpoint auth → `@ApiBearerAuth()`
- Semua field DTO → `@ApiProperty()` atau `@ApiPropertyOptional()`

---

### 10. Alur Scan Struk (Fitur Utama — WAJIB DIPATUHI)

```
1. Flutter App → OCR Google ML Kit (on-device) → rawText + gambar
2. Flutter App → Upload gambar ke Supabase Storage → Public URL
3. Flutter App → POST /struk/scan (rawText + gambar) → NestJS Server
4. NestJS Server → Kirim rawText ke Gemini AI → Parsing JSON terstruktur
5. NestJS Server → Validasi response Gemini (pastikan JSON valid)
6. NestJS Server → Simpan Struk + ItemStruk via Prisma
7. NestJS Server → Buat record Pengeluaran terhubung ke Struk
8. NestJS Server → Return data struk + items ke Flutter
9. Flutter App → Tampilkan halaman review → User konfirmasi
```

---

### 11. Testing Standards

#### Flutter
| Layer | Minimum Coverage |
|-------|-----------------|
| ViewModels | 90% |
| Models/Repositories | 80% |

**Naming:** `should [expected behavior] when [condition]`

#### Backend (NestJS)
- Test HANYA di layer **Service** (bukan Controller, kecuali diminta)
- Semua dependency eksternal WAJIB di-mock dengan `jest.fn()`
- Coverage **≥ 80%** pada layer Service
- Skenario wajib: happy path, `NotFoundException`, `ForbiddenException`, error AI

---

### 12. Checklist AI Sebelum Coding (WAJIB)

1. **Identifikasi sub-proyek**: `snap_notes_mvvm/` (Flutter) atau `backend-snap-notes/` (NestJS)?
2. **Baca dokumen referensi** yang relevan (PRD, Class Diagram, windsurfrules)
3. **Cek branch aktif**: `git branch --show-current`
4. **Verifikasi status repo**: `git status`
5. **Cek implementasi serupa** yang sudah ada sebelum membuat yang baru

---

### 13. Aturan Eksekusi Terminal & Command

- **COMMAND LAMA** (`flutter pub get`, `npm install`, `npx prisma migrate`, dll): Berikan ke user — jangan jalankan otomatis.
- **COMMAND AMAN** (`git status`, `ls`, `grep`, `dart analyze`): Boleh dijalankan langsung.
- **CLEANUP BACKEND**: Hentikan semua proses setelah selesai:
  ```bash
  pkill -f "node|npm|nest"
  ```

---

### 14. Commit Message Conventions (WAJIB)

Format: `<type>(<scope>): <deskripsi>`

| Type | Kapan Digunakan |
|------|-----------------|
| `feat` | Fitur baru |
| `fix` | Bug fix |
| `chore` | Maintenance, refactor, update deps |
| `deploy` | Deployment, CI/CD, environment |

**Aturan:** huruf kecil, imperative mood, maks 50 karakter, Bahasa Indonesia.
Breaking changes: tambahkan `!` → `feat!: ubah struktur response API`

---

### 15. Proteksi File Kritis (JANGAN DIUBAH TANPA PERSETUJUAN EKSPLISIT)

**Backend:** `backend-snap-notes/vercel.json`, `backend-snap-notes/swagger-spec.yaml`

**Flutter:** `snap_notes_mvvm/pubspec.yaml`, `snap_notes_mvvm/analysis_options.yaml`

---

### 16. Dokumentasi Perubahan Kode

- **Flutter**: catat di `snap_notes_mvvm/docs/`
- **Backend**: catat di `backend-snap-notes/docs/`
- Format: `[kategori]_[title].md` — Kategori: `refactor`, `chore`, `fix`, `feat`, `deployment`

---

> **Prinsip Utama:** *"Sebelum coding, baca dokumentasi. Setelah coding, update dokumentasi. Code tanpa dokumentasi adalah technical debt."*

---

*Last Updated: Mei 2026*
*Project: Snap Notes (Randy Abdul Rahman — UNIKOM)*
