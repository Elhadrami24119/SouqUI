import 'package:flutter/material.dart';

// ─── Language notifier ────────────────────────────────────────────────────────

class AppLocale extends ValueNotifier<Locale> {
  static final AppLocale _instance = AppLocale._internal();
  factory AppLocale() => _instance;
  AppLocale._internal() : super(const Locale('fr'));

  bool get isArabic => value.languageCode == 'ar';
  void setFrench()  => value = const Locale('fr');
  void setArabic()  => value = const Locale('ar');
  void toggle()     => isArabic ? setFrench() : setArabic();
}

// ─── Translations ─────────────────────────────────────────────────────────────

class S {
  final bool _ar;
  const S._(this._ar);

  /// Get S from context locale.
  static S of(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return S._(locale.languageCode == 'ar');
  }

  /// Get S directly from AppLocale (outside widget tree).
  static S get current => S._(AppLocale().isArabic);

  String _t(String fr, String ar) => _ar ? ar : fr;

  // ── App ───────────────────────────────────────────────────────────────────
  String get appName       => _t('Souq Marketplace', 'سوق ماركت');
  String get welcome       => _t('Bienvenue 👋', 'مرحباً 👋');
  String get hello         => _t('Bonjour', 'مرحباً');

  // ── Home ──────────────────────────────────────────────────────────────────
  String get categories    => _t('Catégories', 'الفئات');
  String get bestListings  => _t('Meilleures annonces', 'أفضل الإعلانات');
  String get results       => _t('résultats', 'نتيجة');
  String get searchHint    => _t('Rechercher un produit...', 'ابحث عن منتج...');
  String get noProduct     => _t('Aucun produit trouvé', 'لا توجد منتجات');
  String get tryOther      => _t('Essayez une autre recherche', 'جرب بحثاً آخر');
  String get publish       => _t('Publier', 'نشر');

  // ── Menu ──────────────────────────────────────────────────────────────────
  String get administration => _t('Administration', 'الإدارة');
  String get manageListings => _t('Gérer les annonces', 'إدارة الإعلانات');
  String get myListings     => _t('Mes annonces', 'إعلاناتي');
  String get manageProducts => _t('Gérer mes produits', 'إدارة منتجاتي');
  String get loginMenu      => _t('Connexion', 'تسجيل الدخول');
  String get accessAccount  => _t('Accéder à mon compte', 'الوصول إلى حسابي');
  String get createAccount  => _t('Créer un compte', 'إنشاء حساب');
  String get becomeSeller   => _t('Devenir vendeur', 'كن بائعاً');
  String get logout         => _t('Déconnexion', 'تسجيل الخروج');
  String get leaveAccount   => _t('Quitter mon compte', 'مغادرة حسابي');
  String get administrator  => _t('Administrateur', 'مدير');
  String get sellerRole     => _t('Vendeur', 'بائع');

  // ── Auth – Login ──────────────────────────────────────────────────────────
  String get welcomeBack   => _t('Bon retour !', 'مرحباً بعودتك!');
  String get loginSubtitle => _t('Connectez-vous pour gérer vos annonces', 'سجّل دخولك لإدارة إعلاناتك');
  String get emailLabel    => _t('Email', 'البريد الإلكتروني');
  String get passwordLabel => _t('Mot de passe', 'كلمة المرور');
  String get signIn        => _t('Se connecter', 'تسجيل الدخول');
  String get noAccount     => _t('Pas encore de compte ? ', 'ليس لديك حساب؟ ');
  String get signUp        => _t("S'inscrire", 'إنشاء حساب');
  String get adminDemo     => _t('Admin demo : hdr119\n(mot de passe quelconque)', 'حساب المدير: hdr119\n(أي كلمة مرور)');

