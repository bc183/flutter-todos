import 'package:flutter/material.dart';

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder(builder: (context, snapshot) {
        return Column(
          children: [
            TextField(
              controller: _email,
              decoration:
                  const InputDecoration(hintText: "Enter your email address"),
              enableSuggestions: false,
              autocorrect: false,
            ),
            TextField(
              controller: _password,
              decoration: const InputDecoration(
                hintText: "Enter your password",
              ),
              autocorrect: false,
              obscureText: true,
              enableSuggestions: false,
            ),
            TextButton(
              onPressed: () {
                final String email = _email.text;
                final String password = _password.text;

                print("${email}, ${password}");
              },
              child: const Text("Login"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil("/register/", (route) => false);
              },
              child: const Text("Don't have an account ? Register Here!"),
            ),
          ],
        );
      }),
    );
  }
}
