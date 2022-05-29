
import 'package:flutter/material.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
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
              child: const Text("Register"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil("/login/", (route) => false);
              },
              child: const Text("Already have an account ? Login Here!"),
            ),
          ],
        );
      }),
    );
  }
}
