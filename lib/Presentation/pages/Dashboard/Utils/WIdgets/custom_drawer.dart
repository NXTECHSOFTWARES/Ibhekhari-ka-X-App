import 'package:flutter/material.dart';
import 'package:nxbakers/Presentation/ViewModels/pastry_viewmodel.dart';
import 'package:nxbakers/Presentation/pages/Notifications/notifications.dart';
import 'package:nxbakers/Presentation/pages/Pastries/low_stock_details_page.dart';
import 'package:nxbakers/Presentation/pages/Pastries/pastries.dart';
import 'package:nxbakers/Presentation/pages/Settings/notification_settings_page.dart';
import 'package:provider/provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header Section
          _buildHeader(context),

          // Navigation Items
          _buildNavigationItems(context),

          // Divider
          const Divider(height: 1, thickness: 1),

          // Footer Section
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.deepPurple.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App Icon/Logo
          CircleAvatar(
            backgroundColor: Colors.deepPurple.shade100,
            radius: 30,
            child: const Icon(
              Icons.bakery_dining,
              size: 35,
              color: Colors.deepPurple,
            ),
          ),
          const SizedBox(height: 12),
          // App Name
          Text(
            'NX Bakers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple.shade800,
            ),
          ),
          const SizedBox(height: 4),
          // Subtitle
          Text(
            'Pastry Management',
            style: TextStyle(
              fontSize: 14,
              color: Colors.deepPurple.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationItems(BuildContext context) {
    return Column(
      children: [
        // Dashboard
        _buildListTile(
          context: context,
          icon: Icons.dashboard,
          title: 'Dashboard',
          onTap: () {
            Navigator.pop(context); // Close drawer
            // Already on dashboard, no navigation needed
          },
        ),

        // // Pastries
        // _buildListTile(
        //   context: context,
        //   icon: Icons.cake,
        //   title: 'All Pastries',
        //   onTap: () {
        //     Navigator.pop(context);
        //     Navigator.push(context, MaterialPageRoute(builder: (Context) {
        //       return ChangeNotifierProvider(
        //         create: (BuildContext context) => PastryViewModel()..loadPastries(),
        //         child: const PastriesPage(),
        //       );
        //     }));
        //   },
        // ),

        // Low Stock Pastries
        _buildListTile(
          context: context,
          icon: Icons.warning_amber,
          title: 'Low Stock',
          badgeCount: _getLowStockCount(),
          // You'll implement this
          badgeColor: Colors.orange,
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LowStockDetailsPage(),
              ),
            );
          },
        ),

        // Notifications
        _buildListTile(
          context: context,
          icon: Icons.notifications,
          title: 'Notifications',
          badgeCount: _getNotificationCount(),
          // You'll implement this
          badgeColor: Colors.red,
          onTap: () {
            Navigator.pop(context);
            Navigator.pushNamed(context, '/notifications');
          },
        ),

        // Settings
        _buildListTile(
          context: context,
          icon: Icons.settings,
          title: 'Settings',
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NotificationSettingsPage(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // App Version
          Text(
            'Version 1.0.0',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _showLogoutDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    VoidCallback? onTap,
    int? badgeCount,
    Color badgeColor = Colors.red,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: Colors.deepPurple.shade700,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: badgeCount != null && badgeCount > 0
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              child: Text(
                badgeCount > 99 ? '99+' : badgeCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      onTap: onTap,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Close drawer
                // Add your logout logic here
                _performLogout(context);
              },
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) {
    // Add your logout logic here
    // For example: Clear user data, navigate to login, etc.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Placeholder methods - implement these based on your data
  int _getLowStockCount() {
    // TODO: Implement logic to get low stock pastry count
    // Example: return Provider.of<StockProvider>(context).lowStockCount;
    return 3; // Temporary placeholder
  }

  int _getNotificationCount() {
    // TODO: Implement logic to get notification count
    // Example: return Provider.of<NotificationProvider>(context).unreadCount;
    return 5; // Temporary placeholder
  }
}
