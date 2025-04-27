import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  String fromCurrency = "USD";
  String toCurrency = "LKR";
  double rate = 0.0;
  double total = 0.0;
  TextEditingController amountController = TextEditingController();
  List<String> currencies = ["USD", "LKR"]; // Default values

  @override
  void initState() {
    super.initState();
    _getCurrencies();
  }

  Future<void> _getCurrencies() async {
    try {
      var response = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          currencies = (data['rates'] as Map<String, dynamic>).keys.toList();
          rate = data['rates'][toCurrency] ?? 0.0;
        });
      } else {
        throw Exception("Failed to load currency rates");
      }
    } catch (e) {
      print("Error fetching currencies: $e");
    }
  }

  Future<void> _getRate() async {
    try {
      var response = await http.get(Uri.parse('https://api.exchangerate-api.com/v4/latest/$fromCurrency'));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          rate = data['rates'][toCurrency] ?? 0.0;
        });
      } else {
        throw Exception("Failed to fetch rate");
      }
    } catch (e) {
      print("Error fetching rate: $e");
    }
  }

  void _swapCurrencies() {
    setState(() {
      String temp = fromCurrency;
      fromCurrency = toCurrency;
      toCurrency = temp;
    });
    _getRate().then((_) {
      double? amount = double.tryParse(amountController.text);
      if (amount != null) {
        setState(() {
          total = double.parse((amount * rate).toStringAsFixed(2));
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 27, 27, 29),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7C4DFF),
        elevation: 0,
        foregroundColor: Colors.white,
        title: const Text("Currency Converter"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
                child: TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Amount",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    labelStyle: const TextStyle(color: Colors.white),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.white),
                    ),
                  ),
                  onChanged: (value) {
                    double? amount = double.tryParse(value);
                    if (amount != null) {
                      setState(() {
                        total = double.parse((amount * rate).toStringAsFixed(2));
                      });
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 100,
                      child: DropdownButton<String>(
                        value: currencies.contains(fromCurrency) ? fromCurrency : null,
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white),
                        dropdownColor: const Color(0xFF1d2630),
                        items: currencies.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              fromCurrency = newValue;
                            });
                            _getRate();
                          }
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: _swapCurrencies,
                      icon: const Icon(
                        Icons.swap_horiz,
                        size: 40,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      child: DropdownButton<String>(
                        value: currencies.contains(toCurrency) ? toCurrency : null,
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white),
                        dropdownColor: const Color(0xFF1d2630),
                        items: currencies.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          if (newValue != null) {
                            setState(() {
                              toCurrency = newValue;
                            });
                            _getRate();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Card(
                color: Colors.black87,
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        "Exchange Rate: 1 $fromCurrency = $rate $toCurrency",
                        style: const TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        total.toStringAsFixed(2),
                        style: const TextStyle(color: Color(0xFF7C4DFF), fontSize: 40, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

