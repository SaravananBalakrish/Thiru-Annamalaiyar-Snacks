import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants.dart';
import '../../controllers/product_controller.dart';
import '../../models/product.dart';
import '../widgets/product_list_item.dart';

class CategoryMenuPage extends StatefulWidget {
  final String initialCategory;
  const CategoryMenuPage({super.key, required this.initialCategory});

  @override
  State<CategoryMenuPage> createState() => _CategoryMenuPageState();
}

class _CategoryMenuPageState extends State<CategoryMenuPage> {
  late String selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.initialCategory;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedCategory.toUpperCase(),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
      ),
      body: Consumer<ProductController>(
        builder: (context, productController, _) {
          final categories = productController.getCategories();
          if (categories.isNotEmpty && !categories.contains(selectedCategory)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => selectedCategory = categories.first);
            });
          }

          if (productController.isLoading) {
            return const _ShimmerLoading();
          }

          return Row(
            children: [
              _Sidebar(
                categories: categories,
                selectedCategory: selectedCategory,
                onCategorySelected: (cat) =>
                    setState(() => selectedCategory = cat),
              ),
              Expanded(
                child: _ProductList(
                  products:
                      productController.getProductsByCategory(selectedCategory),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onCategorySelected;

  const _Sidebar({
    required this.categories,
    required this.selectedCategory,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 80,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: Border(
          right: BorderSide(color: colorScheme.primary.withValues(alpha: 0.1)),
        ),
      ),
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final meta = CategoryMeta.getByName(cat);
          final isSelected = selectedCategory == cat;

          return InkWell(
            onTap: () => onCategorySelected(cat),
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: kPaddingL,
                    horizontal: kPaddingXS,
                  ),
                  color: isSelected ? colorScheme.surface : Colors.transparent,
                  child: Column(
                    children: [
                      Icon(
                        meta.icon,
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.onSurfaceVariant,
                        size: kIconMedium,
                      ),
                      const SizedBox(height: kPaddingS),
                      Text(
                        cat,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Positioned(
                    left: 0,
                    top: 15,
                    bottom: 15,
                    child: Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(kRadiusS),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ProductList extends StatelessWidget {
  final List<Product> products;

  const _ProductList({required this.products});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(kPaddingXL),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 60,
                color: colorScheme.primary.withValues(alpha: 0.3),
              ),
            ),
            const SizedBox(height: kPaddingXL),
            Text(
              kNoSnacksFound,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: kPaddingS),
            Text(
              kNoSnacksSubtitle,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

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

class _ShimmerLoading extends StatelessWidget {
  const _ShimmerLoading();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surface,
      child: Row(
        children: [
          Container(width: 80, color: colorScheme.surface),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(kPaddingM),
              itemCount: 6,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: kPaddingM),
                child: Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(kRadiusM),
                      ),
                    ),
                    const SizedBox(width: kPaddingM),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 15,
                            width: 100,
                            color: colorScheme.surface,
                          ),
                          const SizedBox(height: kPaddingS),
                          Container(
                            height: 15,
                            width: 60,
                            color: colorScheme.surface,
                          ),
                          const SizedBox(height: kPaddingM),
                          Container(
                            height: 32,
                            width: 80,
                            color: colorScheme.surface,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
