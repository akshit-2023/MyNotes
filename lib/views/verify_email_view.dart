// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/services/auth/auth_service.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({super.key});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify E-mail"),),
      body: Column(children: [//changed from return scaffold to return column because of Navigator error
        const Text("E-mail verification sent, if not received click the button below to resend it."),
        TextButton(onPressed: () async {//try to make child the last argument in TextButton,await used so async also used
          await AuthService.firebase().sendEmailVerification();
        }, 
        child: const Text("Send E-mail verification")),
        TextButton(onPressed:() async {
          await AuthService.firebase().logOut();
          Navigator.of(context).pushNamedAndRemoveUntil(registerRoute,(route)=> false);
        }, child: const Text("Restart")),
      ],),
    );
  }
}