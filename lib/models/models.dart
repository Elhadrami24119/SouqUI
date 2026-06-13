// ─── Enums ────────────────────────────────────────────────────────────────────

enum ProductStatus { pending, approved, rejected, sold }
enum DeliveryOption { available, notAvailable }
enum UserRole { seller, admin }
enum SubscriptionType { none, monthly }
enum SubscriptionRequestStatus { pending, approved, rejected }
enum UserStatus { active, blocked, warned }

// ─── Helpers ──────────────────────────────────────────────────────────────────

ProductStatus productStatusFromString(String s) => switch (s) {
      'approved' => ProductStatus.approved,
      'rejected' => ProductStatus.rejected,
      'sold' => ProductStatus.sold,
      _ => ProductStatus.pending,
    };

DeliveryOption deliveryFromString(String s) =>
    s == 'available' ? DeliveryOption.available : DeliveryOption.notAvailable;

UserRole roleFromString(String s) => switch (s) {
      'admin' => UserRole.admin,
      _ => UserRole.seller,
    };

SubscriptionType subFromString(String s) =>
    s == 'monthly' ? SubscriptionType.monthly : SubscriptionType.none;

UserStatus statusFromString(String s) => switch (s) {
      'blocked' => UserStatus.blocked,
      'warned' => UserStatus.warned,
      _ => UserStatus.active,
    };

SubscriptionRequestStatus subReqStatusFromString(String s) => switch (s) {
      'approved' => SubscriptionRequestStatus.approved,
      'rejected' => SubscriptionRequestStatus.rejected,
      _ => SubscriptionRequestStatus.pending,
    };

// ─── AppNotification ─────────────────────────────────────────────────────────

class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String? type;
  final bool isRead;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.type,
    this.isRead = false,
    required this.createdAt,
  });

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
        id: j['id'] as String,
        userId: j['user_id'] as String,
        title: j['title'] as String,
        body: j['body'] as String,
        type: j['type'] as String?,
        isRead: j['is_read'] as bool? ?? false,
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id, userId: userId, title: title, body: body,
        type: type, isRead: isRead ?? this.isRead, createdAt: createdAt,
      );
}

// ─── SubscriptionRequest ──────────────────────────────────────────────────────

class SubscriptionRequest {
  final String id;
  final String userId;
  final String userName;
  final String userPhone;
  final String proofImagePath; // URL Supabase Storage
  final String? location;
  final SubscriptionRequestStatus status;
  final DateTime createdAt;

  const SubscriptionRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.proofImagePath,
    this.location,
    this.status = SubscriptionRequestStatus.pending,
    required this.createdAt,
  });

  factory SubscriptionRequest.fromJson(Map<String, dynamic> j) =>
      SubscriptionRequest(
        id: j['id'] as String,
        userId: j['user_id'] as String,
        userName: j['user_name'] as String,
        userPhone: j['user_phone'] as String,
        proofImagePath: j['proof_url'] as String,
        location: j['location'] as String?,
        status: subReqStatusFromString(j['status'] as String? ?? 'pending'),
        createdAt: DateTime.parse(j['created_at'] as String),
      );

  SubscriptionRequest copyWith({SubscriptionRequestStatus? status}) =>
      SubscriptionRequest(
        id: id, userId: userId, userName: userName, userPhone: userPhone,
        proofImagePath: proofImagePath, location: location,
        status: status ?? this.status, createdAt: createdAt,
      );
}

// ─── Product ─────────────────────────────────────────────────────────────────

