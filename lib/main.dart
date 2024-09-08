import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mynotes/firebase_options.dart';
import 'package:mynotes/views/login_view.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();//Now we dont need to initialize firebsae.auth in every widget
  final modes = await FlutterDisplayMode.supported;
  modes.sort((a, b) => b.refreshRate.compareTo(a.refreshRate));
  await FlutterDisplayMode.setPreferredMode(modes.first);

  runApp(MaterialApp(
    title: 'Flutter Demo',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 104, 255, 247)),
      useMaterial3: false,
    ),
    home: const HomePage(),
  ));
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        toolbarHeight: 50,
      ),
      body: FutureBuilder(
        future:Firebase.initializeApp(
                  options: DefaultFirebaseOptions.currentPlatform,
                ) ,
        builder: (context, snapshot) {
          switch(snapshot.connectionState){
            case ConnectionState.done:
              final user=FirebaseAuth.instance.currentUser;
              if(user?.emailVerified??false){
                print("You are verified");
              }
              else{
                print("You need to verify your E-mail first");
              }
              return Text("Done");
        default:
        return const Text('Loading...');
              
          }
        },
      ),
    );
  }
}