import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/widgets/wave_background.dart';
import '../../../../l10n/l10n.dart';
import '../providers/translation_provider.dart';
import '../widgets/job_creation_section.dart';
import '../widgets/job_status_section.dart';

// ── Shared design tokens (mirror voice_page.dart) ──────────────────────────
// shared tokens removed — use Theme / AppColors instead

/// Translate Page — redesigned to match Voice Page aesthetic.
class TranslatePage extends ConsumerStatefulWidget {
  const TranslatePage({super.key, required this.projectId});
  final int projectId;

  @override
  ConsumerState<TranslatePage> createState() => _TranslatePageState();
}

class _TranslatePageState extends ConsumerState<TranslatePage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(translationStateProvider(widget.projectId));

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: LoadingOverlay(
        isLoading: state.isBusy,
        message: state.activeLoadingMessage,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              expandedHeight: 210.h,
              pinned: true,
              elevation: 0,
              title: Text(
                context.l10n.fileTranslationTitle,
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              centerTitle: false,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: _TranslateHero(
                  projectId: widget.projectId,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  JobCreationSection(projectId: widget.projectId),
                  SizedBox(height: 16.h),
                  JobStatusSection(projectId: widget.projectId),
                  SizedBox(height: 32.h),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero header ────────────────────────────────────────────────────────────
class _TranslateHero extends StatelessWidget {
  const _TranslateHero({
    required this.projectId,
  });

  final int projectId;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                Theme.of(context).colorScheme.secondary.withValues(alpha: 0.08),
              ],
            ),
          ),
        ),
        AnimatedWaves(
          color1: Theme.of(context).colorScheme.primary.withValues(alpha: 0.18),
          color2: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
        ),
        Positioned(
          bottom: 24,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35)),
                ),
                child: Text(
                  context.l10n.projectBadge(projectId),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                context.l10n.translateHeroTitle(projectId),
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 26.sp,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                context.l10n.translateHeroSubtitle,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

