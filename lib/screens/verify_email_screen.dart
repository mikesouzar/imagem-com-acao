import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../providers/auth_provider.dart';
import '../widgets/gradient_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  Timer? _checkTimer;
  bool _resendCooldown = false;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    // Verifica automaticamente a cada 4 segundos
    _checkTimer = Timer.periodic(const Duration(seconds: 4), (_) => _checkVerified());
  }

  @override
  void dispose() {
    _checkTimer?.cancel();
    _cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerified() async {
    final auth = context.read<AuthProvider>();
    final verified = await auth.checkEmailVerified();
    if (verified && mounted) {
      _checkTimer?.cancel();
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  Future<void> _resend() async {
    await context.read<AuthProvider>().resendVerificationEmail();
    setState(() {
      _resendCooldown = true;
      _cooldownSeconds = 60;
    });
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _cooldownSeconds--);
      if (_cooldownSeconds <= 0) {
        t.cancel();
        setState(() => _resendCooldown = false);
      }
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email reenviado!', style: GoogleFonts.beVietnamPro()),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Ícone
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('📧', style: TextStyle(fontSize: 48)),
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Verifique seu e-mail',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'Enviamos um link de verificação para\n${auth.currentPlayer?.name ?? 'seu e-mail'}.\nAbra o email e clique no link para continuar.',
                style: GoogleFonts.beVietnamPro(
                  fontSize: 14,
                  color: AppColors.onSurface.withValues(alpha: 0.6),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // Botão verificar
              GradientButton(
                text: 'Já verifiquei ✓',
                onPressed: _checkVerified,
              ),

              const SizedBox(height: 16),

              // Reenviar
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _resendCooldown ? null : _resend,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    side: BorderSide(
                      color: _resendCooldown
                          ? AppColors.outlineVariant.withValues(alpha: 0.3)
                          : AppColors.primary,
                    ),
                  ),
                  child: Text(
                    _resendCooldown ? 'Reenviar em ${_cooldownSeconds}s' : 'Reenviar email',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w600,
                      color: _resendCooldown
                          ? AppColors.onSurface.withValues(alpha: 0.35)
                          : AppColors.primary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Sair
              GestureDetector(
                onTap: () async {
                  final nav = Navigator.of(context);
                  await context.read<AuthProvider>().logout();
                  if (mounted) nav.pushReplacementNamed('/login');
                },
                child: Text(
                  'Usar outra conta',
                  style: GoogleFonts.beVietnamPro(
                    fontSize: 13,
                    color: AppColors.onSurface.withValues(alpha: 0.45),
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
