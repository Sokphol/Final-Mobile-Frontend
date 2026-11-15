import 'package:flutter/material.dart';

import '../component/app_bottom_navigation.dart';
import '../state/grocery_state.dart';
import 'account_screen.dart';
import 'cart_screen.dart';
import 'explore_screen.dart';
import 'favourite_screen.dart';
import 'home_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectScreen(int index) {
    if (index < 0 || index >= 5 || index == _currentIndex) return;

    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = GroceryScope.of(context);

    final screens = [
      const HomeScreen(),
      const ExploreScreen(),
      CartScreen(onExploreTap: () => _selectScreen(0)),
      FavouriteScreen(onExploreTap: () => _selectScreen(0)),
      const AccountScreen(),
    ];

    return Scaffold(
      body: PageView(
        key: const ValueKey('main-screen-pages'),
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentIndex = index),
        children: screens,
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _currentIndex,
        cartCount: state.cartCount,
        onTap: _selectScreen,
      ),
    );
  }
}
