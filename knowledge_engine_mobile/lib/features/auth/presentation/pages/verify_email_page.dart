import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/l10n.dart';
import '../providers/auth_notifier.dart';
import '../widgets/auth_widgets.dart';

/// Verifies an email address.
///
/// When opened from the verification link (`/auth/verify-email?token=...`)
/// it verifies automatically; otherwise the user can paste the token from
/// the email manually.
class VerifyEmailPage extends ConsumerStatefulWidget {
  const VerifyEmailPage({super.key, this.token});

  /// Token extracted from the URL, if the page was opened from a link.
  final String? token;

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  late final TextEditingController _tokenController;

  bool _isSubmitting = false;
  bool _success = false;
  String? _errorMessage;
  String? _tokenError;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(text: widget.token ?? '');
    final linkToken = widget.token?.trim();
    if (linkToken != null && linkToken.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _submit());
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final token = _tokenController.text.trim();

    setState(() {
      _errorMessage = null;
      _tokenError = token.isEmpty ? l10n.verificationTokenRequired : null;
    });
    if (_tokenError != null) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(authNotifierProvider.notifier).verifyEmail(token: token);
      if (!mounted) return;
      setState(() => _success = true);
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

    if (_success) {
      return AuthScaffold(
        title: l10n.emailVerifiedTitle,
        subtitle: l10n.emailVerifiedSubtitle,
        children: [
          Icon(
            Icons.verified_outlined,
            size: 48.r,
            color: Theme.of(context).colorScheme.secondary,
          ),
          SizedBox(height: 20.h),
          AuthSubmitButton(
            label: l10n.backToSignIn,
            loadingLabel: l10n.backToSignIn,
            isLoading: false,
            onPressed: () => context.go('/login'),
            icon: Icons.login_rounded,
          ),
        ],
      );
    }

    return AuthScaffold(
      title: l10n.verifyEmailTitle,
      subtitle: l10n.verifyEmailSubtitle,
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
        AuthTextField(
          controller: _tokenController,
          label: l10n.verificationTokenLabel,
          hint: l10n.verificationTokenHint,
          icon: Icons.vpn_key_outlined,
          textInputAction: TextInputAction.done,
          errorText: _tokenError,
          onSubmitted: (_) => _submit(),
          enabled: !_isSubmitting,
        ),
        SizedBox(height: 18.h),
        AuthSubmitButton(
          label: l10n.verifyEmailButton,
          loadingLabel: l10n.verifying,
          isLoading: _isSubmitting,
          onPressed: _submit,
          icon: Icons.verified_user_outlined,
        ),
      ],
    );
  }
}
