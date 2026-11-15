import 'package:flutter/material.dart';

import '../component/app_colors.dart';
import 'appearance_settings_screen.dart';
import 'login_screen.dart';
import 'orders_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String _userName = 'John Doe';
  String _userEmail = 'john@gmail.com';
  bool _notificationsEnabled = true;

  void _editProfile() {
    final nameCtrl = TextEditingController(text: _userName);
    final emailCtrl = TextEditingController(text: _userEmail);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              decoration: const InputDecoration(labelText: 'Full Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: const InputDecoration(labelText: 'Email Address'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.green),
            onPressed: () {
              setState(() {
                _userName = nameCtrl.text.trim();
                _userEmail = emailCtrl.text.trim();
              });
              Navigator.of(ctx).pop();
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showPromoCards() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Available Promo Vouchers',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _promoTile('FRESH10', '10% discount on entire grocery basket'),
              const SizedBox(height: 10),
              _promoTile('ORGANIC5', '\$5 off on orders above \$30'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _promoTile(String code, String desc) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.green.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.green.withValues(alpha: 0.3)),
    ),
    child: Row(
      children: [
        const Icon(Icons.local_offer_outlined, color: AppColors.green),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                code,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.green,
                ),
              ),
              Text(
                desc,
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  void _confirmLogout() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text(
          'Are you sure you want to log out of your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            child: const Text('Log Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Profile Header
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.green.withValues(alpha: 0.15),
                child: const Icon(
                  Icons.person,
                  size: 36,
                  color: AppColors.green,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _userName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.dark,
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: _editProfile,
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: AppColors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _userEmail,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: AppColors.border),

          // Menu Options
          _accountTile(
            icon: Icons.shopping_bag_outlined,
            title: 'Orders',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const OrdersScreen()),
            ),
          ),
          _accountTile(
            icon: Icons.person_outline,
            title: 'My Details',
            onTap: _editProfile,
          ),
          _accountTile(
            icon: Icons.location_on_outlined,
            title: 'Delivery Address',
            subtitle: 'St. 214, Phnom Penh',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Address can also be changed directly during checkout.',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          _accountTile(
            icon: Icons.credit_card_outlined,
            title: 'Payment Methods',
            subtitle: 'ABA Pay / KHQR',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Payment preferences updated.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          _accountTile(
            icon: Icons.confirmation_number_outlined,
            title: 'Promo Card',
            onTap: _showPromoCards,
          ),
          _accountTile(
            icon: Icons.tune_rounded,
            title: 'Appearance & Typography',
            subtitle: 'Theme and font preferences',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AppearanceSettingsScreen(),
              ),
            ),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(
              Icons.notifications_none_outlined,
              color: AppColors.dark,
            ),
            title: const Text(
              'Notifications',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            trailing: Switch(
              value: _notificationsEnabled,
              activeTrackColor: AppColors.green,
              onChanged: (val) => setState(() => _notificationsEnabled = val),
            ),
          ),
          const Divider(color: AppColors.border),
          _accountTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Help & FAQ'),
                  content: const Text(
                    'Need assistance with your grocery order?\n\n'
                    '• Contact hotline: +855 12 345 678\n'
                    '• Support email: support@sonicflowgrocery.com\n'
                    '• Operating hours: 7:00 AM – 10:00 PM everyday',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
          _accountTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'v1.0.0 (Build 2026)',
            onTap: () {},
          ),
          const SizedBox(height: 24),

          // Log Out Button
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2F3F2),
                foregroundColor: AppColors.green,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _confirmLogout,
              icon: const Icon(Icons.logout, color: AppColors.green),
              label: const Text(
                'Log Out',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );

  Widget _accountTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) => Column(
    children: [
      ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(icon, color: AppColors.dark),
        title: Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
              )
            : null,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppColors.dark,
        ),
        onTap: onTap,
      ),
      const Divider(color: AppColors.border, height: 1),
    ],
  );
}
