import 'package:flutter/material.dart';
import 'package:handy_allinone/features/parcel/new_category/widget_category/parcel_pick_drop_widget/parcel_text_field_holder_widget.dart';
import 'package:handy_allinone/util/app_constants.dart';
import 'package:handy_allinone/util/styles.dart';

class ParcelAddressDetailsWidget extends StatelessWidget {
  final String title;
  final TextEditingController streetName;
  final TextEditingController houseNumber;
  final TextEditingController floor;

  const ParcelAddressDetailsWidget(
      {super.key,
      required this.title,
      required this.streetName,
      required this.houseNumber,
      required this.floor});

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
                      Icons.home_work_outlined,
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
            hintText: "Street Name",
            iconData: Icons.rocket_launch_outlined,
            textEditingController: streetName,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: Row(
              spacing: 10,
              children: [
                Flexible(
                  child: TextfiledHolder(
                    hintText: "House/Flat No.",
                    iconData: Icons.home_outlined,
                    textEditingController: houseNumber,
                    wantMargin: false,
                  ),
                ),
                Flexible(
                  child: TextfiledHolder(
                    hintText: "Floor",
                    iconData: Icons.layers_outlined,
                    textEditingController: floor,
                    wantMargin: false,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
