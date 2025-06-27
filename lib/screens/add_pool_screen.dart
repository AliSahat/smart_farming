// lib/screens/add_pool_screen.dart
// VERSI PERBAIKAN FINAL - Input Min/Max dalam CM
// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/pool_model.dart';
import '../data/pool_data.dart';

class AddPoolScreen extends StatefulWidget {
  final Function(String key, Pool pool) onPoolAdded;

  const AddPoolScreen({super.key, required this.onPoolAdded});

  @override
  State<AddPoolScreen> createState() => _AddPoolScreenState();
}

class _AddPoolScreenState extends State<AddPoolScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _depthController = TextEditingController();
  final _normalLevelController = TextEditingController();
  final _maxLevelController = TextEditingController();
  final _minLevelController = TextEditingController();

  String _selectedTemplate = 'custom';

  @override
  void dispose() {
    _nameController.dispose();
    _depthController.dispose();
    _normalLevelController.dispose();
    _maxLevelController.dispose();
    _minLevelController.dispose();
    super.dispose();
  }

  void _applyTemplate(String template) {
    setState(() {
      _selectedTemplate = template;
    });

    // Template sekarang mengisi dalam CM
    switch (template) {
      case 'kolam-ikan':
        _nameController.text = 'Kolam Ikan';
        _depthController.text = '150';
        _minLevelController.text = '45';  // Contoh: 30% dari 150cm
        _maxLevelController.text = '127'; // Contoh: 85% dari 150cm
        _normalLevelController.text = '112';// Contoh: 75% dari 150cm
        break;
      case 'aquarium':
        _nameController.text = 'Aquarium';
        _depthController.text = '60';
        _minLevelController.text = '20';
        _maxLevelController.text = '50';
        _normalLevelController.text = '45';
        break;
      case 'tangki-air':
        _nameController.text = 'Tangki Air';
        _depthController.text = '200';
        _minLevelController.text = '40';
        _maxLevelController.text = '180';
        _normalLevelController.text = '150';
        break;
      default:
        _nameController.clear();
        _depthController.clear();
        _minLevelController.clear();
        _maxLevelController.clear();
        _normalLevelController.clear();
        break;
    }
  }

  void _savePool() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final depth = double.parse(_depthController.text);
    final normalLevel = double.parse(_normalLevelController.text);
    final maxLevel = double.parse(_maxLevelController.text);
    final minLevel = double.parse(_minLevelController.text);

    // Generate unique key
    final key = name
        .toLowerCase()
        .replaceAll(' ', '-')
        .replaceAll(RegExp(r'[^a-z0-9-]'), '');

    // Cek duplikasi key sederhana, bisa diganti dengan logic yang lebih baik
    // if (provider.pools.containsKey(key)) { ... }

    final newPool = Pool(
      name: name,
      depth: depth,
      normalLevel: normalLevel,
      maxLevel: maxLevel,
      minLevel: minLevel,
      currentDepth: 0, // Default ketinggian awal
    );

    widget.onPoolAdded(key, newPool);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Tambah Kolam/Wadah'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTemplateSection(),
              const SizedBox(height: 24),
              _buildFormSection(),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTemplateSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.category, color: Colors.blue, size: 24),
                SizedBox(width: 12),
                Text('Pilih Template', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Pilih template untuk mengisi pengaturan umum secara otomatis.', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildTemplateChip('custom', 'Kosong', Icons.edit),
                _buildTemplateChip('kolam-ikan', 'Kolam Ikan', Icons.set_meal),
                _buildTemplateChip('aquarium', 'Aquarium', Icons.waves),
                _buildTemplateChip('tangki-air', 'Tangki Air', Icons.water_drop),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateChip(String value, String label, IconData icon) {
    final isSelected = _selectedTemplate == value;
    return FilterChip(
      selected: isSelected,
      onSelected: (selected) => _applyTemplate(value),
      avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : Colors.grey[600]),
      label: Text(label),
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.grey[700], fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal),
      backgroundColor: Colors.grey[200],
      selectedColor: Colors.blue[600],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildFormSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.edit_note, color: Colors.orange, size: 24),
                SizedBox(width: 12),
                Text('Detail Kolam/Wadah', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _nameController,
              label: 'Nama Kolam/Wadah',
              icon: Icons.label_important_outline,
              validator: (value) => (value?.trim().isEmpty ?? true) ? 'Nama tidak boleh kosong' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _depthController,
              label: 'Kedalaman Total (cm)',
              icon: Icons.straighten,
              isNumeric: true,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Tidak boleh kosong';
                if ((double.tryParse(value!) ?? 0) <= 0) return 'Harus angka positif';
                return null;
              },
            ),
            const SizedBox(height: 16),
            // FIX: Mengubah input menjadi CM
            _buildTextField(
              controller: _minLevelController,
              label: 'Level Minimum (cm)', // Diubah
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
            // FIX: Mengubah input menjadi CM
            _buildTextField(
              controller: _maxLevelController,
              label: 'Level Maksimum (cm)', // Diubah
              icon: Icons.trending_up,
              isNumeric: true,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Tidak boleh kosong';
                final max = double.tryParse(value!);
                final depth = double.tryParse(_depthController.text);
                if (max == null || max <= 0) return 'Harus angka positif';
                if (depth != null && max > depth) return 'Tidak boleh > Kedalaman Total';
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
                 if ((double.tryParse(value!) ?? 0) <= 0) return 'Harus angka positif';
                 return null;
              },
            ),
          ],
        ),
      ),
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
        prefixIcon: Icon(icon, size: 20, color: Colors.blue[700]),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
        onPressed: _savePool,
        icon: const Icon(Icons.save, size: 20),
        label: const Text('Simpan Kolam/Wadah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
          foregroundColor: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}