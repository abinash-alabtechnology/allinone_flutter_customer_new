import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:handy_allinone/features/handyman/services/controllers/handyman_home_controller.dart';
import 'package:handy_allinone/features/handyman/services/screens/handyman_services_screen.dart';
import 'package:handy_allinone/helper/address_helper.dart';
import 'package:handy_allinone/helper/price_converter.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:handy_allinone/features/checkout/controllers/checkout_controller.dart';
import 'package:handy_allinone/features/checkout/domain/models/place_order_body_model.dart';
import 'package:handy_allinone/helper/auth_helper.dart';
import 'package:handy_allinone/features/cart/controllers/cart_controller.dart';
import 'package:handy_allinone/helper/module_helper.dart';
import 'package:handy_allinone/features/profile/controllers/profile_controller.dart';
import 'package:handy_allinone/features/address/domain/models/address_model.dart';
import 'package:handy_allinone/features/splash/controllers/splash_controller.dart';
import 'package:handy_allinone/api/api_client.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/helper/date_converter.dart';

class HandymanCheckoutScreen extends StatefulWidget {
  const HandymanCheckoutScreen({super.key});

  @override
  State<HandymanCheckoutScreen> createState() => _HandymanCheckoutScreenState();
}

class _HandymanCheckoutScreenState extends State<HandymanCheckoutScreen> {
  // State variables
  late String _preferableTime;
  late DateTime _scheduledDateTime;
  bool _isProviderLocation = true;
  String _contactName = '';
  String _contactPhone = '';
  bool _agreeToTerms = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _isProviderLocation = false;
    final now = DateTime.now();
    _scheduledDateTime = DateTime(now.year, now.month, now.day + 1, 10, 0);
    final formattedDate = intl.DateFormat('MMM dd, yyyy').format(_scheduledDateTime);
    final formattedTime = intl.DateFormat('hh:mm a').format(_scheduledDateTime);
    _preferableTime = '$formattedDate at $formattedTime';
    _initCustomerDetailsAndAddress();
  }

  void _initCustomerDetailsAndAddress() {
    if (Get.isRegistered<ProfileController>()) {
      final user = Get.find<ProfileController>().userInfoModel;
      if (user != null) {
        String name = '${user.fName ?? ''} ${user.lName ?? ''}'.trim();
        if (name.isNotEmpty) _contactName = name;
        if (user.phone != null && user.phone!.isNotEmpty) _contactPhone = user.phone!;
      }
    }

    final AddressModel? savedAddress = AddressHelper.getUserAddressFromSharedPref();
    if (savedAddress != null) {
      if (_contactName.isEmpty && savedAddress.contactPersonName != null && savedAddress.contactPersonName!.isNotEmpty) {
        _contactName = savedAddress.contactPersonName!;
      }
      if (_contactPhone.isEmpty && savedAddress.contactPersonNumber != null && savedAddress.contactPersonNumber!.isNotEmpty) {
        _contactPhone = savedAddress.contactPersonNumber!;
      }
    }

    _nameController.text = _contactName;
    _phoneController.text = _contactPhone;
  }

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

  void _showTimePickerBottomSheet() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _scheduledDateTime.isAfter(now) ? _scheduledDateTime : now.add(const Duration(days: 1));

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
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
      if (!mounted) return;
      final TimeOfDay initialTime = TimeOfDay(hour: _scheduledDateTime.hour, minute: _scheduledDateTime.minute);
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );

      if (pickedTime != null) {
        final DateTime selectedDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        final formattedDate = intl.DateFormat('MMM dd, yyyy').format(selectedDateTime);
        final formattedTime = intl.DateFormat('hh:mm a').format(selectedDateTime);

        setState(() {
          _scheduledDateTime = selectedDateTime;
          _preferableTime = '$formattedDate at $formattedTime';
        });
      }
    }
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
                              'Confirm Order',
                              style: GoogleFonts.inter(
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF6C63FF),
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

                  // 2. Schedule Order
                  _buildSectionTitle('Schedule Order'),
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

                  // 5.5 Payment Method (COD for Handyman)
                  _buildSectionTitle('Payment Method'),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.3), width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.money_rounded, color: Color(0xFF6C63FF), size: 24),
                          ),
                          const Gap(14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cash On Delivery (COD)',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                                const Gap(2),
                                Text(
                                  'Pay with cash after service completion',
                                  style: robotoRegular.copyWith(
                                    fontSize: 11.5.sp,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF6C63FF), size: 22),
                        ],
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
                      onPressed: () async {
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

                        // Build PlaceOrderBodyModel for API checkout via COD
                        List<OnlineCart> onlineCarts = [];
                        for (var item in cartItems) {
                          int itemId = int.tryParse(item.id) ?? (item.id.hashCode & 0x7FFFFFFF);
                          onlineCarts.add(OnlineCart(
                            null,
                            itemId,
                            null,
                            item.startingPrice.toString(),
                            '',
                            null,
                            [],
                            item.cartQuantity,
                            [],
                            [],
                            [],
                            'Item',
                            false,
                          ));
                        }

                        int? providerStoreId;
                        if (Get.isRegistered<CartController>()) {
                          final cartList = Get.find<CartController>().cartList;
                          for (var c in cartList) {
                            if (c.item != null && c.item!.storeId != null && c.item!.storeId! > 0) {
                              providerStoreId = c.item!.storeId;
                              break;
                            }
                          }
                        }
                        if (providerStoreId == null && cartItems.isNotEmpty) {
                          for (var item in cartItems) {
                            if (item.storeId != null && item.storeId! > 0) {
                              providerStoreId = item.storeId;
                              break;
                            }
                          }
                        }
                        providerStoreId ??= ModuleHelper.getModule()?.id ?? 1;

                        String formattedScheduleAt = DateConverter.dateToDateAndTime(_scheduledDateTime);

                        PlaceOrderBodyModel placeOrderBody = PlaceOrderBodyModel(
                          cart: onlineCarts,
                          couponDiscountAmount: 0.0,
                          couponCode: '',
                          orderAmount: grandTotal,
                          orderType: 'delivery',
                          paymentMethod: 'cash_on_delivery',
                          storeId: providerStoreId,
                          distance: 0.0,
                          scheduleAt: formattedScheduleAt,
                          discountAmount: discount,
                          taxAmount: vat,
                          orderNote: '',
                          address: userAddress?.address ?? '',
                          receiverDetails: null,
                          latitude: userAddress?.latitude ?? '',
                          longitude: userAddress?.longitude ?? '',
                          contactPersonName: _contactName,
                          contactPersonNumber: _contactPhone,
                          addressType: userAddress?.addressType ?? 'home',
                          parcelCategoryId: null,
                          chargePayer: null,
                          dmTips: '0',
                          unavailableItemNote: '',
                          cutlery: 0,
                          partialPayment: 0,
                          guestId: AuthHelper.isLoggedIn() ? 0 : (int.tryParse(AuthHelper.getGuestId()) ?? 0),
                          isBuyNow: 0,
                          extraPackagingAmount: 0.0,
                          createNewUser: 0,
                          password: '',
                        );

                        int? handymanModuleId;
                        if (Get.isRegistered<CartController>()) {
                          for (var c in Get.find<CartController>().cartList) {
                            if (c.item?.moduleId != null && c.item!.moduleId! > 0 && c.item?.moduleType?.toLowerCase() == 'handyman') {
                              handymanModuleId = c.item!.moduleId;
                              break;
                            }
                          }
                        }
                        if (handymanModuleId == null && Get.isRegistered<SplashController>()) {
                          final hMod = Get.find<SplashController>().moduleList?.firstWhereOrNull((m) {
                            String name = m.moduleName?.toLowerCase() ?? '';
                            String type = m.moduleType?.toLowerCase() ?? '';
                            return name.contains('handyman') || type.contains('handyman');
                          });
                          if (hMod != null && hMod.id != null) {
                            handymanModuleId = hMod.id;
                          }
                        }
                        handymanModuleId ??= 10;

                        if (Get.isRegistered<ApiClient>()) {
                          Get.find<ApiClient>().updateHeader(
                            Get.find<ApiClient>().token,
                            userAddress?.zoneIds,
                            userAddress?.areaIds,
                            Get.find<ApiClient>().sharedPreferences.getString(AppConstants.languageCode),
                            handymanModuleId,
                            userAddress?.latitude,
                            userAddress?.longitude,
                          );
                        }

                        String apiOrderId = '';
                        if (Get.isRegistered<CheckoutController>()) {
                          int? zoneId = userAddress?.zoneId ?? (ModuleHelper.getModule()?.id);
                          apiOrderId = await Get.find<CheckoutController>().placeOrder(
                            placeOrderBody,
                            zoneId,
                            grandTotal,
                            0.0,
                            true,
                            true,
                            [],
                          );
                        }

                        // ONLY proceed with booking confirmation popup IF apiOrderId is valid (200 success response)!
                        if (apiOrderId.isNotEmpty && apiOrderId != '-1') {
                          final String firstServiceName = cartItems.isNotEmpty ? cartItems[0].name : 'Handyman Service';

                          final List<String> tasks = [];
                          for (var item in cartItems) {
                            tasks.add('${item.name} (${item.cartQuantity}x)');
                          }

                          homeController.placeBooking(
                            serviceName: firstServiceName,
                            price: grandTotal,
                            serviceDate: _scheduledDateTime,
                            tasks: tasks,
                            timeSlot: _preferableTime,
                          );

                          homeController.clearCart();
                          if (Get.isRegistered<CartController>()) {
                            Get.find<CartController>().clearCartOnline();
                          }

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
                                    'Your booking #$apiOrderId is confirmed. A service provider will contact you soon.',
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
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            barrierDismissible: false,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Place Order',
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
