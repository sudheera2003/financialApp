import 'package:financial_app/navigation_menu.dart';
import 'package:financial_app/pages/login_or_register_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
const AuthPage({ super.key });

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(), 
        builder: (context, snapshot) {
            if(snapshot.hasData){
                return NavigationMenu(); // navigation if user logged in
            } else {
              return LoginOrRegisterPage(); // if user is not logged in
            }
      },
      ),
    );
  }
}