import 'package:flutter/material.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/styles.dart';

class ParcelSelectDeliveryWidget extends StatelessWidget {
  final VoidCallback onTap;
  const ParcelSelectDeliveryWidget({super.key,required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        margin: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          spacing: 16,
          children: [
            // Left Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.map_outlined,
                color: Colors.pink.shade400,
                size: 28,
              ),
            ),
            // Text Content
            Expanded(
              child: Column(
                spacing: 4,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Select Delivery Location",
                    style: robotoBold.copyWith(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    "Use map to pinpoint exact location",
                    style: robotoRegular.copyWith(
                      fontSize: 13,
                      color: Colors.black45,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.shade100,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
                border: Border.all(
                  width: 0.8,
                  color: Colors.pink.shade100,
                ),
                color: Colors.pink.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Colors.pink.shade400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
