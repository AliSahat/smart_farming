// lib/widgets/dashboard/pool_settings_widget.dart
// VERSI PERBAIKAN FINAL - Input dalam CM
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
  final _formKey = GlobalKey<FormState>();
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
      text: widget.pool.depth.toStringAsFixed(0),
    );
    _normalLevelController = TextEditingController(
      text: widget.pool.normalLevel.toStringAsFixed(0),
    );
    _maxLevelController = TextEditingController(
      text: widget.pool.maxLevel.toStringAsFixed(0),
    );
    _minLevelController = TextEditingController(
      text: widget.pool.minLevel.toStringAsFixed(0),
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
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final depth = double.parse(_depthController.text);
    final normalLevel = double.parse(_normalLevelController.text);
    final maxLevel = double.parse(_maxLevelController.text);
    final minLevel = double.parse(_minLevelController.text);

    // FIX: Gunakan nilai currentDepth yang sudah ada dari state, jangan dihitung ulang.
    final newPool = Pool(
      name: name,
      depth: depth,
      normalLevel: normalLevel,
      maxLevel: maxLevel,
      minLevel: minLevel,
      currentDepth: widget.pool.currentDepth, // Menggunakan nilai yang ada
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildFormFields(),
                const SizedBox(height: 20),
                _buildSaveButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.settings, color: Colors.orange[600], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Pengaturan Kolam/Wadah',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'Nama Kolam/Wadah',
          icon: Icons.label_important_outline,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _depthController,
          label: 'Kedalaman Total (cm)',
          icon: Icons.straighten,
          isNumeric: true,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Tidak boleh kosong';
            final depth = double.tryParse(value!);
            if (depth == null || depth <= 0) return 'Harus angka positif';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _minLevelController,
          label: 'Level Minimum (cm)', // Diubah dari % ke cm
          icon: Icons.trending_down,
          isNumeric: true,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Tidak boleh kosong';
            final min = double.tryParse(value!);
            final depth = double.tryParse(_depthController.text);
            if (min == null || min < 0) return 'Tidak boleh negatif';
            if (depth != null && min >= depth) return 'Harus < Kedalaman Total';
            final max = double.tryParse(_maxLevelController.text);
            if (max != null && min >= max) return 'Harus < Level Maksimum';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _maxLevelController,
          label: 'Level Maksimum (cm)', // Diubah dari % ke cm
          icon: Icons.trending_up,
          isNumeric: true,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Tidak boleh kosong';
            final max = double.tryParse(value!);
            final depth = double.tryParse(_depthController.text);
            if (max == null || max <= 0) return 'Harus angka positif';
            if (depth != null && max > depth)
              return 'Tidak boleh > Kedalaman Total';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _normalLevelController,
          label: 'Target Level Normal (cm)',
          icon: Icons.track_changes,
          isNumeric: true,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Tidak boleh kosong';
            final normal = double.tryParse(value!);
            if (normal == null || normal <= 0) return 'Harus angka positif';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isNumeric = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
      inputFormatters: isNumeric
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))]
          : null,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.orange[700]),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[400]!),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[400]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _saveSettings,
        icon: const Icon(Icons.save, size: 18),
        label: const Text(
          'Simpan Pengaturan',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
    );
  }
}
