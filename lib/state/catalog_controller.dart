import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/headphone.dart';
import '../models/mock_catalog.dart';

class CatalogController extends ChangeNotifier {
  CatalogController({this.catalogLoader});

  final Future<List<Headphone>> Function()? catalogLoader;

  static const favoritesStorageKey = 'sonicflow.wishlist';
  static const compareStorageKey = 'sonicflow.compare';
  static const searchesStorageKey = 'sonicflow.recentSearches';
  static const reviewsStorageKey = 'sonicflow.reviews';

  String query = '';
  String category = 'All';
  bool ancOnly = false;
  bool wirelessOnly = false;
  RangeValues priceRange = const RangeValues(100, 1000);
  String sorting = 'Featured';
  String? _favoriteUserScope;
  int _favoriteScopeLoadGeneration = 0;
  final Set<String> comparedIds = {};
  final Set<String> favoriteIds = {};
  final List<String> recentSearches = [];
  final Map<String, List<Review>> customReviews = {};
  List<Headphone> _availableProducts = mockCatalog;

  List<Headphone> get availableProducts => _availableProducts;

  List<Headphone> get products {
    final normalized = query.trim().toLowerCase();
    final matches = _availableProducts.where((product) {
      final searchable = <String>[
        product.name,
        product.brand,
        product.tagline,
        product.category,
        ...product.specs.map((spec) => '${spec.label} ${spec.value}'),
      ].join(' ').toLowerCase();
      final matchesCategory =
          category == 'All' ||
          product.category == category ||
          (category == 'ANC Wireless' && product.isWireless && product.hasANC);
      return matchesCategory &&
          (!ancOnly || product.hasANC) &&
          (!wirelessOnly || product.isWireless) &&
          product.price >= priceRange.start &&
          product.price <= priceRange.end &&
          (normalized.isEmpty || searchable.contains(normalized));
    }).toList();
    switch (sorting) {
      case 'Price: Low to High':
        matches.sort((a, b) => a.price.compareTo(b.price));
      case 'Price: High to Low':
        matches.sort((a, b) => b.price.compareTo(a.price));
      case 'Top Rated':
        matches.sort((a, b) => b.rating.compareTo(a.rating));
      default:
        matches.sort(
          (a, b) => (b.isBestSeller ? 1 : 0).compareTo(a.isBestSeller ? 1 : 0),
        );
    }
    return matches;
  }

  int get activeFilterCount =>
      (category != 'All' ? 1 : 0) +
      (ancOnly ? 1 : 0) +
      (wirelessOnly ? 1 : 0) +
      (priceRange.start > 100 || priceRange.end < 1000 ? 1 : 0) +
      (query.isNotEmpty ? 1 : 0);

  List<Headphone> get comparedProducts => _availableProducts
      .where((product) => comparedIds.contains(product.id))
      .toList(growable: false);

  Future<void> hydrate({String? userId}) async {
    _favoriteUserScope = userId;
    final favoriteGeneration = ++_favoriteScopeLoadGeneration;
    final loadCatalog = catalogLoader;
    if (loadCatalog != null) {
      _availableProducts = await loadCatalog();
      setApiCatalog(_availableProducts);
    }

    final preferences = await SharedPreferences.getInstance();
    if (_favoriteScopeLoadGeneration != favoriteGeneration) return;
    final favorites = preferences.getString(_favoritesKeyFor(userId));
    final compares = preferences.getString(compareStorageKey);
    final searches = preferences.getString(searchesStorageKey);
    final reviews = preferences.getString(reviewsStorageKey);
    if (favorites != null) {
      favoriteIds
        ..clear()
        ..addAll(
          (jsonDecode(favorites) as List<dynamic>).cast<String>().where(
            (id) => allStoreProducts.any((product) => product.id == id),
          ),
        );
    }
    if (compares != null) {
      comparedIds
        ..clear()
        ..addAll(
          (jsonDecode(compares) as List<dynamic>)
              .cast<String>()
              .where((id) => allStoreProducts.any((product) => product.id == id))
              .take(3),
        );
    }
    if (searches != null) {
      recentSearches
        ..clear()
        ..addAll(
          (jsonDecode(searches) as List<dynamic>).cast<String>().take(8),
        );
    }
    if (reviews != null) {
      final decoded = jsonDecode(reviews) as Map<String, dynamic>;
      customReviews
        ..clear()
        ..addAll({
          for (final entry in decoded.entries)
            entry.key: (entry.value as List<dynamic>)
                .map((value) => _reviewFromJson(value as Map<String, dynamic>))
                .toList(),
        });
    }
    notifyListeners();
  }

