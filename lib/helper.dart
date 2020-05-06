import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static Future<String> getMessage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getString("msg");
  }

  static setMessage(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.setString("msg", value);
  }
}
