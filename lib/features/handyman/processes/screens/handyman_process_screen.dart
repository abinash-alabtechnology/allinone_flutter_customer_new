import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:handy_allinone/features/handyman/services/controllers/handyman_home_controller.dart';

class HandymanProcessScreen extends StatefulWidget {
  const HandymanProcessScreen({super.key});

  @override
  State<HandymanProcessScreen> createState() => _HandymanProcessScreenState();
}

class _HandymanProcessScreenState extends State<HandymanProcessScreen> {
  int _currentStep = 0;
  String _serviceTitle = 'Handyman Service';
  
  // Step 1: Details
  final List<String> _selectedTasks = [];
  final TextEditingController _descController = TextEditingController();
  double _hours = 2.0;

  // Step 2: Schedule
  int _selectedDateIndex = 0;
  int _selectedTimeIndex = -1;

  // Step 3: Payment
  int _paymentMethodIndex = 0; // 0: COD, 1: Wallet, 2: Online

  final List<String> _timeSlots = [
    '09:00 AM - 11:00 AM',
    '11:00 AM - 01:00 PM',
    '01:00 PM - 03:00 PM',
    '03:00 PM - 05:00 PM',
    '05:00 PM - 07:00 PM',
    '07:00 PM - 09:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args != null && args is Map && args.containsKey('serviceTitle')) {
      _serviceTitle = args['serviceTitle'];
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  List<String> _getPopularTasks() {
    if (_serviceTitle.contains('InstaHelp')) {
      return ['General Assistance', 'Heavy Lifting', 'Quick Errands', 'Housework Helper'];
    } else if (_serviceTitle.contains('Salon')) {
      return ['Hair Cut & Styling', 'Facial Treatment', 'Massage Therapy', 'Manicure & Pedicure'];
    } else if (_serviceTitle.contains('Cleaning')) {
      return ['Deep Home Cleaning', 'Kitchen Cleaning', 'Bathroom Sanitization', 'Pest Spraying'];
    } else if (_serviceTitle.contains('Painting')) {
      return ['Wall Touch-ups', 'Full Room Painting', 'Water-proofing sealant', 'Texture Painting'];
    } else if (_serviceTitle.contains('AC')) {
      return ['AC Filter Cleaning', 'Gas Refill', 'Leakage Repair', 'Appliance Diagnosis'];
    } else if (_serviceTitle.contains('Smart Home') || _serviceTitle.contains('CCTV')) {
      return ['CCTV Camera Install', 'Smart Door Lock Setup', 'Wi-Fi Extender Config', 'Smart Speaker setup'];
    }  else if (_serviceTitle.contains('Gardening') || _serviceTitle.contains('Lawn')) {
      return ['Lawn Mowing & Trim', 'Weed Removal & Spray', 'Garden Cleanup & Soil', 'Flower Bed Trimming'];
    } else if (_serviceTitle.contains('Renovation')) {
      return ['Floor Tiling Work', 'Drywall Patching', 'Door Installation', 'Cabinet Repair & Fix'];
    } else if (_serviceTitle.contains('TV Mount') || _serviceTitle.contains('Setup')) {
      return ['TV Wall Mounting', 'Soundbar Installation', 'Home Theater Setup', 'Wire Concealment'];
    } else if (_serviceTitle.contains('Locksmith') || _serviceTitle.contains('Key')) {
      return ['Door Lock Replacement', 'Key Duplication', 'Broken Key Extraction', 'Digital Lock Setup'];
    } else {
      return ['Electric Socket Repair', 'Tap & Pipe Fix', 'Furniture Assembly', 'Door Lock Installation'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksList = _getPopularTasks();
    final double hourlyRate = _serviceTitle.contains('Salon') ? 35.0 : 25.0;
    final double totalCost = _hours * hourlyRate;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            } else {
              Get.back();
            }
          },
        ),
        title: Text(
          _serviceTitle,
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Step Progress Indicator Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.05),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            child: Row(
              children: [
                _buildStepHeader(0, 'Customize', isActive: _currentStep >= 0),
                _buildStepDivider(isActive: _currentStep >= 1),
                _buildStepHeader(1, 'Schedule', isActive: _currentStep >= 1),
                _buildStepDivider(isActive: _currentStep >= 2),
                _buildStepHeader(2, 'Checkout', isActive: _currentStep >= 2),
              ],
            ),
          ),

