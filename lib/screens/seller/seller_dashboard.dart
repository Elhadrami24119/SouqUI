import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../l10n/app_strings.dart';
import '../../models/models.dart';
import '../../mock/mock_service.dart';
import '../../utils/theme.dart';
import '../../widgets/app_dialogs.dart';
import 'subscription_screen.dart';

class SellerDashboard extends StatefulWidget {
  const SellerDashboard({super.key});

  @override
  State<SellerDashboard> createState() => _SellerDashboardState();
}

class _SellerDashboardState extends State<SellerDashboard>
    with SingleTickerProviderStateMixin {
  final DataService _data = DataService();
  late TabController _tabController;
  List<Product> _products = [];
  bool _hasPendingSub = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    if (!SupabaseService().isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      });
      return;
    }
    _tabController = TabController(length: 4, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final user = AuthService.currentUser;
    if (user == null) return;
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        _data.getMyProducts(),
        _data.hasPendingSubscription(user.id),
      ]);
      final products = (results[0] as List).cast<Product>();
      if (mounted) {
        setState(() {
          _products = products;
          _hasPendingSub = results[1] as bool;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Product> get _pending =>
      _products.where((p) => p.status == ProductStatus.pending).toList();
  List<Product> get _approved =>
      _products.where((p) => p.status == ProductStatus.approved).toList();
  List<Product> get _rejected =>
      _products.where((p) => p.status == ProductStatus.rejected).toList();
  List<Product> get _sold =>
      _products.where((p) => p.status == ProductStatus.sold).toList();

  Future<void> _openAddProduct() async {
    final added = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const AddProductScreen()),
    );
    if (added == true) _loadData();
  }

  Future<void> _markAsSold(Product product) async {
    final confirmed = await AppDialogs.showConfirm(
      context: context,
      icon: Icons.check_circle_rounded,
      iconColor: AppTheme.success,
      confirmColor: AppTheme.success,
      title: 'Marquer comme vendu',
      message: 'Confirmer que cette annonce a été vendue ?',
      detail: product.name,
      confirmLabel: 'Vendu',
    );
    if (confirmed != true) return;
    try {
      await DataService().markProductAsSold(product.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Produit marqué comme vendu ✔'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ));
      _loadData();
    } catch (_) {}
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await AppDialogs.showConfirm(
      context: context,
      icon: Icons.delete_rounded,
      iconColor: Colors.red,
      confirmColor: Colors.red,
      title: "Supprimer l'annonce",
      message: 'Voulez-vous vraiment supprimer définitivement cette annonce ?',
      detail: product.name,
      footnote: 'Cette action est irréversible.',
      confirmLabel: 'Supprimer',
      cancelLabel: 'Annuler',
    );
    if (confirmed != true) return;
    try {
      await DataService().deleteProduct(product.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Annonce supprimée 🗑️'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ));
      _loadData();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        title: Text(
          'Mes annonces',
          style: GoogleFonts.inter(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton.icon(
              onPressed: () {
                AuthService.logout();
                Navigator.of(context)
                    .pushNamedAndRemoveUntil('/', (r) => false);
              },
              icon: const Icon(Icons.logout_rounded,
                  size: 18, color: AppTheme.textGrey),
              label: Text(
                'Déconnexion',
                style: GoogleFonts.inter(
                    fontSize: 13, color: AppTheme.textGrey),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.textGrey,
            indicatorColor: AppTheme.primary,
            labelStyle: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 13),
            unselectedLabelStyle: const TextStyle(
                fontWeight: FontWeight.w500, fontSize: 13),
            tabs: [
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('En attente'),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.warning.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_pending.length}',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.warning),
                      ),
                    ),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Publiées'),
                    if (_approved.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_approved.length}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.success),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Rejetées'),
                    if (_rejected.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.priceRed.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_rejected.length}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.priceRed),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Tab(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Vendues'),
                    if (_sold.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.textGrey.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_sold.length}',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textDark),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(user),
          _buildSubscriptionBanner(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTabList(_pending, 'Aucune annonce en attente'),
                      _buildTabList(_approved, 'Aucune annonce publiée'),
                      _buildTabList(_rejected, 'Aucune annonce rejetée'),
                      _buildTabList(_sold, 'Aucune annonce vendue'),
                    ],
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddProduct,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'Ajouter',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildTabList(List<Product> items, String emptyMsg) {
    if (items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            emptyMsg,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textGrey,
            ),
          ),
        ),
      );
    }
    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        itemCount: items.length,
        itemBuilder: (_, i) => _SellerProductTile(
          product: items[i],
          onMarkAsSold: items[i].status == ProductStatus.approved
              ? () => _markAsSold(items[i])
              : null,
          onDelete: () => _deleteProduct(items[i]),
        ),
      ),
    );
  }

  Widget _buildSubscriptionBanner() {
    final user = AuthService.currentUser;
    if (user == null) return const SizedBox.shrink();

    if (user.isSubscribed) {
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.success.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.success.withOpacity(0.3)),
        ),
        child: Row(children: [
          const Icon(Icons.verified_rounded, color: AppTheme.success, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(
            S.current.upgradeActive,
            style: GoogleFonts.inter(
                color: AppTheme.success, fontWeight: FontWeight.w700,
                fontSize: 13),
          )),
          if (user.subscriptionExpiry != null)
            Text(
              'exp. ${user.subscriptionExpiry!.day}/${user.subscriptionExpiry!.month}/${user.subscriptionExpiry!.year}',
              style: GoogleFonts.inter(
                  color: AppTheme.success.withOpacity(0.7), fontSize: 11),
            ),
        ]),
      );
    }

    if (_hasPendingSub) {
      return Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.warning.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.warning.withOpacity(0.3)),
        ),
        child: Row(children: [
          const SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(
                strokeWidth: 2, color: AppTheme.warning),
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(
            S.current.upgradePending,
            style: GoogleFonts.inter(
                color: AppTheme.warning, fontWeight: FontWeight.w600,
                fontSize: 13),
          )),
        ]),
      );
    }

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SubscriptionScreen()),
      ).then((upgraded) {
        if (upgraded == true) setState(() {});
      }),
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A1A2E), Color(0xFF2D2D4E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.secondary.withOpacity(0.3),
              blurRadius: 12, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(Icons.star_rounded,
                color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(S.current.upgradeTitle,
                  style: GoogleFonts.inter(
                      color: Colors.white, fontWeight: FontWeight.w700,
                      fontSize: 14)),
              const SizedBox(height: 2),
              Text(S.current.upgradeSub,
                  style: GoogleFonts.inter(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 11, height: 1.3)),
            ],
          )),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(S.current.upgradeBtn,
                style: GoogleFonts.inter(
                    color: Colors.white, fontWeight: FontWeight.w700,
                    fontSize: 12)),
          ),
        ]),
      ),
    );
  }

  Widget _buildHeader(AppUser? user) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppTheme.primaryShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.storefront_rounded,
                color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, ${user?.name ?? 'Vendeur'} 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Gérez vos annonces facilement',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback? onMarkAsSold;
  final VoidCallback? onDelete;
  const _SellerProductTile({required this.product, this.onMarkAsSold, this.onDelete});

  @override
  Widget build(BuildContext context) {
    final url = product.imageUrl;
    final isAsset = url.startsWith('lib/assets/');
    final isLocal = url.startsWith('/') || url.startsWith('file://');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(16)),
                child: SizedBox(
                  width: 90,
                  height: 90,
                  child: isAsset
                      ? Image.asset(url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _imagePlaceholder())
                      : isLocal
                          ? Image.file(File(url),
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _imagePlaceholder())
                          : Image.network(url,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _imagePlaceholder()),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        AppTheme.formatPrice(product.price),
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.priceRed,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        product.category,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppTheme.textGrey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme
                              .statusColor(product.status)
                              .withOpacity(0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppTheme.statusColor(product.status).withOpacity(0.2),
                          ),
                        ),
                          child: Text(
                            switch (product.status) {
                              ProductStatus.pending => "⏳ En attente de validation",
                              ProductStatus.approved => "✅ Annonce publiée",
                              ProductStatus.rejected => "❌ Annonce refusée",
                              ProductStatus.sold => "✔ Produit vendu",
                            },
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.statusColor(product.status),
                          ),
                        ),
                      ),
                      if (product.status == ProductStatus.rejected &&
                          product.adminNote != null &&
                          product.adminNote!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.withOpacity(0.15)),
                          ),
                          child: Text(
                            'Motif : ${product.adminNote}',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: Colors.red[850],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (onMarkAsSold != null || onDelete != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
              child: Row(
                children: [
                  if (onDelete != null)
                    Expanded(
                      flex: 2,
                      child: OutlinedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red),
                        label: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                  if (onDelete != null && onMarkAsSold != null)
                    const SizedBox(width: 8),
                  if (onMarkAsSold != null)
                    Expanded(
                      flex: 3,
                      child: ElevatedButton.icon(
                        onPressed: onMarkAsSold,
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: const Text('Vendu'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() => Container(
        color: AppTheme.divider,
        child: const Icon(Icons.image_outlined,
            color: AppTheme.textGrey, size: 32),
      );
}

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  int _step = 0;

  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _deliveryPriceCtrl = TextEditingController();

  String? _selectedCategory;
  DeliveryOption _delivery = DeliveryOption.notAvailable;

  File? _mainImage;
  File? _image2;
  File? _image3;

  File? _paymentProof;

  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _whatsappCtrl.dispose();
    _deliveryPriceCtrl.dispose();
    super.dispose();
  }

  Future<File?> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1200,
      );
      if (picked == null) return null;
      return File(picked.path);
    } on PlatformException {
      return null;
    }
  }

  Future<void> _showImageSourceSheet({
    required void Function(File) onPicked,
  }) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 40,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
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
                Text(
                  'Ajouter une photo',
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 16),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      final f = await _pickImage(ImageSource.camera);
                      if (f != null) onPicked(f);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.primary.withOpacity(0.15)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                color: AppTheme.primary, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Prendre une photo',
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: AppTheme.textDark)),
                                Text('Utiliser l\'appareil photo',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppTheme.textGrey)),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 14, color: AppTheme.textGrey),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      final f = await _pickImage(ImageSource.gallery);
                      if (f != null) onPicked(f);
                    },
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppTheme.secondary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.secondary.withOpacity(0.15)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: AppTheme.secondary.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.photo_library_rounded,
                                color: AppTheme.secondary, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Choisir depuis la galerie',
                                    style: GoogleFonts.inter(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: AppTheme.textDark)),
                                Text('Parcourir les photos',
                                    style: GoogleFonts.inter(
                                        fontSize: 12,
                                        color: AppTheme.textGrey)),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded,
                              size: 14, color: AppTheme.textGrey),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textDark,
                      side: const BorderSide(color: AppTheme.divider),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(0, 48),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _goToStep1() {
    if (!_formKey.currentState!.validate()) return;
    if (_mainImage == null) {
      _showSnack('Veuillez ajouter une photo principale.');
      return;
    }
    setState(() => _step = 1);
  }

  Future<void> _submit() async {
    if (_paymentProof == null) {
      _showSnack('Veuillez joindre la preuve de paiement.');
      return;
    }
    setState(() => _isSubmitting = true);

    try {
      await SupabaseService().createProductWithFiles(
        mainImage: _mainImage!,
        image2: _image2,
        image3: _image3,
        paymentProof: _paymentProof!,
        data: {
          'name': _nameCtrl.text.trim(),
          'price': _priceCtrl.text.trim(),
          'category': _selectedCategory!,
          'description': _descCtrl.text.trim().isEmpty
              ? ''
              : _descCtrl.text.trim(),
          'seller_whatsapp': _whatsappCtrl.text.trim().isEmpty
              ? ''
              : _whatsappCtrl.text.trim(),
          'delivery': _delivery == DeliveryOption.available
              ? 'available'
              : 'not_available',
          if (_delivery == DeliveryOption.available &&
              _deliveryPriceCtrl.text.trim().isNotEmpty)
            'delivery_price': _deliveryPriceCtrl.text.trim(),
        },
      );
      if (mounted) setState(() {
        _isSubmitting = false;
        _step = 2;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showSnack('Erreur : ${e.toString()}');
      }
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: AppTheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: _step == 2
          ? null
          : AppBar(
              backgroundColor: AppTheme.surface,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 20, color: AppTheme.textDark),
                onPressed: () {
                  if (_step == 0) {
                    Navigator.pop(context);
                  } else {
                    setState(() => _step--);
                  }
                },
              ),
              title: Text(
                _step == 0
                    ? 'Nouvelle annonce'
                    : 'Preuve de paiement',
                style: GoogleFonts.inter(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(4),
                child: _StepProgressBar(step: _step, total: 2),
              ),
            ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.05, 0),
              end: Offset.zero,
            ).animate(anim),
            child: child,
          ),
        ),
        child: switch (_step) {
          0 => _buildProductForm(),
          1 => _buildPaymentStep(),
          _ => _buildSuccessStep(),
        },
      ),
    );
  }

  Widget _buildProductForm() {
    return Form(
      key: _formKey,
      child: ListView(
        key: const ValueKey(0),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        children: [
          _SectionLabel(label: 'Photo principale *'),
          const SizedBox(height: 10),
          _MainImagePicker(
            image: _mainImage,
            onTap: () => _showImageSourceSheet(
              onPicked: (f) => setState(() => _mainImage = f),
            ),
          ),
          const SizedBox(height: 20),

          _SectionLabel(label: 'Photos supplémentaires (optionnel)'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SecondaryImagePicker(
                  image: _image2,
                  label: 'Photo 2',
                  onTap: () => _showImageSourceSheet(
                    onPicked: (f) => setState(() => _image2 = f),
                  ),
                  onRemove: () => setState(() => _image2 = null),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SecondaryImagePicker(
                  image: _image3,
                  label: 'Photo 3',
                  onTap: () => _showImageSourceSheet(
                    onPicked: (f) => setState(() => _image3 = f),
                  ),
                  onRemove: () => setState(() => _image3 = null),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _SectionLabel(label: 'Nom du produit *'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Ex: Samsung Galaxy A54',
              prefixIcon: Icon(Icons.label_outline_rounded,
                  color: AppTheme.textGrey, size: 20),
            ),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Champ requis' : null,
          ),
          const SizedBox(height: 16),

          _SectionLabel(label: 'Prix (MRU) *'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _priceCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              hintText: 'Ex: 85000',
              prefixIcon: Icon(Icons.sell_outlined,
                  color: AppTheme.textGrey, size: 20),
              suffixText: 'MRU',
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Champ requis';
              final n = double.tryParse(v.trim());
              if (n == null || n <= 0) return 'Prix invalide';
              return null;
            },
          ),
          const SizedBox(height: 16),

          _SectionLabel(label: 'Catégorie *'),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppTheme.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18, vertical: 16),
              prefixIcon: const Icon(Icons.category_outlined,
                  color: AppTheme.textGrey, size: 20),
            ),
            hint: Text('Sélectionner une catégorie',
                style: GoogleFonts.inter(
                    color: AppTheme.textGrey, fontSize: 14)),
            items: DataService.categories
                .where((c) => c['name'] != 'Tout')
                .map((c) => DropdownMenuItem<String>(
                      value: c['name'] as String,
                      child: Text(
                        '${c['icon']}  ${c['name']}',
                        style: GoogleFonts.inter(
                            fontSize: 14, color: AppTheme.textDark),
                      ),
                    ))
                .toList(),
            onChanged: (v) => setState(() => _selectedCategory = v),
            validator: (v) =>
                v == null ? 'Veuillez choisir une catégorie' : null,
          ),
          const SizedBox(height: 16),

          _SectionLabel(label: 'Description'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _descCtrl,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              hintText: 'Décrivez votre produit (état, caractéristiques…)',
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 16),

          _SectionLabel(label: 'WhatsApp (optionnel)'),
          const SizedBox(height: 8),
          TextFormField(
            controller: _whatsappCtrl,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              hintText: 'Ex: +22222334455',
              prefixIcon: Icon(Icons.chat_outlined,
                  color: AppTheme.textGrey, size: 20),
            ),
          ),
          const SizedBox(height: 24),

          _SectionLabel(label: 'Livraison'),
          const SizedBox(height: 10),
          _DeliverySelector(
            value: _delivery,
            deliveryPriceCtrl: _deliveryPriceCtrl,
            onChanged: (v) => setState(() => _delivery = v),
          ),
          const SizedBox(height: 32),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _goToStep1,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Continuer',
                      style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600, fontSize: 15)),
                  const SizedBox(width: 8),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStep() {
    return ListView(
      key: const ValueKey(1),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.warning.withOpacity(0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: AppTheme.warning.withOpacity(0.3), width: 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline_rounded,
                  color: AppTheme.warning, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Pour publier votre annonce, veuillez joindre la preuve de paiement de l\'abonnement (capture d\'écran du virement).',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppTheme.textMid,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: AppTheme.primaryShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.payments_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Instructions de paiement',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _PayStep(number: '1', text: 'Envoyez 500 MRU via Bankily ou Masrvi'),
              _PayStep(number: '2', text: 'Numéro de réception : +222 44 XX XX XX', highlight: true),
              _PayStep(number: '3', text: 'Prenez une capture d\'écran de la confirmation'),
              _PayStep(number: '4', text: 'Téléchargez la capture ci-dessous', isLast: true),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _SectionLabel(label: 'Preuve de paiement *'),
        const SizedBox(height: 12),

        GestureDetector(
          onTap: () => _showImageSourceSheet(
            onPicked: (f) => setState(() => _paymentProof = f),
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 220,
            decoration: BoxDecoration(
              color: _paymentProof != null
                  ? Colors.transparent
                  : AppTheme.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: _paymentProof != null ? AppTheme.success : AppTheme.divider,
                width: _paymentProof != null ? 2 : 1.5,
              ),
            ),
            child: _paymentProof != null
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(_paymentProof!, fit: BoxFit.cover),
                      ),
                      Positioned(
                        top: 8, right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _paymentProof = null),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.close_rounded,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10, left: 0, right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppTheme.success,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_rounded,
                                    color: Colors.white, size: 14),
                                const SizedBox(width: 5),
                                Text('Preuve ajoutée',
                                    style: GoogleFonts.inter(
                                        color: Colors.white, fontSize: 12,
                                        fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 60, height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.upload_file_rounded,
                            color: AppTheme.primary, size: 28),
                      ),
                      const SizedBox(height: 12),
                      Text('Télécharger la preuve',
                          style: GoogleFonts.inter(
                              fontSize: 14, fontWeight: FontWeight.w600,
                              color: AppTheme.textDark)),
                      const SizedBox(height: 4),
                      Text('Caméra ou galerie',
                          style: GoogleFonts.inter(
                              fontSize: 12, color: AppTheme.textGrey)),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Envoyer la preuve de paiement',
                          style: GoogleFonts.inter(
                              fontWeight: FontWeight.w600, fontSize: 15)),
                      const SizedBox(width: 8),
                      const Icon(Icons.send_rounded, size: 18),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuccessStep() {
    return Center(
      key: const ValueKey(2),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: AppTheme.success, size: 44),
            ),
            const SizedBox(height: 24),
            Text('Annonce soumise !',
                style: GoogleFonts.inter(
                    fontSize: 22, fontWeight: FontWeight.w800,
                    color: AppTheme.textDark, letterSpacing: -0.5)),
            const SizedBox(height: 8),
            Text(
              'Votre annonce est en attente de validation.\nVous serez notifié dès qu\'elle sera approuvée.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                  fontSize: 14, color: AppTheme.textMid, height: 1.6),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              child: Text('Retour à mes annonces',
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Helper widgets ────────────────────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  final int step;
  final int total;
  const _StepProgressBar({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(total, (i) {
          final active = i <= step;
          return Expanded(
            child: Container(
              height: 3,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: active ? AppTheme.primary : AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(label,
        style: GoogleFonts.inter(
            fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textMid));
  }
}

class _MainImagePicker extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;
  const _MainImagePicker({required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 200,
        decoration: BoxDecoration(
          color: image != null ? Colors.transparent : AppTheme.background,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: image != null ? AppTheme.primary : AppTheme.divider,
            width: image != null ? 2 : 1.5,
          ),
        ),
        child: image != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(image!, fit: BoxFit.cover),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 60, height: 60,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        color: AppTheme.primary, size: 28),
                  ),
                  const SizedBox(height: 12),
                  Text('Ajouter une photo',
                      style: GoogleFonts.inter(
                          fontSize: 14, fontWeight: FontWeight.w600,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 4),
                  Text('Caméra ou galerie',
                      style: GoogleFonts.inter(
                          fontSize: 12, color: AppTheme.textGrey)),
                ],
              ),
      ),
    );
  }
}

