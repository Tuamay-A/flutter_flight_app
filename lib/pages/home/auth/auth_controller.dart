import 'package:expedia/navigation/bottom_nav.dart';
import 'package:get/get.dart';
import 'auth_service.dart';
import 'sign_in_page.dart';

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
    await _storage.saveLogin(true);
    Get.offAll(() => const BottomNav());
  }

  void logout() async {
    await _storage.clearAll();
    Get.offAll(() => const SignInPage());
  }
}
