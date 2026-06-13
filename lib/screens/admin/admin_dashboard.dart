import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../l10n/app_strings.dart';
import '../../models/models.dart';
import '../../mock/mock_service.dart';
import '../../utils/theme.dart';
import '../../widgets/app_dialogs.dart';
import '../notifications_screen.dart';
import '../product_detail_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  final DataService _data = DataService();
  late TabController _tabController;

  List<Product> _pendingProducts = [];
  List<Product> _approvedProducts = [];
  List<AppUser> _users = [];
  List<SubscriptionRequest> _subRequests = [];
  List<AppNotification> _adminAlerts = [];
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    if (!SupabaseService().isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
      });
      return;
    }
    _tabController = TabController(length: 5, vsync: this);
    _loadAll();
  }

  Future<void> _loadAll() async {
    try {
      final adminId = SupabaseService().currentUser?.id ?? '';
      final results = await Future.wait([
        _data.getPendingProducts(),
        _data.getApprovedProducts(),
        _data.getAllUsers(),
        _data.getPendingSubscriptions(),
        _data.unreadCount(adminId),
        _data.getNotifications(adminId),
      ]);
      if (!mounted) return;
      setState(() {
        _pendingProducts = (results[0] as List).cast<Product>();
        _approvedProducts = (results[1] as List).cast<Product>();
        _users = (results[2] as List).cast<AppUser>();
        _subRequests = (results[3] as List).cast<SubscriptionRequest>();
        _unreadCount = results[4] as int;
        _adminAlerts = (results[5] as List)
            .cast<AppNotification>()
            .where((n) => n.type == 'admin_alert' || n.type == 'admin_expiry')
            .toList();
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildImg(String url, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (url.startsWith('lib/assets/')) {
      return Image.asset(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _imgPlaceholder(width, height),
      );
    }
    if (url.startsWith('/')) {
      return Image.file(
        File(url),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _imgPlaceholder(width, height),
      );
    }
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, __, ___) => _imgPlaceholder(width, height),
    );
  }

  Widget _imgPlaceholder(double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: AppTheme.divider,
      child: const Icon(Icons.image_not_supported_outlined, color: AppTheme.textGrey),
    );
  }

  Future<void> _approveProduct(Product p) async {
    final confirmed = await AppDialogs.showConfirm(
      context: context,
      icon: Icons.check_circle_rounded,
      iconColor: AppTheme.success,
      confirmColor: AppTheme.success,
      title: 'Approuver cette annonce ?',
      message: 'Cette annonce sera visible publiquement.',
      detail: p.name,
      confirmLabel: 'Approuver',
    );
    if (confirmed != true) return;
    await _data.updateProductStatus(p.id, ProductStatus.approved);
    await _data.addNotification(AppNotification(
      id: 'n-auto-${DateTime.now().millisecondsSinceEpoch}',
      userId: p.sellerId,
      title: 'Annonce approuvée ✅',
      body: 'Votre annonce "${p.name}" a été approuvée et publiée avec succès.',
      createdAt: DateTime.now(),
    ));
    await _loadAll();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('${p.name} → Approuvée ✅'),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    ));
  }

  Future<void> _rejectProduct(Product p) async {
    final result = await AppDialogs.showRejectDialog(
      context: context,
      productName: p.name,
      hintText: S.of(context).rejectReason,
    );
    if (result?.confirmed == true) {
      final reason = result!.reason.isEmpty ? null : result.reason;
      await _data.updateProductStatus(p.id, ProductStatus.rejected, adminNote: reason);
      final body = reason != null
          ? 'Votre annonce "${p.name}" a été refusée. Motif : $reason'
          : 'Votre annonce "${p.name}" a été refusée.';
      await _data.addNotification(AppNotification(
        id: 'n-auto-${DateTime.now().millisecondsSinceEpoch}',
        userId: p.sellerId,
        title: 'Annonce refusée ❌',
        body: body,
        createdAt: DateTime.now(),
      ));
      await _loadAll();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('${p.name} → Refusée ❌'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ));
    }
  }

  Future<void> _editProduct(Product p) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (ctx) => _EditProductDialog(product: p, data: _data),
    );
    if (updated == true) {
      await _loadAll();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Catégorie mise à jour ✅'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ));
    }
  }

  Future<void> _deleteProduct(Product p) async {
    final confirmed = await AppDialogs.showConfirm(
      context: context,
      icon: Icons.delete_rounded,
      iconColor: Colors.red,
      confirmColor: Colors.red,
      title: "Supprimer l'annonce",
      message: 'Voulez-vous vraiment supprimer définitivement cette annonce ?',
      detail: p.name,
      footnote: 'Cette action est irréversible.',
      confirmLabel: 'Supprimer',
    );
    if (confirmed == true) {
      await _data.deleteProduct(p.id);
      await _loadAll();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Annonce supprimée 🗑️'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ));
    }
  }

