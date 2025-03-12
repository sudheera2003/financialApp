import 'package:financial_app/Calender/boxes.dart';
import 'package:financial_app/Calender/transaction.dart';
import 'package:financial_app/navigation_menu.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "AIzaSyDsi6C-e7rJDUIGXPdiHwT5GqP-eHtCe-w",
          authDomain: "financialapp-e0dfc.firebaseapp.com",
          projectId: "financialapp-e0dfc",
          storageBucket: "financialapp-e0dfc.appspot.com",
          messagingSenderId: "698261052536",
          appId: "1:698261052536:web:d1589a52ed14f1f216a18d",
          measurementId: "G-N8DV0QHGDB",
        ),
      );
    } else {
      await Firebase.initializeApp();
    }

    // Initialize Hive
    if (!kIsWeb) {
      final appDocumentDir = await getApplicationDocumentsDirectory();
      Hive.init(appDocumentDir.path);
    } else {
      await Hive.initFlutter();
    }

    // Register Hive adapters
    Hive.registerAdapter(TransactionAdapter());

    // Open Hive box
    boxTransactions = await Hive.openBox<Transaction>('transactionsBox');
    await Hive.openBox('mybox');

    runApp(const MyApp());
  } catch (e) {
    debugPrint('Initialization error: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Financial App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
      ),
      home: const NavigationMenu(),
    );
  }
}