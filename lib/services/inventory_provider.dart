import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InventoryItem {
  final String name;
  final double purchasePrice;
  final int quantity;

  InventoryItem({
    required this.name,
    required this.purchasePrice,
    required this.quantity,
  });

  factory InventoryItem.fromMap(Map<String, dynamic> data) {
    return InventoryItem(
      name: data['name'] ?? '',
      purchasePrice: (data['purchasePrice'] ?? 0).toDouble(),
      quantity: (data['quantity'] ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'purchasePrice': purchasePrice,
      'quantity': quantity,
    };
  }
  
}

class InventoryNotifier extends Notifier<List<InventoryItem>> {
  @override
  List<InventoryItem> build() {
    return [];
  }

  final _firestore = FirebaseFirestore.instance;

  // Fetch or create user document + inventory
  Future<void> fetchUserInventory(String uid, String? email) async {
    final userRef = _firestore.collection('users').doc(uid);

    final doc = await userRef.get();
    if (!doc.exists) {
      // Create user doc if it doesn't exist
      await userRef.set({
        'email': email ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLogin': FieldValue.serverTimestamp(),
        'tier': 'free',
        'placeholderData': [],
        'placeholderSettings': {},
      });

      // Create empty inventory sub-collection
      await userRef.collection('Inventory').doc('_init').set({
        'initialized': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      state = [];
    } else {
      // Update last login timestamp
      await userRef.update({'lastLogin': FieldValue.serverTimestamp()});

      // Fetch inventory subcollection
      final snapshot = await userRef.collection('Inventory').get();

      state = snapshot.docs
          .map((doc) => InventoryItem.fromMap(doc.data()))
          .toList();
    }
  }
  void addItem(InventoryItem item, String uid) async {
    final userRef = _firestore.collection('users').doc(uid);
    await userRef.collection('Inventory').add(item.toMap());
    state = [...state, item];
  }

  void removeItem(InventoryItem item, String uid) async {
    final userRef = _firestore.collection('users').doc(uid);

    // Find doc in subcollection with the same name (simplest way)
    final snapshot = await userRef
        .collection('Inventory')
        .where('name', isEqualTo: item.name)
        .get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }

    state = state.where((i) => i.name != item.name).toList();
  }

  void clearInventory(String uid) async {
    final userRef = _firestore.collection('users').doc(uid);
    final snapshot = await userRef.collection('Inventory').get();

    for (final doc in snapshot.docs) {
      await doc.reference.delete();
    }

    state = [];
  }

  /* void setInventory(List<InventoryItem> items) => state = [...items];
  void addItem(InventoryItem item) => state = [...state, item];
  void removeItem(InventoryItem item) =>
      state = state.where((i) => i.name != item.name).toList();
  void clearInventory() => state = []; */
}

final inventoryProvider =
    NotifierProvider<InventoryNotifier, List<InventoryItem>>(InventoryNotifier.new);