Future<void> _warnUser(AppUser user) async {
  final msgCtrl = TextEditingController();
  final s = S.of(context);

  final confirmed = await AppDialogs.showConfirm(
    context: context,
    icon: Icons.warning_amber_rounded,
    iconColor: AppTheme.warning,
    confirmColor: AppTheme.warning,
    title: s.warnTitle,
    message: '${s.usersTab} : ${user.name}',
    confirmLabel: s.sendBtn,
    extraContent: Padding(
      padding: const EdgeInsets.only(top: 4),
      child: TextField(
        controller: msgCtrl,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: s.warnMessage,
          filled: true,
          fillColor: AppTheme.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppTheme.warning, width: 1.5),
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    ),
  );

  if (confirmed == true && msgCtrl.text.trim().isNotEmpty) {
    await _data.warnUser(user.id, msgCtrl.text.trim());
    await _loadAll();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Utilisateur averti ⚠️'),
      behavior: SnackBarBehavior.floating,
      duration: Duration(seconds: 2),
    ));
  }

  msgCtrl.dispose();
}

  Widget _buildSubscriptionsTab() {
    final requests = _subRequests;
    if (requests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_outline_rounded,
                  size: 40, color: AppTheme.primary),
            ),
            const SizedBox(height: 16),
            Text(S.of(context).noSubRequests,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700,
                    color: AppTheme.textDark)),
            const SizedBox(height: 6),
            Text(S.of(context).allUpToDate,
                style: const TextStyle(color: AppTheme.textGrey, fontSize: 14)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (_, i) => _SubscriptionRequestCard(
        request: requests[i],
        onApprove: () async {
          await _data.approveSubscription(requests[i].id);
          await _loadAll();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Abonnement approuvé ✅'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ));
        },
        onReject: () async {
          await _data.rejectSubscription(requests[i].id);
          await _loadAll();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Abonnement refusé ❌'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ));
        },
      ),
    );
  }

  Widget _buildPendingTab() {
    final pending = _pendingProducts;
    if (pending.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: AppTheme.success),
            SizedBox(height: 16),
            Text('Aucune annonce en attente',
                style: TextStyle(color: AppTheme.textGrey, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: pending.length,
      itemBuilder: (_, i) => _PendingProductCard(
        product: pending[i],
        buildImg: _buildImg,
        onApprove: () => _approveProduct(pending[i]),
        onReject: () => _rejectProduct(pending[i]),
        onEdit: () => _editProduct(pending[i]),
      ),
    );
  }

  Widget _buildPublishedTab() {
    final approved = _approvedProducts;
    if (approved.isEmpty) {
      return const Center(
        child: Text('Aucune annonce publiée',
            style: TextStyle(color: AppTheme.textGrey, fontSize: 16)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: approved.length,
      itemBuilder: (_, i) {
        final p = approved[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: AppTheme.cardShadow,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProductDetailScreen(product: p),
                ),
              ),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _buildImg(p.imageUrl, width: 64, height: 64),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: AppTheme.textDark),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 3),
                          Text(AppTheme.formatPrice(p.price),
                              style: const TextStyle(
                                  color: AppTheme.priceRed,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13)),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(p.category,
                                style: const TextStyle(
                                    fontSize: 10,
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      children: [
                        SizedBox(
                          height: 32,
                          child: OutlinedButton(
                            onPressed: () => _editProduct(p),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppTheme.primary,
                              side: BorderSide(
                                  color: AppTheme.primary.withOpacity(0.4)),
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              textStyle: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(S.of(context).categoryBtn),
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 32,
                          child: ElevatedButton(
                            onPressed: () => _deleteProduct(p),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              textStyle: const TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(S.of(context).deleteBtn),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUsersTab() {
    final users = _users;
    if (users.isEmpty) {
      return const Center(
        child: Text('Aucun utilisateur',
            style: TextStyle(color: AppTheme.textGrey, fontSize: 16)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      itemBuilder: (_, i) => _UserCard(
        user: users[i],
        onBlock: () async {
          await _data.blockUser(users[i].id);
          await _loadAll();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Utilisateur bloqué 🚫'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ));
        },
        onUnblock: () async {
          await _data.unblockUser(users[i].id);
          await _loadAll();
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Utilisateur débloqué ✅'),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ));
        },
        onWarn: () => _warnUser(users[i]),
      ),
    );
  }

  Widget _buildAlertsTab() {
    final alerts = _adminAlerts;
    if (alerts.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_off_outlined,
                size: 64, color: AppTheme.textGrey),
            SizedBox(height: 16),
            Text('Aucune alerte',
                style: TextStyle(
                    color: AppTheme.textGrey, fontSize: 16)),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: alerts.length,
      itemBuilder: (_, i) {
        final n = alerts[i];
        final isUnread = !n.isRead;
        final isExpiry = n.type == 'admin_expiry';
        final accentColor = isExpiry ? AppTheme.warning : AppTheme.priceRed;
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isUnread
                ? accentColor.withOpacity(0.04)
                : AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isUnread
                  ? accentColor.withOpacity(isExpiry ? 0.25 : 0.15)
                  : AppTheme.divider,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isUnread
                      ? accentColor.withOpacity(0.12)
                      : AppTheme.textGrey.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isExpiry
                      ? Icons.timer_off_rounded
                      : isUnread
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_outline,
                  color: isUnread ? accentColor : AppTheme.textGrey,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isExpiry)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.warning.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'EXPIRATION',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.warning,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        Expanded(
                          child: Text(
                            n.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      n.body,
                      style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMid,
                          height: 1.4),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _timeAgo(n.createdAt),
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textGrey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours} h';
    if (diff.inDays == 1) return 'Hier';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays} jours';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        actions: [
          SizedBox(
            width: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => NotificationsScreen(
                          userId: SupabaseService().currentUser?.id ?? ''),
                    ),
                  ),
                ),
                if (_unreadCount > 0)
                  Positioned(
                    top: 8,
                    right: 6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: const BoxDecoration(
                        color: AppTheme.priceRed,
                        shape: BoxShape.circle,
                      ),
                      constraints:
                          const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        _unreadCount > 9 ? '9+' : '$_unreadCount',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
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
                  Text(S.of(context).pendingTab),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.warning.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_pendingProducts.length}',
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.warning),
                    ),
                  ),
                ],
              ),
            ),
            Tab(text: S.of(context).publishedTab),
            Tab(text: S.of(context).usersTab),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(S.of(context).subRequestsTab),
                  const SizedBox(width: 6),
                  Builder(builder: (ctx) {
                    final count = _subRequests.length;
                    if (count == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$count',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary)),
                    );
                  }),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Alertes'),
                  const SizedBox(width: 6),
                  Builder(builder: (ctx) {
                    final count = _adminAlerts.where((n) => !n.isRead).length;
                    if (count == 0) return const SizedBox.shrink();
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.priceRed.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$count',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.priceRed)),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingTab(),
          _buildPublishedTab(),
          _buildUsersTab(),
          _buildSubscriptionsTab(),
          _buildAlertsTab(),
        ],
      ),
    );
  }
}

