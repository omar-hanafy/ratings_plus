import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:ratings_plus/ratings_plus.dart';
import 'package:ratings_plus_example/demo/demo_theme.dart';

enum _ShapePreset {
  stars(
    'Stars',
    Icons.star_rounded,
    Icons.star_outline_rounded,
    DemoPalette.amber,
  ),
  hearts(
    'Hearts',
    Icons.favorite_rounded,
    Icons.favorite_border_rounded,
    DemoPalette.rose,
  ),
  bolts('Bolts', Icons.bolt_rounded, Icons.bolt_outlined, DemoPalette.indigo),
  fire(
    'Fire',
    Icons.local_fire_department_rounded,
    Icons.local_fire_department_outlined,
    DemoPalette.flame,
  );

  const _ShapePreset(this.label, this.filled, this.outlined, this.color);

  final String label;
  final IconData filled;
  final IconData outlined;
  final Color color;
}

class PlaygroundPage extends StatefulWidget {
  const PlaygroundPage({super.key});

  @override
  State<PlaygroundPage> createState() => _PlaygroundPageState();
}

class _PlaygroundPageState extends State<PlaygroundPage> {
  double _value = 3.5;
  int _itemCount = 5;
  double _step = 0.5;
  double _itemSize = 46;
  double _spacing = 6;
  bool _allowClear = true;
  bool _enableHover = true;
  bool _glow = true;
  bool _vertical = false;
  bool _useUnratedBuilder = true;
  RatingGestureMode _gestureMode = RatingGestureMode.tapAndDrag;
  _ShapePreset _preset = _ShapePreset.stars;
  String _lastCallback = 'Ready — interact with the preview above';
  bool _copied = false;

