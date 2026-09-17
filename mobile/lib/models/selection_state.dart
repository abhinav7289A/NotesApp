import 'package:flutter/widgets.dart' show Rect;
import 'package:freezed_annotation/freezed_annotation.dart';

part 'selection_state.freezed.dart';

/// The output of every selection change in the reader. This exact shape is
/// P2's entire input (the AI sheet, action bar wiring) — see
/// `P1-mobile-CLAUDE.md` "Selection behaviour". Do not add fields casually;
/// P2 will be built against whatever this contains.
@freezed
abstract class SelectionState with _$SelectionState {
  const factory SelectionState({
    required String text,
    required List<String> blockIds,
    required List<String> pageIds,
    required Rect anchorRect,
  }) = _SelectionState;
}

/// What kind of selection produced a [SelectionState] — drives which sheet
/// title / copy is shown once P2 wires the action bar up. Not persisted.
enum SelectionKind { text, region }
