import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String isLoggedInKey = 'IsloggedIn';
  static const String activeUidKey = 'uid';
  static const String activeRoleKey = 'role';
  static const String accountsKey = 'accounts'; // store account map as uid:role

  // Save current session and also remember all accounts
  static Future<void> SaveUserSession({
    required String uid,
    required String role,
    required String name,
  }) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLoggedInKey, true);
    await prefs.setString(activeUidKey, uid);
    await prefs.setString(activeRoleKey, role);

    // Maintain list of accounts
    List<String> existingAccounts = prefs.getStringList(accountsKey) ?? [];
    String accountString = '$uid:$role:$name';
    if (!existingAccounts.contains(accountString)) {
      existingAccounts.add(accountString);
      await prefs.setStringList(accountsKey, existingAccounts);
    }
  }

  static Future<bool> isLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedInKey) ?? false;
  }

  static Future<String?> getUid() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(activeUidKey);
  }

  static Future<String?> getRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(activeRoleKey);
  }

  static Future<List<Map<String, String>>> getAllAccounts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> accounts = prefs.getStringList(accountsKey) ?? [];
    return accounts.map((e) {
      final parts = e.split(':');
      return {
        'uid': parts[0],
        'role': parts[1],
        'name': parts.length > 2 ? parts[2] : '',
      };
    }).toList();
  }

  // Logout current account but keep other saved accounts
  static Future<void> logoutCurrentAccount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(isLoggedInKey);
    await prefs.remove(activeUidKey);
    await prefs.remove(activeRoleKey);
  }

  // Clear everything including stored accounts
  static Future<void> clearAll() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // Remove a specific account
  static Future<void> removeAccount(String uid, String role) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> accounts = prefs.getStringList(accountsKey) ?? [];
    accounts.removeWhere((e) => e == '$uid:$role');
    await prefs.setStringList(accountsKey, accounts);
  }
}
