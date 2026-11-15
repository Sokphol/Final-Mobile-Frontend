import 'package:flutter/material.dart';

class ColorVariant {
  const ColorVariant({required this.name, required this.color});

  final String name;
  final Color color;
}

class AcousticSpec {
  const AcousticSpec(this.label, this.value);

  final String label;
  final String value;
}

class Review {
  const Review({
    required this.name,
    required this.title,
    required this.body,
    required this.rating,
    required this.date,
  });

  final String name;
  final String title;
  final String body;
  final int rating;
  final String date;
}

class Headphone {
  const Headphone({
    required this.id,
    required this.name,
    required this.brand,
    required this.tagline,
    required this.description,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviewCount,
    required this.isBestSeller,
    required this.isNewArrival,
    required this.category,
    required this.hasANC,
    required this.isWireless,
    required this.batteryLifeHours,
    required this.imageUrl,
    required this.galleryUrls,
    required this.colors,
    required this.specs,
    required this.frequencyProfile,
    required this.reviews,
  });

  final String id;
  final String name;
  final String brand;
  final String tagline;
  final String description;
  final double price;
  final double? originalPrice;
  final double rating;
  final int reviewCount;
  final bool isBestSeller;
  final bool isNewArrival;
  final String category;
  final bool hasANC;
  final bool isWireless;
  final int batteryLifeHours;
  final String imageUrl;
  final List<String> galleryUrls;
  final List<ColorVariant> colors;
  final List<AcousticSpec> specs;
  final List<double> frequencyProfile;
  final List<Review> reviews;

  int? get discountPercent => originalPrice == null
      ? null
      : (((originalPrice! - price) / originalPrice!) * 100).round();

  String specValue(String label) => specs
      .firstWhere(
        (spec) => spec.label == label,
        orElse: () => const AcousticSpec('', '—'),
      )
      .value;
}
