import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/common/widgets/custom_app_bar.dart';
import '../widgets/faq_view.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar3(title: 'faq'.tr),
      body: const FaqView(),
    );
  }
}
