import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/headphone.dart';

const _configuredApiBaseUrl = String.fromEnvironment('API_BASE_URL');

String get apiBaseUrl {
  if (_configuredApiBaseUrl.isNotEmpty) {
    return _configuredApiBaseUrl.replaceFirst(RegExp(r'/$'), '');
  }
  if (kIsWeb) return '${Uri.base.scheme}://${Uri.base.host}:5000/api/v1';
  if (defaultTargetPlatform == TargetPlatform.android) {
    return 'http://10.0.2.2:5000/api/v1';
  }
  return 'http://127.0.0.1:5000/api/v1';
}

Future<List<Headphone>> fetchCatalog() async {
  final uri = Uri.parse('$apiBaseUrl/products/?per_page=100&sort=popular');
  final response = await http
      .get(uri, headers: const {'Accept': 'application/json'})
      .timeout(const Duration(seconds: 15));
  if (response.statusCode != 200) {
    throw Exception(
      'Catalog request failed (${response.statusCode}): ${response.body}',
    );
  }

  final body = jsonDecode(response.body) as Map<String, dynamic>;
  if (body['success'] != true) {
    throw FormatException('Catalog request was rejected: ${body['message']}');
  }
  final data = body['data'] as Map<String, dynamic>;
  final items = data['items'] as List<dynamic>;
  return items
      .map((item) => _headphoneFromJson(item as Map<String, dynamic>))
      .toList(growable: false);
}

Headphone _headphoneFromJson(Map<String, dynamic> product) {
  final category = product['category'] as Map<String, dynamic>?;
  final brand = product['brand'] as Map<String, dynamic>?;
  final variants = (product['variants'] as List<dynamic>? ?? const [])
      .cast<Map<String, dynamic>>();
  final colors = variants
      .map(
        (variant) => ColorVariant(
          name: variant['color_name'] as String? ?? 'Default',
          color: _colorFromHex(variant['color_hex'] as String?),
        ),
      )
      .toList(growable: false);
  final images = (product['images'] as List<dynamic>? ?? const [])
      .cast<Map<String, dynamic>>();
  final imageUrl =
      product['primary_image'] as String? ??
      (images.isEmpty
          ? 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?auto=format&fit=crop&w=1200&q=85'
          : images.first['image_url'] as String);
  final originalPrice = (product['price'] as num).toDouble();
  final salePrice = (product['sale_price'] as num?)?.toDouble();
  final effectivePrice =
      (product['effective_price'] as num?)?.toDouble() ??
      salePrice ??
      originalPrice;
  final rating = (product['average_rating'] as num?)?.toDouble() ?? 0;
  final connectivity = product['connectivity'] as String? ?? '';
  final batteryLife = product['battery_life'] as String? ?? '';
  final batteryHours =
      int.tryParse(RegExp(r'\d+').firstMatch(batteryLife)?.group(0) ?? '') ?? 0;
  final specs = <AcousticSpec>[
    if (product['driver_size'] case final String value)
      AcousticSpec('Driver Type', value),
    if (product['frequency_response'] case final String value)
      AcousticSpec('Frequency Response', value),
    if (product['impedance'] case final String value)
      AcousticSpec('Impedance', value),
    if (product['weight'] case final num value)
      AcousticSpec('Weight', '${value.toStringAsFixed(0)}g'),
    if (batteryLife.isNotEmpty) AcousticSpec('Battery Life', batteryLife),
    if (connectivity.isNotEmpty)
      AcousticSpec('Bluetooth Codec', connectivity),
  ];

  return Headphone(
    id: product['slug'] as String,
    name: product['name'] as String,
    brand: brand?['name'] as String? ?? 'SonicFlow',
    tagline: product['short_description'] as String? ?? '',
    description: product['description'] as String? ?? '',
    price: effectivePrice,
    originalPrice: salePrice != null && salePrice < originalPrice
        ? originalPrice
        : null,
    rating: rating > 0 ? rating : 4.5,
    reviewCount: product['review_count'] as int? ?? 0,
    isBestSeller: product['is_featured'] as bool? ?? false,
    isNewArrival: false,
    category: category?['name'] as String? ?? 'Over-Ear',
    hasANC: product['noise_cancellation'] as bool? ?? false,
    isWireless: RegExp(
      r'bluetooth|wireless|2\.4ghz',
      caseSensitive: false,
    ).hasMatch(connectivity),
    batteryLifeHours: batteryHours,
    imageUrl: imageUrl,
    galleryUrls: images
        .map((image) => image['image_url'] as String)
        .toList(growable: false),
    colors: colors.isEmpty
        ? const [ColorVariant(name: 'Default', color: Colors.black)]
        : colors,
    specs: specs,
    frequencyProfile: const [0.6, 0.65, 0.6, 0.65, 0.6],
    reviews: const [],
  );
}

Color _colorFromHex(String? hex) {
  if (hex == null) return Colors.black;
  final normalized = hex.replaceFirst('#', '');
  final value = int.tryParse(normalized, radix: 16);
  if (value == null) return Colors.black;
  return Color(normalized.length == 6 ? 0xFF000000 | value : value);
}
