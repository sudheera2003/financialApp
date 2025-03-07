import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class CalculatorSelector extends StatefulWidget {
  const CalculatorSelector({ super.key });

  @override
  _CalculatorSelectorState createState() => _CalculatorSelectorState();
}

class _CalculatorSelectorState extends State<CalculatorSelector> {





 @override
Widget build(BuildContext context) {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color.fromARGB(255, 27, 27, 29),
      statusBarIconBrightness: Brightness.light, // Set icons to light
    ),
  );

  return SafeArea(
    child: Scaffold(
      backgroundColor: const Color.fromARGB(255, 27, 27, 29),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 27, 27, 29),
        foregroundColor: Colors.white,
        title: const Text('Calculator'),
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        backgroundColor: const Color.fromARGB(255, 27, 27, 29),
        width: 200,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [ 
              const SizedBox(height: 100),
              ListTile(
                title: const Center( // Center text inside ListTile
                  child: Text('Calculator', style: TextStyle(color: Colors.white)),
                ),
                onTap: () {},
              ),
              ListTile(
                title: const Center(
                  child: Text('Age Calculate', style: TextStyle(color: Colors.white)),
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

}