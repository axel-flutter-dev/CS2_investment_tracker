import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_app/widgets/add_item_widget.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  static const List<Map<String, dynamic>> items = [
    {'name': 'Sword', 'value': 150, 'image': Icons.security},
    {'name': 'Shield', 'value': 120, 'image': Icons.shield},
    {'name': 'Potion', 'value': 50, 'image': Icons.local_drink},
    {'name': 'Helmet', 'value': 80, 'image': Icons.sports_motorsports},
    {'name': 'Armor', 'value': 200, 'image': Icons.checkroom},
    {'name': 'Ring', 'value': 300, 'image': Icons.circle},
    {'name': 'Boots', 'value': 90, 'image': Icons.directions_walk},
    {'name': 'Bow', 'value': 160, 'image': Icons.architecture},
  ];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inventory')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 100,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 3 / 4,
          ),
          itemBuilder: (context, index) {
            final item = items[index];
            return Column(
              children: [
                Icon(item['image'], size: 40),
                Text(item['name']),
                Text('\$${item['value']}'),
              ],
            );
          },
        ),
      ),
      // This makes a button fixed at the bottom
      bottomSheet: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            final userUid = FirebaseAuth.instance.currentUser?.uid;
            if (userUid == null) return;
            // Open Add Item Popup
            showDialog(
              context: context,
              builder: (context) => AddItemPopup(uid: userUid),
            );
          },
          child: const Text('Add Item'),
        ),
      ),
    );
  }
}
