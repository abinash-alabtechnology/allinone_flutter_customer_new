import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' as intl;
import 'package:handy_allinone/features/handyman/services/models/handyman_booking_model.dart';
import 'package:handy_allinone/util/styles.dart';

class HandymanBookingDetailsScreen extends StatefulWidget {
  final HandymanBookingModel booking;
  const HandymanBookingDetailsScreen({super.key, required this.booking});

  @override
  State<HandymanBookingDetailsScreen> createState() => _HandymanBookingDetailsScreenState();
}

class _HandymanBookingDetailsScreenState extends State<HandymanBookingDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    final List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[dt.month - 1];
    final year = dt.year;
    final day = dt.day;
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return "$day $month, $year ${hour.toString().padLeft(2, '0')}:$minute $ampm";
  }

  String _formatPrice(double price) {
    final formatter = intl.NumberFormat("#,##0.00", "en_US");
    return "₹${formatter.format(price)}";
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFF59E0B); // Amber
      case 'Accepted':
        return const Color(0xFF6C63FF); // Purple
      case 'Ongoing':
        return const Color(0xFF3B82F6); // Blue
      case 'Completed':
        return const Color(0xFF10B981); // Green
      case 'Cancelled':
        return const Color(0xFFEF4444); // Red
      default:
        return Colors.grey;
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'Pending':
        return const Color(0xFFFFFBEB);
      case 'Accepted':
        return const Color(0xFFEEF2FF);
      case 'Ongoing':
        return const Color(0xFFEFF6FF);
      case 'Completed':
        return const Color(0xFFECFDF5);
      case 'Cancelled':
        return const Color(0xFFFEF2F2);
      default:
        return Colors.grey.shade50;
    }
  }

  @override
  Widget build(BuildContext context) {
    final brandColor = const Color(0xFF6C63FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: brandColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Booking Details',
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
          // Premium Floating Pill Tab Bar Selector
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: brandColor,
            child: Container(
              height: 46,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.12),
                borderRadius: BorderRadius.circular(23),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 5,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: brandColor,
                unselectedLabelColor: Colors.white.withOpacity(0.9),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                ),
                unselectedLabelStyle: GoogleFonts.inter(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [
                  Tab(text: 'Booking Details'),
                  Tab(text: 'Status'),
                ],
              ),
            ),
          ),

          // Main contents
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBookingDetailsTab(),
                _buildStatusTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildProviderActions(),
    );
  }

  Widget _buildBookingDetailsTab() {
    final booking = widget.booking;
    final brandColor = const Color(0xFF6C63FF);

    return Stack(
      children: [
        // Decorative Indigo-to-Purple header background curve
        Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [brandColor, brandColor.withOpacity(0.8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
          ),
        ),

        // Scrollable content area
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // 1. Unified Receipt Ticket Card
              Card(
                elevation: 6,
                color: Colors.white,
                shadowColor: Colors.black.withOpacity(0.08),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Area with Booking ID and Stamp
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Booking #${booking.id}',
                                style: GoogleFonts.inter(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF111827),
                                ),
                              ),

                            ],
                          ),
                          // Rotate stamp overlay
                          TactileStampWidget(
                            text: booking.status == 'Completed' ? 'PAID' : booking.status,
                            color: _getStatusColor(booking.status),
                          ),
                        ],
                      ),
                    ),

                    // First cutout perforation divider
                    const PerforationDivider(),

                    // Core booking info section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Column(
                        children: [
                          _buildIconTextRow(
                            icon: Icons.calendar_today_rounded,
                            text: 'Booking Date: ${_formatDate(booking.bookingDate)}',
                          ),
                          const Gap(12),
                          _buildIconTextRow(
                            icon: Icons.schedule_rounded,
                            text: 'Service Schedule Date: ${_formatDate(booking.serviceDate)}',
                          ),
                          const Gap(12),
                          _buildIconTextRow(
                            icon: Icons.location_on_rounded,
                            text: 'Address: ${booking.address}',
                          ),
                        ],
                      ),
                    ),

                    // Second cutout perforation divider
                    const PerforationDivider(),

                    // Payment details
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment Method',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                booking.paymentMethod,
                                style: GoogleFonts.inter(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                booking.paymentStatus,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: booking.paymentStatus.toLowerCase() == 'paid'
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFEF4444),
                                ),
                              ),
                              const Gap(4),
                              Text(
                                _formatPrice(booking.price),
                                style: GoogleFonts.inter(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: brandColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Third cutout perforation divider
                    const PerforationDivider(),

                    // Billing / Invoice Details
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Booking Summary',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF111827),
                            ),
                          ),
                          Icon(Icons.receipt_long_rounded, color: brandColor, size: 20),
                        ],
                      ),
                    ),

                    // Invoice Header Table
                    Container(
                      color: const Color(0xFFF3F4F6),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Service Info',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          Text(
                            'Price',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Billing Items
                    if (booking.items.isNotEmpty)
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: booking.items.length,
                        separatorBuilder: (context, index) => const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6)),
                        itemBuilder: (context, index) {
                          final item = booking.items[index];
                          final itemTotal = item.quantity * item.unitPrice;

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.title,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                          color: const Color(0xFF1F2937),
                                        ),
                                      ),
                                      const Gap(4),
                                      Text(
                                        '${item.variantName}  •  Qty: ${item.quantity}',
                                        style: GoogleFonts.inter(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                      const Gap(2),
                                      Text(
                                        'Unit price: ${_formatPrice(item.unitPrice)}',
                                        style: GoogleFonts.inter(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _formatPrice(itemTotal),
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1F2937),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    booking.serviceName,
                                    style: GoogleFonts.inter(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF1F2937),
                                    ),
                                  ),
                                  const Gap(4),
                                  Text(
                                    '${booking.tasks.join(", ")}  •  Qty: 1',
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  const Gap(2),
                                  Text(
                                    'Unit price: ${_formatPrice(booking.subTotal > 0 ? booking.subTotal : booking.price)}',
                                    style: GoogleFonts.inter(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              _formatPrice(booking.subTotal > 0 ? booking.subTotal : booking.price),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                      ),

                    const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),

                    // Subtotal Breakdowns
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Column(
                        children: [
                          _buildSummaryRow(
                            'Sub Total',
                            _formatPrice(booking.subTotal > 0 ? booking.subTotal : booking.price),
                          ),
                          const Gap(8),
                          _buildSummaryRow(
                            'Service discount',
                            '(-) ${_formatPrice(booking.discount)}',
                          ),
                          const Gap(8),
                          _buildSummaryRow(
                            'Coupon Discount',
                            '(-) ${_formatPrice(booking.couponDiscount)}',
                          ),
                          const Gap(8),
                          _buildSummaryRow(
                            'Campaign Discount',
                            '(-) ${_formatPrice(booking.campaignDiscount)}',
                          ),
                          const Gap(8),
                          _buildSummaryRow(
                            'Service Vat',
                            '(+) ${_formatPrice(booking.vat)}',
                          ),
                          const Gap(8),
                          _buildSummaryRow(
                            'Service Fee',
                            '(+) ${_formatPrice(booking.fee)}',
                          ),
                        ],
                      ),
                    ),

                    // Fourth cutout perforation divider
                    const PerforationDivider(),

                    // Grand Total
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Grand Total',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: brandColor,
                            ),
                          ),
                          Text(
                            _formatPrice(booking.price),
                            style: GoogleFonts.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: brandColor,
                            ),
                          ),
                        ],
                      ),
                    ),



                    // Jagged Bottom edge simulation
                    ClipPath(
                      clipper: SerratedBottomClipper(),
                      child: Container(
                        height: 8,
                        color: const Color(0xFFF3F4F6),
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(16),

              // 2. Map route card preview (replacing plain location box)
              Card(
                elevation: 4,
                shadowColor: Colors.black.withOpacity(0.06),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Service Location Tracker',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF111827),
                        ),
                      ),
                      const Gap(12),
                      const GpsRouteWidget(),
                      const Gap(14),
                      Text(
                        'Scheduled Address',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      const Gap(4),
                      Text(
                        booking.address,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTab() {
    final booking = widget.booking;
    final brandColor = const Color(0xFF6C63FF);

    // Determine steps status
    bool isPlaced = true;
    bool isAccepted = booking.status == 'Accepted' ||
        booking.status == 'Ongoing' ||
        booking.status == 'Completed';
    bool isOngoing = booking.status == 'Ongoing' || booking.status == 'Completed';
    bool isCompleted = booking.status == 'Completed';
    bool isCancelled = booking.status == 'Cancelled';

    return Stack(
      children: [
        // Decorative Indigo-to-Purple header background curve
        Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [brandColor, brandColor.withOpacity(0.8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(36),
              bottomRight: Radius.circular(36),
            ),
          ),
        ),

        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circular Progress ring dashboard
              Card(
                elevation: 3,
                shadowColor: Colors.black.withOpacity(0.04),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    children: [
                      StatusProgressGauge(status: booking.status),
                      const Gap(16),
                      Center(
                        child: Text(
                          isCancelled
                              ? 'This booking request was cancelled.'
                              : (isCompleted
                                  ? 'Your service is fully completed!'
                                  : 'Estimated provider arrival: 10-15 mins'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF4B5563),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(24),

              Text(
                'Timeline Progress',
                style: GoogleFonts.inter(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              const Gap(20),

              // Stepper Timeline with glowing indicators
              _buildTimelineStep(
                title: 'Booking Placed',
                subtitle: 'Booking request placed successfully.',
                dateTime: _formatDate(booking.bookingDate),
                icon: Icons.assignment_turned_in_rounded,
                isActive: isPlaced,
                isLast: false,
              ),
              if (isCancelled)
                _buildTimelineStep(
                  title: 'Booking Cancelled',
                  subtitle: 'This booking has been cancelled.',
                  dateTime: _formatDate(booking.serviceDate),
                  icon: Icons.cancel_rounded,
                  isActive: true,
                  isLast: true,
                  isError: true,
                )
              else ...[
                _buildTimelineStep(
                  title: 'Booking Accepted',
                  subtitle: 'A provider has accepted your booking.',
                  dateTime: isAccepted ? _formatDate(booking.serviceDate.subtract(const Duration(minutes: 5))) : '',
                  icon: Icons.person_pin_rounded,
                  isActive: isAccepted,
                  isLast: false,
                ),
                _buildTimelineStep(
                  title: 'Service Ongoing',
                  subtitle: 'Provider is at your location and performing tasks.',
                  dateTime: isOngoing ? _formatDate(booking.serviceDate) : '',
                  icon: Icons.build_rounded,
                  isActive: isOngoing,
                  isLast: false,
                ),
                _buildTimelineStep(
                  title: 'Service Completed',
                  subtitle: 'Service has been marked completed.',
                  dateTime: isCompleted ? _formatDate(booking.serviceDate.add(const Duration(hours: 1))) : '',
                  icon: Icons.check_circle_rounded,
                  isActive: isCompleted,
                  isLast: true,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconTextRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16.5,
          color: const Color(0xFF7C8BA1),
        ),
        const Gap(10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4B5563),
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF4B5563),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildProviderActions() {
    final booking = widget.booking;
    if (booking.status != 'Accepted' && booking.status != 'Ongoing') {
      return const SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade100, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Get.snackbar(
                  'Call Support',
                  'Dialing provider (+880 1712-345678)...',
                  backgroundColor: const Color(0xFF6C63FF),
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                );
              },
              icon: const Icon(Icons.phone_rounded, color: Colors.white, size: 18),
              label: const Text('Call Provider'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
          const Gap(12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Get.snackbar(
                  'Chat Support',
                  'Opening chat with Provider...',
                  backgroundColor: const Color(0xFF6C63FF),
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                );
              },
              icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 18),
              label: const Text('Chat Support'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required String dateTime,
    required IconData icon,
    required bool isActive,
    required bool isLast,
    bool isError = false,
  }) {
    final markerColor = isError
        ? const Color(0xFFEF4444)
        : (isActive ? const Color(0xFF6C63FF) : Colors.grey.shade300);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Glowing status ring node
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isError
                      ? const Color(0xFFFEF2F2)
                      : (isActive ? const Color(0xFFEEF2FF) : Colors.grey.shade50),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: markerColor,
                    width: 2.5,
                  ),
                  boxShadow: isActive && !isError
                      ? [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withOpacity(0.15),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Icon(
                    icon,
                    size: 14,
                    color: markerColor,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.5,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: isActive && !isError ? const Color(0xFF6C63FF) : Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
            ],
          ),
          const Gap(16),

          // Stepper text content block
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isActive ? const Color(0xFF111827) : Colors.grey.shade400,
                        ),
                      ),
                      if (dateTime.isNotEmpty)
                        Text(
                          dateTime,
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade400,
                          ),
                        ),
                    ],
                  ),
                  const Gap(5),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      color: isActive ? const Color(0xFF4B5563) : Colors.grey.shade400,
                      height: 1.3,
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
}

// ─── Custom UI Helper Widgets ──────────────────────────────────────────────────

class PerforationDivider extends StatelessWidget {
  const PerforationDivider({super.key});

  @override
  Widget build(BuildContext context) {
    const cutoutBgColor = Color(0xFFF9FAFB);

    return Container(
      color: Colors.white,
      height: 20,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dotted middle line
          Row(
            children: List.generate(
              32,
              (index) => Expanded(
                child: Container(
                  height: 1.5,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  color: index % 2 == 0 ? Colors.transparent : Colors.grey.shade200,
                ),
              ),
            ),
          ),

          // Left notch cutout shape
          Positioned(
            left: -8,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: cutoutBgColor,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Right notch cutout shape
          Positioned(
            right: -8,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: cutoutBgColor,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SerratedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);

    double x = size.width;
    const step = 8.0;
    bool up = true;
    while (x > 0) {
      x -= step;
      if (x < 0) x = 0;
      path.lineTo(x, size.height - (up ? 4.0 : 0));
      up = !up;
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class TactileStampWidget extends StatelessWidget {
  final String text;
  final Color color;

  const TactileStampWidget({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.18, // ~10 degrees tilt
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          border: Border.all(color: color.withOpacity(0.55), width: 1.5),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.55), width: 0.8),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            text.toUpperCase(),
            style: GoogleFonts.robotoMono(
              color: color.withOpacity(0.65),
              fontSize: 11.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}

class GpsRouteWidget extends StatelessWidget {
  const GpsRouteWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            CustomPaint(
              painter: GpsRoutePainter(),
              child: const SizedBox.expand(),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.snackbar(
                    'GPS Navigation',
                    'Connecting to Google Maps provider route...',
                    backgroundColor: const Color(0xFF6C63FF),
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                  );
                },
                icon: const Icon(Icons.navigation_rounded, size: 13, color: Colors.white),
                label: Text(
                  'Track Live',
                  style: GoogleFonts.inter(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  elevation: 3,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: Size.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GpsRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw street grid
    const spacing = 18.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw main roads
    final roadPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(const Offset(-10, 45), Offset(size.width + 10, 85), roadPaint);
    canvas.drawLine(Offset(size.width * 0.25, -10), Offset(size.width * 0.75, size.height + 10), roadPaint);

    // Dotted routing line
    final routePaint = Paint()
      ..color = const Color(0xFF6C63FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final start = Offset(size.width * 0.2, size.height * 0.7);
    final end = Offset(size.width * 0.8, size.height * 0.35);
    final control = Offset(size.width * 0.55, size.height * 0.2);

    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);

    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      const dWidth = 5.0;
      const dSpace = 4.0;
      double distance = 0.0;
      while (distance < metric.length) {
        final segment = metric.extractPath(distance, distance + dWidth);
        canvas.drawPath(segment, routePaint);
        distance += dWidth + dSpace;
      }
    }

    // Customer pin (Start node)
    final startGlow = Paint()
      ..color = const Color(0xFF6C63FF).withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(start, 11, startGlow);

    final startPin = Paint()
      ..color = const Color(0xFF6C63FF)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(start, 4.5, startPin);

    // Provider pin (End node)
    final endGlow = Paint()
      ..color = Colors.greenAccent.withOpacity(0.25)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(end, 11, endGlow);

    final endPin = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.fill;
    canvas.drawCircle(end, 4.5, endPin);

    // Tooltip
    final tPainter = TextPainter(
      text: TextSpan(
        text: 'Ambulance',
        style: GoogleFonts.inter(
          fontSize: 8.5,
          fontWeight: FontWeight.w900,
          color: Colors.white70,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tPainter.paint(canvas, Offset(end.dx - tPainter.width / 2, end.dy - 18));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StatusProgressGauge extends StatelessWidget {
  final String status;
  const StatusProgressGauge({super.key, required this.status});

  double _getProgressPercentage() {
    switch (status) {
      case 'Pending':
        return 0.25;
      case 'Accepted':
        return 0.50;
      case 'Ongoing':
        return 0.75;
      case 'Completed':
        return 1.00;
      case 'Cancelled':
        return 0.0;
      default:
        return 0.10;
    }
  }

  @override
  Widget build(BuildContext context) {
    final pct = _getProgressPercentage();
    final color = status == 'Cancelled'
        ? const Color(0xFFEF4444)
        : (status == 'Completed'
            ? const Color(0xFF10B981)
            : const Color(0xFF6C63FF));

    return Center(
      child: Container(
        width: 130,
        height: 130,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: pct,
                strokeWidth: 7,
                backgroundColor: Colors.grey.shade100,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                strokeCap: StrokeCap.round,
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    status == 'Cancelled'
                        ? Icons.cancel_outlined
                        : (status == 'Completed'
                            ? Icons.verified_outlined
                            : Icons.hourglass_empty_rounded),
                    color: color,
                    size: 26,
                  ),
                  const Gap(3),
                  Text(
                    '${(pct * 100).toInt()}%',
                    style: GoogleFonts.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    status,
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
