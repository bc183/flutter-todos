import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todos/constants/routes.dart';
import 'package:todos/services/auth/auth_exceptions.dart';
import 'package:todos/services/auth/auth_service.dart';
import 'package:todos/services/auth/bloc/auth_bloc.dart';
import 'package:todos/services/auth/bloc/auth_event.dart';
import 'package:todos/services/auth/bloc/auth_state.dart';
import 'package:todos/utils/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateRegistering) {
          // final closeDialog = _closeDialogHandle;

          // if (!state.isLoading && closeDialog != null) {
          //   closeDialog();
          //   _closeDialogHandle = null;
          // } else if (state.isLoading && closeDialog == null) {
          //   _closeDialogHandle = showLoadingDialog(
          //     context: context,
          //     text: "Loading...",
          //   );
          // }

          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(
              context,
              'Weak Password',
            );
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(
              context,
              'Email already in use',
            );
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(
              context,
              'Invalid email address',
            );
          } else {
            await showErrorDialog(
              context,
              'Registeration failed',
            );
          }
        }
      },
      child: Scaffold(
        body: Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Register',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              TextField(
                controller: _email,
                enableSuggestions: false,
                autocorrect: false,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Enter your email here',
                ),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: 'Enter your password here',
                ),
              ),
              TextButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;

                  context.read<AuthBloc>().add(
                        AuthEventRegister(
                          email,
                          password,
                        ),
                      );
                },
                child: const Text('Register'),
              ),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(
                        const AuthEventLogOut(),
                      );
                },
                child: const Text('Already registered? Login here!'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
