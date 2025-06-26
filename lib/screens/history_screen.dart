// ignore_for_file: deprecated_member_use, unnecessary_string_interpolations, unused_local_variable, unused_element

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'semua';
  String _selectedPool = 'semua';
  DateTime? _startDate;
  DateTime? _endDate;

  // Data histori dummy - akan diganti dengan data real
  final List<HistoryItem> _historyData = [
    HistoryItem(
      id: '1',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      poolName: 'Aquarium',
      event: 'Kran dibuka otomatis',
      eventType: 'auto_open',
      waterLevel: 25.5,
      details: 'Level air di bawah batas minimum (30 cm)',
    ),
    HistoryItem(
      id: '2',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      poolName: 'Kolam Ikan',
      event: 'Kran ditutup manual',
      eventType: 'manual_close',
      waterLevel: 85.2,
      details: 'Pengguna menutup kran secara manual',
    ),
    HistoryItem(
      id: '3',
      timestamp: DateTime.now().subtract(const Duration(hours: 6)),
      poolName: 'Tangki Air',
      event: 'Pembuangan dibuka otomatis',
      eventType: 'auto_drain',
      waterLevel: 95.0,
      details: 'Level air melebihi batas maksimum (90%)',
    ),
    HistoryItem(
      id: '4',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      poolName: 'Aquarium',
      event: 'Sistem dimulai',
      eventType: 'system_start',
      waterLevel: 65.0,
      details: 'Sistem monitoring dimulai',
    ),
    HistoryItem(
      id: '5',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      poolName: 'Kolam Ikan',
      event: 'Peringatan level rendah',
      eventType: 'warning',
      waterLevel: 32.0,
      details: 'Level air mendekati batas minimum',
    ),
  ];

  List<HistoryItem> get _filteredHistory {
    List<HistoryItem> filtered = List.from(_historyData);

    // Filter by event type
    if (_selectedFilter != 'semua') {
      filtered = filtered.where((item) {
        switch (_selectedFilter) {
          case 'otomatis':
            return item.eventType.contains('auto');
          case 'manual':
            return item.eventType.contains('manual');
          case 'peringatan':
            return item.eventType == 'warning';
          case 'sistem':
            return item.eventType.contains('system');
          default:
            return true;
        }
      }).toList();
    }

    // Filter by pool
    if (_selectedPool != 'semua') {
      filtered = filtered
          .where(
            (item) => item.poolName.toLowerCase().contains(
              _selectedPool.toLowerCase(),
            ),
          )
          .toList();
    }

    // Filter by date range
    if (_startDate != null && _endDate != null) {
      filtered = filtered.where((item) {
        return item.timestamp.isAfter(_startDate!) &&
            item.timestamp.isBefore(_endDate!.add(const Duration(days: 1)));
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Histori Aktivitas',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2937),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                // Refresh data histori
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data histori diperbarui'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportHistory,
          ),
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _showDatePicker,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Section - Minimized
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row - Compact
                Row(
                  children: [
                    Icon(Icons.tune, color: Colors.blue, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Filter',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                      ),
                    ),
                    const Spacer(),
                    // Active filter indicator
                    if (_hasActiveFilters())
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _getActiveFilterCount().toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'semua';
                          _selectedPool = 'semua';
                          _startDate = null;
                          _endDate = null;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Compact Filters Row
                Row(
                  children: [
                    // Event Type - Simplified to just "Semua"
                    Expanded(
                      flex: 2, // Reduced flex since we only have one option
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jenis:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildCompactFilterChip('Semua Event', 'semua', true),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Pool Selection - Compact
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Kolam:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 28,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedPool,
                                isExpanded: true,
                                isDense: true,
                                icon: Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 14,
                                  color: Colors.grey[600],
                                ),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[800],
                                ),
                                onChanged: (String? newValue) {
                                  if (newValue != null) {
                                    setState(() {
                                      _selectedPool = newValue;
                                    });
                                  }
                                },
                                items: [
                                  _buildPoolDropdownItem('semua', 'Semua'),
                                  _buildPoolDropdownItem(
                                    'aquarium',
                                    'Aquarium',
                                  ),
                                  _buildPoolDropdownItem('kolam', 'Kolam'),
                                  _buildPoolDropdownItem('tangki', 'Tangki'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Date Range - Compact
                    GestureDetector(
                      onTap: _showDatePicker,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tanggal:',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: _startDate != null && _endDate != null
                                    ? Colors.blue
                                    : Colors.grey[300]!,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              color: _startDate != null && _endDate != null
                                  ? Colors.blue.withOpacity(0.1)
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.date_range,
                                  size: 12,
                                  color: _startDate != null && _endDate != null
                                      ? Colors.blue
                                      : Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _getCompactDateRange(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        _startDate != null && _endDate != null
                                        ? Colors.blue
                                        : Colors.grey[500],
                                    fontWeight:
                                        _startDate != null && _endDate != null
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // Date range display when selected - more compact
                if (_startDate != null && _endDate != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 12,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${DateFormat('dd/MM').format(_startDate!)} - ${DateFormat('dd/MM').format(_endDate!)}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _startDate = null;
                              _endDate = null;
                            });
                          },
                          child: Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Statistics Summary
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  'Total Event',
                  _filteredHistory.length.toString(),
                  Icons.list_alt,
                  Colors.blue,
                ),
                Container(height: 40, width: 1, color: Colors.grey[300]),
                _buildStatItem(
                  'Otomatis',
                  _filteredHistory
                      .where((h) => h.eventType.contains('auto'))
                      .length
                      .toString(),
                  Icons.auto_mode,
                  Colors.green,
                ),
                Container(height: 40, width: 1, color: Colors.grey[300]),
                _buildStatItem(
                  'Manual',
                  _filteredHistory
                      .where((h) => h.eventType.contains('manual'))
                      .length
                      .toString(),
                  Icons.touch_app,
                  Colors.orange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // History List
          Expanded(
            child: _filteredHistory.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        // Refresh data
                      });
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredHistory.length,
                      itemBuilder: (context, index) {
                        return _buildHistoryItem(_filteredHistory[index]);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[700],
    );
  }

  Widget _buildPoolChip(String label, String value) {
    final isSelected = _selectedPool == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedPool = value;
        });
      },
      backgroundColor: Colors.grey[100],
      selectedColor: Colors.green[100],
      checkmarkColor: Colors.green[700],
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(HistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => _showHistoryDetail(item),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                // Icon berdasarkan jenis event
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getEventColor(item.eventType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getEventIcon(item.eventType),
                    color: _getEventColor(item.eventType),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.event,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.poolName,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd/MM/yyyy HH:mm').format(item.timestamp),
                        style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),

                // Water level indicator
                Column(
                  children: [
                    Text(
                      '${item.waterLevel.toStringAsFixed(1)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _getEventColor(item.eventType),
                      ),
                    ),
                    Text(
                      'cm',
                      style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Tidak ada histori ditemukan',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Coba ubah filter atau rentang tanggal',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedFilter = 'semua';
                _selectedPool = 'semua';
                _startDate = null;
                _endDate = null;
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reset Filter'),
          ),
        ],
      ),
    );
  }

  IconData _getEventIcon(String eventType) {
    switch (eventType) {
      case 'auto_open':
        return Icons.water_drop;
      case 'auto_close':
        return Icons.block;
      case 'auto_drain':
        return Icons.cleaning_services;
      case 'manual_open':
        return Icons.touch_app;
      case 'manual_close':
        return Icons.pan_tool;
      case 'warning':
        return Icons.warning;
      case 'system_start':
        return Icons.power_settings_new;
      default:
        return Icons.info;
    }
  }

  Color _getEventColor(String eventType) {
    switch (eventType) {
      case 'auto_open':
      case 'auto_close':
      case 'auto_drain':
        return Colors.green;
      case 'manual_open':
      case 'manual_close':
        return Colors.blue;
      case 'warning':
        return Colors.orange;
      case 'system_start':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _showHistoryDetail(HistoryItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getEventColor(item.eventType).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getEventIcon(item.eventType),
                color: _getEventColor(item.eventType),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(item.event)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Kolam/Wadah', item.poolName),
            _buildDetailRow(
              'Waktu',
              DateFormat('dd/MM/yyyy HH:mm:ss').format(item.timestamp),
            ),
            _buildDetailRow(
              'Level Air',
              '${item.waterLevel.toStringAsFixed(1)} cm',
            ),
            _buildDetailRow('Jenis Event', _getEventTypeName(item.eventType)),
            _buildDetailRow('Detail', item.details),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _shareHistoryItem(item);
            },
            child: const Text('Bagikan'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  String _getEventTypeName(String eventType) {
    switch (eventType) {
      case 'auto_open':
        return 'Buka Otomatis';
      case 'auto_close':
        return 'Tutup Otomatis';
      case 'auto_drain':
        return 'Buang Otomatis';
      case 'manual_open':
        return 'Buka Manual';
      case 'manual_close':
        return 'Tutup Manual';
      case 'warning':
        return 'Peringatan';
      case 'system_start':
        return 'Sistem Mulai';
      default:
        return 'Lainnya';
    }
  }

  void _showDatePicker() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  void _shareHistoryItem(HistoryItem item) {
    final text =
        '''
Event: ${item.event}
Kolam: ${item.poolName}
Waktu: ${DateFormat('dd/MM/yyyy HH:mm').format(item.timestamp)}
Level Air: ${item.waterLevel.toStringAsFixed(1)} cm
Detail: ${item.details}
    ''';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Data histori: ${item.event}'),
        action: SnackBarAction(
          label: 'Copy',
          onPressed: () {
            // Implement copy to clipboard
          },
        ),
      ),
    );
  }

  void _exportHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ekspor Histori'),
        content: const Text('Pilih format ekspor:'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportAsCSV();
            },
            child: const Text('CSV'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _exportAsJSON();
            },
            child: const Text('JSON'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
        ],
      ),
    );
  }

  void _exportAsCSV() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ekspor CSV akan segera tersedia'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _exportAsJSON() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ekspor JSON akan segera tersedia'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildCompactFilterChip(String label, String value, bool isEventType) {
    final isSelected = _selectedFilter == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = value;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? Colors.blue : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  DropdownMenuItem<String> _buildPoolDropdownItem(String value, String label) {
    return DropdownMenuItem<String>(
      value: value,
      child: Text(
        label,
        style: const TextStyle(fontSize: 11),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  String _getCompactDateRange() {
    if (_startDate == null || _endDate == null) {
      return 'Pilih';
    }
    return '${DateFormat('dd/MM').format(_startDate!)}-${DateFormat('dd/MM').format(_endDate!)}';
  }

  bool _hasActiveFilters() {
    return _selectedFilter != 'semua' ||
        _selectedPool != 'semua' ||
        (_startDate != null && _endDate != null);
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedFilter != 'semua') count++;
    if (_selectedPool != 'semua') count++;
    if (_startDate != null && _endDate != null) count++;
    return count;
  }
}

// Model untuk History Item - dipindah ke dalam file ini
class HistoryItem {
  final String id;
  final DateTime timestamp;
  final String poolName;
  final String event;
  final String eventType;
  final double waterLevel;
  final String details;

  HistoryItem({
    required this.id,
    required this.timestamp,
    required this.poolName,
    required this.event,
    required this.eventType,
    required this.waterLevel,
    required this.details,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'poolName': poolName,
      'event': event,
      'eventType': eventType,
      'waterLevel': waterLevel,
      'details': details,
    };
  }

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      poolName: json['poolName'],
      event: json['event'],
      eventType: json['eventType'],
      waterLevel: json['waterLevel'].toDouble(),
      details: json['details'],
    );
  }
}
