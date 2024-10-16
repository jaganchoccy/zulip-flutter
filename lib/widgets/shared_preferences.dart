import 'package:shared_preferences/shared_preferences.dart';

void saveAccountId(int accountId) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setInt('accountId', accountId);
}

Future<int?> getAccountId() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getInt('accountId');
}
