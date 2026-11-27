import 'package:material_ui/material_ui.dart';
import 'package:ratings_plus/ratings_plus.dart';

class DemoPalette {
  const DemoPalette._();

  static const Color lightBackground = Color(0xFFF6F5F0);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSubtle = Color(0xFFF1EFE9);
  static const Color lightBorder = Color(0xFFE5E1D8);
  static const Color lightTextPrimary = Color(0xFF18181B);
  static const Color lightTextSecondary = Color(0xFF52525B);

  static const Color darkBackground = Color(0xFF0E1117);
  static const Color darkSurface = Color(0xFF161B22);
  static const Color darkSurfaceSubtle = Color(0xFF1F2631);
  static const Color darkBorder = Color(0xFF2B3340);
  static const Color darkTextPrimary = Color(0xFFF4F4F5);
  static const Color darkTextSecondary = Color(0xFFA1A1AA);

  static const Color amber = Color(0xFFF59E0B);
  static const Color amberDeep = Color(0xFFD97706);
  static const Color rose = Color(0xFFF43F5E);
  static const Color indigo = Color(0xFF6366F1);
  static const Color emerald = Color(0xFF10B981);
  static const Color flame = Color(0xFFF97316);
  static const Color violet = Color(0xFF8B5CF6);
}

ThemeData buildDemoLightTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: DemoPalette.amber,
        brightness: Brightness.light,
      ).copyWith(
        primary: DemoPalette.amberDeep,
        onPrimary: Colors.white,
        secondary: DemoPalette.indigo,
        surface: DemoPalette.lightSurface,
        onSurface: DemoPalette.lightTextPrimary,
        onSurfaceVariant: DemoPalette.lightTextSecondary,
        outlineVariant: DemoPalette.lightBorder,
      );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: scheme,
    scaffoldBackgroundColor: DemoPalette.lightBackground,
    dividerColor: DemoPalette.lightBorder,
    extensions: const [
      RatingBarThemeData(
        itemSize: 40,
        spacing: 4,
        glowColor: DemoPalette.amber,
        unratedColor: Color(0xFFD4D0C7),
      ),
    ],
  );
}

ThemeData buildDemoDarkTheme() {
  final scheme =
      ColorScheme.fromSeed(
        seedColor: DemoPalette.amber,
        brightness: Brightness.dark,
      ).copyWith(
        primary: DemoPalette.amber,
        onPrimary: const Color(0xFF1A1300),
        secondary: const Color(0xFF818CF8),
        surface: DemoPalette.darkSurface,
        onSurface: DemoPalette.darkTextPrimary,
        onSurfaceVariant: DemoPalette.darkTextSecondary,
        outlineVariant: DemoPalette.darkBorder,
      );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: DemoPalette.darkBackground,
    dividerColor: DemoPalette.darkBorder,
    extensions: const [
      RatingBarThemeData(
        itemSize: 40,
        spacing: 4,
        glowColor: DemoPalette.amber,
        unratedColor: Color(0xFF333B4A),
      ),
    ],
  );
}

class ShowcaseCard extends StatelessWidget {
  const ShowcaseCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.child,
    this.highlighted = false,
  });

  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final Widget child;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark ? DemoPalette.darkSurface : DemoPalette.lightSurface;
    final border = highlighted
        ? badgeColor.withValues(alpha: 0.7)
        : (isDark ? DemoPalette.darkBorder : DemoPalette.lightBorder);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: highlighted ? 1.5 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.045),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                DemoPill(label: badge, color: badgeColor),
              ],
            ),
            const SizedBox(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class DemoPill extends StatelessWidget {
  const DemoPill({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.11),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.35 : 0.24),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 13, color: color),
              const SizedBox(width: 5),
            ],
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DemoStage extends StatelessWidget {
  const DemoStage({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? DemoPalette.darkSurfaceSubtle
            : DemoPalette.lightSurfaceSubtle,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? DemoPalette.darkBorder : DemoPalette.lightBorder,
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
