import 'package:todos/services/auth/auth_user.dart';

abstract class AuthProvider {
  AuthUser? get currentUser;
  Future<AuthUser> login({required String email, required String password});

  Future<AuthUser> register({required String email, required String password});

  Future<void> logout();
  Future<void> sendEmailVerification();
  Future<void> sendPasswordReset({required String email});
  Future<void> initialize();
}
