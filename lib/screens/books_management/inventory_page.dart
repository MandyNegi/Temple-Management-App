import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:temple/models/books_management/book_item_model.dart';
import 'package:temple/services/firestore_service.dart';
import 'package:temple/utils/colors.dart';
import 'package:temple/widget/confirm_dialog.dart';
import 'package:temple/widget/empty_state.dart';
import 'package:flutter/services.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final CollectionReference _itemsCollection = FirebaseFirestore.instance.collection('book_items');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.mainColor,
        elevation: 0,
        title: const Text("Inventory", style: TextStyle(fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Books"),
            Tab(text: "Gift Items"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildInventoryList('book'),
          _buildInventoryList('gift'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.mainColor,
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddItemDialog(context, _tabController.index == 0 ? 'book' : 'gift');
        },
      ),
    );
  }

  Widget _buildInventoryList(String type) {
    return StreamBuilder<QuerySnapshot>(
      stream: _itemsCollection.where('type', isEqualTo: type).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const EmptyState(message: 'No books or gift items available. Tap + to add.', icon: Icons.menu_book);
        }
            return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var doc = snapshot.data!.docs[index];
            var item = BookItemModel.fromJson(doc.data() as Map<String, dynamic>, doc.id);
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ListTile(
                    title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Price: ₹${item.price} | Stock: ${item.stockQuantity}\nLocation: ${item.storageLocation}" + (item.filePath != null ? '\nAttached: ${item.filePath!.split('/').last}' : '')),
                    onTap: () => _showEditItemDialog(context, item),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (item.filePath != null) IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    tooltip: 'Copy file link',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: item.filePath!));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File link copied')));
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      final ok = await showConfirmDialog(context,
                          title: 'Confirm delete', content: 'Delete "${item.name}"? This cannot be undone.', confirmText: 'Delete');
                      if (ok == true) {
                        await FirestoreService.deleteItem(item.id!);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item deleted')));
                      }
                    },
                  ),
                ]),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddItemDialog(BuildContext context, String type) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final stockController = TextEditingController();
    final locationController = TextEditingController();
    String? pickedFileUrl;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add New ${type == 'book' ? 'Book' : 'Gift Item'}"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
                TextField(controller: priceController, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
                TextField(controller: stockController, decoration: const InputDecoration(labelText: "Stock Quantity"), keyboardType: TextInputType.number),
                TextField(controller: locationController, decoration: const InputDecoration(labelText: "Storage Location")),
                    if (type == 'gift') ...[
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.attach_file),
                        label: const Text('Attach File'),
                        onPressed: () async {
                          final path = await FlutterDocumentPicker.openDocument();
                          if (path != null) {
                            final file = File(path);
                            final url = await FirestoreService.uploadGiftFile(file);
                            pickedFileUrl = url;
                            if (!mounted) return;
                            ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('File uploaded')));
                          }
                        },
                      ),
                    ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) return;
                final newItem = BookItemModel(
                  type: type,
                  name: nameController.text.trim(),
                  price: double.tryParse(priceController.text) ?? 0.0,
                  stockQuantity: int.tryParse(stockController.text) ?? 0,
                  storageLocation: locationController.text.trim(),
                  filePath: pickedFileUrl,
                );
                FirestoreService.addItem(newItem);
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _showEditItemDialog(BuildContext context, BookItemModel item) {
    final nameController = TextEditingController(text: item.name);
    final priceController = TextEditingController(text: item.price.toString());
    final stockController = TextEditingController(text: item.stockQuantity.toString());
    final locationController = TextEditingController(text: item.storageLocation);
    String? pickedFileUrl = item.filePath;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit ${item.type == 'book' ? 'Book' : 'Gift Item'}"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
                TextField(controller: priceController, decoration: const InputDecoration(labelText: "Price"), keyboardType: TextInputType.number),
                TextField(controller: stockController, decoration: const InputDecoration(labelText: "Stock Quantity"), keyboardType: TextInputType.number),
                TextField(controller: locationController, decoration: const InputDecoration(labelText: "Storage Location")),
                if (item.type == 'gift') ...[
                  const SizedBox(height: 8),
                  Row(children: [
                    ElevatedButton.icon(
                      icon: const Icon(Icons.attach_file),
                      label: const Text('Replace File'),
                      onPressed: () async {
                        final path = await FlutterDocumentPicker.openDocument();
                        if (path != null) {
                          final file = File(path);
                          final url = await FirestoreService.uploadGiftFile(file);
                          if (!mounted) return;
                          setState(() { pickedFileUrl = url; });
                          ScaffoldMessenger.of(this.context).showSnackBar(const SnackBar(content: Text('File uploaded')));
                        }
                      },
                    ),
                    const SizedBox(width: 8),
                    if (pickedFileUrl != null)
                      IconButton(icon: const Icon(Icons.delete), onPressed: () { setState(() { pickedFileUrl = null; }); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('File removed'))); }),
                  ]),
                  if (pickedFileUrl != null) Padding(
                    padding: const EdgeInsets.only(top:8.0),
                    child: Text('Attached: ${pickedFileUrl!.split('/').last}', style: const TextStyle(fontSize: 12)),
                  )
                ],
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () {
                final updated = {
                  'name': nameController.text,
                  'price': double.tryParse(priceController.text) ?? 0.0,
                  'stockQuantity': int.tryParse(stockController.text) ?? 0,
                  'storageLocation': locationController.text,
                  'filePath': pickedFileUrl,
                };
                FirestoreService.updateItem(item.id!, updated);
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
