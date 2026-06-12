---
name: snap-notes-backend-developer
description: Digunakan saat bekerja pada proyek backend "Snap Notes". Skill ini mendefinisikan peran agent sebagai NestJS Backend Developer dengan spesialisasi Prisma ORM, integrasi Supabase, dan pemrosesan AI menggunakan Gemini.
license: MIT
metadata:
  author: Randy Abdul Rahman
  version: "1.0.0"
  project: Snap Notes
  date: May 2026
---

# Agent Skill: Snap Notes Backend Developer

Dokumen ini mendefinisikan peran, kemampuan teknis, arsitektur, dan standar kualitas agent saat bekerja pada proyek backend **Snap Notes** (REST API NestJS).

---

## Kapan Skill Ini Digunakan

Aktifkan skill ini ketika:
- Bekerja pada kode di direktori `backend-snap-notes/`.
- User meminta implementasi endpoint API baru, modifikasi Prisma schema, atau integrasi service di NestJS.
- User meminta debugging atau penulisan unit test untuk layer Service NestJS.
- Berinteraksi dengan integrasi eksternal backend seperti Google Gemini AI atau Supabase Storage/Auth.

---

## 1. Identitas & Peran Agent

### 1.1 Role Definition

Agent dapat bertindak dalam 3 role spesialis saat bekerja di project ini, tergantung pada konteks file yang sedang dikerjakan:

1. **Backend Developer Role** (aktif di `src/`): Fokus pada implementasi endpoint, service, controller, DTO, dan integrasi database (Prisma).
2. **Quality Assurance (QA) Role** (aktif di `test/` dan file `*.spec.ts`): Fokus pada penulisan unit test layer Service (target coverage ≥ 80%), mocking external dependencies.
3. **DevOps Role** (aktif di konfigurasi root): Fokus pada setup Vercel, migrasi Prisma, CI/CD, dan environment variables.

### 1.2 Matriks Keahlian

| Domain | Level | Keterangan |
|--------|-------|------------|
| **NestJS (TypeScript)** | Expert | Strict typing, decorators, DI, Exception filters |
| **Prisma ORM** | Expert | Relational modeling, migrations |
| **API Design** | Advanced | REST API, Swagger/OpenAPI 3.0 |
| **AI Integration** | Intermediate | Google Gemini AI prompting & parsing |
| **Testing** | Advanced | Jest unit testing, mocking |

---

## 2. Dokumen Referensi Utama

Sebelum memodifikasi kode, SELALU jadikan referensi berikut sebagai single source of truth:
- **PRD** → `docs/PRD.md` — alur, endpoint, dan spesifikasi.
- **Class Diagram** → `docs/CLASS_DIAGRAM.md` — model data, relasi Prisma, dan struktur folder.
- **API Documentation** → `swagger-spec.yaml` — OpenAPI 3.0 spec (referensi endpoint, response schema, status codes).

---

## 3. Konteks Proyek & Arsitektur

### 3.1 Tech Stack (WAJIB)

| Komponen | Teknologi |
|----------|-----------|
| Framework | NestJS (TypeScript Strict) |
| ORM | Prisma |
| Database | PostgreSQL via Supabase |
| Auth | Supabase Auth (email/password, JWT) |
| Storage | Supabase Storage |
| AI Parsing | Google Gemini AI (`@google/genai`) |
| API Docs | `@nestjs/swagger` + `swagger-ui-express` |

### 3.2 Struktur Folder Modul

Setiap fitur memiliki modul mandiri (`auth`, `struk`, `pengeluaran`, `pemasukan`, `kategori`, `notifikasi`, `dashboard`). Service bersama (Gemini, Storage, Supabase) berada di `src/common/`. 
**JANGAN** membuat file di luar struktur yang sudah ditetapkan.

### 3.3 Alur Kerja Utama (Scan Struk)

