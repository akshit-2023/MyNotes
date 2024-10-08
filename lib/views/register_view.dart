import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

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
      appBar: AppBar(title: const Text("Register"),),
      body: Column(
            children: [
              TextField(
                controller: _email,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration:
                    const InputDecoration(hintText: 'Enter your email here'),
              ),
              TextField(
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration:
                    const InputDecoration(hintText: 'Enter your password here'),
              ),
              TextButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  try{
                    await FirebaseAuth.instance
                      .createUserWithEmailAndPassword(
                          email: email, password: password);
                    final user=FirebaseAuth.instance.currentUser;
                    await user?.sendEmailVerification();//await because this function returns a Future
                    Navigator.of(context).pushNamed(verifyEmailRoute);//pushNamed is used because we dont want to remove the page before the verifyemailroute as if we registered using wrong email we can go back.
                }on FirebaseAuthException catch(e){
                  if(e.code=='weak-password'){
                    await showErrorDialog(context, 'Weak password');
                  }
                  else if(e.code=='email-already-in-use'){
                    await showErrorDialog(context, 'E-mail is already in use');
                  }
                  else if(e.code=='invalid-email'){
                    await showErrorDialog(context, 'Invalid E-mail');
                  }
                  else{
                    await showErrorDialog(context, 'Error: ${e.code}');
                  }
                } catch(e){
                  await showErrorDialog(context, e.toString());
                }
                  }
                  ,
                child: const Text('Register'),
              ),
              TextButton(onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (route) => false);//This removes the current scaffold and pushes a new scaffold on the screen and if the view has no scaffold it gives error so wrap your widget in a scaffold
              },
              child: const Text("Already registered? Login here!"),
              )
            ],
          ),
    );
  }
}

