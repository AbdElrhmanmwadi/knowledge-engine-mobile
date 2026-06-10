import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/l10n.dart';
import '../providers/auth_notifier.dart';
import '../widgets/auth_widgets.dart';

/// Requests a password-reset email. Always shows the same generic success
/// message regardless of whether the account exists, and rate-limits the
/// submit button for 30 seconds after sending.
class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() =>
      _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  static const int _cooldownSeconds = 30;

  late final TextEditingController _emailController;
  Timer? _cooldownTimer;

  bool _isSubmitting = false;
  bool _sent = false;
  int _cooldownRemaining = 0;
  String? _errorMessage;
  String? _emailError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final email = _emailController.text.trim();

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    setState(() {
      _errorMessage = null;
      _emailError = email.isEmpty
          ? l10n.authEmailRequired
          : (!emailPattern.hasMatch(email) ? l10n.authEmailInvalid : null);
    });
    if (_emailError != null) return;

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .requestPasswordReset(email: email);
      if (!mounted) return;
      setState(() {
        _sent = true;
        _cooldownRemaining = _cooldownSeconds;
      });
      _cooldownTimer?.cancel();
      _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          _cooldownRemaining -= 1;
          if (_cooldownRemaining <= 0) timer.cancel();
        });
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = describeAuthFailure(context, error);
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final onCooldown = _cooldownRemaining > 0;

    return AuthScaffold(
      title: l10n.forgotPasswordTitle,
      subtitle: l10n.forgotPasswordSubtitle,
      footer: TextButton(
        onPressed: _isSubmitting ? null : () => context.go('/login'),
        child: Text(
          l10n.backToSignIn,
          style: TextStyle(
            fontSize: 13.sp,
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      children: [
        if (_errorMessage != null) ...[
          AuthErrorBanner(message: _errorMessage!),
          SizedBox(height: 14.h),
        ],
        if (_sent) ...[
          AuthSuccessBanner(message: l10n.resetEmailSentGeneric),
          SizedBox(height: 14.h),
        ],
        AuthTextField(
          controller: _emailController,
          label: l10n.email,
          hint: l10n.emailHint,
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.done,
          errorText: _emailError,
          onSubmitted: (_) => _submit(),
          enabled: !_isSubmitting && !onCooldown,
        ),
        SizedBox(height: 18.h),
        AuthSubmitButton(
          label: onCooldown
              ? l10n.resendInSeconds(_cooldownRemaining)
              : l10n.sendResetLink,
          loadingLabel: l10n.sending,
          isLoading: _isSubmitting,
          onPressed: _submit,
          enabled: !onCooldown,
          icon: Icons.mail_outline_rounded,
        ),
      ],
    );
  }
}
