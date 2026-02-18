import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:rni_app/features/main/providers/theme_provider.dart';
import 'package:rni_app/features/themes/app_theme.dart';
import 'package:rni_app/features/main/pages/home_page_navigation.dart';

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    final darkMode = context.watch<ThemeProvider>().darkMode;
    return MaterialApp(
      title: 'Rni Air Purifier',
      theme: darkMode ? darkTheme : lightTheme,
      home: const HomePage(title: 'Rni Air Purifier'),
    );
  }
}
