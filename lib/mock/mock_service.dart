import 'dart:async';
import '../models/models.dart';

// ─── Real in-memory auth ───────────────────────────────────────────────────────
// Users are stored with their passwords. Login verifies credentials, register
// prevents duplicate emails. All in RAM — no backend needed.

class _StoredUser {
  final AppUser user;
  final String password;
  const _StoredUser({required this.user, required this.password});
}

AppUser? _currentUser;
bool _isLoggedIn = false;
bool _isAdmin = false;

final Map<String, _StoredUser> _userStore = {
  'hdr119': _StoredUser(
    user: AppUser(
      id: 'hdr119',
      name: 'hadrami119',
      email: 'hdr119',
      phone: '+222 44 00 00 00',
      role: UserRole.admin,
      status: UserStatus.active,
      subscription: SubscriptionType.monthly,
    ),
    password: 'admin123',
  ),
  'admin@souq.mr': _StoredUser(
    user: AppUser(
      id: 'hdr119',
      name: 'hadrami119',
      email: 'admin@souq.mr',
      phone: '+222 44 00 00 00',
      role: UserRole.admin,
      status: UserStatus.active,
      subscription: SubscriptionType.monthly,
    ),
    password: 'admin123',
  ),
  'ahmed@test.mr': _StoredUser(
    user: AppUser(
      id: 'seller-1',
      name: 'Ahmed Diallo',
      email: 'ahmed@test.mr',
      phone: '+222 22 33 44 55',
      role: UserRole.seller,
      status: UserStatus.active,
      subscription: SubscriptionType.monthly,
      subscriptionExpiry: DateTime.now().add(const Duration(days: 180)),
    ),
    password: '123456',
  ),
  'fatima@test.mr': _StoredUser(
    user: AppUser(
      id: 'seller-2',
      name: 'Fatima Ould',
      email: 'fatima@test.mr',
      phone: '+222 33 44 55 66',
      role: UserRole.seller,
      status: UserStatus.active,
      subscription: SubscriptionType.none,
    ),
    password: '123456',
  ),
  'moussa@test.mr': _StoredUser(
    user: AppUser(
      id: 'seller-3',
      name: 'Moussa Sy',
      email: 'moussa@test.mr',
      phone: '+222 44 55 66 77',
      role: UserRole.seller,
      status: UserStatus.warned,
      subscription: SubscriptionType.none,
    ),
    password: '123456',
  ),
};

AppUser? get mockCurrentUser => _currentUser;
bool get mockIsLoggedIn => _isLoggedIn;
bool get mockIsAdmin => _isAdmin;
bool get mockIsSeller => _isLoggedIn;

void _setUser(AppUser user) {
  _currentUser = user;
  _isLoggedIn = true;
  _isAdmin = user.role == UserRole.admin;
}

void _clearUser() {
  _currentUser = null;
  _isLoggedIn = false;
  _isAdmin = false;
}

// ─── Mock Data ─────────────────────────────────────────────────────────────────

const List<Map<String, dynamic>> categories = [
  {'name': 'Tout', 'icon': '🛒'},
  {'name': 'Téléphones', 'icon': '📱'},
  {'name': 'Ordinateurs', 'icon': '💻'},
  {'name': 'Montres', 'icon': '⌚'},
  {'name': 'Électroménager', 'icon': '🏠'},
  {'name': 'Meubles', 'icon': '🪑'},
  {'name': 'Vêtements', 'icon': '👕'},
  {'name': 'Véhicules', 'icon': '🚗'},
  {'name': 'Autres', 'icon': '📦'},
];

