import 'package:flutter/material.dart';
import '../../models/destination.dart';
import 'package:provider/provider.dart';
import '../../providers/destination_provider.dart';
import '../../services/auth_service.dart';

class AdminEditSitePage extends StatefulWidget {
  final Destination? destination;

  const AdminEditSitePage({super.key, this.destination});

  @override
  State<AdminEditSitePage> createState() => _AdminEditSitePageState();
}

class _AdminEditSitePageState extends State<AdminEditSitePage> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService(); // Keep this for user ID
  
  late TextEditingController _nameController;
  late TextEditingController _shortDescController;
  late TextEditingController _detailedDescController;
  late TextEditingController _addressController;
  late TextEditingController _latController;
  late TextEditingController _lngController;
  late TextEditingController _imageUrlController;
  late TextEditingController _hoursController;

  // Ticket prices
  late TextEditingController _adultPriceController;
  late TextEditingController _childPriceController;
  late TextEditingController _seniorPriceController;
  late TextEditingController _studentPriceController;
  late TextEditingController _foreignerAdultPriceController;
  late TextEditingController _foreignerChildPriceController;

  DestinationCategory _selectedCategory = DestinationCategory.sites;
  bool _isLoading = false;

  bool get _isEditing => widget.destination != null;

  @override
  void initState() {
    super.initState();
    final d = widget.destination;

    _nameController = TextEditingController(text: d?.name ?? '');
    _shortDescController = TextEditingController(text: d?.shortDescription ?? '');
    _detailedDescController = TextEditingController(text: d?.detailedDescription ?? '');
    _addressController = TextEditingController(text: d?.address ?? '');
    _latController = TextEditingController(text: d?.latitude.toString() ?? '');
    _lngController = TextEditingController(text: d?.longitude.toString() ?? '');
    _imageUrlController = TextEditingController(
      text: d?.images.isNotEmpty == true ? d!.images.first : '',
    );
    _hoursController = TextEditingController(
      text: d?.openingHours.isNotEmpty == true ? d!.openingHours.first.hours : '9:00 AM - 6:00 PM',
    );

    _adultPriceController = TextEditingController(
      text: d?.ticketPrice.adult.toString() ?? '0',
    );
    _childPriceController = TextEditingController(
      text: d?.ticketPrice.child.toString() ?? '0',
    );
    _seniorPriceController = TextEditingController(
      text: d?.ticketPrice.senior.toString() ?? '0',
    );
    _studentPriceController = TextEditingController(
      text: d?.ticketPrice.student.toString() ?? '0',
    );
    _foreignerAdultPriceController = TextEditingController(
      text: d?.ticketPrice.foreignerAdult.toString() ?? '0',
    );
    _foreignerChildPriceController = TextEditingController(
      text: d?.ticketPrice.foreignerChild.toString() ?? '0',
    );

    if (d != null) {
      _selectedCategory = d.category;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _shortDescController.dispose();
    _detailedDescController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _imageUrlController.dispose();
    _hoursController.dispose();
    _adultPriceController.dispose();
    _childPriceController.dispose();
    _seniorPriceController.dispose();
    _studentPriceController.dispose();
    _foreignerAdultPriceController.dispose();
    _foreignerChildPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Site' : 'Add New Site'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic info section
              const Text(
                'Basic Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Site Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<DestinationCategory>(
                initialValue: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category *',
                  border: OutlineInputBorder(),
                ),
                items: DestinationCategory.values.map((cat) {
                  return DropdownMenuItem(
                    value: cat,
                    child: Text(_getCategoryName(cat)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _shortDescController,
                decoration: const InputDecoration(
                  labelText: 'Short Description *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _detailedDescController,
                decoration: const InputDecoration(
                  labelText: 'Detailed Description *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
              const SizedBox(height: 24),

              // Location section
              const Text(
                'Location',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Address *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (v) => v?.isEmpty == true ? 'Required' : null,
              ),
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
                      keyboardType: TextInputType.number,
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
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v?.isEmpty == true) return 'Required';
                        if (double.tryParse(v!) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Image section
              const Text(
                'Image',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(
                  labelText: 'Image Path (e.g., assets/images/site.jpg)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Hours section
              const Text(
                'Opening Hours',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _hoursController,
                decoration: const InputDecoration(
                  labelText: 'Hours (e.g., 9:00 AM - 6:00 PM)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),

              // Pricing section
              const Text(
                'Ticket Prices (RM)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _adultPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Adult',
                        border: OutlineInputBorder(),
                        prefixText: 'RM ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _childPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Child',
                        border: OutlineInputBorder(),
                        prefixText: 'RM ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _seniorPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Senior',
                        border: OutlineInputBorder(),
                        prefixText: 'RM ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _studentPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Student',
                        border: OutlineInputBorder(),
                        prefixText: 'RM ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _foreignerAdultPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Foreigner Adult',
                        border: OutlineInputBorder(),
                        prefixText: 'RM ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _foreignerChildPriceController,
                      decoration: const InputDecoration(
                        labelText: 'Foreigner Child',
                        border: OutlineInputBorder(),
                        prefixText: 'RM ',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveSite,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          _isEditing ? 'Save Changes' : 'Add Site',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _getCategoryName(DestinationCategory category) {
    switch (category) {
      case DestinationCategory.sites:
        return 'Cultural Sites';
      case DestinationCategory.events:
        return 'Events';
      case DestinationCategory.packages:
        return 'Packages';
      case DestinationCategory.food:
        return 'Food & Dining';

    }
  }

  List<DayHours> _generateOpeningHours(String hours) {
    return [
      DayHours(day: 'Monday', hours: hours),
      DayHours(day: 'Tuesday', hours: hours),
      DayHours(day: 'Wednesday', hours: hours),
      DayHours(day: 'Thursday', hours: hours),
      DayHours(day: 'Friday', hours: hours),
      DayHours(day: 'Saturday', hours: hours),
      DayHours(day: 'Sunday', hours: hours),
    ];
  }

  Future<void> _saveSite() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final destination = Destination(
        id: widget.destination?.id ?? 'site-${DateTime.now().millisecondsSinceEpoch}',
        name: _nameController.text.trim(),
        shortDescription: _shortDescController.text.trim(),
        detailedDescription: _detailedDescController.text.trim(),
        category: _selectedCategory,
        address: _addressController.text.trim(),
        latitude: double.parse(_latController.text),
        longitude: double.parse(_lngController.text),
        images: _imageUrlController.text.isNotEmpty
            ? [_imageUrlController.text.trim()]
            : [],
        openingHours: _generateOpeningHours(_hoursController.text.trim()),
        ticketPrice: TicketPrice(
          adult: double.tryParse(_adultPriceController.text) ?? 0,
          child: double.tryParse(_childPriceController.text) ?? 0,
          senior: double.tryParse(_seniorPriceController.text) ?? 0,
          student: double.tryParse(_studentPriceController.text) ?? 0,
          foreignerAdult: double.tryParse(_foreignerAdultPriceController.text) ?? 0,
          foreignerChild: double.tryParse(_foreignerChildPriceController.text) ?? 0,
        ),
        rating: widget.destination?.rating ?? 0,
        reviewCount: widget.destination?.reviewCount ?? 0,
        distanceKm: widget.destination?.distanceKm,
        lastUpdatedAt: DateTime.now(),
        updatedByAdminId: _authService.currentUser?.id,
      );

      final provider = context.read<DestinationProvider>();
      if (_isEditing) {
        await provider.updateDestination(destination);
      } else {
        await provider.addDestination(destination);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Site updated successfully' : 'Site added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
