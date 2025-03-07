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
  if(kIsWeb){
    await Firebase.initializeApp(options: const FirebaseOptions(apiKey: "AIzaSyDsi6C-e7rJDUIGXPdiHwT5GqP-eHtCe-w",
    authDomain: "financialapp-e0dfc.firebaseapp.com",
    projectId: "financialapp-e0dfc",
    storageBucket: "financialapp-e0dfc.firebasestorage.app",
    messagingSenderId: "698261052536",
    appId: "1:698261052536:web:d1589a52ed14f1f216a18d",
    measurementId: "G-N8DV0QHGDB"));
  }else{
    await Firebase.initializeApp();
  }

  if (!kIsWeb) {
    final appDocumentDir = await getApplicationDocumentsDirectory();
    Hive.init(appDocumentDir.path); // Use path_provider for proper initialization
  }

  await Hive.initFlutter();
  Hive.registerAdapter(TransactionAdapter()); // Register Adapter
  boxTransactions = await Hive.openBox<Transaction>('transactionsBox');
  var box =  await Hive.openBox('mybox');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Test App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins'
      ),
      home: NavigationMenu(),
    );
  }
}