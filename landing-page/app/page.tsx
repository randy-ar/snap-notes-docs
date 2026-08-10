import React from "react"
import Image from "next/image"
import { Camera, Sparkles, PieChart, Download, ArrowRight, Check, ShieldCheck, Code2 } from "lucide-react"

function GithubIcon({ className = "w-4 h-4" }: { className?: string }) {
  return (
    <svg
      className={className}
      fill="currentColor"
      viewBox="0 0 24 24"
      aria-hidden="true"
    >
      <path
        fillRule="evenodd"
        clipRule="evenodd"
        d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.53 1.032 1.53 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z"
      />
    </svg>
  )
}

export default function Page() {
  return (
    <div className="min-h-screen bg-white text-slate-900 flex flex-col font-sans selection:bg-slate-900 selection:text-white">
      {/* Navbar */}
      <header className="border-b border-slate-100 bg-white/80 backdrop-blur-md sticky top-0 z-50">
        <div className="max-w-5xl mx-auto px-6 h-16 flex items-center justify-between">
          <div className="flex items-center gap-3 font-semibold text-lg tracking-tight">
            <Image
              src="/logo.png"
              alt="Snap Notes Logo"
              width={32}
              height={32}
              className="rounded-lg object-contain"
            />
            <span>Snap Notes</span>
          </div>

          <nav className="hidden md:flex items-center gap-8 text-sm font-medium text-slate-600">
            <a href="#fitur" className="hover:text-slate-900 transition-colors">Fitur</a>
            <a href="#cara-kerja" className="hover:text-slate-900 transition-colors">Cara Kerja</a>
            <a href="#open-source" className="hover:text-slate-900 transition-colors">Open Source</a>
            <a href="#faq" className="hover:text-slate-900 transition-colors">FAQ</a>
          </nav>

          <div className="flex items-center gap-2">
            <a
              href="https://github.com/randy-ar/snap-notes-docs"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center justify-center p-2 rounded-md border border-slate-200 text-slate-700 hover:bg-slate-50 transition-colors"
              aria-label="GitHub Repository"
            >
              <GithubIcon className="w-4 h-4" />
            </a>
            <a
              href="#download"
              className="inline-flex items-center justify-center gap-2 px-4 py-2 text-xs font-medium rounded-md bg-slate-900 text-white hover:bg-slate-800 transition-colors"
            >
              <Download className="w-3.5 h-3.5" />
              <span>Unduh APK</span>
            </a>
          </div>
        </div>
      </header>

      <main className="flex-1">
        {/* Hero */}
        <section className="py-24 px-6 text-center max-w-4xl mx-auto space-y-8">
          <div className="inline-flex items-center gap-2 px-3 py-1 rounded-full border border-slate-200 bg-slate-50 text-xs font-medium text-slate-600">
            <Sparkles className="w-3.5 h-3.5 text-slate-700" />
            <span>Pencatatan Keuangan Berbasis OCR & AI</span>
          </div>

          <h1 className="text-4xl sm:text-6xl font-semibold tracking-tight leading-tight text-slate-900">
            Catat pengeluaran otomatis <br />
            hanya dengan foto struk.
          </h1>

          <p className="text-base sm:text-lg text-slate-600 max-w-2xl mx-auto leading-relaxed">
            Snap Notes mengekstrak detail transaksi dari nota belanja secara otomatis menggunakan Google ML Kit dan Gemini AI. Praktis dan efisien.
          </p>

          <div className="pt-2 flex flex-col sm:flex-row items-center justify-center gap-3">
            <a
              href="#download"
              className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-6 py-3 text-sm font-medium rounded-md bg-slate-900 text-white hover:bg-slate-800 transition-colors"
            >
              <Download className="w-4 h-4" />
              <span>Unduh APK Production</span>
            </a>
            <a
              href="https://github.com/randy-ar/snap-notes-docs"
              target="_blank"
              rel="noopener noreferrer"
              className="w-full sm:w-auto inline-flex items-center justify-center gap-2 px-6 py-3 text-sm font-medium rounded-md border border-slate-200 bg-white text-slate-700 hover:bg-slate-50 transition-colors"
            >
              <GithubIcon className="w-4 h-4" />
              <span>Source Code</span>
            </a>
          </div>
        </section>

        {/* Minimal Stats / Highlights */}
        <section className="border-y border-slate-100 py-10 bg-slate-50/50">
          <div className="max-w-4xl mx-auto px-6 grid grid-cols-1 md:grid-cols-3 gap-6 text-center">
            <div className="space-y-1">
              <p className="text-2xl font-semibold text-slate-900">Otomatis</p>
              <p className="text-xs text-slate-500">Ekstraksi teks tanpa input manual</p>
            </div>
            <div className="space-y-1">
              <p className="text-2xl font-semibold text-slate-900">Akurat</p>
              <p className="text-xs text-slate-500">Didukung Google ML Kit & Gemini</p>
            </div>
            <div className="space-y-1">
              <p className="text-2xl font-semibold text-slate-900">Open Source</p>
              <p className="text-xs text-slate-500">Transparan & terbuka untuk berkontribusi</p>
            </div>
          </div>
        </section>

        {/* Features */}
        <section id="fitur" className="py-24 px-6 max-w-5xl mx-auto space-y-16">
          <div className="text-center space-y-2">
            <h2 className="text-2xl font-semibold tracking-tight text-slate-900">Fitur Utama</h2>
            <p className="text-sm text-slate-500 max-w-md mx-auto">
              Semua yang Anda butuhkan untuk mengelola catatan transaksi harian.
            </p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="p-6 rounded-lg border border-slate-100 bg-white space-y-3">
              <div className="w-10 h-10 rounded-md bg-slate-100 flex items-center justify-center text-slate-800">
                <Camera className="w-5 h-5" />
              </div>
              <h3 className="text-base font-semibold text-slate-900">Scan Struk Instan</h3>
              <p className="text-xs text-slate-500 leading-relaxed">
                Pindai struk fisik dengan kamera HP Anda untuk mengambil data transaksi secara cepat.
              </p>
            </div>

            <div className="p-6 rounded-lg border border-slate-100 bg-white space-y-3">
              <div className="w-10 h-10 rounded-md bg-slate-100 flex items-center justify-center text-slate-800">
                <Sparkles className="w-5 h-5" />
              </div>
              <h3 className="text-base font-semibold text-slate-900">Kategori AI</h3>
              <p className="text-xs text-slate-500 leading-relaxed">
                Mengelompokkan barang belanjaan ke dalam kategori pengeluaran yang sesuai secara otomatis.
              </p>
            </div>

            <div className="p-6 rounded-lg border border-slate-100 bg-white space-y-3">
              <div className="w-10 h-10 rounded-md bg-slate-100 flex items-center justify-center text-slate-800">
                <PieChart className="w-5 h-5" />
              </div>
              <h3 className="text-base font-semibold text-slate-900">Ringkasan Keuangan</h3>
              <p className="text-xs text-slate-500 leading-relaxed">
                Visualisasi ringkas pengeluaran harian dan bulanan tanpa kerumitan.
              </p>
            </div>
          </div>
        </section>

        {/* How it Works */}
        <section id="cara-kerja" className="py-20 px-6 bg-slate-50/60 border-y border-slate-100">
          <div className="max-w-4xl mx-auto space-y-12">
            <div className="text-center space-y-2">
              <h2 className="text-2xl font-semibold tracking-tight text-slate-900">Cara Kerja</h2>
              <p className="text-sm text-slate-500">Tiga langkah sederhana memulai pencatatan.</p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              <div className="space-y-2">
                <span className="text-xs font-semibold text-slate-400 font-mono">01</span>
                <h3 className="text-base font-semibold text-slate-900">Ambil Foto</h3>
                <p className="text-xs text-slate-500 leading-relaxed">Foto atau pilih gambar struk belanjaan dari galeri perangkat Anda.</p>
              </div>

              <div className="space-y-2">
                <span className="text-xs font-semibold text-slate-400 font-mono">02</span>
                <h3 className="text-base font-semibold text-slate-900">Ekstraksi Data</h3>
                <p className="text-xs text-slate-500 leading-relaxed">Sistem OCR & AI memproses teks struk menjadi format data terstruktur.</p>
              </div>

              <div className="space-y-2">
                <span className="text-xs font-semibold text-slate-400 font-mono">03</span>
                <h3 className="text-base font-semibold text-slate-900">Konfirmasi & Simpan</h3>
                <p className="text-xs text-slate-500 leading-relaxed">Periksa kembali data transaksi lalu simpan ke catatan keuangan Anda.</p>
              </div>
            </div>
          </div>
        </section>

        {/* Open Source / GitHub Section */}
        <section id="open-source" className="py-20 px-6 max-w-4xl mx-auto text-center space-y-6">
          <div className="w-12 h-12 rounded-full bg-slate-100 mx-auto flex items-center justify-center text-slate-800">
            <Code2 className="w-6 h-6" />
          </div>
          <div className="space-y-2">
            <h2 className="text-2xl font-semibold tracking-tight text-slate-900">Transparan & Open Source</h2>
            <p className="text-sm text-slate-500 max-w-xl mx-auto leading-relaxed">
              Kode sumber aplikasi ini dapat diakses secara terbuka di GitHub. Anda dapat memeriksa arsitektur kode, melaporkan isu, atau berkontribusi dalam pengembangannya.
            </p>
          </div>
          <div>
            <a
              href="https://github.com/randy-ar/snap-notes-docs"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center justify-center gap-2 px-5 py-2.5 text-xs font-medium rounded-md border border-slate-200 bg-white text-slate-800 hover:bg-slate-50 transition-colors"
            >
              <GithubIcon className="w-4 h-4" />
              <span>Lihat di GitHub</span>
            </a>
          </div>
        </section>

        {/* Download Section */}
        <section id="download" className="py-24 px-6 max-w-3xl mx-auto text-center space-y-6">
          <div className="p-10 rounded-xl border border-slate-200 bg-white space-y-6">
            <div className="space-y-2">
              <h2 className="text-2xl sm:text-3xl font-semibold tracking-tight text-slate-900">Unduh Snap Notes</h2>
              <p className="text-sm text-slate-500 max-w-md mx-auto">
                Dapatkan aplikasi Snap Notes versi produksi (APK) untuk perangkat Android.
              </p>
            </div>

            <div className="pt-2">
              <a
                href="/snap-notes.apk"
                download
                className="inline-flex items-center justify-center gap-2 px-6 py-3 text-sm font-medium rounded-md bg-slate-900 text-white hover:bg-slate-800 transition-colors"
              >
                <Download className="w-4 h-4" />
                <span>Unduh File APK</span>
              </a>
            </div>

            <div className="flex flex-wrap items-center justify-center gap-6 text-xs text-slate-500 pt-2 border-t border-slate-100">
              <div className="flex items-center gap-1.5">
                <Check className="w-3.5 h-3.5 text-slate-700" />
                <span>Android 8.0+</span>
              </div>
              <div className="flex items-center gap-1.5">
                <Check className="w-3.5 h-3.5 text-slate-700" />
                <span>Bebas Iklan</span>
              </div>
              <div className="flex items-center gap-1.5">
                <ShieldCheck className="w-3.5 h-3.5 text-slate-700" />
                <span>Aman Terverifikasi</span>
              </div>
            </div>
          </div>
        </section>

        {/* FAQ */}
        <section id="faq" className="py-16 px-6 border-t border-slate-100 max-w-3xl mx-auto space-y-8">
          <h2 className="text-xl font-semibold tracking-tight text-center text-slate-900">Pertanyaan Sering Diajukan</h2>
          <div className="space-y-4">
            <div className="p-4 rounded-lg border border-slate-100 bg-slate-50/50 space-y-1">
              <h3 className="text-sm font-semibold text-slate-900">Apakah aplikasi ini gratis?</h3>
              <p className="text-xs text-slate-500">Ya, Snap Notes sepenuhnya gratis untuk penggunaan personal.</p>
            </div>
            <div className="p-4 rounded-lg border border-slate-100 bg-slate-50/50 space-y-1">
              <h3 className="text-sm font-semibold text-slate-900">Bagaimana cara berkontribusi di GitHub?</h3>
              <p className="text-xs text-slate-500">Kunjungi repository GitHub kami, buat issue jika menemukan bug, atau ajukan Pull Request untuk penambahan fitur.</p>
            </div>
            <div className="p-4 rounded-lg border border-slate-100 bg-slate-50/50 space-y-1">
              <h3 className="text-sm font-semibold text-slate-900">Bagaimana cara menginstal APK?</h3>
              <p className="text-xs text-slate-500">Unduh file APK di atas, buka di perangkat Android Anda, lalu izinkan instalasi dari sumber tidak dikenal jika diminta.</p>
            </div>
          </div>
        </section>
      </main>

      {/* Footer */}
      <footer className="border-t border-slate-100 py-8 text-center text-xs text-slate-400">
        <div className="max-w-5xl mx-auto px-6 space-y-2">
          <div className="flex items-center justify-center gap-4">
            <a
              href="https://github.com/randy-ar/snap-notes-docs"
              target="_blank"
              rel="noopener noreferrer"
              className="inline-flex items-center gap-1.5 hover:text-slate-600 transition-colors"
            >
              <GithubIcon className="w-3.5 h-3.5" />
              <span>GitHub Repository</span>
            </a>
          </div>
          <p>© {new Date().getFullYear()} Snap Notes.</p>
        </div>
      </footer>
    </div>
  )
}
