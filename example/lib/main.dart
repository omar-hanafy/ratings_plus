import 'package:material_ui/material_ui.dart';
import 'package:ratings_plus/ratings_plus.dart';
import 'package:ratings_plus_example/demo/demo_theme.dart';
import 'package:ratings_plus_example/demo/gallery_page.dart';
import 'package:ratings_plus_example/demo/playground_page.dart';

void main() {
  final params = Uri.base.queryParameters;
  runApp(
    MyApp(
      initialView: params['view'] == 'playground'
          ? DemoView.playground
          : DemoView.gallery,
      initialDarkMode: params['theme'] == 'dark',
      initialRtl: params['rtl'] == 'true',
      initialSection: params['section'],
    ),
  );
}

enum DemoView { gallery, playground }

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    this.initialView = DemoView.gallery,
    this.initialDarkMode = false,
    this.initialRtl = false,
    this.initialSection,
  });

  final DemoView initialView;
  final bool initialDarkMode;
  final bool initialRtl;
  final String? initialSection;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode = widget.initialDarkMode;
  late bool _isRtl = widget.initialRtl;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ratings Plus — Interactive Demo',
      theme: buildDemoLightTheme(),
      darkTheme: buildDemoDarkTheme(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      builder: (context, child) {
        return Directionality(
          textDirection: _isRtl ? TextDirection.rtl : TextDirection.ltr,
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: RatingBarDemo(
        initialView: widget.initialView,
        initialSection: widget.initialSection,
        isDarkMode: _isDarkMode,
        isRtl: _isRtl,
        onToggleTheme: () => setState(() => _isDarkMode = !_isDarkMode),
        onToggleRtl: () => setState(() => _isRtl = !_isRtl),
      ),
    );
  }
}

class RatingBarDemo extends StatefulWidget {
  const RatingBarDemo({
    super.key,
    this.initialView = DemoView.gallery,
    this.initialSection,
    this.isDarkMode = false,
    this.isRtl = false,
    required this.onToggleTheme,
    required this.onToggleRtl,
  });

  final DemoView initialView;
  final String? initialSection;
  final bool isDarkMode;
  final bool isRtl;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleRtl;

  @override
  State<RatingBarDemo> createState() => _RatingBarDemoState();
}

class _RatingBarDemoState extends State<RatingBarDemo> {
  late DemoView _view = widget.initialView;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeroHeader(
                        view: _view,
                        isDarkMode: widget.isDarkMode,
                        isRtl: widget.isRtl,
                        onViewChanged: (next) => setState(() => _view = next),
                        onToggleTheme: widget.onToggleTheme,
                        onToggleRtl: widget.onToggleRtl,
                      ),
                      const SizedBox(height: 22),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _view == DemoView.gallery
                            ? GalleryPage(
                                key: const ValueKey('gallery'),
                                highlightedSection: widget.initialSection,
                              )
                            : const PlaygroundPage(key: ValueKey('playground')),
                      ),
                      const SizedBox(height: 28),
                      Center(
                        child: Text(
                          'Built with ratings_plus · Flutter Material 3 · Keyboard & Screen-Reader Accessible',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? DemoPalette.darkTextSecondary
                                : DemoPalette.lightTextSecondary,
                          ),
                        ),
                      ),
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

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({
    required this.view,
    required this.isDarkMode,
    required this.isRtl,
    required this.onViewChanged,
    required this.onToggleTheme,
    required this.onToggleRtl,
  });

  final DemoView view;
  final bool isDarkMode;
  final bool isRtl;
  final ValueChanged<DemoView> onViewChanged;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleRtl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [Color(0xFF1D2330), Color(0xFF141922)]
              : const [Color(0xFFFFFBF2), Color(0xFFFFFFFF)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? DemoPalette.darkBorder : DemoPalette.lightBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < 820;
            final titleBlock = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DecoratedBox(
                      decoration: BoxDecoration(
                        color: DemoPalette.amber.withValues(
                          alpha: isDark ? 0.18 : 0.14,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.star_rounded,
                          color: DemoPalette.amber,
                          size: 24,
                        ),
                      ),
                    ),
                    Text(
                      'Ratings Plus',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const DemoPill(
                      label: 'Live Demo',
                      color: DemoPalette.amberDeep,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Fractional ratings, custom builders, smooth hover & drag gestures, form validation, and global theming for Flutter.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                RatingBarIndicator(
                  value: 4.6,
                  itemCount: 5,
                  itemSize: 22,
                  spacing: 3,
                  semanticLabel: 'Hero showcase rating',
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star_rounded, color: DemoPalette.amber),
                ),
              ],
            );

            final viewSwitcher = SegmentedButton<DemoView>(
              segments: const [
                ButtonSegment<DemoView>(
                  value: DemoView.gallery,
                  label: Text('Gallery'),
                  icon: Icon(Icons.grid_view_rounded, size: 17),
                ),
                ButtonSegment<DemoView>(
                  value: DemoView.playground,
                  label: Text('Playground'),
                  icon: Icon(Icons.tune_rounded, size: 17),
                ),
              ],
              selected: {view},
              onSelectionChanged: (selection) => onViewChanged(selection.first),
            );

            final togglesRow = Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                OutlinedButton.icon(
                  onPressed: onToggleTheme,
                  icon: Icon(
                    isDarkMode
                        ? Icons.light_mode_rounded
                        : Icons.dark_mode_rounded,
                    size: 17,
                  ),
                  label: Text(isDarkMode ? 'Light' : 'Dark'),
                ),
                OutlinedButton.icon(
                  onPressed: onToggleRtl,
                  icon: const Icon(Icons.format_textdirection_r_to_l, size: 17),
                  label: Text(isRtl ? 'RTL' : 'LTR'),
                ),
              ],
            );

            if (isCompact) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  titleBlock,
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [viewSwitcher, togglesRow],
                  ),
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: titleBlock),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    viewSwitcher,
                    const SizedBox(height: 10),
                    togglesRow,
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