final List<Product> _mockProducts = [
  Product(
    id: 'p1',
    name: 'iPhone 14 Pro Max 256Go',
    price: 850000,
    category: 'Téléphones',
    description: 'iPhone 14 Pro Max en excellent état. Couleur violet profond. Acheté en janvier 2024, utilisé avec soin. Batterie à 92%. Livré avec chargeur et câble d\'origine.',
    imageUrl: 'lib/assets/images/iphone14_pro_max.jpg',
    sellerId: 'seller-1',
    sellerName: 'Ahmed Diallo',
    sellerPhone: '+222 22 33 44 55',
    sellerWhatsApp: '+22222334455',
    sellerFacebook: 'https://facebook.com/ahmed',
    sellerLocation: 'Nouakchott, Tevragh-Zeina',
    status: ProductStatus.approved,
    delivery: DeliveryOption.available,
    deliveryPrice: 5000,
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    paymentProofPath: null,
  ),
  Product(
    id: 'p2',
    name: 'MacBook Air M2 13" 16Go RAM',
    price: 650000,
    category: 'Ordinateurs',
    description: 'MacBook Air avec puce M2, 16Go de RAM unifié, 256Go SSD. Argent. Utilisé pour le télétravail uniquement. Batterie cycle count < 50.',
    imageUrl: 'lib/assets/images/macbook_air_m2.jpg',
    sellerId: 'seller-1',
    sellerName: 'Ahmed Diallo',
    sellerPhone: '+222 22 33 44 55',
    sellerWhatsApp: '+22222334455',
    sellerLocation: 'Nouakchott',
    status: ProductStatus.approved,
    delivery: DeliveryOption.available,
    deliveryPrice: 3000,
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
  ),
  Product(
    id: 'p3',
    name: 'PlayStation 5 Édition Standard',
    price: 350000,
    category: 'Autres',
    description: 'PlayStation 5 en excellent état, avec manette DualSense blanche, câble HDMI et chargeur. Très peu utilisée, comme neuve.',
    imageUrl: 'lib/assets/images/playstation_5.jpg',
    sellerId: 'seller-2',
    sellerName: 'Fatima Ould',
    sellerPhone: '+222 33 44 55 66',
    sellerWhatsApp: '+22233445566',
    sellerLocation: 'Nouadhibou',
    status: ProductStatus.approved,
    delivery: DeliveryOption.notAvailable,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  Product(
    id: 'p4',
    name: 'Table à manger 6 places en bois massif',
    price: 220000,
    category: 'Meubles',
    description: 'Table à manger rectangulaire en bois massif, 6 places assises. Très bon état, légères marques d\'usage. Dimensions : 180x90 cm.',
    imageUrl: 'lib/assets/images/table_a_manger_6_places.jpg',
    sellerId: 'seller-1',
    sellerName: 'Ahmed Diallo',
    sellerPhone: '+222 22 33 44 55',
    sellerLocation: 'Nouakchott',
    status: ProductStatus.approved,
    delivery: DeliveryOption.available,
    deliveryPrice: 10000,
    createdAt: DateTime.now().subtract(const Duration(days: 14)),
  ),
  Product(
    id: 'p5',
    name: 'Canapé 3 places Cuir',
    price: 95000,
    category: 'Meubles',
    description: 'Canapé 3 places en cuir marron foncé. Très confortable, assis 5 fois maximum. Comme neuf.',
    imageUrl: 'lib/assets/images/canape_moderne_5_places.jpg',
    sellerId: 'seller-3',
    sellerName: 'Moussa Sy',
    sellerPhone: '+222 44 55 66 77',
    sellerLocation: 'Nouakchott, Ksar',
    status: ProductStatus.pending,
    delivery: DeliveryOption.notAvailable,
    createdAt: DateTime.now().subtract(const Duration(hours: 6)),
    paymentProofPath: 'https://picsum.photos/seed/receipt1/400/400',
  ),
  Product(
    id: 'p6',
    name: 'Yamaha YBR 125',
    price: 850000,
    category: 'Véhicules',
    description: 'Yamaha YBR 125, année 2022, 15000 km. Première main, entretien régulier. Consommation très faible, idéale pour ville.',
    imageUrl: 'lib/assets/images/yamaha_ybr_125.jpg',
    sellerId: 'seller-2',
    sellerName: 'Fatima Ould',
    sellerPhone: '+222 33 44 55 66',
    status: ProductStatus.pending,
    delivery: DeliveryOption.available,
    deliveryPrice: 2000,
    createdAt: DateTime.now().subtract(const Duration(hours: 12)),
    paymentProofPath: 'https://picsum.photos/seed/receipt2/400/400',
  ),
  Product(
    id: 'p7',
    name: 'Toyota Hilux 2020 Double Cabine',
    price: 4500000,
    category: 'Véhicules',
    description: 'Toyota Hilux 2020, double cabine, climatisation, 4x4. 80000 km. Entretien régulier. Première main.',
    imageUrl: 'lib/assets/images/toyota_hilux_double_cabine.jpg',
    sellerId: 'seller-3',
    sellerName: 'Moussa Sy',
    sellerPhone: '+222 44 55 66 77',
    sellerLocation: 'Nouakchott',
    status: ProductStatus.rejected,
    delivery: DeliveryOption.notAvailable,
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    adminNote: 'Photos insuffisantes. Veuillez fournir des photos de l\'intérieur et du moteur.',
  ),
  Product(
    id: 'p8',
    name: 'Samsung Galaxy S24 Ultra',
    price: 520000,
    category: 'Téléphones',
    description: 'Samsung Galaxy S24 Ultra 512Go. Couleur titane noir. Sous garantie jusqu\'en 2026. État neuf.',
    imageUrl: 'lib/assets/images/samsung_galaxy_s24_ultra.jpg',
    sellerId: 'seller-2',
    sellerName: 'Fatima Ould',
    sellerPhone: '+222 33 44 55 66',
    sellerWhatsApp: '+22233445566',
    sellerLocation: 'Nouadhibou',
    status: ProductStatus.sold,
    delivery: DeliveryOption.available,
    deliveryPrice: 4000,
    createdAt: DateTime.now().subtract(const Duration(days: 20)),
  ),
  Product(
    id: 'p9',
    name: 'HP EliteBook 840 G8 i7 16Go',
    price: 450000,
    category: 'Ordinateurs',
    description: 'HP EliteBook 840 G8, Intel Core i7 11ème génération, 16Go RAM, 512Go SSD. Écran 14" Full HD. Excellent état professionnel.',
    imageUrl: 'lib/assets/images/hp_elitebook_840_g8.jpg',
    sellerId: 'seller-1',
    sellerName: 'Ahmed Diallo',
    sellerPhone: '+222 22 33 44 55',
    sellerLocation: 'Nouakchott',
    status: ProductStatus.approved,
    delivery: DeliveryOption.available,
    deliveryPrice: 3000,
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
  ),
  Product(
    id: 'p10',
    name: 'Toyota Prado 2020 TX.L',
    price: 8500000,
    category: 'Véhicules',
    description: 'Toyota Land Cruiser Prado 2020 TX.L, 7 places, climatisation, 4x4. 60000 km. Entretien concessionnaire. Première main.',
    imageUrl: 'lib/assets/images/toyota_prado_2020.jpg',
    sellerId: 'seller-3',
    sellerName: 'Moussa Sy',
    sellerPhone: '+222 44 55 66 77',
    sellerLocation: 'Nouakchott',
    status: ProductStatus.approved,
    delivery: DeliveryOption.notAvailable,
    createdAt: DateTime.now().subtract(const Duration(days: 15)),
  ),
];

List<AppUser> get _mockUsers =>
    _userStore.values.map((s) => s.user).toList();

final List<AppNotification> _mockNotifications = [
  AppNotification(
    id: 'n1',
    userId: 'hdr119',
    title: 'Nouvelle annonce en attente',
    body: 'Moussa Sy a soumis une annonce "Canapé 3 places Cuir" en attente de validation.',
    type: 'admin_alert',
    createdAt: DateTime.now().subtract(const Duration(hours: 6)),
  ),
  AppNotification(
    id: 'n2',
    userId: 'hdr119',
    title: 'Nouvelle annonce en attente',
    body: 'Fatima Ould a soumis une annonce "Yamaha YBR 125" en attente de validation.',
    type: 'admin_alert',
    createdAt: DateTime.now().subtract(const Duration(hours: 12)),
  ),
  AppNotification(
    id: 'n3',
    userId: 'hdr119',
    title: 'Annonce approuvée ✅',
    body: 'L\'annonce "iPhone 14 Pro Max" de Ahmed Diallo a été approuvée.',
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    isRead: true,
  ),
  AppNotification(
    id: 'n4',
    userId: 'hdr119',
    title: 'Demande d\'abonnement',
    body: 'Fatima Ould a demandé un abonnement mensuel.',
    type: 'admin_alert',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    isRead: true,
  ),
  AppNotification(
    id: 'n5',
    userId: 'seller-1',
    title: 'Annonce approuvée ✅',
    body: 'Votre annonce "MacBook Air M2" a été approuvée et est maintenant visible.',
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
    isRead: true,
  ),
  AppNotification(
    id: 'n6',
    userId: 'seller-1',
    title: 'Nouveau message',
    body: 'Un acheteur vous a envoyé un message concernant "iPhone 14 Pro Max".',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    isRead: false,
  ),
  AppNotification(
    id: 'n7',
    userId: 'seller-3',
    title: 'Annonce refusée ❌',
    body: 'Votre annonce "Toyota Hilux 2020" a été refusée. Motif : Photos insuffisantes.',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    isRead: false,
  ),
];

final List<SubscriptionRequest> _mockSubRequests = [
  SubscriptionRequest(
    id: 'sub-1',
    userId: 'seller-2',
    userName: 'Fatima Ould',
    userPhone: '+222 33 44 55 66',
    proofImagePath: 'https://picsum.photos/seed/receipt1/400/400',
    location: 'Nouadhibou',
    status: SubscriptionRequestStatus.pending,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
];

// ─── Mode UI helper ────────────────────────────────────────────────────────────

String get modeLabel => '🔷 Mode UI';

// ─── Mock Service (remplace SupabaseService) ────────────────────────────────────

class SupabaseService {
  static final SupabaseService _i = SupabaseService._();
  factory SupabaseService() => _i;
  SupabaseService._();

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _isAdmin;
  bool get isSeller => _isLoggedIn;

  static const List<Map<String, dynamic>> categories = [
    {'name': 'Tout', 'icon': '🛒'},
    {'name': 'Téléphones', 'icon': '📱'},
    {'name': 'Ordinateurs', 'icon': '💻'},
    {'name': 'Montres', 'icon': '⌚'},
    {'name': 'Électroménager', 'icon': '🏠'},
    {'name': 'Meubles', 'icon': '🪑'},
    {'name': 'Vêtements', 'icon': '👕'},
    {'name': 'Véhicules', 'icon': '🚗'},
    {'name': 'Autres', 'icon': '📦'},
  ];

  Future<void> init() async {}

  Future<AppUser> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final key = email.trim().toLowerCase();
    final stored = _userStore[key];
    if (stored == null || stored.password != password) {
      throw Exception('wrong_credentials');
    }
    if (stored.user.status == UserStatus.blocked) {
      throw Exception('account_blocked');
    }
    _setUser(stored.user);
    return _currentUser!;
  }

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final key = email.trim().toLowerCase();
    if (_userStore.containsKey(key)) {
      throw Exception('user_already_exists');
    }
    final newUser = AppUser(
      id: 'seller-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      phone: phone,
      role: UserRole.seller,
      status: UserStatus.active,
    );
    _userStore[key] = _StoredUser(user: newUser, password: password);
    _setUser(newUser);
    return _currentUser!;
  }

  Future<void> logout() async {
    _clearUser();
  }

  Future<void> reloadProfile() async {}

  // ── Products ─────────────────────────────────────────────────────────────────

  Future<List<Product>> getApprovedProducts({String? category, String? search}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    var list = _mockProducts.where((p) => p.status == ProductStatus.approved).toList();
    if (category != null && category != 'Tout') {
      list = list.where((p) => p.category == category).toList();
    }
    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      list = list.where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.category.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  Future<List<Product>> getPendingProducts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockProducts.where((p) => p.status == ProductStatus.pending).toList();
  }

  Future<List<Product>> getMyProducts({String? status}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final sellerId = _currentUser?.id ?? '';
    var list = _mockProducts.where((p) => p.sellerId == sellerId).toList();
    if (status != null) {
      final s = productStatusFromString(status);
      list = list.where((p) => p.status == s).toList();
    }
    return list;
  }

  Future<List<Product>> getSellerProducts(String sellerId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockProducts.where((p) => p.sellerId == sellerId).toList();
  }

  String _extractPath(dynamic file) {
    if (file == null) return '';
    if (file is String) return file;
    try {
      final f = file as dynamic;
      final path = f?.path;
      if (path is String && path.isNotEmpty) return path;
    } catch (_) {}
    return '';
  }

  Future<Map<String, dynamic>> createProductWithFiles({
    required dynamic mainImage,
    dynamic image2,
    dynamic image3,
    required dynamic paymentProof,
    required Map<String, dynamic> data,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final mainPath = _extractPath(mainImage);
    final proofPath = _extractPath(paymentProof);
    final newProduct = Product(
      id: 'p-mock-${DateTime.now().millisecondsSinceEpoch}',
      name: data['name'] as String? ?? 'Produit',
      price: double.tryParse(data['price']?.toString() ?? '') ?? 0,
      category: data['category'] as String? ?? 'Autres',
      description: data['description'] as String?,
      imageUrl: mainPath.isNotEmpty ? mainPath : 'https://picsum.photos/seed/placeholder/400/400',
      imageUrl2: _extractPath(image2),
      imageUrl3: _extractPath(image3),
      sellerId: _currentUser?.id ?? 'unknown',
      sellerName: _currentUser?.name ?? 'Vendeur',
      sellerPhone: _currentUser?.phone ?? '',
      sellerWhatsApp: data['seller_whatsapp'] as String?,
      sellerLocation: _currentUser?.location,
      status: ProductStatus.pending,
      delivery: data['delivery'] == 'available' ? DeliveryOption.available : DeliveryOption.notAvailable,
      deliveryPrice: data['delivery_price'] != null ? double.tryParse(data['delivery_price'].toString()) : null,
      createdAt: DateTime.now(),
      paymentProofPath: proofPath.isNotEmpty ? proofPath : null,
    );
    _mockProducts.insert(0, newProduct);
    return {'id': newProduct.id};
  }

  Future<void> updateProductStatus(String productId, ProductStatus status, {String? adminNote}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _mockProducts.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      final p = _mockProducts[idx];
      _mockProducts[idx] = p.copyWith(status: status, adminNote: adminNote);
    }
  }

  Future<void> updateProductCategory(String productId, String category) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _mockProducts.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      final p = _mockProducts[idx];
      _mockProducts[idx] = p.copyWith(category: category);
    }
  }

  Future<void> deleteProduct(String productId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockProducts.removeWhere((p) => p.id == productId);
  }

  Future<void> markProductAsSold(String productId) async {
    await updateProductStatus(productId, ProductStatus.sold);
  }

  // ── Users (admin) ────────────────────────────────────────────────────────────

  Future<List<AppUser>> getAllUsers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockUsers;
  }

  Future<void> blockUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (final entry in _userStore.entries) {
      if (entry.value.user.id == userId) {
        _userStore[entry.key] = _StoredUser(
          user: entry.value.user.copyWith(status: UserStatus.blocked),
          password: entry.value.password,
        );
        break;
      }
    }
  }

  Future<void> unblockUser(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (final entry in _userStore.entries) {
      if (entry.value.user.id == userId) {
        _userStore[entry.key] = _StoredUser(
          user: entry.value.user.copyWith(status: UserStatus.active),
          password: entry.value.password,
        );
        break;
      }
    }
  }

  Future<void> warnUser(String userId, String message) async {
    await Future.delayed(const Duration(milliseconds: 200));
    for (final entry in _userStore.entries) {
      if (entry.value.user.id == userId) {
        _userStore[entry.key] = _StoredUser(
          user: entry.value.user.copyWith(status: UserStatus.warned),
          password: entry.value.password,
        );
        break;
      }
    }
  }

  // ── Notifications ────────────────────────────────────────────────────────────

  Future<List<AppNotification>> getNotifications(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockNotifications
        .where((n) => n.userId == userId)
        .toList();
  }

  Future<int> unreadCount(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockNotifications
        .where((n) => n.userId == userId && !n.isRead)
        .length;
  }

  Future<void> addNotification(AppNotification notification) async {
    _mockNotifications.insert(0, notification);
  }

  Future<void> markAllRead(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    for (var i = 0; i < _mockNotifications.length; i++) {
      if (_mockNotifications[i].userId == userId && !_mockNotifications[i].isRead) {
        _mockNotifications[i] = _mockNotifications[i].copyWith(isRead: true);
      }
    }
  }

  // ── Subscriptions ────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> requestSubscriptionWithFile({
    required dynamic paymentProof,
    String? location,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final proofPath = _extractPath(paymentProof);
    _mockSubRequests.insert(0, SubscriptionRequest(
      id: 'sub-mock-${DateTime.now().millisecondsSinceEpoch}',
      userId: _currentUser?.id ?? '',
      userName: _currentUser?.name ?? '',
      userPhone: _currentUser?.phone ?? '',
      proofImagePath: proofPath.isNotEmpty ? proofPath : 'https://picsum.photos/seed/receipt/400/400',
      location: location,
      status: SubscriptionRequestStatus.pending,
      createdAt: DateTime.now(),
    ));
    return {};
  }

  Future<List<SubscriptionRequest>> getPendingSubscriptions() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_mockSubRequests);
  }

  Future<bool> hasPendingSubscription(String userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mockSubRequests.any((s) => s.userId == userId && s.status == SubscriptionRequestStatus.pending);
  }

  Future<void> approveSubscription(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _mockSubRequests.indexWhere((s) => s.id == requestId);
    if (idx != -1) {
      _mockSubRequests[idx] = _mockSubRequests[idx].copyWith(status: SubscriptionRequestStatus.approved);
      final userId = _mockSubRequests[idx].userId;
      for (final entry in _userStore.entries) {
        if (entry.value.user.id == userId) {
          _userStore[entry.key] = _StoredUser(
            user: entry.value.user.copyWith(
              subscription: SubscriptionType.monthly,
              subscriptionExpiry: DateTime.now().add(const Duration(days: 30)),
            ),
            password: entry.value.password,
          );
          break;
        }
      }
    }
  }

  Future<void> rejectSubscription(String requestId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _mockSubRequests.indexWhere((s) => s.id == requestId);
    if (idx != -1) {
      _mockSubRequests[idx] = _mockSubRequests[idx].copyWith(status: SubscriptionRequestStatus.rejected);
    }
  }

  // ── Subscription Expiry Check ──────────────────────────────────────────────

  Future<List<String>> checkSubscriptionExpiry() async {
    await Future.delayed(const Duration(milliseconds: 300));
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final expiredUserIds = <String>[];

    for (final entry in _userStore.entries) {
      final user = entry.value.user;
      if (user.subscription == SubscriptionType.monthly &&
          user.subscriptionExpiry != null &&
          user.subscriptionExpiry!.isBefore(now)) {
        expiredUserIds.add(user.id);

        final alreadyNotified = _mockNotifications.any((n) =>
            n.userId == 'hdr119' &&
            n.type == 'admin_expiry' &&
            n.body.contains(user.name) &&
            n.createdAt.isAfter(todayStart));

        if (!alreadyNotified) {
          _mockNotifications.insert(0, AppNotification(
            id: 'exp-${now.millisecondsSinceEpoch}-admin',
            userId: 'hdr119',
            title: 'Abonnement expiré ⏰',
            body: 'L\'abonnement de ${user.name} a expiré. Ce vendeur doit renouveler pour être réactivé.',
            type: 'admin_expiry',
            createdAt: now,
          ));

          _mockNotifications.insert(0, AppNotification(
            id: 'exp-${now.millisecondsSinceEpoch}-seller-${user.id}',
            userId: user.id,
            title: 'Abonnement expiré ❌',
            body: 'Votre abonnement a expiré. Si vous souhaitez continuer à publier, veuillez faire une nouvelle demande d\'abonnement.',
            type: 'subscription_expired',
            createdAt: now,
          ));
        }

        _userStore[entry.key] = _StoredUser(
          user: user.copyWith(subscription: SubscriptionType.none),
          password: entry.value.password,
        );
      }
    }

    if (expiredUserIds.contains(_currentUser?.id)) {
      for (final entry in _userStore.entries) {
        if (entry.value.user.id == _currentUser?.id) {
          _currentUser = entry.value.user;
          break;
        }
      }
    }

    return expiredUserIds;
  }

  // ── Storage ──────────────────────────────────────────────────────────────────

  Future<String> uploadFile({required dynamic file, required String bucket, required String path}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return 'https://picsum.photos/seed/upload/400/400';
  }
}

