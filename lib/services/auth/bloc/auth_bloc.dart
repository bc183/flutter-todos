import 'package:bloc/bloc.dart';
import 'package:todos/services/auth/auth_provider.dart';
import 'package:todos/services/auth/bloc/auth_event.dart';
import 'package:todos/services/auth/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(AuthProvider authProvider) : super(const AuthStateUninitialized()) {
    // initialize event
    on<AuthEventInitialize>((event, emit) async {
      await authProvider.initialize();
      final user = authProvider.currentUser;

      if (user == null) {
        emit(
          const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ),
        );
      } else if (!user.isEmailVerified) {
        emit(const AuthStateNeedVerification());
      } else {
        emit(AuthStateLoggedIn(user));
      }
    });

    //Login event
    on<AuthEventLogIn>((event, emit) async {
      emit(
        const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
        ),
      );
      final email = event.email;
      final password = event.password;

      try {
        final user = await authProvider.login(
          email: email,
          password: password,
        );

        if (!user.isEmailVerified) {
          emit(
            const AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ),
          );
          emit(const AuthStateNeedVerification());
        } else {
          emit(
            const AuthStateLoggedOut(
              exception: null,
              isLoading: false,
            ),
          );
          emit(AuthStateLoggedIn(user));
        }
      } on Exception catch (e) {
        emit(
          AuthStateLoggedOut(
            exception: e,
            isLoading: false,
          ),
        );
      }
    });

    //Logout event
    on<AuthEventLogOut>((event, emit) async {
      emit(
        const AuthStateLoggedOut(
          exception: null,
          isLoading: true,
        ),
      );

      try {
        await authProvider.logout();
        emit(
          const AuthStateLoggedOut(
            exception: null,
            isLoading: false,
          ),
        );
      } on Exception catch (e) {
        emit(
          AuthStateLoggedOut(
            exception: e,
            isLoading: false,
          ),
        );
      }
    });

    // register event
    on<AuthEventRegister>((event, emit) async {
      final email = event.email;
      final password = event.password;

      try {
        await authProvider.register(
          email: email,
          password: password,
        );

        await authProvider.sendEmailVerification();
        emit(const AuthStateNeedVerification());
      } on Exception catch (e) {
        emit(AuthStateRegistering(e));
      }
    });

    // send email verification
    on<AuthEventSendEmailVerification>((event, emit) async {
      await authProvider.sendEmailVerification();
      emit(state);
    });
  }
}
