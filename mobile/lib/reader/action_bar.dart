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
class SelectionActionBar extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final anchor = selection.anchorRect;

    double top = anchor.top - _barHeight - _gap;
    if (top < _margin) {
      top = anchor.bottom + _gap; // flip below when too close to the top
    }
    top = top.clamp(_margin, viewportSize.height - _barHeight - _margin);

    return Positioned(
      left: _margin,
      right: _margin,
      top: top,
      child: Material(
        color: colors.bar,
        borderRadius: BorderRadius.circular(AppRadii.floatingBar),
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: SizedBox(
            height: 44,
            child: Row(
              children: [
                _AskButton(colors: colors, blockIds: selection.blockIds),
                _BarLabel('Summarise', colors: colors, blockIds: selection.blockIds),
                _BarLabel('Simplify', colors: colors, blockIds: selection.blockIds),
                _BarLabel('Translate', colors: colors, blockIds: selection.blockIds),
                Container(width: 1, height: 24, color: colors.barInk.withValues(alpha: 0.2)),
                _IconStub(icon: 'highlight', colors: colors, blockIds: selection.blockIds),
                _IconStub(icon: 'note', colors: colors, blockIds: selection.blockIds),
              ],
            ),
          ),
        ),
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
        height: 44,
        margin: const EdgeInsets.only(right: 4),
        padding: const EdgeInsets.symmetric(horizontal: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.amber,
          borderRadius: BorderRadius.circular(AppRadii.secondaryButton),
        ),
        child: Text('Ask', style: AppText.primaryButtonLabel(const Color(0xFF1A1206))),
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
    return Expanded(
      child: GestureDetector(
        onTap: () => debugPrint('action_bar: ${label.toLowerCase()} blocks=$blockIds'),
        child: Container(
          alignment: Alignment.center,
          child: Text(label, style: AppText.secondaryButtonLabel(colors.barInk)),
        ),
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
