import 'package:flutter/material.dart';
import '../../constants.dart';
import 'auth/login_page.dart';
import 'orders_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCream,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Settings",
          style: TextStyle(color: kText, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileSection(),
            _buildSection("ACCOUNT", [
              _buildListTile(Icons.shopping_bag_outlined, "My Orders", Colors.orange, onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const OrdersPage()));
              }),
              _buildListTile(Icons.calendar_today_outlined, "Active Orders", Colors.blue),
              _buildListTile(Icons.location_on_outlined, "Saved Addresses", Colors.pink),
            ]),
            _buildSection("SUPPORT & LEGAL", [
              _buildListTile(Icons.help_outline, "Contact Us", Colors.teal),
              _buildListTile(Icons.info_outline, "Help & FAQ", Colors.green),
              _buildListTile(Icons.star_outline, "Rate & Review", Colors.amber),
              _buildListTile(Icons.security_outlined, "Privacy Policy", Colors.indigo),
              _buildListTile(Icons.description_outlined, "Terms & Conditions", Colors.blueGrey),
            ]),
            _buildSection("SESSION", [
              _buildListTile(Icons.logout, "Log Out", Colors.red, isDestructive: true, onTap: () {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              }),
              _buildListTile(Icons.delete_outline, "Delete Account", Colors.grey),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: kGold.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: kGold.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(color: kGold.withValues(alpha: 0.2), width: 2),
            ),
            child: const Icon(Icons.person, size: 40, color: kGold),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "saravanan",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kText),
                ),
                Text(
                  "8681020301",
                  style: TextStyle(fontSize: 14, color: kTextMuted.withValues(alpha: 0.7)),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: kGold.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
            child: const Text("Edit", style: TextStyle(color: kGold, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 24, top: 24, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              color: kTextMuted.withValues(alpha: 0.6),
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildListTile(IconData icon, String title, Color iconColor, {bool isDestructive = false, VoidCallback? onTap}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDestructive ? Colors.red : kText,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: kTextMuted.withValues(alpha: 0.3)),
      onTap: onTap,
    );
  }
}
