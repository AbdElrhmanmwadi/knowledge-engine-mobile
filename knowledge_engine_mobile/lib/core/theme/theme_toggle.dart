import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme_controller.dart';

class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);

    return Card(
      color: Colors.transparent,
      elevation: 0,
      child: PopupMenuButton<ThemeMode>(
        icon: Icon(
          mode == ThemeMode.dark
              ? Icons.dark_mode
              : mode == ThemeMode.light
                  ? Icons.light_mode
                  : Icons.brightness_auto,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onSelected: (m) => notifier.setTheme(m),
        itemBuilder: (_) => [
          PopupMenuItem(value: ThemeMode.light, child: Text('Light')),
          PopupMenuItem(value: ThemeMode.dark, child: Text('Dark')),
          PopupMenuItem(value: ThemeMode.system, child: Text('System')),
        ],
      ),
    );
  }
}
