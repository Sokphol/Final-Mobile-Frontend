import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/responsive_shell.dart';
import '../../core/widgets/sticky_top_navbar.dart';
import '../../core/widgets/storefront_footer.dart';
import '../../features/cart_checkout/cart_drawer.dart';
import '../../state/auth_controller.dart';
import '../../features/catalog/filter_sidebar.dart';
import '../../features/catalog/product_grid.dart';
import '../../features/compare/compare_modal.dart';
import '../../features/product_detail/product_detail_modal.dart';
import '../../features/product_detail/soundstage_tester.dart';
import '../../models/headphone.dart';
import '../../models/mock_catalog.dart';
import '../../screens/about_screen.dart';
import '../../screens/appearance_settings_screen.dart';
import '../../screens/contact_screen.dart';
import '../../screens/order_tracking_screen.dart';
import 'mobile_storefront_view.dart';
import '../../state/cart_controller.dart';
import '../../state/catalog_controller.dart';
import '../../state/orders_controller.dart';
import '../../state/theme_accent_controller.dart';
import 'hero_banner.dart';

class StorefrontPage extends StatefulWidget {
  const StorefrontPage({super.key, this.catalogLoader, this.authController});

  final Future<List<Headphone>> Function()? catalogLoader;
  final AuthController? authController;

  @override
  State<StorefrontPage> createState() => _StorefrontPageState();
}

class _StorefrontPageState extends State<StorefrontPage> {
  static const _accountScopeMigrationKey =
      'sonicflow.storage.accountScopesMigrated';
  static const _orderScopeMigrationKey =
      'sonicflow.storage.orderScopesMigrated';
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();
  late final CatalogController _catalog;
  late final AuthController _auth;
  late final CartController _cart;
  late final OrdersController _orders;
  late final ThemeAccentController _accent;
  late final Future<void> _hydration;
  bool _showBackToTop = false;
  int _selectedMobileTab = 0;

  static const _categories = [
    'All',
    'Over-Ear',
    'ANC Wireless',
    'True Wireless',
    'Studio Open-Back',
    'Gaming',
    'IEMs',
    'DAC/Amps',
  ];

  @override
  void initState() {
    super.initState();
    _catalog = CatalogController(catalogLoader: widget.catalogLoader);
    _auth = widget.authController ?? AuthController();
    _cart = CartController();
    _orders = OrdersController();
    _accent = ThemeAccentController();
    _scrollController.addListener(_onScroll);
    _hydration = _hydrate();
  }

  Future<void> _hydrate() async {
    await _migrateUnscopedAccountData();
    await _auth.hydrate();
    final userId = _auth.userStorageScope;
    await Future.wait([
      _catalog.hydrate(userId: userId),
      _cart.hydrate(userId: userId),
      _orders.hydrate(userId: userId),
      _accent.hydrate(),
    ]);
    _auth.addListener(_onAuthChanged);
  }