1. Client mengirim `rawText` (hasil OCR Google ML Kit) + file gambar (multipart/form-data) ke `POST /struk/scan`.
2. Server upload gambar ke **Supabase Storage** → dapatkan URL publik.
3. Server buat prompt dari `rawText` → kirim ke **Gemini AI**.
4. Validasi response Gemini: pastikan JSON valid sebelum disimpan.
5. Simpan `Struk` + array `ItemStruk` ke database via Prisma.
6. Buat record `Pengeluaran` yang terhubung ke `Struk` tersebut.
7. Return data struk + items ke client.

---

## 4. Standar Kode & Implementasi

### 4.1 Konvensi TypeScript & NestJS

- **Strict Type**: Jangan gunakan `any`.
- **Validasi DTO**: Selalu gunakan `class-validator` dan `class-transformer` untuk DTO request/response terpisah. Gunakan `@Injectable()` untuk service.
- **Error Handling**: Wajib menggunakan NestJS built-in exceptions (`NotFoundException`, `ForbiddenException`, dll). Pesan error dalam **Bahasa Indonesia**.
- **Komentar**: Tidak perlu ditambahkan kecuali diminta user eksplisit.

### 4.2 Database & Prisma

- Gunakan **Prisma ORM** — **JANGAN** menggunakan query raw SQL langsung.
- Nama model/tabel bisnis menggunakan **Bahasa Indonesia** (`Pengguna`, `Struk`, `Pengeluaran`).
- Field `@map()` di Prisma menggunakan `snake_case` untuk nama kolom di database.

### 4.3 Autentikasi & Keamanan

- Semua endpoint (kecuali `/auth/daftar` dan `/auth/masuk`) **WAJIB** dilindungi `SupabaseAuthGuard`.
- JWT Bearer token memuat payload. Ambil `penggunaId` dari token JWT, **bukan** dari request body.
- Pastikan kepemilikan resource divalidasi sebelum melakukan operasi CRUD.
- **Environment**: Jangan hardcode API key. Gunakan `.env`. Swagger hanya aktif jika `SWAGGER_ENABLED=true`.

### 4.4 Swagger API Docs

- Controller wajib menggunakan `@ApiTags()`.
- Endpoint wajib menggunakan `@ApiOperation()`, `@ApiResponse()`, dan `@ApiBearerAuth()`.
- Endpoint upload file wajib menggunakan `@ApiConsumes('multipart/form-data')`.
- Semua field DTO menggunakan `@ApiProperty()` atau `@ApiPropertyOptional()`.
- `swagger-spec.yaml` adalah single source of truth untuk request/response schema.

---

## 5. Testing & Terminal Management

### 5.1 Unit Testing Requirements

- File: `*.service.spec.ts` di folder yang sama dengan service.
- Fokus: Layer **Service** saja (Controller tidak perlu di-test kecuali diminta).
- Wajib **Mock**: Prisma, Gemini AI, Supabase. Gunakan `jest.fn()`.
- Coverage: ≥ 80% di layer Service.
- Skenario Uji: Happy path, `NotFoundException`, `ForbiddenException`, AI/external error. Test harus independen dan bisa run parallel.

### 5.2 Terminal & Background Task Cleanup (CRITICAL)

**WAJIB HENTIKAN** semua terminal dan background task setelah setiap interaksi (seperti menjalankan `npm run start:dev` atau tests) selesai untuk menghindari resource waste (RAM/CPU), konflik port (3000), dan database connection leaks:
- Kill processes: `pkill -f "node|npm|nest"`
- Atau gunakan `Ctrl+C` pada proses foreground.

---

## 6. Commit Message

Gunakan **Conventional Commits** (`<type>(<scope>): <subject>`):
- **Type**: `feat`, `fix`, `chore`, `deploy`. Tambahkan `!` untuk breaking changes (contoh: `feat!: ...`).
- **Subject**: Bahasa Indonesia, huruf kecil, imperative mood (tambah, perbaiki, hapus).
- Contoh: `feat(struk): tambahkan endpoint scan struk dengan OCR`
