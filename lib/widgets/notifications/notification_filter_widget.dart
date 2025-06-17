// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class NotificationFilterWidget extends StatelessWidget {
  final String selectedFilter;
  final bool showUnreadOnly;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<bool> onUnreadToggle;
  final VoidCallback onClearAll;

  const NotificationFilterWidget({
    super.key,
    required this.selectedFilter,
    required this.showUnreadOnly,
    required this.onFilterChanged,
    required this.onUnreadToggle,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Filter Notifikasi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton(
                onPressed: onClearAll,
                child: const Text(
                  'Hapus Semua',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Toggle untuk unread only
          Row(
            children: [
              Checkbox(
                value: showUnreadOnly,
                onChanged: (value) => onUnreadToggle(value ?? false),
              ),
              const Text('Tampilkan hanya yang belum dibaca'),
            ],
          ),
          const SizedBox(height: 12),

          // Filter by type
          const Text(
            'Jenis Notifikasi:',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip(
                'Semua',
                'semua',
                Icons.notifications,
                Colors.blue,
              ),
              _buildFilterChip(
                'Sukses',
                'success',
                Icons.check_circle,
                Colors.green,
              ),
              _buildFilterChip(
                'Peringatan',
                'warning',
                Icons.warning,
                Colors.orange,
              ),
              _buildFilterChip('Info', 'info', Icons.info, Colors.blue),
              _buildFilterChip('Error', 'error', Icons.error, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    final isSelected = selectedFilter == value;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? color : Colors.grey),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onFilterChanged(value),
      backgroundColor: Colors.grey[100],
      selectedColor: color.withOpacity(0.1),
      checkmarkColor: color,
    );
  }
}
