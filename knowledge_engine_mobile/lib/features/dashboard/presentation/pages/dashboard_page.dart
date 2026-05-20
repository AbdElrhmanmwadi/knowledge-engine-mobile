import 'dart:math' as math;

import 'package:flutter/material.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          // ── Hero app bar ────────────────────────────────────────
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            expandedHeight: 230,
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
                fontSize: 18,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
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
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Section label
                const _Label('What would you like to do?'),
                const SizedBox(height: 14),

                // Feature cards grid (2 cols)
                _FeatureGrid(projectId: widget.projectId),

                const SizedBox(height: 24),
               
              ]),
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
          bottom: 28,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Project badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                ),
                child: Text(
                  'PROJECT #$projectId',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Your project\nis ready',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pick what you want to do next.',
                style: TextStyle(
                  fontSize: 13,
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

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _FeatureCard(feature: features[0])),
            const SizedBox(width: 12),
            Expanded(child: _FeatureCard(feature: features[1])),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _FeatureCard(feature: features[2])),
            const SizedBox(width: 12),
            Expanded(child: _FeatureCard(feature: features[3])),
          ],
        ),
      ],
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
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        f.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _pressed ? f.color.withOpacity(0.12) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
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
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: f.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: f.color.withOpacity(0.25)),
              ),
              child: Icon(f.icon, color: f.color, size: 22),
            ),
            const SizedBox(height: 14),
            Text(
              f.title,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              f.description,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 11,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            // Arrow indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: f.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: f.color,
                    size: 14,
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
    return Text(
      text.toUpperCase(),
      style: TextStyle(
        color: Theme.of(context).textTheme.bodyMedium?.color,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
      ),
    );
  }
}
