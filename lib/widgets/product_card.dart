import 'dart:io';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../utils/theme.dart';

// Affiche une image locale (File) ou réseau (URL)
Widget _buildProductImage(String imageUrl, {BoxFit fit = BoxFit.cover}) {
  if (imageUrl.startsWith('lib/assets/')) {
    return Image.asset(
      imageUrl,
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        color: AppTheme.background,
        child: const Icon(Icons.image_not_supported_rounded,
            size: 36, color: AppTheme.textGrey),
      ),
    );
  }
  if (imageUrl.startsWith('/') || imageUrl.startsWith('file://')) {
    return Image.file(
      File(imageUrl.replaceFirst('file://', '')),
      fit: fit,
      errorBuilder: (_, __, ___) => Container(
        color: AppTheme.background,
        child: const Icon(Icons.image_not_supported_rounded,
            size: 36, color: AppTheme.textGrey),
      ),
    );
  }
  return Image.network(
    imageUrl,
    fit: fit,
    loadingBuilder: (_, child, progress) {
      if (progress == null) return child;
      return Container(
        color: AppTheme.background,
        child: const Center(
          child: CircularProgressIndicator(
              strokeWidth: 2, color: AppTheme.primary),
        ),
      );
    },
    errorBuilder: (_, __, ___) => Container(
      color: AppTheme.background,
      child: const Icon(Icons.image_not_supported_rounded,
          size: 36, color: AppTheme.textGrey),
    ),
  );
}

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;

  const ProductCard({super.key, required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Image (hauteur fixe) ─────────────────────────────────────
            SizedBox(
              height: 160,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildProductImage(product.imageUrl),
                    if (product.delivery == DeliveryOption.available)
                      Positioned(
                        top: 8, right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.success,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.success.withOpacity(0.5),
                                blurRadius: 10, offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_shipping_rounded,
                                  color: Colors.white, size: 11),
                              SizedBox(width: 3),
                              Text('Livraison',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // ── Infos sous l'image ─────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.category,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textGrey,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    AppTheme.formatPrice(product.price),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 12, color: AppTheme.textGrey),
                      const SizedBox(width: 3),
                      Flexible(
                        child: Text(
                          product.sellerLocation ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textGrey,
                            fontWeight: FontWeight.w400,
                          ),
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
    );
  }
}
