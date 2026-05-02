import 'package:get/get.dart';
import 'package:glass_kit/glass_kit.dart';
import 'package:flutter/material.dart';
//
// class CustomLoaderWidget extends StatelessWidget {
//   const CustomLoaderWidget({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(child: Container(
//       height: 100, width: 100,
//       decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
//       alignment: Alignment.center,
//       child: Text("Hello"),
//     ));
//   }
// }

class CustomLoaderWidget extends StatefulWidget {
  const CustomLoaderWidget({super.key});

  @override
  State<CustomLoaderWidget> createState() => _CustomLoaderWidgetState();
}

class _CustomLoaderWidgetState extends State<CustomLoaderWidget> {
  final List<String> messages = [
    "Warm goodness rolling closer every second...",
    "Joyful moments preparing just for you...",
    "Excitement wrapping beautifully on the move...",
    "Pure delight traveling swiftly towards you...",
    "Smiles packed tightly racing your way...",
    "Happiness getting dressed for grand arrival...",
    "Magic loading gently behind the scenes...",
    "Great vibes cruising smoothly to you...",
    "Careful hands crafting joy in motion...",
    "Heartfelt comfort steering steadily your direction...",
    "Bliss being shaped with gentle precision...",
    "Delight marching confidently through the journey...",
  ];



  int index = 0;
  bool _active = true;
  void shuffleMessages() {
    messages.shuffle();
  }
  @override
  void initState() {
    super.initState();
    rotateText();
    shuffleMessages();
  }

  void rotateText() async {
    while (_active) {
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return; // lifecycle guarantee
      setState(() => index = (index + 1) % messages.length);
    }
  }

  @override
  void dispose() {
    _active = false; // end loop to prevent leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: Container(
        color: Colors.transparent,
        height: 80,width: Get.width/1.5,
        child: Center(
          child: GlassContainer(
            borderRadius:
                BorderRadius.circular(10),
            borderColor: Colors.grey
                .withValues(alpha:
                    0.3),
            gradient: LinearGradient(
              colors: [
                Colors.grey
                    .withValues(alpha: 0.30),
                Colors.grey
                    .withValues(alpha: 0.10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderGradient: LinearGradient(
              colors: [
                Colors.blue
                    .withValues(alpha: 0.60),
                Colors.blue
                    .withValues(alpha: 0.10),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.5, 1.0],
            ),
            blur: 3,
            color: Colors.grey,
            borderWidth: 1.0,
            elevation: 100.0,
            shadowColor: Colors.grey,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  messages[index],
                  key: ValueKey(index),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
