import 'package:todos/services/auth/auth_provider.dart';
import 'package:todos/services/auth/auth_user.dart';
import 'package:todos/services/auth/firebase_auth_provider.dart';

class AuthService implements AuthProvider {
  final AuthProvider authProvider;

  const AuthService(this.authProvider);

  factory AuthService.firebase() => AuthService(FirebaseAuthProvider());

  @override
  AuthUser? get currentUser => authProvider.currentUser;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) =>
      authProvider.login(
        email: email,
        password: password,
      );

  @override
  Future<void> logout() => authProvider.logout();

  @override
  Future<AuthUser> register({
    required String email,
    required String password,
  }) =>
      authProvider.register(
        email: email,
        password: password,
      );

  @override
  Future<void> sendEmailVerification() => authProvider.sendEmailVerification();
  
  @override
  Future<void> initialize() => authProvider.initialize();
}