  // ── Auth – Register ───────────────────────────────────────────────────────
  String get createAccountTitle => _t('Créer un compte', 'إنشاء حساب');
  String get registerSub   => _t('Rejoignez Souq et publiez vos annonces', 'انضم إلى سوق وانشر إعلاناتك');
  String get registerFreeInfo => _t(
    "Compte gratuit : 1 annonce à la fois. Vous pourrez passer à l'abonnement depuis votre espace vendeur.",
    'حساب مجاني: إعلان واحد في كل مرة. يمكنك الترقية للاشتراك من لوحة البائع.',
  );
  // ── Subscription upgrade ──────────────────────────────────────────────────
  String get upgradeTitle  => _t('Passer à l\'abonnement', 'الترقية للاشتراك');
  String get upgradeSub    => _t('Publiez des annonces illimitées pour 500 MRU/mois', 'انشر إعلانات غير محدودة مقابل 500 أوقية/شهر');
  String get upgradeBtn    => _t('Demander l\'abonnement', 'طلب الاشتراك');
  String get upgradePending => _t('Demande en cours de traitement...', 'الطلب قيد المعالجة...');
  String get upgradeActive => _t('Abonnement actif ✅', 'الاشتراك نشط ✅');
  String get upgradeProof  => _t('Preuve de paiement *', 'إثبات الدفع *');
  String get upgradeLocation => _t('Votre ville / adresse', 'مدينتك / عنوانك');
  String get upgradeSubmit => _t('Envoyer la demande', 'إرسال الطلب');
  String get upgradeSuccess => _t('Demande envoyée ! L\'admin va confirmer sous peu.', 'تم إرسال الطلب! سيؤكد المدير قريباً.');
  String get subRequestsTab => _t('Abonnements', 'الاشتراكات');
  String get noSubRequests  => _t('Aucune demande d\'abonnement', 'لا توجد طلبات اشتراك');
  String get approveSubBtn  => _t('Activer', 'تفعيل');
  String get rejectSubBtn   => _t('Refuser', 'رفض');
  String get fullName      => _t('Nom complet', 'الاسم الكامل');
  String get phoneLabel    => _t('Numéro de téléphone', 'رقم الهاتف');
  String get createMyAccount => _t('Créer mon compte', 'إنشاء حسابي');
  String get alreadyAccount => _t('Déjà un compte ? ', 'لديك حساب؟ ');
  String get accountCreated => _t('Compte créé avec succès ! Bienvenue 🎉', 'تم إنشاء الحساب بنجاح! مرحباً 🎉');
  String get emailExists   => _t('Un compte existe déjà avec cet email.', 'يوجد حساب بهذا البريد الإلكتروني.');
  String get accountType   => _t('Type de compte', 'نوع الحساب');
  String get freeLabel     => _t('Gratuit', 'مجاني');
  String get oneListingAtTime => _t('1 annonce à la fois', 'إعلان واحد في كل مرة');
  String get subscriptionLabel => _t('Abonnement', 'اشتراك');
  String get unlimitedListings => _t('Annonces illimitées', 'إعلانات غير محدودة');
  String get locationLabel => _t('Votre localisation *', 'موقعك *');
  String get locationHint  => _t('Ex: Nouakchott, Tevragh-Zeina', 'مثال: نواكشوط، تفرغ زينة');
  String get locationRequired => _t('Veuillez saisir votre localisation.', 'يرجى إدخال موقعك.');
  String get subscriptionInfo => _t(
    "L'abonnement mensuel vous permet de publier des annonces illimitées. Paiement de 500 MRU/mois.",
    'الاشتراك الشهري يتيح لك نشر إعلانات غير محدودة. الدفع 500 أوقية/شهر.',
  );

  // ── Validation ────────────────────────────────────────────────────────────
  String get fillAllFields  => _t('Veuillez remplir tous les champs.', 'يرجى ملء جميع الحقول.');
  String get invalidEmail   => _t('Adresse email invalide.', 'عنوان البريد الإلكتروني غير صالح.');
  String get passwordMin    => _t('Le mot de passe doit contenir au moins 6 caractères.', 'يجب أن تحتوي كلمة المرور على 6 أحرف على الأقل.');
  String get invalidPhone   => _t('Numéro de téléphone invalide.', 'رقم الهاتف غير صالح.');
  String get wrongCredentials => _t('Email ou mot de passe incorrect.', 'البريد الإلكتروني أو كلمة المرور غير صحيحة.');
  String get blockedAccount => _t("Compte suspendu. Contactez l'administrateur.", 'الحساب موقوف. تواصل مع المدير.');
  String get noInternet     => _t('Pas de connexion internet. Vérifiez votre Wi-Fi ou données mobiles.', 'لا يوجد اتصال بالإنترنت. تحقق من Wi-Fi أو بيانات الجوال.');

