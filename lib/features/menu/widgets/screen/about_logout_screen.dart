import 'package:flutter/material.dart';
import 'package:handy_allinone/common/widgets/custom_app_bar.dart';

class AboutLogoutScreen extends StatelessWidget {
  const AboutLogoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar2(title: "Delete Account"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Sorry to see you go :(",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.topLeft,
              child: Text(
                "Deleting your account will permanently remove your data and cancel any active plans. This action cannot be undone, so please procced carefully",
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w400,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              maxLines: 6,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                fillColor: Colors.grey.shade300,
                hintText: "Write your Feedback",
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                  ),
                ),
                enabled: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ),
            const Spacer(),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Expanded(
            //       child: ElevatedButton(
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: Colors.grey,
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(8),
            //           ),
            //         ),
            //         onPressed: () {},
            //         child: const Text(
            //           "Delete Account",
            //           style: TextStyle(
            //             color: Colors.black,
            //           ),
            //         ),
            //       ),
            //     ),
            //     const SizedBox(width: 10),
            //     Expanded(
            //       child: ElevatedButton(
            //         style: ElevatedButton.styleFrom(
            //           backgroundColor: Colors.green,
            //           shape: RoundedRectangleBorder(
            //             borderRadius: BorderRadius.circular(8),
            //           ),
            //         ),
            //         onPressed: () {},
            //         child: const Text(
            //           "Delete Account",
            //           style: TextStyle(
            //             color: Colors.white,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