  Future<void> switchFavoriteUserScope(String? userId) async {
    if (_favoriteUserScope == userId) return;
    _favoriteUserScope = userId;
    final generation = ++_favoriteScopeLoadGeneration;
    favoriteIds.clear();
    notifyListeners();

    final preferences = await SharedPreferences.getInstance();
    if (_favoriteScopeLoadGeneration != generation) return;
    final favorites = preferences.getString(_favoritesKeyFor(userId));
    if (favorites != null) {
      favoriteIds.addAll(
        (jsonDecode(favorites) as List<dynamic>).cast<String>().where(
          (id) => allStoreProducts.any((product) => product.id == id),
        ),
      );
    }
    notifyListeners();
  }

  String _favoritesKeyFor(String? userId) => userId == null
      ? favoritesStorageKey
      : '$favoritesStorageKey.user.${Uri.encodeComponent(userId)}';

  Future<void> setQuery(String value) async {
    query = value;
    notifyListeners();
    final normalized = value.trim();
    if (normalized.isEmpty) return;
    recentSearches
      ..remove(normalized)
      ..insert(0, normalized);
    if (recentSearches.length > 8) recentSearches.removeLast();
    await _persistSearches();
  }

  Future<void> removeRecentSearch(String search) async {
    recentSearches.remove(search);
    notifyListeners();
    await _persistSearches();
  }

  Future<void> clearRecentSearches() async {
    recentSearches.clear();
    notifyListeners();
    await _persistSearches();
  }

  void setCategory(String value) {
    category = value;
    notifyListeners();
  }

  void setAnc(bool value) {
    ancOnly = value;
    notifyListeners();
  }

  void setWireless(bool value) {
    wirelessOnly = value;
    notifyListeners();
  }

  void setPriceRange(RangeValues value) {
    priceRange = value;
    notifyListeners();
  }

  void setSorting(String value) {
    sorting = value;
    notifyListeners();
  }

  Future<bool> toggleCompare(Headphone product) async {
    if (comparedIds.remove(product.id)) {
      notifyListeners();
      await _persistCompare();
      return false;
    }
    if (comparedIds.length == 3) return false;
    comparedIds.add(product.id);
    notifyListeners();
    await _persistCompare();
    return true;
  }

  Future<void> toggleFavorite(Headphone product) async {
    if (!favoriteIds.add(product.id)) favoriteIds.remove(product.id);
    final storageKey = _favoritesKeyFor(_favoriteUserScope);
    final encoded = jsonEncode(favoriteIds.toList());
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(storageKey, encoded);
  }

  List<Review> reviewsFor(Headphone product) => [
    ...product.reviews,
    ...?customReviews[product.id],
  ];

  double ratingFor(Headphone product) {
    final reviews = reviewsFor(product);
    if (reviews.isEmpty) return product.rating;
    return reviews.fold<int>(0, (sum, review) => sum + review.rating) /
        reviews.length;
  }

  Future<void> addReview(
    Headphone product, {
    required String name,
    required String title,
    required String body,
    required int rating,
  }) async {
    if (rating < 1 ||
        rating > 5 ||
        body.trim().isEmpty ||
        title.trim().isEmpty) {
      throw ArgumentError(
        'Review requires a title, body, and rating from 1 to 5.',
      );
    }
    final review = Review(
      name: name.trim().isEmpty ? 'Guest' : name.trim(),
      title: title.trim(),
      body: body.trim(),
      rating: rating,
      date: _reviewDate(),
    );
    customReviews.putIfAbsent(product.id, () => []).insert(0, review);
    notifyListeners();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      reviewsStorageKey,
      jsonEncode({
        for (final entry in customReviews.entries)
          entry.key: entry.value.map(_reviewToJson).toList(),
      }),
    );
  }

  Future<void> _persistCompare() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      compareStorageKey,
      jsonEncode(comparedIds.toList()),
    );
  }

  Future<void> _persistSearches() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(searchesStorageKey, jsonEncode(recentSearches));
  }

  static Map<String, Object> _reviewToJson(Review review) => {
    'name': review.name,
    'title': review.title,
    'body': review.body,
    'rating': review.rating,
    'date': review.date,
  };

  static Review _reviewFromJson(Map<String, dynamic> json) => Review(
    name: json['name'] as String,
    title: json['title'] as String,
    body: json['body'] as String,
    rating: json['rating'] as int,
    date: json['date'] as String,
  );

  static String _reviewDate() {
    final now = DateTime.now();
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[now.month - 1]} ${now.year}';
  }

  void reset() {
    query = '';
    category = 'All';
    ancOnly = false;
    wirelessOnly = false;
    priceRange = const RangeValues(100, 1000);
    sorting = 'Featured';
    notifyListeners();
  }
}
