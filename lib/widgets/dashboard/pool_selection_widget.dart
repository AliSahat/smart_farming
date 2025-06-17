// lib/widgets/dashboard/pool_selection_widget.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../../models/pool_model.dart';

class PoolSelectionWidget extends StatelessWidget {
  final Map<String, Pool> poolSettings;
  final String selectedPoolKey;
  final ValueChanged<String> onPoolSelected;

  const PoolSelectionWidget({
    super.key,
    required this.poolSettings,
    required this.selectedPoolKey,
    required this.onPoolSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header sederhana tanpa indikator "klik"
            Row(
              children: [
                Icon(Icons.pool, color: Colors.blue[600], size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Pilih Kolam/Wadah',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Pool Cards dengan layout responsif
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth > 768) {
                  // Desktop - 3 kolom horizontal
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: poolSettings.entries.map((entry) {
                        return Container(
                          width: constraints.maxWidth / 3 - 8,
                          margin: const EdgeInsets.only(right: 12),
                          child: _buildPoolCard(entry.key, entry.value),
                        );
                      }).toList(),
                    ),
                  );
                } else if (constraints.maxWidth > 480) {
                  // Tablet - 2 kolom grid
                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 2.2,
                    children: poolSettings.entries.map((entry) {
                      return _buildPoolCard(entry.key, entry.value);
                    }).toList(),
                  );
                } else {
                  // Mobile - 1 kolom vertikal
                  return Column(
                    children: poolSettings.entries.map((entry) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: _buildPoolCard(entry.key, entry.value),
                      );
                    }).toList(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPoolCard(String key, Pool pool) {
    final isSelected = key == selectedPoolKey;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: () => onPoolSelected(key),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [
                      Colors.blue[500]!.withOpacity(0.1),
                      Colors.blue[300]!.withOpacity(0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue[400]! : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 120) {
                // Sangat sempit - layout minimal
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getPoolIcon(pool.name),
                      size: 24,
                      color: isSelected ? Colors.blue[600] : Colors.grey[600],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      pool.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                        color: isSelected ? Colors.blue[800] : Colors.grey[700],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                  ],
                );
              } else {
                // Layout normal
                return Stack(
                  children: [
                    Row(
                      children: [
                        Icon(
                          _getPoolIcon(pool.name),
                          size: 28,
                          color: isSelected
                              ? Colors.blue[600]
                              : Colors.grey[600],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                pool.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: isSelected
                                      ? Colors.blue[800]
                                      : Colors.grey[700],
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${pool.depth.toStringAsFixed(0)} cm',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isSelected
                                      ? Colors.blue[600]
                                      : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // Indikator terpilih
                    if (isSelected)
                      Positioned(
                        top: -8,
                        right: -8,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.blue[600],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  IconData _getPoolIcon(String poolName) {
    if (poolName.toLowerCase().contains('ikan')) {
      return Icons.set_meal;
    } else if (poolName.toLowerCase().contains('aquarium')) {
      return Icons.waves;
    } else if (poolName.toLowerCase().contains('tangki')) {
      return Icons.water_drop;
    }
    return Icons.pool;
  }
}
