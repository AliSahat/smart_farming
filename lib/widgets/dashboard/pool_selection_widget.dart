// lib/widgets/dashboard/pool_selection_widget.dart
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/pool_model.dart';

class PoolSelectionWidget extends StatefulWidget {
  final Map<String, Pool> poolSettings;
  final String selectedPoolKey;
  final ValueChanged<String> onPoolSelected;
  final Function(String key, Pool pool) onPoolAdded;
  final Function(String key) onPoolRemoved;

  const PoolSelectionWidget({
    super.key,
    required this.poolSettings,
    required this.selectedPoolKey,
    required this.onPoolSelected,
    required this.onPoolAdded,
    required this.onPoolRemoved,
  });

  @override
  State<PoolSelectionWidget> createState() => _PoolSelectionWidgetState();
}

class _PoolSelectionWidgetState extends State<PoolSelectionWidget> {
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
            // Header dengan tombol tambah - responsive
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 400) {
                  // Layout vertikal untuk mobile kecil
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.pool, color: Colors.blue[600], size: 24),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Kelola Kolam/Wadah',
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
                          onPressed: _showAddPoolDialog,
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
                  // Layout horizontal untuk tablet/desktop
                  return Row(
                    children: [
                      Icon(Icons.pool, color: Colors.blue[600], size: 24),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Kelola Kolam/Wadah',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showAddPoolDialog,
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
            ),
            const SizedBox(height: 16),

            // Pool Cards dengan layout responsif
            LayoutBuilder(
              builder: (context, constraints) {
                if (widget.poolSettings.isEmpty) {
                  return _buildEmptyState();
                }

                if (constraints.maxWidth > 768) {
                  // Desktop - 3 kolom horizontal
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: widget.poolSettings.entries.map((entry) {
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
                    children: widget.poolSettings.entries.map((entry) {
                      return _buildPoolCard(entry.key, entry.value);
                    }).toList(),
                  );
                } else {
                  // Mobile - 1 kolom vertikal
                  return Column(
                    children: widget.poolSettings.entries.map((entry) {
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
    final isSelected = key == widget.selectedPoolKey;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: InkWell(
        onTap: () => widget.onPoolSelected(key),
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth < 140) {
                // Layout vertikal untuk card sangat kecil
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header dengan icon dan tombol hapus
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          _getPoolIcon(pool.name),
                          size: 24,
                          color: isSelected
                              ? Colors.blue[600]
                              : Colors.grey[600],
                        ),
                        GestureDetector(
                          onTap: () => _showDeleteConfirmation(key, pool.name),
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.red[600],
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Nama kolam
                    Text(
                      pool.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        color: isSelected ? Colors.blue[800] : Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Kedalaman
                    Text(
                      '${pool.depth.toStringAsFixed(0)} cm',
                      style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.blue[600] : Colors.grey[500],
                      ),
                    ),
                    // Indikator terpilih
                    if (isSelected) ...[
                      const SizedBox(height: 8),
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.blue[600],
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ],
                  ],
                );
              } else {
                // Layout horizontal untuk card normal
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row dengan tombol hapus
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
                        const SizedBox(width: 8),
                        // Tombol hapus
                        GestureDetector(
                          onTap: () => _showDeleteConfirmation(key, pool.name),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.delete_outline,
                              size: 16,
                              color: Colors.red[600],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Indikator terpilih di bawah
                    if (isSelected) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue[600],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Dipilih',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  void _showAddPoolDialog() {
    final nameController = TextEditingController();
    final depthController = TextEditingController();
    final maxLevelController = TextEditingController(text: '85');
    final minLevelController = TextEditingController(text: '30');
    final normalLevelController = TextEditingController(text: '75');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.add, color: Colors.green[600], size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Tambah Kolam/Wadah Baru',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Kolam/Wadah',
                  prefixIcon: const Icon(Icons.label),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Contoh: Kolam Ikan Lele',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: depthController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Kedalaman Total (cm)',
                  prefixIcon: const Icon(Icons.straighten),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Contoh: 150',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: normalLevelController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Level Normal (cm)',
                  prefixIcon: const Icon(Icons.track_changes),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  hintText: 'Contoh: 75',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: maxLevelController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Level Maksimum (%)',
                        prefixIcon: const Icon(Icons.trending_up),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: minLevelController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      decoration: InputDecoration(
                        labelText: 'Level Minimum (%)',
                        prefixIcon: const Icon(Icons.trending_down),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => _addNewPool(
              nameController,
              depthController,
              maxLevelController,
              minLevelController,
              normalLevelController,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Tambah'),
          ),
        ],
      ),
    );
  }

  void _addNewPool(
    TextEditingController nameController,
    TextEditingController depthController,
    TextEditingController maxLevelController,
    TextEditingController minLevelController,
    TextEditingController normalLevelController,
  ) {
    final name = nameController.text.trim();
    final depth = double.tryParse(depthController.text);
    final maxLevel = double.tryParse(maxLevelController.text);
    final minLevel = double.tryParse(minLevelController.text);
    final normalLevel = double.tryParse(normalLevelController.text);

    if (name.isEmpty) {
      _showErrorSnackBar('Nama kolam/wadah tidak boleh kosong');
      return;
    }

    if (depth == null || depth <= 0) {
      _showErrorSnackBar('Kedalaman harus berupa angka positif');
      return;
    }

    if (normalLevel == null || normalLevel <= 0) {
      _showErrorSnackBar('Level normal harus berupa angka positif');
      return;
    }

    if (maxLevel == null || maxLevel <= 0 || maxLevel > 100) {
      _showErrorSnackBar('Level maksimum harus antara 1-100%');
      return;
    }

    if (minLevel == null || minLevel <= 0 || minLevel > 100) {
      _showErrorSnackBar('Level minimum harus antara 1-100%');
      return;
    }

    if (minLevel >= maxLevel) {
      _showErrorSnackBar('Level minimum harus lebih kecil dari level maksimum');
      return;
    }

    // Generate unique key
    final key = name
        .toLowerCase()
        .replaceAll(' ', '-')
        .replaceAll(RegExp(r'[^a-z0-9-]'), '');

    // Check if key already exists
    if (widget.poolSettings.containsKey(key)) {
      _showErrorSnackBar('Kolam/wadah dengan nama serupa sudah ada');
      return;
    }

    final newPool = Pool(
      name: name,
      maxLevel: maxLevel,
      minLevel: minLevel,
      normalLevel: normalLevel,
      depth: depth,
      currentDepth: 0,
    );

    widget.onPoolAdded(key, newPool);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text('${newPool.name} berhasil ditambahkan')),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _showDeleteConfirmation(String key, String poolName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.warning, color: Colors.red[600], size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Hapus Kolam/Wadah', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: Text(
          'Yakin ingin menghapus "$poolName"?\n\nData histori dan pengaturan akan hilang permanen.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onPoolRemoved(key);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text('$poolName berhasil dihapus')),
                    ],
                  ),
                  backgroundColor: Colors.red,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
