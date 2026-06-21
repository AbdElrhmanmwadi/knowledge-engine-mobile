import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_radius.dart';
import '../../../../core/widgets/directional_icon.dart';
import '../../../../l10n/l10n.dart';
import '../../data/models/auth_failure.dart';

/// Shared scrollable scaffold for all auth pages: brand badge, serif title,
/// subtitle and a card containing the form fields.
///
/// Renders an animated wave background (matching the Files and Onboarding
/// pages) behind the form to keep the app's visual identity consistent.
class AuthScaffold extends StatefulWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.children,
    this.footer,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? footer;

  @override
  State<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Animated wave background (same style as Files / Onboarding pages).
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.scaffoldBackgroundColor,
                  colors.primary.withValues(alpha: 0.35),
                  colors.secondary.withValues(alpha: 0.1),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 220.h,
            child: AnimatedBuilder(
              animation: _waveController,
              builder: (_, _) => CustomPaint(
                size: Size.infinite,
                painter: _WavePainter(
                  progress: _waveController.value,
                  color1: colors.primary.withValues(alpha: 0.16),
                  color2: colors.secondary.withValues(alpha: 0.1),
                ),
              ),
            ),
          ),
          SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.32),
                    ),
                  ),
                  child: Text(
                    context.l10n.knowledgeEngineUpper,
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  widget.title,
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w700,
                    color: theme.textTheme.bodyLarge?.color,
                    height: 1.2,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  widget.subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: theme.textTheme.bodyLarge?.color
                        ?.withValues(alpha: 0.5),
                  ),
                ),
                SizedBox(height: 24.h),
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20.r),
                    border:
                        Border.all(color: Colors.white.withValues(alpha: 0.07)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: widget.children,
                  ),
                ),
                if (widget.footer != null) ...[
                  SizedBox(height: 18.h),
                  Center(child: widget.footer),
                ],
              ],
            ),
          ),
        ),
          ),
        ],
      ),
    );
  }
}

class _WavePainter extends CustomPainter {
  const _WavePainter(
      {required this.progress, required this.color1, required this.color2});
  final double progress;
  final Color color1;
  final Color color2;

  @override
  void paint(Canvas canvas, Size size) {
    void wave(Color c, double amp, double speed, double off) {
      final p = Paint()
        ..color = c
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      final path = Path();
      final phase = (progress * speed + off) * 2 * math.pi;
      path.moveTo(0, size.height * 0.6);
      for (double x = 0; x <= size.width; x++) {
        path.lineTo(
            x,
            size.height * 0.6 +
                math.sin(x / size.width * 3 * math.pi + phase) * amp);
      }
      canvas.drawPath(path, p);
    }

    wave(color1, 14, 0.55, 0.0);
    wave(color1.withValues(alpha: 0.5), 9, 1.0, 0.5);
    wave(color2, 18, 0.4, 1.0);
    wave(color2.withValues(alpha: 0.4), 6, 1.2, 1.5);
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.progress != progress;
}

/// Text field styled consistently with the rest of the app.
///
/// When [obscureText] is true a show/hide toggle is added automatically so
/// users can verify what they typed. Pass [autofillHints] to let the OS /
/// password manager offer saved credentials.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.errorText,
    this.onSubmitted,
    this.enabled = true,
    this.autofillHints,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final IconData? icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? errorText;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final Iterable<String>? autofillHints;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _obscured = widget.obscureText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextField(
      controller: widget.controller,
      obscureText: _obscured,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      autocorrect: false,
      autofillHints: widget.autofillHints,
      style: TextStyle(
        color: theme.textTheme.bodyLarge?.color,
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        errorMaxLines: 3,
        prefixIcon: widget.icon != null
            ? Icon(
                widget.icon,
                size: 18.r,
                color: theme.textTheme.bodyMedium?.color,
              )
            : null,
        suffixIcon: widget.obscureText
            ? IconButton(
                tooltip: _obscured
                    ? context.l10n.showPassword
                    : context.l10n.hidePassword,
                icon: Icon(
                  _obscured
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20.r,
                  color: theme.textTheme.bodyMedium?.color,
                ),
                onPressed: widget.enabled
                    ? () => setState(() => _obscured = !_obscured)
                    : null,
              )
            : null,
      ),
    );
  }
}

/// Primary filled submit button with loading state.
class AuthSubmitButton extends StatelessWidget {
  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.loadingLabel,
    required this.isLoading,
    required this.onPressed,
    this.enabled = true,
    this.icon = Icons.arrow_forward_rounded,
  });

  final String label;
  final String loadingLabel;
  final bool isLoading;
  final VoidCallback onPressed;
  final bool enabled;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: isLoading || !enabled ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          disabledBackgroundColor:
              theme.colorScheme.primary.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        icon: isLoading
            ? SizedBox(
                width: 16.w,
                height: 16.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : DirectionalIcon(icon, size: 18.r),
        label: Text(isLoading ? loadingLabel : label),
      ),
    );
  }
}

/// Inline error banner matching the app's alert style.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: color, size: 16.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 12.sp, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

/// Success banner used after register / reset / verify flows.
class AuthSuccessBanner extends StatelessWidget {
  const AuthSuccessBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.secondary;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline_rounded, color: color, size: 16.r),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 12.sp, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}

/// Maps an [AuthFailure] (or any error) to a localized, user-friendly
/// message following the backend error contract.
String describeAuthFailure(
  BuildContext context,
  Object error, {
  bool isLogin = false,
  bool isPasswordReset = false,
}) {
  final l10n = context.l10n;

  if (error is! AuthFailure) {
    return l10n.authErrorGeneric;
  }

  if (isLogin) {
    if (error.statusCode == 401) return l10n.authErrorInvalidCredentials;
    if (error.isGoogleOnlyAccount) return l10n.authErrorGoogleAccount;
    if (error.statusCode == 403) return l10n.authErrorEmailNotVerified;
  }

  if (isPasswordReset) {
    if (error.statusCode == 401) {
      return error.message.toLowerCase().contains('expired')
          ? l10n.authErrorResetLinkExpired
          : l10n.authErrorResetLinkInvalid;
    }
    if (error.statusCode == 422) return l10n.authPasswordRule;
  }

  if (error.isNetworkError) return l10n.authErrorNetwork;

  return error.message;
}
