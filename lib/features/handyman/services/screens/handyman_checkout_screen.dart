import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:handy_allinone/features/handyman/services/controllers/handyman_home_controller.dart';
import 'package:handy_allinone/features/handyman/services/models/handyman_service_model.dart';
import 'package:handy_allinone/features/handyman/services/models/handyman_booking_model.dart';
import 'package:handy_allinone/features/handyman/services/screens/handyman_bookings_screen.dart';
import 'package:handy_allinone/features/handyman/services/screens/handyman_services_screen.dart';
import 'package:handy_allinone/helper/address_helper.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/util/styles.dart';

class HandymanCheckoutScreen extends StatefulWidget {
  const HandymanCheckoutScreen({super.key});

  @override
  State<HandymanCheckoutScreen> createState() => _HandymanCheckoutScreenState();
}

class _HandymanCheckoutScreenState extends State<HandymanCheckoutScreen> {
  // State variables
  String _preferableTime = 'ASAP';
  bool _isProviderLocation = true;
  String _contactName = '';
  String _contactPhone = '';
  bool _agreeToTerms = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // Price formatter helper matching the pixel-perfect screenshot ($ at right, or config currency)
  String _formatPrice(double price) {
    try {
      return PriceConverter.convertPrice(price);
    } catch (_) {
      final formatter = intl.NumberFormat("#,##0.00", "en_US");
      return "${formatter.format(price)}\$";
    }
  }

