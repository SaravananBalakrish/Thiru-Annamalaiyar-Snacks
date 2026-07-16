import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants.dart';
import '../../controllers/product_controller.dart';
import '../../models/product.dart';
import '../widgets/product_list_item.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildSearchField(theme, colorScheme),
      ),
      body: Consumer<ProductController>(
        builder: (context, productController, _) {
          final allProducts = productController.products;
          final filteredProducts = _query.isEmpty
              ? <Product>[]
              : allProducts.where((p) {
                  final queryLower = _query.toLowerCase();
                  return p.name.toLowerCase().contains(queryLower) ||
                      p.category.toLowerCase().contains(queryLower) ||
                      p.tags.any((t) => t.toLowerCase().contains(queryLower));
                }).toList();

          if (_query.isEmpty) return _buildEmptySearch(theme, colorScheme);
          if (filteredProducts.isEmpty) {
            return _buildNoResults(theme, colorScheme);
          }
          return _buildResults(filteredProducts);
        },
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: kPaddingS),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(kRadiusM),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        style: theme.textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: kSearchSnacksHint,
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          fillColor: Colors.transparent,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: kPaddingS),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: kIconSmall),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = "");
                  },
                )
              : null,
        ),
        onChanged: (value) => setState(() => _query = value),
      ),
    );
  }

  Widget _buildEmptySearch(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 80,
            color: colorScheme.primary.withValues(alpha: 0.1),
          ),
          const SizedBox(height: kPaddingM),
          Text(
            kSearchSnacksAction,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(kPaddingL),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sentiment_dissatisfied,
              size: 60,
              color: colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: kPaddingL),
          Text(
            "$kNoResultsFor \"$_query\"",
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: kPaddingS),
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
      itemBuilder: (context, index) {
        return ProductListItem(product: products[index]);
      },
    );
  }
}
