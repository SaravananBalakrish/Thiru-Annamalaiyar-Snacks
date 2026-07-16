import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/address.dart';
import '../../controllers/address_controller.dart';
import 'home_page.dart';
import 'cart_page.dart';
import 'settings_page.dart';
import 'category_menu_page.dart';
import 'search_page.dart';
import 'saved_addresses_page.dart';
import '../widgets/compact_cart_strip.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});

  static MainScreenState? of(BuildContext context) =>
      context.findAncestorStateOfType<MainScreenState>();

  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void setIndex(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const HomePage(),
    const CategoryMenuPage(initialCategory: "Sweets"),
    const CartPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Column(
        children: [
          if (_selectedIndex == 0) _buildTopBar(),
          Expanded(child: _pages[_selectedIndex]),
        ],
      ),
      bottomNavigationBar: Material(
        elevation: 8,
        color: colorScheme.surface,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedIndex != 2) const CompactCartStrip(),
              BottomNavigationBar(
                elevation: 0,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                selectedItemColor: colorScheme.primary,
                unselectedItemColor: colorScheme.onSurface.withValues(alpha: 0.6),
                currentIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home),
                    label: "Home",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.category_outlined),
                    activeIcon: Icon(Icons.category),
                    label: "Menu",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.shopping_cart_outlined),
                    activeIcon: Icon(Icons.shopping_cart),
                    label: "Cart",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.settings_outlined),
                    activeIcon: Icon(Icons.settings),
                    label: "Settings",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 10, left: 16, right: 16, bottom: 10),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Consumer<AddressController>(
            builder: (context, addressController, _) {
              final selectedAddress = addressController.selectedAddress;
              return Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.person, color: colorScheme.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SavedAddressesPage(isSelectionMode: true)),
                      ).then((value) {
                        if (value != null && value is Address) {
                          addressController.setSelectedAddress(value);
                        }
                      }),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                selectedAddress?.label ?? "Select Location",
                                style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                            ],
                          ),
                          Text(
                            selectedAddress?.fullAddress ?? "Tap to set delivery address",
                            style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          TextField(
            readOnly: true,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SearchPage())),
            decoration: InputDecoration(
              hintText: "Search traditional snacks...",
              prefixIcon: Icon(Icons.search, color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

