import 'package:flutter/material.dart';
import 'package:todos/views/login_view.dart';
import 'package:todos/views/notes__view.dart';
import 'package:todos/views/register_view.dart';
import 'package:todos/views/verify_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      primarySwatch: Colors.red,
    ),
    home: const HomePage(),
    routes: {
      "/login/": (context) => const LoginView(),
      "/register/": (context) => const RegisterView(),
      "/my-notes/": (context) => const NotesView()
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  void goToLogin(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const LoginView()));
  }

  void goToRegister(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const RegisterView()));
  }

  void goToVerifyEmail(BuildContext context) {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const VerifyEmailView()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Todos"),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton(
              onPressed: () {
                goToLogin(context);
              },
              child: const Text("Go to Login")),
          TextButton(
              onPressed: () {
                goToRegister(context);
              },
              child: const Text("Go to Register")),
          TextButton(
              onPressed: () {
                goToVerifyEmail(context);
              },
              child: const Text("Go to Verify Email View")),
        ],
      ),
    );
  }
}