  void _showCustomerDetailsDialog() {
    _nameController.text = _contactName;
    _phoneController.text = _contactPhone;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          titlePadding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          title: Text(
            'Customer Details',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
              color: const Color(0xFF1F2937),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF1F2937)),
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  labelStyle: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF6B7280)),
                  hintText: 'Enter your name',
                  hintStyle: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
                  prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFF6C63FF), size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
                  ),
                ),
              ),
              const Gap(16),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                style: GoogleFonts.inter(fontSize: 14.sp, color: const Color(0xFF1F2937)),
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  labelStyle: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF6B7280)),
                  hintText: 'Enter your phone number',
                  hintStyle: GoogleFonts.inter(fontSize: 13.sp, color: const Color(0xFF9CA3AF)),
                  prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF6C63FF), size: 20),
                  filled: true,
                  fillColor: const Color(0xFFF9FAFB),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 1.5),
                  ),
                ),
              ),
              const Gap(24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_nameController.text.trim().isEmpty || _phoneController.text.trim().isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Name and Phone cannot be empty',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        setState(() {
                          _contactName = _nameController.text.trim();
                          _contactPhone = _phoneController.text.trim();
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: Text(
                        'Save',
                        style: GoogleFonts.inter(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showTimePickerBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Preferable Time',
              style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Gap(16),
            ListTile(
              leading: const Icon(Icons.flash_on, color: Colors.amber),
              title: const Text('ASAP (As Soon As Possible)'),
              onTap: () {
                setState(() {
                  _preferableTime = 'ASAP';
                });
                Get.back();
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month, color: Color(0xFF6C63FF)),
              title: const Text('Schedule for Later'),
              onTap: () async {
                Get.back();
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: Color(0xFF6C63FF),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );

                if (pickedDate != null) {
                  final TimeOfDay? pickedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );

                  if (pickedTime != null) {
                    final formattedDate = intl.DateFormat('MMM dd, yyyy').format(pickedDate);
                    final formattedTime = pickedTime.format(context);
                    setState(() {
                      _preferableTime = '$formattedDate at $formattedTime';
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HandymanHomeController>();
    final cartItems = homeController.cartServices;

    // Calculations
    double subTotal = 0;
    for (var item in cartItems) {
      subTotal += item.startingPrice * item.cartQuantity;
    }
    final double discount = 0.00;
    final double campaignDiscount = 0.00;
    final double couponDiscount = 0.00;
    final double vat = subTotal * 0.03; // 3% VAT
    const double serviceFee = 10.00;
    final double grandTotal = subTotal + vat + serviceFee;

    final userAddress = AddressHelper.getUserAddressFromSharedPref();

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Checkout',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Text(
                'Your cart is empty',
                style: robotoRegular.copyWith(color: Colors.grey),
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(16),
                  
                  // 1. Step Progress Indicator Row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            // Step 1
                            _buildStepCircle(
                              icon: Icons.description_rounded,
                              backgroundColor: const Color(0xFFFBBF24), // amber yellow
                              isActive: true,
                            ),
                            // Line 1
                            Expanded(
                              child: Container(
                                height: 2.5,
                                color: const Color(0xFFFBBF24),
                              ),
                            ),
                            // Step 2
                            _buildStepCircle(
                              icon: Icons.credit_card_rounded,
                              backgroundColor: const Color(0xFFFFEDD5), // light orange
                              iconColor: const Color(0xFFF97316),
                              isActive: false,
                            ),
                            // Line 2
                            Expanded(
                              child: Container(
                                height: 2.5,
                                color: const Color(0xFFBBF7D0), // light green line
                              ),
                            ),
                            // Step 3
                            _buildStepCircle(
                              icon: Icons.check_circle_rounded,
                              backgroundColor: const Color(0xFFBBF7D0), // light green
                              iconColor: const Color(0xFF22C55E),
                              isActive: false,
                            ),
                          ],
                        ),
                        const Gap(6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Booking Details',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            Text(
                              'Payment',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                            Text(
                              'Complete',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF9CA3AF),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Gap(24),

                  // 2. Preferable Time
                  _buildSectionTitle('Preferable Time'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InkWell(
                      onTap: _showTimePickerBottomSheet,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _preferableTime,
                              style: GoogleFonts.inter(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                            const Icon(
                              Icons.access_time_filled_rounded,
                              color: Color(0xFF6C63FF),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const Gap(20),

                  // 3. Getting Service at
                  Row(
                    children: [
                      _buildSectionTitle('Getting Service at'),
                      const Gap(4),
                      Icon(Icons.help_outline_rounded, color: const Color(0xFF6C63FF), size: 16.sp),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          // My Location option
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _isProviderLocation = false),
                              child: Row(
                                children: [
                                  Icon(
                                    _isProviderLocation
                                        ? Icons.radio_button_off_rounded
                                        : Icons.radio_button_on_rounded,
                                    color: _isProviderLocation ? const Color(0xFF9CA3AF) : const Color(0xFF6C63FF),
                                    size: 22.sp,
                                  ),
                                  const Gap(8),
                                  Text(
                                    'My Location',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Provider Location option
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _isProviderLocation = true),
                              child: Row(
                                children: [
                                  Icon(
                                    _isProviderLocation
                                        ? Icons.radio_button_on_rounded
                                        : Icons.radio_button_off_rounded,
                                    color: _isProviderLocation ? const Color(0xFF6C63FF) : const Color(0xFF9CA3AF),
                                    size: 22.sp,
                                  ),
                                  const Gap(8),
                                  Text(
                                    'Provider Location',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const Gap(20),

                  // 4. Service Location (conditional warnings)
                  _buildSectionTitle('Service Location'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _isProviderLocation
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Light blue box
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF), // very light blue
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'You have to go to provider location in order to receive this service',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF1E40AF),
                                  ),
                                ),
                              ),
                              const Gap(10),
                              // Yellow box
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEF3C7), // very light yellow/orange
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: RichText(
                                  text: TextSpan(
                                    style: GoogleFonts.inter(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFFB45309),
                                      height: 1.3,
                                    ),
                                    children: const [
                                      TextSpan(text: 'The '),
                                      TextSpan(
                                        text: 'Service Location',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: ' will be available after a provider accepts your booking. You can view it in your ',
                                      ),
                                      TextSpan(
                                        text: 'Booking Details',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                            ),
                            child: userAddress != null
                                ? Row(
                                    children: [
                                      const Icon(Icons.location_on_rounded, color: Color(0xFF6C63FF), size: 24),
                                      const Gap(12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              userAddress.addressType?.capitalizeFirst ?? 'Selected Address',
                                              style: GoogleFonts.inter(
                                                fontSize: 13.5.sp,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF1F2937),
                                              ),
                                            ),
                                            const Gap(2),
                                            Text(
                                              userAddress.address ?? '',
                                              style: robotoRegular.copyWith(
                                                fontSize: 12.sp,
                                                color: Colors.grey.shade600,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  )
                                : Row(
                                    children: [
                                      const Icon(Icons.location_off_rounded, color: Colors.grey, size: 24),
                                      const Gap(12),
                                      Text(
                                        'No address selected. Tap to add.',
                                        style: robotoRegular.copyWith(
                                          fontSize: 13.sp,
                                          color: Colors.grey.shade500,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                  ),

                  const Gap(20),

                  // 5. Customer Details
                  _buildSectionTitle('Customer Details'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InkWell(
                      onTap: _showCustomerDetailsDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
                        ),
                        child: _contactName.isNotEmpty
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _contactName,
                                        style: GoogleFonts.inter(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                      const Gap(2),
                                      Text(
                                        _contactPhone,
                                        style: robotoRegular.copyWith(
                                          fontSize: 12.5.sp,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.edit_rounded, color: Colors.grey, size: 18),
                                ],
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Add Your Name & Phone',
                                    style: GoogleFonts.inter(
                                      fontSize: 13.5.sp,
                                      fontWeight: FontWeight.w500,
                                      color: const Color(0xFF374151),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.add_circle_outline_rounded,
                                    color: Colors.black87,
                                    size: 20,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  const Gap(24),

                  // 6. Cart Summary List
                  _buildSectionTitle('Cart Summary'),
                  Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Column(
                      children: [
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartItems[index];
                            final double itemTotal = (item.startingPrice * item.cartQuantity).toDouble();

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left side title & category
                                  Expanded(
                                    flex: 3,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: GoogleFonts.inter(
                                            fontSize: 13.5.sp,
                                            fontWeight: FontWeight.w500,
                                            color: const Color(0xFF1F2937),
                                          ),
                                        ),
                                        const Gap(2),
                                        Text(
                                          item.options.isNotEmpty && item.options[0].quantity > 0
                                              ? item.options[0].title
                                              : item.category,
                                          style: robotoRegular.copyWith(
                                            fontSize: 11.5.sp,
                                            color: Colors.grey.shade400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Center quantity multiplier
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      'x ${item.cartQuantity}',
                                      style: GoogleFonts.inter(
                                        fontSize: 13.5.sp,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF1F2937),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  // Right side price total
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      _formatPrice(itemTotal),
                                      style: GoogleFonts.inter(
                                        fontSize: 13.5.sp,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF1F2937),
                                      ),
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        
                        const Divider(height: 24, thickness: 1, color: Color(0xFFE5E7EB)),

                        // Pricing table details
                        _buildPriceRow('Sub Total', _formatPrice(subTotal)),
                        _buildPriceRow('Discount', '(-) ${_formatPrice(discount)}'),
                        _buildPriceRow('Campaign Discount', '(-) ${_formatPrice(campaignDiscount)}'),
                        _buildPriceRow('Coupon Discount', '(-) ${_formatPrice(couponDiscount)}'),
                        _buildPriceRow('VAT', '(+) ${_formatPrice(vat)}'),
                        _buildPriceRow('Service Fee', '(+) ${_formatPrice(serviceFee)}'),
                        
                        const Divider(height: 24, thickness: 1, color: Color(0xFFE5E7EB)),

                        // Grand Total row
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Grand Total',
                                style: GoogleFonts.inter(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              Text(
                                _formatPrice(grandTotal),
                                style: GoogleFonts.inter(
                                  fontSize: 14.5.sp,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Gap(16),

                  // 7. Terms & Conditions checkbox
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          activeColor: const Color(0xFF6C63FF),
                          onChanged: (val) {
                            setState(() {
                              _agreeToTerms = val ?? false;
                            });
                          },
                        ),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              color: const Color(0xFF4B5563),
                            ),
                            children: [
                              const TextSpan(text: 'I agree with the '),
                              TextSpan(
                                text: 'Terms & Conditions',
                                style: const TextStyle(
                                  color: Color(0xFF6C63FF),
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                                // Clickable terms mock
                                recognizer: null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Gap(80), // Space for bottom persistent footer bar
                ],
              ),
            ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, MediaQuery.of(context).padding.bottom + 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Price',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                      const Gap(2),
                      Text(
                        _formatPrice(grandTotal),
                        style: GoogleFonts.inter(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFEF4444), // red-pink accent
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 170.w,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!_agreeToTerms) {
                          Get.snackbar(
                            'Validation Error',
                            'You must agree with the Terms & Conditions to proceed.',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.black87,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(16),
                          );
                          return;
                        }
                        if (_contactName.isEmpty || _contactPhone.isEmpty) {
                          Get.snackbar(
                            'Validation Error',
                            'Please add your Customer Details (Name & Phone).',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.black87,
                            colorText: Colors.white,
                            margin: const EdgeInsets.all(16),
                          );
                          return;
                        }

                        // Order placement logic
                        final String firstServiceName = cartItems.isNotEmpty ? cartItems[0].name : 'Handyman Service';
                        
                        final List<String> tasks = [];
                        for (var item in cartItems) {
                          tasks.add('${item.name} (${item.cartQuantity}x)');
                        }

                        // Use placeBooking method on controller
                        homeController.placeBooking(
                          serviceName: firstServiceName,
                          price: grandTotal,
                          serviceDate: DateTime.now().add(const Duration(days: 1)),
                          tasks: tasks,
                          timeSlot: _preferableTime,
                        );
                        final String bookingId = homeController.bookings.isNotEmpty 
                            ? homeController.bookings.first.id 
                            : '100139';

                        homeController.clearCart();

                        Get.dialog(
                          AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF22C55E),
                                  size: 64,
                                ),
                                const Gap(16),
                                Text(
                                  'Booking Confirmed!',
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18.sp,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                                const Gap(10),
                                Text(
                                  'Your booking #$bookingId is confirmed. A service provider will contact you soon.',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.inter(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w400,
                                    color: const Color(0xFF4B5563),
                                    height: 1.4,
                                  ),
                                ),
                                const Gap(24),
                                SizedBox(
                                  width: double.infinity,
                                  height: 46,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Get.offAll(() => const HandymanServicesScreen(initialPageIndex: 2));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF6C63FF),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'View Bookings',
                                      style: GoogleFonts.inter(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          barrierDismissible: false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Make Payment',
                        style: GoogleFonts.inter(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStepCircle({
    required IconData icon,
    required Color backgroundColor,
    Color iconColor = Colors.white,
    bool isActive = false,
  }) {
    return Container(
      width: 36.sp,
      height: 36.sp,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: isActive
            ? Border.all(color: const Color(0xFFD97706), width: 1.5) // highlighted amber border for active step
            : null,
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        color: iconColor,
        size: 18.sp,
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Text(
        title,
        style: GoogleFonts.inter(
          fontSize: 14.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF1F2937),
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF4B5563),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.inter(
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }
}
