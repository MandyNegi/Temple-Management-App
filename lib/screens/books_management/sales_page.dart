import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:temple/models/books_management/book_item_model.dart';
import 'package:temple/models/books_management/book_sale_model.dart';
import 'package:temple/services/firestore_service.dart';
import 'package:temple/utils/colors.dart';
import 'package:temple/widget/show_custom_snakbar.dart';
import 'package:temple/widget/confirm_dialog.dart';
// import 'package:temple/utils/constant.dart';
import 'package:temple/utils/constant.dart' as CustomConstant;

class SalesPage extends StatefulWidget {
  const SalesPage({Key? key}) : super(key: key);

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final CollectionReference _itemsCollection = FirebaseFirestore.instance.collection('book_items');
  final CollectionReference _salesCollection = FirebaseFirestore.instance.collection('book_sales');

  String? _selectedItemId;
  final TextEditingController _quantityController = TextEditingController();
  String _paymentMode = 'cash'; // 'cash' or 'online'
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        title: const Text("Record Sale", style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildItemSelector(),
              const SizedBox(height: 20),
              TextField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: "Quantity Sold"),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _paymentMode,
                decoration: const InputDecoration(labelText: "Payment Mode"),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text("Cash")),
                  DropdownMenuItem(value: 'online', child: Text("Online")),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _paymentMode = val);
                },
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.mainColor),
                      onPressed: _submitSale,
                      child: const Text("Record Sale", style: TextStyle(color: Colors.white)),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItemSelector() {
    return StreamBuilder<QuerySnapshot>(
      stream: _itemsCollection.snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final items = snapshot.data!.docs.map((doc) {
          return BookItemModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        if (items.isEmpty) {
          return const Text('No items available yet. Add an item first.');
        }

        if (_selectedItemId != null && !items.any((item) => item.id == _selectedItemId)) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedItemId = null;
              });
            }
          });
        }

        return DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: "Select Item"),
          value: _selectedItemId,
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item.id,
              child: Text("${item.name} (${item.type.toUpperCase()}) - ₹${item.price} [Stock: ${item.stockQuantity}]"),
            );
          }).toList(),
          onChanged: (val) {
            setState(() {
              _selectedItemId = val;
            });
          },
        );
      },
    );
  }

  Future<void> _submitSale() async {
    if (_selectedItemId == null) {
      showCustomSnakBar("Please select an item", title: "Error");
      return;
    }

    final snapshot = await _itemsCollection.get();
    final items = snapshot.docs.map((doc) {
      return BookItemModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
    }).toList();

    final selectedItem = items.firstWhere(
      (item) => item.id == _selectedItemId,
      orElse: () => throw Exception('Selected item not found'),
    );
    int quantity = int.tryParse(_quantityController.text) ?? 0;
    if (quantity <= 0) {
      showCustomSnakBar("Please enter a valid quantity", title: "Error");
      return;
    }
    if (quantity > selectedItem.stockQuantity) {
      showCustomSnakBar("Not enough stock available", title: "Error");
      return;
    }

    double totalPrice = quantity * selectedItem.price;

    final confirm = await showConfirmDialog(context,
      title: 'Confirm Sale',
      content: 'Sell $quantity × ${selectedItem.name} for ₹${(totalPrice).toStringAsFixed(2)}?',
      confirmText: 'Confirm');
    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {

      // 1. Record Sale (transactionally updates stock)
      BookSaleModel sale = BookSaleModel(
        itemId: selectedItem.id!,
        itemName: selectedItem.name,
        itemType: selectedItem.type,
        quantitySold: quantity,
        totalPrice: totalPrice,
        paymentMode: _paymentMode,
        saleDate: DateTime.now(),
      );
      debugPrint('Sales: attempting Firestore sale transaction for item ${sale.itemId}');
      await FirestoreService.recordSale(sale);
      debugPrint('Sales: Firestore sale transaction succeeded');
      showCustomSnakBar("Sale recorded successfully", title: "Success");
      _quantityController.clear();
      setState(() => _selectedItemId = null);
    } catch (e) {
      debugPrint('Sales: sale transaction failed: $e');
      showCustomSnakBar("Failed to record sale: ${e.toString()}", title: "Error");
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
