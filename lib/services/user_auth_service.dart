class UserAuthService {
  static Future<bool> login(String email, String password) async {
    await Future.delayed(Duration(seconds: 1));
    return email.isNotEmpty && password.isNotEmpty;
  }

  static Future<bool> signUp(String email, String password) async {
    await Future.delayed(Duration(seconds: 1));
    return email.isNotEmpty && password.isNotEmpty;
  }
}