  // ── Seller Dashboard ──────────────────────────────────────────────────────
  String get myAds         => _t('Mes annonces', 'إعلاناتي');
  String get add           => _t('Ajouter', 'إضافة');
  String get total         => _t('Total', 'المجموع');
  String get publishedStat => _t('Publiées', 'منشورة');
  String get pendingStat   => _t('En attente', 'قيد الانتظار');
  String get rejectedStat  => _t('Rejetées', 'مرفوضة');
  String get noAds         => _t('Aucune annonce', 'لا توجد إعلانات');
  String get publishFirst  => _t('Publiez votre première annonce', 'انشر إعلانك الأول');

  // ── Add Product ───────────────────────────────────────────────────────────
  String get newListing    => _t('Nouvelle annonce', 'إعلان جديد');
  String get paymentStep   => _t('Paiement', 'الدفع');
  String get addPhoto      => _t('Ajouter une photo', 'إضافة صورة');
  String get cameraOrGallery => _t('Caméra ou galerie', 'الكاميرا أو المعرض');
  String get productInfo   => _t('Informations du produit', 'معلومات المنتج');
  String get productName   => _t('Nom du produit *', 'اسم المنتج *');
  String get priceMRU      => _t('Prix (MRU) *', 'السعر (أوقية) *');
  String get categoryField => _t('Catégorie', 'الفئة');
  String get descriptionField => _t('Description (optionnel)', 'الوصف (اختياري)');
  String get sellerContact => _t('Contact vendeur', 'تواصل البائع');
  String get whatsappNum   => _t('Numéro WhatsApp (optionnel)', 'رقم واتساب (اختياري)');
  String get deliveryOptions => _t('Options de livraison', 'خيارات التوصيل');
  String get deliveryAvailable => _t('Disponible', 'متاح');
  String get deliveryNotAvailable => _t('Non disponible', 'غير متاح');
  String get deliveryPriceField => _t('Prix de livraison (optionnel)', 'سعر التوصيل (اختياري)');
  String get continuePayment => _t('Continuer vers le paiement →', 'المتابعة للدفع ←');
  String get fillRequired  => _t('Veuillez remplir les champs obligatoires.', 'يرجى ملء الحقول المطلوبة.');
  String get paymentRequired => _t('Paiement requis', 'الدفع مطلوب');
  String get paymentDesc   => _t('Payez 500 MRU pour publier votre annonce. Envoyez la preuve ci-dessous.', 'ادفع 500 أوقية لنشر إعلانك. أرسل الإثبات أدناه.');
  String get instructionsTitle => _t('Instructions', 'التعليمات');
  String get step1         => _t('Envoyez 500 MRU via Bankily ou Masrvi', 'أرسل 500 أوقية عبر بنكيلي أو مصرفي');
  String get step2         => _t('Numéro : +222 44 XX XX XX', 'الرقم: +222 44 XX XX XX');
  String get step3         => _t("Prenez une capture d'écran de la transaction", 'التقط صورة للمعاملة');
  String get step4         => _t('Téléchargez la preuve ci-dessous', 'حمّل الإثبات أدناه');
  String get uploadProof   => _t('Télécharger la preuve', 'تحميل الإثبات');
  String get sendProof     => _t('Envoyer la preuve de paiement', 'إرسال إثبات الدفع');
  String get proofAdded    => _t('Preuve ajoutée', 'تم إضافة الإثبات');
  String get listingSubmitted => _t('Annonce soumise !', 'تم تقديم الإعلان!');
  String get waitingValidation => _t(
    "Votre annonce est en attente de validation. Vous serez notifié dès qu'elle sera approuvée.",
    'إعلانك قيد المراجعة. ستُبلَّغ عند الموافقة عليه.',
  );
  String get backToMyAds   => _t('Retour à mes annonces', 'العودة إلى إعلاناتي');
  String get choosePhoto   => _t('Choisir une photo', 'اختيار صورة');
  String get takePhoto     => _t('Prendre une photo', 'التقاط صورة');
  String get useCamera     => _t('Utiliser la caméra', 'استخدام الكاميرا');
  String get chooseGallery => _t('Choisir depuis la galerie', 'الاختيار من المعرض');
  String get paymentProofTitle => _t('Preuve de paiement', 'إثبات الدفع');
  String get takeCapture   => _t('Prendre une capture', 'التقاط صورة');
  String get photoTransaction => _t('Photo de la transaction', 'صورة المعاملة');
  String get fromGallery   => _t('Depuis la galerie', 'من المعرض');
  String get existingScreenshot => _t("Capture d'écran existante", 'لقطة شاشة موجودة');

