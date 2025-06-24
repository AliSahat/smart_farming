// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class NotificationFilterWidget extends StatefulWidget {
  final String selectedFilter;
  final bool showUnreadOnly;
  final ValueChanged<String> onFilterChanged;
  final ValueChanged<bool> onUnreadToggle;
  final VoidCallback onClearAll;
  final int unreadCount;
  final bool isExpanded;

  const NotificationFilterWidget({
    super.key,
    required this.selectedFilter,
    required this.showUnreadOnly,
    required this.onFilterChanged,
    required this.onUnreadToggle,
    required this.onClearAll,
    this.unreadCount = 0,
    this.isExpanded = true,
  });

  @override
  State<NotificationFilterWidget> createState() => _NotificationFilterWidgetState();
}

class _NotificationFilterWidgetState extends State<NotificationFilterWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _expandAnimation;
  bool _isExpanded = true;

  final List<FilterOption> _filterOptions = [
    FilterOption('Semua', 'semua', Icons.notifications, Colors.blue),
    FilterOption('Berhasil', 'success', Icons.check_circle, Colors.green),
    FilterOption('Peringatan', 'warning', Icons.warning, Colors.orange),
    FilterOption('Informasi', 'info', Icons.info, Colors.blue),
    FilterOption('Error', 'error', Icons.error, Colors.red),
  ];

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[850] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header yang bisa diklik untuk expand/collapse
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggleExpanded,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.tune,
                      color: theme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Filter Notifikasi',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (widget.unreadCount > 0) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${widget.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.expand_more,
                        color: theme.hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Content yang bisa expand/collapse
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                children: [
                  // Divider
                  Divider(
                    height: 1,
                    color: isDark ? Colors.grey[700] : Colors.grey[200],
                  ),
                  const SizedBox(height: 12),

                  // Controls row
                  Row(
                    children: [
                      // Unread toggle dengan style yang lebih baik
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => widget.onUnreadToggle(!widget.showUnreadOnly),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: widget.showUnreadOnly
                                    ? theme.primaryColor.withOpacity(0.1)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: widget.showUnreadOnly
                                      ? theme.primaryColor
                                      : Colors.transparent,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    widget.showUnreadOnly
                                        ? Icons.check_box
                                        : Icons.check_box_outline_blank,
                                    color: widget.showUnreadOnly
                                        ? theme.primaryColor
                                        : theme.hintColor,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Belum dibaca saja',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: widget.showUnreadOnly
                                          ? theme.primaryColor
                                          : theme.textTheme.bodyMedium?.color,
                                      fontWeight: widget.showUnreadOnly
                                          ? FontWeight.w500
                                          : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      // Clear all button dengan style yang lebih baik
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: widget.onClearAll,
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.clear_all,
                                  color: Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'Hapus Semua',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Filter chips dengan design yang lebih modern
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _filterOptions.map((option) {
                      return _buildModernFilterChip(option, theme);
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFilterChip(FilterOption option, ThemeData theme) {
    final isSelected = widget.selectedFilter == option.value;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onFilterChanged(option.value),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? option.color.withOpacity(0.15)
                : (isDark ? Colors.grey[800] : Colors.grey[50]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? option.color
                  : (isDark ? Colors.grey[600]! : Colors.grey[300]!),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                option.icon,
                size: 16,
                color: isSelected
                    ? option.color
                    : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
              const SizedBox(width: 8),
              Text(
                option.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected
                      ? option.color
                      : (isDark ? Colors.grey[300] : Colors.grey[700]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterOption {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const FilterOption(this.label, this.value, this.icon, this.color);
}