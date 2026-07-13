class BookSaleModel {
  String? id;
  String itemId;
  String itemName;
  String itemType;
  int quantitySold;
  double totalPrice;
  String paymentMode; // 'cash' or 'online'
  DateTime saleDate;

  BookSaleModel({
    this.id,
    required this.itemId,
    required this.itemName,
    required this.itemType,
    required this.quantitySold,
    required this.totalPrice,
    required this.paymentMode,
    required this.saleDate,
  });

  factory BookSaleModel.fromJson(Map<String, dynamic> json, String documentId) {
    return BookSaleModel(
      id: documentId,
      itemId: json['itemId'] ?? '',
      itemName: json['itemName'] ?? '',
      itemType: json['itemType'] ?? 'book',
      quantitySold: json['quantitySold'] ?? 0,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      paymentMode: json['paymentMode'] ?? 'cash',
      saleDate: json['saleDate'] != null ? DateTime.parse(json['saleDate']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemName': itemName,
      'itemType': itemType,
      'quantitySold': quantitySold,
      'totalPrice': totalPrice,
      'paymentMode': paymentMode,
      'saleDate': saleDate.toIso8601String(),
    };
  }
}
