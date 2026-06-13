import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_strings.dart';
import '../models/models.dart';
import '../mock/mock_service.dart';
import '../utils/theme.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});

  Widget _buildImg(String url,
      {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (url.startsWith('lib/assets/')) {
      return Image.asset(url,
          width: width, height: height, fit: fit,
          errorBuilder: (_, __, ___) => _placeholder(width, height));
    }
    if (url.startsWith('/')) {
      return Image.file(File(url),
          width: width, height: height, fit: fit,
          errorBuilder: (_, __, ___) => _placeholder(width, height));
    }
    return Image.network(url,
        width: width, height: height, fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(width, height));
  }

  Widget _placeholder(double? width, double? height) => Container(
        width: width, height: height, color: AppTheme.divider,
        child: const Icon(Icons.image_not_supported_outlined,
            color: AppTheme.textGrey, size: 40),
      );

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openWhatsApp(String phone) async {
    final cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');
    await _launchUrl('https://wa.me/$cleaned');
  }

  Future<void> _openPhone(String phone) async =>
      _launchUrl('tel:$phone');

  Future<void> _openFacebook(String url) async => _launchUrl(url);

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final p = product;
    final thumbnails = <String>[
      if (p.imageUrl2 != null) p.imageUrl2!,
      if (p.imageUrl3 != null) p.imageUrl3!,
    ];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: AppTheme.surface,
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImg(p.imageUrl, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black38, Colors.transparent,
                          Colors.transparent, Colors.black26,
                        ],
                        stops: [0.0, 0.3, 0.7, 1.0],
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
                if (thumbnails.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        _ThumbnailItem(
                          imageUrl: p.imageUrl,
                          buildImg: _buildImg,
                          onTap: () => _openViewer(context, p.imageUrl),
                        ),
                        const SizedBox(width: 8),
                        ...thumbnails.map((url) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: _ThumbnailItem(
                                imageUrl: url,
                                buildImg: _buildImg,
                                onTap: () => _openViewer(context, url),
                              ),
                            )),
                      ],
                    ),
                  ),
                  if (SupabaseService().currentUser?.id == p.sellerId)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.statusColor(p.status)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppTheme.statusColor(p.status)
                                .withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  switch (p.status) {
                                    ProductStatus.pending =>
                                        Icons.hourglass_empty_rounded,
                                    ProductStatus.approved =>
                                        Icons.check_circle_rounded,
                                    ProductStatus.rejected =>
                                        Icons.cancel_rounded,
                                    ProductStatus.sold =>
                                        Icons.task_alt_rounded,
                                  },
                                  size: 20,
                                  color: AppTheme.statusColor(p.status),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    switch (p.status) {
                                      ProductStatus.pending =>
                                        '⏳ En attente de validation',
                                      ProductStatus.approved =>
                                        '✅ Annonce publiée',
                                      ProductStatus.rejected =>
                                        '❌ Annonce refusée',
                                      ProductStatus.sold =>
                                        '✔ Produit vendu',
                                    },
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color:
                                          AppTheme.statusColor(p.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (p.status == ProductStatus.rejected &&
                                p.adminNote != null &&
                                p.adminNote!.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.15),
                                  ),
                                ),
                                child: Text(
                                  'Motif : ${p.adminNote!}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.priceRed,
                                    fontWeight: FontWeight.w500,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              s.translateCategory(p.category),
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.primary),
                            ),
                          ),
                          const Spacer(),
                          if (p.sellerLocation != null)
                            Flexible(
                              child: Chip(
                                avatar: const Icon(Icons.location_on,
                                    size: 14, color: AppTheme.textGrey),
                                label: Text(
                                  p.sellerLocation!,
                                  style: const TextStyle(
                                      fontSize: 11, color: AppTheme.textMid),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                padding: EdgeInsets.zero,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                backgroundColor: AppTheme.background,
                                side: const BorderSide(color: AppTheme.divider),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Text(p.name,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                            letterSpacing: -0.5,
                          )),
                      const SizedBox(height: 8),

                      Text(AppTheme.formatPrice(p.price),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.priceRed,
                          )),

                      if (p.delivery == DeliveryOption.available) ...[
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.local_shipping_outlined,
                              size: 16, color: AppTheme.success),
                          const SizedBox(width: 6),
                          Text(
                            p.deliveryPrice != null
                                ? '${s.deliveryLabel} : ${AppTheme.formatPrice(p.deliveryPrice!)}'
                                : s.deliveryAvailLabel,
                            style: const TextStyle(
                                fontSize: 13, color: AppTheme.success),
                          ),
                        ]),
                      ] else ...[
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.store_rounded,
                              size: 16, color: AppTheme.textGrey),
                          const SizedBox(width: 6),
                          Text(s.pickupOnly,
                              style: const TextStyle(
                                  fontSize: 13, color: AppTheme.textGrey)),
                        ]),
                      ],

                      if (p.description != null &&
                          p.description!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        const Divider(color: AppTheme.divider),
                        const SizedBox(height: 12),
                        Text(s.descriptionTitle,
                            style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark)),
                        const SizedBox(height: 8),
                        Text(p.description!,
                            style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.textMid,
                                height: 1.6)),
                      ],
                    ],
                  ),
                ),

                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  decoration: BoxDecoration(
                    gradient: AppTheme.darkGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppTheme.cardShadow,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.sellerLabel,
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white54)),
                      const SizedBox(height: 10),
                      Row(children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: AppTheme.primary.withOpacity(0.2),
                          child: Text(
                            p.sellerName.isNotEmpty
                                ? p.sellerName[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.sellerName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16),
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(p.sellerPhone,
                                  style: const TextStyle(
                                      color: Colors.white60, fontSize: 13)),
                            ],
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Column(children: [
                    if (p.sellerWhatsApp != null) ...[
                      GestureDetector(
                        onTap: () => _openWhatsApp(p.sellerWhatsApp!),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF25D366),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF25D366).withOpacity(0.35),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.chat,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 10),
                              Text(s.contactWhatsApp,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    Row(children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _openPhone(p.sellerPhone),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: AppTheme.divider, width: 1.5),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.phone_outlined,
                                    size: 18, color: AppTheme.textDark),
                                const SizedBox(width: 8),
                                Text(s.callLabel,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                        color: AppTheme.textDark)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (p.sellerFacebook != null) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _openFacebook(p.sellerFacebook!),
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1877F2),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.facebook,
                                      size: 18, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Text(s.facebookLabel,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ]),
                  ]),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openViewer(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ImageViewer(imageUrl: url, buildImg: _buildImg),
      ),
    );
  }
}

class _ThumbnailItem extends StatelessWidget {
  final String imageUrl;
  final Widget Function(String, {double? width, double? height, BoxFit fit})
      buildImg;
  final VoidCallback onTap;

  const _ThumbnailItem(
      {required this.imageUrl, required this.buildImg, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: buildImg(imageUrl, width: 80, height: 80, fit: BoxFit.cover),
        ),
      );
}

class _ImageViewer extends StatelessWidget {
  final String imageUrl;
  final Widget Function(String, {double? width, double? height, BoxFit fit})
      buildImg;

  const _ImageViewer({required this.imageUrl, required this.buildImg});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(S.of(context).descriptionTitle,
            style: const TextStyle(color: Colors.white)),
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          child: buildImg(imageUrl, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
