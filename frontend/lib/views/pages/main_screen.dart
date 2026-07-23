import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/address.dart';
import '../../controllers/address_controller.dart';

import '../../controllers/product_controller.dart';
import '../../constants.dart';
import 'home_page.dart';
import 'cart_page.dart';
import 'settings_page.dart';
import 'category_menu_page.dart';
import 'saved_addresses_page.dart';
import '../widgets/compact_cart_strip.dart';
import '../widgets/product_list_item.dart';
import '../../models/product.dart';

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
              // Cart strip is now inside the bottom sheet panel — no FAB floating over content
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
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        left: 16,
        right: 16,
        bottom: 10,
      ),
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
                        MaterialPageRoute(
                          builder: (context) =>
                              const SavedAddressesPage(),
                        ),
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
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Icon(Icons.arrow_drop_down, color: colorScheme.primary),
                            ],
                          ),
                          Text(
                            selectedAddress?.fullAddress ??
                                "Tap to set delivery address",
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
          // Search bar tapping opens a modal bottom sheet overlay — not a new page
          GestureDetector(
            onTap: () => _showSearchBottomSheet(context),
            child: AbsorbPointer(
              child: TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: "Search traditional snacks...",
                  prefixIcon: Icon(Icons.search, color: colorScheme.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Shows the search UI as a modal bottom sheet overlay.
  /// This avoids the FAB/content overlap issue when the keyboard appears.
  void _showSearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => const _SearchBottomSheet(),
    );
  }
}

// ---------------------------------------------------------------------------
// Search bottom sheet — appears as an overlay without hiding the main content
// ---------------------------------------------------------------------------
class _SearchBottomSheet extends StatefulWidget {
  const _SearchBottomSheet();

  @override
  State<_SearchBottomSheet> createState() => _SearchBottomSheetState();
}

class _SearchBottomSheetState extends State<_SearchBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<String> _query = ValueNotifier('');

  @override
  void dispose() {
    _controller.dispose();
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Sheet takes up most of the screen height so results are visible
    final sheetHeight = MediaQuery.of(context).size.height * 0.85;

    return Container(
      height: sheetHeight,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Search field row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.search, color: colorScheme.primary, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            autofocus: true,
                            style: theme.textTheme.bodyLarge,
                            decoration: InputDecoration(
                              hintText: kSearchSnacksHint,
                              hintStyle: TextStyle(
                                color: colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.5),
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding:
                                  const EdgeInsets.symmetric(vertical: 12),
                              suffixIcon: ValueListenableBuilder<String>(
                                valueListenable: _query,
                                builder: (context2, q, w) => q.isEmpty
                                    ? const SizedBox.shrink()
                                    : IconButton(
                                        icon: const Icon(Icons.clear, size: 18),
                                        onPressed: () {
                                          _controller.clear();
                                          _query.value = '';
                                        },
                                      ),
                              ),
                            ),
                            onChanged: (v) => _query.value = v,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: colorScheme.primary),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Results area
          Expanded(
            child: ValueListenableBuilder<String>(
              valueListenable: _query,
              builder: (ctx, query, _) {
                return Consumer<ProductController>(
                  builder: (ctx2, pc, child) {
                    if (query.isEmpty) {
                      return _buildEmptyHint(theme, colorScheme);
                    }
                    final q = query.toLowerCase();
                    final results = pc.products.where((p) {
                      return p.name.toLowerCase().contains(q) ||
                          p.category.toLowerCase().contains(q) ||
                          p.tags.any((t) => t.toLowerCase().contains(q));
                    }).toList();

                    if (results.isEmpty) {
                      return _buildNoResults(query, theme, colorScheme);
                    }
                    return _buildResults(results);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyHint(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_rounded,
            size: 72,
            color: colorScheme.primary.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 16),
          Text(
            kSearchSnacksAction,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(String query, ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sentiment_dissatisfied_rounded,
              size: 52,
              color: colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            "$kNoResultsFor \"$query\"",
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            kTrySearchingElse,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(List<Product> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(kPaddingM),
      physics: const BouncingScrollPhysics(),
      itemCount: products.length,
      itemBuilder: (context, index) => ProductListItem(product: products[index]),
    );
  }
}
