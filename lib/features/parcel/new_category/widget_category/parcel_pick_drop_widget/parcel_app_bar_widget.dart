import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/util/styles.dart';


class TabAnimationWidget extends StatefulWidget {
  final RxInt tabIndex;
  const TabAnimationWidget({super.key, required this.tabIndex});
  @override
  State<TabAnimationWidget> createState() => _TabAnimationWidgetState();
}

class _TabAnimationWidgetState extends State<TabAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<AlignmentGeometry> _alignAnimation;
  late Worker _worker;

  @override
  void initState() {
    super.initState();
    initAnimation();
    listenToIndex();
  }

  void initAnimation() {
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _alignAnimation = AlignmentTween(
            begin: const Alignment(-0.87, 0.0), end: const Alignment(0.87, 0.0))
        .animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOutQuart,
      ),
    );
  }

  void listenToIndex() {
    _worker = ever(widget.tabIndex, (i) {
      if (i == 0) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _worker.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            height: 53,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          AlignTransition(
            alignment: _alignAnimation,
            child: Container(
              height: 45,
              width: context.width / 2.3 - 12,
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 28, 3, 101),
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(97, 44, 7, 153),
                      blurRadius: 8,
                      spreadRadius: 0.1,
                      offset: Offset(0, 0),
                    ),
                  ]),
            ),
          ),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    _controller.reverse();
                    widget.tabIndex.value = 0;
                  },
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 350),
                    style: widget.tabIndex.value == 0
                        ? robotoBold.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                    )
                        : robotoBlack.copyWith(
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                    ),
                    curve: Curves.easeIn,
                    child: const Text(
                      "Sender",
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    _controller.forward();
                    widget.tabIndex.value = 1;
                  },
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 350),
                    style: widget.tabIndex.value == 1
                        ? robotoBold.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                    )
                        : robotoBlack.copyWith(
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            ),
                    curve: Curves.easeIn,
                    child: const Text("Receiver",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
