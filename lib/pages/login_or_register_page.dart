import 'package:financial_app/pages/changePages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  _LoginOrRegisterPageState createState() => _LoginOrRegisterPageState();
}

class _LoginOrRegisterPageState extends State<LoginOrRegisterPage> {
  bool showLoginPage = true; // Toggle between Login & Register pages

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  void signOutUser() {
    FirebaseAuth.instance.signOut();
    setState(() {}); // Refresh UI after logout
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;


    return GestureDetector(
      onTap: () {
        if (user == null) {
           Navigator.push(context, 
                              MaterialPageRoute(builder: (context) {
                                return ChangePages();
                              })
                            );
        } else {
          // Log out
          signOutUser();
        }
      },
      child: Row(
        children: [
          Text(
            user == null ? 'Login' : 'Logout',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(width: 5),
          Icon(
            user == null ? Icons.login : Icons.logout,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
