import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/mock_catalog.dart';
import '../../state/cart_controller.dart';
import '../../state/catalog_controller.dart';
import '../../state/theme_accent_controller.dart';
import '../theme/app_colors.dart';

class StickyTopNavbar extends StatefulWidget {
  const StickyTopNavbar({
    required this.catalog,
    required this.cart,
    required this.onCart,
    required this.onCompare,
    required this.onHome,
    required this.onOrders,
    required this.onSettings,
    required this.onEscape,
    required this.accent,
    super.key,
  });

  final CatalogController catalog;
  final CartController cart;
  final VoidCallback onCart;
  final VoidCallback onCompare;
  final VoidCallback onHome;
  final VoidCallback onOrders;
  final VoidCallback onSettings;
  final VoidCallback onEscape;
  final ThemeAccentController accent;

  @override
  State<StickyTopNavbar> createState() => _StickyTopNavbarState();
}

class _StickyTopNavbarState extends State<StickyTopNavbar> {
  late final TextEditingController _search;
  late final FocusNode _searchFocus;
  bool _showRecent = false;
  static const categories = [
    'Over-Ear',
    'True Wireless',
    'Studio Open-Back',
    'Gaming',
  ];

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.catalog.query);
    _searchFocus = FocusNode();
  }

  @override
  void dispose() {
    _search.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Focus(
    autofocus: true,
    onKeyEvent: (node, event) {
      if (event is! KeyDownEvent) return KeyEventResult.ignored;
      final focusContext = FocusManager.instance.primaryFocus?.context;
      final editing = focusContext?.widget is EditableText;
      if (event.logicalKey == LogicalKeyboardKey.escape) {
        widget.onEscape();
        return KeyEventResult.handled;
      }
      if (!editing &&
          (event.logicalKey == LogicalKeyboardKey.slash ||
              (event.logicalKey == LogicalKeyboardKey.keyK &&
                  (HardwareKeyboard.instance.isControlPressed ||
                      HardwareKeyboard.instance.isMetaPressed)))) {
        _searchFocus.requestFocus();
        setState(() => _showRecent = true);
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    },
    child: Material(
      color: AppColors.background.withValues(alpha: 0.97),
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.border)),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: constraintsForPadding(context),
          vertical: 10,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 400) {
                  return _compactMobileNavbar(context);
                }
                final compact = constraints.maxWidth < 1180;
                final mobile = constraints.maxWidth < 650;
                return Row(
                  children: [
                    InkWell(
                      onTap: () {
                        _search.clear();
                        widget.catalog.reset();
                        widget.onHome();
                      },
                      child: const Text(
                        'SONICFLOW',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 19,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(width: 28),
                      for (final category in categories)
                        ListenableBuilder(
                          listenable: widget.catalog,
                          builder: (context, _) => TextButton(
                            onPressed: () =>
                                widget.catalog.setCategory(category),
                            child: Text(
                              category,
                              style: TextStyle(
                                color: widget.catalog.category == category
                                    ? AppColors.orange
                                    : AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(width: 10),
                    ] else
                      const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 42,
                        child: TextField(
                          focusNode: _searchFocus,
                          controller: _search,
                          onChanged: widget.catalog.setQuery,
                          onTap: () => setState(() => _showRecent = true),
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.search, size: 19),
                            hintText: 'Search sound, model, specs...',
                            contentPadding: EdgeInsets.zero,
                            suffixIcon: _search.text.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear search',
                                    icon: const Icon(Icons.close, size: 18),
                                    onPressed: () {
                                      _search.clear();
                                      widget.catalog.setQuery('');
                                    },
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      tooltip: 'Theme accent',
                      onPressed: () => _toggleAccent(),
                      icon: Icon(
                        Icons.palette_outlined,
                        color: widget.accent.accent,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Appearance settings',
                      onPressed: widget.onSettings,
                      icon: const Icon(Icons.tune_rounded),
                    ),
                    IconButton(
                      tooltip: 'Orders',
                      onPressed: widget.onOrders,
                      icon: const Icon(Icons.receipt_long_outlined),
                    ),
                    ListenableBuilder(
                      listenable: widget.catalog,
                      builder: (context, _) => IconButton(
                        tooltip:
                            'Wishlist ${widget.catalog.favoriteIds.length}',
                        onPressed: () => _showFavorites(context),
                        icon: Badge(
                          label: Text('${widget.catalog.favoriteIds.length}'),
                          isLabelVisible: widget.catalog.favoriteIds.isNotEmpty,
                          child: const Icon(Icons.favorite_border),
                        ),
                      ),
                    ),
                    ListenableBuilder(
                      listenable: widget.catalog,
                      builder: (context, _) => mobile
                          ? IconButton(
                              tooltip:
                                  'Compare ${widget.catalog.comparedIds.length} of 3',
                              onPressed: widget.onCompare,
                              icon: Badge(
                                label: Text(
                                  '${widget.catalog.comparedIds.length}',
                                ),
                                isLabelVisible:
                                    widget.catalog.comparedIds.isNotEmpty,
                                child: const Icon(Icons.compare_arrows),
                              ),
                            )
                          : TextButton.icon(
                              onPressed: widget.onCompare,
                              icon: const Icon(Icons.compare_arrows, size: 18),
                              label: Text(
                                '${widget.catalog.comparedIds.length}/3',
                              ),
                            ),
                    ),
                    ListenableBuilder(
                      listenable: widget.cart,
                      builder: (context, _) => IconButton(
                        tooltip: 'Open cart',
                        onPressed: widget.onCart,
                        icon: Badge(
                          label: Text('${widget.cart.itemCount}'),
                          isLabelVisible: widget.cart.itemCount > 0,
                          child: const Icon(Icons.shopping_bag_outlined),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            if (_showRecent && widget.catalog.recentSearches.isNotEmpty)
              _recentSearches(context),
          ],
        ),
      ),
    ),
  );

  double constraintsForPadding(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 650 ? 10 : 24;

  Widget _compactMobileNavbar(BuildContext context) => Column(
    children: [
      Row(
        children: [
          InkWell(
            onTap: () {
              _search.clear();
              widget.catalog.reset();
              widget.onHome();
            },
            child: const Text(
              'SONICFLOW',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 19,
                letterSpacing: 1.5,
              ),
            ),
          ),
          const Spacer(),
          ListenableBuilder(
            listenable: widget.cart,
            builder: (context, _) => IconButton(
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              padding: EdgeInsets.zero,
              tooltip: 'Open cart',
              onPressed: widget.onCart,
              icon: Badge(
                label: Text('${widget.cart.itemCount}'),
                isLabelVisible: widget.cart.itemCount > 0,
                child: const Icon(Icons.shopping_bag_outlined),
              ),
            ),
          ),
          IconButton(
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
            padding: EdgeInsets.zero,
            tooltip: 'Appearance settings',
            onPressed: widget.onSettings,
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      const SizedBox(height: 6),
      Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 42,
              child: TextField(
                focusNode: _searchFocus,
                controller: _search,
                onChanged: widget.catalog.setQuery,
                onTap: () => setState(() => _showRecent = true),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, size: 19),
                  hintText: 'Search sound, model, specs...',
                  contentPadding: EdgeInsets.zero,
                  suffixIcon: _search.text.isEmpty
                      ? null
                      : IconButton(
                          tooltip: 'Clear search',
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _search.clear();
                            widget.catalog.setQuery('');
                          },
                        ),
                ),
              ),
            ),
          ),
          IconButton(
            constraints: const BoxConstraints.tightFor(width: 40, height: 40),
            padding: EdgeInsets.zero,
            tooltip: 'Theme accent',
            onPressed: _toggleAccent,
            icon: Icon(Icons.palette_outlined, color: widget.accent.accent),
          ),
          ListenableBuilder(
            listenable: widget.catalog,
            builder: (context, _) => IconButton(
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              padding: EdgeInsets.zero,
              tooltip: 'Wishlist ${widget.catalog.favoriteIds.length}',
              onPressed: () => _showFavorites(context),
              icon: Badge(
                label: Text('${widget.catalog.favoriteIds.length}'),
                isLabelVisible: widget.catalog.favoriteIds.isNotEmpty,
                child: const Icon(Icons.favorite_border),
              ),
            ),
          ),
          ListenableBuilder(
            listenable: widget.catalog,
            builder: (context, _) => IconButton(
              constraints: const BoxConstraints.tightFor(width: 40, height: 40),
              padding: EdgeInsets.zero,
              tooltip: 'Compare ${widget.catalog.comparedIds.length} of 3',
              onPressed: widget.onCompare,
              icon: Badge(
                label: Text('${widget.catalog.comparedIds.length}'),
                isLabelVisible: widget.catalog.comparedIds.isNotEmpty,
                child: const Icon(Icons.compare_arrows),
              ),
            ),
          ),
        ],
      ),
      if (_showRecent && widget.catalog.recentSearches.isNotEmpty)
        _recentSearches(context),
    ],
  );

  Widget _recentSearches(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Material(
      color: AppColors.elevated,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Recent searches',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await widget.catalog.clearRecentSearches();
                    if (mounted) setState(() => _showRecent = false);
                  },
                  child: const Text('Clear History'),
                ),
              ],
            ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final search in widget.catalog.recentSearches)
                  InputChip(
                    label: Text(search),
                    onPressed: () {
                      _search.text = search;
                      widget.catalog.setQuery(search);
                      setState(() => _showRecent = false);
                    },
                    onDeleted: () async {
                      await widget.catalog.removeRecentSearch(search);
                      if (mounted) setState(() {});
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

  void _toggleAccent() => widget.accent.select(
    widget.accent.accent == ThemeAccentController.orange
        ? ThemeAccentController.champagne
        : ThemeAccentController.orange,
  );

  void _showFavorites(BuildContext context) {
    final favorites = allStoreProducts
        .where((product) => widget.catalog.favoriteIds.contains(product.id))
        .toList();
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your listening list'),
        content: SizedBox(
          width: 360,
          child: favorites.isEmpty
              ? const Text(
                  'Save a headphone with the heart button to keep it here.',
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: favorites
                      .map(
                        (item) => ListTile(
                          title: Text(item.name),
                          subtitle: Text(item.brand),
                          trailing: Text('\$${item.price.toStringAsFixed(0)}'),
                        ),
                      )
                      .toList(),
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
