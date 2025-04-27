import 'package:financial_app/Calender/calanderPage.dart';
import 'package:financial_app/accounts/account.dart';
import 'package:financial_app/dashboard_page.dart';
import 'package:financial_app/menus/more.dart';       
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:financial_app/stats/stats.dart';

class NavigationMenu extends StatelessWidget {

  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBarTheme(
          data: NavigationBarThemeData(
            labelTextStyle: MaterialStateProperty.all(
            const TextStyle(color: Colors.white, fontSize: 12),
          ),
          iconTheme: MaterialStateProperty.all(const IconThemeData(color: Colors.white)),
          indicatorColor: const Color(0xFF7C4DFF),
          backgroundColor: const Color(0xFF2C2C2E),
          surfaceTintColor: Colors.transparent,
          
          ),
          child: NavigationBar(
            backgroundColor: const Color.fromARGB(255, 27, 27, 29),
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: (index) => controller.selectedIndex.value = index,
            destinations: [
              _buildNavItem(Icons.home, 'Home', controller.selectedIndex.value == 0),
              _buildNavItem(Icons.bar_chart, 'Stats', controller.selectedIndex.value == 1),
              _buildNavItem(Icons.account_balance_wallet_outlined, 'Accounts', controller.selectedIndex.value == 2),
              _buildNavItem(Icons.more_horiz, 'More', controller.selectedIndex.value == 3),
            ],
          ),
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }


  NavigationDestination _buildNavItem(IconData icon, String label, bool isSelected) {
    return NavigationDestination(
      icon: Icon(icon, color: Colors.white),
      label: label,
    );
  }

}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;


  final screens = [
    const DashboardPage(),
    const Stats(),
    const Account(),
    const More(),
    
  ];
}