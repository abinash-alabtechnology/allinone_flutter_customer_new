import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:handy_allinone/common/widgets/custom_app_bar.dart';

class DelivarWebViewScreen extends StatefulWidget {
  final String url;
  const DelivarWebViewScreen({super.key, required this.url});

  @override
  State<DelivarWebViewScreen> createState() => _DelivarWebViewScreenState();
}

class _DelivarWebViewScreenState extends State<DelivarWebViewScreen> {
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'track_delivery'.tr),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            onLoadStart: (controller, url) {
              setState(() {
                _isLoading = true;
              });
            },
            onLoadStop: (controller, url) {
              setState(() {
                _isLoading = false;
              });
            },
          ),
          _isLoading ? Center(
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
          ) : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
