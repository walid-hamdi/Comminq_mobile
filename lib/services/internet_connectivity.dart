import 'package:connectivity_plus/connectivity_plus.dart';

import '../utils/dialog_utils.dart';

class InternetConnectivity {
  static Future<bool> checkConnectivity(context) async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      showErrorDialog(
        context: context,
        title: "No Internet Connection",
        content: "Please check your internet connection and try again.",
      );
      return false;
    }
    return true;
  }
}
