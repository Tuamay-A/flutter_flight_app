import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  Future<void> saveLogin(bool value) async {
    final prefs = await SharedPreferences.getInstance();//Get acess to phone storage
    await prefs.setBool('is_logged_in', value);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_logged_in') ?? false;
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}

