import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

// Local design tokens removed — use Theme / AppColors instead

/// Dashboard Page — project hub with feature navigation.
class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key, required this.projectId}) : super(key: key);
  final int projectId;

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _wave;

  @override
  void initState() {
    super.initState();
    _wave = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _wave.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final layout = _DashboardLayout.fromContext(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Hero app bar ────────────────────────────────────────
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            expandedHeight: layout.heroHeight,
            pinned: true,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded,
                  color: Colors.transparent),
              onPressed: () => context.go('/projects'),
            ),
            title: Text(
              'Workspace',
              style: TextStyle(
                fontFamily: 'Georgia',
                fontSize: layout.appBarTitleSize,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            centerTitle: false,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: _DashboardHero(
                projectId: widget.projectId,
                waveController: _wave,
              ),
            ),
          ),

          // ── Body ────────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: layout.horizontalPadding,
              vertical: layout.sectionSpacing,
            ),
            sliver: SliverToBoxAdapter(
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 1120.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section label
                      const _Label('What would you like to do?'),
                      SizedBox(height: layout.itemSpacing),

                      // Feature cards grid
                      _FeatureGrid(projectId: widget.projectId),

                      SizedBox(height: layout.sectionSpacing),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Hero header ──────────────────────────────────────────────────────────────
class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.projectId,
    required this.waveController,
  });
  final int projectId;
  final AnimationController waveController;

  @override
  Widget build(BuildContext context) {
    final layout = _DashboardLayout.fromContext(context);

    return Stack(
      fit: StackFit.expand,
      children: [
        // Gradient bg — subtle multi-color blend
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).scaffoldBackgroundColor,
                Theme.of(context).colorScheme.primary.withOpacity(0.22),
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ],
            ),
          ),
        ),
        // Animated waves
        AnimatedBuilder(
          animation: waveController,
          builder: (_, __) => CustomPaint(
            painter: _WavePainter(
              progress: waveController.value,
              color1: Theme.of(context).colorScheme.primary.withOpacity(0.15),
              color2: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
            ),
          ),
        ),
        // Content
        Positioned(
          bottom: layout.heroBottomPadding,
          left: layout.horizontalPadding,
          right: layout.horizontalPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Project badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20.r),
                  border:
                      Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                ),
                child: Text(
                  'PROJECT #$projectId',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: layout.badgeFontSize,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              SizedBox(height: layout.smallSpacing),
              Text(
                'Your project\nis ready',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: layout.heroTitleSize,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  height: 1.2,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: layout.tinySpacing),
              Text(
                'Pick what you want to do next.',
                style: TextStyle(
                  fontSize: layout.bodyFontSize,
                  color: Theme.of(context).textTheme.bodyLarge?.color?.withOpacity(0.5),
                ),
              ),
            ],
          ),
        ),
      ],
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
        path.lineTo(x,
            size.height * 0.6 +
                math.sin(x / size.width * 3 * math.pi + phase) * amp);
      }
      canvas.drawPath(path, p);
    }

    wave(color1, 14, 0.55, 0.0);
    wave(color1.withOpacity(0.5), 8, 1.0, 0.5);
    wave(color2, 18, 0.4, 1.0);
    wave(color2.withOpacity(0.4), 6, 1.2, 1.5);
  }

  @override
  bool shouldRepaint(_WavePainter old) => old.progress != progress;
}

// ── Feature grid ─────────────────────────────────────────────────────────────
class _FeatureGrid extends StatelessWidget {
  const _FeatureGrid({required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context) {
    final layout = _DashboardLayout.fromContext(context);
    final features = [
      _Feature(
        title: 'Documents',
        description: 'Upload & index files',
        icon: Icons.folder_open_rounded,
        color: Theme.of(context).colorScheme.secondary,
        onTap: () => context.push('/files', extra: projectId),
      ),
      _Feature(
        title: 'Ask AI',
        description: 'Search & get answers',
        icon: Icons.auto_awesome_rounded,
        color: Theme.of(context).colorScheme.primary,
        onTap: () => context.push('/ask', extra: projectId),
      ),
      _Feature(
        title: 'Voice',
        description: 'Speak, transcribe, listen',
        icon: Icons.mic_rounded,
        color: Theme.of(context).colorScheme.tertiary ?? Theme.of(context).colorScheme.primary,
        onTap: () => context.push('/voice', extra: projectId),
      ),
      _Feature(
        title: 'Translate',
        description: 'Translate & download',
        icon: Icons.translate_rounded,
        color: Theme.of(context).colorScheme.tertiaryContainer ?? Theme.of(context).colorScheme.secondary,
        onTap: () => context.push('/translate', extra: projectId),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = layout.featureColumnsFor(constraints.maxWidth);

        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: features.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: layout.cardSpacing,
            mainAxisSpacing: layout.cardSpacing,
            mainAxisExtent: layout.cardHeightFor(columns),
          ),
          itemBuilder: (context, index) {
            return _FeatureCard(feature: features[index]);
          },
        );
      },
    );
  }
}