  // ── Product Detail ────────────────────────────────────────────────────────
  String get sellerLabel   => _t('Vendeur', 'البائع');
  String get contactSeller => _t('Contacter le vendeur', 'تواصل مع البائع');
  String get contactWhatsApp => _t('Contacter sur WhatsApp', 'تواصل عبر واتساب');
  String get callLabel     => _t('Appeler', 'اتصال');
  String get facebookLabel => _t('Facebook', 'فيسبوك');
  String get deliveryLabel => _t('Livraison', 'التوصيل');
  String get deliveryAvailLabel => _t('Livraison disponible', 'التوصيل متاح');
  String get pickupOnly    => _t('Retrait en main propre uniquement', 'الاستلام الشخصي فقط');
  String get descriptionTitle => _t('Description', 'الوصف');

  // ── Admin ─────────────────────────────────────────────────────────────────
  String get adminTitle    => _t('Administration', 'الإدارة');
  String get pendingTab    => _t('En attente', 'قيد الانتظار');
  String get publishedTab  => _t('Publiées', 'منشورة');
  String get usersTab      => _t('Utilisateurs', 'المستخدمون');
  String get noPending     => _t('Aucune annonce en attente', 'لا توجد إعلانات قيد الانتظار');
  String get allUpToDate   => _t('Tout est à jour !', 'كل شيء محدّث!');
  String get approveBtn    => _t('Approuver', 'موافقة');
  String get rejectBtn     => _t('Rejeter', 'رفض');
  String get editBtn       => _t('Modifier', 'تعديل');
  String get deleteBtn     => _t('Supprimer', 'حذف');
  String get approvedSnack => _t('Annonce approuvée ✅', 'تمت الموافقة على الإعلان ✅');
  String get rejectedSnack => _t('Annonce rejetée ❌', 'تم رفض الإعلان ❌');
  String get rejectReason  => _t('Raison du rejet (optionnel)', 'سبب الرفض (اختياري)');
  String get rejectTitle   => _t("Rejeter l'annonce", 'رفض الإعلان');
  String get deleteTitle   => _t("Supprimer l'annonce", 'حذف الإعلان');
  String get deleteConfirm => _t('Supprimer définitivement ?', 'حذف نهائياً؟');
  String get irreversible  => _t('Cette action est irréversible.', 'هذا الإجراء لا يمكن التراجع عنه.');
  String get cancelBtn     => _t('Annuler', 'إلغاء');
  String get saveBtn       => _t('Enregistrer', 'حفظ');
  String get editCategory  => _t('Modifier la catégorie', 'تعديل الفئة');
  String get seeProof      => _t('Voir preuve de paiement', 'عرض إثبات الدفع');
  String get noProof       => _t('Aucune preuve soumise', 'لم يُقدَّم إثبات');
  String get proofAvailable => _t('Preuve de paiement disponible', 'إثبات الدفع متاح');
  String get seeBtn        => _t('Voir', 'عرض');
  String get noPublished   => _t('Aucune annonce publiée', 'لا توجد إعلانات منشورة');
  String get noUsers       => _t('Aucun utilisateur', 'لا يوجد مستخدمون');
  String get blockBtn      => _t('Bloquer', 'حظر');
  String get unblockBtn    => _t('Débloquer', 'رفع الحظر');
  String get warnBtn       => _t('Avertir', 'تحذير');
  String get warnTitle     => _t("Avertir l'utilisateur", 'تحذير المستخدم');
  String get warnMessage   => _t("Message d'avertissement", 'رسالة التحذير');
  String get sendBtn       => _t('Envoyer', 'إرسال');
  String get activeStatus  => _t('Actif', 'نشط');
  String get blockedStatus => _t('Bloqué', 'محظور');
  String get warnedStatus  => _t('Averti', 'محذَّر');
  String get subscribedLabel => _t('Abonné', 'مشترك');
  String get categoryBtn   => _t('Catégorie', 'الفئة');
  String get deletedSnack  => _t('Annonce supprimée 🗑️', 'تم حذف الإعلان 🗑️');

