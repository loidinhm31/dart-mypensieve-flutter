import 'package:flutter/material.dart';
import 'package:my_pensieve/providers/auth.dart';
import 'package:my_pensieve/providers/fragments.dart';
import 'package:my_pensieve/screens/auth_screen.dart';
import 'package:my_pensieve/screens/fragment_detail_screen.dart';
import 'package:my_pensieve/screens/fragment_edit_screen.dart';
import 'package:my_pensieve/screens/fragment_link_screen.dart';
import 'package:my_pensieve/screens/fragments_screen.dart';
import 'package:my_pensieve/screens/tabs_screen.dart';
import 'package:my_pensieve/themes/primary_pallete.dart';
import 'package:my_pensieve/themes/second_pallete.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (_) => Fragments(),
        ),
      ],
      child: Consumer<Auth>(
        builder: (context, auth, _) => MaterialApp(
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
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  displayMedium: const TextStyle(
                    fontFamily: 'University-Oldstyle',
                    fontSize: 18,
                    color: Colors.white54,
                    fontWeight: FontWeight.bold,
                  ),
                  displaySmall: const TextStyle(
                    fontFamily: 'University-Oldstyle',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                  titleLarge: const TextStyle(
                    fontFamily: 'University-Oldstyle',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  titleMedium: const TextStyle(
                    fontFamily: 'University-Oldstyle',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  labelLarge: const TextStyle(
                    fontFamily: 'University-Oldstyle',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: SecondPallete.kToDark,
                  ),
                  labelMedium: const TextStyle(
                    fontFamily: 'University-Oldstyle',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: SecondPallete.kToDark,
                  ),
                ),
          ),
          home: auth.isAuth
              ? const TabScreenWidget()
              : FutureBuilder(
                  future: auth.tryAutoLogin(),
                  builder: (context, authResultSnapshot) =>
                      authResultSnapshot.connectionState ==
                              ConnectionState.waiting
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : const AuthScreen(),
                ),
          routes: {
            TabScreenWidget.routeName: (ctx) => const TabScreenWidget(),
            EditFragmentScreenWidget.routeName: (ctx) =>
                EditFragmentScreenWidget(),
            FragmentListScreenWidget.routeName: (ctx) =>
                const FragmentListScreenWidget(),
            LinkFragmentsScreenWidget.routeName: (ctx) =>
                const LinkFragmentsScreenWidget(),
            DetailFragmentScreenWidget.routeName: (ctx) =>
                const DetailFragmentScreenWidget(),
          },
        ),
      ),
    );
  }
}
