# Agro-AHP Pro
**Microservices-Based Maintenance Decision System**

## Identitas Mahasiswa
- **Nama**: [Nama Mahasiswa]
- **NIM**: [NIM Mahasiswa]
- **Jurusan**: Teknik Informatika / Sistem Informasi

## Deskripsi Kasus
Proyek ini bertujuan untuk menyelesaikan masalah prioritization perawatan mesin di pabrik agroindustri (TIP Holding Company). Menggunakan metode **AHP (Analytic Hierarchy Process)**, sistem ini membantu manajer memutuskan mesin mana yang harus diperbaiki terlebih dahulu berdasarkan kriteria yang ditentukan (Biaya, Kualitas, Waktu, dll).

## Arsitektur Sistem
- **Frontend**: Flutter (Mobile Application).
- **Backend**: Python Flask (AHP Computation Engine).
- **Config Bridge**: GitHub Gist (Menyimpan URL Ngrok).

## Link Penting
- **Google Colab (Backend)**: [Link Colab Anda Disini]
- **GitHub Gist (Config)**: [Link Gist Anda Disini]
- **Demo Aplikasi**: [Link Vercel/APK Disini]

## Cara Menjalankan

### Backend
1. Masuk ke folder `backend`.
2. Install requirements:
   ```bash
   pip install -r requirements.txt
   ```
3. Jalankan server:
   ```bash
   python app.py
   ```
   Atau gunakan Google Colab jika ingin menggunakan tunnel Ngrok secara awan.

### Frontend
1. Masuk ke folder `frontend`.
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Jalankan aplikasi:
   ```bash
   flutter run
   ```

## Fitur Utama
1. **Setup Kriteria**: Input dinamis jumlah dan nama kriteria.
2. **Pairwise Comparison**: Menggunakan slider intuitif (Skala Saaty 1-9).
3. **Analisis Real-time**: Komputasi Eigenvector dilakukan di server Python.
4. **Visualisasi**: Grafik hasil prioritas.
