import 'package:flutter/material.dart';

import 'tokens.dart';

ThemeData buildAppTheme(AppColors c, Brightness brightness) {
  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: c.chrome,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: c.ink,
      onPrimary: c.page,
      secondary: c.amber,
      onSecondary: c.page,
      error: c.rose,
      onError: c.page,
      surface: c.page,
      onSurface: c.ink,
    ),
    dividerColor: c.hairline,
    splashFactory: NoSplash.splashFactory,
    highlightColor: Colors.transparent,
    // No shadows anywhere in the app — depth comes from hairline borders
    // and the `elev` surface tone.
    appBarTheme: AppBarTheme(
      backgroundColor: c.chrome,
      foregroundColor: c.ink,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
  );
}
