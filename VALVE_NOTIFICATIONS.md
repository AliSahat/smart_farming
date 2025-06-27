# Dokumentasi Fitur Notifikasi Valve/Keran

## Fitur yang Diimplementasi

### 1. Helper Function untuk Notifikasi Valve
Telah dibuat fungsi `_addValveNotification()` yang memberikan notifikasi khusus untuk status valve dengan format yang konsisten:

```dart
void _addValveNotification(bool isOpen, String contextInfo, {String type = 'info'})
```

#### Format Notifikasi:
- **Title**: "Status Keran/Valve"
- **Message**: "[🟢/🔴] Keran [TERBUKA/TERTUTUP] (Context) - [Nama Pool]"
- **Icon**: 🟢 untuk terbuka, 🔴 untuk tertutup
- **Type**: 'info', 'warning', 'error', atau 'success'

### 2. Notifikasi untuk Berbagai Skenario

#### A. Manual Control
- **Toggle Valve Manual**: Ketika user mengklik tombol valve secara manual
  - Terbuka: Type 'warning' (karena bisa berbahaya)
  - Tertutup: Type 'info'

#### B. Automatic Mode
- **Fill Mode (Mode Pengisian)**:
  - Valve ditutup otomatis saat mode pengisian aktif
  - Context: "Mode Pengisian"
  - Type: 'info'

- **Drain Mode (Mode Pengosongan)**:
  - Valve dibuka saat drain mode aktif
  - Valve ditutup saat drain mode dinonaktifkan
  - Context: "Mode Pengosongan" / "Mode Pengosongan Off"
  - Type: 'warning' untuk buka, 'info' untuk tutup

#### C. Emergency Stop
- **Emergency Stop**: 
  - Valve dipaksa tutup
  - Context: "Emergency Stop"
  - Type: 'error'

#### D. Automatic Water Level Control (dari PoolProvider)
Sudah tersedia di `pool_provider.dart`:
- Level air rendah → Valve dibuka otomatis
- Level air tinggi → Drain dibuka 
- Level air normal → Sistem standby

### 3. Tombol Test Notifikasi
Ditambahkan tombol "Test Notifikasi Valve" yang akan mengirimkan serangkaian notifikasi test untuk berbagai skenario:

1. Manual Open (warning)
2. Manual Close (info) 
3. Auto Open - Level Rendah (warning)
4. Auto Close - Level Normal (success)
5. Emergency Close (error)

### 4. Konsistensi Notifikasi

#### Tipe Notifikasi berdasarkan Risiko:
- **ERROR** (🔴): Emergency stop, sistem failure
- **WARNING** (🟠): Valve terbuka (manual/auto), kondisi yang perlu perhatian
- **INFO** (🔵): Valve tertutup normal, mode changes
- **SUCCESS** (🟢): Sistem kembali normal, level air optimal

#### Context Information:
- "Manual Control" - Kontrol langsung oleh user
- "Mode Pengisian" - Saat fill mode aktif
- "Mode Pengosongan" - Saat drain mode aktif/deaktif
- "Emergency Stop" - Stop darurat
- "Auto - Level Rendah/Tinggi" - Kontrol otomatis berdasarkan sensor

### 5. Fitur Keamanan
- **Safety Timer**: Sistem akan otomatis menutup valve jika terbuka terlalu lama (dari PoolProvider)
- **Emergency Override**: Tombol stop darurat akan menutup semua valve dan mengirim notifikasi error
- **Pool Context**: Setiap notifikasi mencantumkan nama pool yang terkait

## Cara Testing

1. **Manual Testing**:
   - Klik tombol valve di dashboard
   - Aktifkan/deaktifkan fill mode
   - Aktifkan/deaktifkan drain mode
   - Tekan emergency stop

2. **Automatic Testing**:
   - Klik tombol "Test Notifikasi Valve"
   - Akan mengirim 5 notifikasi dengan delay untuk simulasi berbagai kondisi

3. **Integration Testing**:
   - Ubah level air pool secara manual di simulator
   - Sistem akan otomatis mengontrol valve dan mengirim notifikasi

## Benefits

1. **User Awareness**: User selalu tahu status valve real-time
2. **Safety**: Notifikasi peringatan untuk kondisi berbahaya
3. **Traceability**: History lengkap semua perubahan status valve
4. **Context Rich**: Setiap notifikasi memberikan informasi lengkap kenapa valve berubah
5. **Visual Feedback**: Icon dan warna yang jelas untuk status terbuka/tertutup
