// ignore_for_file: avoid_print

import 'package:expedia/navigation/bottom_nav.dart';
import 'package:get/get.dart';
import 'auth_service.dart';
import 'sign_in_page.dart';
import '../../../data/services/api_service.dart';

class AuthController extends GetxController {
  final _storage = StorageService();

  var isLoggedIn = 'is_logged_in'.obs;
  var obscureText = true.obs;

  @override
  void onReady() {
    super.onReady();
    checkLoginStatus();
  }

  void toggleVisibility() {
    obscureText.value = !obscureText.value;
  }

  void checkLoginStatus() async {
    bool loggedIn = await _storage.isLoggedIn();

    if (loggedIn) {
      Get.offAll(() => const BottomNav());
    } else {
      Get.offAll(() => const SignInPage());
    }
  }

  void login({required String email, required String password}) async {
    // Fetch guest token before navigating so it's ready for flight search
    final apiService = Get.find<ApiService>();
    final token = await apiService.getGuestToken();
    if (token != null) {
      print('✅ AuthController: guest token ready, proceeding to home');
    } else {
      print('⚠️ AuthController: guest token fetch failed, proceeding anyway');
    }
    await _storage.saveLogin(true);
    Get.offAll(() => const BottomNav());
  }

  void logout() async {
    await _storage.clearAll();
    Get.offAll(() => const SignInPage());
  }
}
