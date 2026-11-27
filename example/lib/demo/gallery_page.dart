import 'package:material_ui/material_ui.dart';
import 'package:ratings_plus/ratings_plus.dart';
import 'package:ratings_plus_example/demo/demo_theme.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key, this.highlightedSection});

  final String? highlightedSection;

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  double _basicRating = 4.0;
  String _basicEvent = 'Tap, drag, or hover to preview';

  double _fractionalRating = 2.5;
  double _continuousRating = 3.74;

  double _moodRating = 4.0;
  double _heartRating = 3.5;
  double _scaledScore = 76.0;

  double _heatLevel = 3.0;
  double _signalLevel = 3.5;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Set<String> _selectedTags = {'Smooth Drag', 'Fractional Precision'};
  double _submittedFormRating = 0.0;
  bool _formSubmitted = false;
  int _formResetSeed = 0;

  final GlobalKey _interactiveKey = GlobalKey();
  final GlobalKey _customKey = GlobalKey();
  final GlobalKey _verticalKey = GlobalKey();
  final GlobalKey _reviewsKey = GlobalKey();
  final GlobalKey _formSectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    if (widget.highlightedSection != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSection(widget.highlightedSection!);
      });
    }
  }

  void _scrollToSection(String section) {
    final targetKey = switch (section) {
      'interactive' || 'fractional' => _interactiveKey,
      'custom' || 'mood' => _customKey,
      'vertical' || 'layout' => _verticalKey,
      'reviews' || 'indicator' => _reviewsKey,
      'form' || 'forms' => _formSectionKey,
      _ => null,
    };
    final targetContext = targetKey?.currentContext;
    if (targetContext != null) {
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        alignment: 0.05,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 900;

        final interactiveCard = KeyedSubtree(
          key: _interactiveKey,
          child: _buildInteractiveCard(context),
        );
        final customCard = KeyedSubtree(
          key: _customKey,
          child: _buildCustomBuildersCard(context),
        );
        final verticalCard = KeyedSubtree(
          key: _verticalKey,
          child: _buildVerticalAndRtlCard(context),
        );
        final reviewsCard = KeyedSubtree(
          key: _reviewsKey,
          child: _buildReviewsSummaryCard(context),
        );
        final formCard = KeyedSubtree(
          key: _formSectionKey,
          child: _buildFormCard(context),
        );

        if (!isWide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              interactiveCard,
              const SizedBox(height: 18),
              customCard,
              const SizedBox(height: 18),
              verticalCard,
              const SizedBox(height: 18),
              reviewsCard,
              const SizedBox(height: 18),
              formCard,
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: interactiveCard),
                const SizedBox(width: 20),
                Expanded(child: customCard),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 5, child: reviewsCard),
                const SizedBox(width: 20),
                Expanded(flex: 5, child: formCard),
              ],
            ),
            const SizedBox(height: 20),
            verticalCard,
          ],
        );
      },
    );
  }

  Widget _buildInteractiveCard(BuildContext context) {
    final theme = Theme.of(context);
    return ShowcaseCard(
      title: 'Interactive & Fractional Input',
      subtitle:
          'Hover previews, half-star steps, continuous precision, and scroll-safe taps.',
      badge: 'RatingBar',
      badgeColor: DemoPalette.amberDeep,
      highlighted:
          widget.highlightedSection == 'interactive' ||
          widget.highlightedSection == 'fractional',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionLabel(
            title: 'Tap, Drag & Hover Glow',
            trailing: '${_basicRating.toStringAsFixed(1)} / 5.0',
          ),
          const SizedBox(height: 8),
          DemoStage(
            child: Column(
              children: [
                RatingBar(
                  value: _basicRating,
                  semanticLabel: 'Star rating',
                  itemSize: 40,
                  spacing: 4,
                  enableHover: true,
                  glowColor: DemoPalette.amber,
                  itemBuilder: (context, index) =>
                      const Icon(Icons.star_rounded, color: DemoPalette.amber),
                  onChangeStart: (v) => setState(
                    () =>
                        _basicEvent = 'onChangeStart(${v.toStringAsFixed(1)})',
                  ),
                  onChanged: (v) => setState(() {
                    _basicRating = v;
                    _basicEvent = 'onChanged(${v.toStringAsFixed(1)})';
                  }),
                  onChangeEnd: (v) => setState(
                    () => _basicEvent = 'onChangeEnd(${v.toStringAsFixed(1)})',
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _basicEvent,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionLabel(
            title: 'Half-Star Step (0.5 · Tap to Clear)',
            trailing: 'Value: ${_fractionalRating.toStringAsFixed(1)}',
          ),
          const SizedBox(height: 8),
          DemoStage(
            child: Center(
              child: RatingBar(
                value: _fractionalRating,
                gestureMode: RatingGestureMode.tap,
                semanticLabel: 'Fractional rating',
                itemSize: 48,
                spacing: 0,
                enableFeedback: false,
                step: 0.5,
                allowClear: true,
                glowColor: DemoPalette.indigo,
                itemBuilder: (context, index) =>
                    const Icon(Icons.star_rounded, color: DemoPalette.indigo),
                onChanged: (rating) =>
                    setState(() => _fractionalRating = rating),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionLabel(
            title: 'Continuous Precision (step: 0.0)',
            trailing: '${_continuousRating.toStringAsFixed(2)} / 5.00',
          ),
          const SizedBox(height: 8),
          DemoStage(
            child: Center(
              child: RatingBar(
                value: _continuousRating,
                semanticLabel: 'Continuous rating',
                itemSize: 36,
                spacing: 4,
                step: 0.0,
                enableHover: true,
                glowColor: DemoPalette.emerald,
                itemBuilder: (context, index) =>
                    const Icon(Icons.star_rounded, color: DemoPalette.emerald),
                onChanged: (v) => setState(() => _continuousRating = v),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomBuildersCard(BuildContext context) {
    final moodLabels = [
      'Needs Work',
      'Below Average',
      'Neutral',
      'Great Experience',
      'Delighted',
    ];
    final moodColors = [
      const Color(0xFFEF4444),
      const Color(0xFFF97316),
      DemoPalette.amber,
      const Color(0xFF84CC16),
      DemoPalette.emerald,
    ];
    final moodIcons = [
      Icons.sentiment_very_dissatisfied_rounded,
      Icons.sentiment_dissatisfied_rounded,
      Icons.sentiment_neutral_rounded,
      Icons.sentiment_satisfied_rounded,
      Icons.sentiment_very_satisfied_rounded,
    ];

    final activeMoodIndex = (_moodRating.round() - 1).clamp(0, 4);
    final activeMoodColor = _moodRating == 0
        ? Colors.grey
        : moodColors[activeMoodIndex];
    final activeMoodLabel = _moodRating == 0
        ? 'Unrated'
        : moodLabels[activeMoodIndex];

    return ShowcaseCard(
      title: 'Custom Builders & Scales',
      subtitle:
          'Per-index widgets, separate unrated outlines, and arbitrary numeric scales.',
      badge: 'Builders',
      badgeColor: DemoPalette.rose,
      highlighted:
          widget.highlightedSection == 'custom' ||
          widget.highlightedSection == 'mood',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionLabel(
            title: 'Per-Index Mood Picker',
            trailing: activeMoodLabel,
          ),
          const SizedBox(height: 8),
          DemoStage(
            child: Column(
              children: [
                RatingBar(
                  value: _moodRating,
                  itemCount: 5,
                  itemSize: 42,
                  spacing: 6,
                  enableHover: true,
                  semanticLabel: 'Mood rating',
                  glowColor: activeMoodColor,
                  itemBuilder: (context, index) =>
                      Icon(moodIcons[index], color: moodColors[index]),
                  onChanged: (rating) => setState(() => _moodRating = rating),
                ),
                const SizedBox(height: 10),
                DemoPill(label: activeMoodLabel, color: activeMoodColor),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _SectionLabel(
            title: 'Custom Unrated Outlines (unratedBuilder)',
            trailing: '${_heartRating.toStringAsFixed(1)} / 5.0',
          ),
          const SizedBox(height: 8),
          DemoStage(
            child: Center(
              child: RatingBar(
                value: _heartRating,
                step: 0.5,
                itemSize: 38,
                spacing: 6,
                enableHover: true,
                semanticLabel: 'Heart rating',
                glowColor: DemoPalette.rose,
                itemBuilder: (context, _) =>
                    const Icon(Icons.favorite_rounded, color: DemoPalette.rose),
                unratedBuilder: (context, _) => Icon(
                  Icons.favorite_border_rounded,
                  color: DemoPalette.rose.withValues(alpha: 0.35),
                ),
                onChanged: (v) => setState(() => _heartRating = v),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _SectionLabel(
            title: 'Custom Scale (5 items · maxRating: 100)',
            trailing: '${_scaledScore.round()} / 100 pts',
          ),
          const SizedBox(height: 8),
          DemoStage(
            child: Center(
              child: RatingBar(
                value: _scaledScore,
                itemCount: 5,
                maxRating: 100,
                step: 5,
                itemSize: 36,
                spacing: 8,
                enableHover: true,
                semanticLabel: 'Scaled score',
                glowColor: DemoPalette.violet,
                itemBuilder: (context, _) =>
                    const Icon(Icons.bolt_rounded, color: DemoPalette.violet),
                unratedBuilder: (context, _) => Icon(
                  Icons.bolt_outlined,
                  color: DemoPalette.violet.withValues(alpha: 0.30),
                ),
                onChanged: (v) => setState(() => _scaledScore = v),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSummaryCard(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    const breakdown = <(int, double)>[
      (5, 0.74),
      (4, 0.16),
      (3, 0.06),
      (2, 0.03),
      (1, 0.01),
    ];

    return ShowcaseCard(
      title: 'Read-Only Review Summary',
      subtitle:
          'Lightweight fractional display for cards, lists, and aggregate breakdowns.',
      badge: 'RatingBarIndicator',
      badgeColor: DemoPalette.emerald,
      highlighted:
          widget.highlightedSection == 'reviews' ||
          widget.highlightedSection == 'indicator',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DemoStage(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '4.7',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1.5,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RatingBarIndicator(
                      value: 4.7,
                      semanticLabel: 'Average rating',
                      itemCount: 5,
                      itemSize: 20,
                      spacing: 2,
                      itemBuilder: (context, _) => const Icon(
                        Icons.star_rounded,
                        color: DemoPalette.amber,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '1,284 reviews',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    children: [
                      for (final (stars, ratio) in breakdown)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.5),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 14,
                                child: Text(
                                  '$stars',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.star_rounded,
                                size: 12,
                                color: DemoPalette.amber,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: LinearProgressIndicator(
                                    value: ratio,
                                    minHeight: 7,
                                    backgroundColor: isDark
                                        ? DemoPalette.darkBorder
                                        : DemoPalette.lightBorder,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          DemoPalette.amber,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              SizedBox(
                                width: 32,
                                child: Text(
                                  '${(ratio * 100).round()}%',
                                  textAlign: TextAlign.end,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const _MiniReviewTile(
            author: 'Maya Lin',
            date: '2 days ago',
            rating: 4.8,
            comment: 'Silky drag gestures and crisp half-star clipping.',
          ),
          const SizedBox(height: 10),
          const _MiniReviewTile(
            author: 'Samir Patel',
            date: '1 week ago',
            rating: 4.3,
            comment: 'Global ThemeExtension kept every card consistent.',
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context) {
    final theme = Theme.of(context);
    return ShowcaseCard(
      title: 'Validated Review Form',
      subtitle:
          'First-class FormField integration with live validation, reset, and save hooks.',
      badge: 'RatingBar.form',
      badgeColor: DemoPalette.violet,
      highlighted:
          widget.highlightedSection == 'form' ||
          widget.highlightedSection == 'forms',
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.always,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DemoStage(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  Text(
                    'How would you rate this package?',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap a star to validate — tap the selected star again to clear.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  RatingBar.form(
                    key: ValueKey<int>(_formResetSeed),
                    initialValue: 0,
                    itemSize: 42,
                    spacing: 6,
                    enableHover: true,
                    semanticLabel: 'Form rating',
                    glowColor: DemoPalette.violet,
                    validator: (value) {
                      if (value == null || value < 1) {
                        return 'Please select a rating';
                      }
                      return null;
                    },
                    itemBuilder: (context, _) => const Icon(
                      Icons.star_rounded,
                      color: DemoPalette.violet,
                    ),
                    onChanged: (_) {
                      if (_formSubmitted) {
                        setState(() => _formSubmitted = false);
                      }
                    },
                    onSaved: (value) {
                      _submittedFormRating = value ?? 0;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in const [
                  'Smooth Drag',
                  'Fractional Precision',
                  'Accessible',
                  'Easy Theming',
                ])
                  FilterChip(
                    label: Text(tag),
                    visualDensity: VisualDensity.compact,
                    selected: _selectedTags.contains(tag),
                    onSelected: (selected) => setState(() {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      final form = _formKey.currentState;
                      if (form != null && form.validate()) {
                        form.save();
                        setState(() => _formSubmitted = true);
                      }
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Submit Rating'),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _formResetSeed++;
                      _formSubmitted = false;
                      _submittedFormRating = 0;
                    });
                  },
                  child: const Text('Reset'),
                ),
              ],
            ),
            if (_formSubmitted) ...[
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: DemoPalette.emerald.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: DemoPalette.emerald.withValues(alpha: 0.35),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 18,
                        color: DemoPalette.emerald,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Saved ${_submittedFormRating.toStringAsFixed(1)} / 5.0 stars!',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: DemoPalette.emerald,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalAndRtlCard(BuildContext context) {
    final theme = Theme.of(context);
    final heatLabels = ['Mild', 'Warm', 'Medium', 'Hot', 'Blazing'];
    final heatLabel = _heatLevel == 0
        ? 'No Heat'
        : heatLabels[(_heatLevel.round() - 1).clamp(0, 4)];

    return ShowcaseCard(
      title: 'Vertical & RTL Directionality',
      subtitle:
          'Bottom-up meters, vertical sliders, and native Right-to-Left fractional clipping.',
      badge: 'Layouts',
      badgeColor: DemoPalette.flame,
      highlighted:
          widget.highlightedSection == 'vertical' ||
          widget.highlightedSection == 'layout',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 820;
          final heatBlock = DemoStage(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RatingBar(
                  value: _heatLevel,
                  semanticLabel: 'Heat rating',
                  direction: Axis.vertical,
                  verticalDirection: VerticalDirection.up,
                  itemCount: 5,
                  itemSize: 32,
                  spacing: 4,
                  enableHover: true,
                  glowColor: DemoPalette.flame,
                  itemBuilder: (context, _) => const Icon(
                    Icons.local_fire_department_rounded,
                    color: DemoPalette.flame,
                  ),
                  onChanged: (v) => setState(() => _heatLevel = v),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Spice Meter',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'VerticalDirection.up',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 10),
                      DemoPill(
                        label: '$heatLabel · ${_heatLevel.round()}/5',
                        color: DemoPalette.flame,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

          final signalBlock = DemoStage(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                RatingBar(
                  value: _signalLevel,
                  semanticLabel: 'Intensity meter',
                  direction: Axis.vertical,
                  verticalDirection: VerticalDirection.up,
                  step: 0.5,
                  itemCount: 5,
                  itemSize: 32,
                  spacing: 4,
                  enableHover: true,
                  glowColor: DemoPalette.indigo,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 5,
                    ),
                    child: SizedBox(
                      width: 24,
                      height: 22,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [DemoPalette.indigo, DemoPalette.violet],
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  onChanged: (v) => setState(() => _signalLevel = v),
                ),
                const SizedBox(width: 16),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Custom Widget Bars',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Gradient pills · step: 0.5',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontFamily: 'monospace',
                        ),
                      ),
                      const SizedBox(height: 10),
                      DemoPill(
                        label: '${_signalLevel.toStringAsFixed(1)} / 5.0',
                        color: DemoPalette.indigo,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );

          final rtlBlock = DemoStage(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'RTL Fractional Clipping',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'textDirection: TextDirection.rtl',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 14),
                RatingBarIndicator(
                  value: 3.5,
                  textDirection: TextDirection.rtl,
                  semanticLabel: 'RTL rating preview',
                  itemCount: 5,
                  itemSize: 32,
                  spacing: 4,
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star_rounded, color: DemoPalette.amber),
                ),
                const SizedBox(height: 10),
                const DemoPill(
                  label: 'Fills Right -> Left (3.5)',
                  color: DemoPalette.amberDeep,
                ),
              ],
            ),
          );

          if (!isWide) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                heatBlock,
                const SizedBox(height: 12),
                signalBlock,
                const SizedBox(height: 12),
                rtlBlock,
              ],
            );
          }

          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: heatBlock),
                const SizedBox(width: 14),
                Expanded(child: signalBlock),
                const SizedBox(width: 14),
                Expanded(child: rtlBlock),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.trailing});

  final String title;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          trailing,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _MiniReviewTile extends StatelessWidget {
  const _MiniReviewTile({
    required this.author,
    required this.date,
    required this.rating,
    required this.comment,
  });

  final String author;
  final String date;
  final double rating;
  final String comment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark
            ? DemoPalette.darkSurfaceSubtle
            : DemoPalette.lightSurfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? DemoPalette.darkBorder : DemoPalette.lightBorder,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          author,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        date,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                RatingBarIndicator(
                  value: rating,
                  itemCount: 5,
                  itemSize: 14,
                  spacing: 1,
                  itemBuilder: (context, _) =>
                      const Icon(Icons.star_rounded, color: DemoPalette.amber),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              comment,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
