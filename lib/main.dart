import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:my_pensieve/daos/database.dart' as db;
import 'package:my_pensieve/models/hive/local_sync.dart';
import 'package:my_pensieve/providers/auth.dart';
import 'package:my_pensieve/providers/fragments.dart';
import 'package:my_pensieve/providers/linked_fragments.dart';
import 'package:my_pensieve/repositories/hive/base_repository.dart';
import 'package:my_pensieve/repositories/hive/local_sync_repository.dart';
import 'package:my_pensieve/screens/auth_screen.dart';
import 'package:my_pensieve/screens/category_edit_screent.dart';
import 'package:my_pensieve/screens/category_select_screen.dart';
import 'package:my_pensieve/screens/fragment_detail_screen.dart';
import 'package:my_pensieve/screens/fragment_edit_screen.dart';
import 'package:my_pensieve/screens/fragment_link_screen.dart';
import 'package:my_pensieve/screens/fragments_screen.dart';
import 'package:my_pensieve/screens/tabs_screen.dart';
import 'package:my_pensieve/themes/primary_pallete.dart';
import 'package:my_pensieve/themes/second_pallete.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDocumentDir = await getApplicationDocumentsDirectory();

  Hive
    ..init('${appDocumentDir.path}/pensieve')
    ..registerAdapter(LocalSyncHiveAdapter());

  await BaseHiveRepository.init(LocalSyncHiveRepository.boxInit);

  Get.put(db.AppDatabase());

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
        ChangeNotifierProvider(
          create: (_) => LinkedFragments(),
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
                  titleSmall: const TextStyle(
                    fontFamily: 'University-Oldstyle',
                    fontSize: 16,
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
                  labelSmall: const TextStyle(
                    fontFamily: 'University-Oldstyle',
                    fontSize: 14,
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
            TabScreenWidget.routeName: (context) => const TabScreenWidget(),
            EditFragmentScreenWidget.routeName: (context) =>
                EditFragmentScreenWidget(),
            FragmentListScreenWidget.routeName: (context) =>
                const FragmentListScreenWidget(),
            LinkFragmentsScreenWidget.routeName: (context) =>
                const LinkFragmentsScreenWidget(),
            DetailFragmentScreenWidget.routeName: (context) =>
                const DetailFragmentScreenWidget(),
            CategorySelectScreenWidget.routeName: (context) =>
                const CategorySelectScreenWidget(),
            EditCategoryScreenWidget.routeName: (context) =>
                const EditCategoryScreenWidget(),
          },
        ),
      ),
    );
  }
}
