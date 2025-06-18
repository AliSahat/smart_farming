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
  final _normalLevelController = TextEditingController(text: '75');
  final _maxLevelController = TextEditingController(text: '85');
  final _minLevelController = TextEditingController(text: '30');

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

    switch (template) {
      case 'kolam-ikan':
        _nameController.text = 'Kolam Ikan';
        _depthController.text = '150';
        _normalLevelController.text = '75';
        _maxLevelController.text = '85';
        _minLevelController.text = '30';
        break;
      case 'aquarium':
        _nameController.text = 'Aquarium';
        _depthController.text = '100';
        _normalLevelController.text = '80';
        _maxLevelController.text = '80';
        _minLevelController.text = '30';
        break;
      case 'tangki-air':
        _nameController.text = 'Tangki Air';
        _depthController.text = '200';
        _normalLevelController.text = '75';
        _maxLevelController.text = '90';
        _minLevelController.text = '20';
        break;
      default:
        // Custom - biarkan kosong
        _nameController.clear();
        _depthController.clear();
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
              // Template Section
              _buildTemplateSection(),
              const SizedBox(height: 24),

              // Form Section
              _buildFormSection(),
              const SizedBox(height: 32),

              // Save Button
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ...existing code...

  Widget _buildTemplateSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.category,
                  color: Colors.blue[600],
                  size: 24,
                ), // Changed this line
                const SizedBox(width: 12),
                const Text(
                  'Template Kolam/Wadah',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Pilih template untuk mengisi pengaturan secara otomatis',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _buildTemplateChip('custom', 'Custom', Icons.edit),
                _buildTemplateChip('kolam-ikan', 'Kolam Ikan', Icons.set_meal),
                _buildTemplateChip('aquarium', 'Aquarium', Icons.waves),
                _buildTemplateChip(
                  'tangki-air',
                  'Tangki Air',
                  Icons.water_drop,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ...existing code...
  Widget _buildTemplateChip(String value, String label, IconData icon) {
    final isSelected = _selectedTemplate == value;
    return FilterChip(
      selected: isSelected,
      onSelected: (selected) => _applyTemplate(value),
      avatar: Icon(
        icon,
        size: 16,
        color: isSelected ? Colors.white : Colors.grey[600],
      ),
      label: Text(label),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
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
            Row(
              children: [
                Icon(Icons.edit, color: Colors.orange[600], size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Detail Kolam/Wadah',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildTextField(
              controller: _nameController,
              label: 'Nama Kolam/Wadah',
              icon: Icons.label,
              validator: (value) {
                if (value?.trim().isEmpty ?? true) {
                  return 'Nama tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _depthController,
              label: 'Kedalaman Total (cm)',
              icon: Icons.straighten,
              isNumeric: true,
              validator: (value) {
                if (value?.isEmpty ?? true)
                  return 'Kedalaman tidak boleh kosong';
                final depth = double.tryParse(value!);
                if (depth == null || depth <= 0) {
                  return 'Kedalaman harus berupa angka positif';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _normalLevelController,
              label: 'Level Normal (cm)',
              icon: Icons.track_changes,
              isNumeric: true,
              validator: (value) {
                if (value?.isEmpty ?? true)
                  return 'Level normal tidak boleh kosong';
                final normal = double.tryParse(value!);
                if (normal == null || normal <= 0) {
                  return 'Level normal harus berupa angka positif';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    controller: _maxLevelController,
                    label: 'Level Max (%)',
                    icon: Icons.trending_up,
                    isNumeric: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true)
                        return 'Level max tidak boleh kosong';
                      final max = double.tryParse(value!);
                      if (max == null || max <= 0 || max > 100) {
                        return 'Level max harus 1-100%';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    controller: _minLevelController,
                    label: 'Level Min (%)',
                    icon: Icons.trending_down,
                    isNumeric: true,
                    validator: (value) {
                      if (value?.isEmpty ?? true)
                        return 'Level min tidak boleh kosong';
                      final min = double.tryParse(value!);
                      if (min == null || min <= 0 || min > 100) {
                        return 'Level min harus 1-100%';
                      }
                      final max = double.tryParse(_maxLevelController.text);
                      if (max != null && min >= max) {
                        return 'Level min harus < max';
                      }
                      return null;
                    },
                  ),
                ),
              ],
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
        prefixIcon: Icon(icon, size: 18, color: Colors.blue[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[400]!, width: 2),
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

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _savePool,
        icon: const Icon(Icons.save, size: 20),
        label: const Text(
          'Simpan Kolam/Wadah',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[600],
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
