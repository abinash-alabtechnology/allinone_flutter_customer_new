import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/widget_extensions.dart';
import 'package:handy_allinone/features/parcel/new_category/widget_category/parcel_pick_drop_widget/parcel_text_field_holder_widget.dart';
import 'package:handy_allinone/util/styles.dart';

class ParcelReceiverDetailsWidget extends StatelessWidget {
  final String title;
  final TextEditingController senderName;
  final TextEditingController phoneNumber;
  final TextEditingController emailId;
  final bool isGestuLogin;
  final bool isSender;
  const ParcelReceiverDetailsWidget(
      {super.key,
        required this.title,
        required this.senderName,
        required this.phoneNumber,
        required this.emailId, required this.isGestuLogin, this.isSender = true,});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      margin: const EdgeInsets.only(bottom: 12, top: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: Colors.pink.shade400,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: robotoRegular.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            height: 20,
            thickness: 0.9,
            color: Colors.grey.shade100,
          ),
          TextfiledHolder(
            hintText: isSender ? "Sender Name" : "Receiver Name",
            iconData: Icons.person_outline,
            textEditingController: senderName,
          ),
          TextfiledHolder(
            hintText: "Mobile Number",
            iconData: Icons.phone_outlined,
            textEditingController: phoneNumber,
            textInputFormatter: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            isPhone: true,
          ).paddingOnly(top: 10),
          if(isGestuLogin)
            TextfiledHolder(
              hintText: "Email Name",
              iconData: Icons.email_outlined,
              textEditingController: emailId,
            ),

        ],
      ),
    );
  }
}