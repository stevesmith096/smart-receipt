class Receipt {
  String? companyName;
  List<ReceiptItem>? items;
  int? totalQuantity;
  double? totalPrice;
  double? tax;
  double? subtotal;
  double? serviceCharge;
  String? date;
  Validation? validation; // <-- Add this
  String? category;

  Receipt({
    this.companyName,
    this.items,
    this.totalQuantity,
    this.totalPrice,
    this.tax,
    this.subtotal,
    this.serviceCharge,
    this.date,
    this.validation,
    this.category,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      companyName: json['company_name'],
      category: json['category'],

      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => ReceiptItem.fromJson(item))
              .toList(),
      totalQuantity: json['total_quantity'],
      totalPrice: (json['total_price'] as num?)?.toDouble(),
      tax: (json['tax'] as num?)?.toDouble(),
      subtotal: (json['subtotal'] as num?)?.toDouble(),
      serviceCharge:
          (json["service_charge"] as num?)?.toDouble(), // ✅ Parse here

      date: json['date'],
      validation:
          json['validation'] != null
              ? Validation.fromJson(json['validation'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'company_name': companyName,
      'items': items?.map((i) => i.toJson()).toList(),
      'total_quantity': totalQuantity,
      'total_price': totalPrice,
      'tax': tax,
      'subtotal': subtotal,
      "service_charge": serviceCharge,
      'date': date,
      'validation': validation?.toJson(),
    };
  }

  Receipt copyWith({
    String? companyName,
    List<ReceiptItem>? items,
    int? totalQuantity,
    double? totalPrice,
    double? tax,
    double? subtotal,
    double? serviceCharge,
    String? date,
    Validation? validation,
    String? category,
  }) {
    return Receipt(
      companyName: companyName ?? this.companyName,
      items: items ?? this.items,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      totalPrice: totalPrice ?? this.totalPrice,
      tax: tax ?? this.tax,
      subtotal: subtotal ?? this.subtotal,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      date: date ?? this.date,
      validation: validation ?? this.validation,
      category: category ?? this.category,
    );
  }
}

class ReceiptItem {
  String? item;
  int? quantity;
  double? unitPrice;
  double? itemAmount;

  ReceiptItem({this.item, this.quantity, this.unitPrice, this.itemAmount});

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      item: json['item'],
      quantity:
          (json['quantity'] is double)
              ? (json['quantity'] as double).toInt()
              : json['quantity'],
      unitPrice: (json['unit_price'] as num?)?.toDouble(),
      itemAmount: (json['item_amount'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'item': item,
    'quantity': quantity,
    'unit_price': unitPrice,
    'item_amount': itemAmount,
  };
}

class Validation {
  List<String> warnings;
  List<String> potentialIssues;
  List<String> securityFeaturesDetected;

  Validation({
    this.warnings = const [],
    this.potentialIssues = const [],
    this.securityFeaturesDetected = const [],
  });

  factory Validation.fromJson(Map<String, dynamic> json) {
    return Validation(
      warnings: List<String>.from(json['warnings'] ?? []),
      potentialIssues: List<String>.from(json['potential_issues'] ?? []),
      securityFeaturesDetected: List<String>.from(
        json['security_features_detected'] ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'warnings': warnings,
    'potential_issues': potentialIssues,
    'security_features_detected': securityFeaturesDetected,
  };
}
