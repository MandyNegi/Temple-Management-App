import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:temple/models/books_management/book_item_model.dart';
import 'package:temple/models/books_management/book_sale_model.dart';

class FirestoreService {
  static final CollectionReference _items = FirebaseFirestore.instance.collection('book_items');
  static final CollectionReference _sales = FirebaseFirestore.instance.collection('book_sales');

  static Future<DocumentReference> addItem(BookItemModel item) {
    return _items.add(item.toJson());
  }

  static Future<String> uploadGiftFile(File file) async {
    final storage = FirebaseStorage.instance;
    final name = file.uri.pathSegments.last;
    final ref = storage.ref().child('gift_items').child(name);
    final task = await ref.putFile(file);
    final url = await ref.getDownloadURL();
    return url;
  }

  static Future<void> updateItem(String id, Map<String, dynamic> data) {
    return _items.doc(id).update(data);
  }

  static Future<void> deleteItem(String id) {
    return _items.doc(id).delete();
  }

  /// Record a sale and decrement stock inside a transaction.
  static Future<void> recordSale(BookSaleModel sale) async {
    final FirebaseFirestore db = FirebaseFirestore.instance;
    final itemRef = _items.doc(sale.itemId);
    final saleRef = _sales.doc();

    await db.runTransaction((tx) async {
      final snapshot = await tx.get(itemRef);
      if (!snapshot.exists) throw Exception('Item not found');
      final currentStock = (snapshot.data() as Map<String, dynamic>)['stockQuantity'] ?? 0;
      if (currentStock < sale.quantitySold) throw Exception('Insufficient stock');
      tx.update(itemRef, {'stockQuantity': currentStock - sale.quantitySold});
      tx.set(saleRef, sale.toJson());
    });
  }

  /// Export all sales to a CSV file and return the file path.
  static Future<String> exportSalesCsv() async {
    final query = await _sales.orderBy('saleDate').get();
    final rows = <List<String>>[];
    rows.add(['saleId', 'itemId', 'itemName', 'itemType', 'quantitySold', 'totalPrice', 'paymentMode', 'saleDate']);
    for (var d in query.docs) {
      final m = d.data() as Map<String, dynamic>;
      rows.add([
        d.id,
        m['itemId']?.toString() ?? '',
        m['itemName']?.toString() ?? '',
        m['itemType']?.toString() ?? '',
        m['quantitySold']?.toString() ?? '0',
        m['totalPrice']?.toString() ?? '0',
        m['paymentMode']?.toString() ?? '',
        m['saleDate']?.toString() ?? '',
      ]);
    }

    final csv = rows.map((r) => r.map((c) => '"${c.replaceAll('"', '""')}"').join(',')).join('\n');
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/book_sales_export_${DateTime.now().toIso8601String()}.csv');
    await file.writeAsString(csv);
    return file.path;
  }
}
