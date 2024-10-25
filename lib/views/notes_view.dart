// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:mynotes/constants/routes.dart';
import 'package:mynotes/enums/menu_action.dart';
import 'package:mynotes/services/auth/auth_service.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}
// avoid print calls in production code, because OS keeps track of these messages and if the phone ends up in wrong hands it can be a security threat
//Instead use logs by importing 'dart:developer'
//Log only accepts String as argument so we use toString() in it.
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
                await AuthService.firebase().logOut();
                Navigator.of(context).pushNamedAndRemoveUntil(loginRoute, (_)=>false);
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