// ─── DataService (alias) ───────────────────────────────────────────────────────

class DataService {
  static final DataService _i = DataService._();
  factory DataService() => _i;
  DataService._();

  final _s = SupabaseService();

  Future<List<Product>> getApprovedProducts({String? category, String? search}) =>
      _s.getApprovedProducts(category: category, search: search);

  Future<List<Product>> getPendingProducts() => _s.getPendingProducts();

  Future<List<Product>> getMyProducts({String? status}) => _s.getMyProducts(status: status);

  Future<List<Product>> getSellerProducts(String id) => _s.getSellerProducts(id);

  Future<Map<String, dynamic>> createProductWithFiles({
    required dynamic mainImage, dynamic image2, dynamic image3,
    required dynamic paymentProof, required Map<String, dynamic> data,
  }) => _s.createProductWithFiles(mainImage: mainImage, image2: image2, image3: image3, paymentProof: paymentProof, data: data);

  Future<void> updateProductStatus(String id, ProductStatus status, {String? adminNote}) =>
      _s.updateProductStatus(id, status, adminNote: adminNote);

  Future<void> updateProductCategory(String id, String cat) =>
      _s.updateProductCategory(id, cat);

  Future<void> deleteProduct(String id) => _s.deleteProduct(id);

  Future<void> markProductAsSold(String id) => _s.markProductAsSold(id);

