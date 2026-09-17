import 'package:flutter/material.dart';

import '../models/selection_state.dart';
import '../theme/tokens.dart';

/// The floating selection action bar. Per `P1-mobile-CLAUDE.md`, every
/// button is wired to [debugPrint] only — real behaviour (the AI sheet,
/// highlighting, notes) is P2's job. This widget's contract with P2 is the
/// [SelectionState] it's built from, not its callbacks.
///
/// Must be placed inside a [Stack] sized to the viewport — it positions
/// itself absolutely, floating above [selection.anchorRect] and flipping
/// below when there isn't room above, per the brief ("never off-screen").
///
/// Entrance animation matches the design's `barIn` (whole bar: opacity,
/// translateY, scale) + `barItem` (each child, staggered) keyframes. It
/// plays once per mount — this widget is only ever built while a selection
/// is active (see `reader_screen.dart`), so mounting *is* "a selection just
/// started," the correct trigger.
class SelectionActionBar extends StatefulWidget {
  const SelectionActionBar({
    super.key,
    required this.selection,
    required this.viewportSize,
    required this.colors,
  });

  final SelectionState selection;
  final Size viewportSize;
  final AppColors colors;

  static const double _barHeight = 54;
  static const double _margin = 12;
  static const double _gap = 10;

  @override
  State<SelectionActionBar> createState() => _SelectionActionBarState();
}

class _SelectionActionBarState extends State<SelectionActionBar> with SingleTickerProviderStateMixin {
  // Covers the longest `barItem` stagger (170ms) plus its own 220ms run.
  static const _totalDuration = Duration(milliseconds: 390);
  late final AnimationController _controller;
  late final Animation<double> _barOpacity;
  late final Animation<double> _barTranslateY;
  late final Animation<double> _barScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _totalDuration)..forward();
    // Design's barIn: 200ms cubic-bezier(.2,.9,.3,1.25) — expressed directly
    // as a Cubic so the overshoot past 1.0 is exact, not approximated by a
    // built-in curve.
    final barCurve = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0, 200 / 390, curve: Cubic(0.2, 0.9, 0.3, 1.25)),
    );
    _barOpacity = Tween(begin: 0.0, end: 1.0).animate(barCurve);
    _barTranslateY = Tween(begin: 10.0, end: 0.0).animate(barCurve);
    _barScale = Tween(begin: 0.94, end: 1.0).animate(barCurve);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selection = widget.selection;
    final colors = widget.colors;
    final anchor = selection.anchorRect;

    double top = anchor.top - SelectionActionBar._barHeight - SelectionActionBar._gap;
    if (top < SelectionActionBar._margin) {
      top = anchor.bottom + SelectionActionBar._gap; // flip below when too close to the top
    }
    top = top.clamp(
      SelectionActionBar._margin,
      widget.viewportSize.height - SelectionActionBar._barHeight - SelectionActionBar._margin,
    );

    return Positioned(
      left: SelectionActionBar._margin,
      right: SelectionActionBar._margin,
      top: top,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => Opacity(
          opacity: _barOpacity.value,
          child: Transform.translate(
            offset: Offset(0, _barTranslateY.value),
            child: Transform.scale(scale: _barScale.value, child: child),
          ),
        ),
        child: Material(
          color: colors.bar,
          borderRadius: BorderRadius.circular(AppRadii.floatingBar),
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: SizedBox(
              height: AppControlHeight.barButton,
              child: Row(
                children: [
                  _BarItemFade(
                    controller: _controller,
                    delayMs: 20,
                    child: _AskButton(colors: colors, blockIds: selection.blockIds),
                  ),
                  Expanded(
                    child: _BarItemFade(
                      controller: _controller,
                      delayMs: 50,
                      child: _BarLabel('Summarise', colors: colors, blockIds: selection.blockIds),
                    ),
                  ),
                  Expanded(
                    child: _BarItemFade(
                      controller: _controller,
                      delayMs: 80,
                      child: _BarLabel('Simplify', colors: colors, blockIds: selection.blockIds),
                    ),
                  ),
                  Expanded(
                    child: _BarItemFade(
                      controller: _controller,
                      delayMs: 110,
                      child: _BarLabel('Translate', colors: colors, blockIds: selection.blockIds),
                    ),
                  ),
                  Container(width: 1, height: 24, color: colors.barInk.withValues(alpha: 0.2)),
                  _BarItemFade(
                    controller: _controller,
                    delayMs: 140,
                    child: _IconStub(icon: 'highlight', colors: colors, blockIds: selection.blockIds),
                  ),
                  _BarItemFade(
                    controller: _controller,
                    delayMs: 170,
                    child: _IconStub(icon: 'note', colors: colors, blockIds: selection.blockIds),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// One `barItem` child: 220ms ease-out fade + slight rise, starting [delayMs]
/// into the parent bar's entrance — see the design's staggered
/// 20/50/80/110/140/170ms delays. Shares the bar's own [controller] rather
/// than running a separate one per child.
class _BarItemFade extends StatelessWidget {
  const _BarItemFade({required this.controller, required this.delayMs, required this.child});

  final AnimationController controller;
  final int delayMs;
  final Widget child;

  static const _itemDuration = 220;
  static const _totalMs = 390;

  @override
  Widget build(BuildContext context) {
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(delayMs / _totalMs, (delayMs + _itemDuration) / _totalMs, curve: Curves.easeOut),
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) => Opacity(
        opacity: animation.value,
        child: Transform.translate(offset: Offset(0, 4 * (1 - animation.value)), child: child),
      ),
    );
  }
}

class _AskButton extends StatelessWidget {
  const _AskButton({required this.colors, required this.blockIds});
  final AppColors colors;
  final List<String> blockIds;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => debugPrint('action_bar: ask blocks=$blockIds'),
      child: Container(
        height: AppControlHeight.barButton,
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.amber,
          borderRadius: BorderRadius.circular(AppRadii.secondaryButton),
        ),
        child: Text('Ask', style: AppText.primaryButtonLabel(kAskButtonInk)),
      ),
    );
  }
}

class _BarLabel extends StatelessWidget {
  const _BarLabel(this.label, {required this.colors, required this.blockIds});
  final String label;
  final AppColors colors;
  final List<String> blockIds;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => debugPrint('action_bar: ${label.toLowerCase()} blocks=$blockIds'),
      child: Container(
        alignment: Alignment.center,
        child: Text(label, style: AppText.secondaryButtonLabel(colors.barInk)),
      ),
    );
  }
}

class _IconStub extends StatelessWidget {
  const _IconStub({required this.icon, required this.colors, required this.blockIds});
  final String icon;
  final AppColors colors;
  final List<String> blockIds;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => debugPrint('action_bar: $icon blocks=$blockIds'),
      child: Container(
        width: 40,
        alignment: Alignment.center,
        child: Icon(
          // P1 has no bespoke icon set wired up yet — stock Material icons
          // stand in. Swap for the app's real icon set (thin 1.2-1.5px
          // strokes, per the design handoff) when one exists.
          icon == 'highlight' ? Icons.highlight_outlined : Icons.sticky_note_2_outlined,
          size: 18,
          color: colors.barInk,
        ),
      ),
    );
  }
}