class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String? description;
  final String imageUrl;
  final String? imageUrl2;
  final String? imageUrl3;
  final String sellerId;
  final String sellerName;
  final String sellerPhone;
  final String? sellerWhatsApp;
  final String? sellerFacebook;
  final String? sellerLocation;
  final ProductStatus status;
  final DeliveryOption delivery;
  final double? deliveryPrice;
  final DateTime createdAt;
  final String? paymentProofPath;
  final String? adminNote;

  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    this.description,
    required this.imageUrl,
    this.imageUrl2,
    this.imageUrl3,
    required this.sellerId,
    required this.sellerName,
    required this.sellerPhone,
    this.sellerWhatsApp,
    this.sellerFacebook,
    this.sellerLocation,
    this.status = ProductStatus.pending,
    this.delivery = DeliveryOption.notAvailable,
    this.deliveryPrice,
    required this.createdAt,
    this.paymentProofPath,
    this.adminNote,
  });

  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'] as String,
        name: j['name'] as String,
        price: (j['price'] as num).toDouble(),
        category: j['category'] as String,
        description: j['description'] as String?,
        imageUrl: j['image_url'] as String,
        imageUrl2: j['image_url2'] as String?,
        imageUrl3: j['image_url3'] as String?,
        sellerId: j['seller_id'] as String,
        sellerName: j['seller_name'] as String,
        sellerPhone: j['seller_phone'] as String,
        sellerWhatsApp: j['seller_whatsapp'] as String?,
        sellerFacebook: j['seller_facebook'] as String?,
        sellerLocation: j['seller_location'] as String?,
        status: productStatusFromString(j['status'] as String? ?? 'pending'),
        delivery: deliveryFromString(j['delivery'] as String? ?? 'not_available'),
        deliveryPrice: j['delivery_price'] != null
            ? (j['delivery_price'] as num).toDouble()
            : null,
        createdAt: DateTime.parse(j['created_at'] as String),
        paymentProofPath: j['payment_proof'] as String?,
        adminNote: j['admin_note'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'price': price,
        'category': category,
        'description': description,
        'image_url': imageUrl,
        'image_url2': imageUrl2,
        'image_url3': imageUrl3,
        'seller_id': sellerId,
        'seller_name': sellerName,
        'seller_phone': sellerPhone,
        'seller_whatsapp': sellerWhatsApp,
        'seller_facebook': sellerFacebook,
        'seller_location': sellerLocation,
        'status': status.name,
        'delivery': delivery == DeliveryOption.available ? 'available' : 'not_available',
        'delivery_price': deliveryPrice,
        'payment_proof': paymentProofPath,
        'admin_note': adminNote,
      };

  Product copyWith({
    String? name, double? price, String? category, String? description,
    String? imageUrl, String? imageUrl2, String? imageUrl3,
    ProductStatus? status, String? adminNote, String? paymentProofPath,
  }) =>
      Product(
        id: id,
        name: name ?? this.name,
        price: price ?? this.price,
        category: category ?? this.category,
        description: description ?? this.description,
        imageUrl: imageUrl ?? this.imageUrl,
        imageUrl2: imageUrl2 ?? this.imageUrl2,
        imageUrl3: imageUrl3 ?? this.imageUrl3,
        sellerId: sellerId, sellerName: sellerName, sellerPhone: sellerPhone,
        sellerWhatsApp: sellerWhatsApp, sellerFacebook: sellerFacebook,
        sellerLocation: sellerLocation,
        status: status ?? this.status,
        delivery: delivery, deliveryPrice: deliveryPrice,
        createdAt: createdAt,
        paymentProofPath: paymentProofPath ?? this.paymentProofPath,
        adminNote: adminNote ?? this.adminNote,
      );
}

// ─── AppUser ─────────────────────────────────────────────────────────────────

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? profileImage;
  final UserStatus status;
  final SubscriptionType subscription;
  final String? location;
  final DateTime? subscriptionExpiry;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = UserRole.seller,
    this.profileImage,
    this.status = UserStatus.active,
    this.subscription = SubscriptionType.none,
    this.location,
    this.subscriptionExpiry,
  });

  factory AppUser.fromJson(Map<String, dynamic> j, {String email = ''}) =>
      AppUser(
        id: j['id'] as String,
        name: j['name'] as String? ?? '',
        email: email,
        phone: j['phone'] as String? ?? '',
        role: roleFromString(j['role'] as String? ?? 'seller'),
        status: statusFromString(j['status'] as String? ?? 'active'),
        subscription: subFromString(j['subscription'] as String? ?? 'none'),
        location: j['location'] as String?,
        subscriptionExpiry: j['sub_expiry'] != null
            ? DateTime.parse(j['sub_expiry'] as String)
            : null,
      );

  bool get isSubscribed =>
      subscription == SubscriptionType.monthly &&
      (subscriptionExpiry == null ||
          subscriptionExpiry!.isAfter(DateTime.now()));

  AppUser copyWith({
    UserStatus? status,
    SubscriptionType? subscription,
    String? location,
    DateTime? subscriptionExpiry,
  }) =>
      AppUser(
        id: id, name: name, email: email, phone: phone, role: role,
        status: status ?? this.status,
        subscription: subscription ?? this.subscription,
        location: location ?? this.location,
        subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      );
}
