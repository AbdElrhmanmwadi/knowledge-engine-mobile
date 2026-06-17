import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../l10n/l10n.dart';
import '../providers/auth_notifier.dart';
import '../widgets/auth_widgets.dart';

/// Email/password sign-in screen.
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool _isSubmitting = false;
  String? _errorMessage;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _errorMessage = null;
      _emailError = _validateEmail(email);
      _passwordError = password.isEmpty ? l10n.authPasswordRequired : null;
    });
    if (_emailError != null || _passwordError != null) return;

    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(authNotifierProvider.notifier)
          .login(email: email, password: password);
      // Navigation is handled by the router's auth redirect.
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = describeAuthFailure(context, error, isLogin: true);
      });
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String? _validateEmail(String email) {
    final l10n = context.l10n;
    if (email.isEmpty) return l10n.authEmailRequired;
    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailPattern.hasMatch(email)) return l10n.authEmailInvalid;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return AuthScaffold(
      title: l10n.loginTitle,
      subtitle: l10n.loginSubtitle,
      footer: TextButton(
        onPressed: _isSubmitting ? null : () => context.push('/register'),
        child: Text(
          l10n.noAccountCreateOne,
          style: TextStyle(
            fontSize: 13.sp,
            color: theme.colorScheme.primary,
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
          controller: _emailController,
          label: l10n.email,
          hint: l10n.emailHint,
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          autofillHints: const [AutofillHints.username, AutofillHints.email],
          errorText: _emailError,
          enabled: !_isSubmitting,
        ),
        SizedBox(height: 14.h),
        AuthTextField(
          controller: _passwordController,
          label: l10n.password,
          icon: Icons.lock_outline_rounded,
          obscureText: true,
          textInputAction: TextInputAction.done,
          autofillHints: const [AutofillHints.password],
          errorText: _passwordError,
          onSubmitted: (_) => _submit(),
          enabled: !_isSubmitting,
        ),
        SizedBox(height: 8.h),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: TextButton(
            onPressed: _isSubmitting
                ? null
                : () => context.push('/auth/forgot-password'),
            child: Text(
              l10n.forgotPasswordQuestion,
              style: TextStyle(fontSize: 12.sp),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        AuthSubmitButton(
          label: l10n.signIn,
          loadingLabel: l10n.signingIn,
          isLoading: _isSubmitting,
          onPressed: _submit,
          icon: Icons.login_rounded,
        ),
      ],
    );
  }
}