          // Main Step Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _currentStep == 0
                  ? _buildStepDetails(tasksList, hourlyRate)
                  : _currentStep == 1
                      ? _buildStepSchedule()
                      : _buildStepSummary(totalCost),
            ),
          ),

          // Bottom Action Button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (_currentStep > 0) ...[
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: () {
                          setState(() {
                            _currentStep--;
                          });
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          side: const BorderSide(color: Color(0xFF6C63FF)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Back',
                          style: GoogleFonts.inter(
                            color: const Color(0xFF6C63FF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const Gap(12),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => _handleNextStep(totalCost),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        _currentStep == 2 ? 'Place Booking' : 'Continue',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(int index, String label, {required bool isActive}) {
    final color = isActive ? const Color(0xFF6C63FF) : Colors.grey.shade400;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: isActive ? color : Colors.transparent,
            border: Border.all(color: color, width: 2),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '${index + 1}',
            style: GoogleFonts.inter(
              color: isActive ? Colors.white : color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Gap(6),
        Text(
          label,
          style: GoogleFonts.inter(
            color: isActive ? Colors.black87 : Colors.grey.shade500,
            fontSize: 13,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isActive ? const Color(0xFF6C63FF) : Colors.grey.shade300,
      ),
    );
  }

  // Step 1: Customize Details UI
  Widget _buildStepDetails(List<String> tasksList, double hourlyRate) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Services / Tasks',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        const Gap(4),
        Text(
          'Choose one or more options to customize your booking.',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500),
        ),
        const Gap(12),

        // Tasks Grid Selection
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasksList.length,
          itemBuilder: (context, index) {
            final task = tasksList[index];
            final isSelected = _selectedTasks.contains(task);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedTasks.remove(task);
                    } else {
                      _selectedTasks.add(task);
                    }
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF6C63FF).withOpacity(0.04) : Colors.white,
                    border: Border.all(
                      color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.shade200,
                      width: 1.5,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.radio_button_off,
                        color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.shade400,
                      ),
                      const Gap(12),
                      Expanded(
                        child: Text(
                          task,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? const Color(0xFF6C63FF) : Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        const Gap(24),

        // Slider for Duration
        Text(
          'Estimated Duration',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        const Gap(4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'How many hours of service do you need?',
              style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500),
            ),
            Text(
              '${_hours.toStringAsFixed(1)} hrs',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF6C63FF),
              ),
            ),
          ],
        ),
        const Gap(8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFF6C63FF),
            inactiveTrackColor: Colors.grey.shade200,
            thumbColor: const Color(0xFF6C63FF),
            overlayColor: const Color(0xFF6C63FF).withOpacity(0.2),
            valueIndicatorColor: const Color(0xFF6C63FF),
          ),
          child: Slider(
            value: _hours,
            min: 1.0,
            max: 8.0,
            divisions: 14,
            label: '${_hours.toStringAsFixed(1)} hours',
            onChanged: (value) {
              setState(() {
                _hours = value;
              });
            },
          ),
        ),

        const Gap(24),

        // Description Note
        Text(
          'Detailed Requirements (Optional)',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        const Gap(10),
        TextField(
          controller: _descController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Describe issues, key instructions, or instructions for the handyman...',
            hintStyle: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade400),
            fillColor: const Color(0xFFF9FAFB),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // Step 2: Schedule UI
  Widget _buildStepSchedule() {
    // Generate next 7 days list
    final now = DateTime.now();
    final List<DateTime> days = List.generate(7, (index) => now.add(Duration(days: index)));

    final List<String> weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Date',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        const Gap(12),

        // Horizontal Date Selector
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            itemBuilder: (context, index) {
              final date = days[index];
              final isSelected = _selectedDateIndex == index;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedDateIndex = index;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 65,
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF6C63FF) : const Color(0xFFF9FAFB),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.shade200,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          weekdays[date.weekday % 7],
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white70 : Colors.grey.shade500,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          date.day.toString(),
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                        const Gap(2),
                        Text(
                          months[date.month - 1],
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isSelected ? Colors.white70 : Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        const Gap(28),

        Text(
          'Select Time Slot',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        const Gap(4),
        Text(
          'Choose a convenient time window for arrival.',
          style: GoogleFonts.inter(fontSize: 13, color: Colors.grey.shade500),
        ),
        const Gap(16),

        // Time slots vertical list/grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _timeSlots.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 52,
          ),
          itemBuilder: (context, index) {
            final slot = _timeSlots[index];
            final isSelected = _selectedTimeIndex == index;

            return InkWell(
              onTap: () {
                setState(() {
                  _selectedTimeIndex = index;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF6C63FF).withOpacity(0.04) : Colors.white,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.shade200,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  slot,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF6C63FF) : Colors.black87,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // Step 3: Checkout Summary UI
  Widget _buildStepSummary(double totalCost) {
    final now = DateTime.now();
    final bookingDate = now.add(Duration(days: _selectedDateIndex));
    final String dateString = "${bookingDate.day} ${_getMonthName(bookingDate.month)} ${bookingDate.year}";
    final String timeString = _selectedTimeIndex != -1 ? _timeSlots[_selectedTimeIndex] : 'Anytime';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking Summary',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const Divider(height: 24),
              
              _buildSummaryRow('Service', _serviceTitle),
              const Gap(10),
              
              _buildSummaryRow(
                'Tasks Selected', 
                _selectedTasks.isEmpty ? 'General Service' : _selectedTasks.join(', '),
              ),
              const Gap(10),

              _buildSummaryRow('Estimated Duration', '${_hours.toStringAsFixed(1)} hours'),
              const Gap(10),

              _buildSummaryRow('Schedule Date', dateString),
              const Gap(10),

              _buildSummaryRow('Time Slot', timeString),
              
              const Divider(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Estimated Cost',
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '₹${totalCost.toStringAsFixed(2)}',
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF6C63FF),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const Gap(28),

        Text(
          'Select Payment Method',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1F2937),
          ),
        ),
        const Gap(12),

        // Payment Methods Option List
        _buildPaymentOption(0, 'Cash on Delivery', Icons.payments_outlined),
        _buildPaymentOption(1, 'Handy Wallet', Icons.account_balance_wallet_outlined),
        _buildPaymentOption(2, 'Card / Net Banking', Icons.credit_card_outlined),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 13.5,
              color: Colors.black87,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(int index, String title, IconData icon) {
    final isSelected = _paymentMethodIndex == index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () {
          setState(() {
            _paymentMethodIndex = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF6C63FF).withOpacity(0.04) : Colors.white,
            border: Border.all(
              color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.shade200,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.shade600,
              ),
              const Gap(16),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF6C63FF) : Colors.black87,
                  ),
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_off,
                color: isSelected ? const Color(0xFF6C63FF) : Colors.grey.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    final List<String> months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  void _handleNextStep(double totalCost) {
    if (_currentStep == 0) {
      if (_selectedTasks.isEmpty) {
        Get.snackbar(
          'Task Required',
          'Please select at least one task to customize your service.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red.shade800,
        );
        return;
      }
      setState(() {
        _currentStep = 1;
      });
    } else if (_currentStep == 1) {
      if (_selectedTimeIndex == -1) {
        Get.snackbar(
          'Time Slot Required',
          'Please select a convenient time slot for arrival.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade50,
          colorText: Colors.red.shade800,
        );
        return;
      }
      setState(() {
        _currentStep = 2;
      });
    } else {
      // Step 2 -> Booking Confirmation Dialog
      _showSuccessDialog(totalCost);
    }
  }

  void _showSuccessDialog(double totalCost) {
    final now = DateTime.now();
    final bookingDate = now.add(Duration(days: _selectedDateIndex));
    final String timeString = _selectedTimeIndex != -1 ? _timeSlots[_selectedTimeIndex] : 'Anytime';

    if (Get.isRegistered<HandymanHomeController>()) {
      Get.find<HandymanHomeController>().placeBooking(
        serviceName: _serviceTitle,
        price: totalCost,
        serviceDate: bookingDate,
        tasks: _selectedTasks,
        timeSlot: timeString,
      );
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 64,
                  ),
                ),
                const Gap(20),
                Text(
                  'Booking Confirmed!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const Gap(10),
                Text(
                  'Your booking for $_serviceTitle was successfully placed.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13.5,
                    color: Colors.grey.shade500,
                  ),
                ),
                const Gap(20),
                const Divider(),
                const Gap(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Cost',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      '₹${totalCost.toStringAsFixed(2)}',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const Gap(24),
                ElevatedButton(
                  onPressed: () {
                    Get.close(2); // Close dialog & pop back to Handyman Screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 36),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