class _PendingProductCard extends StatelessWidget {
  final Product product;
  final Widget Function(String url, {double? width, double? height, BoxFit fit}) buildImg;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onEdit;

  const _PendingProductCard({
    required this.product,
    required this.buildImg,
    required this.onApprove,
    required this.onReject,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final p = product;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductDetailScreen(product: p),
            ),
          ),
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: buildImg(p.imageUrl, width: double.infinity, height: 180),
              ),
              Builder(
                builder: (context) {
                  final images = [
                    p.imageUrl,
                    if (p.imageUrl2 != null && p.imageUrl2!.isNotEmpty) p.imageUrl2!,
                    if (p.imageUrl3 != null && p.imageUrl3!.isNotEmpty) p.imageUrl3!,
                  ];
                  if (images.length <= 1) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                    child: SizedBox(
                      height: 50,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: images.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, idx) {
                          final imgUrl = images[idx];
                          return GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => _ProofViewer(imagePath: imgUrl),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.divider, width: 1.5),
                                ),
                                child: buildImg(imgUrl, width: 50, height: 50),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        p.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppTheme.textDark),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        p.category,
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  AppTheme.formatPrice(p.price),
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.priceRed),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person_outline, size: 14, color: AppTheme.textGrey),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        p.sellerName,
                        style: const TextStyle(fontSize: 13, color: AppTheme.textMid),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.phone_outlined, size: 14, color: AppTheme.textGrey),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        p.sellerPhone,
                        style: const TextStyle(fontSize: 13, color: AppTheme.textMid),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (p.paymentProofPath != null) ...[
                  OutlinedButton.icon(
                    icon: const Icon(Icons.receipt_long_outlined, size: 16),
                    label: Text(S.of(context).seeProof),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _ProofViewer(imagePath: p.paymentProofPath!),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textMid,
                      side: const BorderSide(color: AppTheme.divider),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onEdit,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textDark,
                          side: const BorderSide(color: AppTheme.divider),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          textStyle: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        child: Text(S.of(context).editBtn),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          textStyle: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                        ),
                        child: Text(S.of(context).rejectBtn),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onApprove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          textStyle: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                          elevation: 0,
                        ),
                        child: Text(S.of(context).approveBtn),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ));
  }
}

class _UserCard extends StatelessWidget {
  final AppUser user;
  final VoidCallback onBlock;
  final VoidCallback onUnblock;
  final VoidCallback onWarn;

