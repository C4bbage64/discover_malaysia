import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/destination.dart';
import '../models/booking.dart';
import '../providers/auth_provider.dart';
import '../providers/booking_provider.dart';
import '../services/booking_repository.dart' show PriceBreakdown;
import 'booking_confirmation_page.dart';

class BookingFormPage extends StatefulWidget {
  final Destination destination;

  const BookingFormPage({super.key, required this.destination});

  @override
  State<BookingFormPage> createState() => _BookingFormPageState();
}

class _BookingFormPageState extends State<BookingFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Ticket quantities
  final Map<TicketType, int> _ticketQuantities = {
    TicketType.adult: 0,
    TicketType.child: 0,
    TicketType.senior: 0,
    TicketType.student: 0,
    TicketType.foreignerAdult: 0,
    TicketType.foreignerChild: 0,
  };
  
  // Visitor names
  final List<TextEditingController> _visitorNameControllers = [];
  
  // Visit date
  DateTime? _visitDate;
  
  // Loading state
  bool _isLoading = false;

  int get _totalTickets => _ticketQuantities.values.fold(0, (sum, qty) => sum + qty);

  PriceBreakdown _calculatePriceBreakdown(BookingProvider bookingProvider) {
    return bookingProvider.calculatePrice(
      destination: widget.destination,
      ticketQuantities: _ticketQuantities,
    );
  }

  @override
  void dispose() {
    for (final controller in _visitorNameControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _updateVisitorNameFields() {
    // Adjust the number of visitor name fields based on total tickets
    while (_visitorNameControllers.length < _totalTickets) {
      _visitorNameControllers.add(TextEditingController());
    }
    while (_visitorNameControllers.length > _totalTickets) {
      _visitorNameControllers.removeLast().dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingProvider = context.watch<BookingProvider>();
    final priceBreakdown = _calculatePriceBreakdown(bookingProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Tickets'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Destination info card
              _buildDestinationCard(),
              const SizedBox(height: 24),
              
              // Visit date
              const Text(
                'Select Visit Date',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildDatePicker(),
              const SizedBox(height: 24),
              
              // Ticket selection
              const Text(
                'Select Tickets',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildTicketSelectors(),
              const SizedBox(height: 24),
              
              // Visitor names
              if (_totalTickets > 0) ...[
                Text(
                  'Visitor Names ($_totalTickets ${_totalTickets == 1 ? 'visitor' : 'visitors'})',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildVisitorNameFields(),
                const SizedBox(height: 24),
              ],
              
              // Price breakdown
              if (_totalTickets > 0) ...[
                const Text(
                  'Price Summary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildPriceSummary(bookingProvider),
              ],
              
              // Space for button
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      
      // Confirm button
      bottomNavigationBar: _totalTickets > 0
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmBooking,
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
                          'Confirm Booking - ${priceBreakdown.formattedTotal}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildDestinationCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: AssetImage(
                    widget.destination.images.isNotEmpty
                        ? widget.destination.images.first
                        : 'assets/images/placeholder.jpg',
                  ),
                  fit: BoxFit.cover,
                ),
                color: Colors.grey[300],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.destination.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.destination.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Colors.blue),
            const SizedBox(width: 12),
            Text(
              _visitDate != null
                  ? DateFormat('EEEE, MMMM d, yyyy').format(_visitDate!)
                  : 'Select a date',
              style: TextStyle(
                fontSize: 16,
                color: _visitDate != null ? Colors.black : Colors.grey,
              ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_drop_down, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _visitDate ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _visitDate = picked;
      });
    }
  }

  Widget _buildTicketSelectors() {
    final prices = widget.destination.ticketPrice;
    
    return Column(
      children: [
        _buildTicketRow(TicketType.adult, 'Adult', prices.adult),
        _buildTicketRow(TicketType.child, 'Child', prices.child),
        _buildTicketRow(TicketType.senior, 'Senior', prices.senior),
        _buildTicketRow(TicketType.student, 'Student', prices.student),
        _buildTicketRow(TicketType.foreignerAdult, 'Foreigner Adult', prices.foreignerAdult),
        _buildTicketRow(TicketType.foreignerChild, 'Foreigner Child', prices.foreignerChild),
      ],
    );
  }

  Widget _buildTicketRow(TicketType type, String label, double price) {
    final quantity = _ticketQuantities[type] ?? 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  price == 0 ? 'FREE' : 'RM ${price.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: price == 0 ? Colors.green : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Quantity selector
          Row(
            children: [
              IconButton(
                onPressed: quantity > 0
                    ? () {
                        setState(() {
                          _ticketQuantities[type] = quantity - 1;
                          _updateVisitorNameFields();
                        });
                      }
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: quantity > 0 ? Colors.blue : Colors.grey,
              ),
              SizedBox(
                width: 40,
                child: Text(
                  quantity.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _ticketQuantities[type] = quantity + 1;
                    _updateVisitorNameFields();
                  });
                },
                icon: const Icon(Icons.add_circle_outline),
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVisitorNameFields() {
    _updateVisitorNameFields();
    
    return Column(
      children: List.generate(_totalTickets, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: TextFormField(
            controller: _visitorNameControllers[index],
            decoration: InputDecoration(
              labelText: 'Visitor ${index + 1} Name',
              hintText: 'Enter full name',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.person_outline),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter visitor name';
              }
              return null;
            },
          ),
        );
      }),
    );
  }

  Widget _buildPriceSummary(BookingProvider bookingProvider) {
    final breakdown = _calculatePriceBreakdown(bookingProvider);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Ticket breakdown
            ...breakdown.tickets.where((t) => t.quantity > 0).map((ticket) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${ticket.type.displayName} x ${ticket.quantity}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      ticket.pricePerTicket == 0
                          ? 'FREE'
                          : 'RM ${ticket.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            }),
            const Divider(),
            
            // Subtotal
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Subtotal', style: TextStyle(fontSize: 14)),
                Text(breakdown.formattedSubtotal, style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            
            // Tax
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tax (${breakdown.taxRatePercent} SST)',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(breakdown.formattedTax, style: const TextStyle(fontSize: 14)),
              ],
            ),
            const Divider(),
            
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  breakdown.formattedTotal,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmBooking() async {
    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    // Check date selected
    if (_visitDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a visit date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Check at least one ticket
    if (_totalTickets == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one ticket'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Check user is logged in
    final authProvider = context.read<AuthProvider>();
    if (!authProvider.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to make a booking'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final bookingProvider = context.read<BookingProvider>();
      final breakdown = _calculatePriceBreakdown(bookingProvider);
      final visitorNames = _visitorNameControllers
          .map((c) => c.text.trim())
          .toList();
      
      final booking = await bookingProvider.createBooking(
        userId: authProvider.user!.id,
        destination: widget.destination,
        tickets: breakdown.tickets.where((t) => t.quantity > 0).toList(),
        visitorNames: visitorNames,
        visitDate: _visitDate!,
        subtotal: breakdown.subtotal,
        taxAmount: breakdown.taxAmount,
        totalPrice: breakdown.total,
      );
      
      if (mounted && booking != null) {
        // Navigate to confirmation page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BookingConfirmationPage(booking: booking),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(bookingProvider.error ?? 'Booking failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking failed: $e'),
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
