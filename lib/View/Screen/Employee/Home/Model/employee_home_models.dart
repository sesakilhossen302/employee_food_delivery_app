class CategoryModel {
  final String id;
  final String name;
  final String iconEmoji;
  final String? iconUrl;
  final int bgColorValue;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconEmoji,
    this.iconUrl,
    required this.bgColorValue,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      iconEmoji: json['iconEmoji'] ?? '',
      iconUrl: json['iconUrl'],
      bgColorValue: json['bgColorValue'] ?? 0xFFEBF4FF,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconEmoji': iconEmoji,
      'iconUrl': iconUrl,
      'bgColorValue': bgColorValue,
    };
  }
}

class ProductModel {
  final String id;
  final String name;
  final String unit;
  final double price;
  final double? originalPrice;
  final String imageUrl;
  final bool isSale;
  final String category;
  final String description;
  final int maxPerOrder;
  final bool inStock;

  ProductModel({
    required this.id,
    required this.name,
    required this.unit,
    required this.price,
    this.originalPrice,
    required this.imageUrl,
    this.isSale = false,
    this.category = 'Drinks',
    this.description = '',
    this.maxPerOrder = 12,
    this.inStock = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      unit: json['unit'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] ?? '',
      isSale: json['isSale'] ?? false,
      category: json['category'] ?? 'Drinks',
      description: json['description'] ?? '',
      maxPerOrder: json['maxPerOrder'] ?? 12,
      inStock: json['inStock'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'isSale': isSale,
      'category': category,
      'description': description,
      'maxPerOrder': maxPerOrder,
      'inStock': inStock,
    };
  }
}

class DealModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final double originalPrice;
  final String discountTag;
  final String imageUrl;

  DealModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.discountTag,
    required this.imageUrl,
  });

  factory DealModel.fromJson(Map<String, dynamic> json) {
    return DealModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (json['originalPrice'] as num?)?.toDouble() ?? 0.0,
      discountTag: json['discountTag'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'discountTag': discountTag,
      'imageUrl': imageUrl,
    };
  }
}