class _Feature {
  const _Feature({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _FeatureCard extends StatefulWidget {
  const _FeatureCard({required this.feature});
  final _Feature feature;

  @override
  State<_FeatureCard> createState() => _FeatureCardState();
}

class _FeatureCardState extends State<_FeatureCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final f = widget.feature;
    final layout = _DashboardLayout.fromContext(context);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        f.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: EdgeInsets.all(layout.cardPadding),
        decoration: BoxDecoration(
          color: _pressed ? f.color.withOpacity(0.12) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: _pressed
                ? f.color.withOpacity(0.4)
                : f.color.withOpacity(0.18),
            width: _pressed ? 1.5 : 1,
          ),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: f.color.withOpacity(0.1),
                    blurRadius: 16,
                    spreadRadius: 1,
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: layout.iconBoxSize,
              height: layout.iconBoxSize,
              decoration: BoxDecoration(
                color: f.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(13.r),
                border: Border.all(color: f.color.withOpacity(0.25)),
              ),
              child: Icon(f.icon, color: f.color, size: layout.iconSize),
            ),
            SizedBox(height: layout.itemSpacing),
            Text(
              f.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: layout.cardTitleSize,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: layout.tinySpacing),
            Text(
              f.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: layout.cardDescriptionSize,
                height: 1.4,
              ),
            ),
            const Spacer(),
            // Arrow indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: layout.arrowBoxSize,
                  height: layout.arrowBoxSize,
                  decoration: BoxDecoration(
                    color: f.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: f.color,
                    size: layout.arrowIconSize,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    final layout = _DashboardLayout.fromContext(context);

    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyMedium?.color,
        fontSize: layout.labelFontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }
}

class _DashboardLayout {
  const _DashboardLayout._(this.screenWidth);

  factory _DashboardLayout.fromContext(BuildContext context) {
    return _DashboardLayout._(MediaQuery.sizeOf(context).width);
  }

  final double screenWidth;

  bool get _isTablet => screenWidth >= 600;
  bool get _isWide => screenWidth >= 1024;

  double get horizontalPadding => _responsiveWidth(16, 28, 40);
  double get heroHeight => _responsiveHeight(220, 260, 300);
  double get heroBottomPadding => _responsiveHeight(24, 32, 40);
  double get sectionSpacing => _responsiveHeight(16, 22, 28);
  double get cardSpacing => _responsiveWidth(12, 16, 18);
  double get cardPadding => _responsiveRadius(16, 18, 20);
  double get smallSpacing => _responsiveHeight(10, 12, 14);
  double get itemSpacing => _responsiveHeight(12, 14, 16);
  double get tinySpacing => _responsiveHeight(4, 6, 6);

  double get appBarTitleSize => _responsiveFont(18, 19, 20);
  double get badgeFontSize => _responsiveFont(10, 11, 11);
  double get heroTitleSize => _responsiveFont(26, 32, 38);
  double get bodyFontSize => _responsiveFont(13, 14, 15);
  double get labelFontSize => _responsiveFont(11, 12, 12);
  double get cardTitleSize => _responsiveFont(14, 15, 16);
  double get cardDescriptionSize => _responsiveFont(11, 12, 13);

  double get iconBoxSize => _responsiveRadius(42, 46, 50);
  double get iconSize => _responsiveRadius(21, 23, 25);
  double get arrowBoxSize => _responsiveRadius(24, 26, 28);
  double get arrowIconSize => _responsiveRadius(14, 15, 16);

  int featureColumnsFor(double availableWidth) {
    if (availableWidth >= 980) return 4;
    if (availableWidth >= 520) return 2;
    return 1;
  }

  double cardHeightFor(int columns) {
    if (columns == 1) return (_isTablet ? 156 : 148).h;
    if (columns == 2) return (_isTablet ? 172 : 164).h;
    return (_isWide ? 178 : 168).h;
  }

  double _responsiveWidth(double mobile, double tablet, double wide) {
    if (_isWide) return wide.w;
    if (_isTablet) return tablet.w;
    return mobile.w;
  }

  double _responsiveHeight(double mobile, double tablet, double wide) {
    if (_isWide) return wide.h;
    if (_isTablet) return tablet.h;
    return mobile.h;
  }

  double _responsiveRadius(double mobile, double tablet, double wide) {
    if (_isWide) return wide.r;
    if (_isTablet) return tablet.r;
    return mobile.r;
  }

  double _responsiveFont(double mobile, double tablet, double wide) {
    if (_isWide) return wide.sp;
    if (_isTablet) return tablet.sp;
    return mobile.sp;
  }
}
