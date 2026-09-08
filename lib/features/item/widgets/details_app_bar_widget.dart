import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DetailsAppBarWidget extends StatefulWidget implements PreferredSizeWidget {
  const DetailsAppBarWidget({super.key});

  @override
  DetailsAppBarWidgetState createState() => DetailsAppBarWidgetState();

  @override
  Size get preferredSize => const Size(double.maxFinite, 50);
}

class DetailsAppBarWidgetState extends State<DetailsAppBarWidget> with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
  }
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void shake() {
    controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Container(
          width: 30,
          height: 40,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios,
                color: Theme.of(context).textTheme.bodyLarge!.color),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      leadingWidth: 50.w,
      actions: const [],
    );
  }
}
