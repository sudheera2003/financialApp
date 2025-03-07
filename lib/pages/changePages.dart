import 'package:financial_app/pages/login_page.dart';
import 'package:financial_app/pages/register_page.dart';
import 'package:flutter/material.dart';

class ChangePages extends StatefulWidget {
  const ChangePages({ super.key });

  @override
  _ChangePagesState createState() => _ChangePagesState();
}

class _ChangePagesState extends State<ChangePages> {

  bool showLoginPage = true;

  void togglePages(){

    setState(() {
        showLoginPage = !showLoginPage;
    });

  }


  @override
  Widget build(BuildContext context) {
    if(showLoginPage){
      return LoginPage(
        onTap: togglePages,
      );
    } else {
      return RegisterPage(
        onTap: togglePages,
      );
    }
  }
}
