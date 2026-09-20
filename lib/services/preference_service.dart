import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const String _usernameKey = 'username';
  Future<void> saveUsername(String username) async {
    // TODO:
    // 1. เรียก SharedPreferences.getInstance()
    // 2. บันทึก username ด้วย setString()
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, username);
  }
  Future<String?> getUsername() async {
    // TODO:
    // อ่านข้อมูล username ด้วย getString()
    // return null;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  Future<void> removeUsername() async {
    // TODO:
    // ลบข้อมูล username
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_usernameKey);
  }
}
