// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryFilterWidget extends StatefulWidget {
  final String selectedFilter;
  final String selectedPool;
  final DateTime? startDate;
  final DateTime? endDate;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<String> onPoolChanged;
  final Function(DateTime?, DateTime?) onDateRangeChanged;
  final VoidCallback onClearFilters;
  final List<String> filterOptions;
  final List<String> poolOptions;

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
    this.filterOptions = const ['Semua', 'Normal', 'Siaga', 'Waspada', 'Bahaya'],
    this.poolOptions = const ['Semua Pool', 'Pool A', 'Pool B', 'Pool C'],
  });

  @override
  State<HistoryFilterWidget> createState() => _HistoryFilterWidgetState();
}

class _HistoryFilterWidgetState extends State<HistoryFilterWidget> 
    with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    if (_isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: widget.startDate != null && widget.endDate != null
          ? DateTimeRange(start: widget.startDate!, end: widget.endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Colors.blue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      widget.onDateRangeChanged(picked.start, picked.end);
    }
  }

  String _formatDateRange() {
    if (widget.startDate == null || widget.endDate == null) {
      return 'Pilih Rentang Tanggal';
    }
    final formatter = DateFormat('dd MMM yyyy');
    return '${formatter.format(widget.startDate!)} - ${formatter.format(widget.endDate!)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpanded,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: colorScheme.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Filter Histori',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const Spacer(),
                    // Active filters indicator
                    if (_hasActiveFilters())
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getActiveFiltersCount().toString(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Expandable content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 16),
                  
                  // Status Filter
                  _buildFilterSection(
                    title: 'Status Banjir',
                    icon: Icons.warning_amber_rounded,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: widget.filterOptions.map((filter) {
                        final isSelected = widget.selectedFilter == filter;
                        return FilterChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (_) => widget.onFilterChanged(filter),
                          backgroundColor: colorScheme.surface,
                          selectedColor: colorScheme.primary.withOpacity(0.2),
                          checkmarkColor: colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected 
                                ? colorScheme.primary 
                                : colorScheme.onSurfaceVariant,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color: isSelected 
                                ? colorScheme.primary 
                                : colorScheme.outline.withOpacity(0.5),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Pool Filter
                  _buildFilterSection(
                    title: 'Lokasi Pool',
                    icon: Icons.location_on_rounded,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: widget.selectedPool,
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down, color: colorScheme.onSurfaceVariant),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface,
                          ),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              widget.onPoolChanged(newValue);
                            }
                          },
                          items: widget.poolOptions.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Date Range Filter
                  _buildFilterSection(
                    title: 'Rentang Tanggal',
                    icon: Icons.date_range_rounded,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _selectDateRange(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                          decoration: BoxDecoration(
                            border: Border.all(color: colorScheme.outline.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 18,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _formatDateRange(),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: widget.startDate != null && widget.endDate != null
                                        ? colorScheme.onSurface
                                        : colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                              if (widget.startDate != null && widget.endDate != null)
                                GestureDetector(
                                  onTap: () => widget.onDateRangeChanged(null, null),
                                  child: Icon(
                                    Icons.clear_rounded,
                                    size: 18,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: widget.onClearFilters,
                          icon: const Icon(Icons.clear_all_rounded, size: 18),
                          label: const Text('Reset Filter'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.onSurfaceVariant,
                            side: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _toggleExpanded(),
                          icon: const Icon(Icons.check_rounded, size: 18),
                          label: const Text('Terapkan'),
                          style: FilledButton.styleFrom(
                            backgroundColor: colorScheme.primary,
                            foregroundColor: colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  bool _hasActiveFilters() {
    return widget.selectedFilter != 'Semua' ||
           widget.selectedPool != 'Semua Pool' ||
           (widget.startDate != null && widget.endDate != null);
  }

  int _getActiveFiltersCount() {
    int count = 0;
    if (widget.selectedFilter != 'Semua') count++;
    if (widget.selectedPool != 'Semua Pool') count++;
    if (widget.startDate != null && widget.endDate != null) count++;
    return count;
  }
}