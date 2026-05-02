import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:handy_allinone/common/widgets/custom_image.dart';
import 'package:handy_allinone/util/dimensions.dart';
import 'package:handy_allinone/util/app_constants.dart';

class DilogscreenHelp extends GetxController {
  static Future<void> offerdilog(
      BuildContext context, String? image) async {
    if (image == null || image.trim().isEmpty) return;

    final String fullImageUrl = "${AppConstants.baseUrl}$image";
debugPrint("Full Image URL: $fullImageUrl");
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        bool isLoaded = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Material(
                    elevation: 6,
                    borderRadius: BorderRadius.circular(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        height: 300,
                        width: 300,
                        child: Image.network(
                          fullImageUrl,
                          fit: BoxFit.cover,

                          /// LOADING
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) {
                              isLoaded = true;
                              return child;
                            }

                            return Container(
                              color: Colors.grey.shade300,
                              child: Center(
                                child: LoadingAnimationWidget
                                    .threeArchedCircle(
                                  color:
                                  Theme.of(context).primaryColor,
                                  size: 45,
                                ),
                              ),
                            );
                          },

                          /// ERROR → CLOSE DIALOG
                          errorBuilder: (_, __, ___) {
                            Future.microtask(() {
                              Navigator.pop(context);
                            });
                            return const SizedBox();
                          },
                        ),
                      ),
                    ),
                  ),

                  /// CLOSE BUTTON
                  Positioned(
                    top: 10,
                    right: 10,
                    child: InkWell(
                      onTap: () => Navigator.pop(context),
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
