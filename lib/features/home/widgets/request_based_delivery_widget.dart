import 'dart:io';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show PathMetric;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:handy_allinone/features/home/controllers/delivery_quotation_controller.dart';
import 'package:handy_allinone/common/widgets/custom_snackbar.dart';

class RequestBasedDeliveryWidget extends StatefulWidget {
  const RequestBasedDeliveryWidget({super.key});

  @override
  State<RequestBasedDeliveryWidget> createState() =>
      _RequestBasedDeliveryWidgetState();
}

class _RequestBasedDeliveryWidgetState extends State<RequestBasedDeliveryWidget>
    with SingleTickerProviderStateMixin {
  int _activeStep = 0;
  Timer? _timer;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _activeStep = (_activeStep + 1) % 3;
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _onStepTap(int index) {
    _stopTimer();
    setState(() {
      _activeStep = index;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DeliveryQuotationController>(
      builder: (deliveryQuotationController) {
        return Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, const Color(0xFFF4FBF7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.06),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
            border: Border.all(
              color: Colors.green.withOpacity(0.15),
              width: 1.5,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delivery_dining,
                      color: Colors.green,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Request-Based Delivery',
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 26),

              _buildHowItWorks(),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      onTap: () => deliveryQuotationController.pickImage(
                        ImageSource.camera,
                      ),
                      icon: Icons.camera_alt_outlined,
                      label: 'Camera',
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      onTap: () => deliveryQuotationController.pickImage(
                        ImageSource.gallery,
                      ),
                      icon: Icons.photo_library_outlined,
                      label: 'Gallery',
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),

              if (deliveryQuotationController.pickedImages.isNotEmpty) ...[
                const SizedBox(height: 16),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: deliveryQuotationController.pickedImages.length,
                    itemBuilder: (context, index) {
                      return Stack(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.green.withOpacity(0.3),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.file(
                                File(
                                  deliveryQuotationController
                                      .pickedImages[index]
                                      .path,
                                ),
                                height: 100,
                                width: 100,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 5,
                            right: 15,
                            child: GestureDetector(
                              onTap: () => deliveryQuotationController
                                  .removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: deliveryQuotationController.isLoading
                        ? null
                        : () {
                            Get.dialog(
                              AlertDialog(
                                title: const Text('Confirm Submission'),
                                content: const Text(
                                  'Are you sure you want to submit these images for a delivery quotation?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Get.back();
                                      deliveryQuotationController
                                          .uploadQuotationImages();
                                    },
                                    child: const Text('Confirm'),
                                  ),
                                ],
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: deliveryQuotationController.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Submit Quotation',
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.orange,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'For Order Confirmation Our team will Reach you',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHowItWorks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How it works',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.green.withOpacity(0.1)),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (Widget child, Animation<double> animation) {
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.0, 0.1),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                ),
              );
            },
            child: _buildShowcaseCard(_activeStep),
          ),
        ),
        const SizedBox(height: 24),
        _buildHorizontalStepper(),
      ],
    );
  }

  Widget _buildShowcaseCard(int step) {
    switch (step) {
      case 0:
        return _buildStepOneShowcase();
      case 1:
        return _buildStepTwoShowcase();
      case 2:
        return _buildStepThreeShowcase();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStepOneShowcase() {
    return Row(
      key: const ValueKey(0),
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'STEP 01',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Capture & Upload',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Take a photo of your handwritten shopping list, or choose screenshots/images of items from your gallery.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 4,
          child: Center(
            child: _buildPhoneMockupFrame(child: _buildStepOneAnimation()),
          ),
        ),
      ],
    );
  }

  Widget _buildStepOneAnimation() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        // Calculate scanning line position (0.0 to 1.0 back and forth)
        final double scanProgress =
            (math.sin(_animationController.value * 2 * math.pi) + 1.0) / 2.0;

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Shopping list paper container
              Container(
                width: 60,
                height: 80,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Mock Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 25,
                          height: 4,
                          color: Colors.grey.shade400,
                        ),
                        const Icon(
                          Icons.receipt_long,
                          size: 8,
                          color: Colors.green,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Mock list items
                    _buildMockListLine(35),
                    _buildMockListLine(42),
                    _buildMockListLine(28),
                    _buildMockListLine(38),
                    _buildMockListLine(30),
                  ],
                ),
              ),

              // Pulsing Camera icon at the center
              Positioned(
                top: 30,
                child: Transform.scale(
                  scale:
                      1.0 +
                      (math.sin(_animationController.value * 2 * math.pi) *
                          0.1),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Animated Scanner Line
              Positioned(
                top: 8.0 + (scanProgress * 74.0), // Moves within paper area
                left: 12,
                right: 12,
                child: Container(
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.8),
                        blurRadius: 4,
                        spreadRadius: 1.5,
                      ),
                    ],
                  ),
                ),
              ),

              // Uploading indicator
              Positioned(
                bottom: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.4),
                      width: 0.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 6,
                        height: 6,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'UPLOADING...',
                        style: GoogleFonts.inter(
                          fontSize: 6,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMockListLine(double width) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.5),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 3,
            decoration: const BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 3),
          Container(
            width: width,
            height: 3,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepTwoShowcase() {
    return Row(
      key: const ValueKey(1),
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'STEP 02',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Team Review',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Our team reviews your list and checks availability across multiple local stores to find the best prices.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 4,
          child: Center(
            child: _buildPhoneMockupFrame(child: _buildStepTwoAnimation()),
          ),
        ),
      ],
    );
  }

  Widget _buildStepTwoAnimation() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final double value = _animationController.value;
        final bool isChecked1 = value > 0.25;
        final bool isChecked2 = value > 0.55;
        final bool isChecked3 = value > 0.8;
        final bool isVerified = value > 0.9;

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Checklist Card
              Container(
                width: 65,
                height: 85,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.15),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'ITEMS CHECK',
                          style: GoogleFonts.inter(
                            fontSize: 6,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade800,
                          ),
                        ),
                        Icon(
                          Icons.checklist,
                          size: 8,
                          color: Colors.orange.shade700,
                        ),
                      ],
                    ),
                    const Divider(height: 6, thickness: 0.5),
                    const SizedBox(height: 2),

                    // Checklist items
                    _buildStepTwoCheckItem('Milk 🥛', isChecked1),
                    _buildStepTwoCheckItem('Bread 🍞', isChecked2),
                    _buildStepTwoCheckItem('Apples 🍎', isChecked3),
                  ],
                ),
              ),

              // Pulsing Review Status Badge
              Positioned(
                bottom: 8,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2.5,
                  ),
                  decoration: BoxDecoration(
                    color: isVerified ? Colors.green : Colors.orange.shade700,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: (isVerified ? Colors.green : Colors.orange)
                            .withOpacity(0.3),
                        blurRadius: 4,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isVerified) ...[
                        const SizedBox(
                          width: 6,
                          height: 6,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        isVerified ? 'VERIFIED ✓' : 'REVIEWING...',
                        style: GoogleFonts.inter(
                          fontSize: 6,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepTwoCheckItem(String label, bool isChecked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(0.5),
            decoration: BoxDecoration(
              color: isChecked ? Colors.green : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isChecked ? Colors.green : Colors.grey.shade400,
                width: 0.8,
              ),
            ),
            child: Icon(
              Icons.check,
              size: 5,
              color: isChecked ? Colors.white : Colors.transparent,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 6.5,
                fontWeight: isChecked ? FontWeight.w500 : FontWeight.bold,
                decoration: isChecked ? TextDecoration.lineThrough : null,
                color: isChecked ? Colors.grey.shade400 : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepThreeShowcase() {
    return Row(
      key: const ValueKey(2),
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'STEP 03',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Confirm & Deliver',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'We call you to confirm the items and pricing, then quickly dispatch a rider to deliver to your location.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 4,
          child: Center(
            child: _buildPhoneMockupFrame(child: _buildStepThreeAnimation()),
          ),
        ),
      ],
    );
  }

  Widget _buildStepThreeAnimation() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Lottie.asset(
        'assets/animation/delivery_bike.json',
        fit: BoxFit.contain,
        repeat: true,
        errorBuilder: (context, error, stackTrace) {
          return _buildStepThreeFallbackAnimation();
        },
      ),
    );
  }

  Widget _buildStepThreeFallbackAnimation() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final double progress = _animationController.value;
        // Map progress to translate the bike from left to right (-25 to 55)
        final double bikeX = -25.0 + (progress * 80.0);
        // Subtle vertical bounce for a driving effect
        final double bikeY = math.sin(progress * 4 * math.pi) * 2.0;

        return Stack(
          alignment: Alignment.center,
          children: [
            // Road/Track line
            Positioned(
              bottom: 25,
              left: 5,
              right: 5,
              child: Container(
                height: 2.5,
                decoration: BoxDecoration(
                  color: Colors.blue.shade300,
                  borderRadius: BorderRadius.circular(1.2),
                ),
              ),
            ),

            // Dotted guide line
            Positioned(
              bottom: 26,
              left: 8,
              right: 8,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  8,
                  (index) => Container(
                    width: 3,
                    height: 1,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ),

            // Destination House/Marker Icon
            Positioned(
              right: 8,
              bottom: 23,
              child: Transform.scale(
                scale:
                    1.0 +
                    (math.sin(_animationController.value * 2 * math.pi) * 0.08),
                child: Container(
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.home, size: 10, color: Colors.white),
                ),
              ),
            ),

            // Moving Scooter
            Positioned(
              left: bikeX,
              bottom: 23 + bikeY,
              child: Container(
                padding: const EdgeInsets.all(3.5),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 3,
                      offset: Offset(0, 1.5),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.delivery_dining,
                  size: 14,
                  color: Colors.blue.shade700,
                ),
              ),
            ),

            // Dispatching Badge
            Positioned(
              bottom: 6,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.4),
                    width: 0.5,
                  ),
                ),
                child: Text(
                  'DISPATCHED',
                  style: GoogleFonts.inter(
                    fontSize: 5.5,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMockChecklistItem(String label, bool checked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_circle : Icons.radio_button_unchecked,
            color: checked ? Colors.green : Colors.grey,
            size: 10,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 8,
                decoration: checked ? TextDecoration.lineThrough : null,
                color: checked ? Colors.grey : Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneMockupFrame({required Widget child}) {
    return Container(
      width: 85,
      height: 110,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black87, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(10), child: child),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 2),
              width: 24,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalStepper() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        return Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: SizedBox(
                height: 40,
                width: width,
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: WavyStepperPainter(
                        activeStep: _activeStep,
                        activeColor: Colors.green,
                        inactiveColor: Colors.grey.shade300,
                        animationValue: _animationController.value,
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(3, (index) {
                  final bool isActive = _activeStep == index;
                  final bool isPassed = _activeStep >= index;
                  IconData icon;
                  Color activeColor;
                  switch (index) {
                    case 0:
                      icon = Icons.camera_alt;
                      activeColor = Colors.green;
                      break;
                    case 1:
                      icon = Icons.rate_review;
                      activeColor = Colors.orange;
                      break;
                    case 2:
                      icon = Icons.local_shipping;
                      activeColor = Colors.blue;
                      break;
                    default:
                      icon = Icons.check;
                      activeColor = Colors.green;
                  }

                  Widget circleChild = AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isActive ? activeColor : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive
                            ? activeColor
                            : isPassed
                            ? activeColor.withOpacity(0.6)
                            : Colors.grey.shade300,
                        width: 2.5,
                      ),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: activeColor.withOpacity(0.3),
                                blurRadius: 8,
                                spreadRadius: 1,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      icon,
                      color: isActive
                          ? Colors.white
                          : isPassed
                          ? activeColor
                          : Colors.grey.shade400,
                      size: 18,
                    ),
                  );

                  if (isActive) {
                    circleChild = Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Positioned.fill(
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              final double scale =
                                  1.0 + (_animationController.value * 0.4);
                              final double opacity =
                                  1.0 - _animationController.value;
                              return Transform.scale(
                                scale: scale,
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: activeColor.withOpacity(
                                        opacity * 0.5,
                                      ),
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        circleChild,
                      ],
                    );
                  }

                  return GestureDetector(
                    onTap: () => _onStepTap(index),
                    child: SizedBox(
                      width: 60,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          circleChild,
                          const SizedBox(height: 6),
                          Text(
                            index == 0
                                ? 'Upload'
                                : index == 1
                                ? 'Review'
                                : 'Deliver',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: isActive
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isActive
                                  ? activeColor
                                  : isPassed
                                  ? activeColor.withOpacity(0.7)
                                  : Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActionButton({
    required VoidCallback onTap,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: color.withOpacity(0.1),
        highlightColor: color.withOpacity(0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WavyStepperPainter extends CustomPainter {
  final int activeStep;
  final Color activeColor;
  final Color inactiveColor;
  final double animationValue;

  WavyStepperPainter({
    required this.activeStep,
    required this.activeColor,
    required this.inactiveColor,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;
    final double centerY = height / 2;

    final double x1 = 32.0 + 30.0;
    final double x2 = width / 2;
    final double x3 = width - 62.0;

    final double amplitude = 25.0;

    final Path path = Path();
    path.moveTo(0, centerY);
    path.lineTo(x1, centerY);

    path.cubicTo(
      x1 + (x2 - x1) * 0.35,
      centerY + amplitude,
      x1 + (x2 - x1) * 0.65,
      centerY + amplitude,
      x2,
      centerY,
    );

    path.cubicTo(
      x2 + (x3 - x2) * 0.35,
      centerY - amplitude,
      x2 + (x3 - x2) * 0.65,
      centerY - amplitude,
      x3,
      centerY,
    );

    path.lineTo(width - 15, centerY);

    final Paint inactivePaint = Paint()
      ..color = inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, inactivePaint);

    final Path activePath = Path();
    activePath.moveTo(0, centerY);
    activePath.lineTo(x1, centerY);

    if (activeStep >= 1) {
      activePath.cubicTo(
        x1 + (x2 - x1) * 0.35,
        centerY + amplitude,
        x1 + (x2 - x1) * 0.65,
        centerY + amplitude,
        x2,
        centerY,
      );
    }
    if (activeStep >= 2) {
      activePath.cubicTo(
        x2 + (x3 - x2) * 0.35,
        centerY - amplitude,
        x2 + (x3 - x2) * 0.65,
        centerY - amplitude,
        x3,
        centerY,
      );
    }

    final Paint activePaint = Paint()
      ..color = activeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(activePath, activePaint);

    final Paint flowPaint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    _drawDashedPath(canvas, activePath, flowPaint, 8.0, 12.0, animationValue);

    final Paint arrowPaint = Paint()
      ..color = activeStep >= 2 ? activeColor : inactiveColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    final Path arrowPath = Path();
    arrowPath.moveTo(width - 25, centerY - 6);
    arrowPath.lineTo(width - 15, centerY);
    arrowPath.lineTo(width - 25, centerY + 6);
    canvas.drawPath(arrowPath, arrowPaint);

    _drawPathArrow(
      canvas,
      x1 + (x2 - x1) * 0.5,
      centerY + amplitude * 0.8,
      -0.1,
      activeStep >= 1 ? activeColor : inactiveColor,
    );
    _drawPathArrow(
      canvas,
      x2 + (x3 - x2) * 0.5,
      centerY - amplitude * 0.8,
      0.1,
      activeStep >= 2 ? activeColor : inactiveColor,
    );
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint,
    double dashLength,
    double gapLength,
    double animVal,
  ) {
    final double totalDash = dashLength + gapLength;
    final double phase = animVal * totalDash;

    for (final PathMetric metric in path.computeMetrics()) {
      double distance = -phase;
      while (distance < metric.length) {
        final double start = distance.clamp(0.0, metric.length);
        final double end = (distance + dashLength).clamp(0.0, metric.length);

        if (start < end) {
          final Path extract = metric.extractPath(start, end);
          canvas.drawPath(extract, paint);
        }
        distance += totalDash;
      }
    }
  }

  void _drawPathArrow(
    Canvas canvas,
    double x,
    double y,
    double angle,
    Color color,
  ) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    canvas.save();
    canvas.translate(x, y);
    canvas.rotate(angle);
    final Path arrow = Path();
    arrow.moveTo(-6, -4);
    arrow.lineTo(0, 0);
    arrow.lineTo(-6, 4);
    canvas.drawPath(arrow, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant WavyStepperPainter oldDelegate) {
    return oldDelegate.activeStep != activeStep ||
        oldDelegate.activeColor != activeColor ||
        oldDelegate.inactiveColor != inactiveColor ||
        oldDelegate.animationValue != animationValue;
  }
}

class _MockMapRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final Path path = Path();
    path.moveTo(15, size.height - 15);
    path.cubicTo(
      size.width * 0.3,
      size.height * 0.8,
      size.width * 0.6,
      size.height * 0.2,
      size.width - 15,
      15,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
