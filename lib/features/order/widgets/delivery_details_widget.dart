import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
class DeliveryDetailsWidget extends StatelessWidget {
  final bool from;
  final String? address;
  const DeliveryDetailsWidget({super.key, this.from = true, this.address});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisAlignment: MainAxisAlignment.start, children: [
      // Icon(from ? Icons.store : Icons.location_on, size: 28, color: from ? Colors.blue : Theme.of(context).primaryColor),
      const SizedBox(width: Dimensions.paddingSizeSmall),

      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(from ? 'from_store'.tr : 'to'.tr, style: robotoMedium),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Text(
          address ?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
          style: robotoRegular.copyWith(color: Theme.of(context).disabledColor,fontSize: 12),
        )
      ])),
    ]);
  }
}



class DeliveryDetailsWidget1 extends StatelessWidget {
  final bool from;
  final String? address;

  const DeliveryDetailsWidget1({
    super.key,
    this.from = true,
    this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
      from ? CrossAxisAlignment.start : CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment:
          from ? MainAxisAlignment.start : MainAxisAlignment.end,
          children: [
            if (from)
              Icon(Icons.store, size: 26, color: Colors.blue)
            else
              const SizedBox(),
            if (from) const SizedBox(width: 6),
            Text(
              from ? 'From' : 'To',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Theme.of(context).textTheme.bodyMedium!.color,
              ),
            ),
            if (!from) const SizedBox(width: 6),
            if (!from)
              Icon(Icons.location_on,
                  size: 26, color: Theme.of(context).primaryColor),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          address ?? '',
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          textAlign: from ? TextAlign.start : TextAlign.end,
          style: TextStyle(
            color: Theme.of(context).disabledColor,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
/// Elegant looping left-to-right arrow animation
class LeftToRightArrow extends StatefulWidget {
  final Color? color;
  final double size;
  final Duration duration;

  const LeftToRightArrow({
    super.key,
    this.color,
    this.size = 32,
    this.duration = const Duration(milliseconds: 1200),
  });

  @override
  State<LeftToRightArrow> createState() => _LeftToRightArrowState();
}

class _LeftToRightArrowState extends State<LeftToRightArrow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller =
    AnimationController(vsync: this, duration: widget.duration)..repeat();

    _slide = Tween<double>(begin: -10, end: 10)
        .chain(CurveTween(curve: Curves.easeInOut))
        .animate(_controller);

    _fade = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.3, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.3), weight: 50),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => Opacity(
        opacity: _fade.value,
        child: Transform.translate(
          offset: Offset(_slide.value, 0),
          child: child,
        ),
      ),
      child: Icon(
        Icons.double_arrow_rounded,
        size: widget.size,
        color: widget.color ?? Theme.of(context).primaryColor,
      ),
    );
  }
}