  Future<void> _migrateUnscopedAccountData() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(_accountScopeMigrationKey) != true) {
      await preferences.remove(CartController.storageKey);
      await preferences.remove(CatalogController.favoritesStorageKey);
      await preferences.setBool(_accountScopeMigrationKey, true);
    }
    if (preferences.getBool(_orderScopeMigrationKey) != true) {
      await preferences.remove(OrdersController.storageKey);
      await preferences.setBool(_orderScopeMigrationKey, true);
    }
  }

  void _onAuthChanged() {
    unawaited(_reloadUserStorage(_auth.userStorageScope));
  }

  Future<void> _reloadUserStorage(String? userId) async {
    try {
      await Future.wait([
        _catalog.switchFavoriteUserScope(userId),
        _cart.switchUserScope(userId),
        _orders.switchUserScope(userId),
      ]);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not load this account’s saved items: $error',
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _auth.removeListener(_onAuthChanged);
    _catalog.dispose();
    if (widget.authController == null) _auth.dispose();
    _cart.dispose();
    _orders.dispose();
    _accent.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final flagship = _catalog.products.firstWhere(
      (product) => product.id == 'apex-anc-pro',
      orElse: () => flagshipHeadphone,
    );
    return FutureBuilder<void>(
      future: _hydration,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Could not restore saved store data: ${snapshot.error}',
              ),
            ),
          );
        }
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        return ListenableBuilder(
          listenable: _accent,
          builder: (context, _) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: Theme.of(
                context,
              ).colorScheme.copyWith(primary: _accent.accent),
            ),
            child: Scaffold(
              key: _scaffoldKey,
              endDrawer: CartDrawer(cart: _cart, orders: _orders, auth: _auth),
              floatingActionButton: _floatingControls(context),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              body: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    if (constraints.maxWidth < 760) {
                      return _mobileLayout(context);
                    }
                    return Column(
                      children: [
                        StickyTopNavbar(
                          catalog: _catalog,
                          cart: _cart,
                          onCart: () =>
                              _scaffoldKey.currentState?.openEndDrawer(),
                          onCompare: () =>
                              CompareModal.show(context, _catalog, _cart),
                          onOrders: () => _showOrders(context),
                          onSettings: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const AppearanceSettingsScreen(),
                            ),
                          ),
                          onEscape: () {
                            if (_scaffoldKey.currentState?.isEndDrawerOpen ??
                                false) {
                              _scaffoldKey.currentState?.closeEndDrawer();
                            } else if (Navigator.of(context).canPop()) {
                              Navigator.of(context).maybePop();
                            }
                          },
                          accent: _accent,
                          onHome: () {
                            if (_scrollController.hasClients) {
                              _scrollController.animateTo(
                                0,
                                duration: const Duration(milliseconds: 450),
                                curve: Curves.easeOutCubic,
                              );
                            }
                          },
                        ),
                        ResponsiveShell(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(22, 8, 22, 0),
                            child: _categoryBar(),
                          ),
                        ),
                        Expanded(
                          child: CustomScrollView(
                            controller: _scrollController,
                            slivers: [
                              SliverToBoxAdapter(
                                child: ResponsiveShell(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      22,
                                      24,
                                      22,
                                      0,
                                    ),
                                    child: HeroBanner(
                                      cart: _cart,
                                      onInspect: () => _openProduct(flagship),
                                    ),
                                  ),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: ResponsiveShell(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      22,
                                      18,
                                      22,
                                      32,
                                    ),
                                    child: _catalogSection(),
                                  ),
                                ),
                              ),
                              SliverToBoxAdapter(
                                child: ResponsiveShell(
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                      22,
                                      0,
                                      22,
                                      46,
                                    ),
                                    child: _soundstageSection(),
                                  ),
                                ),
                              ),
                              const SliverToBoxAdapter(
                                child: StorefrontFooter(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _mobileLayout(BuildContext context) => Column(
    children: [
      MobileStorefrontHeader(
        catalog: _catalog,
        cart: _cart,
        onCart: () => _scaffoldKey.currentState?.openEndDrawer(),
        onSettings: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => const AppearanceSettingsScreen(),
          ),
        ),
      ),
      Expanded(
        child: IndexedStack(
          index: _selectedMobileTab == 4 ? 3 : _selectedMobileTab,
          children: [
            _mobileHome(context),
            MobileStudioContent(cart: _cart),
            _mobileWishlist(),
            MobileProfileContent(
              cart: _cart,
              savedCount: _catalog.favoriteIds.length,
              onOrders: () => _showOrders(context),
              onAbout: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AboutScreen()),
              ),
              onContact: () => Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const ContactScreen()),
              ),
            ),
          ],
        ),
      ),
      ListenableBuilder(
        listenable: _cart,
        builder: (context, _) => MobileBottomNavigation(
          selectedIndex: _selectedMobileTab,
          cartCount: _cart.itemCount,
          onSelected: _selectMobileTab,
        ),
      ),
    ],
  );

  Widget _mobileHome(BuildContext context) => CustomScrollView(
    key: const PageStorageKey<String>('sonicflow-mobile-discover'),
    slivers: [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 19, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SOUND, WELL FOUND.',
                style: TextStyle(
                  color: AppColors.gold,
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.7,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Hear more.\nCarry less.',
                style: TextStyle(
                  fontSize: 31,
                  height: 1.04,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                'Considered sound for wherever life takes you.',
                style: TextStyle(color: AppColors.muted, fontSize: 10),
              ),
              const SizedBox(height: 14),
              MobileFeaturedCarousel(
                products: _catalog.availableProducts,
                cart: _cart,
                onOpen: _openProduct,
              ),
              const SizedBox(height: 17),
              const Row(
                children: [
                  MobilePerk(
                    icon: Icons.local_shipping_outlined,
                    label: 'Complimentary delivery',
                  ),
                  SizedBox(width: 14),
                  MobilePerk(
                    icon: Icons.verified_user_outlined,
                    label: 'Two-year warranty',
                  ),
                ],
              ),
              const SizedBox(height: 23),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: ListenableBuilder(
            listenable: _catalog,
            builder: (context, _) => MobileSectionHeading(
              eyebrow: 'CURATED FOR YOU',
              title: 'The collection',
              trailing: Text(
                '${_catalog.products.length} pieces',
                style: TextStyle(color: AppColors.muted, fontSize: 9),
              ),
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
        sliver: SliverToBoxAdapter(
          child: ListenableBuilder(
            listenable: _catalog,
            builder: (context, _) => MobileProductGrid(
              products: _catalog.products,
              catalog: _catalog,
              cart: _cart,
              onOpen: _openProduct,
            ),
          ),
        ),
      ),
    ],
  );

  Widget _mobileWishlist() => ListenableBuilder(
    listenable: _catalog,
    builder: (context, _) {
      final saved = _catalog.availableProducts
          .where((product) => _catalog.favoriteIds.contains(product.id))
          .toList(growable: false);
      return SingleChildScrollView(
        key: const PageStorageKey<String>('sonicflow-mobile-saved'),
        padding: const EdgeInsets.fromLTRB(18, 19, 18, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MobileSectionHeading(
              eyebrow: 'COLLECTED BY YOU',
              title: 'Your saved sound',
              trailing: Text(
                '${saved.length} saved',
                style: TextStyle(color: AppColors.muted, fontSize: 9),
              ),
            ),
            const SizedBox(height: 14),
            MobileProductGrid(
              products: saved,
              catalog: _catalog,
              cart: _cart,
              onOpen: _openProduct,
            ),
          ],
        ),
      );
    },
  );

  void _selectMobileTab(int index) {
    if (index == 3) {
      _scaffoldKey.currentState?.openEndDrawer();
      return;
    }
    setState(() => _selectedMobileTab = index);
  }

  void _onScroll() {
    final show = _scrollController.hasClients && _scrollController.offset > 500;
    if (show != _showBackToTop && mounted) {
      setState(() => _showBackToTop = show);
    }
  }

  Widget _floatingControls(BuildContext context) => ListenableBuilder(
    listenable: _catalog,
    builder: (context, _) => Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSlide(
          offset: _catalog.comparedIds.isEmpty
              ? const Offset(0, 1.2)
              : Offset.zero,
          duration: const Duration(milliseconds: 220),
          child: AnimatedOpacity(
            opacity: _catalog.comparedIds.isEmpty ? 0 : 1,
            duration: const Duration(milliseconds: 180),
            child: Container(
              key: const ValueKey('compare-dock'),
              constraints: const BoxConstraints(maxWidth: 560),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 20),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final product in _catalog.comparedProducts.take(3))
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CircleAvatar(
                        radius: 17,
                        backgroundColor: AppColors.surface,
                        child: Text(
                          product.name.isNotEmpty ? product.name[0] : '',
                          style: const TextStyle(fontSize: 11),
                        ),
                      ),
                    ),
                  TextButton(
                    onPressed: () async {
                      for (final product in _catalog.comparedProducts) {
                        await _catalog.toggleCompare(product);
                      }
                    },
                    child: const Text('Clear'),
                  ),
                  ElevatedButton(
                    onPressed: _catalog.comparedIds.isEmpty
                        ? null
                        : () => CompareModal.show(context, _catalog, _cart),
                    child: Text(
                      'Compare Now (${_catalog.comparedIds.length}/3)',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (_showBackToTop) ...[
          const SizedBox(height: 8),
          FloatingActionButton.small(
            tooltip: 'Back to top',
            onPressed: () => _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOutCubic,
            ),
            child: const Icon(Icons.arrow_upward),
          ),
        ],
      ],
    ),
  );

  void _showOrders(BuildContext context) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Your orders'),
      content: SizedBox(
        width: 480,
        child: ListenableBuilder(
          listenable: _orders,
          builder: (context, _) => _orders.orders.isEmpty
              ? const Text('No orders yet.')
              : ListView(
                  shrinkWrap: true,
                  children: [
                    for (final order in _orders.orders)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('#${order.id}'),
                              Text(
                                order.deliveryStatus,
                                style: TextStyle(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              for (final line in order.lines)
                                Text('${line.quantity} × ${line.productName}'),
                              Text('\$${order.total.toStringAsFixed(2)}'),
                              Text(
                                'Estimated delivery: ${_formatOrderDate(order.estimatedDelivery)}',
                                style: TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 11,
                                ),
                              ),
                              Wrap(
                                children: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            OrderTrackingScreen(order: order),
                                      ),
                                    ),
                                    child: const Text('Track delivery'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      for (final line in order.lines) {
                                        final product = allStoreProducts
                                            .firstWhere(
                                              (candidate) =>
                                                  candidate.id == line.productId,
                                            );
                                        final variant = product.colors
                                            .firstWhere(
                                              (candidate) =>
                                                  candidate.name == line.variant,
                                            );
                                        await _cart.add(
                                          product,
                                          variant,
                                          quantity: line.quantity,
                                        );
                                      }
                                      if (context.mounted) {
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text('Buy Again'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    ),
  );

  String _formatOrderDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  Widget _categoryBar() => ListenableBuilder(
    listenable: _catalog,
    builder: (context, _) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final category in _categories)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(category),
                selected: _catalog.category == category,
                onSelected: (_) => _catalog.setCategory(category),
                selectedColor: AppColors.orange,
                side: BorderSide(
                  color: _catalog.category == category
                      ? AppColors.orange
                      : AppColors.border,
                ),
                labelStyle: TextStyle(
                  color: _catalog.category == category
                      ? AppColors.onAccent
                      : AppColors.muted,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    ),
  );

  Widget _catalogSection() => LayoutBuilder(
    builder: (context, constraints) {
      final desktop = ResponsiveShell.isDesktop(constraints.maxWidth);
      final filters = FilterSidebar(controller: _catalog);
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (desktop) SizedBox(width: 258, child: filters),
          if (desktop) const SizedBox(width: 20),
          Expanded(
            child: ProductGrid(
              catalog: _catalog,
              cart: _cart,
              onOpen: _openProduct,
              onOpenFilters: () => _openFilters(filters),
              showFilterButton: !desktop,
            ),
          ),
        ],
      );
    },
  );

  Widget _soundstageSection() => LayoutBuilder(
    builder: (context, constraints) {
      final narrow = constraints.maxWidth < 720;
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
        ),
        child: narrow
            ? const SoundstageTester()
            : Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LISTEN BEYOND THE SPECS',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'A little more space\nfor the sound.',
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Explore spatial character and hear how active noise cancellation changes the room around your music.',
                          style: TextStyle(
                            color: AppColors.muted,
                            height: 1.6,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  const Expanded(child: SoundstageTester()),
                ],
              ),
      );
    },
  );

  void _openProduct(Headphone product) =>
      ProductDetailModal.show(context, product, _cart, catalog: _catalog);

  void _openFilters(Widget filters) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'LISTENING FILTERS',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: filters,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Show matching headphones'),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
