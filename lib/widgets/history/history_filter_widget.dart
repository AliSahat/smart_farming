import 'package:flutter/material.dart';

class HistoryFilterWidget extends StatelessWidget {
  final String selectedFilter;
  final String selectedPool;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onPoolChanged;
  final Function(DateTime?, DateTime?) onDateRangeChanged;
  final VoidCallback onClearFilters;

  const HistoryFilterWidget({
    super.key,
    required this.selectedFilter,
    required this.selectedPool,
    required this.startDate,
    required this.endDate,
    required this.onFilterChanged,
    required this.onPoolChanged,
    required this.onDateRangeChanged,
    required this.onClearFilters,
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
                'Filter Histori',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              TextButton(onPressed: onClearFilters, child: const Text('Reset')),
            ],
          ),
          const SizedBox(height: 16),

          // Filter content goes here
          // ... implementation sama seperti di history_screen.dart
        ],
      ),
    );
  }
}
