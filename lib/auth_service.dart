// class UserAuthService {
//   // Simple in-memory user storage
//   static final Map<String, String> _users = {};

//   static Future<bool> signUp(String email, String password) async {
//     await Future.delayed(Duration(milliseconds: 400));
//     if (_users.containsKey(email)) return false;
//     _users[email] = password;
//     return true;
//   }

//   static Future<bool> login(String email, String password) async {
//     await Future.delayed(Duration(milliseconds: 400));
//     if (!_users.containsKey(email)) return false;
//     return _users[email] == password;
//   }
// }