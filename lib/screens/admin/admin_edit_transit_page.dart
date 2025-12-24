import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/transit_station.dart';
import '../../providers/transit_provider.dart';

class AdminEditTransitPage extends StatefulWidget {
  final TransitStation? station;

  const AdminEditTransitPage({super.key, this.station});

  @override
  State<AdminEditTransitPage> createState() => _AdminEditTransitPageState();
}

class _AdminEditTransitPageState extends State<AdminEditTransitPage> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _lineInfoController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  
  String _selectedType = 'lrt';
  bool _isLoading = false;

  bool get _isEditing => widget.station != null;

  @override
  void initState() {
    super.initState();
    final s = widget.station;
    _nameController = TextEditingController(text: s?.name ?? '');
    _lineInfoController = TextEditingController(text: s?.lineInfo ?? '');
    _latController = TextEditingController(text: s?.latitude.toString() ?? '');
    _lngController = TextEditingController(text: s?.longitude.toString() ?? '');
    
    if (s != null) {
      _selectedType = s.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lineInfoController.dispose();
    _latController.dispose();
    _lngController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Station' : 'Add Station'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Station Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type *',
                  border: OutlineInputBorder(),
                ),
                items: ['lrt', 'mrt', 'monorail', 'ktm', 'hub', 'bus']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedType = val);
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _lineInfoController,
                decoration: const InputDecoration(
                  labelText: 'Line Info * (e.g. Kelana Jaya Line)',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              const Text('Location',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _latController,
                      decoration: const InputDecoration(
                        labelText: 'Latitude *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v?.isEmpty == true) return 'Required';
                        if (double.tryParse(v!) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lngController,
                      decoration: const InputDecoration(
                        labelText: 'Longitude *',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (v) {
                        if (v?.isEmpty == true) return 'Required';
                        if (double.tryParse(v!) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(_isEditing ? 'Save Changes' : 'Add Station'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final station = TransitStation(
        id: widget.station?.id ?? '', // Correctly passing empty ID for new items (repo handles if needed, or we might need to verify provider behavior)
        // Wait, provider update uses doc(id), so new item needs ID? 
        // Firestore add() generates ID. update() needs existing ID.
        // So for new station, ID can be empty string if we use add().
        // My Logic:
        // if editing -> updateStation(station) -> uses station.id
        // if new -> addStation(station) -> ignores station.id, generates new.
        
        name: _nameController.text.trim(),
        type: _selectedType,
        lineInfo: _lineInfoController.text.trim(),
        latitude: double.parse(_latController.text),
        longitude: double.parse(_lngController.text),
      );

      final provider = context.read<TransitProvider>();
      
      if (_isEditing) {
        await provider.updateStation(station);
      } else {
        await provider.addStation(station);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Saved successfully'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
