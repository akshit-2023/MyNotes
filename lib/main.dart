import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:mynotes/views/register_view.dart';
import 'package:mynotes/views/verify_email_view.dart';
import 'dart:developer' as devtools show log;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();//Now we dont need to initialize firebsae.auth in every widget
  final modes = await FlutterDisplayMode.supported;
  modes.sort((a, b) => b.refreshRate.compareTo(a.refreshRate));
  await FlutterDisplayMode.setPreferredMode(modes.first);

  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 12, 13, 72)),
      useMaterial3: false,
    ),
    home: const HomePage(),
    routes: {
      '/login/': (context) => const LoginView(),
      '/register/': (context) => const RegisterView()
    },
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future:Firebase.initializeApp(
                  options: DefaultFirebaseOptions.currentPlatform,
                ) ,
        builder: (context, snapshot) {//Builder should return a widget
          switch(snapshot.connectionState){
            case ConnectionState.done:
              final user=FirebaseAuth.instance.currentUser;
              if(user != null){
                if(user.emailVerified){
                  return const NotesView();
                }
                else{
                  return const VerifyEmailView();
                }
              }else{//if user is null then pop loginview so that user can enter details.
               return const LoginView(); 
              }
              
        default:
        return const CircularProgressIndicator();
              
          }
        },
      );
  }
}

//Enumeration
enum MenuActions{
  logout
}

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}
// avoid print calls in production code, because OS keeps track of these messages and if the phone ends up in wrong hands it can be a security threat
//Instead use logs by importing 'dart:developer'
//printf is also called poor man's debugger


class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Main UI"), 
      actions: [
        PopupMenuButton<MenuActions>(onSelected: (value) async {
          switch(value){
            case MenuActions.logout:
              final shouldLogout= await showLogOutDialog(context);
              if(shouldLogout){
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil('/login/', (_)=>false);
              }
          }
        },
        itemBuilder: (context) {//itemBuilder requires a list to be returned so we wrapped the menuitem in a list
          return const [
            PopupMenuItem<MenuActions>(
            value: MenuActions.logout,
            child: Text("Logout"),
            )
          ];
        },)
      ],
      ),
      body: const Text("Hello world!!"),
    );
  }
}

//Dialog view for logout
Future<bool> showLogOutDialog(BuildContext context){
    return showDialog<bool>(
      context: context,
      builder:(context) {
      return AlertDialog(
        title: const Text("Log-out"),
        content: const Text("Are you sure you wan't to Log-out?"),
        actions: [
          TextButton(onPressed: () {
            Navigator.of(context).pop(true);
          },child: const Text("Log-out"),),
          TextButton(onPressed: () {
            Navigator.of(context).pop(false);
          },child: const Text("Cancel"),)
        ],
      );
    },
    ).then((value) => value?? false);
}