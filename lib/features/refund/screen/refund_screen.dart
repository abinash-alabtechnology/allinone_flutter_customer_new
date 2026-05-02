import 'package:flutter/material.dart';
import 'package:handy_allinone/common/widgets/custom_app_bar.dart';
import 'package:handy_allinone/features/refund/widgets/refund_card_widget.dart';

class RefundScreen extends StatelessWidget {
  const RefundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar2(title: "Refund history"),
      body: ListView.builder(
        itemBuilder: (context, index) => const RefundCardWidget(),
        itemCount: 2,
      ),
    );
  }
}