  // ── Notifications ─────────────────────────────────────────────────────────
  String get notificationsTitle => _t('Notifications', 'الإشعارات');
  String get noNotifications => _t('Aucune notification', 'لا توجد إشعارات');
  String get notifSub      => _t('Vous serez notifié ici', 'ستتلقى إشعاراتك هنا');

  // ── Subscription Expiry ──────────────────────────────────────────────────
  String get subscriptionExpired => _t('Abonnement expiré ❌', 'انتهت صلاحية الاشتراك ❌');
  String get subscriptionExpiredDesc => _t(
    'Votre abonnement a expiré. Renouvelez-le pour continuer à publier des annonces.',
    'انتهت صلاحية اشتراكك. جدّده لمواصلة نشر الإعلانات.',
  );
  String get renewSubscription => _t('Renouveler l\'abonnement', 'تجديد الاشتراك');
  String get expiredBannerTitle => _t('Abonnement expiré', 'الاشتراك منتهي');
  String get expiredBannerDesc => _t(
    'Votre abonnement a expiré. Vous ne pouvez plus publier de nouvelles annonces.',
    'انتهت صلاحية اشتراكك. لا يمكنك نشر إعلانات جديدة.',
  );
  String get adminExpiryAlertTitle => _t('Abonnement expiré ⏰', 'انتهاء الاشتراك ⏰');
  String get adminExpiryAlertBody => _t(
    'L\'abonnement de {name} a expiré. Ce vendeur doit renouveler pour être réactivé.',
    'انتهت صلاحية اشتراك {name}. يجب على هذا البائع التجديد لإعادة التنشيط.',
  );
  String get renewalPrompt => _t(
    'Votre abonnement a expiré. Si vous souhaitez continuer à publier, veuillez faire une nouvelle demande d\'abonnement.',
    'انتهت صلاحية اشتراكك. إذا كنت ترغب في مواصلة النشر، يرجى تقديم طلب اشتراك جديد.',
  );

  // ── Connectivity ──────────────────────────────────────────────────────────
  String get noConnection  => _t('Pas de connexion', 'لا يوجد اتصال');
  String get checkWifi     => _t('Vérifiez votre connexion Wi-Fi ou données mobiles et réessayez.', 'تحقق من اتصال Wi-Fi أو بيانات الجوال وأعد المحاولة.');
  String get retryBtn      => _t('Réessayer', 'إعادة المحاولة');
  String get noConnectionAds => _t(
    'Les annonces ne sont pas disponibles hors ligne.\nVérifiez votre Wi-Fi ou données mobiles.',
    'الإعلانات غير متاحة بدون اتصال.\nتحقق من Wi-Fi أو بيانات الجوال.',
  );

  // ── Status labels ─────────────────────────────────────────────────────────
  String get statusPublished => _t('Publiée', 'منشور');
  String get statusPending   => _t('En attente', 'قيد الانتظار');
  String get statusRejected  => _t('Rejetée', 'مرفوض');

  // ── Categories (translated labels) ────────────────────────────────────────
  /// Returns the translated label for a French category key.
  String translateCategory(String frKey) => switch (frKey) {
    'Tout'          => _t('Tout', 'الكل'),
    'Téléphones'    => _t('Téléphones', 'هواتف'),
    'Ordinateurs'   => _t('Ordinateurs', 'حواسيب'),
    'Montres'       => _t('Montres', 'ساعات'),
    'Électroménager'=> _t('Électroménager', 'أجهزة منزلية'),
    'Meubles'       => _t('Meubles', 'أثاث'),
    'Vêtements'     => _t('Vêtements', 'ملابس'),
    'Véhicules'     => _t('Véhicules', 'مركبات'),
    'Autres'        => _t('Autres', 'أخرى'),
    _               => frKey,
  };
}
