import 'package:icons_plus/icons_plus.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/styles.dart';
import 'package:flutter/material.dart';

class RatingBar extends StatelessWidget {
  final double? rating;
  final double size;
  final int? ratingCount;
  const RatingBar({super.key, required this.rating, required this.ratingCount, this.size = 18});

  @override
  Widget build(BuildContext context) {
    List<Widget> starList = [];

    int realNumber = rating!.floor();
    int partNumber = ((rating! - realNumber) * 10).ceil();

    for (int i = 0; i < 5; i++) {
      if (i < realNumber) {
        starList.add(Padding(
          padding: EdgeInsets.only(left: 2),
          child: Icon(FontAwesome.star_solid, color:  Colors.yellow.shade700, size: size),
        ));
      } else if (i == realNumber) {
        starList.add(Padding(
          padding: EdgeInsets.only(left: 2),
          child: SizedBox(
            height: size,
            width: size,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Icon(FontAwesome.star_solid, color:  Colors.yellow.shade700, size: size),
                ClipRect(
                  clipper: _Clipper(part: partNumber),
                  child: Icon(FontAwesome.star_solid, color: Colors.grey, size: size),
                )
              ],
            ),
          ),
        ));
      } else {
        starList.add(Padding(
          padding: EdgeInsets.only(left: 2),
          child: Icon(FontAwesome.star_solid, color: Colors.grey, size: size),
        ));
      }
    }
    ratingCount != null ? starList.add(Padding(
      padding: const EdgeInsets.only(left: Dimensions.paddingSizeExtraSmall),
      child: Text('($ratingCount)', style: robotoBold.copyWith(fontSize: size*0.8, color: Theme.of(context).disabledColor), textDirection: TextDirection.ltr),
    )) : const SizedBox();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: starList,
    );
  }
}

class _Clipper extends CustomClipper<Rect> {
  final int part;

  _Clipper({required this.part});

  @override
  Rect getClip(Size size) {
    return Rect.fromLTRB(
      (size.width / 10) * part,
      0.0,
      size.width,
      size.height,
    );
  }

  @override
  bool shouldReclip(CustomClipper<Rect> oldClipper) => true;
}
