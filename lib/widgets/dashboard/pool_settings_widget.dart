// lib/widgets/dashboard/pool_settings_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';
import '../../models/pool_model.dart';
import '../../providers/pool_provider.dart';

class PoolSettingsWidget extends StatefulWidget {
  final Pool pool;
  final Function(Pool) onSettingsChanged;
  final Function(String)? onPoolDeleted;
  final double waterLevelPercent;
  final String? poolKey; // Make this optional with default handling

  const PoolSettingsWidget({
    super.key,
    required this.pool,
    required this.onSettingsChanged,
    required this.waterLevelPercent,
    this.poolKey, // Optional parameter
    this.onPoolDeleted,
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
    Logger().i("🏁 Pool settings widget initialized for: ${widget.pool.name}");
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

    Logger().i("💾 Saving pool settings for: ${widget.pool.name}");

    final name = _nameController.text.trim();
    final depth = double.parse(_depthController.text);
    final normalLevel = double.parse(_normalLevelController.text);
    final maxLevel = double.parse(_maxLevelController.text);
    final minLevel = double.parse(_minLevelController.text);

    final newCurrentDepth = (widget.waterLevelPercent / 100) * depth;

    final newPool = Pool(
      name: name,
      depth: depth,
      normalLevel: normalLevel,
      maxLevel: maxLevel,
      minLevel: minLevel,
      currentDepth: newCurrentDepth,
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

    Logger().i("✅ Pool settings saved successfully for: ${newPool.name}");
  }

  Future<void> _deletePool() async {
    // Check if we have the required data for deletion
    if (widget.poolKey == null) {
      Logger().e("❌ Cannot delete pool: poolKey is null");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Error: Tidak dapat menghapus kolam (poolKey tidak tersedia)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    Logger().w("⚠️ Delete pool requested for: ${widget.pool.name}");

    // Show confirmation dialog
    final bool? shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red[600], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Hapus Kolam',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Apakah Anda yakin ingin menghapus kolam "${widget.pool.name}"?',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.red[600], size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'PERINGATAN:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.red[700],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '• Semua data historis akan terhapus\n'
                      '• Pengaturan kolam akan hilang\n'
                      '• Tindakan ini tidak dapat dibatalkan',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.red[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
                Logger().d("❌ Pool deletion cancelled by user");
              },
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                Logger().w("✅ Pool deletion confirmed by user");
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    // If user confirmed deletion
    if (shouldDelete == true && mounted) {
      await _performDeletion();
    }
  }

  Future<void> _performDeletion() async {
    Logger().i("🗑️ Starting pool deletion process for: ${widget.pool.name}");

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 16),
              Text('Menghapus ${widget.pool.name}...'),
            ],
          ),
        ),
      );

      final poolProvider = Provider.of<PoolProvider>(context, listen: false);

      // Delete from database
      final success = await poolProvider.deletePool(widget.poolKey!);

      // Close loading dialog
      if (mounted) Navigator.of(context).pop();

      if (success) {
        Logger().i("✅ Pool deleted successfully: ${widget.pool.name}");

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Kolam "${widget.pool.name}" berhasil dihapus'),
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

        // Call the callback if provided
        if (widget.onPoolDeleted != null) {
          widget.onPoolDeleted!(widget.poolKey!);
        }
      } else {
        Logger().e("❌ Failed to delete pool: ${widget.pool.name}");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('Gagal menghapus kolam. Silakan coba lagi.'),
                  ),
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
    } catch (e) {
      Logger().e("💥 Exception during pool deletion", error: e);

      // Close loading dialog if still open
      if (mounted) Navigator.of(context).pop();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error menghapus kolam: $e'),
            backgroundColor: Colors.red,
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildFormFields(),
                const SizedBox(height: 20),
                _buildActionButtons(),
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
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Nama tidak boleh kosong';
            if (value!.length < 2) return 'Nama minimal 2 karakter';
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
            if (value?.isEmpty ?? true) return 'Tidak boleh kosong';
            final depth = double.tryParse(value!);
            if (depth == null || depth <= 0) return 'Harus angka positif';
            if (depth > 1000) return 'Kedalaman terlalu besar (max 1000cm)';
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _minLevelController,
          label: 'Level Minimum (cm)',
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
          label: 'Level Maksimum (cm)',
          icon: Icons.trending_up,
          isNumeric: true,
          validator: (value) {
            if (value?.isEmpty ?? true) return 'Tidak boleh kosong';
            final max = double.tryParse(value!);
            final depth = double.tryParse(_depthController.text);
            if (max == null || max <= 0) return 'Harus angka positif';
            if (depth != null && max > depth)
              return 'Tidak boleh > Kedalaman Total';
            final min = double.tryParse(_minLevelController.text);
            if (min != null && max <= min) return 'Harus > Level Minimum';
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
            final min = double.tryParse(_minLevelController.text);
            final max = double.tryParse(_maxLevelController.text);
            if (min != null && normal < min) return 'Harus >= Level Minimum';
            if (max != null && normal > max) return 'Harus <= Level Maksimum';
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

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Save button
        SizedBox(
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
        ),

        const SizedBox(height: 12),

        // Delete button - only show if poolKey is available
        if (widget.poolKey != null) ...[
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _deletePool,
              icon:
                  Icon(Icons.delete_forever, size: 18, color: Colors.red[600]),
              label: Text(
                'Hapus Kolam',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.red[600],
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red[400]!, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
