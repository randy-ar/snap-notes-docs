# Rancangan Class Diagram & Arsitektur MVVM (Client Mobile)

Dokumen ini merangkum daftar class yang dirancang untuk memetakan arsitektur MVC/MVVM pada aplikasi client Snap Notes. Susunan class ini digunakan sebagai rujukan standar untuk penyusunan *Class Diagram* dan metode pada *Sequence Diagram*.

## Core / Utils
- `DioClient`

## Features

### 1. Auth
**Services**
- `AuthService`
**ViewModels**
- `AuthViewModel`
- `LoginViewModel`
- `RegisterViewModel`
**Views**
- `LoginPage`
- `RegisterPage`
**Models**
- `Pengguna`
- `AuthToken`

### 2. Dashboard
**Services**
- `DashboardService`
**ViewModels**
- `DashboardViewModel`
**Views**
- `DashboardPage`
- `CalendarWidget`
- `LineChartWidget`
- `PieChartWidget`
**Models**
- *(None defined specifically here, may rely on aggregations)*

### 3. Notifikasi
**Services**
- `NotifikasiService`
**ViewModels**
- `NotifikasiViewModel`
**Views**
- `NotifikasiFormPage`
- `NotifikasiPage`
**Models**
- `PreferensiNotifikasi`

### 4. Pemasukan
**Services**
- `PemasukanService`
**ViewModels**
- `PemasukanViewModel`
**Views**
- `PemasukanDetailPage`
- `PemasukanFormPage`
- `PemasukanPage`
**Models**
- `Pemasukan`

### 5. Pengeluaran
**Services**
- `PengeluaranService`
**ViewModels**
- `PengeluaranViewModel`
**Views**
- `PengeluaranDetailPage`
- `PengeluaranFormPage`
- `PengeluaranPage`
**Models**
- `Pengeluaran`
- `Kategori`

### 6. Receipt (Pemindaian Struk)
**Services**
- `ReceiptService`
**ViewModels**
- `ReceiptViewModel`
**Views**
- `ReceiptScanPage`
- `ReceiptTextRecognizedPage`
- `ReceiptParsedPage`
- `ReceiptUploadPage`
**Models**
- `Receipt`
- `RecognizedText`