import 'dart:convert' show jsonDecode;

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'app_constants.dart';

class AppLifecycleHandler extends StatefulWidget {
  final Widget child;
  const AppLifecycleHandler({super.key, required this.child});

  @override
  State<AppLifecycleHandler> createState() => _AppLifecycleHandlerState();
}

class _AppLifecycleHandlerState extends State<AppLifecycleHandler>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setOnline();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _setOffline();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final sharedPreferences = Get.find<SharedPreferences>();
    final token = sharedPreferences.getString(AppConstants.token);
    if (token == null || token.isEmpty) return;
    debugPrint("sksk");
    debugPrint(state.toString());
    if (state == AppLifecycleState.resumed) {
      updateOnlineStatus(1, token).then((success) {
        debugPrint(success
            ? "Online status updated successfully."
            : "Failed to update online status.");
      });
    } else if (state == AppLifecycleState.paused ||state==AppLifecycleState.hidden||state==AppLifecycleState.inactive||
        state == AppLifecycleState.detached) {
      updateOnlineStatus(0, token).then((success) {
        debugPrint(success
            ? "Offline status updated successfully."
            : "Failed to update offline status.");
      });
    }
  }

  void _setOnline() async {
    final sharedPreferences = Get.find<SharedPreferences>();
    final token = sharedPreferences.getString(AppConstants.token);
    if (token != null && token.isNotEmpty) {
      await updateOnlineStatus(1, token);
    }
  }

  void _setOffline() async {
    final sharedPreferences = Get.find<SharedPreferences>();
    final token = sharedPreferences.getString(AppConstants.token);
    if (token != null && token.isNotEmpty) {
      await updateOnlineStatus(0, token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

Future<bool> updateOnlineStatus(int status, String token) async {
  final url = Uri.parse('${AppConstants.baseUrl}/api/v1/customer/update-onlineoroffline');

  try {
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
      body: {
        'status': status.toString(),
      },
    );


    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] ?? true;
    } else {
      return false;
    }
  } catch (e) {
    print('Error updating online status: $e');
    return false;
  }
}