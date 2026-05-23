import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../l10n/l10n.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  static const _storageKey = 'hasSeenOnboarding';
  static const _slideCount = 3;

  final _controller = PageController();
  int _index = 0;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    if (_saving) return;
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_storageKey, true);
    if (!mounted) return;
    context.go('/projects');
  }

  void _next() {
    if (_index == _slideCount - 1) {
      _finish();
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final l10n = context.l10n;
    final slides = [
      _OnboardingSlide(
        icon: Icons.auto_stories_rounded,
        title: l10n.onboardingOrganizeTitle,
        body: l10n.onboardingOrganizeBody,
      ),
      _OnboardingSlide(
        icon: Icons.manage_search_rounded,
        title: l10n.onboardingAskTitle,
        body: l10n.onboardingAskBody,
      ),
      _OnboardingSlide(
        icon: Icons.translate_rounded,
        title: l10n.onboardingFormatsTitle,
        body: l10n.onboardingFormatsBody,
      ),
    ];
    final isLast = _index == slides.length - 1;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _saving ? null : _finish,
                  child: Text(l10n.skip),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: slides.length,
                  onPageChanged: (value) => setState(() => _index = value),
                  itemBuilder: (context, index) => _OnboardingPanel(
                    slide: slides[index],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < slides.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: i == _index ? 22 : 8,
                      height: 8.h,
                      margin: EdgeInsets.symmetric(horizontal: 4.w),
                      decoration: BoxDecoration(
                        color: i == _index
                            ? colors.primary
                            : colors.onSurface.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 28.h),
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: FilledButton(
                  onPressed: _saving ? null : _next,
                  child: _saving
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(isLast ? l10n.getStarted : l10n.next),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingPanel extends StatelessWidget {
  const _OnboardingPanel({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 112.w,
          height: 112.h,
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(color: colors.primary.withValues(alpha: 0.24)),
          ),
          child: Icon(slide.icon, size: 52.r, color: colors.primary),
        ),
        SizedBox(height: 36.h),
        Text(
          slide.title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: 14.h),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 340.w),
          child: Text(
            slide.body,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.68),
              height: 1.55,
            ),
          ),
        ),
      ],
    );
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}
