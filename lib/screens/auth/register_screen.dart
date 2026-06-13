import 'package:flutter/material.dart';
import '../../l10n/app_strings.dart';
import '../../mock/mock_service.dart';
import '../../utils/theme.dart';
import '../../widgets/lang_toggle.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl  = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    AppLocale().addListener(() { if (mounted) setState(() {}); });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _register() async {
    final s = S.of(context);
    final name  = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final pass  = _passCtrl.text;

    if (name.isEmpty || email.isEmpty || phone.isEmpty || pass.isEmpty) {
      setState(() => _error = s.fillAllFields);
      return;
    }
    if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      setState(() => _error = s.invalidEmail);
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = s.passwordMin);
      return;
    }
    if (!RegExp(r'^\+?[\d\s]{8,15}$').hasMatch(phone)) {
      setState(() => _error = s.invalidPhone);
      return;
    }

    setState(() { _loading = true; _error = null; });
    try {
      await SupabaseService().register(
        name: name, email: email, password: pass, phone: phone,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(s.accountCreated,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
      ));
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final msg = e.toString();
      setState(() {
        _loading = false;
        _error = msg.contains('already') || msg.contains('user_already_exists')
            ? s.emailExists
            : msg.contains('rate_limit') || msg.contains('429')
                ? 'Trop de tentatives. Attendez quelques minutes avant de réessayer.'
                : msg;
      });
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 16, color: AppTheme.textDark),
                    ),
                  ),
                  const LangToggle(),
                ],
              ),
              const SizedBox(height: 36),
              Container(
                width: 72, height: 72,
                decoration: BoxDecoration(
                  gradient: AppTheme.darkGradient,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [BoxShadow(
                    color: AppTheme.secondary.withOpacity(0.3),
                    blurRadius: 16, offset: const Offset(0, 6),
                  )],
                ),
                child: const Icon(Icons.person_add_rounded,
                    size: 34, color: Colors.white),
              ),
              const SizedBox(height: 28),
              Text(s.createAccountTitle,
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800,
                      color: AppTheme.textDark, letterSpacing: -0.8)),
              const SizedBox(height: 6),
              Text(s.registerSub,
                  style: const TextStyle(color: AppTheme.textGrey, fontSize: 15)),
              const SizedBox(height: 32),
              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline_rounded, color: Colors.red, size: 18),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_error!,
                        style: const TextStyle(color: Colors.red, fontSize: 13,
                            fontWeight: FontWeight.w500))),
                  ]),
                ),
                const SizedBox(height: 20),
              ],
              TextField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: s.fullName,
                  prefixIcon: const Icon(Icons.person_outline_rounded, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: s.emailLabel,
                  prefixIcon: const Icon(Icons.email_outlined, size: 20),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: s.phoneLabel,
                  prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                  hintText: '+222 XX XX XX XX',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                obscureText: _obscure,
                decoration: InputDecoration(
                  labelText: s.passwordLabel,
                  prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined
                                       : Icons.visibility_outlined,
                        size: 20, color: AppTheme.textGrey),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppTheme.primaryShadow,
                ),
                child: ElevatedButton(
                  onPressed: _loading ? null : _register,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _loading
                      ? const SizedBox(height: 20, width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(s.createMyAccount, style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 15)),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: Text.rich(TextSpan(
                    text: s.alreadyAccount,
                    style: const TextStyle(color: AppTheme.textGrey, fontSize: 14),
                    children: [TextSpan(
                      text: s.signIn,
                      style: const TextStyle(color: AppTheme.primary,
                          fontWeight: FontWeight.w700),
                    )],
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
