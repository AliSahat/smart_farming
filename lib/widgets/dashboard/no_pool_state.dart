import 'package:flutter/material.dart';

class NoPoolStateWidget extends StatelessWidget {
  final VoidCallback onAddPoolPressed;

  const NoPoolStateWidget({super.key, required this.onAddPoolPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pool_outlined, size: 80, color: Colors.blue[200]),
            const SizedBox(height: 24),
            const Text(
              'Belum Ada Kolam',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Tambahkan kolam atau wadah pertama Anda untuk memulai monitoring.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onAddPoolPressed,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Tambah Kolam/Wadah Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
