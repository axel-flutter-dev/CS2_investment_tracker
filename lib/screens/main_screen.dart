import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'inventory_screen.dart';
import 'settings_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/services/inventory_provider.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late int _selectedIndex;


  @override
  void initState() {
    super.initState();
    bool isNewAccount =  ref.read(inventoryProvider.notifier).newAccount;

    if (isNewAccount) {
      _selectedIndex = 1; // Navigate to Inventory tab for new accounts
    } else {
      _selectedIndex = 0; // Default to Dashboard tab
    }
  }
  

  // pages for each tab
  static const List<Widget> _pages = [
    DashboardScreen(),
    InventoryScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped (int index) { 
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon (Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon (Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon (Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
