import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design tokens transcribed verbatim from `P1-mobile-CLAUDE.md` /
/// `design_handoff_marginalia/README.md`. Colour is semantic, not
/// decorative: [amber] always and only means "the student did this",
/// [rose] always and only means "the AI did this". Never repurpose either
/// for generic accent or emphasis, and never invert the page for dark mode
/// (see `reader_screen.dart`'s tone filter) — a straight invert turns
/// photographs and figures into negatives.
class AppColors {
  const AppColors({
    required this.page,
    required this.chrome,
    required this.elev,
    required this.ink,
    required this.ink2,
    required this.hairline,
    required this.amber,
    required this.rose,
    required this.selectionFill,
    required this.bar,
    required this.barInk,
  });

  final Color page;
  final Color chrome;
  final Color elev;
  final Color ink;
  final Color ink2;
  final Color hairline;
  final Color amber;
  final Color rose;
  final Color selectionFill;
  final Color bar;
  final Color barInk;

  static const light = AppColors(
    page: Color(0xFFFFFFFF),
    chrome: Color(0xFFEDF0F4),
    elev: Color(0xFFF7F9FB),
    ink: Color(0xFF16181D),
    ink2: Color(0xFF5A6472),
    hairline: Color(0xFFD8DCE2),
    amber: Color(0xFFC77A00),
    rose: Color(0xFFA8324A),
    selectionFill: Color(0x66FFE9A8), // #FFE9A8 @ 40%
    bar: Color(0xFF16181D),
    barInk: Color(0xFFFFFFFF),
  );

  static const dark = AppColors(
    page: Color(0xFF20242B),
    chrome: Color(0xFF14161A),
    elev: Color(0xFF1B1F26),
    ink: Color(0xFFE4E7EC),
    ink2: Color(0xFF9AA3B0),
    hairline: Color(0xFF343A44),
    amber: Color(0xFFE8A33D),
    rose: Color(0xFFE07A93),
    selectionFill: Color(0x8C4A3A14), // #4A3A14 @ 55%
    bar: Color(0xFF2E343D),
    barInk: Color(0xFFE9ECF1),
  );
}

/// Spacing scale in use across the app. Screen gutters 18-20, card padding
/// 14-16, list-row padding 14.
class AppSpacing {
  static const double xs2 = 2;
  static const double xs = 3;
  static const double sm = 5;
  static const double smMd = 6;
  static const double md = 7;
  static const double mdLg = 9;
  static const double lg = 11;
  static const double lgXl = 12;
  static const double xl = 14;
  static const double xl2 = 16;
  static const double xl3 = 18;
  static const double xl4 = 20;
  static const double xl5 = 22;
  static const double xl6 = 26;
}

class AppRadii {
  static const double keyboardKey = 5;
  static const double segmentedButton = 8;
  static const double secondaryButton = 10;
  static const double primaryButton = 12;
  static const double floatingBar = 15;
  static const double sheetTop = 18;
  /// Note blocks, document pages, figures and tables are square — radius 0.
  static const double paper = 0;
}

/// Plex Mono is reserved for provenance — page references, page numbers,
/// quota counters, section kickers. Never use it for prose.
class AppText {
  static TextStyle documentBody(Color color) => GoogleFonts.ibmPlexSerif(
        fontSize: 15.5,
        height: 1.68,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle documentH2(Color color) => GoogleFonts.ibmPlexSerif(
        fontSize: 17.5,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle screenTitle(Color color) => GoogleFonts.ibmPlexSerif(
        fontSize: 22,
        height: 1.22,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle navBarTitle(Color color) => GoogleFonts.ibmPlexSans(
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle primaryButtonLabel(Color color) => GoogleFonts.ibmPlexSans(
        fontSize: 13.25,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle secondaryButtonLabel(Color color) => GoogleFonts.ibmPlexSans(
        fontSize: 12.25,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle bodyChrome(Color color) => GoogleFonts.ibmPlexSans(
        fontSize: 11.5,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle caption(Color color) => GoogleFonts.ibmPlexSans(
        fontSize: 10.75,
        height: 1.5,
        fontWeight: FontWeight.w400,
        color: color,
      );

  /// Source references, page numbers, counters, labels — provenance only.
  static TextStyle provenance(Color color) => GoogleFonts.ibmPlexMono(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: color,
      );
}
