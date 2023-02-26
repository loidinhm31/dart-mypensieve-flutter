import 'package:flutter/material.dart';
import 'package:my_pensieve/providers/fragments.dart';
import 'package:my_pensieve/screens/fragments_screen.dart';
import 'package:my_pensieve/screens/fragment_detail_screen.dart';
import 'package:my_pensieve/screens/fragment_new_screen.dart';
import 'package:my_pensieve/screens/tabs_screen.dart';
import 'package:my_pensieve/themes/primary_pallete.dart';
import 'package:my_pensieve/themes/second_pallete.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => Fragments(),
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: 'University-Oldstyle',
          colorScheme: ThemeData.light().colorScheme.copyWith(
                primary: PrimaryPalette.kToDark,
                secondary: SecondPallete.kToDark,
                tertiary: Colors.blueGrey,
                background: PrimaryPalette.kToDark.shade900,
              ),
          canvasColor: PrimaryPalette.kToDark.shade500,
          textTheme: ThemeData.light().textTheme.copyWith(
                displayLarge: const TextStyle(
                  fontFamily: 'University-Oldstyle',
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                displayMedium: const TextStyle(
                  fontFamily: 'University-Oldstyle',
                  fontSize: 16,
                  color: Colors.white54,
                  fontWeight: FontWeight.bold,
                ),
                displaySmall: const TextStyle(
                  fontFamily: 'University-Oldstyle',
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
                titleLarge: const TextStyle(
                  fontFamily: 'University-Oldstyle',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: PrimaryPalette.kToDark,
                ),
                titleMedium: const TextStyle(
                  fontFamily: 'University-Oldstyle',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: PrimaryPalette.kToDark,
                ),
                labelLarge: const TextStyle(
                  fontFamily: 'University-Oldstyle',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: SecondPallete.kToDark,
                ),
                labelMedium: const TextStyle(
                  fontFamily: 'University-Oldstyle',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: SecondPallete.kToDark,
                ),
              ),
        ),
        initialRoute: '/',
        routes: {
          '/': (ctx) => const TabScreenWidget(),
          NewFragmentScreenWidget.routeName: (ctx) =>
              const NewFragmentScreenWidget(),
          FragmentListScreenWidget.routeName: (ctx) =>
              const FragmentListScreenWidget(),
          DetailFragmentScreenWidget.routeName: (ctx) =>
              const DetailFragmentScreenWidget(),
        },
      ),
    );
  }
}
