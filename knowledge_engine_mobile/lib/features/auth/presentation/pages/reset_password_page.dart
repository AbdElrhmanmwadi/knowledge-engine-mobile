import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/constants.dart';
import '../../../../l10n/l10n.dart';
import '../providers/auth_notifier.dart';
import '../widgets/auth_widgets.dart';

/// Sets a new password using the token from the reset email.
///
/// The token arrives via the deep-link query parameter
/// (`/auth/reset-password?token=...`); when the link was opened on another
/// device the user can paste the token manually instead.
class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key, this.token});

  /// Token extracted from the URL, if the page was opened from a link.
  final String? token;

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  late final TextEditingController _tokenController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmController;

  bool _isSubmitting = false;
  bool _success = false;
  String? _errorMessage;
  String? _tokenError;
  String? _passwordError;
  String? _confirmError;

  bool get _hasLinkToken =>
      widget.token != null && widget.token!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(text: widget.token ?? '');
    _passwordController = TextEditingController();
    _confirmController = TextEditingController();
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final token = _tokenController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    setState(() {
      _errorMessage = null;
      _tokenError = token.isEmpty ? l10n.resetTokenRequired : null;
      _passwordError = password.length < AuthConstants.minPasswordLength ||
              password.length > AuthConstants.maxPasswordLength
          ? l10n.authPasswordRule
          : null;
      _confirmError = confirm != password ? l10n.passwordsDoNotMatch : null;
    });
    if (_tokenError != null || _passwordError != null || _confirmError != null) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .resetPassword(token: token, newPassword: password);
      if (!mounted) return;
      setState(() => _success = true);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage =
            describeAuthFailure(context, error, isPasswordReset: true);
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
        title: l10n.passwordChangedTitle,
        subtitle: l10n.passwordChangedSubtitle,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
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
      title: l10n.resetPasswordTitle,
      subtitle: l10n.resetPasswordSubtitle,
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
          SizedBox(height: 6.h),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: _isSubmitting
                  ? null
                  : () => context.go('/auth/forgot-password'),
              child: Text(
                l10n.requestNewLink,
                style: TextStyle(fontSize: 12.sp),
              ),
            ),
          ),
          SizedBox(height: 8.h),
        ],
        if (!_hasLinkToken) ...[
          AuthTextField(
            controller: _tokenController,
            label: l10n.resetTokenLabel,
            hint: l10n.resetTokenHint,
            icon: Icons.vpn_key_outlined,
            textInputAction: TextInputAction.next,
            errorText: _tokenError,
            enabled: !_isSubmitting,
          ),
          SizedBox(height: 14.h),
        ],
        AuthTextField(
          controller: _passwordController,
          label: l10n.newPassword,
          hint: l10n.authPasswordRule,
          icon: Icons.lock_outline_rounded,
          obscureText: true,
          textInputAction: TextInputAction.next,
          errorText: _passwordError,
          enabled: !_isSubmitting,
        ),
        SizedBox(height: 14.h),
        AuthTextField(
          controller: _confirmController,
          label: l10n.confirmPassword,
          icon: Icons.lock_reset_rounded,
          obscureText: true,
          textInputAction: TextInputAction.done,
          errorText: _confirmError,
          onSubmitted: (_) => _submit(),
          enabled: !_isSubmitting,
        ),
        SizedBox(height: 18.h),
        AuthSubmitButton(
          label: l10n.resetPasswordButton,
          loadingLabel: l10n.resetting,
          isLoading: _isSubmitting,
          onPressed: _submit,
          icon: Icons.lock_reset_rounded,
        ),
      ],
    );
  }
}
