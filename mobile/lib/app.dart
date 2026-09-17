import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/providers.dart';
import 'library/library_screen.dart';
import 'theme/app_theme.dart';
import 'theme/tokens.dart';

class MarginaliaApp extends ConsumerWidget {
  const MarginaliaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Marginalia',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: buildAppTheme(AppColors.light, Brightness.light),
      darkTheme: buildAppTheme(AppColors.dark, Brightness.dark),
      home: const LibraryScreen(),
    );
  }
}
