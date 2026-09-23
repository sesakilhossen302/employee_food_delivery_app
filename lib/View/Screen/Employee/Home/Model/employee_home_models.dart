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

  static String sanitizeEmoji(String name, String? raw) {
    if (raw != null && raw.trim().isNotEmpty) {
      final s = raw.trim();
      if (!s.contains('ð') && !s.contains('â') && !s.contains('ï') && !s.contains('') && s.length <= 4) {
        return s;
      }
    }
    final lower = name.toLowerCase();
    if (lower.contains('drink') || lower.contains('pop') || lower.contains('beverage')) return '🥤';
    if (lower.contains('energy')) return '⚡';
    if (lower.contains('snack') || lower.contains('chip')) return '🍿';
    if (lower.contains('candy') || lower.contains('chocolate')) return '🍫';
    if (lower.contains('ice cream')) return '🍦';
    if (lower.contains('auto') || lower.contains('fluid')) return '🚗';
    if (lower.contains('cooler') || lower.contains('ice')) return '🧊';
    if (lower.contains('firewood') || lower.contains('camp')) return '🪵';
    if (lower.contains('grocery') || lower.contains('essential')) return '🛒';
    if (lower.contains('special') || lower.contains('season')) return '🔥';
    return '🛍️';
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final catName = json['name']?.toString() ?? '';
    return CategoryModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: catName,
      iconEmoji: sanitizeEmoji(catName, json['iconEmoji']?.toString()),
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
    final priceVal = (json['price'] as num?)?.toDouble() ?? 0.0;
    final saleVal = (json['salePrice'] as num?)?.toDouble() ?? (json['originalPrice'] as num?)?.toDouble();
    return ProductModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      unit: json['unit'] ?? '1 pc',
      price: priceVal,
      originalPrice: saleVal,
      imageUrl: json['imageUrl']?.toString().isNotEmpty == true
          ? json['imageUrl']
          : 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=400',
      isSale: json['isSale'] == true || (saleVal != null && saleVal > priceVal),
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
