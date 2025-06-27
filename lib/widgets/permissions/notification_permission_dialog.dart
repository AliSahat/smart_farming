import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionHelper {
  static Future<void> checkAndRequestPermission(BuildContext context) async {
    final status = await Permission.notification.status;

    if (status.isDenied) {
      // Show dialog explaining why notification permission is needed
      // ignore: use_build_context_synchronously
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Izin Notifikasi'),
            content: const Text(
              'Aplikasi ini memerlukan izin notifikasi untuk memberi tahu Anda '
              'tentang perubahan status sistem pertanian, seperti level air, '
              'status katup, dan peringatan penting lainnya.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Permission.notification.request();
                },
                child: const Text('Berikan Izin'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Nanti Saja'),
              ),
            ],
          ),
        );
      }
    } else if (status.isPermanentlyDenied) {
      // Show dialog to open app settings
      // ignore: use_build_context_synchronously
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Izin Notifikasi Ditolak'),
            content: const Text(
              'Izin notifikasi telah ditolak secara permanen. '
              'Buka pengaturan aplikasi untuk mengaktifkan notifikasi.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  openAppSettings();
                },
                child: const Text('Buka Pengaturan'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
            ],
          ),
        );
      }
    }
  }
}
