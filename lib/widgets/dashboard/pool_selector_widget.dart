import 'package:flutter/material.dart';
import '../../models/pool_model.dart';
import '../../data/pool_data.dart';

class PoolSelectorWidget extends StatelessWidget {
  final Map<String, Pool> poolSettings;
  final String selectedPoolKey;
  final ValueChanged<String> onPoolSelected;
  final VoidCallback onAddPoolTapped;

  const PoolSelectorWidget({
    super.key,
    required this.poolSettings,
    required this.selectedPoolKey,
    required this.onPoolSelected,
    required this.onAddPoolTapped,
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
            // Header
            _buildHeader(context),
            const SizedBox(height: 16),

            // Pool Cards
            _buildPoolCards(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 400) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.pool, color: Colors.blue[600], size: 24),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Pilih Kolam/Wadah',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAddPoolTapped,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Tambah Kolam/Wadah'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          );
        } else {
          return Row(
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
              ElevatedButton.icon(
                onPressed: onAddPoolTapped,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Tambah'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildPoolCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (poolSettings.isEmpty) {
          return _buildEmptyState();
        }

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
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.pool, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada kolam/wadah',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan kolam atau wadah pertama Anda',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
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
          padding: const EdgeInsets.all(16),
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
          child: _buildCardContent(pool, isSelected),
        ),
      ),
    );
  }

  Widget _buildCardContent(Pool pool, bool isSelected) {
    return Row(
      children: [
        Icon(
          PoolData.getPoolIcon(pool.name),
          size: 28,
          color: isSelected ? Colors.blue[600] : Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                pool.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: isSelected ? Colors.blue[800] : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${pool.depth.toStringAsFixed(0)} cm',
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.blue[600] : Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
        if (isSelected)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Aktif',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }
}
