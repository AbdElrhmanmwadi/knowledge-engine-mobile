import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/constants.dart';
import '../../../../l10n/l10n.dart';
import '../providers/auth_notifier.dart';
import '../widgets/auth_widgets.dart';

/// Account creation screen. After a successful registration it swaps to a
/// "check your email" confirmation view.
class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  bool _isSubmitting = false;
  bool _registered = false;
  String? _errorMessage;
  String? _emailError;
  String? _usernameError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    setState(() {
      _errorMessage = null;
      _emailError = email.isEmpty
          ? l10n.authEmailRequired
          : (!emailPattern.hasMatch(email) ? l10n.authEmailInvalid : null);
      _usernameError = username.isEmpty ? l10n.authUsernameRequired : null;
      _passwordError = password.length < AuthConstants.minPasswordLength ||
              password.length > AuthConstants.maxPasswordLength
          ? l10n.authPasswordRule
          : null;
    });
    if (_emailError != null ||
        _usernameError != null ||
        _passwordError != null) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await ref.read(authNotifierProvider.notifier).register(
            email: email,
            username: username,
            password: password,
          );
      if (!mounted) return;
      setState(() => _registered = true);
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

    if (_registered) {
      return AuthScaffold(
        title: l10n.checkYourEmailTitle,
        subtitle: l10n.checkYourEmailSubtitle,
        children: [
          Icon(
            Icons.mark_email_unread_outlined,
            size: 48.r,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 16.h),
          Text(
            l10n.checkYourEmailBody(_emailController.text.trim()),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.5,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
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
      title: l10n.registerTitle,
      subtitle: l10n.registerSubtitle,
      footer: TextButton(
        onPressed: _isSubmitting ? null : () => context.go('/login'),
        child: Text(
          l10n.alreadyHaveAccountSignIn,
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
          controller: _emailController,
          label: l10n.email,
          hint: l10n.emailHint,
          icon: Icons.alternate_email_rounded,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          errorText: _emailError,
          enabled: !_isSubmitting,
        ),
        SizedBox(height: 14.h),
        AuthTextField(
          controller: _usernameController,
          label: l10n.username,
          icon: Icons.person_outline_rounded,
          textInputAction: TextInputAction.next,
          errorText: _usernameError,
          enabled: !_isSubmitting,
        ),
        SizedBox(height: 14.h),
        AuthTextField(
          controller: _passwordController,
          label: l10n.password,
          hint: l10n.authPasswordRule,
          icon: Icons.lock_outline_rounded,
          obscureText: true,
          textInputAction: TextInputAction.done,
          errorText: _passwordError,
          onSubmitted: (_) => _submit(),
          enabled: !_isSubmitting,
        ),
        SizedBox(height: 18.h),
        AuthSubmitButton(
          label: l10n.createAccount,
          loadingLabel: l10n.creatingAccount,
          isLoading: _isSubmitting,
          onPressed: _submit,
          icon: Icons.person_add_alt_rounded,
        ),
      ],
    );
  }
}
