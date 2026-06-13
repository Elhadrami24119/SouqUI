import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../l10n/app_strings.dart';
import '../../mock/mock_service.dart';
import '../../utils/theme.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _locationCtrl = TextEditingController();
  final _picker       = ImagePicker();
  File? _proofImage;
  bool _loading = false;

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickProof() async {
    showModalBottomSheet(
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
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 36, height: 4,
                decoration: BoxDecoration(color: AppTheme.divider,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(S.of(context).upgradeProof,
                style: GoogleFonts.inter(fontSize: 17,
                    fontWeight: FontWeight.w700, color: AppTheme.textDark)),
            const SizedBox(height: 16),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  Navigator.pop(context);
                  final xf = await _picker.pickImage(
                      source: ImageSource.camera, imageQuality: 90);
                  if (xf != null) setState(() => _proofImage = File(xf.path));
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
                        width: 46, height: 46,
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
                            Text(S.of(context).takePhoto,
                                style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: AppTheme.textDark)),
                            Text(S.of(context).useCamera,
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
                  final xf = await _picker.pickImage(
                      source: ImageSource.gallery, imageQuality: 90);
                  if (xf != null) setState(() => _proofImage = File(xf.path));
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
                        width: 46, height: 46,
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
                            Text(S.of(context).fromGallery,
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
    );
  }

  Future<void> _submit() async {
    final s = S.of(context);
    if (_proofImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(s.upgradeProof.replaceAll(' *', '') + ' requis'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ));
      return;
    }

    setState(() => _loading = true);

    try {
      await SupabaseService().requestSubscriptionWithFile(
        paymentProof: _proofImage!,
        location: _locationCtrl.text.trim().isEmpty
            ? null
            : _locationCtrl.text.trim(),
      );
      if (!mounted) return;
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(s.upgradeSuccess,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ));
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Erreur : ${e.toString()}'),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 16, color: AppTheme.textDark),
          ),
        ),
        title: Text(s.upgradeTitle),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: AppTheme.primaryShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.star_rounded,
                        color: Colors.white, size: 26),
                  ),
                  const SizedBox(height: 14),
                  Text(s.upgradeTitle,
                      style: GoogleFonts.inter(
                          color: Colors.white, fontSize: 20,
                          fontWeight: FontWeight.w800, letterSpacing: -0.4)),
                  const SizedBox(height: 8),
                  Text(s.upgradeSub,
                      style: GoogleFonts.inter(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 14, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(18),
                boxShadow: AppTheme.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    const Icon(Icons.receipt_long_rounded,
                        color: AppTheme.primary, size: 18),
                    const SizedBox(width: 8),
                    Text(S.of(context).instructionsTitle,
                        style: GoogleFonts.inter(
                            fontSize: 14, fontWeight: FontWeight.w700,
                            color: AppTheme.textDark)),
                  ]),
                  const SizedBox(height: 14),
                  _Step(n: '1', text: s.step1),
                  _Step(n: '2', text: s.step2, bold: true),
                  _Step(n: '3', text: s.step3),
                  _Step(n: '4', text: s.step4, isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 20),

            TextField(
              controller: _locationCtrl,
              decoration: InputDecoration(
                labelText: s.upgradeLocation,
                hintText: s.locationHint,
                prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
              ),
            ),
            const SizedBox(height: 16),

            Text(s.upgradeProof,
                style: GoogleFonts.inter(
                    fontSize: 13, fontWeight: FontWeight.w600,
                    color: AppTheme.textMid)),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _pickProof,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 200,
                decoration: BoxDecoration(
                  color: _proofImage != null
                      ? Colors.transparent
                      : AppTheme.background,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _proofImage != null
                        ? AppTheme.success
                        : AppTheme.divider,
                    width: _proofImage != null ? 2 : 1.5,
                  ),
                ),
                child: _proofImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.file(_proofImage!, fit: BoxFit.cover),
                            Positioned(
                              top: 8, right: 8,
                              child: GestureDetector(
                                onTap: () => setState(() => _proofImage = null),
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
                                      Text(s.proofAdded,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                          Text(s.uploadProof,
                              style: GoogleFonts.inter(
                                  fontSize: 14, fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark)),
                          const SizedBox(height: 4),
                          Text(s.cameraOrGallery,
                              style: GoogleFonts.inter(
                                  fontSize: 12, color: AppTheme.textGrey)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 28),

            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppTheme.primaryShadow,
              ),
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _submit,
                icon: _loading
                    ? const SizedBox(width: 18, height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded,
                        color: Colors.white, size: 18),
                label: Text(s.upgradeSubmit,
                    style: GoogleFonts.inter(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final String n;
  final String text;
  final bool bold;
  final bool isLast;
  const _Step({required this.n, required this.text,
      this.bold = false, this.isLast = false});

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
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Text(n,
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
                      fontSize: bold ? 14 : 13,
                      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                      color: bold ? AppTheme.textDark : AppTheme.textMid,
                      height: 1.4)),
            ),
          ),
        ],
      ),
    );
  }
}

