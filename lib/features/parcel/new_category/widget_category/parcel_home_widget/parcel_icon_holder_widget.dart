import 'package:flutter/material.dart';

class ParcelIconHolderWidget extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;
  const ParcelIconHolderWidget({
    super.key,
    required this.icon,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 37,
        width: 37,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white12,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Icon(
            icon,
            color: iconColor ?? Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}