  String _generateSnippet() {
    final buffer = StringBuffer()
      ..writeln('RatingBar(')
      ..writeln('  value: ${_value.toStringAsFixed(_step == 0.0 ? 2 : 1)},')
      ..writeln('  itemCount: $_itemCount,')
      ..writeln('  step: $_step,')
      ..writeln('  itemSize: ${_itemSize.round()},')
      ..writeln('  spacing: ${_spacing.round()},')
      ..writeln('  gestureMode: RatingGestureMode.${_gestureMode.name},')
      ..writeln('  allowClear: $_allowClear,')
      ..writeln('  enableHover: $_enableHover,')
      ..writeln('  glow: $_glow,');
    if (_vertical) {
      buffer
        ..writeln('  direction: Axis.vertical,')
        ..writeln('  verticalDirection: VerticalDirection.up,');
    }
    final iconName = switch (_preset) {
      _ShapePreset.stars => 'Icons.star_rounded',
      _ShapePreset.hearts => 'Icons.favorite_rounded',
      _ShapePreset.bolts => 'Icons.bolt_rounded',
      _ShapePreset.fire => 'Icons.local_fire_department_rounded',
    };
    final unratedIconName = switch (_preset) {
      _ShapePreset.stars => 'Icons.star_outline_rounded',
      _ShapePreset.hearts => 'Icons.favorite_border_rounded',
      _ShapePreset.bolts => 'Icons.bolt_outlined',
      _ShapePreset.fire => 'Icons.local_fire_department_outlined',
    };
    final colorName = switch (_preset) {
      _ShapePreset.stars => 'Colors.amber',
      _ShapePreset.hearts => 'Colors.pinkAccent',
      _ShapePreset.bolts => 'Colors.indigo',
      _ShapePreset.fire => 'Colors.deepOrange',
    };
    buffer.writeln(
      '  itemBuilder: (context, _) =>\n'
      '      const Icon($iconName, color: $colorName),',
    );
    if (_useUnratedBuilder) {
      buffer.writeln(
        '  unratedBuilder: (context, _) =>\n'
        '      const Icon($unratedIconName, color: Colors.grey),',
      );
    }
    buffer
      ..writeln('  onChanged: (value) => setState(() => _rating = value),')
      ..write(')');
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;
        final previewColumn = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPreviewCard(context),
            const SizedBox(height: 18),
            _buildCodeCard(context),
          ],
        );
        final controlsCard = _buildControlsCard(context);

        if (!isWide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [previewColumn, const SizedBox(height: 18), controlsCard],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: previewColumn),
            const SizedBox(width: 20),
            Expanded(flex: 5, child: controlsCard),
          ],
        );
      },
    );
  }

  Widget _buildPreviewCard(BuildContext context) {
    final theme = Theme.of(context);
    final decimals = _step == 0.0 ? 2 : 1;
    final formattedValue = _value.toStringAsFixed(decimals);
    final formattedMax = _itemCount.toDouble().toStringAsFixed(decimals);

    return ShowcaseCard(
      title: 'Live Interactive Preview',
      subtitle:
          'Test gestures, hover previews, keyboard arrows (Tab to focus), and glow live.',
      badge: '$formattedValue / $formattedMax',
      badgeColor: _preset.color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DemoStage(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 34),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: RatingBar(
                    value: _value.clamp(0.0, _itemCount.toDouble()),
                    itemCount: _itemCount,
                    step: _step,
                    itemSize: _itemSize,
                    spacing: _spacing,
                    direction: _vertical ? Axis.vertical : Axis.horizontal,
                    verticalDirection: VerticalDirection.up,
                    gestureMode: _gestureMode,
                    allowClear: _allowClear,
                    enableHover: _enableHover,
                    glow: _glow,
                    glowColor: _preset.color,
                    semanticLabel: 'Playground rating',
                    itemBuilder: (context, _) =>
                        Icon(_preset.filled, color: _preset.color),
                    unratedBuilder: _useUnratedBuilder
                        ? (context, _) => Icon(
                            _preset.outlined,
                            color: _preset.color.withValues(alpha: 0.34),
                          )
                        : null,
                    onChangeStart: (v) => setState(
                      () => _lastCallback =
                          'onChangeStart(${v.toStringAsFixed(decimals)})',
                    ),
                    onChanged: _gestureMode == RatingGestureMode.none
                        ? null
                        : (v) => setState(() {
                            _value = v;
                            _lastCallback =
                                'onChanged(${v.toStringAsFixed(decimals)})';
                          }),
                    onChangeEnd: (v) => setState(
                      () => _lastCallback =
                          'onChangeEnd(${v.toStringAsFixed(decimals)})',
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    DemoPill(
                      label: _lastCallback,
                      color: _preset.color,
                      icon: Icons.bolt_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Text(
                'Quick value:',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final presetVal in [
                      0.0,
                      1.5,
                      3.5,
                      _itemCount.toDouble(),
                    ])
                      ActionChip(
                        label: Text(presetVal.toStringAsFixed(1)),
                        visualDensity: VisualDensity.compact,
                        onPressed: () => setState(() {
                          _value = presetVal.clamp(0.0, _itemCount.toDouble());
                          _lastCallback =
                              'Programmatic value(${_value.toStringAsFixed(decimals)})';
                        }),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCodeCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final snippet = _generateSnippet();

    return ShowcaseCard(
      title: 'Generated Dart Snippet',
      subtitle:
          'Updates automatically as you tweak properties in the playground.',
      badge: 'Copy & Paste',
      badgeColor: DemoPalette.indigo,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B0E14) : const Color(0xFF18181B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? DemoPalette.darkBorder
                    : const Color(0xFF27272A),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                snippet,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12.5,
                  height: 1.55,
                  color: Color(0xFFE4E4E7),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: FilledButton.tonalIcon(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: snippet));
                if (!mounted) return;
                setState(() => _copied = true);
                Future<void>.delayed(const Duration(seconds: 2), () {
                  if (mounted) setState(() => _copied = false);
                });
              },
              icon: Icon(
                _copied ? Icons.check_rounded : Icons.copy_rounded,
                size: 16,
              ),
              label: Text(_copied ? 'Copied!' : 'Copy Dart Code'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlsCard(BuildContext context) {
    final theme = Theme.of(context);

    return ShowcaseCard(
      title: 'Configuration',
      subtitle:
          'Tune step precision, gestures, layout geometry, and visual effects.',
      badge: 'Controls',
      badgeColor: DemoPalette.emerald,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Item Style',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in _ShapePreset.values)
                ChoiceChip(
                  showCheckmark: false,
                  avatar: Icon(preset.filled, size: 16, color: preset.color),
                  label: Text(preset.label),
                  selected: _preset == preset,
                  onSelected: (_) => setState(() => _preset = preset),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Step Precision',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final option in const [
                (1.0, 'Whole (1.0)'),
                (0.5, 'Half (0.5)'),
                (0.1, 'Tenth (0.1)'),
                (0.0, 'Continuous'),
              ])
                ChoiceChip(
                  label: Text(option.$2),
                  selected: _step == option.$1,
                  onSelected: (_) => setState(() => _step = option.$1),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Gesture Mode',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final mode in RatingGestureMode.values)
                ChoiceChip(
                  label: Text(mode.name),
                  selected: _gestureMode == mode,
                  onSelected: (_) => setState(() => _gestureMode = mode),
                ),
            ],
          ),
          const SizedBox(height: 16),
          _SliderRow(
            label: 'Item Count',
            valueLabel: '$_itemCount',
            value: _itemCount.toDouble(),
            min: 3,
            max: 7,
            divisions: 4,
            onChanged: (v) => setState(() {
              _itemCount = v.round();
              if (_value > _itemCount) _value = _itemCount.toDouble();
            }),
          ),
          _SliderRow(
            label: 'Item Size',
            valueLabel: '${_itemSize.round()} px',
            value: _itemSize,
            min: 24,
            max: 56,
            divisions: 8,
            onChanged: (v) => setState(() => _itemSize = v),
          ),
          _SliderRow(
            label: 'Spacing',
            valueLabel: '${_spacing.round()} px',
            value: _spacing,
            min: 0,
            max: 16,
            divisions: 8,
            onChanged: (v) => setState(() => _spacing = v),
          ),
          const Divider(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              FilterChip(
                label: const Text('allowClear'),
                selected: _allowClear,
                onSelected: (v) => setState(() => _allowClear = v),
              ),
              FilterChip(
                label: const Text('enableHover'),
                selected: _enableHover,
                onSelected: (v) => setState(() => _enableHover = v),
              ),
              FilterChip(
                label: const Text('glow'),
                selected: _glow,
                onSelected: (v) => setState(() => _glow = v),
              ),
              FilterChip(
                label: const Text('Vertical'),
                selected: _vertical,
                onSelected: (v) => setState(() => _vertical = v),
              ),
              FilterChip(
                label: const Text('unratedBuilder'),
                selected: _useUnratedBuilder,
                onSelected: (v) => setState(() => _useUnratedBuilder = v),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.valueLabel,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  final String label;
  final String valueLabel;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              valueLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
