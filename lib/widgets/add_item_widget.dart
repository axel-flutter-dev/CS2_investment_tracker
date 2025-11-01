import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_app/services/inventory_provider.dart';
import 'package:my_app/services/local_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';

final log = Logger();

class AddItemPopup extends ConsumerStatefulWidget {
  final String uid; // Needed to update Firestore
  const AddItemPopup({super.key, required this.uid});

  @override
  ConsumerState<AddItemPopup> createState() => _AddItemPopupState();
}

class _AddItemPopupState extends ConsumerState<AddItemPopup> {
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();

  bool _isloading = false;

  void _addItem() async {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim()) ?? 0.0;
    final quantity = int.tryParse(_quantityController.text.trim()) ?? 0;
    final initExists = ref.read(inventoryProvider.notifier).initExists;

    if (name.isEmpty || price <= 0 || quantity <= 0) {
      // Show error
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter valid item details.')),
      );
      return;
    }

    setState(() {
      _isloading = true;
    });

    final item = InventoryItem(
      name: name,
      purchasePrice: price,
      quantity: quantity,
    );

    try {
      // Add item to Firestore and update state
      ref.read(inventoryProvider.notifier).addItem(item, widget.uid);

      // remove the placeholder _init document
      if (initExists) {
        log.i('Removing _init document');
        final userRef = FirebaseFirestore.instance
            .collection('users')
            .doc(widget.uid);
        final initDoc = await userRef
            .collection('Inventory')
            .doc('_init')
            .get();
        if (initDoc.exists) {
          await userRef.collection('Inventory').doc('_init').delete();
        }
        ref.read(inventoryProvider.notifier).initExists = false;
      }

      if (!mounted) return;
      Navigator.of(context).pop(); // Close popup on success
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Item added successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error adding item: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Autocomplete<String>(
            optionsBuilder: (TextEditingValue textEditingValue) {
              if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
              }
              return validItemNames.where(
                (name) => name.toLowerCase().contains(
                  textEditingValue.text.toLowerCase(),
                ),
              );
            },
            onSelected: (String selection) {
              _nameController.text = selection; // update the controller
            },
            fieldViewBuilder:
                (
                  BuildContext context,
                  TextEditingController fieldTextEditingController,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  return TextField(
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
                    decoration: const InputDecoration(labelText: 'Item Name'),
                  );
                },
          ),
          TextField(
            controller: _priceController,
            decoration: const InputDecoration(labelText: 'Purchase Price'),
            keyboardType: TextInputType.number,
          ),

          TextField(
            controller: _quantityController,
            decoration: const InputDecoration(labelText: 'Quantity'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isloading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (!validItemNames.contains(_nameController.text)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please select a valid item name'),
                ),
              );
              return; // Stop here if invalid
            }
            _isloading ? null : _addItem();
          },
          child: _isloading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Add'),
        ),
      ],
    );
  }
}
