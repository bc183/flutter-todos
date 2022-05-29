import 'package:flutter/material.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verify Email"),
        backgroundColor: Colors.red,
      ),
      body: Column(
        children: [
          const Center(child: Text("Please, Verify Email")),
          TextButton(onPressed: () {}, child: const Text("verify")),
        ],
      ),
    );
  }
}