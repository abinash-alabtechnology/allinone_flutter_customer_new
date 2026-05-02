import 'package:flutter/material.dart';

// class TaxiHomeScreen extends StatefulWidget {
//   const TaxiHomeScreen({super.key});
//
//   @override
//   State<TaxiHomeScreen> createState() => _TaxiHomeScreenState();
// }
//
// class _TaxiHomeScreenState extends State<TaxiHomeScreen> {
//
//   @override
//   Widget build(BuildContext context) {
//     return const SizedBox();
//   }
// }
//


class TaxiHomeScreen extends StatefulWidget {
  final ScrollController? scrollController;
  const TaxiHomeScreen({super.key, this.scrollController});

  @override
  State<TaxiHomeScreen> createState() => _TaxiHomeScreenState();
}

class _TaxiHomeScreenState extends State<TaxiHomeScreen> {


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: widget.scrollController,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: Add your Taxi Home Screen widgets here
          const SizedBox(height: 20),
          const Center(child: Text("Taxi Home Screen Placeholder")),
        ],
      ),
    );
  }
}

