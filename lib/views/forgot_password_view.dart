import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:todos/services/auth/bloc/auth_bloc.dart';
import 'package:todos/services/auth/bloc/auth_event.dart';
import 'package:todos/services/auth/bloc/auth_state.dart';
import 'package:todos/utils/dialogs/error_dialog.dart';
import 'package:todos/utils/dialogs/password_reset_email_sent_dialog.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    _textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        if (state is AuthStateForgotPassword) {
          if (state.hasSentEmail) {
            _textEditingController.clear();
            await showPasswordResetSentDialog(context);
          }

          if (state.exception != null) {
            if (mounted) {
              await showErrorDialog(context,
                  "We could not process your request. Please, make sure you are a registered user.");
            }
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
                'Forgot Password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 10.0),
              TextField(
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofocus: true,
                controller: _textEditingController,
                decoration: const InputDecoration(
                  hintText: "Email address",
                ),
              ),
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: () {
                  final email = _textEditingController.text;
                  context
                      .read<AuthBloc>()
                      .add(AuthEventForgotPassword(email: email));
                },
                child: const Text("Send Link"),
              ),
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventLogOut());
                },
                child: const Text("Back To Login"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