  Future<List<AppUser>> getAllUsers() => _s.getAllUsers();

  Future<void> blockUser(String id) => _s.blockUser(id);

  Future<void> unblockUser(String id) => _s.unblockUser(id);

  Future<void> warnUser(String id, String msg) => _s.warnUser(id, msg);

  Future<List<AppNotification>> getNotifications(String userId) =>
      _s.getNotifications(userId);

  Future<int> unreadCount(String userId) => _s.unreadCount(userId);

  Future<void> addNotification(AppNotification n) => _s.addNotification(n);

  Future<void> markAllRead(String userId) => _s.markAllRead(userId);

  Future<List<SubscriptionRequest>> getPendingSubscriptions() =>
      _s.getPendingSubscriptions();

  Future<bool> hasPendingSubscription(String id) =>
      _s.hasPendingSubscription(id);

  Future<void> approveSubscription(String id) => _s.approveSubscription(id);

  Future<void> rejectSubscription(String id) => _s.rejectSubscription(id);

  Future<List<String>> checkSubscriptionExpiry() => _s.checkSubscriptionExpiry();

  Future<String> uploadFile({
    required dynamic file, required String bucket, required String path,
  }) => _s.uploadFile(file: file, bucket: bucket, path: path);

  static const List<Map<String, dynamic>> categories = [
    {'name': 'Tout', 'icon': '🛒'},
    {'name': 'Téléphones', 'icon': '📱'},
    {'name': 'Ordinateurs', 'icon': '💻'},
    {'name': 'Montres', 'icon': '⌚'},
    {'name': 'Électroménager', 'icon': '🏠'},
    {'name': 'Meubles', 'icon': '🪑'},
    {'name': 'Vêtements', 'icon': '👕'},
    {'name': 'Véhicules', 'icon': '🚗'},
    {'name': 'Autres', 'icon': '📦'},
  ];
}

// ─── AuthService (static alias) ─────────────────────────────────────────────────

class AuthService {
  static AppUser? get currentUser => _currentUser;
  static bool get isLoggedIn => _isLoggedIn;
  static bool get isAdmin => _isAdmin;
  static bool get isSeller => _isLoggedIn;

  static Future<void> logout() async {
    _clearUser();
  }
}

// ─── ConnectivityService (always connected) ─────────────────────────────────────

class ConnectivityService {
  static final ConnectivityService _i = ConnectivityService._();
  factory ConnectivityService() => _i;
  ConnectivityService._();

  bool get isConnected => true;
  Stream<bool> get onChanged => _alwaysConnected.stream;

  final StreamController<bool> _alwaysConnected = StreamController<bool>.broadcast();

  Future<void> init() async {
    _alwaysConnected.add(true);
  }

  void dispose() {
    _alwaysConnected.close();
  }
}
