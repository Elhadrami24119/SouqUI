import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_strings.dart';
import '../models/models.dart';
import '../mock/mock_service.dart';
import '../utils/theme.dart';
import '../widgets/product_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/lang_toggle.dart';
import 'product_detail_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _svc = SupabaseService();
  final _searchController = TextEditingController();
  String _selectedCategory = 'Tout';
  String _searchQuery = '';

  List<Product> _products = [];
  bool _isLoading = true;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    AppLocale().addListener(() {
      if (mounted) setState(() {});
    });
    _loadProducts();
    _loadUnreadCount();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      final products = await _svc.getApprovedProducts(
        category: _selectedCategory,
        search: _searchQuery,
      );
      if (mounted) setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUnreadCount() async {
    final user = _svc.currentUser;
    if (user == null) return;
    try {
      final count = await _svc.unreadCount(user.id);
      if (mounted) setState(() => _unreadCount = count);
    } catch (_) {}
  }

  void _onCategoryChanged(String category) {
    setState(() => _selectedCategory = category);
    _loadProducts();
  }

  void _onSearchChanged(String value) {
    setState(() => _searchQuery = value);
    _loadProducts();
  }

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MenuSheet(
        onNavigate: (route) {
          Navigator.pop(context);
          Navigator.pushNamed(context, route).then((_) {
            setState(() {});
            _loadProducts();
            _loadUnreadCount();
          });
        },
        onLogout: () async {
          Navigator.pop(context);
          await SupabaseService().logout();
          setState(() {});
          _loadProducts();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _svc.isLoggedIn
                                      ? '${S.of(context).hello}, ${_svc.currentUser!.name.split(' ').first} 👋'
                                      : S.of(context).welcome,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppTheme.textGrey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                if (_svc.isLoggedIn)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _svc.isAdmin
                                          ? AppTheme.secondary.withOpacity(0.15)
                                          : AppTheme.primary.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _svc.isAdmin ? Icons.admin_panel_settings_rounded : Icons.storefront_rounded,
                                          size: 11,
                                          color: _svc.isAdmin ? AppTheme.secondary : AppTheme.primary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          _svc.isAdmin ? 'Administrateur' : 'Vendeur',
                                          style: TextStyle(
                                            color: _svc.isAdmin ? AppTheme.secondary : AppTheme.primary,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppTheme.textGrey.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.visibility_outlined, size: 11, color: AppTheme.textGrey),
                                        SizedBox(width: 4),
                                        Text('Visiteur',
                                            style: TextStyle(color: AppTheme.textGrey, fontSize: 10, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                Text(
                                  S.of(context).appName,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                    color: AppTheme.textDark,
                                    letterSpacing: -0.8,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.black87,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.phone_android_rounded, size: 11, color: Colors.white70),
                                      SizedBox(width: 4),
                                      Text('Mode UI',
                                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              const LangToggle(),
                              const SizedBox(width: 10),
                              if (_svc.isLoggedIn) ...[
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NotificationsScreen(
                                          userId: _svc.currentUser!.id),
                                    ),
                                  ).then((_) {
                                    setState(() => _unreadCount = 0);
                                  }),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: 46,
                                        height: 46,
                                        decoration: BoxDecoration(
                                          color: AppTheme.surface,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          boxShadow: AppTheme.cardShadow,
                                        ),
                                        child: const Icon(
                                            Icons.notifications_outlined,
                                            color: AppTheme.textDark,
                                            size: 22),
                                      ),
                                      if (_unreadCount > 0)
                                        Positioned(
                                          top: 6,
                                          right: 6,
                                          child: Container(
                                            width: 16,
                                            height: 16,
                                            decoration: const BoxDecoration(
                                              color: AppTheme.priceRed,
                                              shape: BoxShape.circle,
                                            ),
                                            child: Center(
                                              child: Text(
                                                _unreadCount > 9
                                                    ? '9+'
                                                    : '$_unreadCount',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 9,
                                                    fontWeight:
                                                        FontWeight.w700),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 10),
                              ],
                              GestureDetector(
                                onTap: _openMenu,
                                child: Container(
                                  width: 46,
                                  height: 46,
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.darkGradient,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppTheme.secondary
                                            .withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.menu_rounded,
                                      color: Colors.white, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: AppTheme.cardShadow,
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          style: const TextStyle(
                              fontSize: 15, color: AppTheme.textDark),
                          decoration: InputDecoration(
                            hintText: S.of(context).searchHint,
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: AppTheme.textGrey, size: 22),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.cancel_rounded,
                                        color: AppTheme.textGrey, size: 20),
                                    onPressed: () {
                                      _searchController.clear();
                                      _onSearchChanged('');
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppTheme.surface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                      child: Text(
                        S.of(context).categories,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 88,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: SupabaseService.categories.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(width: 10),
                        itemBuilder: (_, i) {
                          final cat = SupabaseService.categories[i];
                          return CategoryChip(
                            label: cat['name'],
                            emoji: cat['icon'],
                            selected: _selectedCategory == cat['name'],
                            onTap: () => _onCategoryChanged(cat['name']),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        S.of(context).bestListings,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_products.length} ${S.of(context).results}',
                          style: const TextStyle(
                            color: AppTheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              if (_isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_products.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 60),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppTheme.textGrey.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.search_off_rounded,
                              size: 36, color: AppTheme.textGrey),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          S.of(context).noProduct,
                          style: const TextStyle(
                            color: AppTheme.textDark,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          S.of(context).tryOther,
                          style: const TextStyle(
                              color: AppTheme.textGrey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => ProductCard(
                        product: _products[i],
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ProductDetailScreen(
                                product: _products[i]),
                          ),
                        ),
                      ),
                      childCount: _products.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      mainAxisExtent: 320,
                    ),
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(18),
              boxShadow: AppTheme.primaryShadow,
            ),
            child: FloatingActionButton.extended(
              onPressed: () {
                if (_svc.isLoggedIn) {
                  Navigator.pushNamed(context, '/seller').then((_) {
                    setState(() {});
                    _loadProducts();
                  });
                } else {
                  Navigator.pushNamed(context, '/login');
                }
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(
                S.of(context).publish,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ),
      ),
    );
  }
}

class _MenuSheet extends StatelessWidget {
  final void Function(String) onNavigate;
  final VoidCallback onLogout;

  const _MenuSheet({required this.onNavigate, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final svc = SupabaseService();
    final isLoggedIn = svc.isLoggedIn;
    final isAdmin = svc.isAdmin;

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          if (isLoggedIn) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppTheme.darkGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.person_rounded,
                        color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          svc.currentUser!.name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15),
                        ),
                        Text(
                          isAdmin
                              ? S.of(context).administrator
                              : S.of(context).sellerRole,
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (isAdmin)
            _MenuItem(
              icon: Icons.admin_panel_settings_rounded,
              label: S.of(context).administration,
              subtitle: S.of(context).manageListings,
              color: AppTheme.secondary,
              onTap: () => onNavigate('/admin'),
            ),
          if (isLoggedIn)
            _MenuItem(
              icon: Icons.storefront_rounded,
              label: S.of(context).myListings,
              subtitle: S.of(context).manageProducts,
              color: AppTheme.primary,
              onTap: () => onNavigate('/seller'),
            ),
          if (!isLoggedIn) ...[
            _MenuItem(
              icon: Icons.login_rounded,
              label: S.of(context).loginMenu,
              subtitle: S.of(context).accessAccount,
              color: AppTheme.primary,
              onTap: () => onNavigate('/login'),
            ),
            _MenuItem(
              icon: Icons.person_add_rounded,
              label: S.of(context).createAccount,
              subtitle: S.of(context).becomeSeller,
              color: AppTheme.secondary,
              onTap: () => onNavigate('/register'),
            ),
          ],
          if (isLoggedIn) ...[
            const Divider(height: 24, color: AppTheme.divider),
            _MenuItem(
              icon: Icons.logout_rounded,
              label: S.of(context).logout,
              subtitle: S.of(context).leaveAccount,
              color: Colors.red,
              onTap: onLogout,
            ),
          ],
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppTheme.textDark)),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textGrey)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded,
                  size: 14, color: AppTheme.textGrey),
            ],
          ),
        ),
      ),
    );
  }
}
