class BookItemModel {
  String? id;
  String type; // 'book' or 'gift'
  String name;
  double price;
  int stockQuantity;
  String storageLocation;
  String? filePath;

  BookItemModel({
    this.id,
    required this.type,
    required this.name,
    required this.price,
    required this.stockQuantity,
    required this.storageLocation,
    this.filePath,
  });

  factory BookItemModel.fromJson(Map<String, dynamic> json, String documentId) {
    return BookItemModel(
      id: documentId,
      type: json['type'] ?? 'book',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      stockQuantity: json['stockQuantity'] ?? 0,
      storageLocation: json['storageLocation'] ?? '',
      filePath: json['filePath'] as String?, 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'price': price,
      'stockQuantity': stockQuantity,
      'storageLocation': storageLocation,
      'filePath': filePath,
    };
  }
}
