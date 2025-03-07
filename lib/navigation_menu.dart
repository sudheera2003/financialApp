import 'package:financial_app/Calender/calanderPage.dart';
import 'package:financial_app/menus/home.dart';
import 'package:financial_app/menus/more.dart';
import 'package:financial_app/menus/stats.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavigationMenu extends StatelessWidget {

  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());

    return Scaffold(
      bottomNavigationBar: Obx(
        () => NavigationBarTheme(
          data: NavigationBarThemeData(
            indicatorColor: Colors.transparent,
            overlayColor: WidgetStateProperty.all(Colors.transparent),
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
              (Set<WidgetState> states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(color: Colors.deepOrangeAccent);
                }
                return const TextStyle(color: Colors.white);
              },
            ),
          ),
          child: NavigationBar(
            backgroundColor: const Color.fromARGB(255, 27, 27, 29),
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: (index) => controller.selectedIndex.value = index,
            destinations: [
              _buildNavItem(Icons.home, 'Home', controller.selectedIndex.value == 0),
              _buildNavItem(Icons.data_usage, 'Stats', controller.selectedIndex.value == 1),
              _buildNavItem(Icons.calendar_month, 'Calander', controller.selectedIndex.value == 2),
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
      icon: Icon(icon, color: isSelected ? Colors.deepOrangeAccent : Colors.white),
      label: label,
    );
  }

}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;


  final screens = [
    const Calanderpage(),
    const Stats(),
    const Home(),
    const More(),
    
  ];
}