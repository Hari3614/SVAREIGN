import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static Future<void> Saveusersession({
    required String uid,
    required String role,
  }) async {
    SharedPreferences prefr = await SharedPreferences.getInstance();
    await prefr.setBool('IsloggedIn', true);
    await prefr.setString('uid', uid);
    await prefr.setString('role', role);
  }

  static Future<bool> IsloggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('IsloggedIn') ?? false;
  }

  static Future<String?> getrole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  static Future<String?> getuid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('uid');
  }

  static Future<void> clearsession() async {
    SharedPreferences perfss = await SharedPreferences.getInstance();
    await perfss.clear();
  }
}