  const _UserCard({
    required this.user,
    required this.onBlock,
    required this.onUnblock,
    required this.onWarn,
  });

  Color _statusColor(UserStatus s) => switch (s) {
        UserStatus.active => AppTheme.success,
        UserStatus.blocked => Colors.red,
        UserStatus.warned => AppTheme.warning,
      };

  String _statusLabel(UserStatus s) => switch (s) {
        UserStatus.active => 'Actif',
        UserStatus.blocked => 'Bloqué',
        UserStatus.warned => 'Averti',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.primary.withOpacity(0.12),
                child: Text(
                  user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                  style: const TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppTheme.textDark),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textGrey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(user.status).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _statusLabel(user.status),
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _statusColor(user.status)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.phone_outlined, size: 13, color: AppTheme.textGrey),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  user.phone,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMid),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: user.subscription == SubscriptionType.monthly
                      ? AppTheme.primary.withOpacity(0.1)
                      : AppTheme.divider,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  user.subscription == SubscriptionType.monthly ? 'Abonné' : 'Gratuit',
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: user.subscription == SubscriptionType.monthly
                          ? AppTheme.primary
                          : AppTheme.textGrey),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onWarn,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.warning,
                    side: BorderSide(color: AppTheme.warning.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    textStyle:
                        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  child: const Text('Avertir'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: user.status == UserStatus.blocked
                    ? ElevatedButton(
                        onPressed: onUnblock,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 0,
                          textStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Débloquer'),
                      )
                    : ElevatedButton(
                        onPressed: onBlock,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 0,
                          textStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        child: const Text('Bloquer'),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditProductDialog extends StatefulWidget {
  final Product product;
  final DataService data;

  const _EditProductDialog({required this.product, required this.data});

  @override
  State<_EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<_EditProductDialog> {
  late String _selectedCategory;

  static const List<String> _categories = [
    'Téléphones',
    'Ordinateurs',
    'Montres',
    'Électroménager',
    'Meubles',
    'Vêtements',
    'Véhicules',
    'Autres',
  ];

  @override
  void initState() {
    super.initState();
    _selectedCategory = _categories.contains(widget.product.category)
        ? widget.product.category
        : _categories.first;
  }

  void _save() {
    widget.data.updateProductCategory(
      widget.product.id,
      _selectedCategory,
    );
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1A000000),
              blurRadius: 40,
              offset: Offset(0, 10),
            ),
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.category_rounded,
                      color: AppTheme.primary, size: 30),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Modifier la catégorie',
                  style: GoogleFonts.inter(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.inventory_2_outlined,
                        size: 18, color: AppTheme.textGrey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.product.name,
                        style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Catégorie',
                style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textGrey),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppTheme.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.primary, width: 1.5),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedCategory,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: AppTheme.primary),
                    style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark),
                    items: _categories
                        .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c),
                            ))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedCategory = v);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.textDark,
                        side: const BorderSide(color: AppTheme.divider),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size(0, 48),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size(0, 48),
                      ),
                      child: const Text('Enregistrer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProofViewer extends StatelessWidget {
  final String imagePath;
  const _ProofViewer({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Preuve de paiement',
            style: TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          child: imagePath.startsWith('lib/assets/')
              ? Image.asset(imagePath, fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.broken_image,
                      color: Colors.white54, size: 64))
              : imagePath.startsWith('/')
                  ? Image.file(File(imagePath), fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image,
                          color: Colors.white54, size: 64))
                  : Image.network(imagePath, fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.broken_image,
                          color: Colors.white54, size: 64)),
        ),
      ),
    );
  }
}

class _SubscriptionRequestCard extends StatelessWidget {
  final SubscriptionRequest request;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _SubscriptionRequestCard({
    required this.request,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primary.withOpacity(0.12),
              child: Text(
                request.userName.isNotEmpty
                    ? request.userName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(request.userName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppTheme.textDark)),
                  const SizedBox(height: 2),
                  Text(request.userPhone,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textGrey)),
                  if (request.location != null)
                    Text(request.location!,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textMid)),
                ],
              ),
            ),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            if (request.proofImagePath.isNotEmpty) ...[
              OutlinedButton.icon(
                icon: const Icon(Icons.receipt_long_outlined, size: 16),
                label: const Text('Voir preuve'),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) =>
                        _ProofViewer(imagePath: request.proofImagePath))),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.textMid,
                  side: const BorderSide(color: AppTheme.divider),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  textStyle: const TextStyle(fontSize: 13),
                ),
              ),
              const Spacer(),
            ],
            ElevatedButton(
              onPressed: onReject,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                textStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                elevation: 0,
              ),
              child: const Text('Refuser'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: onApprove,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                textStyle:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                elevation: 0,
              ),
              child: const Text('Activer'),
            ),
          ],
        ),
      ],
    ),
  );
  }
}
