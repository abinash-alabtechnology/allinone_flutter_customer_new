import 'package:flutter/material.dart';
import 'package:handy_allinone/util/styles.dart';

class BookingStatusBanner extends StatefulWidget {
  final String rideStatus;
  final int bookingId;

  const BookingStatusBanner({
    Key? key,
    required this.rideStatus,
    required this.bookingId,
  }) : super(key: key);

  @override
  State<BookingStatusBanner> createState() => _BookingStatusBannerState();
}

class _BookingStatusBannerState extends State<BookingStatusBanner>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  String getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return " Hang tight! We're finding your perfect captain...";
      case 'accepted':
        return "Buckle up! Your captain is gearing up to reach you!";
      case 'in_progress':
        return "You're on the move! Enjoy the ride – Booking #${widget.bookingId}";
      case 'completed':
        return "Ride complete! Thanks for riding with us!";
      case 'cancelled':
        return "Your ride was cancelled. We hope to serve you better next time.";
      case 'dropped':
        return "Captain has arrived! Please meet at the pickup spot.";
      default:
        return "📢 Booking Update: $status";
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Stack(
            children: [
              // Main gradient background
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF4CAF50), // darker green
                      Color(0xFF66BB6A), // lighter green
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.directions_car, color: Colors.white, size: 36),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your Booking ${widget.bookingId} is ON LIVE!",
                            style: robotoBold.copyWith(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            getStatusMessage(widget.rideStatus),
                            style: robotoRegular.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white, size: 28),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
