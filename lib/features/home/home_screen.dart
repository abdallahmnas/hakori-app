import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/auth_provider.dart';
import '../../core/services/order_provider.dart';
import '../../core/services/product_provider.dart';
import '../../core/widgets/app_bar_luxury.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/badge_chip.dart';
import '../catalog/catalog_filter_drawer.dart';

/// Screen 7: home_luxury_grillz_discovery
/// Main discovery screen with editorial hero carousel, category pills, and 2-column showcase connected to ProductProvider
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);

      productProvider.fetchCatalog();
      if (authProvider.isAuthenticated) {
        authProvider.refreshProfile();
        orderProvider.fetchOrders();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CatalogFilterDrawer(),
    );
  }

  void _openDashboardLoginSheet() {
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    bool isLoggingIn = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.outlineLight,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Log In to Hakori',
                      style: AppTypography.headlineMD(color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Access your bespoke commissions, orders, and private catalog.',
                      style: AppTypography.bodySM(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: 'Email',
                      hintText: 'you@example.com',
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(Icons.mail_outline, size: 20, color: AppColors.primaryGold),
                    ),
                    const SizedBox(height: 14),
                    AppTextField(
                      label: 'Password',
                      hintText: '••••••••',
                      controller: passCtrl,
                      isPassword: true,
                      prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.primaryGold),
                    ),
                    const SizedBox(height: 22),
                    AppButton.primary(
                      text: isLoggingIn ? 'LOGGING IN...' : 'LOG IN',
                      onPressed: isLoggingIn
                          ? null
                          : () async {
                              final email = emailCtrl.text.trim();
                              final pass = passCtrl.text;
                              if (email.isEmpty || pass.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please enter both email and password.'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                                return;
                              }
                              setSheetState(() => isLoggingIn = true);
                              final auth = Provider.of<AuthProvider>(context, listen: false);
                              final ok = await auth.login(email: email, password: pass);
                              if (!mounted) return;
                              setSheetState(() => isLoggingIn = false);

                              if (ok) {
                                final productProvider = Provider.of<ProductProvider>(context, listen: false);
                                final orderProvider = Provider.of<OrderProvider>(context, listen: false);
                                productProvider.fetchCatalog();
                                orderProvider.fetchOrders();
                                auth.refreshProfile();

                                if (ctx.mounted) {
                                  Navigator.of(ctx).pop();
                                }
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Welcome back! Logged in successfully.'),
                                      backgroundColor: AppColors.darkBase,
                                    ),
                                  );
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(auth.errorMessage ?? 'Login failed. Please check credentials.'),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                              }
                            },
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          context.push('/signup');
                        },
                        child: Text(
                          "Don't have an account? Sign Up",
                          style: AppTypography.labelSM(color: AppColors.primaryGold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final auth = Provider.of<AuthProvider>(context);
    final displayedProducts = productProvider.products;
    final categoryFilters = productProvider.categoryFilters;
    final selectedCategory = productProvider.selectedCategory;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LuxuryAppBar(),
      body: RefreshIndicator(
        color: AppColors.primaryGold,
        backgroundColor: AppColors.darkBase,
        onRefresh: () async {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          final orderProvider = Provider.of<OrderProvider>(context, listen: false);
          await Future.wait([
            productProvider.fetchCatalog(),
            if (authProvider.isAuthenticated) ...[
              authProvider.refreshProfile(),
              orderProvider.fetchOrders(),
            ],
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Search Bar & Filter Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outlineLight),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: (val) => productProvider.setSearchQuery(val),
                          style: AppTypography.bodyMD(),
                          decoration: InputDecoration(
                            hintText: 'Search fine jewelry, gold, diamonds...',
                            hintStyle: AppTypography.bodySM(
                              color: AppColors.textMuted,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              size: 18,
                              color: AppColors.primaryGold,
                            ),
                            suffixIcon: _searchController.text.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 16),
                                    onPressed: () {
                                      _searchController.clear();
                                      productProvider.setSearchQuery('');
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _openFilterDrawer,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: AppColors.darkBase,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                        child: const Icon(
                          Icons.tune,
                          color: AppColors.primaryGold,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Guest Login Banner (if not authenticated)
            if (!auth.isAuthenticated)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.darkCard,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.primaryGold.withAlpha(140), width: 1),
                      boxShadow: const [AppColors.goldGlow],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primaryGold, width: 1),
                          ),
                          child: const Icon(Icons.lock_outline, size: 16, color: AppColors.primaryGold),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Browsing as Guest',
                                style: AppTypography.labelMD(color: AppColors.textOnDark),
                              ),
                              Text(
                                'Log in to view orders, profile, and private pieces.',
                                style: AppTypography.bodyXS(color: AppColors.surfaceContainerHigh),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppButton.primary(
                          text: 'LOG IN',
                          height: 34,
                          width: 80,
                          borderRadius: 8,
                          onPressed: _openDashboardLoginSheet,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Editorial Hero Carousel Banner
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [AppColors.softCardShadow],
                    image: const DecorationImage(
                      image: NetworkImage(
                        'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=1000&auto=format&fit=crop',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.4),
                          Colors.black.withOpacity(0.92),
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 24),
                        const AppBadgeChip(
                          label: 'AUTUMN ATELIER DROP',
                          variant: BadgeChipVariant.goldPurity,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '18K VVS1 Diamond Pavé Arch',
                          style: AppTypography.headlineMD(
                            color: AppColors.textOnDark,
                          ).copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Handcrafted fine jewelry in gold, diamonds, and sterling silver.',
                          style: AppTypography.bodyXS(
                            color: AppColors.surfaceContainerHigh,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            AppButton.primary(
                              text: 'EXPLORE PIECE',
                              height: 36,
                              width: 136,
                              borderRadius: 18,
                              onPressed: () {
                                if (displayedProducts.isNotEmpty) {
                                  context.push('/product/${displayedProducts.first.id}');
                                } else {
                                  context.push('/categories');
                                }
                              },
                            ),
                            AppButton.outline(
                              text: 'TRY ON',
                              height: 36,
                              width: 114,
                              borderRadius: 18,
                              onPressed: () => context.push('/ar-fitting'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Curated Collections Showcase on Dashboard
            if (productProvider.categories.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: SectionHeader(
                          title: 'Curated Collections',
                          subtitle: 'Place Vendôme disciplines & jewelry categories',
                          actionText: 'ALL (${productProvider.categories.length})',
                          onActionTap: () => context.push('/categories'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 94,
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: productProvider.categories.length,
                          separatorBuilder: (context, index) => const SizedBox(width: 10),
                          itemBuilder: (context, index) {
                            final cat = productProvider.categories[index];
                            final isSelected = cat.name.toLowerCase() == selectedCategory.toLowerCase();
                            return InkWell(
                              onTap: () {
                                if (isSelected) {
                                  productProvider.setSelectedCategory('ALL');
                                } else {
                                  productProvider.setSelectedCategory(cat.name);
                                }
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                width: 140,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isSelected ? AppColors.primaryGold : AppColors.outlineLight,
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                  boxShadow: const [AppColors.softCardShadow],
                                  image: DecorationImage(
                                    image: NetworkImage(
                                      cat.imageUrl.isNotEmpty
                                          ? cat.imageUrl
                                          : 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=1000&auto=format&fit=crop',
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(13),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.15),
                                        Colors.black.withOpacity(0.85),
                                      ],
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        cat.name.toUpperCase(),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.labelSM(color: AppColors.textOnDark).copyWith(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      Text(
                                        '${cat.pieceCount} PIECES',
                                        style: AppTypography.bodyXS(color: AppColors.primaryGold).copyWith(fontSize: 8.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Horizontal Category Filter Pills
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: SizedBox(
                  height: 34,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: categoryFilters.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final cat = categoryFilters[index];
                      final isSelected = cat == selectedCategory;
                      return InkWell(
                        onTap: () => productProvider.setSelectedCategory(cat),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.darkBase
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primaryGold
                                  : AppColors.outlineLight,
                              width: 1,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              cat,
                              style: AppTypography.labelSM(
                                color: isSelected
                                    ? AppColors.primaryGold
                                    : AppColors.textSecondary,
                              ).copyWith(fontSize: 9),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Section Header: Haute Joaillerie Showcase
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                child: SectionHeader(
                  title: 'Atelier Vault Highlights',
                  subtitle: 'Single-origin 18K solid gold & certified gemstones',
                  actionText: 'ALL (${displayedProducts.length})',
                  onActionTap: () => context.push('/categories'),
                ),
              ),
            ),

            // Loading / Empty / Grid State
            if (productProvider.isLoading && displayedProducts.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                    ),
                  ),
                ),
              )
            else if (displayedProducts.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.search_off, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'No Atelier Pieces Found',
                          style: AppTypography.headlineSM(color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'No items matched your search query or selected discipline.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyXS(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        AppButton.outline(
                          text: 'RESET FILTERS',
                          height: 38,
                          width: 140,
                          onPressed: () {
                            _searchController.clear();
                            productProvider.setSearchQuery('');
                            productProvider.setSelectedCategory('ALL');
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              // 2-Column Product Grid
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.52,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final product = displayedProducts[index];
                    return ProductCard(
                      product: product,
                      onTap: () => context.push('/product/${product.id}'),
                    );
                  }, childCount: displayedProducts.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
