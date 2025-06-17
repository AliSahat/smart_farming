// ignore_for_file: deprecated_member_use, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/pool_model.dart';

class PoolSettingsWidget extends StatefulWidget {
  final Pool pool;
  final Function(Pool) onSettingsChanged;
  final double waterLevelPercent;

  const PoolSettingsWidget({
    super.key,
    required this.pool,
    required this.onSettingsChanged,
    required this.waterLevelPercent,
  });

  @override
  State<PoolSettingsWidget> createState() => _PoolSettingsWidgetState();
}

class _PoolSettingsWidgetState extends State<PoolSettingsWidget> {
  late TextEditingController _nameController;
  late TextEditingController _depthController;
  late TextEditingController _normalLevelController;
  late TextEditingController _maxLevelController;
  late TextEditingController _minLevelController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.pool.name);
    _depthController = TextEditingController(
      text: widget.pool.depth.toString(),
    );
    _normalLevelController = TextEditingController(
      text: widget.pool.normalLevel.toString(),
    );
    _maxLevelController = TextEditingController(
      text: widget.pool.maxLevel.toString(),
    );
    _minLevelController = TextEditingController(
      text: widget.pool.minLevel.toString(),
    );
  }

  @override
  void didUpdateWidget(PoolSettingsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pool.name != widget.pool.name) {
      _initializeControllers();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _depthController.dispose();
    _normalLevelController.dispose();
    _maxLevelController.dispose();
    _minLevelController.dispose();
    super.dispose();
  }

  void _saveSettings() {
    try {
      final newPool = Pool(
        name: _nameController.text,
        depth: double.parse(_depthController.text),
        normalLevel: double.parse(_normalLevelController.text),
        maxLevel: double.parse(_maxLevelController.text),
        minLevel: double.parse(_minLevelController.text),
        currentDepth:
            (widget.waterLevelPercent / 100) *
            double.parse(_depthController.text),
      );

      widget.onSettingsChanged(newPool);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Pengaturan ${newPool.name} berhasil disimpan'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(child: Text('Error: Periksa input angka')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Colors.orange[50]!.withOpacity(0.3),
              Colors.amber[50]!.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header responsif
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 500) {
                    // Mobile - Header vertikal
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.settings,
                                color: Colors.orange[600],
                                size: 24,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Pengaturan Kolam',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Mengatur: ${widget.pool.name}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.orange[700],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.orange[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'EDIT MODE',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else {
                    // Desktop/Tablet - Header horizontal
                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.settings,
                            color: Colors.orange[600],
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Pengaturan Kolam/Wadah',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1F2937),
                                  ),
                                ),
                                Text(
                                  'Mengatur: ${widget.pool.name}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.orange[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.orange[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'EDIT MODE',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orange[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 20),

              // Form Fields dengan layout responsif
              LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 600) {
                    // Mobile - Layout vertikal
                    return Column(
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          label: 'Nama Kolam/Wadah',
                          icon: Icons.label,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _depthController,
                          label: 'Kedalaman Total (cm)',
                          icon: Icons.straighten,
                          isNumeric: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _normalLevelController,
                          label: 'Level Normal (cm)',
                          icon: Icons.track_changes,
                          isNumeric: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _maxLevelController,
                          label: 'Level Maksimal (%)',
                          icon: Icons.trending_up,
                          isNumeric: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _minLevelController,
                          label: 'Level Minimal (%)',
                          icon: Icons.trending_down,
                          isNumeric: true,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: _saveSettings,
                            icon: const Icon(Icons.save, size: 18),
                            label: const Text(
                              'Simpan Pengaturan',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[600],
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // Desktop/Tablet - Layout horizontal dengan rows
                    return Column(
                      children: [
                        // Row 1: Nama dan Kedalaman
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _nameController,
                                label: 'Nama Kolam/Wadah',
                                icon: Icons.label,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _depthController,
                                label: 'Kedalaman Total (cm)',
                                icon: Icons.straighten,
                                isNumeric: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Row 2: Level Normal dan Level Maksimal
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _normalLevelController,
                                label: 'Level Normal (cm)',
                                icon: Icons.track_changes,
                                isNumeric: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _maxLevelController,
                                label: 'Level Maksimal (%)',
                                icon: Icons.trending_up,
                                isNumeric: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Row 3: Level Minimal dan Tombol Simpan
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _minLevelController,
                                label: 'Level Minimal (%)',
                                icon: Icons.trending_down,
                                isNumeric: true,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: ElevatedButton.icon(
                                  onPressed: _saveSettings,
                                  icon: const Icon(Icons.save, size: 18),
                                  label: const Text(
                                    'Simpan Pengaturan',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange[600],
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    );
                  }
                },
              ),

              // Info tambahan
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[600], size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Pengaturan akan diterapkan setelah menekan tombol Simpan. Pastikan nilai yang dimasukkan sudah benar.',
                        style: TextStyle(fontSize: 12, color: Colors.blue[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumeric = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumeric
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
          : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 18, color: Colors.orange[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.orange[400]!, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
