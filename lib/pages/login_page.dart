import 'package:financial_app/components/big_button.dart';
import 'package:financial_app/components/login_text_field.dart';
import 'package:financial_app/pages/forgot_password_page.dart';
import 'package:financial_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class LoginPage extends StatefulWidget {

  final void Function()? onTap;

   const LoginPage({ super.key, required this.onTap });

  
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  //text editing controller
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  //sign in user method
  void signUserIn() async {
  if (!mounted) return;

  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF7C4DFF),));
    },
  );

  try {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: usernameController.text.trim(),
      password: passwordController.text.trim(),
    );

    // Ensure the dialog is dismissed safely
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

  } catch (e) {
    // Ensure loading dialog is dismissed safely
    if (mounted && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    // Show error message only if the widget is still active
    if (mounted) {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Login Failed"),
                content: Text("Invalid Email or Password"),
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
      }
      );
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
                  
                  Text('LOGIN', style: TextStyle(color: Colors.white, fontSize: 40),),
          
                  const SizedBox(height: 25,),
                  // username
                  LoginTextField(
                    controller: usernameController,
                    hintText: "Username",
                    obscureText: false,
                  ),
          
                  const SizedBox(height: 25,),
          
                  //password
                  LoginTextField(
                    controller: passwordController,
                    hintText: "Password",
                    obscureText: true,
                  ),
                  
                  const SizedBox(height: 10,),
          
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                         onTap: () {
                            Navigator.push(context, 
                              MaterialPageRoute(builder: (context) {
                                return ForgotPasswordPage();
                              })
                            );
                          },
                          child: Text('Forget Password ?', 
                          style: TextStyle(color: Color(0xFF7C4DFF), fontSize:15)
                          )
                        ),
                      ],
                    ),
                  ),
          
                  const SizedBox(height: 25,),
          
                  //sign in button
                  BigButton(onTap: signUserIn,text: 'Sign in',),
          
                  const SizedBox(height: 70,),
          
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
                        child: Text('Or continue with',style: TextStyle(color: Colors.grey.shade400,),),
                      ),
          
                      Expanded(
                        child: Divider(
                          color: Colors.grey.shade700,
                          thickness: 1,
                        ),
                      ),
                    ],
                  ),
          
                  const SizedBox(height: 30,),
          
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
                          child: Image.asset('images/google_logo.png', height: 30,)
                          ),
                      ),
                    ],
                  ),
          
                  const SizedBox(height: 70,),
          
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Not a member?',style:TextStyle(color: Colors.white),),
                      SizedBox(width: 5,),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text('Register now',style:TextStyle(color: Color(0xFF7C4DFF)),)
                        ),
                    ],
                  )
          
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}