import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../constants.dart';
import '../../models/product.dart';
import '../../controllers/product_controller.dart';
import '../widgets/product_list_item.dart';
import 'category_menu_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductController>().loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return RefreshIndicator(
      onRefresh: () => context.read<ProductController>().loadProducts(),
      color: colorScheme.primary,
      child: Consumer<ProductController>(
        builder: (context, productController, _) {
          if (productController.isLoading) {
            return const _ShimmerLoading();
          }

          if (productController.error != null) {
            return _buildErrorState(productController, colorScheme);
          }

          final products = productController.products;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Banner(),
                _MindSection(productController: productController),
                _RecommendedSection(products: products),
                const Footer(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildErrorState(
    ProductController productController,
    ColorScheme colorScheme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            productController.error!,
            style: TextStyle(color: colorScheme.error),
          ),
          const SizedBox(height: kPaddingM),
          ElevatedButton(
            onPressed: () => productController.loadProducts(),
            child: const Text(kRetry),
          )
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      height: 180,
      width: double.infinity,
      margin: const EdgeInsets.all(kPaddingM),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(kRadiusL),
        child: Stack(
          children: [
            CachedNetworkImage(
              imageUrl:
                  'https://images.unsplash.com/photo-1505253149613-112d21d9f6a9?q=80&w=1000&auto=format&fit=crop',
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (context, url) => Container(
                color: colorScheme.surfaceContainerHighest,
              ),
              errorWidget: (context, url, error) => Container(
                color: colorScheme.surfaceContainerHighest,
                child: const Icon(Icons.error),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  colors: [kBlack.withValues(alpha: 0.8), Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.all(kPaddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "TRIPLE BERRY SUNDAE",
                    style: theme.textTheme.titleLarge?.copyWith(color: kWhite),
                  ),
                  Text(
                    "THIS SUNDAE IS UN-BERRY-LIEVABLY\nDELICIOUS!",
                    style: theme.textTheme.bodySmall?.copyWith(color: kWhite.withValues(alpha: 0.7)),
                  ),
                  const SizedBox(height: kPaddingM),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kWhite,
                      foregroundColor: kBlack,
                      minimumSize: const Size(120, 36),
                      padding: const EdgeInsets.symmetric(
                        horizontal: kPaddingM,
                        vertical: kPaddingS,
                      ),
                    ),
                    child: const Text(kShopNow),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MindSection extends StatelessWidget {
  final ProductController productController;

  const _MindSection({required this.productController});

  String getImgForCategory(String name) {
    switch (name.toLowerCase()) {
      case 'sweets':
        return 'https://cdn-icons-png.flaticon.com/512/2513/2513831.png';
      case 'savoury':
        return 'https://cdn-icons-png.flaticon.com/512/3014/3014534.png';
      case 'bakery':
        return 'https://cdn-icons-png.flaticon.com/512/3014/3014498.png';
      default:
        return 'https://cdn-icons-png.flaticon.com/512/3014/3014511.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dynamicCategories =
        productController.getCategories().where((c) => c != 'All').toList();
    if (dynamicCategories.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: kPaddingM,
            vertical: kPaddingS,
          ),
          child: Text(
            kWhatsOnMind,
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: kPaddingS),
            physics: const BouncingScrollPhysics(),
            itemCount: dynamicCategories.length,
            itemBuilder: (context, index) {
              final catName = dynamicCategories[index];
              return _CategoryItem(
                name: catName,
                imageUrl: getImgForCategory(catName),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String name;
  final String imageUrl;

  const _CategoryItem({required this.name, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryMenuPage(initialCategory: name),
          ),
        );
      },
      borderRadius: BorderRadius.circular(kRadiusL),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            margin: const EdgeInsets.symmetric(horizontal: kPaddingS),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(kRadiusL),
              boxShadow: [
                BoxShadow(
                  color: colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(kPaddingM),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colorScheme.primary,
                  ),
                ),
                errorWidget: (context, url, error) => Icon(
                  Icons.fastfood_outlined,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: kPaddingS),
          Text(
            name,
            style:
                theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _RecommendedSection extends StatelessWidget {
  final List<Product> products;

  const _RecommendedSection({required this.products});

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(kPaddingM),
          child: Text(
            kRecommendedItems,
            style: TextStyle(
              color: colorScheme.primary,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: kPaddingM),
          itemCount: products.length > 5 ? 5 : products.length,
          itemBuilder: (context, index) =>
              ProductListItem(product: products[index]),
        ),
        if (products.length > 5)
          Center(
            child: TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const CategoryMenuPage(initialCategory: 'All'),
                  ),
                );
              },
              icon: Text(
                kViewAllSnacks,
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              label: Icon(
                Icons.arrow_forward,
                size: 16,
                color: colorScheme.primary,
              ),
            ),
          ),
      ],
    );
  }
}

class _ShimmerLoading extends StatelessWidget {
  const _ShimmerLoading();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return SingleChildScrollView(
      child: Shimmer.fromColors(
        baseColor: baseColor,
        highlightColor: highlightColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              margin: const EdgeInsets.all(kPaddingM),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(kRadiusL),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: kPaddingM,
                vertical: kPaddingS,
              ),
              child: Container(height: 20, width: 150, color: colorScheme.surface),
            ),
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: kPaddingS),
                itemCount: 5,
                itemBuilder: (context, index) => Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      margin: const EdgeInsets.symmetric(horizontal: kPaddingS),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(kRadiusL),
                      ),
                    ),
                    const SizedBox(height: kPaddingS),
                    Container(height: 10, width: 50, color: colorScheme.surface),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(kPaddingM),
              child: Container(height: 20, width: 180, color: colorScheme.surface),
            ),
            ...List.generate(
              3,
              (_) => Container(
                height: 120,
                margin: const EdgeInsets.symmetric(
                  horizontal: kPaddingM,
                  vertical: kPaddingS,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(kRadiusL),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: theme.brightness == Brightness.dark 
          ? colorScheme.surfaceContainer 
          : kDark, // Using kDark for brand identity in light mode too
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "ANNAMALAIYAR",
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.outline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      kFooterDesc,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: kWhite.withValues(alpha: 0.38),
                        fontSize: 12,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
          const Expanded(
            child: FooterCol(
              title: kContact,
              items: ["+91 86810 20301", kWhatsAppUs, kEmailUs],
            ),
          ),
        ],
      ),
      const SizedBox(height: 40),
      Divider(color: kWhite.withValues(alpha: 0.1)),
      const SizedBox(height: 20),
      Text(
        kCopyright,
        style: theme.textTheme.bodySmall?.copyWith(
          color: kWhite.withValues(alpha: 0.24),
          fontSize: 12,
        ),
      ),
    ],
  ),
);
}
}

class FooterCol extends StatelessWidget {
final String title;
final List<String> items;
const FooterCol({super.key, required this.title, required this.items});

@override
Widget build(BuildContext context) {
final theme = Theme.of(context);
return Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text(
      title,
      style: theme.textTheme.labelSmall?.copyWith(
        color: kWhite,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    ),
    const SizedBox(height: 12),
    ...items.map(
      (i) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          i,
          style: theme.textTheme.bodySmall?.copyWith(
            color: kWhite.withValues(alpha: 0.38),
            fontSize: 12,
          ),
        ),
      ),
    ),
      ],
    );
  }
}
