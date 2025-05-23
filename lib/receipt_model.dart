class Receipt {
  String? companyName;
  List<ReceiptItem>? items;
  int? totalQuantity;
  double? totalPrice;
  double? tax;
  double? subtotal;
  String? date;

  Receipt({
    this.companyName,
    this.items,
    this.totalQuantity,
    this.totalPrice,
    this.tax,
    this.subtotal,
    this.date,
  });

  factory Receipt.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return Receipt(
        companyName: null,
        items: [],
        totalQuantity: 0,
        totalPrice: 0.0,
        tax: 0.0,
        subtotal: 0.0,
        date: null,
      );
    }

    return Receipt(
      companyName: json['company_name'] as String?,
      items:
          (json['items'] as List?)
              ?.map((item) => ReceiptItem.fromJson(item))
              .toList() ??
          [],
      totalQuantity: (json['total_quantity'] as num?)?.toInt() ?? 0,
      totalPrice: (json['total_price'] as num?)?.toDouble() ?? 0.0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'company_name': companyName,
      'items': items?.map((item) => item.toJson()).toList(),
      'total_quantity': totalQuantity,
      'total_price': totalPrice,
      'tax': tax,
      'subtotal': subtotal,
      'date': date,
    };
  }
}

class ReceiptItem {
  final String? item;
  final int quantity;
  final double unitPrice;
  final double itemAmount;

  ReceiptItem({
    this.item,
    required this.quantity,
    required this.unitPrice,
    required this.itemAmount,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return ReceiptItem(
        item: null,
        quantity: 0,
        unitPrice: 0.0,
        itemAmount: 0.0,
      );
    }

    return ReceiptItem(
      item: json['item'] as String?,
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      itemAmount: (json['item_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'item': item,
      'quantity': quantity,
      'unit_price': unitPrice,
      'item_amount': itemAmount,
    };
  }
}