class _SecondaryImagePicker extends StatelessWidget {
  final File? image;
  final String label;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  const _SecondaryImagePicker({
    required this.image, required this.label,
    required this.onTap, required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: image != null ? Colors.transparent : AppTheme.background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: image != null ? AppTheme.primary.withOpacity(0.5) : AppTheme.divider,
            width: image != null ? 1.5 : 1,
          ),
        ),
        child: image != null
            ? Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(image!, fit: BoxFit.cover),
                  ),
                  Positioned(
                    top: 4, right: 4,
                    child: GestureDetector(
                      onTap: onRemove,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(Icons.close_rounded,
                            color: Colors.white, size: 14),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_rounded, color: AppTheme.textGrey, size: 24),
                  const SizedBox(height: 4),
                  Text(label,
                      style: GoogleFonts.inter(
                          fontSize: 11, color: AppTheme.textGrey)),
                ],
              ),
      ),
    );
  }
}

class _DeliverySelector extends StatelessWidget {
  final DeliveryOption value;
  final TextEditingController deliveryPriceCtrl;
  final ValueChanged<DeliveryOption> onChanged;
  const _DeliverySelector({
    required this.value, required this.deliveryPriceCtrl,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          _DeliveryChoice(
            label: 'Disponible',
            icon: Icons.local_shipping_rounded,
            selected: value == DeliveryOption.available,
            onTap: () => onChanged(DeliveryOption.available),
          ),
          const SizedBox(width: 12),
          _DeliveryChoice(
            label: 'Non disponible',
            icon: Icons.store_rounded,
            selected: value == DeliveryOption.notAvailable,
            onTap: () => onChanged(DeliveryOption.notAvailable),
          ),
        ]),
        if (value == DeliveryOption.available) ...[
          const SizedBox(height: 12),
          TextFormField(
            controller: deliveryPriceCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              hintText: 'Prix de livraison (optionnel)',
              prefixIcon: Icon(Icons.monetization_on_outlined,
                  color: AppTheme.textGrey, size: 20),
            ),
          ),
        ],
      ],
    );
  }
}

class _DeliveryChoice extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _DeliveryChoice({
    required this.label, required this.icon,
    required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary.withOpacity(0.08) : AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppTheme.primary : AppTheme.divider,
              width: selected ? 2 : 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 18,
                  color: selected ? AppTheme.primary : AppTheme.textGrey),
              const SizedBox(width: 8),
              Text(label,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppTheme.primary : AppTheme.textGrey,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class _PayStep extends StatelessWidget {
  final String number;
  final String text;
  final bool highlight;
  final bool isLast;
  const _PayStep({
    required this.number, required this.text,
    this.highlight = false, this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26, height: 26,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(7),
            ),
            alignment: Alignment.center,
            child: Text(number,
                style: GoogleFonts.inter(
                    color: Colors.white, fontSize: 12,
                    fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(text,
                  style: GoogleFonts.inter(
                    fontSize: highlight ? 14 : 13,
                    fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
                    color: highlight ? Colors.white : Colors.white.withOpacity(0.85),
                    height: 1.4,
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
