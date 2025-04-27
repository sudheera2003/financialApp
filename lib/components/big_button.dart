import 'package:flutter/material.dart';

class BigButton extends StatefulWidget {

  final void Function()? onTap;
  final String text;

  const BigButton({ super.key, required this.onTap, required this.text});

  @override
  _BigButtonState createState() => _BigButtonState();
}

class _BigButtonState extends State<BigButton> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: EdgeInsets.all(15),
        margin: EdgeInsets.symmetric(horizontal: 100),
        decoration: BoxDecoration(
          color: Color(0xFF7C4DFF),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(widget.text,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.white),),
          ),
      ),
    );
  }
}