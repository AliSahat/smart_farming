// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryItemWidget extends StatelessWidget {
  final dynamic historyItem; // Gunakan dynamic untuk sementara
  final VoidCallback onTap;

  const HistoryItemWidget({
    super.key,
    required this.historyItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: const Row(
              children: [
                // Widget implementation
                Text('History Item'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
