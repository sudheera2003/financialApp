import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:financial_app/components/big_button.dart';
import 'package:financial_app/components/login_text_field.dart';
import 'package:financial_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confPasswordController = TextEditingController();
  final fnameController = TextEditingController();
  final lnameController = TextEditingController();
  String errorMessage = "";

  bool passwordsMatch = true; // Track password matching

  void signUserUp() async {
    if (!mounted) return;

    // Validate passwords
    setState(() {
      passwordsMatch = passwordController.text == confPasswordController.text;
    });

    if (!passwordsMatch) return;

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(color: Colors.deepOrangeAccent),
        );
      },
    );

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: usernameController.text.trim(),
        password: passwordController.text.trim(),
      );

    Future addUserDetails(
      String fname, String lname, String email, String password
    ) async {
      await FirebaseFirestore.instance.collection('users').add({
          'fname': fname,
          'lname': lname,
          'email': email,
          'password': password,
        }
      );
    }  

    
      addUserDetails(
          fnameController.text.trim(),
          lnameController.text.trim(),
          usernameController.text.trim(),
          passwordController.text.trim(),
      );

      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      
      errorMessage = e.message.toString();
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      if (mounted) {
        Future.delayed(Duration.zero, () {
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: Text("Signup Failed"),
                  content: Text(errorMessage),
                  actions: [
                    TextButton(
                      onPressed: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        }
                      },
                      child: Text("OK"),
                    ),
                  ],
                );
              },
            );
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 27, 27, 29),
        body: SingleChildScrollView(
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('images/loading_logo.png',height: 200,),
                  Text(
                    'SIGN UP',
                    style: TextStyle(color: Colors.white, fontSize: 40),
                  ),
                  const SizedBox(height: 25),
                  // First Name
                  LoginTextField(
                    controller: fnameController,
                    hintText: "Enter first name",
                    obscureText: false,
                  ),
                  const SizedBox(height: 25),
                  //last name
                  LoginTextField(
                    controller: lnameController,
                    hintText: "Enter last name",
                    obscureText: false,
                  ),
                  const SizedBox(height: 25),
                  // Username
                  LoginTextField(
                    controller: usernameController,
                    hintText: "Enter email",
                    obscureText: false,
                  ),
                  const SizedBox(height: 25),
                  // Password
                  LoginTextField(
                    controller: passwordController,
                    hintText: "Enter password",
                    obscureText: true,
                    borderColor: passwordsMatch ? Colors.white : Colors.red,
                  ),
                  const SizedBox(height: 25),
                  // Confirm Password
                  LoginTextField(
                    controller: confPasswordController,
                    hintText: "Confirm password",
                    obscureText: true,
                    borderColor: passwordsMatch ? Colors.white : Colors.red,
                  ),
                  if (!passwordsMatch)
                    Padding(
                      padding: const EdgeInsets.only(left: 30, top: 5),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Passwords do not match",
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    ),
                  const SizedBox(height: 25),
                  // Sign Up Button
                  BigButton(
                    onTap: signUserUp,
                    text: 'Sign up',
                  ),
                  const SizedBox(height: 50),
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade700,
                          thickness: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade700,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: ()  async {
                          UserCredential? userCredential = await AuthService().signInWithGoogle(context);
                          if (userCredential != null) {
                            // Handle successful sign-in
                          } else {
                            // Handle failed sign-in (or cancellation)
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: Image.asset(
                            'images/google_logo.png',
                            height: 30,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already Have an Account?',
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(width: 5),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          'Login now',
                          style: TextStyle(color: Colors.deepOrangeAccent),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 40,)
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
